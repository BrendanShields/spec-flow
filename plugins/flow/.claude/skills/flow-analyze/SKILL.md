---
name: flow:analyze
description: Validate consistency across all Flow artifacts. Use when: 1) Before implementation to catch issues early, 2) After spec/plan changes to verify alignment, 3) Team handoffs requiring validation, 4) Detecting missing requirements or tasks. Performs read-only analysis and reports gaps/conflicts.
allowed-tools: Read, Task
---

# Flow Analyze: Consistency Validation

Perform read-only analysis to identify inconsistencies before implementation.

## When to Use

- After `flow:tasks` generates task breakdown
- Before `flow:implement` to catch issues early
- When spec/plan/tasks are updated
- **CRITICAL for multi-person teams**

## What This Skill Does

1. **Loads** spec.md, plan.md, tasks.md, architecture-blueprint.md
2. **Validates** using `flow-analyzer` subagent:
   - Requirement coverage (all requirements have tasks)
   - Task mapping (all tasks map to requirements)
   - Blueprint alignment (if exists)
   - Cross-document consistency
   - Terminology alignment
3. **Reports** findings with severity levels
4. **Suggests** remediation

## Analysis Categories

### Coverage Gaps
- Requirements with zero tasks
- Tasks with no mapped requirement
- Missing non-functional task coverage

### Inconsistencies
- Terminology drift
- Conflicting requirements
- Task ordering contradictions

### Constitution Violations
- **CRITICAL**: Must principles violated
- Missing mandatory sections
- Quality gate failures

### Ambiguities
- Vague terms (fast, scalable, robust)
- Unresolved placeholders
- Untestable requirements

## Output Format

```markdown
## Analysis Report

| ID | Severity | Category | Issue | Recommendation |
|----|----------|----------|-------|----------------|
| A1 | CRITICAL | Constitution | TDD required but no tests | Add test tasks |
| C1 | HIGH | Coverage | Auth requirement has no tasks | Add implementation tasks |
| I1 | MEDIUM | Terminology | "User" vs "Account" inconsistent | Standardize to "User" |

### Metrics
- Total Requirements: 24
- Total Tasks: 45
- Coverage: 92%
- Critical Issues: 1
- Constitution Compliant: NO
```

## Severity Levels

- **CRITICAL**: Constitution violation, blocking gaps
- **HIGH**: Coverage gaps, conflicting requirements
- **MEDIUM**: Terminology drift, missing NF coverage
- **LOW**: Style improvements, minor redundancy

## Configuration

```json
{
  "workflow": {
    "autoAnalyze": false  // Run after each phase
  }
}
```

## Subagents Used

- **flow-analyzer**: Pattern extraction and consistency checking

## Related Skills

- **flow:tasks**: Generate task breakdown (run before)
- **flow:implement**: Execute tasks (run after passing analysis)
