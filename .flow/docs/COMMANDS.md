# Flow Commands - Quick Reference

Fast lookup for all Flow commands with syntax and examples.

## Workflow Commands

### /flow

**Unified workflow command** - Interactive menu or direct routing.

**Syntax**:
```bash
/flow                    # Interactive menu (NEW: visual selection)
/flow <subcommand> [args]  # Direct execution
```

**Interactive Mode** (default, `preferences.interactive_mode: true`):
- Shows visual AskUserQuestion menu
- Click to select: Initialize, Specify, Plan, Tasks, Implement, Validate, Status, Help
- Phase-aware options (only shows relevant commands)
- Automatic skill invocation after selection

**Examples**:
```bash
# Interactive visual menu (NEW)
/flow
# Shows clickable options → user selects → automatically executes

# Direct execution (unchanged)
/flow init              # Initialize Flow
/flow specify "feature" # Create specification
/flow status            # Show progress

# Disable interactive mode
set_flow_config "preferences.interactive_mode" "false"
/flow  # Now shows text menu
```

**Note**: CLI arguments bypass interactive prompts (e.g., `/flow init --type=brownfield` skips prompts)

---

### /flow init

**Initialize Flow** in project with configuration.

**Syntax**:
```bash
/flow init [--type=TYPE] [--jira=KEY] [--confluence=ID]
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
/flow init
# Step 1: Select Greenfield/Brownfield, JIRA yes/no, Confluence yes/no
# Step 2: Enter keys only if integrations enabled

# Greenfield project
/flow init --type=greenfield

# Brownfield with JIRA
/flow init --type=brownfield --jira=PROJ

# Complete setup (skips all prompts)
/flow init --type=greenfield --jira=FLOW --confluence=123456
```

**Creates**:
- `.flow/` directory structure
- `.flow/config/flow.json`
- State and memory files

**Next**: `/flow specify`

---

### /flow specify

**Create feature specification** with user stories.

**Syntax**:
```bash
/flow specify "<feature description>"
```

**Examples**:
```bash
/flow specify "User authentication with OAuth"
/flow specify "Export data to CSV format"
```

**Creates**:
- `.flow/features/###-feature-name/spec.md`

**Contains**:
- P1/P2/P3 user stories
- Acceptance criteria
- Technical notes

**Next**: `/flow plan`

---

### /flow plan

**Create technical plan** from specification.

**Syntax**:
```bash
/flow plan
```

**Creates**:
- `.flow/features/###-feature-name/plan.md`

**Contains**:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts
- Implementation phases

**Next**: `/flow tasks`

---

### /flow tasks

**Break down into tasks** from technical plan.

**Syntax**:
```bash
/flow tasks
```

**Creates**:
- `.flow/features/###-feature-name/tasks.md`

**Contains**:
- Numbered tasks (T001, T002, ...)
- Dependencies
- Priorities (P1/P2/P3)
- Parallel markers [P]
- Acceptance criteria

**Next**: `/flow implement`

---

### /flow implement

**Execute implementation** autonomously.

**Syntax**:
```bash
/flow implement [--resume] [--filter=PRIORITY]
```

**Arguments**:
- `--resume` - Continue from last checkpoint
- `--filter=P1` - Implement specific priority only

**Examples**:
```bash
/flow implement              # Start implementation
/flow implement --resume     # Continue after interruption
/flow implement --filter=P1  # P1 tasks only
```

**Updates**:
- Task checkboxes in tasks.md
- `.flow/state/current-session.md`
- `.flow/memory/CHANGES-COMPLETED.md`

**Next**: `/flow validate`

---

### /flow validate

**Check workflow consistency** and completeness.

**Syntax**:
```bash
/flow validate
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

### /flow status

**Show current progress** and phase.

**Syntax**:
```bash
/flow status
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
Recommended next: /flow implement
```

---

### /flow help

**Context-aware help** for current phase.

**Syntax**:
```bash
/flow help
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
source .flow/scripts/config.sh

# Read values
project_type=$(get_flow_config "project.type")
jira_enabled=$(get_flow_config "integrations.jira.enabled")
jira_key=$(get_flow_config "integrations.jira.project_key")
```

### Update Configuration

```bash
source .flow/scripts/config.sh

# Update values
set_flow_config "integrations.jira.enabled" "true"
set_flow_config "integrations.jira.project_key" "NEWPROJ"

# Validate
validate_flow_config
```

### Validate Inputs

```bash
source .flow/scripts/config.sh

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
source .flow/scripts/format-output.sh

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
source .flow/scripts/routing.sh

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
.flow/config/flow.json           # Main configuration
```

### State (git-ignored)

```
.flow/state/current-session.md   # Active session
.flow/state/checkpoints/          # Saved checkpoints
```

### Memory (committed)

```
.flow/memory/WORKFLOW-PROGRESS.md   # Metrics
.flow/memory/DECISIONS-LOG.md       # ADRs
.flow/memory/CHANGES-PLANNED.md     # Upcoming work
.flow/memory/CHANGES-COMPLETED.md   # History
```

### Features (committed)

```
.flow/features/###-name/spec.md     # Specification
.flow/features/###-name/plan.md     # Technical plan
.flow/features/###-name/tasks.md    # Implementation tasks
```

### Scripts

```
.flow/scripts/config.sh             # Config utilities
.flow/scripts/format-output.sh      # Formatting utilities
.flow/scripts/routing.sh            # Routing utilities
```

### Documentation

```
.flow/docs/CLAUDE-FLOW.md           # Complete guide
.flow/docs/ARCHITECTURE.md          # System design
.flow/docs/COMMANDS.md              # This file
```

---

## Common Workflows

### New Feature

```bash
/flow specify "Feature description"
/flow plan
/flow tasks
/flow implement
/flow validate
```

### Resume Work

```bash
/flow status                    # Check where you are
/flow implement --resume        # Continue
```

### Check Progress

```bash
/flow                          # Interactive menu
/flow status                   # Detailed status
```

### Reconfigure

```bash
/flow init                     # Reconfigure interactively

# Or update config directly
source .flow/scripts/config.sh
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
alias f='flow'
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
FLOW_PHASE=$(detect_current_phase 2>/dev/null || echo "none")
```

### Batch Operations

```bash
# Multiple features
/flow specify "Feature 1" && /flow specify "Feature 2"

# Full workflow
/flow specify "Quick feature" && /flow plan && /flow tasks
```

---

## Error Messages

### "Config file not found"

```bash
# Solution: Initialize Flow
/flow init
```

### "Invalid JIRA key format"

```bash
# JIRA keys must be: PROJECT or PROJECT-123
set_flow_config "integrations.jira.project_key" "VALIDKEY"
```

### "Phase detection failed"

```bash
# Check feature directory
ls -la .flow/features/###-feature-name/
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
