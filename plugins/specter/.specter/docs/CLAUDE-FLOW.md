# Specter Workflow System - Complete Guide

Specter is a specification-driven development workflow for Claude Code that helps you ship features faster with better quality.

## Overview

Specter provides a structured workflow:
1. **Specify** - Define what to build (user stories, acceptance criteria)
2. **Plan** - Design how to build it (architecture, components, ADRs)
3. **Tasks** - Break down into actionable tasks
4. **Implement** - Execute with progress tracking
5. **Validate** - Check consistency and completeness

## Quick Start

### Initialize Specter

```bash
# Interactive mode (recommended for first time)
/specter init

# Non-interactive mode
/specter init --type=brownfield --jira=PROJ --confluence=123456
```

### Create Your First Feature

```bash
/specter specify "User authentication with email/password"
/specter plan
/specter tasks
/specter implement
```

### Check Progress

```bash
/specter status     # Current phase and progress
/specter            # Interactive menu
```

## Commands Reference

### Workflow Commands

**`/specter init`**
Initialize Specter in your project.

Options:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA integration
- `--confluence=PAGE-ID` - Enable Confluence integration

Examples:
```bash
/specter init --type=greenfield
/specter init --type=brownfield --jira=FLOW
/specter init --type=brownfield --jira=PROJ --confluence=123456
```

**`/specter specify "Feature description"`**
Create feature specification with prioritized user stories.

Creates: `.specter/features/###-feature-name/spec.md`

**`/specter plan`**
Create technical implementation plan.

Creates: `.specter/features/###-feature-name/plan.md`

**`/specter tasks`**
Break plan into implementation tasks.

Creates: `.specter/features/###-feature-name/tasks.md`

**`/specter implement`**
Execute implementation autonomously.

Options:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**`/specter validate`**
Check workflow consistency and completeness.

**`/specter status`**
Show current phase, feature, and progress.

**`/specter help`**
Show context-aware help for current phase.

### Utility Commands

**`/flow`** (no args)
Shows interactive menu with phase-aware recommendations.

## Directory Structure

```
.specter/
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

Location: `.specter/config/flow.json`

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
source .specter/scripts/config.sh

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
- `.specter/` directory structure
- Configuration file
- State and memory files
- Templates

**Next**: `/specter specify`

### 2. Specify (specify)

Define what to build with user stories and acceptance criteria.

**When**: Starting new feature.

**Creates**: `.specter/features/###-feature-name/spec.md`

**Contains**:
- User stories (P1/P2/P3 prioritized)
- Acceptance criteria
- Technical notes
- Non-functional requirements

**Next**: `/specter plan`

### 3. Plan (plan)

Design technical implementation approach.

**When**: Spec is complete.

**Creates**: `.specter/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/specter tasks`

### 4. Tasks (tasks)

Break plan into actionable implementation tasks.

**When**: Plan is complete.

**Creates**: `.specter/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, etc.)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel execution markers
- Acceptance criteria per task

**Next**: `/specter implement`

### 5. Implement (implement)

Execute tasks autonomously with progress tracking.

**When**: Tasks are defined.

**Updates**:
- Task checkboxes in tasks.md
- Progress in current-session.md
- Completion in CHANGES-COMPLETED.md

**Next**: `/specter validate`

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
/specter init --jira=PROJ

# Or update existing config
source .specter/scripts/config.sh
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "PROJ"
```

**Validation**: Project key must match `^[A-Z][A-Z0-9]+(-[0-9]+)?$`

**Examples**: `FLOW`, `PROJ`, `FLOW-123`

### Confluence Integration

Enable during init or update config:

```bash
/specter init --confluence=123456

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

Run `/specter validate` before:
- Committing changes
- Starting implementation
- Switching phases

### 3. Use Checkpoints

Flow auto-checkpoints at phase transitions. Manual checkpoint:
```bash
/session save "Before major refactor"
```

### 4. Review ADRs

Check `.specter/memory/DECISIONS-LOG.md` for architecture decisions.

### 5. Track Progress

Monitor `.specter/memory/WORKFLOW-PROGRESS.md` for velocity and metrics.

## Troubleshooting

### "Config file not found"

```bash
# Reinitialize Flow
/specter init
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
ls -la .specter/features/###-feature-name/
# Should contain: spec.md, plan.md, tasks.md
```

### "Commands not routing"

Ensure scripts are sourced:
```bash
source .specter/scripts/routing.sh
detect_current_phase  # Should return phase name
```

## Advanced Usage

### Custom Templates

Add custom templates to `.specter/templates/`:

```bash
cp your-template.md .specter/templates/
# Reference in skills as needed
```

### Scripting

All utilities are bash scripts and can be sourced:

```bash
source .specter/scripts/config.sh
source .specter/scripts/format-output.sh
source .specter/scripts/routing.sh

# Use functions
current_phase=$(detect_current_phase)
format_success_header "Custom Operation"
```

### Resume Implementation

Continue from last task:

```bash
/specter implement --resume
```

### Filter by Priority

Implement only P1 tasks:

```bash
/specter implement --filter=P1
```

## Getting Help

- **Context help**: `/specter help` (shows next steps for current phase)
- **Status check**: `/specter status` (current phase and progress)
- **Interactive menu**: `/flow` (shows all options)
- **Full docs**: This file (`.specter/docs/CLAUDE-FLOW.md`)
- **Architecture**: `.specter/docs/ARCHITECTURE.md`
- **Commands**: `.specter/docs/COMMANDS.md`

## Migration from Old Structure

If you have old `.specter-state/` or `.specter-memory/`:

```bash
# Flow automatically migrates on init
/specter init

# Or manually:
mv .specter-state/* .specter/state/
mv .specter-memory/* .specter/memory/
mv features/* .specter/features/
```

## Contributing

Specter is extensible. Add custom skills in `.claude/skills/flow-*/`.

Follow the pattern:
1. Create skill directory
2. Add SKILL.md with workflow
3. Update routing if needed
4. Document in this file

---

**Version**: 2.0
**Last Updated**: 2025-10-28
