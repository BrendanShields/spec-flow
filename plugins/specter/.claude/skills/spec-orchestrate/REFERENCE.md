# Spec Orchestrate - Technical Reference

Advanced technical details for workflow orchestration.

## Table of Contents

1. [Orchestration Algorithm](#orchestration-algorithm)
2. [Phase Transition Logic](#phase-transition-logic)
3. [Checkpoint System](#checkpoint-system)
4. [State Persistence](#state-persistence)
5. [Error Recovery Strategies](#error-recovery-strategies)
6. [Configuration Options](#configuration-options)
7. [Performance Optimization](#performance-optimization)
8. [Troubleshooting](#troubleshooting)

---

## Orchestration Algorithm

### Main Orchestration Loop

```pseudocode
function orchestrate(userRequest, options):
  // Phase 1: Assessment
  state = loadCurrentState()
  workflowType = determineWorkflowType(state)
  startPhase = determineStartPhase(state, options.resume)

  // Phase 2: Execute workflow phases
  phases = buildPhaseSequence(workflowType, options)

  for phase in phases starting from startPhase:
    // Pre-phase validation
    if not validatePrerequisites(phase):
      handleMissingPrerequisites(phase)
      continue

    // Execute phase
    checkpoint = createCheckpoint(phase, "pre")
    result = executePhase(phase, state, options)

    // Handle phase result
    if result.success:
      updateState(phase, result)
      createCheckpoint(phase, "post")
      notifyProgress(phase, result)
    else:
      if result.recoverable:
        recovery = attemptRecovery(phase, result)
        if recovery.success:
          continue
      return handleFailure(phase, result, checkpoint)

    // Post-phase processing
    if shouldPromptUser(phase, result):
      userChoice = promptForDecision(phase, result)
      applyUserChoice(userChoice, state)

  // Phase 3: Completion
  return generateSummary(state, phases)
```

### Workflow Type Detection

```pseudocode
function determineWorkflowType(state):
  if not exists(".specter/"):
    return "uninitialized"

  if not exists(".specter/architecture-blueprint.md"):
    if isEmptyProject():
      return "greenfield"

  if state.currentFeature:
    return "feature_continuation"

  if hasUnfinishedFeature():
    return "feature_resume"

  return "new_feature"
```

### Phase Sequence Builder

```pseudocode
function buildPhaseSequence(workflowType, options):
  baseSequence = [
    "generate",
    "clarify",  // conditional
    "plan",
    "analyze",  // conditional
    "tasks",
    "implement"
  ]

  // Apply workflow type filters
  if workflowType == "greenfield":
    baseSequence = ["blueprint"] + baseSequence

  // Apply option filters
  if options.skipClarify or options.auto:
    baseSequence.remove("clarify")

  if options.skipAnalyze or options.auto:
    baseSequence.remove("analyze")

  return baseSequence
```

---

## Phase Transition Logic

### Phase Prerequisites

Each phase has specific prerequisites:

```yaml
generate:
  requires:
    - .specter/ directory exists
    - User requirement provided
  validates:
    - Requirement is not empty
    - Not duplicate of existing feature

clarify:
  requires:
    - spec.md exists
    - [CLARIFY] tags present in spec.md
  validates:
    - All [CLARIFY] tags are parseable
    - User available for input

plan:
  requires:
    - spec.md exists
    - All [CLARIFY] tags resolved
  validates:
    - Spec contains user stories
    - Requirements are clear

analyze:
  requires:
    - spec.md exists
    - plan.md exists
  validates:
    - Both files are well-formed
    - No file corruption

tasks:
  requires:
    - plan.md exists
    - Plan is complete
  validates:
    - Plan has implementation sections
    - Architecture defined

implement:
  requires:
    - tasks.md exists
    - Tasks are prioritized
  validates:
    - At least 1 P1 task exists
    - No circular dependencies
```

### Transition Decision Matrix

```
Current Phase → Next Phase: Conditions

generate → clarify:
  IF [CLARIFY] tags present AND not --skip-clarify
  ELSE → plan

clarify → plan:
  IF all clarifications resolved
  ELSE prompt user to complete clarifications

plan → analyze:
  IF complex feature (>15 tasks) AND not --skip-analyze
  ELSE → tasks

analyze → tasks:
  IF validation passed OR warnings only
  ELSE IF errors present:
    prompt for corrective action
    IF re-plan selected: → plan
    IF skip selected: → tasks (with warning)

tasks → implement:
  IF task breakdown complete
  ELSE error (invalid state)

implement → complete:
  IF all P1 tasks complete
  ELSE IF user requests early exit: → partial_complete
```

### State Transition Validation

```pseudocode
function validateTransition(fromPhase, toPhase, state):
  // Check prerequisites
  prerequisites = PHASE_PREREQUISITES[toPhase]
  for prereq in prerequisites.requires:
    if not checkPrerequisite(prereq, state):
      return {
        valid: false,
        reason: "Missing prerequisite: " + prereq,
        suggestion: "Run " + getSuggestion(prereq)
      }

  // Run validations
  for validation in prerequisites.validates:
    if not runValidation(validation, state):
      return {
        valid: false,
        reason: "Validation failed: " + validation,
        suggestion: "Fix issue and retry"
      }

  return { valid: true }
```

---

## Checkpoint System

### Checkpoint Structure

```yaml
checkpoint_metadata:
  timestamp: "2025-10-31T15:30:00Z"
  phase: "post-plan"
  feature_id: "003"
  feature_name: "product-search"
  workflow_type: "new_feature"

checkpoint_state:
  completed_phases:
    - generate: { duration: 45s, status: success }
    - clarify: { duration: 120s, status: success }
    - plan: { duration: 180s, status: success }

  current_phase:
    name: "analyze"
    status: "pending"
    estimated_duration: 60s

  pending_phases:
    - analyze
    - tasks
    - implement

  artifacts_created:
    - path: "features/003-product-search/spec.md"
      size: 4823
      hash: "a3f8d9e..."
    - path: "features/003-product-search/plan.md"
      size: 7142
      hash: "b2e7c4f..."

  state_snapshot:
    workflow_progress: |
      [Content of WORKFLOW-PROGRESS.md]
    decisions_log: |
      [Content of DECISIONS-LOG.md]
    current_session: |
      [Content of current-session.md]

recovery_information:
  can_resume: true
  resume_from_phase: "analyze"
  rollback_to_phase: "plan"
  estimated_remaining_time: 480s
```

### Checkpoint Creation Strategy

```pseudocode
function createCheckpoint(phase, timing):
  checkpoint = {
    metadata: gatherMetadata(phase, timing),
    state: captureCurrentState(),
    artifacts: listCreatedArtifacts(),
    recovery: buildRecoveryInfo(phase)
  }

  filename = formatCheckpointFilename(phase, timing)
  path = ".specter-state/checkpoints/" + filename

  writeCheckpoint(path, checkpoint)
  updateCheckpointIndex(checkpoint)

  return checkpoint
```

### Checkpoint Recovery

```pseudocode
function loadCheckpoint(checkpointId):
  checkpoint = readCheckpoint(checkpointId)

  // Restore state files
  restoreFile(".specter-state/current-session.md",
              checkpoint.state.current_session)
  restoreFile(".specter-memory/WORKFLOW-PROGRESS.md",
              checkpoint.state.workflow_progress)

  // Verify artifacts still exist
  for artifact in checkpoint.artifacts_created:
    if not exists(artifact.path):
      warn("Artifact missing: " + artifact.path)
    else if hash(artifact.path) != artifact.hash:
      warn("Artifact modified: " + artifact.path)

  return checkpoint
```

---

## State Persistence

### State Update Protocol

```pseudocode
function updateWorkflowState(phase, result):
  // 1. Read current state atomically
  currentSession = readFile(".specter-state/current-session.md")
  workflowProgress = readFile(".specter-memory/WORKFLOW-PROGRESS.md")

  // 2. Update relevant sections
  updatedSession = updatePhaseInSession(currentSession, phase, result)
  updatedProgress = updateFeatureInProgress(workflowProgress, phase, result)

  // 3. Write atomically (temp file → rename)
  writeTempFile(".specter-state/current-session.tmp", updatedSession)
  rename(".specter-state/current-session.tmp",
         ".specter-state/current-session.md")

  writeTempFile(".specter-memory/WORKFLOW-PROGRESS.tmp", updatedProgress)
  rename(".specter-memory/WORKFLOW-PROGRESS.tmp",
         ".specter-memory/WORKFLOW-PROGRESS.md")

  // 4. Update timestamp
  updateTimestamp(phase)
```

### State Consistency Checks

```pseudocode
function validateStateConsistency():
  issues = []

  // Check file existence
  requiredFiles = [
    ".specter-state/current-session.md",
    ".specter-memory/WORKFLOW-PROGRESS.md"
  ]
  for file in requiredFiles:
    if not exists(file):
      issues.append("Missing: " + file)

  // Check state alignment
  session = parseSessionState()
  progress = parseWorkflowProgress()

  if session.activeFeature != progress.inProgressFeature:
    issues.append("State mismatch: active feature differs")

  if session.currentPhase not in VALID_PHASES:
    issues.append("Invalid phase: " + session.currentPhase)

  return issues
```

---

## Error Recovery Strategies

### Recoverable Error Handling

```pseudocode
function attemptRecovery(phase, error):
  strategy = selectRecoveryStrategy(error.type)

  switch strategy:
    case "retry":
      return retryWithBackoff(phase, error)

    case "fallback":
      return executeFallbackApproach(phase, error)

    case "prompt_user":
      return promptUserForResolution(phase, error)

    case "skip_phase":
      return skipPhaseWithWarning(phase, error)

    default:
      return { success: false, reason: "No recovery strategy" }
```

### Error Classification

```yaml
error_types:
  timeout:
    recoverable: true
    strategy: retry
    max_retries: 2
    backoff: exponential

  validation_failure:
    recoverable: true
    strategy: prompt_user
    options:
      - re_run_phase
      - edit_manually
      - skip_validation

  missing_prerequisite:
    recoverable: true
    strategy: fallback
    fallback_actions:
      - install_dependency
      - create_missing_file
      - prompt_user_setup

  file_corruption:
    recoverable: false
    strategy: restore_from_checkpoint

  user_cancellation:
    recoverable: false
    strategy: save_checkpoint_and_exit
```

### Recovery Decision Tree

```
Error Detected
├─ Is Recoverable?
│  ├─ YES
│  │  ├─ Retry Count < Max?
│  │  │  ├─ YES → Retry with backoff
│  │  │  └─ NO → Try alternative strategy
│  │  └─ Alternative Available?
│  │     ├─ YES → Execute alternative
│  │     └─ NO → Prompt user for decision
│  └─ NO
│     ├─ Checkpoint Exists?
│     │  ├─ YES → Offer rollback
│     │  └─ NO → Save current state
│     └─ Exit gracefully with error report
```

---

## Configuration Options

### Environment Variables

```bash
# Orchestration mode
SPEC_ORCHESTRATE_MODE=interactive|auto|batch
  # interactive: Prompt at decision points (default)
  # auto: Use defaults, minimize prompts
  # batch: No prompts, fail on ambiguity

# Phase skipping
SPEC_ORCHESTRATE_SKIP_CLARIFY=true|false
SPEC_ORCHESTRATE_SKIP_ANALYZE=true|false
SPEC_ORCHESTRATE_SKIP_BLUEPRINT=true|false

# Checkpointing
SPEC_ORCHESTRATE_CHECKPOINT_FREQUENCY=all|phases|milestones
  # all: Checkpoint after every skill execution
  # phases: Checkpoint after each phase (default)
  # milestones: Only checkpoint at major milestones

# Validation
SPEC_ORCHESTRATE_VALIDATE_STRICT=true|false
  # true: Block on any validation error
  # false: Allow warnings, block only on errors (default)

# Recovery
SPEC_ORCHESTRATE_AUTO_RESUME=true|false
  # true: Automatically resume from checkpoint
  # false: Prompt user to confirm resume (default)

# Progress reporting
SPEC_ORCHESTRATE_PROGRESS_UPDATES=verbose|normal|quiet
  # verbose: Real-time task-level updates
  # normal: Phase-level updates (default)
  # quiet: Only start and completion messages
```

### Project-Level Configuration

In `CLAUDE.md`:

```markdown
# Spec Orchestration Configuration

## Workflow Preferences

SPEC_ORCHESTRATE_MODE=interactive
SPEC_ORCHESTRATE_AUTO_CLARIFY=false
SPEC_ORCHESTRATE_VALIDATE_STRICT=true

## Phase Configuration

SPEC_ORCHESTRATE_ALWAYS_ANALYZE=true
SPEC_ORCHESTRATE_REQUIRE_BLUEPRINT=false

## MCP Integration

SPEC_ORCHESTRATE_SYNC_JIRA=true
SPEC_ORCHESTRATE_SYNC_CONFLUENCE=true

## Custom Phase Order (Advanced)

# Override default phase sequence
SPEC_ORCHESTRATE_PHASES=generate,clarify,plan,custom-validation,tasks,implement

# Define custom phase
SPEC_ORCHESTRATE_CUSTOM_PHASE_NAME=custom-validation
SPEC_ORCHESTRATE_CUSTOM_PHASE_SKILL=spec:custom-validator
SPEC_ORCHESTRATE_CUSTOM_PHASE_AFTER=plan
```

---

## Performance Optimization

### Parallel Phase Execution

Some phases can run in parallel:

```yaml
parallel_opportunities:
  early_validation:
    parallel_phases:
      - clarify  # Can start while generate completes
      - style_check  # Can run alongside clarify

  artifact_generation:
    parallel_phases:
      - generate_docs  # Can run during tasks phase
      - setup_tests  # Can run during tasks phase
```

### Caching Strategy

```pseudocode
function executePhaseCached(phase, state):
  cacheKey = computeCacheKey(phase, state)

  if cacheExists(cacheKey) and not cacheExpired(cacheKey):
    cachedResult = loadFromCache(cacheKey)
    if validateCachedResult(cachedResult, state):
      return cachedResult

  result = executePhase(phase, state)
  saveToCache(cacheKey, result)
  return result
```

### Progress Estimation

```pseudocode
function estimateRemainingTime(currentPhase, state):
  historicalData = loadHistoricalDurations()

  remainingPhases = getPhasesAfter(currentPhase)

  estimate = 0
  for phase in remainingPhases:
    // Use historical average for similar features
    similarFeatures = findSimilarFeatures(state.feature, historicalData)
    avgDuration = average([f.phases[phase].duration for f in similarFeatures])

    // Adjust for feature complexity
    complexityFactor = calculateComplexityFactor(state.feature)
    adjustedDuration = avgDuration * complexityFactor

    estimate += adjustedDuration

  return estimate
```

---

## Troubleshooting

### Common Issues

#### Issue: Orchestration Stuck in Phase

**Symptoms**: Phase shows "in_progress" indefinitely

**Diagnosis**:
```bash
# Check current state
cat .specter-state/current-session.md

# Check for hung processes
ps aux | grep spec

# Check last checkpoint
ls -lt .specter-state/checkpoints/
```

**Resolution**:
1. Kill hung process if exists
2. Load last checkpoint: `spec:orchestrate --resume`
3. If resume fails: `spec:orchestrate --rollback=plan`

#### Issue: Validation Always Fails

**Symptoms**: spec:analyze phase repeatedly fails

**Diagnosis**:
```bash
# Run validation manually
spec:analyze --verbose

# Check state consistency
spec:validate --check-files
```

**Resolution**:
1. Fix validation errors manually
2. Skip validation: `spec:orchestrate --skip-analyze`
3. If files corrupted: Restore from git

#### Issue: Lost Progress After Interruption

**Symptoms**: No checkpoint found for resume

**Diagnosis**:
```bash
# Check checkpoint directory
ls .specter-state/checkpoints/

# Check if state files intact
cat .specter-state/current-session.md
```

**Resolution**:
1. If checkpoints exist: `spec:orchestrate --resume --checkpoint=<id>`
2. If no checkpoints: `spec:orchestrate --recover-state`
3. Worst case: Start from last git commit

#### Issue: Phase Transition Fails

**Symptoms**: "Cannot transition from X to Y" error

**Diagnosis**:
```bash
# Check phase prerequisites
spec:validate --phase=<next-phase>

# Check for missing artifacts
ls features/###-name/
```

**Resolution**:
1. Manually create missing artifacts
2. Run missing prerequisite phase
3. Force transition (risky): `spec:orchestrate --force-phase=<phase>`

### Debug Mode

Enable detailed logging:

```bash
# Enable debug mode
export SPEC_DEBUG=true
export SPEC_ORCHESTRATE_DEBUG=true

# Run with verbose output
spec:orchestrate --verbose

# Debug output saved to:
.specter-state/debug-orchestrate-<timestamp>.log
```

### State Recovery Commands

```bash
# List all checkpoints
spec:checkpoint list

# Restore specific checkpoint
spec:checkpoint restore <id>

# Create manual checkpoint
spec:checkpoint save "before-risky-operation"

# Diff current state vs checkpoint
spec:checkpoint diff <id>

# Rollback to checkpoint (destructive)
spec:checkpoint rollback <id>
```

---

## Advanced Usage

### Custom Workflow Sequences

Define custom phase sequences for specialized workflows:

```yaml
# In .specter/config.yml
custom_workflows:
  quick_poc:
    phases: [generate, plan, implement]
    options:
      skip_clarify: true
      skip_analyze: true
      auto_mode: true

  production_ready:
    phases: [generate, clarify, plan, analyze, security_review, tasks, implement, qa_check]
    options:
      validate_strict: true
      require_approvals: true

  docs_only:
    phases: [generate, clarify, plan]
    options:
      stop_before_implementation: true
```

### Orchestration Hooks

Execute custom code at phase transitions:

```yaml
# In .specter/hooks/orchestration-hooks.yml
hooks:
  pre_generate:
    - check_dependencies.sh
    - notify_team.sh

  post_plan:
    - update_jira.sh
    - create_architecture_diagram.sh

  pre_implement:
    - run_security_scan.sh
    - backup_current_state.sh

  post_complete:
    - run_full_test_suite.sh
    - generate_release_notes.sh
    - notify_success.sh
```

---

## Related Documentation

- **SKILL.md**: Core orchestration instructions
- **EXAMPLES.md**: Concrete usage scenarios
- **shared/workflow-patterns.md**: Common workflow patterns
- **shared/state-management.md**: State file specifications
- **spec:implement/REFERENCE.md**: Implementation phase details
- **spec:analyze/REFERENCE.md**: Validation phase details

---

**Last Updated**: 2025-10-31
**Skill Version**: 1.0.0
**Token Size**: ~3,200 tokens (REFERENCE only)
