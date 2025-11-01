#!/bin/bash
# Validate Spec state files for consistency and required artifacts
# Provides checks for hybrid JSON/Markdown workflow guarantees

set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
STATE_DIR="${PROJECT_ROOT}/.spec-state"
MEMORY_DIR="${PROJECT_ROOT}/.spec-memory"
CONFIG_DIR="${PROJECT_ROOT}/.spec"

error=false

print_section() {
    echo ""
    echo "== $1 =="
}

check_path() {
    local description=$1
    local path=$2
    if [[ -e "$path" ]]; then
        echo "✅ ${description}: ${path}"
    else
        echo "❌ ${description} missing: ${path}" >&2
        error=true
    fi
}

format_time() {
    local timestamp=$1
    if date -d @0 >/dev/null 2>&1; then
        date -d @${timestamp} '+%Y-%m-%d %H:%M:%S'
    else
        date -r ${timestamp} '+%Y-%m-%d %H:%M:%S'
    fi
}

check_json_md_pair() {
    local json_file=$1
    local md_file=$2
    local context=$3

    if [[ ! -f "$json_file" || ! -f "$md_file" ]]; then
        echo "⚠️  Skipping ${context} validation (missing files)"
        return
    fi

    local json_mtime=$(stat -c %Y "$json_file")
    local md_mtime=$(stat -c %Y "$md_file")

    local json_hash=$(jq -S 'del(.lastUpdated, .timestamp, .generatedAt)' "$json_file" 2>/dev/null | sha1sum | cut -d' ' -f1)
    local md_hash=$(sed 's/Last updated.*/Last updated: <timestamp removed>/' "$md_file" | sha1sum | cut -d' ' -f1)

    echo "📄 ${context}:"
    printf '   ├─ JSON updated: %s\n' "$(format_time ${json_mtime})"
    printf '   ├─ Markdown updated: %s\n' "$(format_time ${md_mtime})"

    if (( json_mtime > md_mtime )); then
        echo "   ├─ ⚠️  Markdown older than JSON"
        error=true
    fi

    if [[ -z "$json_hash" ]]; then
        echo "   ├─ ❌ Unable to parse JSON"
        error=true
    else
        echo "   ├─ JSON hash: ${json_hash}"
    fi

    echo "   └─ Markdown hash: ${md_hash}"
}

print_section "Verifying required directories"
check_path "Config directory" "$CONFIG_DIR"
check_path "State directory" "$STATE_DIR"
check_path "Memory directory" "$MEMORY_DIR"

print_section "Checking hybrid state artifacts"
check_path "Session JSON" "$STATE_DIR/session.json"
check_path "Session Markdown" "$STATE_DIR/current-session.md"
check_path "Workflow JSON" "$MEMORY_DIR/workflow.json"
check_path "Workflow Markdown" "$MEMORY_DIR/WORKFLOW-PROGRESS.md"

print_section "Validating JSON ↔ Markdown synchronization"
check_json_md_pair "$STATE_DIR/session.json" "$STATE_DIR/current-session.md" "Session state"
check_json_md_pair "$MEMORY_DIR/workflow.json" "$MEMORY_DIR/WORKFLOW-PROGRESS.md" "Workflow progress"

print_section "Optional recovery hint"
cat <<'TIP'
If any checks failed, regenerate Markdown from JSON using:
  ./plugins/spec/scripts/state-management/json-to-md.sh session
  ./plugins/spec/scripts/state-management/json-to-md.sh workflow
TIP

if [[ "$error" == true ]]; then
    echo ""
    echo "State validation detected issues." >&2
    exit 1
fi

echo ""
echo "✅ Spec state validation passed"
