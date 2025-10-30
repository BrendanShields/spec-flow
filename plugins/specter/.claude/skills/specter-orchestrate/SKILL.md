---
name: specter:orchestrate
description: Execute complete Specter workflow end-to-end. Use when 1) Want full automated workflow from spec to implementation, 2) User says "do everything/complete workflow", 3) Starting fresh project with all steps, 4) Need guided workflow execution, 5) Resuming interrupted workflows. Orchestrates all Specter skills in proper sequence.
allowed-tools: Skill, Read, AskUserQuestion
---

# Flow Orchestrate

Execute the complete Specter workflow from initialization to implementation with intelligent orchestration.

## Core Capability

Orchestrates Specter skills in proper sequence:
- Assesses current project state
- Determines next steps automatically
- Executes skills with decision point handling
- Tracks progress with state persistence
- Resumes from interruptions

## Workflow Sequences

### Greenfield Project
```
specter:init → specter:blueprint → specter:specify → specter:clarify →
specter:plan → specter:analyze → specter:tasks → specter:implement
```

### Brownfield Project
```
specter:init → specter:specify → specter:clarify →
specter:plan → specter:tasks → specter:implement
```

### Feature Addition
```
specter:specify → specter:clarify → specter:plan → specter:tasks → specter:implement
```

### POC/Prototype
```
specter:init → specter:specify --skip-validation →
specter:plan --minimal → specter:tasks --simple →
specter:implement --skip-checklists
```

## Execution Phases

### 1. Project Assessment
- Check if Specter is initialized (`.specter/` exists)
- Determine project type (greenfield/brownfield/feature)
- Identify current workflow position
- Load saved state if workflow was interrupted

### 2. Setup
Execute if needed:
- `specter:init` - Create `.specter/` structure
- `specter:blueprint` - Define architecture (greenfield only)
- `specter:update` - Configure new MCP servers

### 3. Specification
Execute sequence:
- `specter:specify` - Generate specification
- `specter:clarify` - Resolve ambiguities (if detected)

### 4. Planning
Execute sequence:
- `specter:plan` - Create technical design
- `specter:analyze` - Validate consistency (if configured)

Handle analysis issues by re-running affected skills.

### 5. Task Generation
Execute:
- `specter:tasks` - Generate implementation tasks

### 6. Implementation
Execute sequence:
- `specter:checklist` - Quality gates (if configured)
- `specter:implement` - Execute implementation

## Decision Logic

### Auto-Skip Rules

| Step | Skip When |
|------|-----------|
| `specter:blueprint` | Brownfield project or POC mode |
| `specter:clarify` | No ambiguities detected in spec |
| `specter:analyze` | POC mode or simple features |
| `specter:checklist` | POC mode or not configured |

### Required Steps
- `specter:init` - Always run if `.specter/` doesn't exist
- `specter:specify` - Always run if no spec exists
- `specter:plan` - Always run if no plan exists
- `specter:tasks` - Always run if no tasks exist
- `specter:implement` - Always run for actual implementation

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

State saved to `.specter/.orchestration-state.json` for resumption.

## Interactive Mode

Enable confirmations before each skill:
```
📋 Next Step: specter:plan

Creates technical implementation plan
Estimated time: 2-3 minutes

Continue? [Y/n/skip]:
```

Configure in `CLAUDE.md`:
```
SPECTER_ORCHESTRATE_CONFIRMATION=true
SPECTER_ORCHESTRATE_AUTO_SKIP=true
```

## Error Handling

**Recoverable**: Retry or run corrective skill
- Skill timeout → Retry with longer timeout
- Ambiguities detected → Run `specter:clarify`
- Validation failures → Re-run affected skill

**Non-recoverable**: Save state and exit
- Missing prerequisites → Guide user to install
- Critical failures → Provide error details
- User cancellation → Clean exit with summary

## Resume Capability

Resume interrupted workflows:
```bash
specter:orchestrate --resume
```

Detects saved state and continues from last completed step.

## Completion Summary

Provides execution summary:
```markdown
✅ Flow Orchestration Complete

Duration: 11 minutes 25 seconds

Executed Steps (5):
- specter:init (10s)
- specter:specify (45s)
- specter:plan (120s)
- specter:tasks (30s)
- specter:implement (480s)

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

- **specter:init** - Initialize Specter structure
- **specter:specify** - Create specification
- **specter:plan** - Generate technical plan
- **specter:implement** - Execute implementation

## Validation

Test this skill:
```bash
scripts/validate.sh
```