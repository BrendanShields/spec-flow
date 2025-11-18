---
name: spec:orchestrate
description: Use when running complete workflow end-to-end, user says "do everything/full workflow/automate workflow/complete pipeline", starting fresh feature with all phases, need guided execution from spec to implementation - executes generate→plan→tasks→implement automatically with checkpointing
allowed-tools: Read, Write, Edit, AskUserQuestion
---

# Spec Orchestrate

Execute complete specification-driven workflow automatically from requirements to implementation.

## What This Skill Does

- Runs full workflow: generate → plan → tasks → implement
- Intelligently determines which phases to run
- Prompts at decision points (clarify, analyze)
- Creates checkpoints between phases
- Validates prerequisites before phase transitions
- Resumes from interruptions
- Tracks progress and provides real-time status

## When to Use

1. Starting new feature and want end-to-end execution
2. User says "automate the workflow" or "do everything"
3. Need guided workflow with automatic phase transitions
4. Want checkpointing for recovery from failures
5. Resuming interrupted workflow from saved state
6. Running complete pipeline with validation

## Execution Flow

### Phase 1: Assessment

Determine workflow starting point:

1. Check initialization state
   - If `{config.paths.spec_root}/` missing → Run initialize phase first
   - If `{config.paths.state}/` missing → Initialize state
2. Detect current workflow position
   - Read current-session.md for active feature/phase
   - Check for resume checkpoint
3. Identify workflow type
   - New project: Need blueprint phase
   - New feature: Start at generate phase
   - Resume: Continue from saved phase

### Phase 2: Orchestration

Execute workflow phases in sequence:

**2.1 Generate Specification**
- Run generate phase to create spec.md
- Check for [CLARIFY] tags
- Save checkpoint: "post-generate"

**2.2 Clarify (Conditional)**
- If [CLARIFY] tags present → Run clarify phase
- If --skip-clarify flag → Skip
- If --auto mode → Auto-resolve simple clarifications
- Save checkpoint: "post-clarify"

**2.3 Plan Technical Design**
- Run plan phase to create plan.md
- Log architecture decisions to decisions-log.md
- Save checkpoint: "post-plan"

**2.4 Validate (Conditional)**
- If complex feature (>15 tasks estimated) → Run analyze phase
- If validation errors → Prompt for corrective action
- If --skip-analyze flag → Skip
- Save checkpoint: "post-analyze"

**2.5 Generate Tasks**
- Run tasks phase to create tasks.md
- Identify parallel work opportunities
- Save checkpoint: "post-tasks"

**2.6 Execute Implementation**
- Run implement phase
- Update changes-completed.md as tasks complete
- Final validation
- Save checkpoint: "complete"

### Phase 3: Completion

Provide execution summary:

```markdown
Workflow Complete

Duration: 14 minutes 32 seconds

Phases Executed:
- generate (spec.md created)
- clarify (2 ambiguities resolved)
- plan (plan.md created, 3 ADRs logged)
- tasks (23 tasks generated)
- implement (23/23 tasks complete)

Artifacts Created:
- {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
- {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}
- {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}

Files Modified: 15 files
Lines Added: +1,847
Lines Deleted: -92
Tests: 12/12 passing

Next Steps:
1. Review implementation
2. Create pull request
3. Update documentation
```

## Decision Logic

### Auto-Skip Rules

Skip phases automatically when:
- **clarify phase**: No [CLARIFY] tags found
- **analyze phase**: Simple feature (<10 tasks) or --skip-analyze
- **blueprint phase**: Not a greenfield project

### Required Phases

Always execute:
- **generate phase**: Creates specification
- **plan phase**: Creates technical design
- **tasks phase**: Breaks down implementation
- **implement phase**: Executes tasks

### Conditional Prompts

Prompt user when:
- Multiple clarification approaches possible
- Validation errors require choice
- Major architecture decision needed
- Risk of destructive operation

## Orchestration Modes

**Default Mode** (Interactive):
```
Prompts at decision points
Shows progress indicators
Validates between phases
Creates all checkpoints
```

**Auto Mode** (--auto):
```
Minimizes prompts
Uses sensible defaults
Skips optional validation
Faster execution
```

**Resume Mode** (--resume):
```
Loads last checkpoint
Continues from saved phase
Preserves context
Skips completed work
```

## Progress Tracking

Real-time status display:

```
Spec Orchestration Progress

Setup       [████████████] Complete (12s)
Generate    [████████████] Complete (45s)
Clarify     [████████░░░░] In Progress (18s)
Plan        [░░░░░░░░░░░░] Pending
Tasks       [░░░░░░░░░░░░] Pending
Implement   [░░░░░░░░░░░░] Pending

Current: Resolving clarifications (2/3)
Next: Create technical plan
ETA: ~8 minutes
```

## Error Handling

**Recoverable Errors**:
- Skill timeout → Retry with extended timeout
- Validation failure → Prompt for corrective action
- Missing prerequisite → Guide installation
- Clarification needed → Run clarify phase

**Non-Recoverable Errors**:
- Critical file corruption → Report error, exit cleanly
- User cancellation → Save checkpoint, exit gracefully
- System resource exhaustion → Save state, notify user

All errors save current state for resumption.

## Configuration

Set in project claude.md:

```markdown
SPEC_ORCHESTRATE_MODE=interactive|auto
SPEC_ORCHESTRATE_SKIP_ANALYZE=true|false
SPEC_ORCHESTRATE_CHECKPOINT_ALL=true|false
SPEC_ORCHESTRATE_VALIDATE_PHASES=true|false
```

## State Management

**Checkpoint Creation**:
- After each phase completion
- Before risky operations
- On user request
- On error/interruption

**Checkpoint Location**: `{config.paths.state}/checkpoints/orchestrate-{timestamp}.md`

**Resume Detection**: Automatically detects and offers to resume from last checkpoint

## Examples

See EXAMPLES.md for:
- Complete greenfield workflow
- Feature addition to existing project
- Resuming after interruption
- Auto mode execution
- Selective phase execution

## Reference

See REFERENCE.md for:
- Detailed orchestration algorithms
- Phase transition logic
- Checkpoint format specification
- Advanced configuration options
- Troubleshooting guide

## Related Skills

- **generate phase** - Create specification
- **clarify phase** - Resolve ambiguities
- **plan phase** - Generate technical plan
- **tasks phase** - Break into tasks
- **implement phase** - Execute implementation
- **analyze phase** - Validate consistency

## Shared Resources

For workflow patterns: `docs/patterns/workflow-patterns.md`
For state management: `docs/patterns/state-management.md`
