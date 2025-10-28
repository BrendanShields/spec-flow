---
name: flow:analyze
description: Validate consistency across all Flow artifacts. Use when 1) Before implementation to catch issues early, 2) After spec/plan changes to verify alignment, 3) Team handoffs requiring validation, 4) Detecting missing requirements or tasks, 5) Multi-person teams need consistency checks. Performs read-only analysis and reports gaps/conflicts.
allowed-tools: Read, Task
---

# Flow Analyze

Perform read-only consistency validation across spec, plan, tasks, and blueprint to catch issues before implementation.

## Core Capability

Identifies gaps and conflicts using the `flow-analyzer` subagent:
- Loads all Flow artifacts (spec, plan, tasks, blueprint)
- Validates requirement coverage (forward and backward)
- Checks blueprint alignment and compliance
- Detects terminology inconsistencies
- Analyzes cross-document consistency
- Validates task dependencies and ordering
- Reports findings with severity levels
- Suggests specific remediation steps

## Analysis Categories

### Coverage Gaps
- **Forward**: Requirements with zero tasks
- **Backward**: Tasks with no mapped requirement
- **Non-functional**: Missing performance, security tasks

### Blueprint Violations
- **CRITICAL**: Must principles violated (e.g., TDD required, no tests)
- Missing mandatory sections
- Quality gate failures
- Blocks implementation until resolved

### Inconsistencies
- Terminology drift ("User" vs "Account" vs "Member")
- Conflicting requirements
- Task ordering contradictions
- Dependency violations

### Cross-Document Alignment
- User stories without components
- Components without tasks
- Tasks without requirements

## Severity Levels

| Severity | Impact | Action |
|----------|--------|--------|
| **CRITICAL** | Blocks implementation | MUST fix |
| **HIGH** | Major gaps/conflicts | SHOULD fix |
| **MEDIUM** | Quality concerns | Consider fixing |
| **LOW** | Style/minor issues | Optional |

## Output Format

```markdown
# Analysis Report

Status: ⚠️ Issues Found (1 CRITICAL, 3 HIGH, 2 MEDIUM)
Recommendation: Fix CRITICAL before proceeding

## Issues

| ID | Severity | Category | Issue | Recommendation |
|----|----------|----------|-------|----------------|
| A1 | CRITICAL | Blueprint | TDD required, no tests | Add test tasks |
| C1 | HIGH | Coverage | Auth requirement: 0 tasks | Add implementation |
| I1 | MEDIUM | Terminology | "User" vs "Account" | Standardize |

## Metrics

- Requirements: 24 (22 with tasks = 92%)
- Tasks: 67 (65 mapped = 97%)
- Blueprint Compliance: ❌ FAILED
- Terminology: ⚠️ 2 inconsistencies
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Coverage gap detection
- Blueprint violation analysis
- Terminology inconsistency reports
- Missing non-functional coverage
- Task ordering contradictions
- All-green passing analysis

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete analysis algorithms
- Coverage calculation methods
- Blueprint validation rules
- Terminology detection patterns
- Dependency analysis logic
- Report format specification
- Configuration options
- Subagent integration details

## Related Skills

- **flow-analyzer** (subagent): Performs consistency checks
- **flow:tasks**: Generate tasks (run before analyze)
- **flow:implement**: Execute implementation (run after passing)

## Validation

Test this skill:
```bash
scripts/validate.sh
```
