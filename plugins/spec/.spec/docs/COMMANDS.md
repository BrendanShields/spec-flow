# Spec Commands - Quick Reference

Fast lookup for all Spec commands with syntax and examples.

## Workflow Commands

### /spec

**Unified workflow command** - Interactive menu or direct routing.

**Syntax**:
```bash
/spec                    # Interactive menu
/spec <subcommand> [args]  # Direct execution
```

**Examples**:
```bash
/spec                    # Show menu
/spec init              # Initialize Spec
/spec specify "feature" # Create specification
/spec status            # Show progress
```

---

### /spec init

**Initialize Spec** in project with configuration.

**Syntax**:
```bash
/spec init [--type=TYPE] [--jira=KEY] [--confluence=ID]
```

**Arguments**:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA with key
- `--confluence=PAGE-ID` - Enable Confluence with page ID

**Examples**:
```bash
# Interactive mode
/spec init

# Greenfield project
/spec init --type=greenfield

# Brownfield with JIRA
/spec init --type=brownfield --jira=PROJ

# Complete setup
/spec init --type=greenfield --jira=FLOW --confluence=123456
```

**Creates**:
- `.spec/` directory structure
- `.spec/config/flow.json`
- State and memory files

**Next**: `/spec specify`

---

### /spec specify

**Create feature specification** with user stories.

**Syntax**:
```bash
/spec specify "<feature description>"
```

**Examples**:
```bash
/spec specify "User authentication with OAuth"
/spec specify "Export data to CSV format"
```

**Creates**:
- `.spec/features/###-feature-name/spec.md`

**Contains**:
- P1/P2/P3 user stories
- Acceptance criteria
- Technical notes

**Next**: `/spec plan`

---

### /spec plan

**Create technical plan** from specification.

**Syntax**:
```bash
/spec plan
```

**Creates**:
- `.spec/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/spec tasks`

---

### /spec tasks

**Break down into tasks** from technical plan.

**Syntax**:
```bash
/spec tasks
```

**Creates**:
- `.spec/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, ...)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel markers [P]
- Acceptance criteria

**Next**: `/spec implement`

---

### /spec implement

**Execute implementation** autonomously.

**Syntax**:
```bash
/spec implement [--resume] [--filter=PRIORITY]
```

**Arguments**:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**Examples**:
```bash
/spec implement              # Start implementation
/spec implement --resume     # Continue after interruption
/spec implement --filter=P1  # P1 tasks only
```

**Updates**:
- Task checkboxes in tasks.md
- `.spec/state/current-session.md`
- `.spec/memory/CHANGES-COMPLETED.md`

**Next**: `/spec validate`

---

### /spec validate

**Check workflow consistency** and completeness.

**Syntax**:
```bash
/spec validate
```

**Checks**:
- Spec/plan/tasks alignment
- Task completion
- File consistency
- Configuration validity

**When to Run**:
- Before committing
- After major changes
- Before starting implementation

---

### /spec status

**Show current progress** and phase.

**Syntax**:
```bash
/spec status
```

**Displays**:
- Current phase
- Active feature
- Task progress (X/Y complete)
- Recommended next command

**Example Output**:
```
Phase: implement
Feature: 001-user-auth
Progress: 12/22 tasks
Recommended next: /spec implement
```

---

### /spec help

**Context-aware help** for current phase.

**Syntax**:
```bash
/spec help
```

**Shows**:
- Current phase
- Next recommended step
- Command syntax
- All available commands

---

## Configuration Commands

### Read Configuration

```bash
source .spec/scripts/config.sh

# Read values
project_type=$(get_flow_config "project.type")
jira_enabled=$(get_flow_config "integrations.jira.enabled")
jira_key=$(get_flow_config "integrations.jira.project_key")
```

### Update Configuration

```bash
source .spec/scripts/config.sh

# Update values
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_flow_config
```

### Validate Inputs

```bash
source .spec/scripts/config.sh

# Validate JIRA key
validate_jira_key "PROJ"      # Valid
validate_jira_key "FLOW-123"  # Valid
validate_jira_key "invalid"   # Error

# Validate Confluence page ID
validate_confluence_page_id "123456"  # Valid
validate_confluence_page_id "abc"     # Error
```

---

## Output Formatting

### Use in Scripts/Skills

```bash
source .spec/scripts/format-output.sh

# TLDR box
tldr_content="Summary of changes"
format_tldr "$tldr_content"

# Next steps box
next_steps="1. Run tests\n2. Commit changes"
format_next_steps "$next_steps"

# Status indicators
format_status_indicator "completed"  # ✅
format_status_indicator "next"       # ➡️
format_status_indicator "pending"    # ⏳
format_status_indicator "error"      # ❌
format_status_indicator "warning"    # ⚠️

# Complete success message
format_complete_success "Operation Complete" "$tldr" "$details" "$next_steps"

# Progress bar
format_progress_bar 7 10  # [████████░░] 70% (7/10)
```

---

## Phase Detection

### Check Current Phase

```bash
source .spec/scripts/routing.sh

# Detect phase
current_phase=$(detect_current_phase)
# Returns: init|specify|plan|tasks|implement|complete

# Get recommendation
next_cmd=$(get_next_suggested_command)
# Returns: init|specify|plan|tasks|implement|validate

# Check if phase complete
is_phase_complete "specify" && echo "Spec done"
```

---

## Session Management

### Save Checkpoint

```bash
/session save "Before major refactor"
```

### Restore Checkpoint

```bash
/session restore <checkpoint-name>
```

### List Checkpoints

```bash
/session list
```

---

## File Locations

### Configuration

```
.spec/config/flow.json           # Main configuration
```

### State (git-ignored)

```
.spec/state/current-session.md   # Active session
.spec/state/checkpoints/          # Saved checkpoints
```

### Memory (committed)

```
.spec/memory/WORKFLOW-PROGRESS.md   # Metrics
.spec/memory/DECISIONS-LOG.md       # ADRs
.spec/memory/CHANGES-PLANNED.md     # Upcoming work
.spec/memory/CHANGES-COMPLETED.md   # History
```

### Features (committed)

```
.spec/features/###-name/spec.md     # Specification
.spec/features/###-name/plan.md     # Technical plan
.spec/features/###-name/tasks.md    # Implementation tasks
```

### Scripts

```
.spec/scripts/config.sh             # Config utilities
.spec/scripts/format-output.sh      # Formatting utilities
.spec/scripts/routing.sh            # Routing utilities
```

### Documentation

```
.spec/docs/CLAUDE-FLOW.md           # Complete guide
.spec/docs/ARCHITECTURE.md          # System design
.spec/docs/COMMANDS.md              # This file
```

---

## Common Workflows

### New Feature

```bash
/spec specify "Feature description"
/spec plan
/spec tasks
/spec implement
/spec validate
```

### Resume Work

```bash
/spec status                    # Check where you are
/spec implement --resume        # Continue
```

### Check Progress

```bash
/spec                          # Interactive menu
/spec status                   # Detailed status
```

### Reconfigure

```bash
/spec init                     # Reconfigure interactively

# Or update config directly
source .spec/scripts/config.sh
set_flow_config "integrations.jira.project_key" "NEWPROJ"
```

---

## Keyboard Shortcuts

None currently - all commands are text-based.

Future: Add keyboard shortcuts for common operations.

---

## Tips & Tricks

### Fast Navigation

```bash
alias f='spec'
f status
f specify "Quick feature"
```

### Auto-complete

If using zsh/bash completion:
```bash
# Add to .zshrc or .bashrc
complete -W "init specify plan tasks implement validate status help" flow
```

### Quick Status

```bash
# Add to shell prompt
SPEC_PHASE=$(detect_current_phase 2>/dev/null || echo "none")
```

### Batch Operations

```bash
# Multiple features
/spec specify "Feature 1" && /spec specify "Feature 2"

# Full workflow
/spec specify "Quick feature" && /spec plan && /spec tasks
```

---

## Error Messages

### "Config file not found"

```bash
# Solution: Initialize Spec
/spec init
```

### "Invalid JIRA key format"

```bash
# JIRA keys must be: PROJECT or PROJECT-123
set_flow_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection failed"

```bash
# Check feature directory
ls -la .spec/features/###-feature-name/
# Should contain: spec.md, plan.md, tasks.md
```

### "jq not found"

```bash
# Install jq
brew install jq          # macOS
apt-get install jq       # Linux

# Fallback parser available but limited
```

---

## Version

**Commands Reference Version**: 2.0
**Last Updated**: 2025-10-28

For complete documentation, see [CLAUDE-FLOW.md](./CLAUDE-FLOW.md).
