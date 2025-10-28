#!/bin/bash

# Common Validation Library
# Reusable validation logic to eliminate duplication

# Source common files
source "$(dirname "$0")/common-files.sh" 2>/dev/null || true

# Validation status codes
readonly VALID=0
readonly INVALID=1
readonly WARNING=2

# Validation result tracking (using files for compatibility)
VALIDATION_RESULTS_FILE="/tmp/navi-validation-results-$$"
VALIDATION_MESSAGES_FILE="/tmp/navi-validation-messages-$$"

# Initialize
> "$VALIDATION_RESULTS_FILE"
> "$VALIDATION_MESSAGES_FILE"

# Core validation framework
validate() {
    local name="$1"
    local value="$2"
    local validator="$3"
    shift 3

    if $validator "$value" "$@"; then
        echo "$name=$VALID" >> "$VALIDATION_RESULTS_FILE"
        echo "$name=✓ Valid" >> "$VALIDATION_MESSAGES_FILE"
        return $VALID
    else
        echo "$name=$INVALID" >> "$VALIDATION_RESULTS_FILE"
        local msg=$(grep "^validation_message=" /tmp/navi-validation-msg-$$ 2>/dev/null | cut -d'=' -f2- || echo "validation failed")
        echo "$name=✗ Invalid: $msg" >> "$VALIDATION_MESSAGES_FILE"
        rm -f /tmp/navi-validation-msg-$$
        return $INVALID
    fi
}

# Helper to set validation message
set_validation_message() {
    echo "validation_message=$1" > /tmp/navi-validation-msg-$$
}

# File validators
validate_file_exists() {
    local file="$1"

    if [ -f "$file" ]; then
        return $VALID
    else
        set_validation_message "File not found: $file"
        return $INVALID
    fi
}

validate_dir_exists() {
    local dir="$1"

    if [ -d "$dir" ]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Directory not found: $dir"
        return $INVALID
    fi
}

validate_file_not_empty() {
    local file="$1"

    if [ -f "$file" ] && [ -s "$file" ]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="File is empty or missing: $file"
        return $INVALID
    fi
}

validate_file_extension() {
    local file="$1"
    local expected_ext="$2"

    if [[ "$file" == *".$expected_ext" ]]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Invalid extension, expected: .$expected_ext"
        return $INVALID
    fi
}

# Content validators
validate_markdown() {
    local file="$1"

    # Check basic markdown structure
    if ! grep -q "^#" "$file"; then
        validation_messages["${FUNCNAME[1]}"]="No headers found in markdown"
        return $INVALID
    fi

    # Check for common markdown issues
    local issues=()

    # Check for broken links
    if grep -q "\[.*\]()" "$file"; then
        issues+=("Empty links found")
    fi

    # Check for incomplete code blocks
    local code_blocks_open=$(grep -c '```' "$file")
    if [ $((code_blocks_open % 2)) -ne 0 ]; then
        issues+=("Unclosed code blocks")
    fi

    if [ ${#issues[@]} -gt 0 ]; then
        validation_messages["${FUNCNAME[1]}"]="${issues[*]}"
        return $WARNING
    fi

    return $VALID
}

validate_json() {
    local file="$1"

    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        return $VALID
    elif which jq > /dev/null 2>&1; then
        if jq . "$file" > /dev/null 2>&1; then
            return $VALID
        fi
    else
        # Basic check
        if grep -q "^{" "$file" && grep -q "}$" "$file"; then
            return $WARNING
        fi
    fi

    validation_messages["${FUNCNAME[1]}"]="Invalid JSON format"
    return $INVALID
}

validate_yaml() {
    local file="$1"

    if which python3 > /dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            return $VALID
        fi
    fi

    # Basic check
    if grep -q "^---" "$file" || grep -q "^[a-z_]*:" "$file"; then
        return $WARNING
    fi

    validation_messages["${FUNCNAME[1]}"]="Invalid YAML format"
    return $INVALID
}

# Workflow validators
validate_phase() {
    local phase="$1"
    local valid_phases="init specify plan tasks implement validate complete unknown"

    if [[ " $valid_phases " =~ " $phase " ]]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Invalid phase: $phase"
        return $INVALID
    fi
}

validate_spec_file() {
    local spec_file="$1"

    # Check file exists
    if ! validate_file_exists "$spec_file"; then
        return $INVALID
    fi

    # Check required sections
    local required_sections=("User Stories" "Acceptance Criteria" "Success Metrics")
    local missing=()

    for section in "${required_sections[@]}"; do
        if ! grep -q "## $section" "$spec_file"; then
            missing+=("$section")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        validation_messages["${FUNCNAME[1]}"]="Missing sections: ${missing[*]}"
        return $WARNING
    fi

    # Check for priorities
    if ! grep -q "\[P[123]\]" "$spec_file"; then
        validation_messages["${FUNCNAME[1]}"]="No priority markers found"
        return $WARNING
    fi

    return $VALID
}

validate_plan_file() {
    local plan_file="$1"

    if ! validate_file_exists "$plan_file"; then
        return $INVALID
    fi

    # Check for ADRs
    if ! grep -q "ADR\|Decision\|Architecture" "$plan_file"; then
        validation_messages["${FUNCNAME[1]}"]="No architecture decisions found"
        return $WARNING
    fi

    # Check for components
    if ! grep -q "Component\|Module\|Service" "$plan_file"; then
        validation_messages["${FUNCNAME[1]}"]="No component definitions found"
        return $WARNING
    fi

    return $VALID
}

validate_tasks_file() {
    local tasks_file="$1"

    if ! validate_file_exists "$tasks_file"; then
        return $INVALID
    fi

    # Check for task markers
    if ! grep -q "\[ \]\|\[x\]" "$tasks_file"; then
        validation_messages["${FUNCNAME[1]}"]="No task checkboxes found"
        return $INVALID
    fi

    # Check for task IDs
    if ! grep -q "T[0-9]\{3\}" "$tasks_file"; then
        validation_messages["${FUNCNAME[1]}"]="No task IDs (T###) found"
        return $WARNING
    fi

    # Check for parallel markers
    if ! grep -q "\[P\]" "$tasks_file"; then
        validation_messages["${FUNCNAME[1]}"]="No parallel markers [P] found"
        return $WARNING
    fi

    return $VALID
}

# String validators
validate_not_empty() {
    local value="$1"

    if [ -n "$value" ]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Value is empty"
        return $INVALID
    fi
}

validate_length() {
    local value="$1"
    local min_length="${2:-0}"
    local max_length="${3:-999999}"

    local length=${#value}

    if [ $length -ge $min_length ] && [ $length -le $max_length ]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Length must be between $min_length and $max_length"
        return $INVALID
    fi
}

validate_pattern() {
    local value="$1"
    local pattern="$2"

    if [[ "$value" =~ $pattern ]]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Does not match pattern: $pattern"
        return $INVALID
    fi
}

# Numeric validators
validate_number() {
    local value="$1"

    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Not a valid number: $value"
        return $INVALID
    fi
}

validate_range() {
    local value="$1"
    local min="${2:--999999}"
    local max="${3:-999999}"

    if ! validate_number "$value"; then
        return $INVALID
    fi

    if [ "$value" -ge "$min" ] && [ "$value" -le "$max" ]; then
        return $VALID
    else
        validation_messages["${FUNCNAME[1]}"]="Value must be between $min and $max"
        return $INVALID
    fi
}

# Composite validators
validate_workflow_ready() {
    local feature_dir="$1"

    local all_valid=true

    # Check directory structure
    if ! validate_dir_exists "$feature_dir"; then
        all_valid=false
    fi

    # Check required files
    for file_type in spec plan tasks; do
        if ! validate_file_exists "$feature_dir/${file_type}.md"; then
            echo "Missing: ${file_type}.md"
            all_valid=false
        fi
    done

    # Validate file contents
    if [ -f "$feature_dir/spec.md" ]; then
        validate_spec_file "$feature_dir/spec.md" || all_valid=false
    fi

    if [ -f "$feature_dir/plan.md" ]; then
        validate_plan_file "$feature_dir/plan.md" || all_valid=false
    fi

    if [ -f "$feature_dir/tasks.md" ]; then
        validate_tasks_file "$feature_dir/tasks.md" || all_valid=false
    fi

    if $all_valid; then
        return $VALID
    else
        return $INVALID
    fi
}

# Validation report generation
generate_validation_report() {
    echo "## Validation Report"
    echo ""
    echo "Date: $(date)"
    echo ""

    local total=0
    local passed=0
    local warnings=0
    local failed=0

    for name in "${!validation_results[@]}"; do
        ((total++))

        case "${validation_results[$name]}" in
            $VALID)
                ((passed++))
                echo "✓ $name: ${validation_messages[$name]}"
                ;;
            $WARNING)
                ((warnings++))
                echo "⚠️ $name: ${validation_messages[$name]}"
                ;;
            $INVALID)
                ((failed++))
                echo "✗ $name: ${validation_messages[$name]}"
                ;;
        esac
    done

    echo ""
    echo "### Summary"
    echo "- Total checks: $total"
    echo "- Passed: $passed"
    echo "- Warnings: $warnings"
    echo "- Failed: $failed"

    if [ $failed -eq 0 ]; then
        echo ""
        echo "**Status: ✅ All validations passed**"
        return $VALID
    elif [ $warnings -gt 0 ] && [ $failed -eq 0 ]; then
        echo ""
        echo "**Status: ⚠️ Passed with warnings**"
        return $WARNING
    else
        echo ""
        echo "**Status: ❌ Validation failed**"
        return $INVALID
    fi
}

# Clear validation results
clear_validations() {
    validation_results=()
    validation_messages=()
}

# Batch validation
validate_all() {
    local validators=("$@")

    for validator in "${validators[@]}"; do
        $validator
    done

    generate_validation_report
}

# Export functions if sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export -f validate
    export -f validate_file_exists validate_dir_exists
    export -f validate_file_not_empty validate_file_extension
    export -f validate_markdown validate_json validate_yaml
    export -f validate_phase validate_spec_file validate_plan_file validate_tasks_file
    export -f validate_not_empty validate_length validate_pattern
    export -f validate_number validate_range
    export -f validate_workflow_ready
    export -f generate_validation_report clear_validations
fi

# Test if run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Testing Common Validation..."

    # Test file validation
    test_file="/tmp/test-validate-$$.md"
    echo "# Test File" > "$test_file"
    echo "## User Stories" >> "$test_file"
    echo "[P1] Test story" >> "$test_file"

    validate "test_file" "$test_file" validate_file_exists
    validate "test_markdown" "$test_file" validate_markdown
    validate "test_spec" "$test_file" validate_spec_file

    # Test string validation
    validate "not_empty" "hello" validate_not_empty
    validate "length" "test" validate_length 2 10
    validate "pattern" "T001" validate_pattern "T[0-9]{3}"

    # Test number validation
    validate "number" "42" validate_number
    validate "range" "5" validate_range 1 10

    # Generate report
    generate_validation_report

    # Cleanup
    rm -f "$test_file"
fi