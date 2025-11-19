#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_ROOT="${PROJECT_DIR}/.spec"
STATE_DIR="${SPEC_ROOT}/state"
MEMORY_DIR="${SPEC_ROOT}/memory"
ARCH_DIR="${SPEC_ROOT}/architecture"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates/state"

mkdir -p "$SPEC_ROOT" "$STATE_DIR/checkpoints" "$MEMORY_DIR" "$ARCH_DIR"

copy_template() {
  local name="$1" dest="$2"
  local template="$TEMPLATE_DIR/$name"
  if [[ -f "$template" ]]; then
    mkdir -p "$(dirname "$dest")"
    sed "s/{timestamp}/$(date -u +%Y-%m-%dT%H:%M:%SZ)/g" "$template" > "$dest"
  fi
}

copy_template current-session.md "$STATE_DIR/current-session.md"
copy_template workflow-progress.md "$MEMORY_DIR/workflow-progress.md"
copy_template changes-planned.md "$MEMORY_DIR/changes-planned.md"
copy_template changes-completed.md "$MEMORY_DIR/changes-completed.md"
copy_template architecture-decision-record.md "$ARCH_DIR/architecture-decision-record.md"

if [[ ! -f "$SPEC_ROOT/.spec-config.yml" ]]; then
  cat > "$SPEC_ROOT/.spec-config.yml" <<'YAML'
version: "3.3.0"
paths:
  spec_root: ".spec"
  state: "state"
  memory: "memory"
  features: "features"
  architecture: "architecture"
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

grep -qxF '.spec/state/' "$PROJECT_DIR/.gitignore" 2>/dev/null || echo '.spec/state/' >> "$PROJECT_DIR/.gitignore"

echo "Orbit state initialized under $SPEC_ROOT"
