#!/usr/bin/env bash

# PreToolUse: Block edits to protected files.
# Exit 2 = block with error message to Claude

set -euo pipefail

INPUT=$(cat 2>/dev/null || true)
[[ -z "${INPUT}" ]] && exit 0

# Extract file_path from tool_input (correct JSON path per docs)
file_path=$(echo "${INPUT}" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

[[ -z "${file_path}" ]] && exit 0

# Protected patterns
protected_patterns=(".env" "package-lock.json" ".git/" "yarn.lock" "pnpm-lock.yaml")

for pattern in "${protected_patterns[@]}"; do
  if [[ "${file_path}" == *"${pattern}"* ]]; then
    echo "Protected file: ${pattern} - cannot modify" >&2
    exit 2
  fi
done

exit 0
