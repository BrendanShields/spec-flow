---
name: flow:init
description: Initialize Flow for specification-driven development. Use when 1) Starting new project (greenfield), 2) Adding Flow to existing codebase (brownfield), 3) User says "setup/configure/initialize flow", 4) Reconfiguring after adding MCP servers, 5) Setting up JIRA/Confluence integration. Creates __specification__/ directory with templates and configuration.
allowed-tools: Bash, Write, Read, Edit, AskUserQuestion
---

# Flow Init

Initialize Flow project structure with interactive configuration and optional integrations.

## Core Workflow

### 1. Check for CLI Arguments

Parse command-line arguments if provided:
- `--type=greenfield|brownfield` - Skip project type prompt
- `--jira=PROJECT-KEY` - Enable JIRA and set project key
- `--confluence=PAGE-ID` - Enable Confluence and set root page ID

If all arguments provided, skip interactive prompts.

### 2. Interactive Configuration (if needed)

Use AskUserQuestion tool with TWO-STEP conditional approach to gather configuration.

**STEP 1: Core Configuration** (3 questions - ask together)

Use AskUserQuestion to ask all 3 questions in a single call:

```json
{
  "questions": [
    {
      "question": "What type of project is this?",
      "header": "Project",
      "multiSelect": false,
      "options": [
        {
          "label": "Greenfield",
          "description": "New project - creates full architecture blueprint and templates"
        },
        {
          "label": "Brownfield",
          "description": "Existing codebase - focuses on feature specifications"
        }
      ]
    },
    {
      "question": "Enable JIRA integration for issue tracking?",
      "header": "JIRA",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes",
          "description": "Sync specs and tasks with JIRA"
        },
        {
          "label": "No",
          "description": "Use Flow without JIRA integration"
        }
      ]
    },
    {
      "question": "Enable Confluence integration for documentation?",
      "header": "Confluence",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes",
          "description": "Sync plans and specs to Confluence"
        },
        {
          "label": "No",
          "description": "Use Flow without Confluence integration"
        }
      ]
    }
  ]
}
```

**STEP 2: Integration Keys** (conditional - only if integrations enabled)

If JIRA or Confluence was enabled in Step 1, ask for keys:

Build questions array dynamically:
- If JIRA enabled: include JIRA key question
- If Confluence enabled: include Confluence page ID question
- Ask 1-2 questions depending on what was enabled

```json
{
  "questions": [
    // Include only if JIRA enabled:
    {
      "question": "Enter your JIRA project key (examples: PROJ, FLOW, MYPROJ):",
      "header": "JIRA Key",
      "multiSelect": false,
      "options": [
        {
          "label": "PROJ",
          "description": "Use PROJ as project key"
        },
        {
          "label": "FLOW",
          "description": "Use FLOW as project key"
        }
        // User can select "Other" to type custom key
      ]
    },
    // Include only if Confluence enabled:
    {
      "question": "Enter your Confluence root page ID (numeric only):",
      "header": "Page ID",
      "multiSelect": false,
      "options": [
        {
          "label": "123456",
          "description": "Example page ID"
        },
        {
          "label": "654321",
          "description": "Example page ID"
        }
        // User can select "Other" to type custom ID
      ]
    }
  ]
}
```

**Handling "Other" Responses**:
- When user selects "Other", the response will be: "Other: user-typed-value"
- Extract the value after "Other: " and use it
- Validate the extracted value (see Step 3 below)

### 3. Validation and Re-prompting

Validate user inputs and re-prompt if invalid:

```bash
source __specification__/scripts/config.sh

# Validate JIRA key if provided
if [ -n "$jira_key" ]; then
  while ! validate_jira_key "$jira_key"; do
    echo "Invalid JIRA key format. Expected: PROJECT or PROJECT-123 (e.g., FLOW, PROJ-456)"
    # Re-prompt using AskUserQuestion with error message shown
    # Ask again for JIRA key only
  done
fi

# Validate Confluence page ID if provided
if [ -n "$confluence_id" ]; then
  while ! validate_confluence_page_id "$confluence_id"; do
    echo "Invalid Confluence page ID. Must be numeric only (e.g., 123456)"
    # Re-prompt using AskUserQuestion with error message shown
    # Ask again for Confluence page ID only
  done
fi
```

**Re-prompting Flow**:
1. Attempt validation using helper functions from config.sh
2. If validation fails, show clear error message
3. Use AskUserQuestion again to ask for ONLY the invalid field
4. Repeat until valid input received
5. Validation functions: `validate_jira_key()` and `validate_confluence_page_id()`

### 4. Initialize Configuration

Create JSON configuration file:
```bash
source __specification__/scripts/config.sh

# Initialize with project type
init_flow_config "$project_type"

# Update JIRA settings if enabled
if [ "$jira_enabled" = "true" ]; then
  set_flow_config "integrations.jira.enabled" "true"
  set_flow_config "integrations.jira.project_key" "$jira_key"
fi

# Update Confluence settings if enabled
if [ "$confluence_enabled" = "true" ]; then
  set_flow_config "integrations.confluence.enabled" "true"
  set_flow_config "integrations.confluence.root_page_id" "$confluence_id"
fi

# Validate configuration
validate_flow_config
```

### 5. Directory Structure Creation

Create directory structure:
```bash
# Create all __specification__ subdirectories
mkdir -p __specification__/{config,state,memory,features,templates,scripts,docs}
mkdir -p __specification__/state/checkpoints

# Initialize state management
source .claude/commands/lib/init-state.sh
main
```

### 6. Copy Templates and Scripts

Copy templates from plugin (if available):
```bash
# Check if plugin templates exist
if [ -d "plugins/flow/templates" ]; then
  cp plugins/flow/templates/*.md __specification__/templates/ 2>/dev/null || true
fi

# Copy script utilities (already created in Phase 1)
# config.sh, format-output.sh, routing.sh already exist
```

### 7. Update Root CLAUDE.md

Prepend concise Flow section to root CLAUDE.md:
```markdown
# Flow Workflow System

Flow is initialized. For complete documentation, see [__specification__/docs/FLOW-GUIDE.md](__specification__/docs/FLOW-GUIDE.md).

## Quick Commands

- `/flow` - Interactive workflow menu
- `/flow init` - Reinitialize or reconfigure
- `/flow specify` - Create feature specification
- `/flow plan` - Create technical plan
- `/flow tasks` - Break into implementation tasks
- `/flow implement` - Execute implementation

## Configuration

Project: {project_type}
JIRA: {enabled/disabled} {project_key if enabled}
Confluence: {enabled/disabled} {page_id if enabled}

Configuration file: `__specification__/config/flow.json`

---

[Rest of existing CLAUDE.md content...]
```

### 8. Output Formatting

Use enhanced output formatting:
```bash
source __specification__/scripts/format-output.sh

# Success message with TLDR
tldr_content="Flow initialized successfully!
• Project type: $project_type
• JIRA: $([ "$jira_enabled" = "true" ] && echo "Enabled ($jira_key)" || echo "Disabled")
• Confluence: $([ "$confluence_enabled" = "true" ] && echo "Enabled ($confluence_id)" || echo "Disabled")
• Config: __specification__/config/flow.json"

next_steps="➡️  /flow specify \"Your first feature\"
➡️  /flow help (for context-aware guidance)
➡️  See __specification__/docs/ for complete documentation"

format_complete_success "Flow Initialized" "$tldr_content" "" "$next_steps"
```

## Command-Line Arguments

**`--type=greenfield|brownfield`**
Set project type explicitly, skip interactive prompt.

**`--jira=PROJECT-KEY`**
Enable JIRA integration with project key (e.g., `--jira=FLOW`).
Skips JIRA prompts. Validates key format.

**`--confluence=PAGE-ID`**
Enable Confluence integration with root page ID (e.g., `--confluence=123456`).
Skips Confluence prompts. Validates numeric format.

**Example Usage**:
```bash
# Interactive mode (all prompts)
/flow init

# Greenfield with no integrations
/flow init --type=greenfield

# Brownfield with JIRA only
/flow init --type=brownfield --jira=PROJ

# Complete non-interactive setup
/flow init --type=greenfield --jira=FLOW --confluence=123456
```

## Configuration File

Settings stored in `__specification__/config/flow.json`:
```json
{
  "version": "2.0",
  "project": {
    "type": "greenfield|brownfield",
    "initialized": "2025-10-28T12:00:00Z",
    "name": "project-name"
  },
  "integrations": {
    "jira": {
      "enabled": true,
      "project_key": "PROJ"
    },
    "confluence": {
      "enabled": true,
      "root_page_id": "123456"
    }
  },
  "preferences": {
    "auto_checkpoint": true,
    "validate_on_save": true,
    "interactive_mode": true,
    "interactive_transitions": false
  }
}
```

**New Preferences** (added in feature 002):
- `interactive_mode` (default: `true`) - Enable/disable AskUserQuestion interactive prompts
- `interactive_transitions` (default: `false`) - Show transition prompts between workflow phases

Other skills read config using `__specification__/scripts/config.sh`:
```bash
source __specification__/scripts/config.sh
project_type=$(get_flow_config "project.type")
jira_key=$(get_flow_config "integrations.jira.project_key")
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Basic greenfield setup
- Brownfield project addition
- Enterprise with JIRA/Confluence
- Reconfiguring after adding MCPs
- POC/spike minimal setup
- Troubleshooting common issues

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete flag documentation
- Directory structure details
- Configuration file formats
- MCP detection logic
- Template copying process
- Integration-specific setup
- Advanced configuration options
- Troubleshooting guide

## Related Skills

- **flow:blueprint**: Define architecture (run after init)
- **flow:specify**: Create specifications (uses init's templates)
- **flow:update**: Add MCP integrations later (extends init)
- **flow:discover**: Analyze brownfield projects (pairs with brownfield init)

## Validation

Test this skill:
```bash
scripts/validate.sh
```

Validates: YAML syntax, description format, token count, modular resources, activation patterns.
