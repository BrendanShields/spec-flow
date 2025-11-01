# Spec Workflow System - Complete Guide

Spec is a specification-driven development workflow for Claude Code that helps you ship features faster with better quality.

## Overview

Spec provides a structured workflow:
1. **Specify** - Define what to build (user stories, acceptance criteria)
2. **Plan** - Design how to build it (architecture, components, ADRs)
3. **Tasks** - Break down into actionable tasks
4. **Implement** - Execute with progress tracking
5. **Validate** - Check consistency and completeness

## Quick Start

### Initialize Spec

```bash
# Interactive mode (recommended for first time)
/spec init

# Non-interactive mode
/spec init --type=brownfield --jira=PROJ --confluence=123456
```

### Create Your First Feature

```bash
/spec specify "User authentication with email/password"
/spec plan
/spec tasks
/spec implement
```

### Check Progress

```bash
/spec status     # Current phase and progress
/spec            # Interactive menu
```

## Commands Reference

### Workflow Commands

**`/spec init`**
Initialize Spec in your project.

Options:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA integration
- `--confluence=PAGE-ID` - Enable Confluence integration

Examples:
```bash
/spec init --type=greenfield
/spec init --type=brownfield --jira=FLOW
/spec init --type=brownfield --jira=PROJ --confluence=123456
```

**`/spec specify "Feature description"`**
Create feature specification with prioritized user stories.

Creates: `.spec/features/###-feature-name/spec.md`

**`/spec plan`**
Create technical implementation plan.

Creates: `.spec/features/###-feature-name/plan.md`

**`/spec tasks`**
Break plan into implementation tasks.

Creates: `.spec/features/###-feature-name/tasks.md`

**`/spec implement`**
Execute implementation autonomously.

Options:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**`/spec validate`**
Check workflow consistency and completeness.

**`/spec status`**
Show current phase, feature, and progress.

**`/spec help`**
Show context-aware help for current phase.

### Utility Commands

**`/flow`** (no args)
Shows interactive menu with phase-aware recommendations.

## Directory Structure

```
.spec/
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

Location: `.spec/config/flow.json`

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
    "validate_on_save": true
  }
}
```

### Reading Configuration

```bash
source .spec/scripts/config.sh

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

## Workflow Phases

### 1. Initialize (init)

Setup Flow structure and configuration.

**When**: First time in project or reconfiguration needed.

**Creates**:
- `.spec/` directory structure
- Configuration file
- State and memory files
- Templates

**Next**: `/spec specify`

### 2. Specify (specify)

Define what to build with user stories and acceptance criteria.

**When**: Starting new feature.

**Creates**: `.spec/features/###-feature-name/spec.md`

**Contains**:
- User stories (P1/P2/P3 prioritized)
- Acceptance criteria
- Technical notes
- Non-functional requirements

**Next**: `/spec plan`

### 3. Plan (plan)

Design technical implementation approach.

**When**: Spec is complete.

**Creates**: `.spec/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/spec tasks`

### 4. Tasks (tasks)

Break plan into actionable implementation tasks.

**When**: Plan is complete.

**Creates**: `.spec/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, etc.)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel execution markers
- Acceptance criteria per task

**Next**: `/spec implement`

### 5. Implement (implement)

Execute tasks autonomously with progress tracking.

**When**: Tasks are defined.

**Updates**:
- Task checkboxes in tasks.md
- Progress in current-session.md
- Completion in CHANGES-COMPLETED.md

**Next**: `/spec validate`

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
/spec init --jira=PROJ

# Or update existing config
source .spec/scripts/config.sh
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "PROJ"
```

**Validation**: Project key must match `^[A-Z][A-Z0-9]+(-[0-9]+)?$`

**Examples**: `FLOW`, `PROJ`, `FLOW-123`

### Confluence Integration

Enable during init or update config:

```bash
/spec init --confluence=123456

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

Run `/spec validate` before:
- Committing changes
- Starting implementation
- Switching phases

### 3. Use Checkpoints

Flow auto-checkpoints at phase transitions. Manual checkpoint:
```bash
/session save "Before major refactor"
```

### 4. Review ADRs

Check `.spec/memory/DECISIONS-LOG.md` for architecture decisions.

### 5. Track Progress

Monitor `.spec/memory/WORKFLOW-PROGRESS.md` for velocity and metrics.

## Troubleshooting

### "Config file not found"

```bash
# Reinitialize Flow
/spec init
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
ls -la .spec/features/###-feature-name/
# Should contain: spec.md, plan.md, tasks.md
```

### "Commands not routing"

Ensure scripts are sourced:
```bash
source .spec/scripts/routing.sh
detect_current_phase  # Should return phase name
```

## Advanced Usage

### Custom Templates

Add custom templates to `.spec/templates/`:

```bash
cp your-template.md .spec/templates/
# Reference in skills as needed
```

### Scripting

All utilities are bash scripts and can be sourced:

```bash
source .spec/scripts/config.sh
source .spec/scripts/format-output.sh
source .spec/scripts/routing.sh

# Use functions
current_phase=$(detect_current_phase)
format_success_header "Custom Operation"
```

### Resume Implementation

Continue from last task:

```bash
/spec implement --resume
```

### Filter by Priority

Implement only P1 tasks:

```bash
/spec implement --filter=P1
```

## Getting Help

- **Context help**: `/spec help` (shows next steps for current phase)
- **Status check**: `/spec status` (current phase and progress)
- **Interactive menu**: `/flow` (shows all options)
- **Full docs**: This file (`.spec/docs/CLAUDE-FLOW.md`)
- **Architecture**: `.spec/docs/ARCHITECTURE.md`
- **Commands**: `.spec/docs/COMMANDS.md`

## Migration from Old Structure

If you have old `.spec-state/` or `.spec-memory/`:

```bash
# Flow automatically migrates on init
/spec init

# Or manually:
mv .spec-state/* .spec/state/
mv .spec-memory/* .spec/memory/
mv features/* .spec/features/
```

## Contributing

Spec is extensible. Add custom skills in `.claude/skills/flow-*/`.

Follow the pattern:
1. Create skill directory
2. Add SKILL.md with workflow
3. Update routing if needed
4. Document in this file

---

**Version**: 2.0
**Last Updated**: 2025-10-28
