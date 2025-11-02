# Changes Planned

Tracks planned changes from all active features.

---

## Feature 001: Comprehensive Refactoring

**Total Tasks**: 60+ subtasks across 9 epics
**Estimated**: 100 hours
**Priority Breakdown**: 32h P0, 40h P1, 20h P2, 8h P3

### Priority 0 (Launch Blockers) - 32 hours

**Epic 1: Documentation Consistency** (16h)
- [ ] ST-1.1.x: Rewrite quick-start.md (8h)
- [ ] ST-1.2.x: Update all examples to /workflow:spec (7.5h)
- [ ] ST-1.3.x: Remove premature migration docs (3h)

**Epic 2: State Management** (8h)
- [ ] ST-2.1.x: Create state file templates (3h)
- [ ] ST-2.2.x: Update init/guide.md to create state files (3.5h)
- [ ] ST-2.3.x: Implement state update logic in guides (2.5h)

**Epic 4: Command Implementation** (8h)
- [ ] ST-4.1.x: Implement menu system in workflow:spec (6.5h)
- [ ] ST-4.2.x: Implement state detection logic (1.5h)

### Priority 1 (High) - 40 hours

**Epic 3: Token Optimization** (8h)
- [ ] ST-3.1.x: Delete blueprint examples duplication (1h)
- [ ] ST-3.2.x: Trim orchestrate examples (1h)
- [ ] ST-3.3.x: Remove redundant state reads (3h)
- [ ] ST-3.4.x: Clean deprecated command references (2.25h)

**Epic 5: Guide Refactoring** (16h)
- [ ] ST-5.1.x: Extract TDD documentation (2.5h)
- [ ] ST-5.2.x: Extract hook setup docs (2h)
- [ ] ST-5.3.x: Trim command files (3h)
- [ ] ST-5.4.x: Update CLAUDE.md (3.5h)

**Epic 6: Auto-Mode & Checkpoints** (16h)
- [ ] ST-6.1.x: Design checkpoint system (4h)
- [ ] ST-6.2.x: Implement phase orchestration (6h)
- [ ] ST-6.3.x: Test auto-mode (4h)

### Priority 2 (Medium) - 20 hours

**Epic 7: Configuration Enhancement** (12h)
- [ ] ST-7.1.x: Document path interpolation (2h)
- [ ] ST-7.2.x: Implement config validation (6.5h)

**Epic 9: Final Testing** (8h)
- [ ] ST-9.1.x: Execute all test scenarios (5h)
- [ ] ST-9.2.x: Production ready validation (3h)

### Priority 3 (Polish) - 8 hours

**Epic 8: Reference Trimming** (8h)
- [ ] ST-8.1.x: Trim all reference.md files (8h)

---

## Files to Modify

**High Impact** (40 files):
- .claude/skills/workflow/quick-start.md
- .claude/commands/workflow:spec.md
- .claude/commands/workflow:track.md
- All 13 phases/*/guide.md files
- 15+ examples.md and reference.md files
- .claude/.spec-config.yml
- CLAUDE.md

**Templates to Create** (5 files):
- templates/state/current-session.md.template
- templates/state/WORKFLOW-PROGRESS.md.template
- templates/state/DECISIONS-LOG.md.template
- templates/state/CHANGES-PLANNED.md.template
- templates/state/CHANGES-COMPLETED.md.template

---

## Risk Mitigation

**Breaking Changes**: None expected (pre-launch, no users)
**Rollback Plan**: All changes in git, can revert per-file
**Testing**: Manual validation after each epic
**Approval Gates**: After Week 1 (P0), Week 2 (P1), Week 3 (Complete)
