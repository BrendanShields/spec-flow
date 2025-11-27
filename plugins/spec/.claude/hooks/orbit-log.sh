#!/usr/bin/env bash

# PostToolUse/SubagentStop: Log activity to feature's metrics.md
# Uses correct field names per Claude Code hook docs

set -euo pipefail

INPUT=$(cat 2>/dev/null || true)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"
SESSION_FILE="${SPEC_DIR}/state/session.json"

# Get current feature
feature=""
if [[ -f "${SESSION_FILE}" ]]; then
  feature=$(python3 -c "import json; print(json.load(open('${SESSION_FILE}')).get('feature',''))" 2>/dev/null || echo "")
fi

[[ -z "${feature}" ]] && exit 0

metrics_file="${SPEC_DIR}/features/${feature}/metrics.md"
[[ ! -f "${metrics_file}" ]] && exit 0

# Parse event from input (correct field names per docs)
event=""
if [[ -n "${INPUT}" ]]; then
  event=$(echo "${INPUT}" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    tool_name = data.get('tool_name', '')
    hook_event = data.get('hook_event_name', '')

    if tool_name:
        # For tool events, get file path if available
        file_path = data.get('tool_input', {}).get('file_path', '')
        if file_path:
            # Make relative
            import os
            project_dir = os.environ.get('PROJECT_DIR', '.')
            if file_path.startswith(project_dir):
                file_path = file_path[len(project_dir)+1:]
            print(f'{tool_name}:{file_path}')
        else:
            print(f'{tool_name}')
    elif hook_event == 'SubagentStop':
        print('subagent:complete')
    else:
        print('')
except:
    print('')
" 2>/dev/null || echo "")
fi

# Log if we have an event
if [[ -n "${event}" ]]; then
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  echo "| ${timestamp} | ${event} |" >> "${metrics_file}"
fi

exit 0
