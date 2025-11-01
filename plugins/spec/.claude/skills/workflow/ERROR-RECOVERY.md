# Error Recovery Guide

**Troubleshooting guide for common Spec workflow issues**

---

## Table of Contents

1. [Common Problems](#common-problems)
2. [Error Messages](#error-messages)
3. [State Recovery](#state-recovery)
4. [Function-Specific Issues](#function-specific-issues)
5. [Integration Problems](#integration-problems)
6. [Performance Issues](#performance-issues)
7. [Prevention Tips](#prevention-tips)

---

## Common Problems

### Problem 1: Stuck in Clarify with Too Many Questions

**Symptoms**:
- `/spec clarify` asks 4 questions
- Still have [CLARIFY] tags remaining
- Want to proceed but can't resolve everything

**Why This Happens**:
- Clarify runs max 4 questions per session (by design)
- Complex features may have 8+ ambiguities
- Some questions need more context to answer

**Solution A: Skip and Continue** ⭐ **Recommended**
```bash
# Continue workflow with remaining [CLARIFY] tags
/spec plan

# [CLARIFY] tags stay in spec.md
# Can return to clarify later after seeing plan
```

**Solution B: Run Clarify Multiple Times**
```bash
# First session: 4 questions answered
/spec clarify

# Review results, then second session
/spec clarify

# Repeat until all resolved
```

**Solution C: Manual Resolution**
```bash
# Edit spec.md directly
# Replace [CLARIFY: question] with actual decision
# Document decision in .spec-memory/DECISIONS-LOG.md
```

**Prevention**:
- Be specific in initial feature description
- Research similar features before generating spec
- Use `--max-questions=8` flag if you know you'll have many

**When to Use Each**:
- **Solution A**: Most cases - context from plan helps answer questions
- **Solution B**: When you can answer questions now
- **Solution C**: When you already know the answer

---

### Problem 2: Implementation Failed Midway

**Symptoms**:
- `/spec implement` was running
- Error occurred or session interrupted
- Tasks partially complete (e.g., 3/12 done)
- Need to resume

**Why This Happens**:
- Code errors during implementation
- Test failures blocking progress
- Session timeout or manual interruption
- Dependency issues

**Solution A: Resume Implementation** ⭐ **Recommended**
```bash
# Check current state
/spec status

# Resume from where you left off
/spec implement --continue

# Will skip completed tasks, continue with next pending
```

**Solution B: Restart Specific Task**
```bash
# If specific task failed
/spec implement --task=T005

# Runs T005 and all subsequent tasks
```

**Solution C: Review and Fix**
```bash
# 1. Check what failed
cat .spec-state/current-session.md

# 2. Look at error logs
cat .spec-state/implementation-errors.log

# 3. Fix code manually
# 4. Mark task complete
/spec implement --mark-complete=T005

# 5. Continue
/spec implement --continue
```

**Prevention**:
- Run `/spec validate` before implement
- Ensure all tests pass before starting
- Create checkpoints: commit after each task
- Use `--parallel=false` for sequential execution (safer)

---

### Problem 3: Requirements Changed Mid-Implementation

**Symptoms**:
- Already have spec.md, plan.md, tasks.md
- Some tasks complete
- Requirements now different

**Why This Happens**:
- Stakeholder feedback
- Market changes
- Technical discoveries
- User feedback

**Solution: Update and Propagate** ⭐ **Recommended**
```bash
# 1. Update specification with changes
/spec update "New requirements description"

# 2. Validate impact
/spec analyze

# Review analysis report - shows affected tasks

# 3. Update task breakdown
/spec tasks --update

# 4. Continue implementation
/spec implement --continue
```

**Solution: Full Regeneration** (if massive changes)
```bash
# 1. Archive current work
mv features/003-feature features/003-feature.old

# 2. Start fresh
/spec generate "Revised feature description"
/spec plan
/spec tasks
/spec implement

# 3. Salvage code from old implementation if applicable
```

**When to Use Each**:
- **Update**: Requirements tweaked (80% same)
- **Regeneration**: Complete pivot (less than 50% same)

---

### Problem 4: Don't Know Where I Am in Workflow

**Symptoms**:
- Unsure what phase you're in
- Don't know what to run next
- Lost track of progress

**Solution: Check Status** ⭐ **Always Start Here**
```bash
/spec status
```

**Output Shows**:
```
📍 Current Location: Phase 3 (Design Solution)
🎯 Active Feature: #003-user-authentication
✅ Completed: init, generate, clarify
⏳ Current: plan (in progress)
→ Next: spec:tasks (after plan complete)

Available in this phase:
- /spec plan - Create technical plan (IN PROGRESS)
- /spec analyze - Validate consistency

Need more detail? Read phases/3-design/README.md
```

**Additional Context**:
```bash
# View detailed progress
/spec metrics

# See complete workflow
"Show me the workflow map"
# Or read navigation/workflow-map.md
```

---

### Problem 5: Session State Corrupted or Lost

**Symptoms**:
- `.spec-state/current-session.md` missing or corrupted
- Workflow doesn't recognize current feature
- "Session not found" errors

**Solution A: Restore from Checkpoint** ⭐ **If checkpoints exist**
```bash
# List available checkpoints
ls .spec-state/checkpoints/

# Restore most recent
cp .spec-state/checkpoints/latest.md .spec-state/current-session.md

# Verify restoration
/spec status
```

**Solution B: Reconstruct from Artifacts**
```bash
# 1. Check what artifacts exist
ls features/003-*/

# 2. Manually create session state
cat > .spec-state/current-session.md << 'EOF'
## Active Work
### Current Feature
- **Feature ID**: 003
- **Feature Name**: user-authentication
- **Phase**: [determine from artifacts: specification/planning/implementation]
- **Started**: [today's date]

## Workflow Progress
### Completed Phases
- [x] spec:init
- [x] spec:generate (spec.md exists)
- [x] spec:plan (plan.md exists)
- [ ] spec:tasks (tasks.md missing)
EOF

# 3. Resume workflow
/spec tasks  # Or whatever next step is
```

**Solution C: Start Fresh** (last resort)
```bash
# Archive old state
mv .spec-state .spec-state.backup

# Reinitialize
/spec init

# Manually restore feature context
# Copy artifacts from features/ back into place
```

**Prevention**:
- Commit .spec-memory/ regularly (not .spec-state/)
- Use checkpoints: workflow creates them automatically
- Back up before major changes

---

### Problem 6: Validation Fails with Errors

**Symptoms**:
- `/spec validate` or `/spec analyze` reports errors
- Issues categorized as CRITICAL, HIGH, MEDIUM, LOW
- Not sure how to fix

**Solution: Prioritize by Severity** ⭐ **Fix Critical First**
```bash
# 1. Run validation
/spec analyze

# 2. Review report - focus on CRITICAL first
```

**Sample Report**:
```
## CRITICAL Issues (Must Fix)
- [spec.md:45] User story US2.1 has no acceptance criteria
  FIX: Add specific, measurable criteria

- [plan.md:78] API endpoint /api/users missing authentication
  FIX: Add authentication requirement to API contract

## HIGH Priority (Should Fix)
- [tasks.md:23] Task T008 has circular dependency with T012
  FIX: Reorder tasks to break circular dependency

## MEDIUM Priority (Consider Fixing)
- [spec.md:89] Vague term "fast" without definition
  FIX: Add [CLARIFY: Define "fast" - response time SLA?]
```

**Fix Process**:
```bash
# 1. Fix CRITICAL issues manually
# Edit spec.md, plan.md, tasks.md directly

# 2. Re-validate
/spec analyze

# 3. If still issues, ask for help
"How do I fix [specific error]?"

# 4. Once CRITICAL clear, continue workflow
/spec implement
```

**Common Validation Errors**:

| Error | Fix |
|-------|-----|
| Missing acceptance criteria | Add measurable criteria to user story |
| Circular task dependencies | Reorder tasks, break cycles |
| Unresolved [CLARIFY] tags | Run `/spec clarify` or resolve manually |
| Missing API authentication | Add auth requirements to plan.md |
| Vague requirements | Add [CLARIFY] or be specific |
| Task missing dependencies | Add `→ T001` dependency notation |

---

### Problem 7: Want to Restart a Phase

**Symptoms**:
- Completed a phase (e.g., plan)
- Result unsatisfactory
- Want to regenerate

**Solution: Regenerate Specific Artifact**
```bash
# Backup current version
cp features/003-auth/plan.md features/003-auth/plan.md.backup

# Regenerate
/spec plan --force

# Will recreate plan.md with fresh research
```

**Solution: Manual Edit Then Continue**
```bash
# Edit the artifact directly
# Make changes to spec.md, plan.md, or tasks.md

# Update dependent artifacts
/spec tasks --update    # If edited spec or plan
/spec analyze           # Validate changes

# Continue workflow
/spec implement
```

**When to Regenerate vs Edit**:
- **Regenerate**: Fundamentally wrong approach, need fresh start
- **Edit**: Small tweaks, specific corrections

---

### Problem 8: Tests Keep Failing During Implementation

**Symptoms**:
- `/spec implement` runs tests
- Tests fail repeatedly
- Implementation blocks on test failures

**Solution A: Fix Tests** ⭐ **Recommended**
```bash
# 1. Check test output
cat .spec-state/test-results.log

# 2. Fix failing tests manually
# Debug and correct code

# 3. Verify tests pass
npm test  # or pytest, go test, etc.

# 4. Resume implementation
/spec implement --continue
```

**Solution B: Skip Tests Temporarily** (not recommended)
```bash
# Only for prototyping/POC
/spec implement --skip-tests

# MUST fix tests before merging
```

**Solution C: Update Test Strategy**
```bash
# If tests are wrong, update plan
# Edit plan.md → Testing Strategy section

# Regenerate tasks with new strategy
/spec tasks --update

# Continue implementation
/spec implement --continue
```

**Prevention**:
- Define clear testing strategy in plan phase
- Write tests incrementally (TDD approach)
- Ensure test environment set up correctly
- Use `/spec analyze` to catch issues early

---

### Problem 9: Running Out of Context (Token Limit)

**Symptoms**:
- "Context window full" messages
- Slow responses
- Unable to load large artifacts

**Solution A: Use Progressive Disclosure** ⭐ **Recommended**
```bash
# Load only what you need
/spec plan                    # Guide only (~1,500 tokens)

# Don't use --examples unless needed
# Don't use --reference unless needed
```

**Solution B: Clear Context**
```bash
# Start new conversation
# State loaded from .spec-state/ automatically

"Continue my workflow from where I left off"
# Workflow will read state and resume
```

**Solution C: Summarize State**
```bash
# Create compact summary
/spec status --compact

# Work with summaries instead of full artifacts
```

**Prevention**:
- Don't load --examples by default
- Use status commands instead of reading full files
- Start fresh conversations for new phases
- Leverage state files (workflow remembers context)

---

## Error Messages

### "Session state not found"

**Full Message**:
```
Error: Session state not found
.spec-state/current-session.md does not exist
```

**Meaning**: Workflow not initialized in this project

**Fix**:
```bash
/spec init
```

**Details**: Must run init before any other workflow commands

---

### "Feature not found: ###"

**Full Message**:
```
Error: Feature not found: 003
features/003-* directory does not exist
```

**Meaning**: Trying to work on non-existent feature

**Fix**:
```bash
# Check existing features
ls features/

# If feature should exist, check feature ID
# Might be 002 or 004, not 003

# If starting new feature
/spec generate "Feature description"
```

---

### "Circular dependency detected"

**Full Message**:
```
Error: Circular dependency detected in tasks.md
T003 → T005 → T007 → T003
```

**Meaning**: Task dependencies form a loop

**Fix**:
```bash
# Edit tasks.md manually
# Remove or reorder dependencies to break loop

# Example: Change
# T003 → T005
# T005 → T007
# T007 → T003

# To:
# T003 (no dependencies)
# T005 → T003
# T007 → T005

# Validate fix
/spec analyze
```

---

### "Validation failed: [FIELD] required"

**Full Message**:
```
Validation failed: spec.md
Error: User story US2.3 missing acceptance criteria (required)
```

**Meaning**: Required section missing from artifact

**Fix**:
```bash
# Edit spec.md
# Find US2.3
# Add acceptance criteria:

**Acceptance Criteria:**
- [ ] Specific criterion 1
- [ ] Specific criterion 2
- [ ] Edge case handled

# Re-validate
/spec validate
```

---

### "Integration error: [SERVICE] not configured"

**Full Message**:
```
Integration error: JIRA not configured
SPEC_JIRA_PROJECT_KEY not found in CLAUDE.md
```

**Meaning**: External integration referenced but not set up

**Fix**:
```bash
# Add configuration to CLAUDE.md
echo "SPEC_JIRA_PROJECT_KEY=PROJ" >> CLAUDE.md

# Or disable integration
# Remove JIRA references from workflow
```

**Details**: Integrations are optional, can skip if not needed

---

### "Cannot resolve [CLARIFY] tags"

**Full Message**:
```
Warning: Cannot resolve [CLARIFY] tags
2 unresolved ambiguities in spec.md
```

**Meaning**: Ambiguities still present in spec

**Fix (Option 1)**: Resolve ambiguities
```bash
/spec clarify
```

**Fix (Option 2)**: Continue with ambiguities
```bash
# They're warnings, not blocking errors
# Can continue workflow
/spec plan

# Resolve later when you have more context
```

---

## State Recovery

### Checkpoint System

**Checkpoints Created**:
- After each phase completion
- Every 30 minutes during long-running tasks
- Before potentially destructive operations

**Checkpoint Location**: `.spec-state/checkpoints/`

**Restore Checkpoint**:
```bash
# List checkpoints
ls -lt .spec-state/checkpoints/

# View checkpoint
cat .spec-state/checkpoints/2025-11-01-14-30.md

# Restore specific checkpoint
cp .spec-state/checkpoints/2025-11-01-14-30.md .spec-state/current-session.md

# Verify
/spec status
```

---

### Manual State Recovery

**If no checkpoints available:**

```bash
# 1. Determine what artifacts exist
ls features/003-*/
# Outputs: spec.md, plan.md, tasks.md (if they exist)

# 2. Determine current phase from artifacts
# - spec.md only → Phase 2 complete
# - + plan.md → Phase 3 complete
# - + tasks.md → Phase 4 (ready to implement)

# 3. Reconstruct session state
cat > .spec-state/current-session.md << 'EOF'
## Active Work
### Current Feature
- **Feature ID**: 003
- **Feature Name**: [name from spec.md]
- **Phase**: [determined from artifacts above]
- **Started**: [today's date]

## Workflow Progress
### Completed Phases
- [x] spec:init
- [x] spec:generate
- [x] spec:plan
- [ ] spec:tasks
- [ ] spec:implement
EOF

# 4. Continue workflow from current phase
/spec tasks  # Or whatever is next
```

---

### Recovery from Git

**If you have committed .spec-memory/:**

```bash
# View workflow progress from memory
cat .spec-memory/WORKFLOW-PROGRESS.md

# View decisions made
cat .spec-memory/DECISIONS-LOG.md

# Reconstruct state from memory files
# Use workflow progress to determine current phase
# Use decisions log to understand context
```

---

## Function-Specific Issues

### init/ Issues

**Problem**: "Directory already exists"
```bash
Error: .spec/ directory already exists
Cannot initialize - already initialized
```

**Fix**: Already initialized, proceed to generate
```bash
/spec generate "Feature"
```

**Problem**: "Cannot create directories"
```bash
Error: Permission denied creating .spec/
```

**Fix**: Check permissions
```bash
# Check current directory permissions
ls -la

# Ensure you have write access
chmod u+w .

# Retry
/spec init
```

---

### generate/ Issues

**Problem**: "Spec already exists for this feature"
```bash
Error: features/003-auth/spec.md already exists
```

**Fix (Option 1)**: Update existing spec
```bash
/spec update "Changes to requirements"
```

**Fix (Option 2)**: Force regenerate
```bash
/spec generate "Feature" --force
```

**Fix (Option 3)**: Create new feature
```bash
/spec generate "Different feature description"
# Will create 004-* instead
```

---

### clarify/ Issues

**Problem**: "No [CLARIFY] tags found"
```bash
Warning: No [CLARIFY] tags found in spec.md
Nothing to clarify
```

**Fix**: Normal - means spec is clear
```bash
# Continue to next phase
/spec plan
```

**Problem**: "Cannot answer without more context"
```bash
Clarify question: "What is acceptable response time?"
User response: "I don't know"
```

**Fix**: Skip and research
```bash
# Leave [CLARIFY] tag for now
# Continue workflow
/spec plan

# Plan phase will include research on acceptable response times
# Can return to clarify later
```

---

### plan/ Issues

**Problem**: "No spec.md found"
```bash
Error: No specification found
Cannot create plan without spec.md
```

**Fix**: Create spec first
```bash
/spec generate "Feature description"
# Then
/spec plan
```

**Problem**: "Research failed"
```bash
Warning: Web research failed for "best practices X"
Continuing with cached knowledge only
```

**Fix**: Not blocking, can continue
```bash
# Plan will still be created
# Just won't have latest research

# Or retry with better search terms
/spec plan --research-query="specific search terms"
```

---

### tasks/ Issues

**Problem**: "Plan incomplete or missing sections"
```bash
Error: plan.md missing API Contracts section
Cannot generate accurate tasks
```

**Fix**: Complete plan first
```bash
# Edit plan.md manually
# Add missing sections

# Re-validate
/spec analyze

# Then retry
/spec tasks
```

**Problem**: "Too many tasks generated"
```bash
Warning: Generated 45 tasks
This may be too granular
```

**Fix**: Review and consolidate
```bash
# Edit tasks.md
# Combine related micro-tasks
# Keep 10-25 tasks for most features

# Example: Combine
# T001: Create User model
# T002: Add User validation
# T003: Add User methods

# Into:
# T001: Implement User model with validation and methods
```

---

### implement/ Issues

**Problem**: "Task depends on incomplete task"
```bash
Error: Cannot execute T005
Dependency T003 not complete
```

**Fix**: Complete dependency first
```bash
# Execute dependency
/spec implement --task=T003

# Then continue
/spec implement --continue
```

**Problem**: "Parallel execution failed"
```bash
Error: Task T007 failed in parallel execution
```

**Fix**: Run sequentially
```bash
# Disable parallel execution
/spec implement --parallel=false

# Or fix specific task
# Review error in T007
# Fix code
# Retry
/spec implement --continue
```

---

## Integration Problems

### JIRA Integration

**Problem**: "Cannot create JIRA epic"
```bash
Error: JIRA API authentication failed
Check credentials in CLAUDE.md
```

**Fix**: Verify JIRA config
```bash
# Check configuration
cat CLAUDE.md | grep JIRA

# Ensure these exist:
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_JIRA_API_TOKEN=[token]

# Test connection
# (Feature depends on MCP server availability)
```

**Problem**: "Feature created locally but JIRA sync failed"
```bash
Warning: Feature 003 created locally
JIRA sync failed - run manual sync later
```

**Fix**: Not blocking, can sync manually
```bash
# Continue workflow locally
/spec plan

# Sync to JIRA later when connection restored
# Or create JIRA ticket manually from spec.md
```

---

### Confluence Integration

**Problem**: "Page already exists with same title"
```bash
Error: Confluence page "Feature: User Auth" already exists
Cannot create duplicate
```

**Fix**: Update existing page
```bash
/spec generate --confluence-update

# Or change feature name to be unique
/spec generate "User Authentication v2"
```

---

## Performance Issues

### Slow Execution

**Problem**: Commands taking >5 minutes

**Common Causes**:
1. Large codebase (discover phase)
2. Extensive research (plan phase)
3. Many tasks (implement phase)
4. Network issues (integrations)

**Solution**: Use faster options
```bash
# Discover: Limit scope
/spec discover --scope=./src/auth  # Not entire codebase

# Plan: Reduce research depth
/spec plan --research-depth=shallow

# Implement: Sequential execution
/spec implement --parallel=false  # Easier to debug

# Skip optional integrations during development
# Add them later
```

---

### High Token Usage

**Problem**: Hitting context limits frequently

**Solution**: Optimize loading
```bash
# Don't load examples/reference unless needed
/spec plan                    # NOT --examples

# Use status instead of reading files
/spec status                  # NOT "read all my files"

# Start fresh conversations per phase
# State persists across conversations
```

---

## Prevention Tips

### Tip 1: Validate Early and Often

```bash
# After spec
/spec validate

# After plan
/spec analyze

# Before implement
/spec validate
```

**Catches issues before they compound**

---

### Tip 2: Commit After Each Phase

```bash
# After spec
git add features/003-*/spec.md
git commit -m "feat: Add user auth spec"

# After plan
git add features/003-*/plan.md
git commit -m "feat: Add user auth plan"

# After tasks
git add features/003-*/tasks.md
git commit -m "feat: Add user auth tasks"
```

**Provides rollback points**

---

### Tip 3: Use Checkpoints

**Automatic**: Created every 30 minutes

**Manual**: Create before risky operations
```bash
# Before major change
cp .spec-state/current-session.md .spec-state/checkpoints/before-update.md

# Make changes
/spec update "Major changes"

# If problems, restore
cp .spec-state/checkpoints/before-update.md .spec-state/current-session.md
```

---

### Tip 4: Read Documentation Before Functions

```bash
# Before first use of a function
# Read the guide
"Show me the plan/ function guide"

# Understand what it does
# Then execute
/spec plan
```

---

### Tip 5: Ask for Help

```bash
# In-conversation
"I'm getting error X, how do I fix it?"

# Or check this guide
# Read ERROR-RECOVERY.md (this file)

# Or check glossary
# Read GLOSSARY.md for terms
```

---

## Quick Troubleshooting Checklist

When something goes wrong:

1. **Check Status** ✓
   ```bash
   /spec status
   ```

2. **Check Error Logs** ✓
   ```bash
   cat .spec-state/errors.log
   ```

3. **Validate Artifacts** ✓
   ```bash
   /spec validate
   ```

4. **Check This Guide** ✓
   - Find your error message above
   - Follow solution steps

5. **Try Recovery** ✓
   - Restore checkpoint if available
   - Reconstruct state if needed

6. **Ask for Help** ✓
   - "How do I fix [specific error]?"
   - Provide context from status/logs

---

## Summary: Common Fixes

| Problem | Quick Fix |
|---------|-----------|
| Stuck in clarify | `/spec plan` (skip and continue) |
| Implementation failed | `/spec implement --continue` |
| Requirements changed | `/spec update "changes"` |
| Don't know where I am | `/spec status` |
| Session state lost | Restore checkpoint or reconstruct |
| Validation errors | Fix CRITICAL first, then continue |
| Want to restart phase | Re-run with `--force` flag |
| Tests failing | Fix tests, then `--continue` |
| Out of context | Start new conversation, state persists |

---

## Related Resources

- **Quick Start**: `QUICK-START.md` - Get started guide
- **Glossary**: `GLOSSARY.md` - Term definitions
- **Workflow Map**: `navigation/workflow-map.md` - Visual guide
- **Review**: `WORKFLOW-REVIEW.md` - Comprehensive analysis

---

**Still stuck?**

Ask Claude: "I'm having [specific problem], how do I recover?"

Provide:
1. What you were trying to do
2. What error/behavior you see
3. Output of `/spec status`

This helps diagnose and resolve issues quickly!
