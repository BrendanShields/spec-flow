# Flow Analyze Reference

## Analysis Categories

### 1. Coverage Gaps

**Forward Coverage** (Requirements → Tasks):
- Each requirement should have ≥1 task
- Non-functional requirements need implementation tasks
- Edge cases should have test tasks

**Backward Coverage** (Tasks → Requirements):
- Each task should map to ≥1 requirement
- Orphan tasks indicate missing requirements or unnecessary work

**Algorithm**:
```javascript
function analyzeCoverage(spec, tasks) {
  const requirements = extractRequirements(spec);
  const taskMap = mapTasksToRequirements(tasks, requirements);

  const gaps = [];

  // Forward: requirements with no tasks
  for (const req of requirements) {
    const taskCount = taskMap[req.id]?.length || 0;
    if (taskCount === 0) {
      gaps.push({
        type: 'FORWARD_GAP',
        severity: req.type === 'functional' ? 'HIGH' : 'MEDIUM',
        requirement: req,
        recommendation: `Add implementation tasks for ${req.id}`
      });
    }
  }

  // Backward: tasks with no requirement
  for (const task of tasks) {
    if (!task.requirementId) {
      gaps.push({
        type: 'BACKWARD_GAP',
        severity: 'MEDIUM',
        task: task,
        recommendation: `Add requirement or remove orphan task ${task.id}`
      });
    }
  }

  return gaps;
}
```

### 2. Blueprint Alignment

**Validation Rules**:
```javascript
const blueprintChecks = {
  'tdd-required': (tasks) => {
    // For each feature task, check for corresponding test task
    const featureTasks = tasks.filter(t => !t.description.includes('test'));
    const testTasks = tasks.filter(t => t.description.includes('test'));

    if (featureTasks.length > 0 && testTasks.length === 0) {
      return {
        severity: 'CRITICAL',
        message: 'TDD required but no test tasks found',
        blocking: true
      };
    }
  },

  'api-versioning-required': (plan) => {
    if (!plan.apiDesign.versioning) {
      return {
        severity: 'HIGH',
        message: 'Blueprint requires API versioning but none specified',
        blocking: false
      };
    }
  },

  'performance-targets': (spec, plan) => {
    const perfReqs = spec.requirements.filter(r => r.type === 'performance');
    const perfTasks = plan.tasks.filter(t => t.tags.includes('performance'));

    if (perfReqs.length > 0 && perfTasks.length === 0) {
      return {
        severity: 'HIGH',
        message: 'Performance requirements exist but no optimization tasks',
        blocking: false
      };
    }
  }
};
```

### 3. Terminology Consistency

**Detection**:
```javascript
function analyzeTerminology(spec, plan, tasks) {
  const terms = extractTerms([spec, plan, tasks]);
  const groups = clusterSimilarTerms(terms);

  const inconsistencies = [];

  for (const group of groups) {
    if (group.variants.length > 1) {
      inconsistencies.push({
        severity: 'MEDIUM',
        concept: group.concept,
        variants: group.variants,  // e.g., ["User", "Account", "Member"]
        recommendation: `Standardize to "${group.mostCommon}"`
      });
    }
  }

  return inconsistencies;
}

function clusterSimilarTerms(terms) {
  // Use string similarity, synonyms, plurals
  const groups = [];

  for (const term of terms) {
    const normalized = normalize(term);
    let found = false;

    for (const group of groups) {
      if (isSimilar(normalized, group.concept)) {
        group.variants.push(term);
        found = true;
        break;
      }
    }

    if (!found) {
      groups.push({
        concept: normalized,
        variants: [term],
        mostCommon: term
      });
    }
  }

  return groups.filter(g => g.variants.length > 1);
}
```

### 4. Cross-Document Consistency

**Validation**:
```javascript
function validateConsistency(spec, plan, tasks) {
  const issues = [];

  // Check spec user stories match plan components
  const specStories = spec.userStories;
  const planComponents = plan.components;

  for (const story of specStories) {
    const hasComponent = planComponents.some(c =>
      c.relatedStory === story.id
    );

    if (!hasComponent) {
      issues.push({
        severity: 'HIGH',
        type: 'MISSING_COMPONENT',
        message: `User story ${story.id} has no components in plan`,
        recommendation: 'Add components to plan or remove story from spec'
      });
    }
  }

  // Check plan components have tasks
  for (const component of planComponents) {
    const hasTasks = tasks.some(t =>
      t.component === component.name
    );

    if (!hasTasks) {
      issues.push({
        severity: 'HIGH',
        type: 'MISSING_TASKS',
        message: `Component "${component.name}" has no tasks`,
        recommendation: 'Add implementation tasks for component'
      });
    }
  }

  return issues;
}
```

### 5. Dependency Analysis

**Topological Sort**:
```javascript
function validateTaskOrder(tasks) {
  const graph = buildDependencyGraph(tasks);
  const sorted = topologicalSort(graph);

  if (!sorted) {
    return {
      severity: 'CRITICAL',
      message: 'Circular dependency detected',
      blocking: true
    };
  }

  const violations = [];

  for (let i = 0; i < tasks.length; i++) {
    const task = tasks[i];
    for (const depId of task.dependencies || []) {
      const depIndex = tasks.findIndex(t => t.id === depId);

      if (depIndex > i) {
        violations.push({
          severity: 'HIGH',
          type: 'DEPENDENCY_ORDERING',
          message: `${task.id} depends on ${depId} which comes later`,
          recommendation: `Move ${depId} before ${task.id}`
        });
      }
    }
  }

  return violations;
}
```

## Severity Levels

### CRITICAL
- **Blocks**: Implementation cannot proceed
- **Examples**:
  - Blueprint violation (TDD required, no tests)
  - Circular dependencies
  - Missing prerequisites

**Action**: MUST fix before flow:implement

### HIGH
- **Impact**: Major coverage gaps, inconsistencies
- **Examples**:
  - Functional requirement with no tasks
  - User story with no components
  - Task ordering violations

**Action**: SHOULD fix before implementation

### MEDIUM
- **Impact**: Quality/maintainability concerns
- **Examples**:
  - Terminology inconsistencies
  - Non-functional requirement gaps
  - Minor redundancy

**Action**: Consider fixing, not blocking

### LOW
- **Impact**: Style, nice-to-haves
- **Examples**:
  - Formatting inconsistencies
  - Minor wording improvements
  - Redundant documentation

**Action**: Optional

## Metrics

### Coverage Percentage

```
coverage = (requirementsWithTasks / totalRequirements) * 100
```

**Targets**:
- ≥95%: Excellent
- 85-94%: Good
- 75-84%: Acceptable
- <75%: Poor (missing work)

### Task Mapping

```
mappingRate = (mappedTasks / totalTasks) * 100
```

**Interpretation**:
- 100%: All tasks trace to requirements
- <100%: Orphan tasks (possibly unnecessary)

## Report Format

```markdown
# Flow Analysis Report

Generated: [TIMESTAMP]
Artifacts: spec.md, plan.md, tasks.md, blueprint.md

## Executive Summary

**Status**: ⚠️ Issues Found (3 CRITICAL, 5 HIGH, 2 MEDIUM)
**Recommendation**: Fix CRITICAL issues before proceeding

## Issues by Category

### Coverage Gaps (5 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| C1 | HIGH | Requirement "Error handling" has 0 tasks | Add error handling tasks |
| C2 | MEDIUM | "Logging" has 0 tasks | Add logger setup task |
...

### Blueprint Violations (3 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| A1 | CRITICAL | TDD required but no tests | Add test tasks |
...

### Inconsistencies (2 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| I1 | MEDIUM | "User" vs "Account" | Standardize to "User" |
...

## Metrics

- **Requirements**: 24 total
  - With tasks: 22 (92%)
  - Without tasks: 2 (8%)

- **Tasks**: 67 total
  - Mapped to requirements: 65 (97%)
  - Orphaned: 2 (3%)

- **Blueprint Compliance**: ❌ FAILED
  - Violations: 3 CRITICAL

- **Terminology Consistency**: ⚠️ 2 inconsistencies

## Detailed Findings

[Detailed breakdown of each issue with context]

## Remediation Steps

1. Fix CRITICAL issues (required):
   - [ ] Add test tasks for TDD compliance
   - [ ] Resolve circular dependencies
   - [ ] Add missing prerequisites

2. Fix HIGH issues (recommended):
   - [ ] Add tasks for uncovered requirements
   - [ ] Reorder dependent tasks
   - [ ] Add components for user stories

3. Consider MEDIUM issues:
   - [ ] Standardize terminology
   - [ ] Add non-functional tasks
```

## Subagent Integration

### flow-analyzer Subagent

The analysis is performed by the `flow-analyzer` subagent:

**Capabilities**:
- Pattern recognition across documents
- Semantic similarity detection
- Dependency graph analysis
- Blueprint rule validation

**Invocation**:
```javascript
const results = await executeSubagent('flow-analyzer', {
  artifacts: {
    spec: readFile('spec.md'),
    plan: readFile('plan.md'),
    tasks: readFile('tasks.md'),
    blueprint: readFile('.flow/architecture-blueprint.md')
  },
  checks: [
    'coverage',
    'blueprint-alignment',
    'terminology',
    'consistency',
    'dependencies'
  ]
});
```

## Configuration

### Auto-Analyze Mode

```json
{
  "workflow": {
    "autoAnalyze": true
  }
}
```

When enabled, runs automatically:
- After `flow:tasks` completes
- Before `flow:implement` starts
- When artifacts are updated

### Severity Threshold

```json
{
  "analyze": {
    "blockOnSeverity": "HIGH"
  }
}
```

- `CRITICAL`: Block only on CRITICAL issues
- `HIGH`: Block on CRITICAL + HIGH
- `MEDIUM`: Block on CRITICAL + HIGH + MEDIUM
- `NONE`: Never block (report only)

### Skip Checks

```bash
flow:analyze --skip=terminology,formatting
```

Skip specific analysis categories.

## Troubleshooting

### "Analysis finds false positives"

**Cause**: Overly strict pattern matching

**Fix**: Update blueprint to reflect actual patterns, or skip specific checks

### "Coverage percentage seems wrong"

**Cause**: Tasks not properly mapped to requirements

**Fix**: Ensure task descriptions reference requirements explicitly

### "Blueprint violations but no blueprint exists"

**Cause**: Default blueprint rules applied

**Fix**: Create explicit `.flow/architecture-blueprint.md` or disable blueprint checks

## Related Files

- `spec.md` - Requirements (input)
- `plan.md` - Technical plan (input)
- `tasks.md` - Task list (input)
- `.flow/architecture-blueprint.md` - Blueprint (input)
- `analysis-report.md` - Generated report (output)
