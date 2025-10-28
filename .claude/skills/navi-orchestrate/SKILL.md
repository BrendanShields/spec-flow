---
name: flow:orchestrate
description: Execute complete Flow workflow end-to-end. Use when 1) Want full automated workflow from spec to implementation, 2) User says "do everything/complete workflow", 3) Starting fresh project with all steps, 4) Need guided workflow execution, 5) Resuming interrupted workflows. Orchestrates all Flow skills in proper sequence.
allowed-tools: Skill, Read, AskUserQuestion
---

# Flow Orchestrate

Execute the complete Flow workflow from initialization to implementation with intelligent orchestration.

## Core Capability

Orchestrates Flow skills in proper sequence:
- Assesses current project state
- Determines next steps automatically
- Executes skills with decision point handling
- Tracks progress with state persistence
- Resumes from interruptions

## Workflow Sequences

### Greenfield Project
```
flow:init → flow:blueprint → flow:specify → flow:clarify →
flow:plan → flow:analyze → flow:tasks → flow:implement
```

### Brownfield Project
```
flow:init → flow:specify → flow:clarify →
flow:plan → flow:tasks → flow:implement
```

### Feature Addition
```
flow:specify → flow:clarify → flow:plan → flow:tasks → flow:implement
```

### POC/Prototype
```
flow:init → flow:specify --skip-validation →
flow:plan --minimal → flow:tasks --simple →
flow:implement --skip-checklists
```

## Execution Phases

### 1. Project Assessment
- Check if Flow is initialized (`__specification__/` exists)
- Determine project type (greenfield/brownfield/feature)
- Identify current workflow position
- Load saved state if workflow was interrupted

### 2. Setup
Execute if needed:
- `flow:init` - Create `__specification__/` structure
- `flow:blueprint` - Define architecture (greenfield only)
- `flow:update` - Configure new MCP servers

### 3. Specification
Execute sequence:
- `flow:specify` - Generate specification
- `flow:clarify` - Resolve ambiguities (if detected)

### 4. Planning
Execute sequence:
- `flow:plan` - Create technical design
- `flow:analyze` - Validate consistency (if configured)

Handle analysis issues by re-running affected skills.

### 5. Task Generation
Execute:
- `flow:tasks` - Generate implementation tasks

### 6. Implementation
Execute sequence:
- `flow:checklist` - Quality gates (if configured)
- `flow:implement` - Execute implementation

## Decision Logic

### Auto-Skip Rules

| Step | Skip When |
|------|-----------|
| `flow:blueprint` | Brownfield project or POC mode |
| `flow:clarify` | No ambiguities detected in spec |
| `flow:analyze` | POC mode or simple features |
| `flow:checklist` | POC mode or not configured |

### Required Steps
- `flow:init` - Always run if `__specification__/` doesn't exist
- `flow:specify` - Always run if no spec exists
- `flow:plan` - Always run if no plan exists
- `flow:tasks` - Always run if no tasks exist
- `flow:implement` - Always run for actual implementation

## Progress Tracking

Real-time progress display:
```
🎭 Flow Orchestration Progress

Setup      ████████████ Complete (15s)
Specify    ████████░░░░ In Progress (23s)
Clarify    ░░░░░░░░░░░░ Pending
Plan       ░░░░░░░░░░░░ Pending
Tasks      ░░░░░░░░░░░░ Pending
Implement  ░░░░░░░░░░░░ Pending

Current: Generating specification...
Next: Clarify ambiguities
ETA: ~12 minutes
```

State saved to `__specification__/.orchestration-state.json` for resumption.

## Interactive Mode

Enable confirmations before each skill:
```
📋 Next Step: flow:plan

Creates technical implementation plan
Estimated time: 2-3 minutes

Continue? [Y/n/skip]:
```

Configure in `CLAUDE.md`:
```
FLOW_ORCHESTRATE_CONFIRMATION=true
FLOW_ORCHESTRATE_AUTO_SKIP=true
```

## Error Handling

**Recoverable**: Retry or run corrective skill
- Skill timeout → Retry with longer timeout
- Ambiguities detected → Run `flow:clarify`
- Validation failures → Re-run affected skill

**Non-recoverable**: Save state and exit
- Missing prerequisites → Guide user to install
- Critical failures → Provide error details
- User cancellation → Clean exit with summary

## Resume Capability

Resume interrupted workflows:
```bash
flow:orchestrate --resume
```

Detects saved state and continues from last completed step.

## Completion Summary

Provides execution summary:
```markdown
✅ Flow Orchestration Complete

Duration: 11 minutes 25 seconds

Executed Steps (5):
- flow:init (10s)
- flow:specify (45s)
- flow:plan (120s)
- flow:tasks (30s)
- flow:implement (480s)

Created Artifacts:
- features/001-user-auth/spec.md
- features/001-user-auth/plan.md
- features/001-user-auth/tasks.md

Implementation Results:
- Files: 12 created
- Tests: 8/8 passing
- Tasks: 24/24 completed
```

## Examples

See [examples.md](./examples.md) for:
- Complete greenfield project setup
- Adding feature to existing project
- Quick POC mode workflow
- Resuming interrupted workflow
- Selective orchestration (partial workflow)

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Detailed orchestration algorithms
- Configuration options
- Error handling strategies
- State persistence format
- Custom workflow sequences
- Troubleshooting guide

## Related Skills

- **flow:init** - Initialize Flow structure
- **flow:specify** - Create specification
- **flow:plan** - Generate technical plan
- **flow:implement** - Execute implementation

## Validation

Test this skill:
```bash
scripts/validate.sh
```