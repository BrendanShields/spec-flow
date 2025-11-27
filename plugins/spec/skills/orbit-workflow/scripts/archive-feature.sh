#!/usr/bin/env bash
# archive-feature.sh - Archive a completed feature
# Usage: archive-feature.sh <feature-id>

set -euo pipefail

FEATURE="${1:-}"

if [[ -z "$FEATURE" ]]; then
  echo '{"error":"Usage: archive-feature.sh <feature-id>"}'
  exit 1
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"
ARCHIVE_DIR="${SPEC_DIR}/archive"
SESSION_FILE="${SPEC_DIR}/state/session.json"

SRC="${SPEC_DIR}/features/${FEATURE}"
DST="${ARCHIVE_DIR}/${FEATURE}"

if [[ ! -d "${SRC}" ]]; then
  echo "{\"error\":\"Feature not found: ${FEATURE}\"}"
  exit 1
fi

# Update frontmatter before archiving
SPEC_FILE="${SRC}/spec.md"
if [[ -f "${SPEC_FILE}" ]]; then
  # Update status to complete
  if grep -q '^status:' "$SPEC_FILE"; then
    sed -i '' "s/^status:.*/status: complete/" "$SPEC_FILE"
  fi

  # Add archived fields
  TIMESTAMP=$(date -u +%Y-%m-%d)
  if ! grep -q '^archived:' "$SPEC_FILE"; then
    # Add after status line
    sed -i '' "/^status:/a\\
archived: true\\
archived_date: ${TIMESTAMP}
" "$SPEC_FILE"
  fi
fi

# Move to archive
mkdir -p "${ARCHIVE_DIR}"
mv "${SRC}" "${DST}"

# Clear session if this was current feature
if [[ -f "${SESSION_FILE}" ]]; then
  CURRENT=$(python3 -c "import json; print(json.load(open('${SESSION_FILE}')).get('feature',''))" 2>/dev/null || echo "")
  if [[ "${CURRENT}" == "${FEATURE}" ]]; then
    echo '{"feature": null}' > "${SESSION_FILE}"
  fi
fi

echo "{\"archived\":true,\"feature\":\"${FEATURE}\",\"destination\":\"${DST}\"}"
