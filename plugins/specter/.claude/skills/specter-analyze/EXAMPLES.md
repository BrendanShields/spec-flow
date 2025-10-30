# Flow Analyze Examples

## 1. Coverage Gap Detection

**Scenario**: Spec has requirement with no corresponding tasks

**Analysis Output**:
```markdown
## Analysis Report

### Coverage Gaps (2 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| C1 | HIGH | "Error handling for API failures" (Spec §NFR-2) has 0 tasks | Add tasks for error middleware, error responses |
| C2 | MEDIUM | "Logging" (Spec §NFR-5) has 0 tasks | Add task for logger setup |

**Metrics**:
- Requirements: 15
- Requirements with tasks: 13 (87%)
- Tasks: 42
- Tasks mapped to requirements: 42 (100%)
```

## 2. Blueprint Violation

**Scenario**: Plan violates architecture blueprint

**Analysis Output**:
```markdown
## Analysis Report

### Constitution Violations (1 CRITICAL)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| A1 | CRITICAL | Blueprint requires TDD but no test tasks exist | Add test tasks for each feature |

**Constitution Compliance**: ❌ FAILED
- Blocking issues: 1
- Implementation CANNOT proceed until resolved
```

**Resolution**: Add test tasks, re-run analyze

## 3. Terminology Inconsistency

**Scenario**: Same concept referenced with different names

**Analysis Output**:
```markdown
## Analysis Report

### Inconsistencies (3 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| I1 | MEDIUM | "User" (Spec) vs "Account" (Plan) vs "Member" (Tasks) | Standardize to "User" |
| I2 | LOW | "Product" vs "Item" used interchangeably | Choose one term consistently |
| I3 | LOW | API endpoint naming: /users vs /accounts | Use /users consistently |

**Action**: Update plan.md and tasks.md to use "User" everywhere
```

## 4. Missing Non-Functional Coverage

**Scenario**: Performance requirements with no implementation plan

**Analysis Output**:
```markdown
## Analysis Report

### Coverage Gaps - Non-Functional

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| C3 | HIGH | Performance requirement "<500ms API" has no tasks | Add caching, indexing, query optimization tasks |
| C4 | HIGH | Security requirement "HTTPS only" not in plan | Add TLS configuration task |
| C5 | MEDIUM | "99.9% uptime" has no monitoring tasks | Add health checks, monitoring setup |
```

## 5. Task Ordering Contradiction

**Scenario**: Tasks depend on things that come later

**Analysis Output**:
```markdown
## Analysis Report

### Dependencies (2 issues)

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| D1 | HIGH | T015 "Use Auth service" but T020 "Create Auth service" comes later | Reorder: T020 before T015 |
| D2 | MEDIUM | Migration T012 depends on model T018 (Phase 4) | Move T018 to Phase 2 |

**Dependency Violations**: 2
- Some tasks cannot execute in current order
```

## 6. All Green - No Issues

**Scenario**: Well-structured Flow artifacts

**Analysis Output**:
```markdown
## Analysis Report

✅ **No issues found**

**Metrics**:
- Requirements: 24
- Requirements with tasks: 24 (100% coverage)
- Tasks: 67
- Tasks mapped to requirements: 67 (100%)
- Blueprint compliance: ✅ PASS
- Terminology consistency: ✅ PASS
- Task ordering: ✅ PASS

**Recommendation**: Safe to proceed with specter:implement
```

For detailed analysis algorithms and validation rules, see [REFERENCE.md](./REFERENCE.md).
