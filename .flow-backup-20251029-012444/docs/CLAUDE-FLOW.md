# Flow Workflow System - Complete Guide

Flow is a specification-driven development workflow for Claude Code that helps you ship features faster with better quality.

## Overview

Flow provides a structured workflow:
1. **Specify** - Define what to build (user stories, acceptance criteria)
2. **Plan** - Design how to build it (architecture, components, ADRs)
3. **Tasks** - Break down into actionable tasks
4. **Implement** - Execute with progress tracking
5. **Validate** - Check consistency and completeness

## Quick Start

### Initialize Flow

```bash
# Interactive mode (recommended for first time)
/flow init

# Non-interactive mode
/flow init --type=brownfield --jira=PROJ --confluence=123456
```

### Create Your First Feature

```bash
/flow specify "User authentication with email/password"
/flow plan
/flow tasks
/flow implement
```

### Check Progress

```bash
/flow status     # Current phase and progress
/flow            # Interactive menu
```

## Commands Reference

### Workflow Commands

**`/flow init`**
Initialize Flow in your project.

Options:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA integration
- `--confluence=PAGE-ID` - Enable Confluence integration

Examples:
```bash
/flow init --type=greenfield
/flow init --type=brownfield --jira=FLOW
/flow init --type=brownfield --jira=PROJ --confluence=123456
```

**`/flow specify "Feature description"`**
Create feature specification with prioritized user stories.

Creates: `.flow/features/###-feature-name/spec.md`

**`/flow plan`**
Create technical implementation plan.

Creates: `.flow/features/###-feature-name/plan.md`

**`/flow tasks`**
Break plan into implementation tasks.

Creates: `.flow/features/###-feature-name/tasks.md`

**`/flow implement`**
Execute implementation autonomously.

Options:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**`/flow validate`**
Check workflow consistency and completeness.

**`/flow status`**
Show current phase, feature, and progress.

**`/flow help`**
Show context-aware help for current phase.

### Utility Commands

**`/flow`** (no args)
Shows interactive menu with phase-aware recommendations.

## Directory Structure

```
.flow/
├── config/
│   └── flow.json              # Configuration (JIRA, Confluence, preferences)
│
├── state/                     # Session state (git-ignored)
│   ├── current-session.md     # Active feature and phase
│   └── checkpoints/           # Session snapshots
│
├── memory/                    # Persistent tracking (committed)
│   ├── WORKFLOW-PROGRESS.md   # Feature completion metrics
│   ├── DECISIONS-LOG.md       # Architecture decisions (ADRs)
│   ├── CHANGES-PLANNED.md     # Upcoming work queue
│   └── CHANGES-COMPLETED.md   # Historical record
│
├── features/                  # Feature artifacts (committed)
│   └── ###-feature-name/
│       ├── spec.md            # Specification with user stories
│       ├── plan.md            # Technical design
│       └── tasks.md           # Implementation tasks
│
├── templates/                 # Document templates
│   ├── spec-template.md
│   ├── plan-template.md
│   └── tasks-template.md
│
├── scripts/                   # Utility scripts
│   ├── config.sh              # Configuration management
│   ├── format-output.sh       # Output formatting
│   └── routing.sh             # Command routing
│
└── docs/                      # Documentation
    ├── CLAUDE-FLOW.md         # This file
    ├── ARCHITECTURE.md        # System design
    └── COMMANDS.md            # Quick reference
```

## Configuration

### Configuration File

Location: `.flow/config/flow.json`

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

### Reading Configuration

```bash
source .flow/scripts/config.sh

# Get values
project_type=$(get_flow_config "project.type")
jira_enabled=$(get_flow_config "integrations.jira.enabled")
jira_key=$(get_flow_config "integrations.jira.project_key")

# Update values
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_flow_config
```

### Project Types

**Greenfield Projects**:
- New projects from scratch
- Full architecture blueprint
- Complete templates and scaffolding
- API contracts and data models

**Brownfield Projects**:
- Existing codebases
- Feature-focused specifications
- Minimal disruption to existing structure
- Incremental adoption

### Interactive Mode

**NEW in Feature 002**: Flow now supports interactive visual menus using Claude Code's AskUserQuestion tool.

**Interactive Mode** (`preferences.interactive_mode: true` - default):
- `/flow` with no arguments shows visual selection menu
- Click to select next action instead of typing commands
- Phase-aware options (only shows relevant commands)
- Automatic skill invocation after selection
- Disable with: `set_flow_config "preferences.interactive_mode" "false"`

**Interactive Transitions** (`preferences.interactive_transitions: false` - opt-in):
- Shows "What's next?" prompts after completing each phase
- Helps guide users through the workflow
- Enable with: `set_flow_config "preferences.interactive_transitions" "true"`

**Examples**:

```bash
# Interactive menu (default)
/flow
# Shows: Initialize, Specify, Plan, Tasks, Implement, Validate, Status, Help
# User clicks option → automatically executes

# Interactive with transitions enabled
/flow specify "User auth"
# After spec completes, shows: Create Plan, Review Spec, Validate, Exit
# User clicks "Create Plan" → automatically runs /flow plan

# Disable interactive mode
set_flow_config "preferences.interactive_mode" "false"
/flow  # Now shows text menu instead
```

**CLI Arguments Bypass Interactive Prompts**:
- `/flow specify "Feature"` - Direct execution, no prompts
- `/flow init --type=brownfield` - Skips interactive prompts
- Any command with arguments skips interactive mode

## Workflow Phases

### 1. Initialize (init)

Setup Flow structure and configuration.

**When**: First time in project or reconfiguration needed.

**Creates**:
- `.flow/` directory structure
- Configuration file
- State and memory files
- Templates

**Next**: `/flow specify`

### 2. Specify (specify)

Define what to build with user stories and acceptance criteria.

**When**: Starting new feature.

**Creates**: `.flow/features/###-feature-name/spec.md`

**Contains**:
- User stories (P1/P2/P3 prioritized)
- Acceptance criteria
- Technical notes
- Non-functional requirements

**Next**: `/flow plan`

### 3. Plan (plan)

Design technical implementation approach.

**When**: Spec is complete.

**Creates**: `.flow/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/flow tasks`

### 4. Tasks (tasks)

Break plan into actionable implementation tasks.

**When**: Plan is complete.

**Creates**: `.flow/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, etc.)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel execution markers
- Acceptance criteria per task

**Next**: `/flow implement`

### 5. Implement (implement)

Execute tasks autonomously with progress tracking.

**When**: Tasks are defined.

**Updates**:
- Task checkboxes in tasks.md
- Progress in current-session.md
- Completion in CHANGES-COMPLETED.md

**Next**: `/flow validate`

### 6. Validate (validate)

Check workflow consistency and completeness.

**When**: Implementation complete or before commits.

**Checks**:
- Spec/plan/tasks alignment
- Task completion
- Documentation quality
- Test coverage

## Integrations

### JIRA Integration

Enable during init or update config:

```bash
/flow init --jira=PROJ

# Or update existing config
source .flow/scripts/config.sh
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "PROJ"
```

**Validation**: Project key must match `^[A-Z][A-Z0-9]+(-[0-9]+)?$`

**Examples**: `FLOW`, `PROJ`, `FLOW-123`

### Confluence Integration

Enable during init or update config:

```bash
/flow init --confluence=123456

# Or update existing config
set_flow_config "integrations.confluence.enabled" "true"
set_flow_config "integrations.confluence.root_page_id" "123456"
```

**Validation**: Page ID must be numeric only.

**Finding Page ID**: Check Confluence URL - `pageId=123456`

## Best Practices

### 1. Start Small

Begin with P1 user stories only. Add P2/P3 later if needed.

### 2. Validate Often

Run `/flow validate` before:
- Committing changes
- Starting implementation
- Switching phases

### 3. Use Checkpoints

Flow auto-checkpoints at phase transitions. Manual checkpoint:
```bash
/session save "Before major refactor"
```

### 4. Review ADRs

Check `.flow/memory/DECISIONS-LOG.md` for architecture decisions.

### 5. Track Progress

Monitor `.flow/memory/WORKFLOW-PROGRESS.md` for velocity and metrics.

## Troubleshooting

### "Config file not found"

```bash
# Reinitialize Flow
/flow init
```

### "Invalid JIRA key format"

JIRA keys must be uppercase letters/numbers: `PROJ`, `FLOW`, `ABC-123`

```bash
# Fix in config
set_flow_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection incorrect"

Check feature directory structure:
```bash
ls -la .flow/features/###-feature-name/
# Should contain: spec.md, plan.md, tasks.md
```

### "Commands not routing"

Ensure scripts are sourced:
```bash
source .flow/scripts/routing.sh
detect_current_phase  # Should return phase name
```

## Advanced Usage

### Custom Templates

Add custom templates to `.flow/templates/`:

```bash
cp your-template.md .flow/templates/
# Reference in skills as needed
```

### Scripting

All utilities are bash scripts and can be sourced:

```bash
source .flow/scripts/config.sh
source .flow/scripts/format-output.sh
source .flow/scripts/routing.sh

# Use functions
current_phase=$(detect_current_phase)
format_success_header "Custom Operation"
```

### Resume Implementation

Continue from last task:

```bash
/flow implement --resume
```

### Filter by Priority

Implement only P1 tasks:

```bash
/flow implement --filter=P1
```

## Getting Help

- **Context help**: `/flow help` (shows next steps for current phase)
- **Status check**: `/flow status` (current phase and progress)
- **Interactive menu**: `/flow` (shows all options)
- **Full docs**: This file (`.flow/docs/CLAUDE-FLOW.md`)
- **Architecture**: `.flow/docs/ARCHITECTURE.md`
- **Commands**: `.flow/docs/COMMANDS.md`

## Migration from Old Structure

If you have old `.flow-state/` or `.flow-memory/`:

```bash
# Flow automatically migrates on init
/flow init

# Or manually:
mv .flow-state/* .flow/state/
mv .flow-memory/* .flow/memory/
mv features/* .flow/features/
```

## Contributing

Flow is extensible. Add custom skills in `.claude/skills/flow-*/`.

Follow the pattern:
1. Create skill directory
2. Add SKILL.md with workflow
3. Update routing if needed
4. Document in this file

---

**Version**: 2.0
**Last Updated**: 2025-10-28
