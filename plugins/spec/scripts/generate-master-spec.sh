#!/bin/bash
# Generate Master Specification
# Aggregates all feature specs, architecture, and decisions into one document

set -euo pipefail

SPEC_DIR="${PWD}/.spec"
FEATURES_DIR="${PWD}/features"
MEMORY_DIR="${PWD}/.spec-memory"
OUTPUT_FILE="${SPEC_DIR}/master-spec.md"

generate_master_spec() {
    echo "📝 Generating Master Specification..."

    # Create temp file
    local temp_file="${OUTPUT_FILE}.tmp"

    # Header
    cat > "$temp_file" << EOF
# $(basename "$(pwd)") - Master Specification

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Version**: $(cat "${SPEC_DIR}/version" 2>/dev/null || echo "3.0.0")
**Features**: $(find "$FEATURES_DIR" -maxdepth 1 -type d | wc -l | tr -d ' ') total

---

## Table of Contents

1. [Product Vision](#product-vision)
2. [Architecture](#architecture)
3. [Features](#features)
   - [Completed Features](#completed-features)
   - [Active Features](#active-features)
   - [Planned Features](#planned-features)
4. [Technical Decisions](#technical-decisions)
5. [Metrics](#metrics)

---

EOF

    # Product Vision
    echo "## Product Vision" >> "$temp_file"
    echo "" >> "$temp_file"
    if [[ -f "${SPEC_DIR}/product-requirements.md" ]]; then
        cat "${SPEC_DIR}/product-requirements.md" >> "$temp_file"
    else
        echo "*No product requirements defined yet.*" >> "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Architecture
    echo "## Architecture" >> "$temp_file"
    echo "" >> "$temp_file"
    if [[ -f "${SPEC_DIR}/architecture-blueprint.md" ]]; then
        cat "${SPEC_DIR}/architecture-blueprint.md" >> "$temp_file"
    else
        echo "*No architecture blueprint defined yet.*" >> "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Features
    echo "## Features" >> "$temp_file"
    echo "" >> "$temp_file"

    # Completed Features
    echo "### ✅ Completed Features" >> "$temp_file"
    echo "" >> "$temp_file"
    local found_completed=false
    for feature_dir in "$FEATURES_DIR"/*/; do
        [[ -d "$feature_dir" ]] || continue
        local feature_name=$(basename "$feature_dir")
        local spec_file="${feature_dir}/spec.md"

        if [[ -f "$spec_file" ]]; then
            # Check if completed (simple heuristic: look for completion marker or date)
            if grep -q "Status.*[Cc]omplete" "$spec_file" 2>/dev/null; then
                found_completed=true
                echo "#### Feature: $feature_name" >> "$temp_file"
                echo "" >> "$temp_file"
                # Include first 50 lines of spec
                head -n 50 "$spec_file" >> "$temp_file"
                echo "" >> "$temp_file"
                echo "<details>" >> "$temp_file"
                echo "<summary>Full Specification</summary>" >> "$temp_file"
                echo "" >> "$temp_file"
                cat "$spec_file" >> "$temp_file"
                echo "" >> "$temp_file"
                echo "</details>" >> "$temp_file"
                echo "" >> "$temp_file"
                echo "---" >> "$temp_file"
                echo "" >> "$temp_file"
            fi
        fi
    done
    [[ "$found_completed" == "false" ]] && echo "*No completed features yet.*" >> "$temp_file" && echo "" >> "$temp_file"

    # Active Features
    echo "### 🔄 Active Features" >> "$temp_file"
    echo "" >> "$temp_file"
    local found_active=false
    for feature_dir in "$FEATURES_DIR"/*/; do
        [[ -d "$feature_dir" ]] || continue
        local feature_name=$(basename "$feature_dir")
        local spec_file="${feature_dir}/spec.md"

        if [[ -f "$spec_file" ]]; then
            # Check if active (not completed)
            if ! grep -q "Status.*[Cc]omplete" "$spec_file" 2>/dev/null; then
                found_active=true
                echo "#### Feature: $feature_name" >> "$temp_file"
                echo "" >> "$temp_file"
                cat "$spec_file" >> "$temp_file"
                echo "" >> "$temp_file"
                echo "---" >> "$temp_file"
                echo "" >> "$temp_file"
            fi
        fi
    done
    [[ "$found_active" == "false" ]] && echo "*No active features.*" >> "$temp_file" && echo "" >> "$temp_file"

    # Planned Features
    echo "### 📋 Planned Features" >> "$temp_file"
    echo "" >> "$temp_file"
    if [[ -f "${MEMORY_DIR}/CHANGES-PLANNED.md" ]]; then
        cat "${MEMORY_DIR}/CHANGES-PLANNED.md" >> "$temp_file"
    else
        echo "*No planned features.*" >> "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Technical Decisions
    echo "## Technical Decisions" >> "$temp_file"
    echo "" >> "$temp_file"
    if [[ -f "${MEMORY_DIR}/DECISIONS-LOG.md" ]]; then
        cat "${MEMORY_DIR}/DECISIONS-LOG.md" >> "$temp_file"
    else
        echo "*No decisions logged yet.*" >> "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Metrics
    echo "## Metrics" >> "$temp_file"
    echo "" >> "$temp_file"
    if [[ -f "${MEMORY_DIR}/WORKFLOW-PROGRESS.md" ]]; then
        cat "${MEMORY_DIR}/WORKFLOW-PROGRESS.md" >> "$temp_file"
    else
        echo "*No metrics available yet.*" >> "$temp_file"
    fi
    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"

    # Footer
    cat >> "$temp_file" << EOF

---

*Auto-generated by Spec v3.0*
*Do not edit manually - changes will be overwritten*
*Source files: see individual feature directories*
*Generated: $(date '+%Y-%m-%d %H:%M:%S')*
EOF

    # Atomic move
    mv "$temp_file" "$OUTPUT_FILE"

    local line_count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    echo "✅ Generated master spec: $OUTPUT_FILE ($line_count lines)"
}

# Execute
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_master_spec "$@"
fi
