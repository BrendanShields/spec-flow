---
description: "Task list for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: plan.md, spec.md, research.md, data-model.md, contracts/
**Organization**: Tasks grouped by user story for independent implementation
**Format**: `[ID] [P?] [Story] Description`
- [P] = parallel (no dependencies)
- [Story] = user story label (US1, US2, etc.)

---

## Phase 1: Setup

- [ ] T001 Create project structure per plan
- [ ] T002 Initialize [language] with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting

---

## Phase 2: Foundational (REQUIRED BEFORE USER STORIES)

- [ ] T004 Setup database schema and migrations
- [ ] T005 [P] Implement auth/authorization framework
- [ ] T006 [P] Setup API routing and middleware
- [ ] T007 Create base entities (all stories depend on this)
- [ ] T008 Configure error handling and logging
- [ ] T009 Setup environment configuration

**Checkpoint**: Foundation complete → user stories can proceed in parallel

---

## Phase 3: User Story 1 - [Title] (P1) MVP

**Goal**: [Brief description]
**Independent Test**: [Verification method]

**Tests** (optional, write first):
- [ ] T010 [P] [US1] Contract test in tests/contract/test_[name].py
- [ ] T011 [P] [US1] Integration test in tests/integration/test_[name].py

**Implementation**:
- [ ] T012 [P] [US1] Create [Entity1] model
- [ ] T013 [P] [US1] Create [Entity2] model
- [ ] T014 [US1] Implement [Service] (depends: T012, T013)
- [ ] T015 [US1] Implement [endpoint/feature]
- [ ] T016 [US1] Add validation and error handling

**Checkpoint**: User Story 1 complete and testable independently

---

## Phase 4: User Story 2 - [Title] (P2)

**Goal**: [Brief description]
**Tests** (optional):
- [ ] T017 [P] [US2] Contract test
- [ ] T018 [P] [US2] Integration test

**Implementation**:
- [ ] T019 [P] [US2] Create [Entity] model
- [ ] T020 [US2] Implement [Service]
- [ ] T021 [US2] Implement [endpoint/feature]
- [ ] T022 [US2] Integrate with US1 (if needed)

---

## Phase 5: User Story 3 - [Title] (P3)

[Follow Phase 4 pattern]

---

## Phase N: Polish

- [ ] TXXX [P] Documentation updates
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart validation

---

## Execution Order

**Setup (Phase 1)** → **Foundational (Phase 2)** → **User Stories (P1→P2→P3 or parallel)**

- [P] tasks can run in parallel (different files)
- User stories can run in parallel after Phase 2 completes
- Tests must fail before implementation

---

**Key**: Each story independently completable | Validate at each checkpoint



