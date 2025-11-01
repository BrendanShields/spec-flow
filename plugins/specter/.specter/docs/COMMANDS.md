# Specter Commands - Quick Reference

Fast lookup for all Specter commands with syntax and examples.

## Workflow Commands

### /specter

**Unified workflow command** - Interactive menu or direct routing.

**Syntax**:
```bash
/specter                    # Interactive menu
/specter <subcommand> [args]  # Direct execution
```

**Examples**:
```bash
/specter                    # Show menu
/specter init              # Initialize Specter
/specter specify "feature" # Create specification
/specter status            # Show progress
```

---

### /specter init

**Initialize Specter** in project with configuration.

**Syntax**:
```bash
/specter init [--type=TYPE] [--jira=KEY] [--confluence=ID]
```

**Arguments**:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA with key
- `--confluence=PAGE-ID` - Enable Confluence with page ID

**Examples**:
```bash
# Interactive mode
/specter init

# Greenfield project
/specter init --type=greenfield

# Brownfield with JIRA
/specter init --type=brownfield --jira=PROJ

# Complete setup
/specter init --type=greenfield --jira=FLOW --confluence=123456
```

**Creates**:
- `.specter/` directory structure
- `.specter/config/flow.json`
- State and memory files

**Next**: `/specter specify`

---

### /specter specify

**Create feature specification** with user stories.

**Syntax**:
```bash
/specter specify "<feature description>"
```

**Examples**:
```bash
/specter specify "User authentication with OAuth"
/specter specify "Export data to CSV format"
```

**Creates**:
- `.specter/features/###-feature-name/spec.md`

**Contains**:
- P1/P2/P3 user stories
- Acceptance criteria
- Technical notes

**Next**: `/specter plan`

---

### /specter plan

**Create technical plan** from specification.

**Syntax**:
```bash
/specter plan
```

**Creates**:
- `.specter/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/specter tasks`

---

### /specter tasks

**Break down into tasks** from technical plan.

**Syntax**:
```bash
/specter tasks
```

**Creates**:
- `.specter/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, ...)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel markers [P]
- Acceptance criteria

**Next**: `/specter implement`

---

### /specter implement

**Execute implementation** autonomously.

**Syntax**:
```bash
/specter implement [--resume] [--filter=PRIORITY]
```

**Arguments**:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**Examples**:
```bash
/specter implement              # Start implementation
/specter implement --resume     # Continue after interruption
/specter implement --filter=P1  # P1 tasks only
```

**Updates**:
- Task checkboxes in tasks.md
- `.specter/state/current-session.md`
- `.specter/memory/CHANGES-COMPLETED.md`

**Next**: `/specter validate`

---

### /specter validate

**Check workflow consistency** and completeness.

**Syntax**:
```bash
/specter validate
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

### /specter status

**Show current progress** and phase.

**Syntax**:
```bash
/specter status
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
Recommended next: /specter implement
```

---

### /specter help

**Context-aware help** for current phase.

**Syntax**:
```bash
/specter help
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
source .specter/scripts/config.sh

# Read values
project_type=$(get_flow_config "project.type")
jira_enabled=$(get_flow_config "integrations.jira.enabled")
jira_key=$(get_flow_config "integrations.jira.project_key")
```

### Update Configuration

```bash
source .specter/scripts/config.sh

# Update values
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_flow_config
```

### Validate Inputs

```bash
source .specter/scripts/config.sh

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
source .specter/scripts/format-output.sh

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
source .specter/scripts/routing.sh

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
.specter/config/flow.json           # Main configuration
```

### State (git-ignored)

```
.specter/state/current-session.md   # Active session
.specter/state/checkpoints/          # Saved checkpoints
```

### Memory (committed)

```
.specter/memory/WORKFLOW-PROGRESS.md   # Metrics
.specter/memory/DECISIONS-LOG.md       # ADRs
.specter/memory/CHANGES-PLANNED.md     # Upcoming work
.specter/memory/CHANGES-COMPLETED.md   # History
```

### Features (committed)

```
.specter/features/###-name/spec.md     # Specification
.specter/features/###-name/plan.md     # Technical plan
.specter/features/###-name/tasks.md    # Implementation tasks
```

### Scripts

```
.specter/scripts/config.sh             # Config utilities
.specter/scripts/format-output.sh      # Formatting utilities
.specter/scripts/routing.sh            # Routing utilities
```

### Documentation

```
.specter/docs/CLAUDE-FLOW.md           # Complete guide
.specter/docs/ARCHITECTURE.md          # System design
.specter/docs/COMMANDS.md              # This file
```

---

## Common Workflows

### New Feature

```bash
/specter specify "Feature description"
/specter plan
/specter tasks
/specter implement
/specter validate
```

### Resume Work

```bash
/specter status                    # Check where you are
/specter implement --resume        # Continue
```

### Check Progress

```bash
/specter                          # Interactive menu
/specter status                   # Detailed status
```

### Reconfigure

```bash
/specter init                     # Reconfigure interactively

# Or update config directly
source .specter/scripts/config.sh
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
alias f='specter'
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
SPECTER_PHASE=$(detect_current_phase 2>/dev/null || echo "none")
```

### Batch Operations

```bash
# Multiple features
/specter specify "Feature 1" && /specter specify "Feature 2"

# Full workflow
/specter specify "Quick feature" && /specter plan && /specter tasks
```

---

## Error Messages

### "Config file not found"

```bash
# Solution: Initialize Specter
/specter init
```

### "Invalid JIRA key format"

```bash
# JIRA keys must be: PROJECT or PROJECT-123
set_flow_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection failed"

```bash
# Check feature directory
ls -la .specter/features/###-feature-name/
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
