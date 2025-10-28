# Navi Worknavi System - Complete Guide

Navi is a specification-driven development worknavi for Claude Code that helps you ship features faster with better quality.

## Overview

Navi provides a structured worknavi:
1. **Specify** - Define what to build (user stories, acceptance criteria)
2. **Plan** - Design how to build it (architecture, components, ADRs)
3. **Tasks** - Break down into actionable tasks
4. **Implement** - Execute with progress tracking
5. **Validate** - Check consistency and completeness

## Quick Start

### Initialize Navi

```bash
# Interactive mode (recommended for first time)
/navi init

# Non-interactive mode
/navi init --type=brownfield --jira=PROJ --confluence=123456
```

### Create Your First Feature

```bash
/navi specify "User authentication with email/password"
/navi plan
/navi tasks
/navi implement
```

### Check Progress

```bash
/navi status     # Current phase and progress
/navi            # Interactive menu
```

## Commands Reference

### Worknavi Commands

**`/navi init`**
Initialize Navi in your project.

Options:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA integration
- `--confluence=PAGE-ID` - Enable Confluence integration

Examples:
```bash
/navi init --type=greenfield
/navi init --type=brownfield --jira=FLOW
/navi init --type=brownfield --jira=PROJ --confluence=123456
```

**`/navi specify "Feature description"`**
Create feature specification with prioritized user stories.

Creates: `.navi/features/###-feature-name/spec.md`

**`/navi plan`**
Create technical implementation plan.

Creates: `.navi/features/###-feature-name/plan.md`

**`/navi tasks`**
Break plan into implementation tasks.

Creates: `.navi/features/###-feature-name/tasks.md`

**`/navi implement`**
Execute implementation autonomously.

Options:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**`/navi validate`**
Check worknavi consistency and completeness.

**`/navi status`**
Show current phase, feature, and progress.

**`/navi help`**
Show context-aware help for current phase.

### Utility Commands

**`/navi`** (no args)
Shows interactive menu with phase-aware recommendations.

## Directory Structure

```
.navi/
├── config/
│   └── navi.json              # Configuration (JIRA, Confluence, preferences)
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

Location: `.navi/config/navi.json`

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
source .navi/scripts/config.sh

# Get values
project_type=$(get_navi_config "project.type")
jira_enabled=$(get_navi_config "integrations.jira.enabled")
jira_key=$(get_navi_config "integrations.jira.project_key")

# Update values
set_navi_config "integrations.jira.enabled" "true"
set_navi_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_navi_config
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

**NEW in Feature 002**: Navi now supports interactive visual menus using Claude Code's AskUserQuestion tool.

**Interactive Mode** (`preferences.interactive_mode: true` - default):
- `/navi` with no arguments shows visual selection menu
- Click to select next action instead of typing commands
- Phase-aware options (only shows relevant commands)
- Automatic skill invocation after selection
- Disable with: `set_navi_config "preferences.interactive_mode" "false"`

**Interactive Transitions** (`preferences.interactive_transitions: false` - opt-in):
- Shows "What's next?" prompts after completing each phase
- Helps guide users through the worknavi
- Enable with: `set_navi_config "preferences.interactive_transitions" "true"`

**Examples**:

```bash
# Interactive menu (default)
/navi
# Shows: Initialize, Specify, Plan, Tasks, Implement, Validate, Status, Help
# User clicks option → automatically executes

# Interactive with transitions enabled
/navi specify "User auth"
# After spec completes, shows: Create Plan, Review Spec, Validate, Exit
# User clicks "Create Plan" → automatically runs /navi plan

# Disable interactive mode
set_navi_config "preferences.interactive_mode" "false"
/navi  # Now shows text menu instead
```

**CLI Arguments Bypass Interactive Prompts**:
- `/navi specify "Feature"` - Direct execution, no prompts
- `/navi init --type=brownfield` - Skips interactive prompts
- Any command with arguments skips interactive mode

## Worknavi Phases

### 1. Initialize (init)

Setup Navi structure and configuration.

**When**: First time in project or reconfiguration needed.

**Creates**:
- `.navi/` directory structure
- Configuration file
- State and memory files
- Templates

**Next**: `/navi specify`

### 2. Specify (specify)

Define what to build with user stories and acceptance criteria.

**When**: Starting new feature.

**Creates**: `.navi/features/###-feature-name/spec.md`

**Contains**:
- User stories (P1/P2/P3 prioritized)
- Acceptance criteria
- Technical notes
- Non-functional requirements

**Next**: `/navi plan`

### 3. Plan (plan)

Design technical implementation approach.

**When**: Spec is complete.

**Creates**: `.navi/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/navi tasks`

### 4. Tasks (tasks)

Break plan into actionable implementation tasks.

**When**: Plan is complete.

**Creates**: `.navi/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, etc.)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel execution markers
- Acceptance criteria per task

**Next**: `/navi implement`

### 5. Implement (implement)

Execute tasks autonomously with progress tracking.

**When**: Tasks are defined.

**Updates**:
- Task checkboxes in tasks.md
- Progress in current-session.md
- Completion in CHANGES-COMPLETED.md

**Next**: `/navi validate`

### 6. Validate (validate)

Check worknavi consistency and completeness.

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
/navi init --jira=PROJ

# Or update existing config
source .navi/scripts/config.sh
set_navi_config "integrations.jira.enabled" "true"
set_navi_config "integrations.jira.project_key" "PROJ"
```

**Validation**: Project key must match `^[A-Z][A-Z0-9]+(-[0-9]+)?$`

**Examples**: `FLOW`, `PROJ`, `FLOW-123`

### Confluence Integration

Enable during init or update config:

```bash
/navi init --confluence=123456

# Or update existing config
set_navi_config "integrations.confluence.enabled" "true"
set_navi_config "integrations.confluence.root_page_id" "123456"
```

**Validation**: Page ID must be numeric only.

**Finding Page ID**: Check Confluence URL - `pageId=123456`

## Best Practices

### 1. Start Small

Begin with P1 user stories only. Add P2/P3 later if needed.

### 2. Validate Often

Run `/navi validate` before:
- Committing changes
- Starting implementation
- Switching phases

### 3. Use Checkpoints

Navi auto-checkpoints at phase transitions. Manual checkpoint:
```bash
/session save "Before major refactor"
```

### 4. Review ADRs

Check `.navi/memory/DECISIONS-LOG.md` for architecture decisions.

### 5. Track Progress

Monitor `.navi/memory/WORKFLOW-PROGRESS.md` for velocity and metrics.

## Troubleshooting

### "Config file not found"

```bash
# Reinitialize Navi
/navi init
```

### "Invalid JIRA key format"

JIRA keys must be uppercase letters/numbers: `PROJ`, `FLOW`, `ABC-123`

```bash
# Fix in config
set_navi_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection incorrect"

Check feature directory structure:
```bash
ls -la .navi/features/###-feature-name/
# Should contain: spec.md, plan.md, tasks.md
```

### "Commands not routing"

Ensure scripts are sourced:
```bash
source .navi/scripts/routing.sh
detect_current_phase  # Should return phase name
```

## Advanced Usage

### Custom Templates

Add custom templates to `.navi/templates/`:

```bash
cp your-template.md .navi/templates/
# Reference in skills as needed
```

### Scripting

All utilities are bash scripts and can be sourced:

```bash
source .navi/scripts/config.sh
source .navi/scripts/format-output.sh
source .navi/scripts/routing.sh

# Use functions
current_phase=$(detect_current_phase)
format_success_header "Custom Operation"
```

### Resume Implementation

Continue from last task:

```bash
/navi implement --resume
```

### Filter by Priority

Implement only P1 tasks:

```bash
/navi implement --filter=P1
```

## Getting Help

- **Context help**: `/navi help` (shows next steps for current phase)
- **Status check**: `/navi status` (current phase and progress)
- **Interactive menu**: `/navi` (shows all options)
- **Full docs**: This file (`.navi/docs/CLAUDE-FLOW.md`)
- **Architecture**: `.navi/docs/ARCHITECTURE.md`
- **Commands**: `.navi/docs/COMMANDS.md`

## Migration from Old Structure

If you have old `.navi-state/` or `.navi-memory/`:

```bash
# Navi automatically migrates on init
/navi init

# Or manually:
mv .navi-state/* .navi/state/
mv .navi-memory/* .navi/memory/
mv features/* .navi/features/
```

## Contributing

Navi is extensible. Add custom skills in `.claude/skills/navi-*/`.

Follow the pattern:
1. Create skill directory
2. Add SKILL.md with worknavi
3. Update routing if needed
4. Document in this file

---

**Version**: 2.0
**Last Updated**: 2025-10-28
