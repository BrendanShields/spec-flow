# Flow Analyzer: Reference Guide

## Analysis Patterns

### Cross-Artifact Validation

```javascript
class ArtifactAnalyzer {
  async analyze(spec, plan, tasks) {
    const results = {
      gaps: [],
      conflicts: [],
      warnings: [],
      suggestions: []
    };

    // Check spec → plan alignment
    this.validateSpecToPlan(spec, plan, results);

    // Check plan → tasks coverage
    this.validatePlanToTasks(plan, tasks, results);

    // Check tasks → spec traceability
    this.validateTasksToSpec(tasks, spec, results);

    // Check blueprint compliance
    this.validateBlueprintCompliance(plan, results);

    return results;
  }
}
```

## Validation Rules

### Specification Completeness
| Check | Severity | Description |
|-------|----------|-------------|
| User stories present | CRITICAL | Every spec needs user stories |
| Acceptance criteria | HIGH | Each story needs testable criteria |
| Priority assigned | MEDIUM | P1/P2/P3 classification |
| Edge cases covered | MEDIUM | Common edge cases addressed |
| Non-functionals | LOW | Performance, security considered |

### Plan Coverage
| Check | Severity | Description |
|-------|----------|-------------|
| All stories addressed | CRITICAL | Every user story has plan |
| Technical decisions | HIGH | Key choices documented |
| API contracts | HIGH | Endpoints defined for API projects |
| Data models | MEDIUM | Entities and relationships |
| Error handling | MEDIUM | Failure scenarios planned |

### Task Completeness
| Check | Severity | Description |
|-------|----------|-------------|
| Story coverage | CRITICAL | All stories have tasks |
| File paths | HIGH | Tasks specify target files |
| Dependencies | MEDIUM | Task order makes sense |
| Parallelization | LOW | [P] markers appropriate |
| Test tasks | MEDIUM | Tests for each component |

## Conflict Detection Patterns

### Pattern 1: Naming Conflicts
```javascript
function detectNamingConflicts(artifacts) {
  const names = new Map();
  const conflicts = [];

  // Collect all names
  for (const artifact of artifacts) {
    extractNames(artifact).forEach(name => {
      if (!names.has(name)) {
        names.set(name, []);
      }
      names.get(name).push(artifact.path);
    });
  }

  // Find conflicts
  for (const [name, locations] of names) {
    if (locations.length > 1) {
      conflicts.push({
        type: 'naming',
        name,
        locations,
        severity: 'MEDIUM'
      });
    }
  }

  return conflicts;
}
```

### Pattern 2: Dependency Cycles
```javascript
function detectCycles(dependencies) {
  const graph = buildGraph(dependencies);
  const cycles = [];
  const visited = new Set();
  const recursionStack = new Set();

  function dfs(node, path = []) {
    visited.add(node);
    recursionStack.add(node);
    path.push(node);

    for (const neighbor of graph.get(node) || []) {
      if (!visited.has(neighbor)) {
        dfs(neighbor, [...path]);
      } else if (recursionStack.has(neighbor)) {
        // Cycle detected
        const cycleStart = path.indexOf(neighbor);
        cycles.push(path.slice(cycleStart));
      }
    }

    recursionStack.delete(node);
  }

  for (const node of graph.keys()) {
    if (!visited.has(node)) {
      dfs(node);
    }
  }

  return cycles;
}
```

### Pattern 3: Resource Conflicts
```javascript
function detectResourceConflicts(tasks) {
  const resources = new Map();
  const conflicts = [];

  for (const task of tasks) {
    const resource = extractResource(task);
    if (!resource) continue;

    if (!resources.has(resource)) {
      resources.set(resource, []);
    }

    // Check for concurrent access
    const concurrent = resources.get(resource)
      .filter(t => t.parallel && task.parallel);

    if (concurrent.length > 0) {
      conflicts.push({
        type: 'resource',
        resource,
        tasks: [task.id, ...concurrent.map(t => t.id)],
        severity: 'HIGH'
      });
    }

    resources.get(resource).push(task);
  }

  return conflicts;
}
```

## Gap Analysis

### Missing Requirements
- Unspecified error cases
- Missing non-functional requirements
- Incomplete acceptance criteria
- Undefined edge cases

### Missing Implementation
- Specified but not planned
- Planned but no tasks
- Tasks without tests
- Missing documentation tasks

### Missing Integration
- External dependencies not addressed
- API contracts incomplete
- Data migration not planned
- Deployment tasks missing

## Blueprint Compliance Checks

### Architecture Alignment
```javascript
function checkArchitectureAlignment(plan, blueprint) {
  const violations = [];

  // Check technology stack
  if (blueprint.stack && !plan.technologies.includes(blueprint.stack)) {
    violations.push({
      type: 'stack',
      expected: blueprint.stack,
      actual: plan.technologies
    });
  }

  // Check patterns
  if (blueprint.patterns) {
    for (const pattern of blueprint.patterns) {
      if (!isPatternFollowed(plan, pattern)) {
        violations.push({
          type: 'pattern',
          pattern: pattern.name,
          description: pattern.description
        });
      }
    }
  }

  return violations;
}
```

## Reporting Templates

### Gap Report
```markdown
## Gap Analysis Report

### Critical Gaps
- [ ] User Story US3 has no implementation tasks
- [ ] API endpoint /users/profile not in plan

### Missing Test Coverage
- [ ] Component: UserService
- [ ] API: Authentication endpoints

### Documentation Gaps
- [ ] API documentation for new endpoints
- [ ] Migration guide for breaking changes
```

### Conflict Report
```markdown
## Conflict Analysis Report

### Resource Conflicts
⚠️ Multiple tasks modifying src/api/users.js in parallel
- T012 [P]: Add user validation
- T015 [P]: Update user model

### Naming Conflicts
⚠️ Duplicate component name "UserProfile"
- spec.md: Line 45
- plan.md: Line 120

### Dependency Cycles
🔄 Circular dependency detected:
T005 → T008 → T011 → T005
```