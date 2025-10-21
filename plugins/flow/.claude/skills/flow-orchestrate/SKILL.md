---
name: flow:orchestrate
description: Execute complete Flow workflow end-to-end. Use when: 1) Want full automated workflow from spec to implementation, 2) User says "do everything" or "complete workflow", 3) Starting fresh project with all steps, 4) Need guided workflow execution. Orchestrates all Flow skills in proper sequence.
allowed-tools: Skill, Read, AskUserQuestion
---

# Flow Orchestrate: Complete Workflow Automation

Execute the entire Flow workflow from initialization to implementation with intelligent orchestration.

## What This Skill Does

Orchestrates the complete Flow workflow by:
1. Checking current project state
2. Determining next steps
3. Executing skills in proper sequence
4. Handling decision points
5. Tracking progress throughout

## Workflow Sequences

### Greenfield Project (New)
```
flow:init → flow:blueprint → flow:specify → flow:clarify → flow:plan → flow:analyze → flow:tasks → flow:implement
```

### Brownfield Project (Existing)
```
flow:init → flow:specify → flow:clarify → flow:plan → flow:tasks → flow:implement
```

### Feature Addition
```
flow:specify → flow:clarify → flow:plan → flow:tasks → flow:implement
```

## Execution Flow

### Phase 1: Project Assessment
- Check if Flow is initialized
- Determine project type (greenfield/brownfield)
- Identify current workflow position
- Load existing state if any

### Phase 2: Setup (if needed)
```javascript
if (!hasFlowDirectory()) {
  await executeSkill('flow:init');
}

if (isGreenfield() && !hasBlueprint()) {
  await executeSkill('flow:blueprint');
}
```

### Phase 3: Specification
```javascript
// Check for existing spec
if (!hasSpecification()) {
  const description = await promptUser('Describe your project/feature');
  await executeSkill('flow:specify', description);
}

// Check for ambiguities
if (hasAmbiguities()) {
  await executeSkill('flow:clarify');
}
```

### Phase 4: Planning
```javascript
// Generate technical plan
if (!hasPlan()) {
  await executeSkill('flow:plan');
}

// Validate consistency
if (shouldAnalyze()) {
  const results = await executeSkill('flow:analyze');
  if (results.hasIssues) {
    await handleIssues(results);
  }
}
```

### Phase 5: Task Generation
```javascript
if (!hasTasks()) {
  await executeSkill('flow:tasks');
}
```

### Phase 6: Implementation
```javascript
// Check for quality gates
if (requiresChecklists()) {
  await executeSkill('flow:checklist');
}

// Execute implementation
await executeSkill('flow:implement');
```

## Decision Points

### When to Skip Steps
- **Skip blueprint**: Brownfield projects with existing architecture
- **Skip clarify**: No ambiguities detected in spec
- **Skip analyze**: Simple features, low risk
- **Skip checklist**: POC/prototype work

### When to Add Steps
- **Add analyze**: Multi-person teams, complex features
- **Add checklist**: Compliance requirements, quality gates
- **Add update**: New MCP servers detected

## Progress Tracking

The orchestrator provides real-time progress updates:

```
🎭 Flow Orchestration Progress

Setup      ████████████ Complete
Specify    ████████░░░░ In Progress
Plan       ░░░░░░░░░░░░ Pending
Tasks      ░░░░░░░░░░░░ Pending
Implement  ░░░░░░░░░░░░ Pending

Current: Generating specification...
Next: Technical planning
ETA: ~15 minutes
```

## Configuration

Orchestration behavior can be configured:

```javascript
{
  "orchestration": {
    "autoSkip": true,        // Skip unnecessary steps
    "requireConfirmation": false, // Confirm before each skill
    "parallel": false,       // Run independent skills in parallel
    "stopOnError": true,     // Halt on skill failure
    "maxDuration": 3600000   // 1 hour timeout
  }
}
```

## Error Handling

### Recoverable Errors
- Skill temporarily unavailable → Retry
- Ambiguities found → Run clarify
- Validation failures → Fix and continue

### Non-recoverable Errors
- Missing prerequisites → Guide user
- Critical failures → Save state and exit
- User cancellation → Clean exit

## Interactive Mode

When `requireConfirmation` is enabled:

```
📋 Next Step: flow:plan

This will create a technical implementation plan.
Estimated time: 2-3 minutes

Continue? [Y/n/skip]:
```

## Completion Summary

Upon completion, provides full summary:

```markdown
✅ Flow Orchestration Complete

## Executed Steps
- [x] flow:init (10s)
- [x] flow:specify (45s)
- [x] flow:plan (120s)
- [x] flow:tasks (30s)
- [x] flow:implement (480s)

## Created Artifacts
- features/001-user-auth/spec.md
- features/001-user-auth/plan.md
- features/001-user-auth/tasks.md

## Implementation Results
- Files created: 12
- Tests passing: 8/8
- Tasks completed: 24/24

Total duration: 11 minutes 25 seconds
```