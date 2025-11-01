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

## Conflict Detection

**Naming Conflicts:** Duplicate component/file names across artifacts
**Dependency Cycles:** Circular task dependencies detected via DFS
**Resource Conflicts:** Multiple parallel tasks accessing same file/resource

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

## Blueprint Compliance

Check technology stack, patterns followed, and architectural principles (DRY, SOLID).

## Reporting

**Gap Report:** User stories → tasks mapping, test coverage, documentation
**Conflict Report:** Resource conflicts, naming duplicates, dependency cycles