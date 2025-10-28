# Navi Commands - Quick Reference

Fast lookup for all Navi commands with syntax and examples.

## Worknavi Commands

### /navi

**Unified worknavi command** - Interactive menu or direct routing.

**Syntax**:
```bash
/navi                    # Interactive menu (NEW: visual selection)
/navi <subcommand> [args]  # Direct execution
```

**Interactive Mode** (default, `preferences.interactive_mode: true`):
- Shows visual AskUserQuestion menu
- Click to select: Initialize, Specify, Plan, Tasks, Implement, Validate, Status, Help
- Phase-aware options (only shows relevant commands)
- Automatic skill invocation after selection

**Examples**:
```bash
# Interactive visual menu (NEW)
/navi
# Shows clickable options → user selects → automatically executes

# Direct execution (unchanged)
/navi init              # Initialize Navi
/navi specify "feature" # Create specification
/navi status            # Show progress

# Disable interactive mode
set_navi_config "preferences.interactive_mode" "false"
/navi  # Now shows text menu
```

**Note**: CLI arguments bypass interactive prompts (e.g., `/navi init --type=brownfield` skips prompts)

---

### /navi init

**Initialize Navi** in project with configuration.

**Syntax**:
```bash
/navi init [--type=TYPE] [--jira=KEY] [--confluence=ID]
```

**Arguments**:
- `--type=greenfield|brownfield` - Project type
- `--jira=PROJECT-KEY` - Enable JIRA with key
- `--confluence=PAGE-ID` - Enable Confluence with page ID

**Interactive Prompts** (NEW: Two-step approach):
1. **Step 1**: Project type, JIRA integration (yes/no), Confluence integration (yes/no)
2. **Step 2**: JIRA key and/or Confluence page ID (only if enabled in step 1)

**Examples**:
```bash
# Interactive mode (NEW: visual prompts)
/navi init
# Step 1: Select Greenfield/Brownfield, JIRA yes/no, Confluence yes/no
# Step 2: Enter keys only if integrations enabled

# Greenfield project
/navi init --type=greenfield

# Brownfield with JIRA
/navi init --type=brownfield --jira=PROJ

# Complete setup (skips all prompts)
/navi init --type=greenfield --jira=FLOW --confluence=123456
```

**Creates**:
- `.navi/` directory structure
- `.navi/config/navi.json`
- State and memory files

**Next**: `/navi specify`

---

### /navi specify

**Create feature specification** with user stories.

**Syntax**:
```bash
/navi specify "<feature description>"
```

**Examples**:
```bash
/navi specify "User authentication with OAuth"
/navi specify "Export data to CSV format"
```

**Creates**:
- `.navi/features/###-feature-name/spec.md`

**Contains**:
- P1/P2/P3 user stories
- Acceptance criteria
- Technical notes

**Next**: `/navi plan`

---

### /navi plan

**Create technical plan** from specification.

**Syntax**:
```bash
/navi plan
```

**Creates**:
- `.navi/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/navi tasks`

---

### /navi tasks

**Break down into tasks** from technical plan.

**Syntax**:
```bash
/navi tasks
```

**Creates**:
- `.navi/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, ...)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel markers [P]
- Acceptance criteria

**Next**: `/navi implement`

---

### /navi implement

**Execute implementation** autonomously.

**Syntax**:
```bash
/navi implement [--resume] [--filter=PRIORITY]
```

**Arguments**:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**Examples**:
```bash
/navi implement              # Start implementation
/navi implement --resume     # Continue after interruption
/navi implement --filter=P1  # P1 tasks only
```

**Updates**:
- Task checkboxes in tasks.md
- `.navi/state/current-session.md`
- `.navi/memory/CHANGES-COMPLETED.md`

**Next**: `/navi validate`

---

### /navi validate

**Check worknavi consistency** and completeness.

**Syntax**:
```bash
/navi validate
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

### /navi status

**Show current progress** and phase.

**Syntax**:
```bash
/navi status
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
Recommended next: /navi implement
```

---

### /navi help

**Context-aware help** for current phase.

**Syntax**:
```bash
/navi help
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
source .navi/scripts/config.sh

# Read values
project_type=$(get_navi_config "project.type")
jira_enabled=$(get_navi_config "integrations.jira.enabled")
jira_key=$(get_navi_config "integrations.jira.project_key")
```

### Update Configuration

```bash
source .navi/scripts/config.sh

# Update values
set_navi_config "integrations.jira.enabled" "true"
set_navi_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_navi_config
```

### Validate Inputs

```bash
source .navi/scripts/config.sh

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
source .navi/scripts/format-output.sh

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
source .navi/scripts/routing.sh

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
.navi/config/navi.json           # Main configuration
```

### State (git-ignored)

```
.navi/state/current-session.md   # Active session
.navi/state/checkpoints/          # Saved checkpoints
```

### Memory (committed)

```
.navi/memory/WORKFLOW-PROGRESS.md   # Metrics
.navi/memory/DECISIONS-LOG.md       # ADRs
.navi/memory/CHANGES-PLANNED.md     # Upcoming work
.navi/memory/CHANGES-COMPLETED.md   # History
```

### Features (committed)

```
.navi/features/###-name/spec.md     # Specification
.navi/features/###-name/plan.md     # Technical plan
.navi/features/###-name/tasks.md    # Implementation tasks
```

### Scripts

```
.navi/scripts/config.sh             # Config utilities
.navi/scripts/format-output.sh      # Formatting utilities
.navi/scripts/routing.sh            # Routing utilities
```

### Documentation

```
.navi/docs/CLAUDE-FLOW.md           # Complete guide
.navi/docs/ARCHITECTURE.md          # System design
.navi/docs/COMMANDS.md              # This file
```

---

## Common Worknavis

### New Feature

```bash
/navi specify "Feature description"
/navi plan
/navi tasks
/navi implement
/navi validate
```

### Resume Work

```bash
/navi status                    # Check where you are
/navi implement --resume        # Continue
```

### Check Progress

```bash
/navi                          # Interactive menu
/navi status                   # Detailed status
```

### Reconfigure

```bash
/navi init                     # Reconfigure interactively

# Or update config directly
source .navi/scripts/config.sh
set_navi_config "integrations.jira.project_key" "NEWPROJ"
```

---

## Keyboard Shortcuts

None currently - all commands are text-based.

Future: Add keyboard shortcuts for common operations.

---

## Tips & Tricks

### Fast Navigation

```bash
alias f='navi'
f status
f specify "Quick feature"
```

### Auto-complete

If using zsh/bash completion:
```bash
# Add to .zshrc or .bashrc
complete -W "init specify plan tasks implement validate status help" navi
```

### Quick Status

```bash
# Add to shell prompt
NAVI_PHASE=$(detect_current_phase 2>/dev/null || echo "none")
```

### Batch Operations

```bash
# Multiple features
/navi specify "Feature 1" && /navi specify "Feature 2"

# Full worknavi
/navi specify "Quick feature" && /navi plan && /navi tasks
```

---

## Error Messages

### "Config file not found"

```bash
# Solution: Initialize Navi
/navi init
```

### "Invalid JIRA key format"

```bash
# JIRA keys must be: PROJECT or PROJECT-123
set_navi_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection failed"

```bash
# Check feature directory
ls -la .navi/features/###-feature-name/
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
