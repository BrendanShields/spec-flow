# Implementation Tasks: Navi System Optimization

## Overview

Breaking down the Navi optimization into 84 executable tasks organized by user story with parallel execution opportunities marked.

**Legend**:
- `T###` - Task ID (sequential)
- `[P]` - Can be executed in parallel
- `[US#]` - User Story reference
- File paths are absolute from project root

---

## Phase 1: Setup & Preparation

### Infrastructure Setup
- [x] T001 [P] Create backup of existing .flow directory at .flow-backup-$(date)
- [x] T002 [P] Set up testing infrastructure at __specification__/tests/
- [x] T003 [P] Create migration tool scaffold at scripts/migrate-to-navi.sh
- [x] T004 Document existing command inventory at docs/command-audit.md
- [x] T005 Create rollback script at scripts/rollback-migration.sh

---

## Phase 2: US1 - System Renaming (P1)

**Goal**: Rename Flow to Navi throughout the system
**Independent Test**: All "Flow" references updated, commands work with "navi"

### Global Renaming Tasks
- [x] T010 [P] [US1] Update all .md files: Flow → Navi at .flow/docs/*.md
- [x] T011 [P] [US1] Update all .sh scripts: flow → navi at .flow/scripts/*.sh
- [x] T012 [P] [US1] Update CLAUDE.md: Flow → Navi at CLAUDE.md
- [x] T013 [P] [US1] Update README.md: Flow → Navi at README.md
- [x] T014 [P] [US1] Update skill prompts: flow → navi at .claude/skills/*/README.md

### Command Updates
- [x] T015 [US1] Create /navi base command at .claude/commands/navi.md
- [x] T016 [P] [US1] Update flow-init → navi-init at .claude/skills/flow-init/
- [x] T017 [P] [US1] Update flow-specify → navi-specify at .claude/skills/flow-specify/
- [x] T018 [P] [US1] Update flow-plan → navi-plan at .claude/skills/flow-plan/
- [x] T019 [P] [US1] Update flow-tasks → navi-tasks at .claude/skills/flow-tasks/
- [x] T020 [P] [US1] Update flow-implement → navi-implement at .claude/skills/flow-implement/
- [x] T021 [P] [US1] Update flow-analyze → navi-analyze at .claude/skills/flow-analyze/

### Environment Variables
- [x] T022 [P] [US1] Update FLOW_ → NAVI_ in config.sh at .flow/scripts/config.sh
- [x] T023 [P] [US1] Update FLOW_ → NAVI_ in routing.sh at .flow/scripts/routing.sh
- [x] T024 [P] [US1] Update FLOW_ → NAVI_ in documentation at .flow/docs/*.md

### Parallel Opportunities
`T010-T014, T016-T021, T022-T024` (different files, no dependencies)

---

## Phase 3: US2 - Directory Migration (P1)

**Goal**: Migrate .flow/ to __specification__/
**Independent Test**: All functionality works with new directory structure

### Directory Migration
- [x] T030 [US2] Create __specification__ directory structure at __specification__/
- [x] T031 [US2] Git move .flow to __specification__ preserving history
- [x] T032 [US2] Update gitignore for __specification__ at .gitignore
- [x] T033 [US2] Create temporary symlink .flow → __specification__

### Path Updates
- [x] T034 [P] [US2] Update paths in all .sh scripts at __specification__/scripts/*.sh
- [x] T035 [P] [US2] Update paths in skill definitions at .claude/skills/*/
- [x] T036 [P] [US2] Update paths in command definitions at .claude/commands/
- [x] T037 [P] [US2] Update paths in CLAUDE.md at CLAUDE.md
- [x] T038 [P] [US2] Update paths in templates at __specification__/templates/*.md

### Migration Tool
- [x] T039 [US2] Implement directory detection in migration tool at scripts/migrate-to-navi.sh
- [x] T040 [US2] Implement safe migration with git mv at scripts/migrate-to-navi.sh
- [x] T041 [US2] Implement path reference updates at scripts/migrate-to-navi.sh
- [x] T042 [US2] Add migration validation checks at scripts/migrate-to-navi.sh

### Parallel Opportunities
`T034-T038` (different files, independent updates)

---

## Phase 4: US3 - Documentation Consolidation (P1)

**Goal**: Eliminate duplicate documentation, use lowercase naming
**Independent Test**: Single source of truth for all docs, consistent naming

### Document Merging
- [x] T050 [P] [US3] Merge ARCHITECTURE.md + architecture-blueprint.md → architecture.md at __specification__/docs/architecture.md
- [x] T051 [P] [US3] Rename PRODUCT-REQUIREMENTS.md → requirements.md at __specification__/docs/requirements.md
- [x] T052 [P] [US3] Rename CLAUDE-FLOW.md content → merge into CLAUDE.md
- [x] T053 [P] [US3] Remove redundant COMMANDS.md at __specification__/docs/

### Documentation Updates
- [x] T054 [US3] Update all uppercase .md filenames to lowercase at __specification__/**/*.md
- [x] T055 [P] [US3] Update references to consolidated docs at .claude/skills/*/README.md
- [x] T056 [P] [US3] Update template references at __specification__/templates/*.md

### Parallel Opportunities
`T050-T053, T055-T056` (different files, no dependencies)

---

## Phase 5: US4 - Command Simplification (P1)

**Goal**: Remove unnecessary commands and files
**Independent Test**: Simplified command structure works correctly

### Command Cleanup
- [x] T060 [US4] Remove CLAUDE-FLOW file (functionality in skills)
- [x] T061 [US4] Remove COMMANDS file (covered by .claude/)
- [x] T062 [US4] Consolidate duplicate command logic at .claude/commands/
- [x] T063 [US4] Create unified /navi router at .claude/commands/navi.md

### Deprecation Handling
- [x] T064 [US4] Add deprecation warnings to old commands at .claude/commands/flow-*.md
- [x] T065 [US4] Create command alias mapping at __specification__/scripts/aliases.sh
- [x] T066 [US4] Document migration path at docs/migration-guide.md

---

## Phase 6: US5 - Token Optimization (P2)

**Goal**: Reduce token usage by 30%+
**Independent Test**: Measure token usage before/after, verify 30% reduction

### Prompt Optimization
- [x] T070 [P] [US5] Extract common patterns to shared utilities at .claude/shared/
- [x] T071 [P] [US5] Implement progressive disclosure in flow-init at .claude/skills/flow-init/README.md
- [x] T072 [P] [US5] Implement progressive disclosure in flow-specify at .claude/skills/flow-specify/README.md
- [x] T073 [P] [US5] Implement progressive disclosure in flow-plan at .claude/skills/flow-plan/README.md
- [x] T074 [P] [US5] Implement progressive disclosure in flow-tasks at .claude/skills/flow-tasks/README.md
- [x] T075 [P] [US5] Implement progressive disclosure in flow-implement at .claude/skills/flow-implement/README.md

### Context Management
- [x] T076 [US5] Implement context compression utility at __specification__/scripts/compress-context.sh
- [x] T077 [US5] Add lazy loading for detailed instructions at .claude/shared/lazy-loader.md
- [x] T078 [US5] Create token usage metrics tracker at __specification__/scripts/measure-tokens.sh

### Parallel Opportunities
`T070-T075` (different skill files, independent optimization)

---

## Phase 7: US6 - Parallel Processing (P2)

**Goal**: Maximize parallel execution for faster operations
**Independent Test**: Verify parallel operations complete correctly and faster

### Parallel Infrastructure
- [x] T080 [US6] Implement worker pool pattern at __specification__/scripts/parallel-executor.sh
- [x] T081 [US6] Add [P] markers to parallelizable tasks in all skills
- [x] T082 [US6] Create parallel file operations utility at __specification__/scripts/parallel-files.sh

### Skill Parallelization
- [x] T083 [P] [US6] Enable parallel execution in navi-analyze at .claude/skills/navi-analyze/
- [x] T084 [P] [US6] Enable parallel execution in navi-implement at .claude/skills/navi-implement/
- [x] T085 [P] [US6] Enable parallel research in navi-plan at .claude/skills/navi-plan/

### Parallel Opportunities
`T083-T085` (different skills, independent changes)

---

## Phase 8: US7 - Cognitive Simplification (P2)

**Goal**: Reduce cognitive complexity for users
**Independent Test**: User can complete workflow with fewer commands

### User Experience
- [x] T090 [US7] Implement intelligent command routing at .claude/commands/navi.md
- [x] T091 [US7] Add context-aware suggestions at __specification__/scripts/suggest-next.sh
- [x] T092 [US7] Create simplified help system at .claude/commands/help.md
- [x] T093 [US7] Add command shortcuts and aliases at __specification__/scripts/shortcuts.sh

---

## Phase 9: US8 - DRY Implementation (P2)

**Goal**: Apply DRY principles throughout codebase
**Independent Test**: No duplicate code patterns remain

### Code Deduplication
- [x] T100 [P] [US8] Extract common file operations at __specification__/scripts/common-files.sh
- [x] T101 [P] [US8] Extract common validation logic at __specification__/scripts/common-validate.sh
- [x] T102 [P] [US8] Extract common formatting utilities at __specification__/scripts/common-format.sh
- [x] T103 [US8] Update skills to use shared utilities at .claude/skills/*/

### Parallel Opportunities
`T100-T102` (different utility files, independent extraction)

---

## Phase 10: Testing & Validation

### Integration Testing
- [x] T110 [P] Test migration tool with sample projects at __specification__/tests/
- [x] T111 [P] Test command routing and deprecation at __specification__/tests/
- [x] T112 [P] Test token optimization metrics at __specification__/tests/
- [x] T113 [P] Test parallel execution correctness at __specification__/tests/

### Performance Validation
- [x] T114 Benchmark execution time improvements at __specification__/tests/benchmarks/
- [x] T115 Measure token usage reduction at __specification__/tests/metrics/
- [x] T116 Validate backward compatibility at __specification__/tests/compatibility/

### Parallel Opportunities
`T110-T113` (different test suites, independent execution)

---

## Phase 11: Documentation & Release

### Documentation Updates
- [x] T120 [P] Update user guide for Navi at docs/user-guide.md
- [x] T121 [P] Create migration guide at docs/migration-guide.md
- [x] T122 [P] Update API documentation at docs/api-reference.md
- [x] T123 [P] Create changelog at CHANGELOG.md

### Release Preparation
- [x] T124 Create release notes at docs/release-notes.md
- [x] T125 Update version numbers at __specification__/config/version
- [x] T126 Tag release in git at v2.0.0

### Parallel Opportunities
`T120-T123` (different documentation files)

---

## Summary

**Total Tasks**: 84
**Parallelizable Tasks**: 52 (62%)
**Sequential Tasks**: 32 (38%)

### By Priority
- **P1 (Must Have)**: US1-US4 (42 tasks)
- **P2 (Should Have)**: US5-US8 (31 tasks)
- **P3 (Nice to Have)**: Not included in initial implementation

### Estimated Timeline
- **Week 1**: Phases 1-4 (Core refactoring)
- **Week 2**: Phases 5-8 (Optimization)
- **Week 3**: Phases 9-11 (Testing & Release)

### Critical Path
1. T001-T005 (Setup)
2. T030-T033 (Directory migration)
3. T039-T042 (Migration tool)
4. T110-T116 (Testing)
5. T124-T126 (Release)

### Parallel Execution Opportunities
- Phase 2: 15 tasks can run in parallel
- Phase 4: 6 tasks can run in parallel
- Phase 6: 6 tasks can run in parallel
- Testing: 4 test suites can run in parallel

This aggressive parallelization can reduce total execution time by approximately 60%.