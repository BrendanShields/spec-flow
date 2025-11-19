#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_ROOT="${PROJECT_DIR}/.spec"
STATE_DIR="${SPEC_ROOT}/state"
MEMORY_DIR="${SPEC_ROOT}/memory"
ARCH_DIR="${SPEC_ROOT}/architecture"
ARCHIVE_DIR="${SPEC_ROOT}/archive"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates/state"
HOOK_LIB="${PROJECT_DIR}/.claude/hooks/lib.sh"

mkdir -p "${SPEC_ROOT}" "${STATE_DIR}" "${MEMORY_DIR}" "${ARCH_DIR}" "${ARCHIVE_DIR}"

if [[ -f "${HOOK_LIB}" ]]; then
  # shellcheck source=/dev/null
  source "${HOOK_LIB}"
  ensure_config
  ensure_session_file
fi

copy_template() {
  local name="$1" dest="$2"
  local template="${TEMPLATE_DIR}/${name}"
  if [[ -f "${template}" ]]; then
    mkdir -p "$(dirname "${dest}")"
    sed "s/{timestamp}/$(date -u +%Y-%m-%dT%H:%M:%SZ)/g" "${template}" > "${dest}"
  fi
}

copy_template activity-log.md "${MEMORY_DIR}/activity-log.md"
copy_template history.md "${ARCHIVE_DIR}/history.md"
copy_template architecture-decision-record.md "${ARCH_DIR}/architecture-decision-record.md"

if [[ ! -f "${SPEC_ROOT}/.spec-config.yml" ]]; then
  cat > "${SPEC_ROOT}/.spec-config.yml" <<'YAML'
version: "3.4.0"
paths:
  spec_root: ".spec"
  state: "state"
  memory: "memory"
  features: "features"
  architecture: "architecture"
  archive: "archive"
naming:
  feature_directory: "{id:000}-{slug}"
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
workflow:
  auto_checkpoint: true
  validate_on_save: true
YAML
fi

if [[ -x "$(command -v git)" ]]; then
  grep -qxF '.spec/state/' "${PROJECT_DIR}/.gitignore" 2>/dev/null || echo '.spec/state/' >> "${PROJECT_DIR}/.gitignore"
fi

echo "Orbit state initialized under ${SPEC_ROOT}"
