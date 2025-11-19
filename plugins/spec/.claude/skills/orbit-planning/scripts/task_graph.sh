#!/usr/bin/env bash
set -euo pipefail
if [[ $# -eq 0 ]]; then
  echo "Usage: task_graph.sh T001>T002 ..." >&2
  exit 1
fi
cat <<'MERMAID'
```mermaid
graph TD
MERMAID
for pair in "$@"; do
  echo "  ${pair//>/ --> }"
done
echo '```'
