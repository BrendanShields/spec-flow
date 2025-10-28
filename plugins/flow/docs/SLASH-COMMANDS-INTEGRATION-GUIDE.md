# Slash Commands & Memory Management Integration Guide

## Quick Start

### For Users

```bash
# Check where you are
/flow-status

# Get help
/flow-help

# Save your work
/flow-session save

# Resume later
/flow-resume
```

### For Developers

```bash
# Initialize tracking
mkdir -p .flow-state .flow-memory

# Start workflow
flow:init
/flow-session save --name="project-start"

# Work on features
flow:specify "Your feature"
/flow-validate
flow:implement

# Track progress
/flow-status
/flow-report --progress
```

## Integration Architecture

### How Commands Work With Skills

```mermaid
graph TD
    A[User Input] --> B{Slash Command?}
    B -->|Yes| C[/flow-command]
    B -->|No| D[flow:skill]

    C --> E[Read State Files]
    D --> F[Read State Files]

    E --> G[Execute Command Logic]
    F --> H[Execute Skill Logic]

    G --> I[Update State Files]
    H --> I[Update State Files]

    I --> J[Session State Updated]
    J --> K[Memory Files Updated]
```

### State Flow

1. **Commands read state** from `.flow-state/` and `.flow-memory/`
2. **Skills update progress** in tracking files
3. **Commands provide visibility** into current state
4. **Session management** preserves context between Claude sessions

## Command & Skill Interaction Examples

### Example 1: Starting a New Feature

```bash
# 1. Check current state
/flow-status
> No active workflow

# 2. Initialize if needed
flow:init --type=greenfield

# 3. Create specification
flow:specify "Add user authentication"
> Creates features/001-user-authentication/spec.md

# 4. Validate consistency
/flow-validate
> ✅ All checks passed

# 5. Save checkpoint
/flow-session save --name="spec-complete"

# 6. Continue with planning
flow:plan
```

### Example 2: Resuming After Interruption

```bash
# Claude session 1
flow:implement
> Complete tasks T001, T002
> Session ends unexpectedly

# Claude session 2 (next day)
/flow-resume
> Restored from checkpoint
> Continuing from T003

flow:implement --continue
> Picks up exactly where you left off
```

### Example 3: Handling Changes Mid-Flight

```bash
# Working on implementation
/flow-status
> Phase: Implementation (5/15 tasks)

# Requirements change
flow:update "Revised requirements"

# Check what changed
/flow-validate
> ⚠️ 3 tasks no longer align with spec

# Fix issues
/flow-validate --fix
> ✅ Tasks realigned

# Continue
flow:implement --continue
```

## Memory File Updates

### When Skills Update Memory

| Skill | Updates | Files Modified |
|-------|---------|----------------|
| flow:init | Project start | WORKFLOW-PROGRESS.md |
| flow:specify | Feature added | current-session.md, WORKFLOW-PROGRESS.md |
| flow:clarify | Decisions made | DECISIONS-LOG.md |
| flow:plan | Architecture decisions | DECISIONS-LOG.md |
| flow:tasks | Tasks created | CHANGES-PLANNED.md |
| flow:implement | Tasks completed | CHANGES-COMPLETED.md, WORKFLOW-PROGRESS.md |
| flow:update | Changes tracked | CHANGES-PLANNED.md |

### When Commands Read State

| Command | Reads From | Purpose |
|---------|------------|---------|
| /flow-status | All memory files | Show current state |
| /flow-resume | current-session.md | Restore context |
| /flow-validate | All artifact files | Check consistency |
| /flow-session | Checkpoint files | Manage saves |
| /flow-report | WORKFLOW-PROGRESS.md | Generate metrics |

## Configuration Integration

### In CLAUDE.md

```markdown
# Flow Configuration
FLOW_AUTO_CHECKPOINT=true        # Auto-save on phase completion
FLOW_SESSION_TIMEOUT=30           # Minutes before auto-save
FLOW_MAX_CHECKPOINTS=10           # Keep last 10 checkpoints
FLOW_VALIDATE_ON_SAVE=true        # Run validation before checkpoint
FLOW_TRACK_DECISIONS=true         # Log all decisions
FLOW_TRACK_METRICS=true           # Collect productivity metrics
```

### Skills Reading Configuration

```bash
# Skills check configuration
flow:implement
> Reading FLOW_AUTO_VALIDATE from CLAUDE.md
> Auto-validation enabled

# Commands respect settings
/flow-session save
> FLOW_VALIDATE_ON_SAVE=true
> Running validation first...
> ✅ Validation passed
> Checkpoint created
```

## Best Practices

### Session Management

1. **Start each session with status check**
   ```bash
   /flow-status
   ```

2. **Save before stopping work**
   ```bash
   /flow-session save --name="descriptive-name"
   ```

3. **Resume with validation**
   ```bash
   /flow-resume --validate
   ```

### Progress Tracking

1. **Update planned changes regularly**
   ```bash
   # After planning session
   Update CHANGES-PLANNED.md with new items
   ```

2. **Log decisions as they're made**
   ```bash
   # During flow:clarify or flow:plan
   Automatically logged to DECISIONS-LOG.md
   ```

3. **Review progress weekly**
   ```bash
   /flow-report --type=progress --period=week
   ```

### Error Recovery

1. **If state seems wrong**
   ```bash
   /flow-validate --fix
   /flow-status
   ```

2. **If session corrupted**
   ```bash
   /flow-session list
   /flow-session restore --checkpoint=last-good
   ```

3. **If completely lost**
   ```bash
   /flow-debug
   # Follow recovery suggestions
   ```

## Workflow Patterns

### Pattern 1: Daily Workflow

```bash
# Morning
/flow-resume                    # Continue from yesterday
/flow-status                    # See what's pending
flow:implement --continue        # Work on tasks

# Before lunch
/flow-session save --name="morning-progress"

# After lunch
/flow-status                    # Quick check
flow:implement --continue        # Continue work

# End of day
/flow-session save --name="eod"
/flow-report --type=progress    # Review accomplishments
```

### Pattern 2: Feature Development

```bash
# Start feature
flow:specify "New feature"
/flow-validate
/flow-session save --name="spec"

# Planning
flow:clarify
flow:plan
/flow-validate
/flow-session save --name="plan"

# Implementation
flow:tasks
flow:implement
/flow-session save --name="checkpoint" # Periodically

# Completion
flow:checklist
/flow-report --type=feature
```

### Pattern 3: Team Handoff

```bash
# Developer A finishing
/flow-session save --name="handoff-to-b"
/flow-report --type=progress > handoff.md
# Share checkpoint name with Developer B

# Developer B starting
/flow-session restore --checkpoint=handoff-to-b
/flow-status
/flow-resume
```

## Troubleshooting

### Common Issues

#### Issue: "No session found"
```bash
Solution:
/flow-status              # Check if any work exists
flow:init                  # If new project
/flow-session list         # Check for checkpoints
```

#### Issue: "State out of sync"
```bash
Solution:
/flow-validate --fix       # Auto-fix formatting
/flow-debug               # Diagnose deeper issues
```

#### Issue: "Can't resume"
```bash
Solution:
/flow-session list        # Find available checkpoints
/flow-session restore --checkpoint=NAME
/flow-validate           # Check consistency
```

## Advanced Usage

### Custom Workflows

```bash
# Create custom workflow
Create .claude/commands/my-workflow.md

# Use in combination
/my-workflow
flow:implement
/flow-status
```

### Automation Hooks

```bash
# In hooks.json
{
  "PostToolUse": {
    "pattern": "flow:*",
    "action": "/flow-session save --auto"
  }
}
```

### Metrics Collection

```bash
# Generate comprehensive metrics
/flow-report --type=metrics --format=json > metrics.json

# Analyze trends
/flow-report --type=velocity --period=month

# Track decisions
/flow-report --type=decisions --format=markdown
```

## Performance Considerations

### Memory Management

- Checkpoints: ~5-10 KB each
- Memory files: ~50 KB total typical
- Auto-cleanup after 30 days
- Compression for archives

### Command Performance

| Command | Typical Time | Max Time |
|---------|-------------|----------|
| /flow-status | <100ms | 500ms |
| /flow-resume | <200ms | 1s |
| /flow-validate | <500ms | 2s |
| /flow-session save | <100ms | 500ms |
| /flow-report | <1s | 5s |

## Testing Integration

### Test Workflow

```bash
# 1. Initialize test project
flow:init --type=test
/flow-session save --name="test-start"

# 2. Create test feature
flow:specify "Test feature"
/flow-validate
assert: No errors

# 3. Test resume
# Simulate session end
/flow-resume
assert: Correct state restored

# 4. Test validation
# Introduce error
/flow-validate
assert: Error detected

# 5. Clean up
/flow-session clean --all
```

## Migration Guide

### From Existing Project

```bash
# 1. Add to existing project
mkdir -p .flow-state .flow-memory

# 2. Initialize state
/flow-status  # Creates initial state

# 3. Import existing decisions
# Manually add to DECISIONS-LOG.md

# 4. Start using commands
/flow-help
```

### Version Upgrades

```bash
# Check version compatibility
/flow-status --version

# Migrate if needed
/flow-migrate --from=v1 --to=v2

# Validate migration
/flow-validate --strict
```

## Summary

The slash commands and memory management system provides:

1. **Persistent Context** - Never lose work between sessions
2. **Workflow Visibility** - Always know current state
3. **Smart Recovery** - Resume exactly where you left off
4. **Progress Tracking** - Quantify accomplishments
5. **Decision History** - Track architectural choices
6. **Change Management** - Plan and track modifications

Together with the flow skills, this creates a complete specification-driven development environment that maintains context across any number of Claude Code sessions.

---

## Quick Command Reference

```bash
# Essential Commands
/flow-status              # Where am I?
/flow-help               # What can I do?
/flow-session save       # Save my work
/flow-resume             # Continue work
/flow-validate           # Check consistency

# Skills (work with commands)
flow:init                # Start project
flow:specify             # Create spec
flow:plan                # Design solution
flow:tasks               # Break down work
flow:implement           # Build it

# Reporting
/flow-report --progress  # What's done?
/flow-report --velocity  # How fast?
/flow-report --decisions # What was decided?
```