# Planned Changes

**Project**: Spec Plugin v3.3 Refactoring
**Created**: 2025-11-03
**Last Updated**: 2025-11-03

Post-launch enhancements and optional improvements for future iterations.

---

## Summary

- **Total Planned Changes**: 7
- **P1 (Should Have)**: 2
- **P2 (Nice to Have)**: 5
- **Blocked**: 0

**Note**: All P0 (Must Have) changes are complete. These are post-launch enhancements.

---

## Priority 1 (Should Have)

### CHG-P7: Configuration Documentation

**Phase**: Phase 7 (Deferred)
**Priority**: P1
**Estimated Effort**: S (30 minutes)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Create user-facing documentation for `.spec-config.yml` format and customization options.

#### Acceptance Criteria
- [ ] Document all config fields and their purposes
- [ ] Provide examples of common customizations
- [ ] Explain variable interpolation system
- [ ] Show how to override defaults
- [ ] Include troubleshooting section

#### Technical Notes
- Config already works (session-init hook auto-generates)
- Just needs user documentation
- Could be part of README or separate CONFIG.md
- Reference existing examples in hook code

#### Related
- **Blocks**: None
- **Blocked By**: None
- **Related To**: README.md, session-init hook

---

### CHG-P8: Reference File Trimming

**Phase**: Phase 8 (Deferred)
**Priority**: P1
**Estimated Effort**: M (2 hours)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Trim 13 reference.md files to reduce token usage by additional 5-10K tokens.

#### Acceptance Criteria
- [ ] Analyze all 13 reference.md files for redundancy
- [ ] Identify sections to extract/condense
- [ ] Apply progressive disclosure pattern
- [ ] Verify functionality preserved
- [ ] Measure token savings achieved

#### Technical Notes
- Target: 5-10K additional token savings
- Use same approach as Phase 3 (link instead of duplicate)
- Focus on examples and verbose explanations
- Keep technical specifications intact

#### Files to Trim
1. `phases/1-initialize/init/reference.md`
2. `phases/1-initialize/discover/reference.md`
3. `phases/1-initialize/blueprint/reference.md`
4. `phases/2-define/generate/reference.md`
5. `phases/2-define/clarify/reference.md`
6. `phases/2-define/checklist/reference.md`
7. `phases/3-design/plan/reference.md`
8. `phases/3-design/analyze/reference.md`
9. `phases/4-build/tasks/reference.md`
10. `phases/4-build/implement/reference.md`
11. `phases/5-track/metrics/reference.md`
12. `phases/5-track/update/reference.md`
13. `phases/5-track/orchestrate/reference.md`

#### Related
- **Blocks**: None
- **Blocked By**: None
- **Related To**: CHG-005 (Token Optimization)

---

## Priority 2 (Nice to Have)

### CHG-E1: Config Validation in Init

**Priority**: P2
**Estimated Effort**: S (30 minutes)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Add validation to init/guide.md to check if config exists before proceeding.

#### Acceptance Criteria
- [ ] Check if `.spec-config.yml` exists
- [ ] Validate config is well-formed YAML
- [ ] Verify required fields present
- [ ] Provide helpful error messages
- [ ] Auto-fix common issues

#### Technical Notes
- Currently session-init hook auto-creates config
- This adds defensive validation
- Improves error handling for edge cases

---

### CHG-E2: Better Error Messages

**Priority**: P2
**Estimated Effort**: M (1 hour)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Enhance error messages throughout workflow with more context and actionable suggestions.

#### Acceptance Criteria
- [ ] Review all error paths in guides
- [ ] Add context to error messages
- [ ] Provide suggested fixes
- [ ] Link to troubleshooting docs
- [ ] Test common error scenarios

#### Technical Notes
- Focus on most common user errors
- Add examples of what went wrong and how to fix
- Consider adding error codes for easy reference

---

### CHG-E3: Progress Indicators

**Priority**: P2
**Estimated Effort**: S (30 minutes)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Add progress indicators during long-running operations (init, generate, implement).

#### Acceptance Criteria
- [ ] Show "Initializing..." during init
- [ ] Show "Generating specification..." during generate
- [ ] Show "Implementing task X/Y..." during implement
- [ ] Use spinner or progress bar
- [ ] Don't interfere with checkpoints

#### Technical Notes
- Simple text indicators may be sufficient
- Could use emoji for visual appeal
- Should appear before operation, disappear after

---

### CHG-E4: Init Rollback

**Priority**: P2
**Estimated Effort**: M (1 hour)
**Dependencies**: CHG-E1
**Added**: 2025-11-03

#### Description
If initialization fails, automatically clean up partial state to avoid corrupted setup.

#### Acceptance Criteria
- [ ] Track what was created during init
- [ ] On error, remove created directories/files
- [ ] Log what was cleaned up
- [ ] Ask user before deleting anything
- [ ] Don't delete user files

#### Technical Notes
- Create cleanup function in init/guide.md
- Only delete files we created (not existing files)
- Use try/catch or error handling in guide
- Requires CHG-E1 for proper error detection

---

### CHG-E5: TDD Documentation Extraction

**Priority**: P2
**Estimated Effort**: M (1 hour)
**Dependencies**: None
**Added**: 2025-11-03

#### Description
Extract TDD mode documentation to shared file to reduce duplication across guides.

#### Acceptance Criteria
- [ ] Create `phases/shared/tdd-mode.md`
- [ ] Document 3 enforcement levels (strict, balanced, flexible)
- [ ] Explain integration points with each phase
- [ ] Update guides to reference shared doc
- [ ] Remove redundant TDD sections

#### Technical Notes
- Currently mentioned in 4+ guides
- ~400 tokens potential savings
- Improves maintainability (single source)
- Part of original Phase 5 scope (deferred)

---

## Change History

### Recently Deferred
- CHG-P7: Configuration Documentation (from Phase 7)
- CHG-P8: Reference File Trimming (from Phase 8)

### Recently Completed
See CHANGES-COMPLETED.md for full audit trail of v3.3 refactoring.

---

## Notes

All P0 (Must Have) changes are complete for v3.3 launch. These planned changes are enhancements that can be completed post-launch based on:

1. **User Feedback**: Real usage patterns and pain points
2. **Token Budget**: How critical further optimization becomes
3. **Team Capacity**: Available time for improvements
4. **Priority**: Impact vs effort analysis

None of these changes block v3.3 production launch.

---

*Maintained by Spec Workflow System*
*Post-launch enhancement backlog*
