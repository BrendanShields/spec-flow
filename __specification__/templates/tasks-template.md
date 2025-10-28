# Implementation Tasks: {Feature Name}

**Feature ID**: {feature-id}
**Created**: {date}
**Based on**: plan.md
**Total Tasks**: {count}
**Estimated Duration**: {hours} hours

## Task Overview

| Phase | Tasks | Priority | Parallel | Estimated Time |
|-------|-------|----------|----------|----------------|
| Phase 1 | {count} | P1 | {count} | {hours}h |
| Phase 2 | {count} | P1 | {count} | {hours}h |
| Phase 3 | {count} | P2 | {count} | {hours}h |
| **Total** | **{total}** | - | **{parallel}** | **{total}h** |

---

## Task List

### Phase 1: Foundation

**Goal**: {Phase goal}
**Dependencies**: None
**Tasks**: {count}

#### T001 [US1] {Task Title}
**Priority**: P1
**Type**: {setup|implementation|testing|documentation}
**Estimated Time**: {minutes} minutes
**Dependencies**: None
**Parallel**: No

**Description**:
{Detailed task description}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

**Implementation Notes**:
- {Note 1}
- {Note 2}

**Files to Modify**:
- `{file1}` - {what to change}
- `{file2}` - {what to change}

---

#### T002 [US1] {Task Title}
**Priority**: P1
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T001
**Parallel**: No

**Description**:
{Description}

**Acceptance Criteria**:
- [ ] {Criterion}

---

#### T003 [P] [US1] {Task Title}
**Priority**: P1
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T001
**Parallel**: Yes (with T002)

**Description**:
{Description}

**Acceptance Criteria**:
- [ ] {Criterion}

---

### Phase 2: Core Features

**Goal**: {Phase goal}
**Dependencies**: Phase 1 complete
**Tasks**: {count}

#### T004 [US2] {Task Title}
**Priority**: P1
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T001, T002, T003
**Parallel**: No

**Description**:
{Description}

**Acceptance Criteria**:
- [ ] {Criterion}

---

#### T005 [P] [US2] {Task Title}
**Priority**: P1
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T004
**Parallel**: Yes (with T006)

**Description**:
{Description}

---

#### T006 [P] [US2] {Task Title}
**Priority**: P1
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T004
**Parallel**: Yes (with T005)

**Description**:
{Description}

---

### Phase 3: Integration & Polish

**Goal**: {Phase goal}
**Dependencies**: Phase 1, Phase 2 complete
**Tasks**: {count}

#### T007 [US3] {Task Title}
**Priority**: P2
**Type**: {type}
**Estimated Time**: {minutes} minutes
**Dependencies**: T004, T005, T006
**Parallel**: No

**Description**:
{Description}

---

## Parallel Execution Opportunities

Tasks marked with [P] can be executed in parallel:
- **Group 1**: T003 || T002 (after T001)
- **Group 2**: T005 || T006 (after T004)

## Task Dependencies Graph

```
T001 (Foundation)
  ├── T002 (Feature A)
  └── T003 [P] (Feature B)
      └── T004 (Integration)
          ├── T005 [P] (Enhancement A)
          └── T006 [P] (Enhancement B)
              └── T007 (Polish)
```

## Checkpoint Recommendations

Save checkpoints after completing:
- T003 (Phase 1 complete)
- T006 (Phase 2 complete)
- T007 (Feature complete)

## Testing Checklist

After implementation, verify:
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance acceptable
- [ ] Security validated
- [ ] Documentation updated
- [ ] Code reviewed

## Implementation Notes

### Prerequisites
- {Prerequisite 1}
- {Prerequisite 2}

### Common Patterns
- {Pattern to use}
- {Convention to follow}

### Gotchas
- {Watch out for this}
- {Common mistake to avoid}

## Progress Tracking

Update `__specification__-state/current-session.md` after completing each task.

---

**Next Steps**: Run `/flow-implement` to start execution
