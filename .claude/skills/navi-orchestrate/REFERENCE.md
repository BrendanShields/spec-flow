# Flow Orchestrate Reference

## Workflow Sequences

### Complete Sequences by Project Type

**Greenfield (New Project)**:
```
flow:init → flow:blueprint → flow:specify → flow:clarify →
flow:plan → flow:analyze → flow:tasks → flow:implement
```

**Brownfield (Existing Codebase)**:
```
flow:init → flow:specify → flow:clarify →
flow:plan → flow:tasks → flow:implement
```

**Feature Addition**:
```
flow:specify → flow:clarify → flow:plan → flow:tasks → flow:implement
```

**POC/Prototype**:
```
flow:specify --skip-validation → flow:plan --minimal →
flow:tasks --simple → flow:implement --skip-checklists
```

## Orchestration Algorithm

### Phase 1: Project Assessment

```javascript
function assessProject() {
  const hasFlow = checkDirectory('.flow/');
  const projectType = hasFlow ? detectType() : null;
  const currentPhase = detectCurrentPhase();

  return {
    initialized: hasFlow,
    type: projectType,  // greenfield | brownfield | feature
    phase: currentPhase, // init | spec | plan | tasks | implement
    canResume: currentPhase !== null
  };
}
```

### Phase 2: Setup

```javascript
async function setup(assessment) {
  if (!assessment.initialized) {
    await executeSkill('flow:init');
  }

  if (isGreenfield() && !hasBlueprint()) {
    const response = await askUser('Create architecture blueprint?');
    if (response === 'yes') {
      await executeSkill('flow:blueprint');
    }
  }

  // Check for new MCP servers
  const newServers = await detectNewMCPServers();
  if (newServers.length > 0) {
    await executeSkill('flow:update');
  }
}
```

### Phase 3: Specification

```javascript
async function specify() {
  // Create or load spec
  if (!hasSpecification()) {
    const description = await promptUser({
      question: 'Describe your project or feature',
      examples: ['User authentication', 'API for products']
    });
    await executeSkill('flow:specify', description);
  }

  // Check for ambiguities
  const spec = loadSpecification();
  if (hasAmbiguities(spec)) {
    const shouldClarify = await askUser('Clarify ambiguities?');
    if (shouldClarify) {
      await executeSkill('flow:clarify');
    }
  }
}
```

### Phase 4: Planning

```javascript
async function plan() {
  // Generate technical plan
  if (!hasPlan()) {
    await executeSkill('flow:plan');
  }

  // Validate consistency (optional)
  const config = loadConfig();
  if (config.FLOW_REQUIRE_ANALYSIS === 'true') {
    const results = await executeSkill('flow:analyze');

    if (results.hasIssues) {
      await handleAnalysisIssues(results);
    }
  }
}

async function handleAnalysisIssues(results) {
  console.log('⚠️  Analysis found issues:');
  results.issues.forEach(issue => {
    console.log(`  - ${issue.type}: ${issue.description}`);
  });

  const action = await askUser('Fix now or continue?', {
    options: ['fix', 'continue', 'abort']
  });

  if (action === 'fix') {
    // Re-run appropriate skill
    if (results.issues.some(i => i.source === 'spec')) {
      await executeSkill('flow:specify', '--update');
    }
    if (results.issues.some(i => i.source === 'plan')) {
      await executeSkill('flow:plan', '--update');
    }

    // Re-analyze
    await executeSkill('flow:analyze');
  } else if (action === 'abort') {
    throw new Error('Orchestration aborted by user');
  }
}
```

### Phase 5: Task Generation

```javascript
async function generateTasks() {
  if (!hasTasks()) {
    await executeSkill('flow:tasks');
  }
}
```

### Phase 6: Implementation

```javascript
async function implement() {
  // Check for quality gates
  const config = loadConfig();
  if (config.FLOW_REQUIRE_CHECKLISTS === 'true') {
    const checklistTypes = determineChecklistTypes();
    await executeSkill('flow:checklist', `--type ${checklistTypes.join(',')}`);
  }

  // Execute implementation
  await executeSkill('flow:implement');
}

function determineChecklistTypes() {
  const types = [];
  const spec = loadSpecification();

  if (spec.requiresSecurity) types.push('security');
  if (spec.requiresCompliance) types.push('compliance');
  if (spec.hasUI) types.push('ux');

  return types;
}
```

## Configuration Options

### Orchestration Settings

```javascript
{
  "orchestration": {
    "autoSkip": true,              // Automatically skip unnecessary steps
    "requireConfirmation": false,  // Confirm before each skill execution
    "parallel": false,             // Run independent skills in parallel (experimental)
    "stopOnError": true,           // Halt workflow on skill failure
    "maxDuration": 3600000,        // Maximum workflow duration (ms)
    "saveState": true,             // Save progress for resumption
    "verboseLogging": false        // Detailed execution logs
  }
}
```

**Configuration Effects**:

| Setting | `true` | `false` |
|---------|--------|---------|
| `autoSkip` | Skips unnecessary steps based on context | Runs all steps in sequence |
| `requireConfirmation` | Prompts before each skill | Runs continuously |
| `parallel` | Runs independent skills concurrently | Sequential execution |
| `stopOnError` | Halts on first error | Continues after errors |
| `saveState` | Can resume interrupted workflows | Fresh start only |
| `verboseLogging` | Detailed logs for debugging | Minimal output |

### Step Skip Logic

```javascript
function shouldSkipStep(step, context) {
  const skipRules = {
    'flow:blueprint': () => {
      return context.type === 'brownfield' ||
             context.mode === 'poc';
    },

    'flow:clarify': () => {
      const spec = loadSpecification();
      return !hasAmbiguities(spec);
    },

    'flow:analyze': () => {
      return context.mode === 'poc' ||
             (context.type === 'feature' && isSimple());
    },

    'flow:checklist': () => {
      return context.mode === 'poc' ||
             config.FLOW_REQUIRE_CHECKLISTS !== 'true';
    }
  };

  const rule = skipRules[step];
  return rule ? rule() : false;
}
```

## Error Handling

### Error Types and Recovery

**Recoverable Errors**:

| Error | Recovery Strategy |
|-------|------------------|
| Skill timeout | Retry with increased timeout |
| Ambiguities found | Execute `flow:clarify` |
| Validation failures | Re-run failed skill with fixes |
| Missing dependencies | Prompt user to install |

```javascript
async function handleRecoverableError(error, skill) {
  switch (error.type) {
    case 'TIMEOUT':
      console.log(`⏱️  ${skill} timed out. Retrying...`);
      return await executeSkill(skill, { timeout: error.timeout * 2 });

    case 'AMBIGUITY':
      console.log('🤔 Ambiguities detected. Running clarification...');
      await executeSkill('flow:clarify');
      return await executeSkill(skill); // Retry original skill

    case 'VALIDATION':
      console.log(`❌ Validation failed: ${error.message}`);
      const fix = await askUser('How would you like to fix this?');
      // Apply fix and retry
      return await executeSkill(skill);
  }
}
```

**Non-recoverable Errors**:

| Error | Action |
|-------|--------|
| Missing prerequisites | Guide user to setup, save state, exit |
| Critical skill failure | Log error, save state, exit |
| User cancellation | Clean exit with summary |
| Circular dependency | Report issue, exit |

```javascript
async function handleNonRecoverableError(error, state) {
  console.error(`🚨 Critical error: ${error.message}`);

  // Save current state
  await saveState(state);
  console.log('💾 Progress saved. Resume with "flow:orchestrate --resume"');

  // Provide guidance
  if (error.type === 'MISSING_PREREQ') {
    console.log('📋 Prerequisites needed:');
    error.prerequisites.forEach(prereq => {
      console.log(`  - ${prereq.name}: ${prereq.install}`);
    });
  }

  throw error; // Exit orchestration
}
```

## Progress Tracking

### Progress Display Format

```
🎭 Flow Orchestration Progress

Setup      ████████████ Complete (15s)
Specify    ████████░░░░ In Progress (23s elapsed)
Clarify    ░░░░░░░░░░░░ Pending
Plan       ░░░░░░░░░░░░ Pending
Tasks      ░░░░░░░░░░░░ Pending
Implement  ░░░░░░░░░░░░ Pending

Current: Generating specification...
Next: Clarify ambiguities
ETA: ~12 minutes remaining
```

### State Persistence

```javascript
// State saved to .flow/.orchestration-state.json
{
  "sessionId": "uuid-1234",
  "startTime": "2024-10-24T10:30:00Z",
  "completedSteps": [
    { "skill": "flow:init", "duration": 15000, "timestamp": "..." },
    { "skill": "flow:blueprint", "duration": 45000, "timestamp": "..." }
  ],
  "currentStep": {
    "skill": "flow:specify",
    "startTime": "2024-10-24T10:31:00Z"
  },
  "pendingSteps": ["flow:clarify", "flow:plan", "flow:tasks", "flow:implement"],
  "context": {
    "type": "greenfield",
    "mode": "full",
    "featureName": "user-authentication"
  }
}
```

## Interactive Mode

### Confirmation Prompts

When `requireConfirmation: true`:

```
📋 Next Step: flow:plan

This will create a technical implementation plan including:
- Architecture design
- API contracts
- Data models
- Component breakdown

Estimated time: 2-3 minutes
Input required: None (fully automated)

Continue? [Y/n/skip]:
  Y     → Execute this step
  n     → Abort orchestration
  skip  → Skip this step and continue
```

### User Decisions During Workflow

```javascript
// Decision points that pause for user input
const decisions = [
  {
    step: 'flow:blueprint',
    question: 'Create architecture blueprint?',
    defaultAction: 'yes',
    affects: ['All future features will reference blueprint']
  },
  {
    step: 'flow:analyze',
    question: 'Run consistency analysis?',
    defaultAction: 'auto',  // Based on config
    affects: ['May find issues requiring fixes before continuing']
  },
  {
    step: 'flow:checklist',
    question: 'Run quality checklists?',
    defaultAction: 'auto',
    affects: ['Quality gates may block implementation']
  }
];
```

## Completion Summary

### Full Summary Format

```markdown
✅ Flow Orchestration Complete

## Workflow Summary
- Project Type: Greenfield
- Workflow Mode: Full
- Feature: User Authentication

## Executed Steps
- [x] flow:init (10s) - Created .flow/ structure
- [x] flow:blueprint (45s) - Defined architecture patterns
- [x] flow:specify (67s) - Generated specification
- [x] flow:clarify (23s) - Resolved 3 ambiguities
- [x] flow:plan (120s) - Created technical plan
- [x] flow:analyze (15s) - Validated consistency (0 issues)
- [x] flow:tasks (30s) - Generated 24 tasks
- [x] flow:implement (480s) - Completed implementation

## Created Artifacts
- .flow/architecture-blueprint.md (v1.0.0)
- features/001-user-auth/spec.md
- features/001-user-auth/plan.md
- features/001-user-auth/tasks.md

## Implementation Results
- Files created: 12
- Files modified: 3
- Tests created: 8
- Tests passing: 8/8
- Tasks completed: 24/24

## Quality Metrics
- Specification clarity: 95%
- Blueprint alignment: 100%
- Test coverage: 87%

Total duration: 12 minutes 50 seconds
Peak memory: 145 MB

Next steps:
- Review implementation in features/001-user-auth/
- Run tests: npm test
- Create git commit: git add . && git commit
```

## Resume Functionality

### Resuming Interrupted Workflows

```bash
# Orchestration was interrupted during flow:plan
$ flow:orchestrate --resume

Checking saved state...
✓ Found session from 2024-10-24T10:30:00Z
✓ Completed: flow:init, flow:blueprint, flow:specify
✓ Interrupted during: flow:plan

Resume options:
1. Continue from flow:plan (recommended)
2. Restart flow:plan from beginning
3. Skip flow:plan and continue to flow:tasks
4. Abort and start fresh

Choice [1]:
```

### State Recovery

```javascript
async function resume() {
  const state = loadState('.flow/.orchestration-state.json');

  if (!state) {
    throw new Error('No saved state found. Cannot resume.');
  }

  console.log(`Resuming session ${state.sessionId}`);
  console.log(`Completed: ${state.completedSteps.map(s => s.skill).join(', ')}`);

  // Determine resume point
  const resumeFrom = state.currentStep?.skill || state.pendingSteps[0];

  const choice = await askUser('Resume from where?', {
    options: [
      `Continue from ${resumeFrom}`,
      `Restart ${resumeFrom}`,
      'Start fresh'
    ]
  });

  if (choice === 'Start fresh') {
    await deleteState();
    return orchestrate();
  }

  // Resume workflow
  return continueWorkflow(state, resumeFrom);
}
```

## Troubleshooting

### Common Issues

**"Orchestration stuck on skill"**:
- Check skill logs for errors
- Increase timeout in config
- Run skill manually to debug: `flow:plan`

**"State file corrupted"**:
- Delete `.flow/.orchestration-state.json`
- Restart orchestration with `flow:orchestrate`

**"Steps running in wrong order"**:
- Check for custom configuration overrides
- Verify `.flow/` directory structure
- Review CLAUDE.md for workflow customizations

**"Can't resume after interruption"**:
- Ensure `saveState: true` in config
- Check `.flow/.orchestration-state.json` exists
- Verify file permissions

### Debug Mode

```bash
# Enable verbose logging
FLOW_DEBUG=true flow:orchestrate

# Output:
[DEBUG] Assessing project...
[DEBUG] Project type: greenfield
[DEBUG] Current phase: null
[DEBUG] Executing: flow:init
[DEBUG] Skill output: ...
```

## Advanced Usage

### Custom Workflow Sequences

```javascript
// Override default sequence via CLAUDE.md
FLOW_ORCHESTRATE_SEQUENCE="init,specify,plan,implement"
FLOW_ORCHESTRATE_SKIP="blueprint,clarify,analyze,tasks"
```

### Parallel Execution (Experimental)

```javascript
// When enabled, runs independent skills in parallel
{
  "orchestration": {
    "parallel": true
  }
}

// Example: If spec and blueprint don't depend on each other
await Promise.all([
  executeSkill('flow:specify'),
  executeSkill('flow:blueprint')
]);
```

### Custom Decision Logic

```javascript
// In CLAUDE.md, define custom skip logic
FLOW_SKIP_CLARIFY_IF="spec.ambiguities.length === 0"
FLOW_SKIP_ANALYZE_IF="spec.userStories.length < 3"
FLOW_REQUIRE_CHECKLIST_IF="spec.requiresSecurity || spec.isPublicAPI"
```
