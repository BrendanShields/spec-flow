#!/usr/bin/env bash

# Clone/refresh marketplace plugins so they are available immediately.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

CONTEXT="$(cat || true)"

MARKETPLACE_FILE="${PROJECT_DIR}/.claude-plugin/marketplace.json"
CACHE_DIR="${PROJECT_DIR}/.claude/.cache/plugins"
LOG_FILE="${STATE_DIR}/prefetch-log.json"

if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  exit 0
fi

ensure_directories
mkdir -p "${CACHE_DIR}"

readarray -t REMOTE_PLUGINS < <(python3 - "${MARKETPLACE_FILE}" <<'PY'
import json, sys, pathlib
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding='utf-8'))
except Exception:
    raise SystemExit(0)
plugins = data.get("plugins") or []
for plugin in plugins:
    source = plugin.get("source") or ""
    if source.startswith("http://") or source.startswith("https://") or source.startswith("git@"):
        print(f"{plugin.get('name')}|{source}")
PY
)

if [[ "${#REMOTE_PLUGINS[@]}" -eq 0 ]]; then
  exit 0
fi

declare -a result_lines

for entry in "${REMOTE_PLUGINS[@]}"; do
  [[ -z "${entry}" ]] && continue
  name="${entry%%|*}"
  remote="${entry##*|}"
  dest="${CACHE_DIR}/${name}"
  if [[ -d "${dest}/.git" ]]; then
    git -C "${dest}" pull --ff-only >/dev/null 2>&1 || true
  else
    git clone "${remote}" "${dest}" >/dev/null 2>&1 || true
  fi

  if [[ ! -d "${dest}" ]]; then
    continue
  fi

  target="${PROJECT_DIR}/plugins/${name}"
  mkdir -p "$(dirname "${target}")"
  rm -rf "${target}"
  cp -R "${dest}" "${target}"
  rm -rf "${target}/.git"
  result_lines+=("${name}|${remote}|${target}")
done

if [[ "${#result_lines[@]}" -gt 0 ]]; then
  payload="$(SPEC_PREFETCH_RESULTS="$(printf '%s\n' "${result_lines[@]}")" python3 - "${LOG_FILE}" <<'PY'
import json, os, pathlib, sys, time
lines = [line for line in os.environ.get("SPEC_PREFETCH_RESULTS","").splitlines() if line.strip()]
entries = []
for line in lines:
    name, remote, target = line.split("|", 2)
    entries.append({
        "name": name,
        "source": remote,
        "path": target,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    })
pathlib.Path(sys.argv[1]).write_text(json.dumps(entries, indent=2), encoding='utf-8')
print(json.dumps(entries))
PY
)"
  write_hook_output "prefetch" "Prefetched marketplace plugins" "${payload}"
fi
