# Flow Orchestrate Reference

## Workflow Sequences

### Complete Sequences by Project Type

**Greenfield (New Project)**:
```
specter:init → specter:blueprint → specter:specify → specter:clarify →
specter:plan → specter:analyze → specter:tasks → specter:implement
```

**Brownfield (Existing Codebase)**:
```
specter:init → specter:specify → specter:clarify →
specter:plan → specter:tasks → specter:implement
```

**Feature Addition**:
```
specter:specify → specter:clarify → specter:plan → specter:tasks → specter:implement
```

**POC/Prototype**:
```
specter:specify --skip-validation → specter:plan --minimal →
specter:tasks --simple → specter:implement --skip-checklists
```

## Orchestration Algorithm

### Phase 1: Project Assessment

```javascript
function assessProject() {
  const hasFlow = checkDirectory('.specter/');
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
    await executeSkill('specter:init');
  }

  if (isGreenfield() && !hasBlueprint()) {
    const response = await askUser('Create architecture blueprint?');
    if (response === 'yes') {
      await executeSkill('specter:blueprint');
    }
  }

  // Check for new MCP servers
  const newServers = await detectNewMCPServers();
  if (newServers.length > 0) {
    await executeSkill('specter:update');
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
    await executeSkill('specter:specify', description);
  }

  // Check for ambiguities
  const spec = loadSpecification();
  if (hasAmbiguities(spec)) {
    const shouldClarify = await askUser('Clarify ambiguities?');
    if (shouldClarify) {
      await executeSkill('specter:clarify');
    }
  }
}
```

### Phase 4: Planning

```javascript
async function plan() {
  // Generate technical plan
  if (!hasPlan()) {
    await executeSkill('specter:plan');
  }

  // Validate consistency (optional)
  const config = loadConfig();
  if (config.SPECTER_REQUIRE_ANALYSIS === 'true') {
    const results = await executeSkill('specter:analyze');

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
      await executeSkill('specter:specify', '--update');
    }
    if (results.issues.some(i => i.source === 'plan')) {
      await executeSkill('specter:plan', '--update');
    }

    // Re-analyze
    await executeSkill('specter:analyze');
  } else if (action === 'abort') {
    throw new Error('Orchestration aborted by user');
  }
}
```

### Phase 5: Task Generation

```javascript
async function generateTasks() {
  if (!hasTasks()) {
    await executeSkill('specter:tasks');
  }
}
```

### Phase 6: Implementation

```javascript
async function implement() {
  // Check for quality gates
  const config = loadConfig();
  if (config.SPECTER_REQUIRE_CHECKLISTS === 'true') {
    const checklistTypes = determineChecklistTypes();
    await executeSkill('specter:checklist', `--type ${checklistTypes.join(',')}`);
  }

  // Execute implementation
  await executeSkill('specter:implement');
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
    'specter:blueprint': () => {
      return context.type === 'brownfield' ||
             context.mode === 'poc';
    },

    'specter:clarify': () => {
      const spec = loadSpecification();
      return !hasAmbiguities(spec);
    },

    'specter:analyze': () => {
      return context.mode === 'poc' ||
             (context.type === 'feature' && isSimple());
    },

    'specter:checklist': () => {
      return context.mode === 'poc' ||
             config.SPECTER_REQUIRE_CHECKLISTS !== 'true';
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
| Ambiguities found | Execute `specter:clarify` |
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
      await executeSkill('specter:clarify');
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
  console.log('💾 Progress saved. Resume with "specter:orchestrate --resume"');

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
// State saved to .specter/.orchestration-state.json
{
  "sessionId": "uuid-1234",
  "startTime": "2024-10-24T10:30:00Z",
  "completedSteps": [
    { "skill": "specter:init", "duration": 15000, "timestamp": "..." },
    { "skill": "specter:blueprint", "duration": 45000, "timestamp": "..." }
  ],
  "currentStep": {
    "skill": "specter:specify",
    "startTime": "2024-10-24T10:31:00Z"
  },
  "pendingSteps": ["specter:clarify", "specter:plan", "specter:tasks", "specter:implement"],
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
📋 Next Step: specter:plan

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
    step: 'specter:blueprint',
    question: 'Create architecture blueprint?',
    defaultAction: 'yes',
    affects: ['All future features will reference blueprint']
  },
  {
    step: 'specter:analyze',
    question: 'Run consistency analysis?',
    defaultAction: 'auto',  // Based on config
    affects: ['May find issues requiring fixes before continuing']
  },
  {
    step: 'specter:checklist',
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
- [x] specter:init (10s) - Created .specter/ structure
- [x] specter:blueprint (45s) - Defined architecture patterns
- [x] specter:specify (67s) - Generated specification
- [x] specter:clarify (23s) - Resolved 3 ambiguities
- [x] specter:plan (120s) - Created technical plan
- [x] specter:analyze (15s) - Validated consistency (0 issues)
- [x] specter:tasks (30s) - Generated 24 tasks
- [x] specter:implement (480s) - Completed implementation

## Created Artifacts
- .specter/architecture-blueprint.md (v1.0.0)
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
# Orchestration was interrupted during specter:plan
$ specter:orchestrate --resume

Checking saved state...
✓ Found session from 2024-10-24T10:30:00Z
✓ Completed: specter:init, specter:blueprint, specter:specify
✓ Interrupted during: specter:plan

Resume options:
1. Continue from specter:plan (recommended)
2. Restart specter:plan from beginning
3. Skip specter:plan and continue to specter:tasks
4. Abort and start fresh

Choice [1]:
```

### State Recovery

```javascript
async function resume() {
  const state = loadState('.specter/.orchestration-state.json');

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
- Run skill manually to debug: `specter:plan`

**"State file corrupted"**:
- Delete `.specter/.orchestration-state.json`
- Restart orchestration with `specter:orchestrate`

**"Steps running in wrong order"**:
- Check for custom configuration overrides
- Verify `.specter/` directory structure
- Review CLAUDE.md for workflow customizations

**"Can't resume after interruption"**:
- Ensure `saveState: true` in config
- Check `.specter/.orchestration-state.json` exists
- Verify file permissions

### Debug Mode

```bash
# Enable verbose logging
SPECTER_DEBUG=true specter:orchestrate

# Output:
[DEBUG] Assessing project...
[DEBUG] Project type: greenfield
[DEBUG] Current phase: null
[DEBUG] Executing: specter:init
[DEBUG] Skill output: ...
```

## Advanced Usage

### Custom Workflow Sequences

```javascript
// Override default sequence via CLAUDE.md
SPECTER_ORCHESTRATE_SEQUENCE="init,specify,plan,implement"
SPECTER_ORCHESTRATE_SKIP="blueprint,clarify,analyze,tasks"
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
  executeSkill('specter:specify'),
  executeSkill('specter:blueprint')
]);
```

### Custom Decision Logic

```javascript
// In CLAUDE.md, define custom skip logic
SPECTER_SKIP_CLARIFY_IF="spec.ambiguities.length === 0"
SPECTER_SKIP_ANALYZE_IF="spec.userStories.length < 3"
SPECTER_REQUIRE_CHECKLIST_IF="spec.requiresSecurity || spec.isPublicAPI"
```
