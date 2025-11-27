#!/usr/bin/env bash

# Helpers for Orbit hooks and workflow.
# Philosophy: Artifacts are truth. Frontmatter tracks state.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"
SESSION_FILE="${SPEC_DIR}/state/session.json"
ARCHIVE_DIR="${SPEC_DIR}/archive"

# Get current feature from session or find most recent
get_feature() {
  if [[ -f "${SESSION_FILE}" ]]; then
    local feature
    feature=$(python3 -c "import json; print(json.load(open('${SESSION_FILE}')).get('feature',''))" 2>/dev/null || echo "")
    if [[ -n "${feature}" && -d "${SPEC_DIR}/features/${feature}" ]]; then
      echo "${feature}"
      return
    fi
  fi

  # Find most recent feature
  if [[ -d "${SPEC_DIR}/features" ]]; then
    ls -t "${SPEC_DIR}/features" 2>/dev/null | head -1
  fi
}

# Get feature directory path
get_feature_dir() {
  local feature="${1:-$(get_feature)}"
  if [[ -n "${feature}" ]]; then
    echo "${SPEC_DIR}/features/${feature}"
  fi
}

# Get metrics.md path for current feature
get_metrics_file() {
  local feature
  feature=$(get_feature)
  if [[ -n "${feature}" ]]; then
    echo "${SPEC_DIR}/features/${feature}/metrics.md"
  fi
}

# Append line to metrics.md activity log
log_activity() {
  local event="$1"
  local metrics_file
  metrics_file=$(get_metrics_file)

  [[ -z "${metrics_file}" ]] && return
  [[ ! -f "${metrics_file}" ]] && return

  local timestamp
  timestamp=$(date -u +"%H:%M")

  echo "| ${timestamp} | ${event} |" >> "${metrics_file}"
}

# Initialize .spec directory structure
init_spec_dir() {
  mkdir -p "${SPEC_DIR}/features" "${SPEC_DIR}/architecture" "${SPEC_DIR}/state" "${ARCHIVE_DIR}"

  if [[ ! -f "${SESSION_FILE}" ]]; then
    mkdir -p "$(dirname "${SESSION_FILE}")"
    echo '{"feature": null}' > "${SESSION_FILE}"
  fi
}

# Set current feature in session
set_feature() {
  local feature="$1"
  mkdir -p "$(dirname "${SESSION_FILE}")"
  echo "{\"feature\": \"${feature}\"}" > "${SESSION_FILE}"
}

# Update frontmatter field in a markdown file
# Usage: update_frontmatter <file> <key> <value>
update_frontmatter() {
  local file="$1"
  local key="$2"
  local value="$3"

  [[ ! -f "${file}" ]] && return 1

  python3 << PYTHON
import sys

file_path = "${file}"
key = "${key}"
value = "${value}"

with open(file_path, 'r') as f:
    content = f.read()

if not content.startswith('---'):
    # No frontmatter, add it
    new_content = f"---\\n{key}: {value}\\n---\\n\\n{content}"
else:
    # Find end of frontmatter
    end = content.find('---', 3)
    if end == -1:
        sys.exit(1)

    frontmatter = content[3:end]
    body = content[end+3:]

    # Check if key exists
    lines = frontmatter.strip().split('\\n')
    found = False
    new_lines = []

    for line in lines:
        if line.startswith(f"{key}:"):
            new_lines.append(f"{key}: {value}")
            found = True
        else:
            new_lines.append(line)

    if not found:
        new_lines.append(f"{key}: {value}")

    new_frontmatter = '\\n'.join(new_lines)
    new_content = f"---\\n{new_frontmatter}\\n---{body}"

with open(file_path, 'w') as f:
    f.write(new_content)
PYTHON
}

# Update nested frontmatter (e.g., progress.tasks_done)
# Usage: update_frontmatter_nested <file> <parent_key> <child_key> <value>
update_frontmatter_nested() {
  local file="$1"
  local parent="$2"
  local child="$3"
  local value="$4"

  [[ ! -f "${file}" ]] && return 1

  python3 << PYTHON
import sys

file_path = "${file}"
parent = "${parent}"
child = "${child}"
value = "${value}"

with open(file_path, 'r') as f:
    content = f.read()

if not content.startswith('---'):
    sys.exit(1)

end = content.find('---', 3)
if end == -1:
    sys.exit(1)

frontmatter = content[3:end]
body = content[end+3:]

lines = frontmatter.strip().split('\\n')
new_lines = []
in_parent = False
found_child = False

for i, line in enumerate(lines):
    if line.startswith(f"{parent}:"):
        new_lines.append(line)
        in_parent = True
    elif in_parent and line.startswith("  "):
        if line.strip().startswith(f"{child}:"):
            new_lines.append(f"  {child}: {value}")
            found_child = True
        else:
            new_lines.append(line)
    else:
        if in_parent and not found_child:
            new_lines.append(f"  {child}: {value}")
            found_child = True
        in_parent = False
        new_lines.append(line)

if in_parent and not found_child:
    new_lines.append(f"  {child}: {value}")

new_frontmatter = '\\n'.join(new_lines)
new_content = f"---\\n{new_frontmatter}\\n---{body}"

with open(file_path, 'w') as f:
    f.write(new_content)
PYTHON
}

# Archive a completed feature
# Usage: archive_feature <feature>
archive_feature() {
  local feature="$1"
  local src="${SPEC_DIR}/features/${feature}"
  local dst="${ARCHIVE_DIR}/${feature}"

  if [[ ! -d "${src}" ]]; then
    echo "Feature not found: ${feature}" >&2
    return 1
  fi

  # Update frontmatter before archiving
  local spec_file="${src}/spec.md"
  if [[ -f "${spec_file}" ]]; then
    update_frontmatter "${spec_file}" "status" "complete"
    update_frontmatter "${spec_file}" "archived" "true"
    update_frontmatter "${spec_file}" "archived_date" "$(date -u +%Y-%m-%d)"
  fi

  # Move to archive
  mkdir -p "${ARCHIVE_DIR}"
  mv "${src}" "${dst}"

  # Clear session if this was current feature
  local current
  current=$(get_feature)
  if [[ "${current}" == "${feature}" ]]; then
    echo '{"feature": null}' > "${SESSION_FILE}"
  fi

  echo "Archived: ${feature} -> ${dst}"
}

# Search archive for related features
# Usage: search_archive <query>
search_archive() {
  local query="$1"

  if [[ ! -d "${ARCHIVE_DIR}" ]]; then
    return
  fi

  python3 << PYTHON
import os
import json

archive_dir = "${ARCHIVE_DIR}"
query = "${query}".lower()

matches = []
for name in os.listdir(archive_dir):
    feature_dir = f"{archive_dir}/{name}"
    if not os.path.isdir(feature_dir):
        continue

    # Check name match
    if query in name.lower():
        matches.append({"feature": name, "match": "name"})
        continue

    # Check spec.md content
    spec_file = f"{feature_dir}/spec.md"
    if os.path.exists(spec_file):
        with open(spec_file) as f:
            content = f.read().lower()
        if query in content:
            matches.append({"feature": name, "match": "content"})

print(json.dumps(matches, indent=2))
PYTHON
}

# Count tasks in tasks.md
# Usage: count_tasks <feature>
count_tasks() {
  local feature="${1:-$(get_feature)}"
  local tasks_file="${SPEC_DIR}/features/${feature}/tasks.md"

  if [[ ! -f "${tasks_file}" ]]; then
    echo '{"total": 0, "done": 0, "pending": 0}'
    return
  fi

  local total done pending
  total=$(grep -c '\- \[ \]\|\- \[x\]' "${tasks_file}" 2>/dev/null || echo 0)
  done=$(grep -c '\- \[x\]' "${tasks_file}" 2>/dev/null || echo 0)
  pending=$((total - done))

  echo "{\"total\": ${total}, \"done\": ${done}, \"pending\": ${pending}}"
}

# Load context using context-loader.sh
load_context() {
  local loader="${PROJECT_DIR}/.claude/hooks/lib/context-loader.sh"
  if [[ -f "${loader}" ]]; then
    bash "${loader}"
  else
    echo '{"error": "context-loader.sh not found"}'
  fi
}

# Output JSON for hook response
hook_output() {
  local message="$1"
  echo "{\"message\": \"${message}\"}"
}
