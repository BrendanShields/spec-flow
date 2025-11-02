# Spec Analyze - Examples

Concrete usage scenarios for the analyze phase skill.

## Example 1: All-Green Validation

**Context**: Feature ready for implementation, no issues detected.

**Input**:
```bash
User: "Validate the authentication feature before I start coding"
Current feature: 001-user-authentication
Files exist: spec.md, plan.md, tasks.md
```

**Skill Activation**:
```markdown
Trigger: "validate" + feature context
Loads: spec.md, plan.md, tasks.md
Invokes: analyze phaser
```

**Analysis Process**:
```markdown
1. Coverage check:
   - 4 user stories → 23 tasks (100% coverage)
   - 23 tasks → 4 stories (100% mapped)
   - 12 acceptance criteria → 19 tasks (100% addressed)

2. Priority alignment:
   - P1 stories (2) → P1 tasks (12) ✅
   - P2 stories (2) → P2 tasks (11) ✅

3. Blueprint compliance:
   - TDD required → Test tasks present ✅
   - Security checklist → Validation tasks present ✅

4. Consistency:
   - Terminology: "User" used consistently ✅
   - Components: All referenced in tasks ✅
```

**Output**:
```markdown
# Analysis Report: User Authentication System

**Date**: 2025-10-31 16:00:00
**Feature**: 001-user-authentication
**Status**: ✅ Validation Passed

## Summary

- **CRITICAL**: 0 issues
- **HIGH**: 0 issues
- **MEDIUM**: 0 issues
- **LOW**: 0 issues

**Recommendation**: Validation passed - proceed with implementation

## Metrics

### Coverage
- User Stories: 4 (4 with tasks = 100%)
- Tasks: 23 (23 mapped to stories = 100%)
- Acceptance Criteria: 12 (12 addressed = 100%)

### Priority Distribution
- P1 Stories: 2 → P1 Tasks: 12 (100% aligned)
- P2 Stories: 2 → P2 Tasks: 11 (100% aligned)

### Blueprint Compliance
- MUST Principles: 3 (3 compliant = 100%)
- SHOULD Principles: 2 (2 compliant = 100%)

### Consistency
- Terminology Variations: 0 detected
- Orphaned Tasks: 0
- Unmapped Stories: 0

## Next Steps

All validation checks passed. Ready to proceed:

1. Run: `implement phase` to start implementation
2. Session will track progress in {config.paths.state}/
3. Tasks will move to CHANGES-COMPLETED.md as done
```

**User Experience**:
```
✅ Validation complete - no issues found
→ Ready to implement: implement phase
```

---

## Example 2: Coverage Gaps Detected

**Context**: Specification incomplete, missing tasks for requirements.

**Input**:
```bash
User: "Check if my search feature spec is complete"
Current feature: 002-product-search
Files: spec.md (5 stories), plan.md (3 components), tasks.md (8 tasks)
```

**Analysis Process**:
```markdown
1. Coverage check:
   - US2.1: Basic search → 3 tasks ✅
   - US2.2: Filters → 2 tasks ✅
   - US2.3: Autocomplete → 0 tasks ❌ HIGH
   - US2.4: Sort results → 1 task ✅
   - US2.5: Pagination → 2 tasks ✅

2. Tasks mapped:
   - T001-T003 → US2.1 ✅
   - T004-T005 → US2.2 ✅
   - T006 → US2.4 ✅
   - T007-T008 → US2.5 ✅

3. Acceptance criteria:
   - US2.3 AC1: "Show suggestions" → No task ❌ HIGH
   - US2.3 AC2: "Debounce input" → No task ❌ MEDIUM
   - US2.3 AC3: "Handle errors" → No task ❌ MEDIUM
```

**Output**:
```markdown
# Analysis Report: Product Search

**Status**: ⚠️ Issues Found (0 CRITICAL, 2 HIGH, 2 MEDIUM)

## Summary

**Recommendation**: Fix HIGH issues before implementation

## Issues by Severity

### HIGH Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| H1 | Coverage | US2.3 has 0 tasks | spec.md:L89 | Add autocomplete tasks |
| H2 | Acceptance | AC2.3.1 not addressed | spec.md:L95 | Add suggestion display task |

### MEDIUM Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| M1 | Acceptance | AC2.3.2 not addressed | spec.md:L96 | Add debounce implementation |
| M2 | Acceptance | AC2.3.3 not addressed | spec.md:L97 | Add error handling task |

## Metrics

- User Stories: 5 (4 with tasks = 80%)
- Tasks: 8 (8 mapped = 100%)
- Acceptance Criteria: 15 (11 addressed = 73%)

## Recommendations

### Immediate Actions (HIGH)
1. Add tasks for US2.3 autocomplete functionality
2. Create task to implement suggestion display (AC2.3.1)

### Important Improvements (MEDIUM)
1. Add debounce implementation task (AC2.3.2)
2. Add error handling task (AC2.3.3)

## Next Steps

Run `tasks phase --update` to add missing tasks for US2.3
Then re-run `analyze phase` to verify
```

**User Experience**:
```
⚠️  Found 4 issues (2 HIGH, 2 MEDIUM)
→ Fix with: tasks phase --update
```

---

## Example 3: Priority Misalignment

**Context**: Task priorities don't match story importance.

**Input**:
```bash
Current feature: 003-payment-processing
Issue: P1 story has only P3 tasks
```

**Analysis Process**:
```markdown
1. Story priorities:
   - US3.1: Process payments (P1)
   - US3.2: Refund handling (P1)
   - US3.3: Payment history (P2)
   - US3.4: Export receipts (P3)

2. Task mapping:
   - US3.1 → T001(P3), T002(P3), T003(P3) ❌ CRITICAL
   - US3.2 → T004(P1), T005(P1) ✅
   - US3.3 → T006(P2), T007(P2) ✅
   - US3.4 → T008(P3) ✅
```

**Output**:
```markdown
# Analysis Report: Payment Processing

**Status**: ⚠️ Issues Found (1 CRITICAL, 0 HIGH)

## Issues by Severity

### CRITICAL Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| C1 | Priority | P1 story has only P3 tasks | US3.1 | Increase T001-T003 to P1 |

## Metrics

### Priority Distribution
- P1 Stories: 2 → P1 Tasks: 2 (50% aligned) ❌
  - US3.1 misaligned: P1 story → P3 tasks
- P2 Stories: 1 → P2 Tasks: 2 (100% aligned) ✅
- P3 Stories: 1 → P3 Tasks: 1 (100% aligned) ✅

## Recommendations

### Immediate Actions (CRITICAL)
1. Update tasks.md: Change T001, T002, T003 from P3 to P1
   - These implement core payment processing (US3.1)
   - Cannot defer - required for release

## Next Steps

Manually edit {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}
Change task priorities, then re-run analyze phase
```

**User Experience**:
```
❌ CRITICAL: Priority mismatch blocks implementation
→ Fix T001-T003 priorities in tasks.md
```

---

## Example 4: Blueprint Violations

**Context**: Architecture blueprint defines mandatory patterns not followed.

**Input**:
```bash
Current feature: 004-user-notifications
Blueprint: TDD required (MUST), API versioning (MUST)
Tasks: No test tasks, no versioning tasks
```

**Analysis Process**:
```markdown
1. Blueprint compliance:
   - MUST: Test-Driven Development
     → Search tasks for "test", "spec", "TDD"
     → Found: 0 test tasks ❌ CRITICAL

   - MUST: API versioning
     → Search tasks for "version", "v1", "api"
     → Found: 0 versioning tasks ❌ CRITICAL

   - SHOULD: Security review
     → Found: 1 security task ✅
```

**Output**:
```markdown
# Analysis Report: User Notifications

**Status**: ⚠️ Issues Found (2 CRITICAL, 0 HIGH)

## Issues by Severity

### CRITICAL Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| C1 | Blueprint | TDD required, no test tasks | tasks.md | Add TDD tasks for all components |
| C2 | Blueprint | API versioning required | tasks.md | Add versioning implementation |

## Metrics

### Blueprint Compliance
- MUST Principles: 3 (1 compliant = 33%) ❌
  - TDD: Not compliant (0 test tasks)
  - API versioning: Not compliant (0 tasks)
  - Security: Compliant ✅
- SHOULD Principles: 2 (2 compliant = 100%) ✅

## Recommendations

### Immediate Actions (CRITICAL)
1. Add test tasks following TDD:
   - Write tests before implementation for each component
   - Minimum: Unit tests for service layer
   - Recommended: Integration tests for API

2. Add API versioning tasks:
   - Implement /v1/notifications endpoint structure
   - Add version middleware
   - Document versioning strategy

## Next Steps

CRITICAL issues block implementation - must fix first:
1. Update tasks.md with test tasks
2. Update tasks.md with versioning tasks
3. Re-run analyze phase to verify compliance
```

**User Experience**:
```
❌ CRITICAL: Blueprint violations detected
→ Add TDD and versioning tasks before proceeding
```

---

## Example 5: Terminology Inconsistencies

**Context**: Same concept called different names across documents.

**Analysis Process**:
```markdown
1. Terminology scan:
   - spec.md: "User" (15 occurrences)
   - plan.md: "Account" (8 occurrences), "User" (3 occurrences)
   - tasks.md: "Member" (5 occurrences), "User" (10 occurrences)

2. Detect variations:
   - Concept: Authenticated person
   - Variants: "User", "Account", "Member" ❌ MEDIUM

3. Impact:
   - Code confusion: UserService vs AccountService?
   - Database: users table vs accounts table?
   - API: /users vs /accounts endpoints?
```

**Output**:
```markdown
# Analysis Report: User Management

**Status**: ⚠️ Issues Found (0 CRITICAL, 0 HIGH, 1 MEDIUM)

## Issues by Severity

### MEDIUM Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| M1 | Consistency | "User"/"Account"/"Member" used inconsistently | Multiple | Standardize to one term |

## Metrics

### Consistency
- Terminology Variations: 3 detected
  - "User": spec.md (15), plan.md (3), tasks.md (10)
  - "Account": plan.md (8)
  - "Member": tasks.md (5)

## Detailed Findings

### Terminology Analysis

**Recommendation**: Standardize on "User" (most common in spec)

**Required Changes**:
1. plan.md: Replace 8 instances of "Account" with "User"
2. tasks.md: Replace 5 instances of "Member" with "User"

**Affected Areas**:
- Component names: AccountService → UserService
- Database: accounts table → users table
- API endpoints: /accounts → /users
- Variable names: currentAccount → currentUser

## Recommendations

### Optional Enhancements (MEDIUM)
1. Standardize terminology to "User" across all documents
2. Update component names for consistency
3. Consider creating glossary in {config.paths.spec_root}/

## Next Steps

Optional but recommended:
1. Run update phase to fix terminology in spec/plan
2. Manually update tasks.md
3. Re-run analyze phase to verify
```

**User Experience**:
```
⚠️  1 MEDIUM issue: Terminology inconsistent
→ Optional: Standardize to "User"
→ OK to proceed if desired
```

---

## Example 6: Complex Multi-Issue Scenario

**Context**: Multiple issues across categories.

**Output Summary**:
```markdown
# Analysis Report: E-commerce Checkout

**Status**: ⚠️ Issues Found (1 CRITICAL, 3 HIGH, 5 MEDIUM, 2 LOW)

## Summary

**Recommendation**: Fix CRITICAL and HIGH issues before implementation

## Issues (11 total)

CRITICAL:
- C1: TDD required, no test tasks

HIGH:
- H1: US5.3 payment gateway has 0 tasks
- H2: P1 story has only P3 tasks
- H3: Acceptance criteria AC5.1.2 not addressed

MEDIUM:
- M1: "Cart"/"Basket" terminology inconsistent
- M2: OrderService in plan, CheckoutService in tasks
- M3: Missing error handling tasks
- M4: No logging tasks for audit trail
- M5: Orphaned task T015 not mapped to story

LOW:
- L1: Task numbering gaps (T001, T003, T005...)
- L2: Inconsistent priority notation ([P] vs P1)

## Metrics

- Coverage: 83% (5/6 stories have tasks)
- Priority Alignment: 67% (2/3 P1 stories aligned)
- Blueprint Compliance: 50% (TDD failing)
- Terminology: 2 inconsistencies detected

## Next Steps

1. Add test tasks (fixes C1)
2. Add payment gateway tasks (fixes H1)
3. Fix priority misalignment (fixes H2)
4. Add acceptance task (fixes H3)
5. Consider: Standardize terminology (M1, M2)
6. Consider: Add error/logging tasks (M3, M4)
```

**User Experience**:
```
⚠️  11 issues found (1 CRITICAL, 3 HIGH)
→ Fix critical/high before implementing
→ Run: tasks phase --update
```

---

## Testing This Skill

**Trigger phrases**:
- "Validate the spec"
- "Check for consistency"
- "Analyze gaps in the feature"
- "Are there any issues with the plan?"
- "Verify everything aligns"

**Expected behavior**:
1. Loads current feature artifacts
2. Invokes analyze phaser subagent
3. Generates structured report
4. Categorizes by severity
5. Provides actionable recommendations
6. Saves report to {config.paths.state}/
