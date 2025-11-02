# Implementation Plan: Comprehensive Codebase Refactoring

**Branch**: `refactor/comprehensive-v3.3-cleanup` | **Feature**: 001 | **Spec**: `.spec/features/001-comprehensive-refactoring/spec.md`

## Summary

Comprehensive refactoring to align documentation with implementation, implement missing state management, optimize token usage by 66%, and prepare v3.3 for production launch. Technical approach combines systematic documentation updates, state management implementation, strategic token reduction, and workflow enhancement.

## Technical Context

**Language**: TypeScript/Markdown | **Dependencies**: None (documentation + templates) | **Storage**: File system
**Testing**: Manual workflow validation | **Platform**: Claude Code plugin | **Type**: Plugin refactoring
**Performance**: Token optimization (115K → 40K worst-case) | **Constraints**: No breaking changes | **Scale**: 60+ files

## Project Artifacts

References (flat peer model, user approval required to modify):
- **Analysis**: `COMPREHENSIVE-ANALYSIS.md` (full technical breakdown)
- **UX Analysis**: `UX-ANALYSIS.md`, `UX-ANALYSIS-FLOWCHARTS.md`, `UX-ANALYSIS-INDEX.md`
- **Configuration**: `.claude/.spec-config.yml`
- **Documentation**: `CLAUDE.md`, `README.md`, `quick-start.md`

**MISSING ARTIFACTS** (must be created before implementation):
- **Product Requirements**: `.spec/product-requirements.md` - NOT FOUND
- **Architecture Blueprint**: `.spec/architecture-blueprint.md` - NOT FOUND

**GUARD**: Phase 0 (Pre-Implementation) must create these artifacts before any other work begins.

## Blueprint Alignment

**Architecture Pattern**: Command → (Missing Dispatcher) → Phase Guides - **MISALIGNED**
- Issue: Commands describe "workflow skill" invocation but no dispatcher exists
- Fix: Either implement dispatcher or have commands directly load guides

**Documentation Stack**: Markdown + YAML + Templates - **ALIGNED**
- Template system exists and functional
- Just needs to be used consistently

**State Management**: Dual-layer (session + memory) - **PARTIALLY ALIGNED**
- Design is good, implementation missing
- Templates don't exist, state files not created on init

**Token Strategy**: Progressive disclosure (guide → examples → reference) - **MISALIGNED**
- Design excellent, execution wasteful
- Examples too verbose, references duplicated

**Deviations** (user approval required):
| Deviation | Reason | Alternative |
|-----------|--------|-------------|
| No workflow skill dispatcher | Commands reference it but doesn't exist | Implement OR remove abstraction |
| Inline TDD docs | Loaded even when disabled | Extract to separate file |
| Duplicated templates | Blueprint examples = full template | Link to templates/ instead |

## Project Structure

**Documentation**:
```
.spec/features/001-comprehensive-refactoring/
├── spec.md      # Feature specification (THIS REFACTORING)
├── plan.md      # This file (technical plan)
└── tasks.md     # Task breakdown (TO BE CREATED)
```

**Source Files** (files to modify):
```
Priority 0 (Launch Blockers):
.claude/skills/workflow/quick-start.md          # Complete rewrite
.claude/commands/workflow:spec.md               # Add menu implementation
.claude/commands/workflow:track.md              # Add menu implementation
.claude/skills/workflow/phases/1-initialize/init/guide.md  # Add state file creation
+ 15 example files (update commands)

Priority 1 (High):
.claude/skills/workflow/phases/1-initialize/blueprint/examples.md  # Delete duplication
.claude/skills/workflow/phases/5-track/orchestrate/examples.md     # Trim to 1-2 examples
All 13 phases/*/guide.md                        # Remove redundant state reads
10 files with spec:specify                      # Global find-replace
3 files with migration notes                    # Remove

Priority 2 (Medium):
.claude/skills/workflow/phases/4-build/implement/guide.md  # Extract TDD docs
.claude/skills/workflow/phases/1-initialize/init/guide.md  # Extract hook docs
.claude/.spec-config.yml                        # Add header comments
CLAUDE.md                                       # Update config section

Priority 3 (Polish):
13 reference.md files                           # Trim by 60%
.claude/skills/workflow/SKILL.md                # Rename to README.md
```

**Templates to Create**:
```
.claude/skills/workflow/templates/state/
├── current-session.md.template
├── WORKFLOW-PROGRESS.md.template
├── DECISIONS-LOG.md.template
├── CHANGES-PLANNED.md.template
└── CHANGES-COMPLETED.md.template
```

## Implementation Strategy

**CRITICAL**: This plan includes explicit **AskUserQuestion checkpoints** at every decision point to ensure human oversight throughout implementation.

### Checkpoint Protocol

**After every phase, story, and significant task**, I will:
1. ✅ Present completion summary
2. ❓ Use AskUserQuestion with options:
   - **Continue** → Proceed to next step
   - **Review** → Show what was done, allow inspection
   - **Refine** → Make adjustments before continuing
   - **Pause** → Stop here, save state, resume later

**Never proceed without user confirmation via AskUserQuestion.**

---

### Phase 0: Pre-Implementation (PREREQUISITE - 4 hours)

**Goal**: Create missing Product Requirements and Architecture Blueprint before starting implementation

**GUARD**: This phase MUST complete successfully before any other phase. If these artifacts don't exist, implementation cannot proceed.

**Checkpoint**: Before starting Phase 0
- Present: Missing artifacts (PRD, Blueprint), need for creation
- Ask: "Create Product Requirements and Architecture Blueprint?"
- Options: Start Phase 0 / Review what's needed / Use existing docs / Pause

**Approach**:

**Step 0.1: Create Product Requirements Document** (2 hours)
   - Use template: `.claude/skills/workflow/templates/project-setup/product-requirements-template.md`
   - Document: v3.3 goals, user needs, success criteria
   - Content:
     - Vision: Spec-driven development for Claude Code
     - Target Users: Developers using Claude Code plugin
     - Key Features: State management, interactive menus, token optimization
     - Success Metrics: 0% error rate, 66% token reduction, 9/10 production score
     - Constraints: No breaking changes (pre-launch)
     - Timeline: 100 hours over 3 weeks

**Checkpoint**: After PRD created
- Present: Product Requirements document content
- Ask: "PRD created at .spec/product-requirements.md. Continue?"
- Options: Continue to blueprint / Review PRD / Refine PRD / Pause

**Step 0.2: Create Architecture Blueprint** (2 hours)
   - Use template: `.claude/skills/workflow/templates/project-setup/architecture-blueprint-template.md`
   - Document: System architecture, component relationships, data flow
   - Content:
     - Architecture Pattern: Command → State Detection → AskUserQuestion Menus → Phase Guides
     - Components: Commands (2), Phase Guides (13), Templates (state, artifacts), State Management (dual-layer)
     - Data Flow: User → /workflow:spec → state read → menu display → guide execution → state update
     - Tech Stack: Markdown, YAML, Claude Code plugin system
     - Integration Points: Templates, State files, Memory files, Config

**Checkpoint**: After Blueprint created
- Present: Architecture Blueprint document content
- Ask: "Blueprint created at .spec/architecture-blueprint.md. Continue?"
- Options: Continue to Phase 1 / Review blueprint / Refine blueprint / Pause

**Phase 0 Complete Checkpoint**:
- Present: PRD and Blueprint created, all prerequisites met
- Ask: "Phase 0: Pre-Implementation complete. Ready for Phase 1?"
- Options: Continue to Phase 1 (Documentation) / Review artifacts / Refine artifacts / Commit / Pause

**Validation**:
- [ ] `.spec/product-requirements.md` exists and complete
- [ ] `.spec/architecture-blueprint.md` exists and complete
- [ ] Both documents reference spec.md and analysis reports
- [ ] Ready to proceed to Phase 1

---

### Phase 1: Documentation Emergency (Week 1, Days 1-2, 16 hours)

**Goal**: Fix documentation time-travel problem immediately

**Checkpoint**: Before starting Phase 1
- Present: Phase 1 goals, files to modify, expected outcomes
- Ask: "Ready to start Phase 1: Documentation Emergency?"
- Options: Start / Review plan first / Skip to different phase / Pause

**Approach**:

**Step 1.1: Rewrite quick-start.md** (8 hours)
   - Document current system: /workflow:spec with menus
   - Remove all /spec-* command references (40+ occurrences)
   - Update decision tree, examples, troubleshooting
   - Add menu navigation instructions

**Checkpoint**: After quick-start.md rewrite
- Present: Diff of changes, new structure, command examples
- Ask: "Quick-start.md rewritten. What would you like to do?"
- Options: Continue to examples / Review rewrite / Refine quick-start / Pause

**Step 1.2: Update all examples** (8 hours)
   - Search: `grep -r "/spec-" .claude/skills/workflow/`
   - Replace pattern:
     ```markdown
     OLD: /spec generate "feature"
     NEW: /workflow:spec → Select "Define Feature" → Enter "feature"
     ```
   - Files: 15+ examples.md and guide.md files
   - Validate each replacement in context

**Checkpoint**: After examples updated
- Present: List of files modified, grep verification results
- Ask: "All examples updated to /workflow:spec. Continue?"
- Options: Continue to Phase 2 / Review changes / Refine examples / Pause

**Technical Decisions**:
- Quick-start follows user journey (first-time → returning → auto-mode)
- Menu instructions use visual format: "Select X → Select Y → Enter Z"
- Examples show both interactive and auto-mode approaches
- All code blocks tested for accuracy

**Validation**:
- Manual walkthrough of quick-start guide
- 0 grep results for deprecated commands
- CLAUDE.md and quick-start.md alignment check

**Phase 1 Complete Checkpoint**:
- Present: Summary of all documentation fixes, metrics (files changed, lines updated)
- Ask: "Phase 1: Documentation Emergency complete. Next step?"
- Options: Continue to Phase 2 (State Management) / Review all changes / Refine any docs / Commit changes / Pause

---

### Phase 2: State Management (Week 1, Day 3, 8 hours)

**Goal**: Make state management actually work

**Checkpoint**: Before starting Phase 2
- Present: Phase 2 goals, templates to create, init changes needed
- Ask: "Ready to start Phase 2: State Management?"
- Options: Start / Review Phase 1 first / Skip to different phase / Pause

**Approach**:

**Step 2.1: Create state file templates** (3 hours)
   ```markdown
   templates/state/current-session.md.template:
   ---
   feature: null
   phase: null
   started: null
   last_updated: null
   ---
   # Current Session

   **Status**: No active feature
   **Last Activity**: [timestamp]

   ## Feature
   None

   ## Phase
   None

   ## Progress
   No tasks in progress
   ```
   - Create all 5 template files
   - Follow existing template patterns
   - Include helpful comments

**Checkpoint**: After templates created
- Present: All 5 template files with content preview
- Ask: "State templates created. Continue?"
- Options: Continue to init update / Review templates / Refine templates / Pause

**Step 2.2: Update init/guide.md** (3 hours)
   - Add step to copy templates to .spec/state/ and .spec/memory/
   - Use bash commands or Edit tool
   - Verify directory creation first
   - Update .gitignore if needed

**Checkpoint**: After init/guide.md updated
- Present: Diff of init/guide.md changes, new steps added
- Ask: "Init guide updated to create state files. Continue?"
- Options: Continue to testing / Review changes / Refine init guide / Pause

**Step 2.3: Test state creation** (2 hours)
   - Manual test: run init process
   - Verify all files created
   - Check file contents valid
   - Test state read operations

**Checkpoint**: After state testing
- Present: Test results, state files created, validation passed
- Ask: "State management tested and working. Continue?"
- Options: Continue to Phase 3 / Review state files / Fix issues / Pause

**Phase 2 Complete Checkpoint**:
- Present: Summary of state management implementation, templates created, init updated
- Ask: "Phase 2: State Management complete. Next step?"
- Options: Continue to Phase 3 (Command Implementation) / Review all changes / Commit changes / Pause

**Technical Decisions**:
- Use YAML frontmatter + Markdown body for state files (consistent with spec.md pattern)
- Templates in `.claude/skills/workflow/templates/state/`
- Copy operation in init guide, not hooks (simpler, more transparent)
- State files use null for empty values (clear vs missing)

**Validation**:
- .spec/state/ contains current-session.md after init
- .spec/memory/ contains all 4 memory files
- Files have valid structure (YAML + Markdown)
- No init errors

---

### Phase 3: Command Implementation (Week 1, Day 4, 8 hours)

**Goal**: Implement menu system described in commands

**Checkpoint**: Before starting Phase 3
- Present: Phase 3 goals, command files to modify, menu designs
- Ask: "Ready to start Phase 3: Command Implementation?"
- Options: Start / Review Phase 2 first / Skip to different phase / Pause

**Approach**:

**Step 3.1: Add AskUserQuestion implementation** (4 hours)
   - workflow:spec.md currently describes menus
   - Add explicit tool calls in Implementation section:
     ```markdown
     ## Implementation

     ### Step 1: Detect State
     I'll check if .spec/ exists and read current-session.md

     [Use Read tool, handle file not found]

     ### Step 2: Present Menu
     I'll use AskUserQuestion with context-specific options:

     [Use AskUserQuestion tool with state-based options]

     ### Step 3: Execute Selection
     Based on user's choice, I'll load the appropriate phase guide:

     [Use Read tool to load guide, execute instructions]
     ```

**Checkpoint**: After AskUserQuestion implementation
- Present: Diff of workflow:spec.md changes, new menu logic
- Ask: "Menu implementation added to command. Continue?"
- Options: Continue to state detection / Review implementation / Refine menus / Pause

**Step 3.2: Add state detection logic** (2 hours)
   - Check .spec/ directory exists
   - Try to read .spec/state/current-session.md
   - Parse YAML frontmatter
   - Determine menu based on state
   - Handle errors gracefully

**Checkpoint**: After state detection logic
- Present: State detection code, error handling flows
- Ask: "State detection logic added. Continue?"
- Options: Continue to testing / Review logic / Refine detection / Pause

**Step 3.3: Test menu system** (2 hours)
   - Test: no .spec/ → initialization menu
   - Test: .spec/ exists, no feature → new feature menu
   - Test: feature in progress → resume menu
   - Test: feature complete → validation menu

**Checkpoint**: After menu testing
- Present: Test results for all menu states
- Ask: "Menu system tested and working. Continue?"
- Options: Continue to Phase 4 / Review tests / Fix issues / Pause

**Phase 3 Complete Checkpoint**:
- Present: Summary of command implementation, menus functional, state detection working
- Ask: "Phase 3: Command Implementation complete. Next step?"
- Options: Continue to Phase 4 (Token Optimization) / Review all changes / Commit changes / Pause

**Technical Decisions**:
- State detection happens first, before menu
- Graceful fallback if state file corrupted
- Menus are exhaustive (all valid next steps)
- Each menu option maps to specific phase guide

**Validation**:
- AskUserQuestion displays appropriate menus
- State changes trigger different menus
- All menu paths functional

---

### Phase 4: Token Optimization Quick Wins (Week 1, Day 5, 8 hours)

**Goal**: Reduce token usage by 50%+ with minimal effort

**Checkpoint**: Before starting Phase 4
- Present: Phase 4 goals, files to optimize, expected token savings (27,933 tokens)
- Ask: "Ready to start Phase 4: Token Optimization?"
- Options: Start / Review Phase 3 first / Skip to different phase / Pause

**Approach**:
1. **Delete blueprint/examples.md duplication** (1 hour)
   - Current: 15,392 tokens (entire blueprint template)
   - Target: 500 tokens (link to template)
   - Edit file to:
     ```markdown
     # Blueprint Examples

     See the complete blueprint template:
     `templates/project-setup/architecture-blueprint-template.md`

     ## Quick Example
     [One concise example showing template usage]
     ```

2. **Trim orchestrate/examples.md** (1 hour)
   - Current: 7 examples, 9,841 tokens
   - Target: 2 examples, 2,000 tokens
   - Keep: Example 1 (simple) and Example 7 (complex)
   - Delete: Examples 2-6 (redundant)

3. **Remove redundant state reads** (3 hours)
   - Pattern: `Read {config.paths.state}/current-session.md`
   - Files: All 13 guide.md files
   - Replace with: "State is passed from command as context"
   - Update guide frontmatter if needed

4. **Clean deprecated references** (2 hours)
   - `spec:specify` → `workflow:spec (generate phase)` (30+ occurrences)
   - Remove migration notes from reference.md files
   - Clean hooks/src/hooks/session/restore-session.ts

**Checkpoint**: After each optimization step
- After blueprint deletion: Present token savings, ask to continue
- After orchestrate trim: Present token savings, ask to continue
- After state reads removed: Present grep results, ask to continue
- After deprecated refs cleaned: Present grep results, ask to continue

5. **Validation** (1 hour)
   - Token count verification
   - Grep for deprecated patterns
   - Manual spot checks

**Phase 4 Complete Checkpoint**:
- Present: Total token savings achieved (~27,933 tokens), files modified, grep verification
- Ask: "Phase 4: Token Optimization complete. Next step?"
- Options: Continue to Phase 5 (Guide Refactoring) / Review changes / Commit changes / Week 1 summary / Pause

**Technical Decisions**:
- Optimize high-impact files first (blueprint, orchestrate)
- State read removal is safe (violates current design anyway)
- Keep 1-2 examples per component (not 7)
- Links > duplication

**Expected Savings**:
- Blueprint: -14,892 tokens (91%)
- Orchestrate: -7,841 tokens (71%)
- State reads: -5,200 tokens (400/phase × 13)
- **Total: -27,933 tokens in 8 hours**

---

### Phase 5: Guide Refactoring (Week 2, Days 1-2, 16 hours)

**Goal**: Extract conditional content to reduce base token usage

**Checkpoint**: Before starting Phase 5
- Present: Phase 5 goals, extraction targets (TDD, hooks), expected savings (6,900 tokens)
- Ask: "Ready to start Phase 5: Guide Refactoring?"
- Options: Start / Review Week 1 progress / Skip to different phase / Pause

**Approach**:
1. **Extract TDD documentation** (3 hours)
   - Source: implement/guide.md lines 47-323 (277 lines)
   - Destination: `implement/tdd-guide.md`
   - Keep in guide: 1 paragraph about TDD mode, link to tdd-guide.md
   - Progressive disclosure: "For TDD details, ask to load tdd-guide.md"

2. **Extract hook setup** (3 hours)
   - Source: init/guide.md lines 106-348 (243 lines)
   - Destination: `init/hooks-setup-guide.md` or `init/reference.md`
   - Keep in guide: High-level hook auto-detection flow
   - Move: Bash scripts, template generation, detailed logic

3. **Update guide cross-references** (2 hours)
   - Update any guides referencing extracted content
   - Add "See also" sections with links
   - Update navigation/workflow-map.md

4. **Test extracted guides** (2 hours)
   - Verify base guides still functional
   - Test loading extracted guides on demand
   - Measure token reduction

5. **Trim command files** (3 hours)
   - workflow:spec.md: 2,100 → 750 tokens
   - Remove: Verbatim menu text, duplicate examples
   - Keep: High-level flow, 1 example per menu

6. **Update CLAUDE.md** (3 hours)
   - Remove command description duplication
   - Update with lessons learned
   - Document new patterns (state passing, progressive disclosure)

**Checkpoint**: After each extraction
- After TDD extraction: Present new files, token savings, ask to continue
- After hook extraction: Present new files, token savings, ask to continue
- After command trimming: Present diffs, token savings, ask to continue
- After CLAUDE.md update: Present changes, ask to continue

**Expected Savings**:
- TDD extraction: -2,000 tokens (when disabled)
- Hook extraction: -1,200 tokens
- Command trimming: -2,700 tokens
- CLAUDE.md: -1,000 tokens
- **Total: -6,900 tokens**

**Phase 5 Complete Checkpoint**:
- Present: All extractions complete, files created, token savings achieved
- Ask: "Phase 5: Guide Refactoring complete. Next step?"
- Options: Continue to Phase 6 (Auto-Mode) / Review changes / Commit changes / Week 2 Day 2 summary / Pause

---

### Phase 6: Auto-Mode & Checkpoints (Week 2, Days 3-4, 16 hours)

**Goal**: Implement auto-mode with checkpoints as described

**Checkpoint**: Before starting Phase 6
- Present: Phase 6 goals, checkpoint system design, orchestration logic
- Ask: "Ready to start Phase 6: Auto-Mode & Checkpoints?"
- Options: Start / Review Phase 5 first / Skip to different phase / Pause

**Approach**:
1. **Design checkpoint system** (4 hours)
   - After each phase: AskUserQuestion with "Continue / Refine / Review / Exit"
   - Store checkpoint state in current-session.md
   - Resume logic: detect last checkpoint, offer continuation

2. **Implement phase orchestration** (8 hours)
   - Loop: execute phase → checkpoint → next phase
   - Phase order: init → generate → plan → tasks → implement
   - Conditional phases: clarify (if [CLARIFY] tags), analyze (if requested)
   - Progress tracking: update state after each phase

3. **Test auto-mode** (4 hours)
   - Full workflow: init through implement
   - Exit at checkpoint, resume
   - Refine at checkpoint, continue
   - Error mid-phase, recovery

**Checkpoint**: After each step
- After checkpoint design: Present state machine diagram, ask to continue
- After orchestration implementation: Present code, ask to test
- After auto-mode testing: Present test results, ask to continue

**Technical Decisions**:
- Checkpoints are blocking (require user input)
- State updated before and after each phase
- Exit preserves state for resume
- Refine re-runs current phase

**Phase 6 Complete Checkpoint**:
- Present: Auto-mode functional, checkpoint system working, test results
- Ask: "Phase 6: Auto-Mode & Checkpoints complete. Next step?"
- Options: Continue to Phase 7 (Configuration) / Review changes / Commit changes / Week 2 Day 4 summary / Pause

---

### Phase 7: Configuration & Validation (Week 2, Day 5 + Week 3, Day 1, 12 hours)

**Goal**: Make config robust and well-documented

**Checkpoint**: Before starting Phase 7
- Present: Phase 7 goals, config enhancements, validation requirements
- Ask: "Ready to start Phase 7: Configuration & Validation?"
- Options: Start / Review Phase 6 first / Skip to different phase / Pause

**Approach**:
1. **Add config comments** (2 hours)
   - Header explaining interpolation syntax
   - Inline comments for each section
   - Examples of custom paths

2. **Implement validation** (6 hours)
   - Schema definition (YAML comment schema or validation code)
   - Validation logic in init or hooks
   - Error messages with suggestions
   - Example: "spec_root must be relative path, got '/absolute'"

3. **Test validation** (2 hours)
   - Test invalid configs
   - Verify helpful errors
   - Test edge cases

4. **Document in CLAUDE.md** (2 hours)
   - Expand config section
   - Show path resolution examples
   - Document variable interpolation rules

**Checkpoint**: After each step
- After config comments: Present updated config file, ask to continue
- After validation implementation: Present validation code, ask to test
- After testing: Present test results, ask to continue
- After CLAUDE.md update: Present changes, ask to continue

**Phase 7 Complete Checkpoint**:
- Present: Config documented and validated, test results, CLAUDE.md updated
- Ask: "Phase 7: Configuration & Validation complete. Next step?"
- Options: Continue to Phase 8 (Reference Trimming) / Review changes / Commit changes / Week 3 Day 1 summary / Pause

---

### Phase 8: Reference Trimming (Week 3, Day 2, 8 hours)

**Goal**: Trim all reference.md files by 60%

**Checkpoint**: Before starting Phase 8
- Present: Phase 8 goals, 13 reference files to trim, expected savings (22,426 tokens)
- Ask: "Ready to start Phase 8: Reference Trimming?"
- Options: Start / Review Phase 7 first / Skip to different phase / Pause

**Approach**:
1. **Systematic reduction** (6 hours)
   - For each reference.md (13 files):
     - Remove algorithmic pseudocode (keep high-level only)
     - Remove duplicated schema definitions (link to config)
     - Condense examples
     - Target: 1,500 → 600 tokens each

2. **Validation** (2 hours)
   - Ensure essential information preserved
   - Check token counts
   - Verify links work

**Checkpoint**: Progress checkpoints
- After 5 files trimmed: Present progress (5/13), token savings so far, ask to continue
- After 10 files trimmed: Present progress (10/13), cumulative savings, ask to continue
- After all 13 files: Present final savings, ask to validate

**Expected Savings**: -22,426 tokens (60% reduction)

**Phase 8 Complete Checkpoint**:
- Present: All reference files trimmed, total token savings, essential content preserved
- Ask: "Phase 8: Reference Trimming complete. Next step?"
- Options: Continue to Phase 9 (Final Testing) / Review changes / Commit changes / Week 3 Day 2 summary / Pause

---

### Phase 9: Final Testing & Polish (Week 3, Day 3, 8 hours)

**Goal**: Validate all scenarios pass

**Checkpoint**: Before starting Phase 9
- Present: Phase 9 goals, test scenarios, validation checklist
- Ask: "Ready to start Phase 9: Final Testing & Polish?"
- Options: Start / Review Phase 8 first / Run tests / Pause

**Test Scenarios** (from spec.md):
1. First-time user completes workflow ✓
2. Returning user resumes work ✓
3. Auto-mode executes with checkpoints ✓
4. Token efficiency < 2,500/phase ✓
5. Configuration validation works ✓

**Checkpoint**: After each test scenario
- After scenario 1: Present test results, ask to continue
- After scenario 2: Present test results, ask to continue
- After scenario 3: Present test results, ask to continue
- After scenario 4: Present token measurements, ask to continue
- After scenario 5: Present validation results, ask to continue

**Validation Checklist**:
- [ ] All P0 issues resolved
- [ ] Documentation consistent (CLAUDE.md = quick-start.md)
- [ ] 0 deprecated command references
- [ ] State management functional
- [ ] Token savings achieved (50%+)
- [ ] All test scenarios pass

**Final Checkpoint**: Production Ready Decision
- Present: Complete summary of all 9 phases, metrics achieved, production ready score (2/10 → 9/10)
- Ask: "All phases complete! What would you like to do?"
- Options:
  - **Declare Production Ready** → Mark v3.3 ready for launch
  - **Review Complete Implementation** → Walk through all changes
  - **Create Launch Checklist** → Prepare deployment steps
  - **Commit All Changes** → Git commit with comprehensive message
  - **Additional Polish** → Continue refinements

---

## Architectural Decision Records (ADRs)

### ADR-001: State Passed from Commands, Not Re-Read in Guides

**Context**: Guides currently re-read state files, wasting tokens.

**Decision**: Commands read state once, pass to guides as context.

**Rationale**:
- Eliminates redundant reads (400 tokens/phase)
- Aligns with stated architecture (CLAUDE.md:129)
- Simpler mental model

**Implementation**: Remove Read calls from guides, document state passing convention.

---

### ADR-002: Progressive Disclosure via Extraction, Not Inline

**Context**: Implement/guide.md has 277 lines of TDD docs loaded unconditionally.

**Decision**: Extract conditional content to separate files, load on demand.

**Rationale**:
- Base guide stays lean (< 1,000 tokens)
- Users get details only when needed
- Follows progressive disclosure principle

**Implementation**: Extract to implement/tdd-guide.md, add "See also" link.

---

### ADR-003: Template Links over Duplication

**Context**: blueprint/examples.md duplicates entire 15K token template.

**Decision**: Replace with link to templates/ directory.

**Rationale**:
- Single source of truth
- Massive token savings (91%)
- Users get same information via link

**Implementation**: Edit blueprint/examples.md to 500-token link + brief example.

---

### ADR-004: Remove Workflow Skill Abstraction (For Now)

**Context**: Commands reference "workflow skill" but no dispatcher exists.

**Decision**: Commands directly Read and execute phase guides.

**Rationale**:
- Simpler implementation
- Matches current reality
- Can add dispatcher later if needed

**Alternative**: Implement workflow skill dispatcher (8 hours additional work).

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Breaking existing workflows | High | Low | No users yet (pre-launch) |
| Token optimization too aggressive | Medium | Low | Keep 1-2 examples, preserve essentials |
| State management bugs | High | Medium | Thorough testing, fallback to fresh init |
| Documentation still inconsistent | High | Low | Systematic review, validation checklist |
| Timeline overrun | Medium | Medium | Prioritized approach (P0 first) |

---

## Dependencies

**External**:
- None (all internal plugin files)

**Internal**:
- Phase 2 (state management) blocks Phase 3 (command implementation)
- Phase 1 (documentation) can run parallel to others
- Phase 4 (token optimization) independent
- Phases 5-8 can overlap

**Critical Path**: P0 issues (documentation + state + commands) = 32 hours

---

## Testing Strategy

**Unit Level**: Manual validation of each file change
- Does quick-start guide work step-by-step?
- Do menus display correctly?
- Are tokens actually reduced?

**Integration Level**: Full workflow testing
- New user: init → generate → plan → tasks → implement
- Returning user: resume from checkpoint
- Auto-mode: full automation with checkpoints

**Regression**: Ensure existing functionality preserved
- Templates still work
- Existing features unaffected
- No new errors introduced

---

## Success Metrics (from spec.md)

- **SC-001**: New user completes workflow without errors (0% error rate)
- **SC-002**: Token usage reduced by 50%+ (target: 66%)
- **SC-003**: 0 deprecated command references (grep verification)
- **SC-004**: State management functional (all scenarios pass)
- **SC-005**: All 5 test scenarios pass
- **SC-006**: Production ready: 2/10 → 9/10

**Measurement**:
- Token counts: before/after comparison via token counter
- Command references: `grep -r "/spec-\|spec:specify" .claude/`
- Test scenarios: manual checklist
- Production ready: subjective assessment against criteria

---

## Rollback Plan

If critical issues found:

1. **Documentation**: Revert quick-start.md to previous version
2. **State Management**: Remove state file creation from init (graceful degradation)
3. **Token Optimization**: Keep old examples temporarily
4. **Command Implementation**: Commands remain aspirational (document future work)

All changes are in version control, can revert per-file.

---

## Post-Implementation

**Documentation**:
- Update CHANGELOG.md with v3.3 refactoring notes
- Update README.md if needed
- Archive old documentation in docs/archive/

**Monitoring**:
- Track user feedback after launch
- Monitor token usage in practice
- Watch for state management issues

**Future Enhancements** (out of scope):
- Workflow skill dispatcher implementation
- Multi-feature support
- Enhanced error recovery
- Automated testing

---

## Timeline Summary

| Week | Days | Tasks | Hours | Priority |
|------|------|-------|-------|----------|
| **Pre** | **0.5** | **Phase 0: PRD + Blueprint** | **4** | **GUARD** |
| 1 | 1-2 | Documentation Emergency | 16 | P0 |
| 1 | 3 | State Management | 8 | P0 |
| 1 | 4 | Command Implementation | 8 | P0 |
| 1 | 5 | Token Quick Wins | 8 | P1 |
| 2 | 1-2 | Guide Refactoring | 16 | P1 |
| 2 | 3-4 | Auto-Mode | 16 | P1 |
| 2 | 5 + 3:1 | Config & Validation | 12 | P2 |
| 3 | 2 | Reference Trimming | 8 | P3 |
| 3 | 3 | Testing & Polish | 8 | All |

**Total**: 104 hours (~2.6 weeks with 1 engineer, ~1.6 weeks with 2 engineers)

**CRITICAL PATH**: Phase 0 (PRD + Blueprint) MUST complete before any other work begins.

---

## Approval Gates

**After Week 1** (P0 complete):
- Review: Documentation fixed, state management working, commands functional
- Decision: Proceed to P1 or launch with P0 only

**After Week 2** (P1 complete):
- Review: Token optimization achieved, auto-mode working
- Decision: Launch or polish with P2/P3

**After Week 3** (All complete):
- Final review: All scenarios pass
- Decision: Launch v3.3

---

**Plan complete. Ready to proceed to tasks.md breakdown.**
