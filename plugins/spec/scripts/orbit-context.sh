#!/usr/bin/env bash

# UserPromptSubmit: Inject Orbit context when /orbit command is used.
# Only triggers for prompts starting with "/orbit"

set -euo pipefail

INPUT=$(cat 2>/dev/null || true)
[[ -z "${INPUT}" ]] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"

# Extract prompt from input
prompt=$(echo "${INPUT}" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('prompt', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Only inject context for /orbit command
[[ "${prompt}" != "/orbit"* ]] && exit 0

# Not initialized - suggest initialization
if [[ ! -d "${SPEC_DIR}" ]]; then
  cat << 'EOF'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"Orbit not initialized. No .spec directory found."}}
EOF
  exit 0
fi

# Scan features and output context
python3 << 'PYTHON'
import json
import os

spec_dir = os.environ.get('SPEC_DIR', '.spec')

def find_spec_file(feature_dir):
    """Find spec file with case-insensitive matching.
    Priority: spec.md > SPEC.md > specs.md > SPECS.md
    """
    candidates = ['spec.md', 'SPEC.md', 'Spec.md', 'specs.md', 'SPECS.md', 'Specs.md']
    for name in candidates:
        path = f"{feature_dir}/{name}"
        if os.path.exists(path):
            return path
    return None

def get_frontmatter(spec_path):
    """Parse frontmatter from spec file."""
    if not spec_path or not os.path.exists(spec_path):
        return {}

    try:
        with open(spec_path) as f:
            content = f.read()

        if not content.startswith('---'):
            return {}

        end = content.find('---', 3)
        if end == -1:
            return {}

        frontmatter = {}
        for line in content[3:end].split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                frontmatter[key.strip()] = value.strip()

        return frontmatter
    except:
        return {}

def count_tasks(feature_dir):
    """Count tasks in tasks.md."""
    tasks_path = f"{feature_dir}/tasks.md"
    if not os.path.exists(tasks_path):
        return None

    try:
        with open(tasks_path) as f:
            content = f.read()
        total = content.count("- [ ]") + content.count("- [x]")
        done = content.count("- [x]")
        return {"total": total, "done": done}
    except:
        return None

def get_artifacts(feature_dir):
    """List available artifacts."""
    artifacts = []
    # Check for spec file (case-insensitive)
    if find_spec_file(feature_dir):
        artifacts.append("spec.md")
    for name in ["plan.md", "tasks.md", "metrics.md"]:
        if os.path.exists(f"{feature_dir}/{name}"):
            artifacts.append(name)
    return artifacts

# Scan features
features = []
features_dir = f"{spec_dir}/features"

if os.path.isdir(features_dir):
    for name in sorted(os.listdir(features_dir)):
        feature_dir = f"{features_dir}/{name}"
        if not os.path.isdir(feature_dir):
            continue

        spec_path = find_spec_file(feature_dir)
        frontmatter = get_frontmatter(spec_path)
        status = frontmatter.get('status', 'initialize')

        # Include active features
        if status in ["initialize", "specification", "clarification", "planning", "implementation", "complete"]:
            feature = {
                "id": name,
                "title": frontmatter.get('title', name),
                "status": status,
                "priority": frontmatter.get('priority', 'P2'),
                "artifacts": get_artifacts(feature_dir)
            }

            # Add progress for implementation
            if status in ["implementation", "complete"]:
                progress = count_tasks(feature_dir)
                if progress:
                    feature["progress"] = progress

            features.append(feature)

# Check for architecture docs
arch_dir = f"{spec_dir}/architecture"
has_prd = os.path.exists(f"{arch_dir}/product-requirements.md")
has_tdd = os.path.exists(f"{arch_dir}/technical-design.md")

# Build suggestion based on state
if not features:
    suggestion = "No active features. Start a new feature or analyze codebase for brownfield project."
else:
    # Prioritize by status
    priority_order = ["complete", "implementation", "planning", "clarification", "specification", "initialize"]
    suggestion = None

    for status in priority_order:
        for f in features:
            if f["status"] == status:
                if status == "complete":
                    prog = f.get("progress", {})
                    suggestion = f"Archive completed feature '{f['title']}' ({prog.get('done', '?')}/{prog.get('total', '?')} tasks)"
                elif status == "implementation":
                    prog = f.get("progress", {})
                    suggestion = f"Continue implementing '{f['title']}' ({prog.get('done', 0)}/{prog.get('total', '?')} tasks done)"
                elif status == "planning":
                    suggestion = f"Create tasks.md for '{f['title']}'"
                elif status == "clarification":
                    suggestion = f"Resolve [CLARIFY] tags in '{f['title']}' plan.md"
                elif status == "specification":
                    suggestion = f"Create plan.md for '{f['title']}'"
                else:
                    suggestion = f"Create spec.md for '{f['title']}'"
                break
        if suggestion:
            break

    if not suggestion:
        suggestion = "Review features and continue work"

# Build context
context = {
    "features": features,
    "architecture": {
        "has_prd": has_prd,
        "has_tdd": has_tdd
    },
    "suggestion": suggestion
}

# Output in UserPromptSubmit format
output = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": json.dumps(context)
    }
}

print(json.dumps(output))
PYTHON
