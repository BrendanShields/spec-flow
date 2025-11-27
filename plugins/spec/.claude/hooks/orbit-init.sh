#!/usr/bin/env bash

# SessionStart: Output minimal Orbit context for Claude.
# This stdout is automatically added to Claude's context.

set -euo pipefail

# Consume stdin (required by hook protocol)
cat >/dev/null 2>&1 || true

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"

# Not initialized - minimal output
if [[ ! -d "${SPEC_DIR}" ]]; then
  echo '{"orbit":{"initialized":false,"suggestion":"Run /orbit to initialize"}}'
  exit 0
fi

# Scan features and output minimal context
python3 << 'PYTHON'
import json
import os

spec_dir = os.environ.get('SPEC_DIR', '.spec')

def get_status(feature_dir):
    """Get status from spec.md frontmatter."""
    spec_path = f"{feature_dir}/spec.md"
    if not os.path.exists(spec_path):
        return "initialize"

    try:
        with open(spec_path) as f:
            content = f.read()

        if not content.startswith('---'):
            return "specification"

        # Simple frontmatter parsing
        end = content.find('---', 3)
        if end == -1:
            return "specification"

        for line in content[3:end].split('\n'):
            if line.startswith('status:'):
                return line.split(':', 1)[1].strip()

        return "specification"
    except:
        return "unknown"

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
        return f"{done}/{total}"
    except:
        return None

def get_title(feature_dir, feature_id):
    """Get title from spec.md or derive from id."""
    spec_path = f"{feature_dir}/spec.md"
    if os.path.exists(spec_path):
        try:
            with open(spec_path) as f:
                content = f.read()
            if content.startswith('---'):
                end = content.find('---', 3)
                if end != -1:
                    for line in content[3:end].split('\n'):
                        if line.startswith('title:'):
                            return line.split(':', 1)[1].strip()
        except:
            pass

    # Derive from id: "001-feature-name" -> "Feature Name"
    parts = feature_id.split('-', 1)
    if len(parts) > 1:
        return parts[1].replace('-', ' ').title()
    return feature_id

# Scan features
features = []
features_dir = f"{spec_dir}/features"

if os.path.isdir(features_dir):
    for name in sorted(os.listdir(features_dir)):
        feature_dir = f"{features_dir}/{name}"
        if not os.path.isdir(feature_dir):
            continue

        status = get_status(feature_dir)

        # Include active features and completed (not archived) features
        if status in ["initialize", "specification", "clarification", "planning", "implementation", "complete"]:
            feature = {
                "id": name,
                "title": get_title(feature_dir, name),
                "status": status
            }

            # Add progress for implementation and complete
            if status in ["implementation", "complete"]:
                progress = count_tasks(feature_dir)
                if progress:
                    feature["progress"] = progress

            features.append(feature)

# Build suggestion
if not features:
    suggestion = "No active features. Run /orbit to start a new feature."
else:
    # Prioritize: complete (archive) > implementation > planning > clarification > specification
    priority = ["complete", "implementation", "planning", "clarification", "specification", "initialize"]
    for status in priority:
        for f in features:
            if f["status"] == status:
                if status == "complete":
                    suggestion = f"Archive completed feature: {f['title']} ({f.get('progress', '?')})"
                elif status == "implementation":
                    suggestion = f"Continue implementing {f['title']} ({f.get('progress', '?')})"
                else:
                    suggestion = f"Continue {f['title']} ({status})"
                break
        else:
            continue
        break
    else:
        suggestion = "Run /orbit to continue"

# Build context data
orbit_data = {
    "initialized": True,
    "features": features,
    "suggestion": suggestion
}

# Option 1: Use hookSpecificOutput format (official format per docs)
output = {
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": json.dumps(orbit_data)
    }
}

print(json.dumps(output))
PYTHON
