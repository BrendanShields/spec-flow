#!/usr/bin/env bash
# Context loader for Orbit workflow.
# Single script that gathers all context and outputs JSON.
# Usage: bash context-loader.sh

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"

python3 << 'PYTHON'
import json
import os
import sys

spec_dir = os.environ.get('SPEC_DIR', '.spec')
project_dir = os.environ.get('PROJECT_DIR', '.')

def read_file(path):
    """Read file contents or return None."""
    try:
        with open(path, 'r') as f:
            return f.read()
    except:
        return None

def parse_frontmatter(content):
    """Extract YAML frontmatter from markdown."""
    if not content or not content.startswith('---'):
        return {}
    try:
        end = content.find('---', 3)
        if end == -1:
            return {}
        yaml_str = content[3:end].strip()
        # Simple YAML parsing without external dependency
        result = {}
        current_key = None
        nested = {}
        in_nested = False

        for line in yaml_str.split('\n'):
            line = line.rstrip()
            if not line or line.startswith('#'):
                continue

            # Check for nested content (indented)
            if line.startswith('  ') and current_key:
                if in_nested:
                    parts = line.strip().split(':', 1)
                    if len(parts) == 2:
                        nested[parts[0].strip()] = parts[1].strip()
                continue

            # End nested block
            if in_nested and current_key:
                result[current_key] = nested
                nested = {}
                in_nested = False

            # Parse key: value
            if ':' in line:
                parts = line.split(':', 1)
                key = parts[0].strip()
                value = parts[1].strip() if len(parts) > 1 else ''

                if value == '':
                    # Start of nested block
                    current_key = key
                    in_nested = True
                    nested = {}
                else:
                    # Remove quotes
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:-1]
                    elif value.startswith("'") and value.endswith("'"):
                        value = value[1:-1]
                    # Convert booleans and numbers
                    if value.lower() == 'true':
                        value = True
                    elif value.lower() == 'false':
                        value = False
                    elif value.isdigit():
                        value = int(value)
                    result[key] = value
                    current_key = key

        # Handle final nested block
        if in_nested and current_key:
            result[current_key] = nested

        return result
    except Exception as e:
        return {}

def get_feature_state(feature_dir):
    """Get feature state from spec.md frontmatter."""
    spec_path = f"{feature_dir}/spec.md"
    content = read_file(spec_path)

    if not content:
        return {
            "status": "initialize",
            "progress": {"tasks_total": 0, "tasks_done": 0}
        }

    fm = parse_frontmatter(content)

    # Fallback status detection if not in frontmatter
    status = fm.get("status")
    if not status:
        if "[CLARIFY]" in content:
            status = "clarification"
        elif os.path.exists(f"{feature_dir}/tasks.md"):
            tasks_content = read_file(f"{feature_dir}/tasks.md") or ""
            if "- [ ]" in tasks_content:
                status = "implementation"
            elif "- [x]" in tasks_content:
                status = "complete"
            else:
                status = "planning"
        elif os.path.exists(f"{feature_dir}/plan.md"):
            status = "planning"
        else:
            status = "specification"

    # Count tasks if in implementation
    progress = fm.get("progress", {})
    if isinstance(progress, dict):
        tasks_total = progress.get("tasks_total", 0)
        tasks_done = progress.get("tasks_done", 0)
    else:
        tasks_total = 0
        tasks_done = 0

    # Recount from tasks.md if exists
    tasks_path = f"{feature_dir}/tasks.md"
    if os.path.exists(tasks_path):
        tasks_content = read_file(tasks_path) or ""
        tasks_total = tasks_content.count("- [ ]") + tasks_content.count("- [x]")
        tasks_done = tasks_content.count("- [x]")

    return {
        "id": fm.get("id", os.path.basename(feature_dir)),
        "title": fm.get("title", os.path.basename(feature_dir).split('-', 1)[-1].replace('-', ' ').title()),
        "status": status,
        "priority": fm.get("priority", "P2"),
        "created": str(fm.get("created", "")),
        "updated": str(fm.get("updated", "")),
        "progress": {
            "tasks_total": tasks_total,
            "tasks_done": tasks_done
        },
        "owner": fm.get("owner", "")
    }

def scan_features(features_dir):
    """Scan all features and return their states."""
    features = []
    if not os.path.isdir(features_dir):
        return features

    for name in sorted(os.listdir(features_dir)):
        feature_dir = f"{features_dir}/{name}"
        if os.path.isdir(feature_dir):
            state = get_feature_state(feature_dir)
            state["path"] = name
            features.append(state)

    return features

def get_in_progress_features(features):
    """Filter to features that need attention."""
    active_statuses = ["initialize", "specification", "clarification", "planning", "implementation"]
    return [f for f in features if f.get("status") in active_statuses]

def suggest_next_action(features, current_feature):
    """Suggest what user should do next based on feature states."""
    in_progress = get_in_progress_features(features)

    if not in_progress:
        return {
            "action": "new_feature",
            "feature": None,
            "reason": "No features in progress. Start a new feature?"
        }

    # Priority order: implementation > planning > clarification > specification
    priority_order = ["implementation", "planning", "clarification", "specification", "initialize"]

    for status in priority_order:
        for f in in_progress:
            if f.get("status") == status:
                progress_str = ""
                if status == "implementation":
                    p = f.get("progress", {})
                    progress_str = f" ({p.get('tasks_done', 0)}/{p.get('tasks_total', 0)} tasks)"

                if f.get("id") == current_feature or f.get("path") == current_feature:
                    return {
                        "action": f"continue_{status}",
                        "feature": f.get("path") or f.get("id"),
                        "reason": f"Continue {f.get('title')}{progress_str}"
                    }
                else:
                    return {
                        "action": f"switch_to_{status}",
                        "feature": f.get("path") or f.get("id"),
                        "reason": f"Resume {f.get('title')} ({status}){progress_str}"
                    }

    return {
        "action": "new_feature",
        "feature": None,
        "reason": "All features complete. Start a new feature?"
    }

# Load session
session_file = f"{spec_dir}/state/session.json"
session = {}
if os.path.exists(session_file):
    try:
        with open(session_file) as f:
            session = json.load(f)
    except:
        pass

current_feature = session.get("feature")

# Scan active features
features = scan_features(f"{spec_dir}/features")
in_progress = get_in_progress_features(features)

# Get suggestion
suggestion = suggest_next_action(features, current_feature)

# Get current feature details
current_feature_state = None
current_artifacts = None

if current_feature:
    feature_dir = f"{spec_dir}/features/{current_feature}"
    if os.path.isdir(feature_dir):
        current_feature_state = get_feature_state(feature_dir)
        current_artifacts = {
            "spec": read_file(f"{feature_dir}/spec.md"),
            "plan": read_file(f"{feature_dir}/plan.md"),
            "tasks": read_file(f"{feature_dir}/tasks.md"),
            "metrics": read_file(f"{feature_dir}/metrics.md")
        }

# Scan archive
archived_count = 0
archive_dir = f"{spec_dir}/archive"
if os.path.isdir(archive_dir):
    archived_count = len([d for d in os.listdir(archive_dir) if os.path.isdir(f"{archive_dir}/{d}")])

# Architecture files
architecture_files = []
arch_dir = f"{spec_dir}/architecture"
if os.path.isdir(arch_dir):
    architecture_files = [f for f in os.listdir(arch_dir) if f.endswith('.md')]

# Detect MCP servers
mcp_servers = []
for mcp_file in [f"{project_dir}/.mcp.json", f"{project_dir}/mcp.json"]:
    if os.path.exists(mcp_file):
        try:
            with open(mcp_file) as f:
                mcp_config = json.load(f)
            mcp_servers = list(mcp_config.get("mcpServers", {}).keys())
            break
        except:
            pass

# Detect user skills
user_skills = []
skills_dir = f"{project_dir}/.claude/skills"
if os.path.isdir(skills_dir):
    user_skills = [d for d in os.listdir(skills_dir) if os.path.isdir(f"{skills_dir}/{d}")]

# Detect user agents
user_agents = []
agents_dir = f"{project_dir}/.claude/agents"
if os.path.isdir(agents_dir):
    user_agents = [f.replace('.md', '') for f in os.listdir(agents_dir) if f.endswith('.md')]

# Project detection
has_openapi = any(os.path.exists(f"{project_dir}/{f}") for f in ["openapi.yml", "openapi.yaml", "swagger.yml", "swagger.yaml"])
has_prisma = os.path.exists(f"{project_dir}/prisma/schema.prisma")
has_package_json = os.path.exists(f"{project_dir}/package.json")

# Build output
context = {
    "suggestion": suggestion,
    "current": {
        "feature": current_feature,
        "state": current_feature_state,
        "artifacts": current_artifacts
    },
    "features": {
        "active": features,
        "in_progress": in_progress,
        "in_progress_count": len(in_progress),
        "archived_count": archived_count
    },
    "architecture_files": architecture_files,
    "extensions": {
        "mcp_servers": mcp_servers,
        "user_skills": user_skills,
        "user_agents": user_agents
    },
    "project": {
        "has_openapi": has_openapi,
        "has_prisma": has_prisma,
        "has_package_json": has_package_json
    }
}

print(json.dumps(context, indent=2))
PYTHON
