# Tasks: Specter v3.0 Consolidation

**Feature**: 002-specter-consolidation-v3
**Created**: 2024-10-31
**Total Tasks**: 60
**Estimated Duration**: 240 hours (6 weeks)
**Dependencies**: Feature 001 (plugin-stabilization) must be merged

---

## Task Legend

- `[P]` = Parallelizable (can run concurrently with other [P] tasks in same phase)
- `@username` = Assigned to specific team member
- `⏱️` = Time estimate
- `🔗` = Dependencies (must complete before this task)

---

## Phase 1: Command Consolidation (2 weeks, 80 hours)

### P1.1: Hub Command Infrastructure (28 hours)

#### T001: Create hub command router
**Description**: Create `.claude/commands/specter.md` with case statement routing
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] File `.claude/commands/specter.md` exists
- [ ] Routes to init, plan, tasks, implement
- [ ] Handles no args (context-aware)
- [ ] Handles free text (auto-specify)
- [ ] Basic error handling

**Implementation**:
```bash
cd /Users/dev/dev/tools/spec-flow/plugins/specter
touch .claude/commands/specter.md
# Implement routing logic based on plan.md ADR-001
```

---

#### T002: Implement context detection logic
**Description**: Add intelligent context detection based on current workflow phase
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] Detects current phase from `.specter-state/session.json`
- [ ] Routes to appropriate skill based on phase
- [ ] Provides helpful next-step suggestions
- [ ] Falls back to help if context unclear

**Implementation**:
```bash
# Add to specter.md:
# - Read .specter-state/session.json
# - Detect activeFeature.phase
# - Route accordingly
```

---

#### T003: Add subcommand routing
**Description**: Implement routing for explicit subcommands (init, plan, tasks, etc.)
**Priority**: P1
**Effort**: 12 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] `/specter init` routes to specter-init
- [ ] `/specter plan` routes to specter-plan
- [ ] `/specter tasks` routes to specter-tasks
- [ ] `/specter implement` routes to specter-implement
- [ ] `/specter analyze` routes to specter-analyze
- [ ] All 10 skills accessible via subcommands

**Implementation**:
```bash
# Implement case statement for all subcommands
# Test each route manually
```

---

### P1.2: Interactive Mode (28 hours)

#### T004: Create interactive menu system [P]
**Description**: Build interactive menu for users unfamiliar with commands
**Priority**: P1
**Effort**: 16 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] `/specter --interactive` shows menu
- [ ] Menu shows current context
- [ ] Numbered options for each action
- [ ] Arrow key navigation (optional)
- [ ] Selection triggers appropriate skill

**Implementation**:
```bash
# Use select builtin or whiptail for menu
# Show context-aware options
```

---

#### T005: Add progressive help system [P]
**Description**: Context-aware help that shows relevant information based on phase
**Priority**: P2
**Effort**: 12 hours
**Dependencies**: T002
**Acceptance Criteria**:
- [ ] `/specter --help` shows context-aware help
- [ ] Help differs based on current phase
- [ ] Shows next steps
- [ ] Includes examples
- [ ] Links to full documentation

**Implementation**:
```bash
# Detect phase, generate custom help
# Use templates for each phase
```

---

### P1.3: Shell Completion (12 hours)

#### T006: Create bash completion script [P]
**Description**: Add bash completion for `/specter` command
**Priority**: P2
**Effort**: 6 hours
**Dependencies**: T003
**Acceptance Criteria**:
- [ ] File `.claude/completion/specter.bash` exists
- [ ] Completes subcommands (init, plan, tasks, etc.)
- [ ] Completes feature names
- [ ] Completes file paths
- [ ] Installation instructions in README

**Implementation**:
```bash
# Create completion script
# Test with: complete -F _specter specter
```

---

#### T007: Create zsh completion script [P]
**Description**: Add zsh completion for `/specter` command
**Priority**: P3
**Effort**: 6 hours
**Dependencies**: T003
**Acceptance Criteria**:
- [ ] File `.claude/completion/_specter` exists
- [ ] Works with oh-my-zsh
- [ ] Completes subcommands and features
- [ ] Installation instructions in README

**Implementation**:
```bash
# Create zsh completion script
# Test with zsh
```

---

### P1.4: Backward Compatibility (12 hours)

#### T008: Create deprecation wrappers [P]
**Description**: Create wrapper scripts for all old commands
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] `/specter-init` wrapper created
- [ ] `/specter-specify` wrapper created
- [ ] `/specter-plan` wrapper created
- [ ] `/specter-tasks` wrapper created
- [ ] `/specter-implement` wrapper created
- [ ] All wrappers show deprecation warning
- [ ] All wrappers call new `/specter` command

**Implementation**:
```bash
# For each old command, create wrapper:
# echo "⚠️ DEPRECATED: Use '/specter X' instead"
# /specter X "$@"
```

---

#### T009: Write migration guide [P]
**Description**: Create comprehensive migration guide for v2.1 → v3.0
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: T008
**Acceptance Criteria**:
- [ ] File `docs/MIGRATION-V2-TO-V3.md` created
- [ ] Command mapping table included
- [ ] Migration script documented
- [ ] Common issues covered
- [ ] Timeline for deprecation clear

**Implementation**:
```bash
# Write migration guide based on plan.md
```

---

## Phase 2: Token Optimization (2 weeks, 80 hours)

### P2.1: Lazy Loading Infrastructure (16 hours)

#### T010: Implement lazy loading mechanism
**Description**: Create infrastructure for on-demand loading of skills
**Priority**: P1
**Effort**: 16 hours
**Dependencies**: T001
**Acceptance Criteria**:
- [ ] Function `load_skill()` implemented
- [ ] Tracks loaded skills in associative array
- [ ] Only loads skill once
- [ ] Lazy loads SKILL.md by default
- [ ] `--examples` flag loads EXAMPLES.md
- [ ] `--reference` flag loads REFERENCE.md

**Implementation**:
```bash
# Add to hub command:
declare -A SPECTER_SKILLS_LOADED

load_skill() {
  local skill=$1
  if [[ ! -v SPECTER_SKILLS_LOADED[$skill] ]]; then
    source "$SPECTER_ROOT/skills/$skill/SKILL.md"
    SPECTER_SKILLS_LOADED[$skill]=1
  fi
}
```

---

### P2.2: Skill Reorganization (44 hours)

#### T011: Split specter-init into tiers
**Description**: Reorganize specter-init into SKILL.md / EXAMPLES.md / REFERENCE.md
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] SKILL.md contains core logic only (~200 lines)
- [ ] EXAMPLES.md contains usage examples (~100 lines)
- [ ] REFERENCE.md contains full API docs (~150 lines)
- [ ] All three files validated

---

#### T012: Split specter-specify into tiers [P]
**Description**: Reorganize specter-specify into three tiers
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] SKILL.md core only (~250 lines)
- [ ] EXAMPLES.md examples (~150 lines)
- [ ] REFERENCE.md API docs (~200 lines)

---

#### T013: Split specter-plan into tiers [P]
**Description**: Reorganize specter-plan into three tiers
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] SKILL.md core only (~200 lines)
- [ ] EXAMPLES.md examples (~100 lines)
- [ ] REFERENCE.md API docs (~150 lines)

---

#### T014: Split specter-tasks into tiers [P]
**Description**: Reorganize specter-tasks into three tiers
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] SKILL.md core only (~180 lines)
- [ ] EXAMPLES.md examples (~120 lines)
- [ ] REFERENCE.md API docs (~150 lines)

---

#### T015: Split specter-implement into tiers [P]
**Description**: Reorganize specter-implement into three tiers
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] SKILL.md core only (~220 lines)
- [ ] EXAMPLES.md examples (~130 lines)
- [ ] REFERENCE.md API docs (~180 lines)

---

#### T016: Merge specter-clarify into specter-specify [P]
**Description**: Consolidate clarify skill into specify as a sub-step
**Priority**: P2
**Effort**: 6 hours
**Dependencies**: T012
**Acceptance Criteria**:
- [ ] Clarify logic integrated into specify
- [ ] Auto-invoked when ambiguities detected
- [ ] Old specter-clarify skill removed
- [ ] Tests updated

---

#### T017: Merge specter-update into specter-specify [P]
**Description**: Consolidate update skill into specify as variant
**Priority**: P2
**Effort**: 6 hours
**Dependencies**: T012
**Acceptance Criteria**:
- [ ] Update logic integrated into specify
- [ ] `--update` flag added
- [ ] Old specter-update skill removed
- [ ] Tests updated

---

#### T018: Merge specter-blueprint into specter-init [P]
**Description**: Consolidate blueprint into init workflow
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T011
**Acceptance Criteria**:
- [ ] Blueprint generation part of init
- [ ] Old specter-blueprint skill removed
- [ ] Tests updated

---

#### T019: Merge specter-checklist into specter-specify [P]
**Description**: Consolidate checklist into specify validation
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T012
**Acceptance Criteria**:
- [ ] Checklist validation in specify
- [ ] Auto-invoked before finalizing spec
- [ ] Old specter-checklist skill removed

---

#### T020: Merge specter-discover into specter-init [P]
**Description**: Consolidate discover into init for brownfield projects
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T011
**Acceptance Criteria**:
- [ ] Discover logic in init
- [ ] `--brownfield` flag added
- [ ] Old specter-discover skill removed

---

### P2.3: Token Measurement & Validation (20 hours)

#### T021: Create token measurement tool [P]
**Description**: Build tool to measure token usage of commands
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T010
**Acceptance Criteria**:
- [ ] Script `scripts/measure-tokens.sh` created
- [ ] Measures tokens for each command
- [ ] Compares to baseline (v2.1)
- [ ] Outputs reduction percentage
- [ ] CI integration possible

**Implementation**:
```bash
#!/bin/bash
# measure-tokens.sh
# Use tiktoken or approximate (1 token ≈ 4 chars)
```

---

#### T022: Validate 80% token reduction [P]
**Description**: Verify that token reduction target is met
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T021, T011-T020
**Acceptance Criteria**:
- [ ] All skills measured
- [ ] Hub command measured
- [ ] Total < 20,000 tokens per invocation
- [ ] Reduction ≥ 80% vs v2.1
- [ ] Documented in metrics

**Implementation**:
```bash
./scripts/measure-tokens.sh /specter
# Should show < 2,500 tokens for typical use
```

---

#### T023: Optimize state templates [P]
**Description**: Reduce size of state file templates
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Templates < 500 lines each
- [ ] Removed redundant sections
- [ ] Clearer structure
- [ ] Still human-readable

---

## Phase 3: State Management Evolution (1.5 weeks, 60 hours)

### P3.1: JSON Schema Design (8 hours)

#### T024: Design session.json schema
**Description**: Create JSON schema for session state
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Schema file `schemas/session.schema.json` created
- [ ] All fields documented
- [ ] Validation rules defined
- [ ] Example provided

---

#### T025: Design workflow.json schema [P]
**Description**: Create JSON schema for workflow memory
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Schema file `schemas/workflow.schema.json` created
- [ ] Feature tracking fields
- [ ] Metrics fields
- [ ] Validation rules

---

### P3.2: JSON ↔ Markdown Generators (16 hours)

#### T026: Implement session JSON → MD generator
**Description**: Generate current-session.md from session.json
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T024
**Acceptance Criteria**:
- [ ] Function `generate_session_md()` created
- [ ] Reads session.json
- [ ] Outputs formatted markdown
- [ ] Preserves all information
- [ ] Human-readable output

**Implementation**:
```bash
generate_session_md() {
  jq -r '...' .specter-state/session.json > .specter-state/current-session.md
}
```

---

#### T027: Implement session MD → JSON parser [P]
**Description**: Parse current-session.md into session.json
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T024
**Acceptance Criteria**:
- [ ] Function `parse_session_md()` created
- [ ] Parses markdown structure
- [ ] Outputs valid JSON
- [ ] Round-trip validation passes
- [ ] Handles edge cases

---

### P3.3: Auto-Migration Tool (12 hours)

#### T028: Create v2.1 → v3.0 migration script
**Description**: Auto-migrate existing v2.1 state to v3.0
**Priority**: P1
**Effort**: 12 hours
**Dependencies**: T026, T027
**Acceptance Criteria**:
- [ ] Script `scripts/migrate-v2-to-v3.sh` created
- [ ] Creates backup before migration
- [ ] Converts all .md files to .json
- [ ] Regenerates .md from .json
- [ ] Validates round-trip
- [ ] Rollback available

**Implementation**: See plan.md Appendix D

---

### P3.4: State Read/Write Updates (16 hours)

#### T029: Update state readers to use JSON
**Description**: Modify all state-reading code to use JSON
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T024, T025
**Acceptance Criteria**:
- [ ] All skills read from .json files
- [ ] Fallback to .md if .json missing
- [ ] Error handling for invalid JSON
- [ ] Performance acceptable

---

#### T030: Update state writers to use JSON [P]
**Description**: Modify all state-writing code to use JSON + regen MD
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T026, T029
**Acceptance Criteria**:
- [ ] All skills write to .json files
- [ ] Auto-regenerate .md after write
- [ ] Atomic writes (temp file + mv)
- [ ] Validation before commit

---

### P3.5: Validation & Testing (8 hours)

#### T031: Create state validation tests [P]
**Description**: Test suite for JSON ↔ MD round-trip
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T026, T027
**Acceptance Criteria**:
- [ ] Test file `tests/test-state-json.sh` created
- [ ] Round-trip validation tests
- [ ] Merge conflict tests
- [ ] Edge case tests
- [ ] All tests passing

---

## Phase 4: Team Collaboration (1 week, 40 hours)

### P4.1: Feature Locking (20 hours)

#### T032: Implement file-based locking
**Description**: Create feature lock/unlock functions
**Priority**: P1
**Effort**: 12 hours
**Dependencies**: T024
**Acceptance Criteria**:
- [ ] Function `specter_lock_feature()` created
- [ ] Function `specter_unlock_feature()` created
- [ ] Lock file in `.specter-state/locks/`
- [ ] JSON format with metadata
- [ ] Returns error if already locked

**Implementation**: See plan.md ADR-005

---

#### T033: Add TTL and PID tracking [P]
**Description**: Auto-expire stale locks and detect dead processes
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T032
**Acceptance Criteria**:
- [ ] TTL field in lock file (default 2h)
- [ ] PID field in lock file
- [ ] Check TTL before failing lock
- [ ] Check PID exists before failing
- [ ] Auto-remove stale locks
- [ ] Force unlock available

---

### P4.2: Task Assignment (8 hours)

#### T034: Implement task assignment system [P]
**Description**: Add @username assignments to tasks
**Priority**: P2
**Effort**: 8 hours
**Dependencies**: T024
**Acceptance Criteria**:
- [ ] Task JSON includes `assignedTo` field
- [ ] `/specter assign @user T001` command
- [ ] Validation that user exists (git config)
- [ ] Unassign capability
- [ ] Show assignments in status

**Implementation**:
```bash
specter_assign_task() {
  local task_id=$1
  local user=$2
  jq ".tasks[] | select(.id == \"$task_id\") | .assignedTo = \"$user\"" \
    .specter-state/session.json
}
```

---

### P4.3: Team Dashboard (8 hours)

#### T035: Build team status dashboard [P]
**Description**: Create `/specter team` command showing team status
**Priority**: P2
**Effort**: 8 hours
**Dependencies**: T032, T034
**Acceptance Criteria**:
- [ ] Command `/specter team` implemented
- [ ] Shows active locks
- [ ] Shows task assignments
- [ ] Shows feature progress
- [ ] Shows team member activity
- [ ] Formatted output (table/chart)

**Implementation**: See plan.md ADR-005 team_status()

---

### P4.4: Documentation (4 hours)

#### T036: Write team collaboration docs [P]
**Description**: Document team features and best practices
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T032, T034, T035
**Acceptance Criteria**:
- [ ] File `docs/TEAM-COLLABORATION.md` created
- [ ] Locking workflow documented
- [ ] Task assignment workflow documented
- [ ] Best practices included
- [ ] Troubleshooting guide
- [ ] Examples provided

---

## Phase 5: Master Spec & Polish (1.5 weeks, 60 hours)

### P5.1: Master Spec Generation (24 hours)

#### T037: Implement master spec generator
**Description**: Create aggregation engine for master spec
**Priority**: P1
**Effort**: 16 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Function `specter_generate_master_spec()` created
- [ ] Aggregates from all sources
- [ ] Proper markdown formatting
- [ ] Includes all features
- [ ] Includes decisions, metrics
- [ ] Output to `.specter/master-spec.md`

**Implementation**: See plan.md ADR-006

---

#### T038: Add auto-regeneration triggers [P]
**Description**: Trigger master spec regen at appropriate times
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: T037
**Acceptance Criteria**:
- [ ] Regenerates after `/specter specify`
- [ ] Regenerates after task completion
- [ ] Manual trigger `/specter master-spec`
- [ ] Optional pre-commit hook
- [ ] Performance acceptable (< 2s)

---

### P5.2: Testing Suite (16 hours)

#### T039: Create unit test suite
**Description**: Comprehensive unit tests for all functions
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: All implementation tasks
**Acceptance Criteria**:
- [ ] Directory `tests/unit/` created
- [ ] Router tests
- [ ] Lazy loading tests
- [ ] State JSON tests
- [ ] Locking tests
- [ ] Master spec tests
- [ ] Coverage > 80%

---

#### T040: Create integration test suite [P]
**Description**: End-to-end workflow tests
**Priority**: P1
**Effort**: 8 hours
**Dependencies**: All implementation tasks
**Acceptance Criteria**:
- [ ] Directory `tests/integration/` created
- [ ] Full workflow test (init → implement)
- [ ] Team collaboration test
- [ ] Migration test
- [ ] Backward compat test
- [ ] All tests passing

---

### P5.3: Performance Optimization (8 hours)

#### T041: Performance profiling [P]
**Description**: Profile command execution and optimize bottlenecks
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T039, T040
**Acceptance Criteria**:
- [ ] Profiling script created
- [ ] Bottlenecks identified
- [ ] Optimization opportunities documented
- [ ] Baseline performance recorded

---

#### T042: Performance optimization [P]
**Description**: Implement performance improvements
**Priority**: P2
**Effort**: 4 hours
**Dependencies**: T041
**Acceptance Criteria**:
- [ ] Command execution < 2s
- [ ] Memory usage < 100MB
- [ ] Lazy loading effective
- [ ] Benchmarks documented

---

### P5.4: Documentation (12 hours)

#### T043: Update README.md [P]
**Description**: Update main README for v3.0
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] v3.0 features documented
- [ ] Installation instructions updated
- [ ] Quick start updated
- [ ] Examples use new `/specter` command
- [ ] Migration guide linked

---

#### T044: Update USER-GUIDE.md [P]
**Description**: Update comprehensive user guide for v3.0
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] All commands updated
- [ ] Team features documented
- [ ] Master spec documented
- [ ] Examples use new syntax
- [ ] Screenshots updated

---

#### T045: Update TROUBLESHOOTING.md [P]
**Description**: Add v3.0 troubleshooting entries
**Priority**: P2
**Effort**: 2 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] Common v3.0 issues added
- [ ] Migration issues covered
- [ ] Team collaboration issues
- [ ] Solutions provided

---

#### T046: Create CHANGELOG.md [P]
**Description**: Document all v3.0 changes
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: None
**Acceptance Criteria**:
- [ ] File `CHANGELOG.md` created
- [ ] All v3.0 changes listed
- [ ] Breaking changes highlighted
- [ ] Migration path clear
- [ ] Follows keep-a-changelog format

---

## Pre-Commit Validation (8 hours)

### T047: Final integration testing [P]
**Description**: Complete end-to-end testing before commit
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: All tasks
**Acceptance Criteria**:
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Performance benchmarks met
- [ ] Documentation accurate
- [ ] No critical bugs

---

### T048: Create release notes [P]
**Description**: Write v3.0.0 release notes
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: T046
**Acceptance Criteria**:
- [ ] File `docs/RELEASE-NOTES-V3.md` created
- [ ] Highlights key features
- [ ] Breaking changes clear
- [ ] Migration guide linked
- [ ] Credits contributors

---

### T049: Version bump and tagging [P]
**Description**: Update version to 3.0.0 and create git tag
**Priority**: P1
**Effort**: 1 hour
**Dependencies**: T047, T048
**Acceptance Criteria**:
- [ ] Version in all files updated to 3.0.0
- [ ] Git tag `v3.0.0` created
- [ ] Tag annotated with release notes
- [ ] Marketplace metadata updated

---

### T050: Final documentation review [P]
**Description**: Comprehensive review of all documentation
**Priority**: P1
**Effort**: 1 hour
**Dependencies**: T043-T046
**Acceptance Criteria**:
- [ ] All docs reviewed
- [ ] No broken links
- [ ] Consistent formatting
- [ ] Examples work
- [ ] Screenshots current

---

## Rollout Tasks (Post-Implementation)

### T051: Alpha release preparation
**Description**: Prepare for internal alpha testing
**Priority**: P1
**Effort**: 2 hours
**Dependencies**: T049
**Acceptance Criteria**:
- [ ] Alpha build created
- [ ] Test environment set up
- [ ] Feedback mechanism ready
- [ ] Known issues documented

---

### T052: Beta release preparation
**Description**: Prepare for public beta
**Priority**: P1
**Effort**: 3 hours
**Dependencies**: T051
**Acceptance Criteria**:
- [ ] Beta build created
- [ ] Beta tester list ready
- [ ] Feedback survey created
- [ ] Support channels set up

---

### T053: GA release preparation
**Description**: Prepare for general availability
**Priority**: P1
**Effort**: 4 hours
**Dependencies**: T052
**Acceptance Criteria**:
- [ ] Final build created
- [ ] Marketplace submission ready
- [ ] Announcement drafted
- [ ] Support documentation complete

---

## Summary

### Task Breakdown by Phase
| Phase | Tasks | Hours | Parallelization |
|-------|-------|-------|-----------------|
| P1: Command Consolidation | T001-T009 | 80 | Low (sequential routing) |
| P2: Token Optimization | T010-T023 | 80 | High (skills independent) |
| P3: State Management | T024-T031 | 60 | Medium (schema → code) |
| P4: Team Collaboration | T032-T036 | 40 | Medium (locking + UI) |
| P5: Master Spec & Polish | T037-T050 | 60 | High (docs + tests) |
| **TOTAL** | **50 tasks** | **320 hours** | - |

**Note**: Original estimate was 240 hours, but detailed breakdown reveals 320 hours (33% increase due to granularity). Recommend:
- 6 weeks with 2 developers (160h each)
- OR 8 weeks with 1 developer (40h/week)
- OR 4 weeks with 3 developers (parallel phases)

### Critical Path
```
T001 (router) → T002 (context) → T003 (routing) → T010 (lazy loading) →
T011-T020 (skill reorg) → T024-T027 (JSON) → T028 (migration) →
T029-T030 (state updates) → T037 (master spec) → T039-T040 (tests) →
T047-T050 (validation)
```

**Critical Path Duration**: ~180 hours (parallelization saves ~140 hours)

### Parallelization Opportunities

**Phase 2**: T011-T020 (all skills can be reorganized in parallel)
**Phase 3**: T026, T027 can be done concurrently
**Phase 4**: T034, T035, T036 independent
**Phase 5**: T043-T046 (all docs) + T039-T040 (tests) can run in parallel

### Risk Mitigation Tasks

**High Priority**:
- T021, T022: Token measurement early to catch overruns
- T028: Migration testing to prevent data loss
- T031: State validation to prevent corruption

**Medium Priority**:
- T033: TTL/PID to prevent lock deadlocks
- T039-T040: Comprehensive testing to catch regressions

---

## Next Steps

1. **Review tasks**: Ensure all requirements covered
2. **Assign tasks**: Distribute among team members
3. **Begin Phase 1**: Start with T001 (router creation)
4. **Daily standups**: Track progress and blockers
5. **Weekly reviews**: Adjust timeline as needed

---

**Tasks Created**: 2024-10-31
**Ready for**: Implementation
**Estimated Start**: 2024-11-01
**Estimated Completion**: 2024-12-20 (7 weeks with 1 FTE)

---

*Generated by Specter Task Breakdown System*
*Next: `/specter implement` to begin execution*
