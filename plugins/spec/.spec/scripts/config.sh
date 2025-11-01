#!/bin/bash
# Flow Configuration Management
# Manages JSON configuration at .spec/config/flow.json

# Initialize config with defaults
init_flow_config() {
  local type="${1:-brownfield}"
  local config_dir=".spec/config"
  local config_file="$config_dir/flow.json"

  # Create config directory if needed
  mkdir -p "$config_dir"

  # Generate default configuration
  cat > "$config_file" <<EOF
{
  "version": "2.0",
  "project": {
    "type": "$type",
    "initialized": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "name": "$(basename "$(pwd)")"
  },
  "integrations": {
    "jira": {
      "enabled": false,
      "project_key": ""
    },
    "confluence": {
      "enabled": false,
      "root_page_id": ""
    }
  },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true,
    "interactive_mode": true,
    "interactive_transitions": false
  }
}
EOF

  echo "Config initialized at $config_file"
}

# Read config value
# Usage: get_flow_config "project.type"
get_flow_config() {
  local key="$1"
  local config_file=".spec/config/flow.json"

  if [ ! -f "$config_file" ]; then
    echo "Error: Config file not found at $config_file" >&2
    return 1
  fi

  # Check if jq is available
  if command -v jq &> /dev/null; then
    jq -r ".$key // empty" "$config_file" 2>/dev/null
  else
    # Fallback: simple grep/sed parsing for basic keys
    echo "Warning: jq not found, using fallback parser" >&2
    grep "\"${key##*.}\"" "$config_file" | sed 's/.*: "\(.*\)".*/\1/' | sed 's/,$//'
  fi
}

# Write config value
# Usage: set_flow_config "integrations.jira.enabled" "true"
set_flow_config() {
  local key="$1"
  local value="$2"
  local config_file=".spec/config/flow.json"

  if [ ! -f "$config_file" ]; then
    echo "Error: Config file not found at $config_file" >&2
    return 1
  fi

  # Check if jq is available
  if command -v jq &> /dev/null; then
    local tmp=$(mktemp)
    # Handle boolean and numeric values
    if [ "$value" = "true" ] || [ "$value" = "false" ] || [[ "$value" =~ ^[0-9]+$ ]]; then
      jq ".$key = $value" "$config_file" > "$tmp"
    else
      jq ".$key = \"$value\"" "$config_file" > "$tmp"
    fi
    mv "$tmp" "$config_file"
    echo "Config updated: $key = $value"
  else
    echo "Error: jq required for config updates. Install with: brew install jq" >&2
    return 1
  fi
}

# Validate config file
validate_flow_config() {
  local config_file=".spec/config/flow.json"

  if [ ! -f "$config_file" ]; then
    echo "Error: Config file not found at $config_file" >&2
    return 1
  fi

  # Check if jq is available
  if command -v jq &> /dev/null; then
    # Validate JSON syntax
    if ! jq empty "$config_file" 2>/dev/null; then
      echo "Error: Invalid JSON in $config_file" >&2
      return 1
    fi

    # Check required fields
    local version=$(jq -r '.version // empty' "$config_file")
    if [ "$version" != "2.0" ]; then
      echo "Error: Unsupported config version: $version (expected 2.0)" >&2
      return 1
    fi

    local project_type=$(jq -r '.project.type // empty' "$config_file")
    if [ -z "$project_type" ]; then
      echo "Error: Missing required field: project.type" >&2
      return 1
    fi

    if [ "$project_type" != "greenfield" ] && [ "$project_type" != "brownfield" ]; then
      echo "Error: Invalid project.type: $project_type (must be greenfield or brownfield)" >&2
      return 1
    fi

    echo "Config validation passed"
    return 0
  else
    echo "Warning: jq not available, skipping validation" >&2
    return 0
  fi
}

# Check if jq is available
check_jq_available() {
  if command -v jq &> /dev/null; then
    return 0
  else
    echo "Warning: jq is not installed. Some config features may be limited." >&2
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)" >&2
    return 1
  fi
}

# Validate JIRA project key format
validate_jira_key() {
  local key="$1"

  # JIRA key format: PROJECT or PROJECT-123
  if [[ "$key" =~ ^[A-Z][A-Z0-9]+(-[0-9]+)?$ ]]; then
    return 0
  else
    echo "Error: Invalid JIRA key format: $key" >&2
    echo "Expected format: PROJECT or PROJECT-123 (e.g., FLOW, FLOW-456)" >&2
    return 1
  fi
}

# Validate Confluence page ID (numeric only)
validate_confluence_page_id() {
  local page_id="$1"

  if [[ "$page_id" =~ ^[0-9]+$ ]]; then
    return 0
  else
    echo "Error: Invalid Confluence page ID: $page_id" >&2
    echo "Expected format: numeric only (e.g., 123456)" >&2
    return 1
  fi
}

# Check if interactive mode should be used
# Returns 0 (true) if prompts should be shown, 1 (false) if they should be skipped
should_prompt_interactive() {
  # Check for CLI arguments (any arguments skip prompts)
  if [ $# -gt 0 ]; then
    return 1  # Skip prompts
  fi

  # Check global flag
  if [ "$SPEC_NO_INTERACTIVE" = "true" ]; then
    return 1  # Skip prompts
  fi

  # Check config
  local config_file=".spec/config/flow.json"
  if [ -f "$config_file" ] && command -v jq &> /dev/null; then
    local interactive=$(jq -r '.preferences.interactive_mode // true' "$config_file" 2>/dev/null)
    if [ "$interactive" = "false" ]; then
      return 1  # Skip prompts
    fi
  fi

  return 0  # Show prompts
}

# Check if phase transition prompts should be shown
# Returns 0 (true) if transition prompts should be shown, 1 (false) if they should be skipped
should_prompt_transitions() {
  local config_file=".spec/config/flow.json"

  if [ -f "$config_file" ] && command -v jq &> /dev/null; then
    local enabled=$(jq -r '.preferences.interactive_transitions // false' "$config_file" 2>/dev/null)
    if [ "$enabled" = "true" ]; then
      return 0  # Show transition prompts
    fi
  fi

  return 1  # Skip transition prompts
}

# Export functions for use in other scripts
export -f init_flow_config
export -f get_flow_config
export -f set_flow_config
export -f validate_flow_config
export -f check_jq_available
export -f validate_jira_key
export -f validate_confluence_page_id
export -f should_prompt_interactive
export -f should_prompt_transitions
