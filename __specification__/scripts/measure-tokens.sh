#!/bin/bash

# Token Usage Metrics Tracker
# Measures and tracks token usage for optimization

# Configuration
METRICS_FILE="__specification__/metrics/token-usage.csv"
BASELINE_FILE="__specification__/metrics/baseline.json"

# Token estimation (rough: 1 token per 4 characters, adjust based on model)
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $((char_count / 4))
}

# Measure skill token usage
measure_skill() {
    local skill_name="$1"
    local skill_path=".claude/skills/$skill_name"

    if [ ! -d "$skill_path" ]; then
        echo "Skill not found: $skill_name"
        return 1
    fi

    local total_tokens=0

    # Measure main skill files
    for file in "$skill_path"/*.md; do
        if [ -f "$file" ]; then
            content=$(cat "$file")
            tokens=$(estimate_tokens "$content")
            total_tokens=$((total_tokens + tokens))
        fi
    done

    echo "$total_tokens"
}

# Compare before/after optimization
compare_optimization() {
    local skill="$1"
    local before_file="$2"
    local after_file="$3"

    local before_tokens=$(estimate_tokens "$(cat "$before_file")")
    local after_tokens=$(estimate_tokens "$(cat "$after_file")")
    local reduction=$((before_tokens - after_tokens))
    local percent=$((reduction * 100 / before_tokens))

    echo "Skill: $skill"
    echo "Before: $before_tokens tokens"
    echo "After: $after_tokens tokens"
    echo "Reduction: $reduction tokens ($percent%)"
}

# Record metrics
record_metric() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local skill="$1"
    local tokens="$2"
    local type="${3:-measurement}"

    mkdir -p "$(dirname "$METRICS_FILE")"

    # Create CSV header if file doesn't exist
    if [ ! -f "$METRICS_FILE" ]; then
        echo "timestamp,skill,tokens,type" > "$METRICS_FILE"
    fi

    echo "$timestamp,$skill,$tokens,$type" >> "$METRICS_FILE"
}

# Generate report
generate_report() {
    echo "## Token Usage Report"
    echo ""
    echo "### Current Usage by Skill"
    echo ""

    for skill_dir in .claude/skills/navi-*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            tokens=$(measure_skill "$skill_name")
            echo "- $skill_name: $tokens tokens"
            record_metric "$skill_name" "$tokens" "current"
        fi
    done

    echo ""
    echo "### Optimization Summary"
    echo ""

    # Calculate totals
    local total_before=0
    local total_after=0

    # Read baseline if exists
    if [ -f "$BASELINE_FILE" ]; then
        total_before=$(grep '"total":' "$BASELINE_FILE" | grep -oE '[0-9]+')
    fi

    # Calculate current total
    for skill_dir in .claude/skills/navi-*; do
        if [ -d "$skill_dir" ]; then
            tokens=$(measure_skill "$(basename "$skill_dir")")
            total_after=$((total_after + tokens))
        fi
    done

    if [ $total_before -gt 0 ]; then
        local reduction=$((total_before - total_after))
        local percent=$((reduction * 100 / total_before))
        echo "- Baseline: $total_before tokens"
        echo "- Current: $total_after tokens"
        echo "- Reduction: $reduction tokens"
        echo "- **Optimization: ${percent}% reduction**"
    else
        echo "- Current Total: $total_after tokens"
        echo "- No baseline available for comparison"
    fi

    # Save current as baseline if not exists
    if [ ! -f "$BASELINE_FILE" ]; then
        mkdir -p "$(dirname "$BASELINE_FILE")"
        echo "{\"total\": $total_after, \"timestamp\": \"$(date +"%Y-%m-%d %H:%M:%S")\"}" > "$BASELINE_FILE"
    fi
}

# Analyze trends
analyze_trends() {
    if [ ! -f "$METRICS_FILE" ]; then
        echo "No metrics data available"
        return
    fi

    echo "## Token Usage Trends"
    echo ""

    # Get unique skills
    skills=$(tail -n +2 "$METRICS_FILE" | cut -d',' -f2 | sort -u)

    for skill in $skills; do
        echo "### $skill"
        # Get last 5 measurements
        grep ",$skill," "$METRICS_FILE" | tail -5 | while IFS=',' read -r ts sk tok typ; do
            echo "- $ts: $tok tokens ($typ)"
        done
        echo ""
    done
}

# Main execution
main() {
    local action="${1:-report}"

    case "$action" in
        measure)
            skill="${2:-}"
            if [ -z "$skill" ]; then
                echo "Usage: $0 measure <skill-name>"
                exit 1
            fi
            tokens=$(measure_skill "$skill")
            echo "$skill: $tokens tokens"
            record_metric "$skill" "$tokens"
            ;;
        report)
            generate_report
            ;;
        trends)
            analyze_trends
            ;;
        compare)
            skill="${2:-}"
            before="${3:-}"
            after="${4:-}"
            if [ -z "$skill" ] || [ -z "$before" ] || [ -z "$after" ]; then
                echo "Usage: $0 compare <skill> <before-file> <after-file>"
                exit 1
            fi
            compare_optimization "$skill" "$before" "$after"
            ;;
        *)
            echo "Usage: $0 {measure|report|trends|compare} [args]"
            exit 1
            ;;
    esac
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi