# Flow Troubleshooting Guide

Complete guide to solving common issues with the Flow workflow system.

## 📋 Quick Diagnostics

```bash
# Run these first when something's wrong
/status                 # Check current state
/validate              # Check consistency
/help                  # Get contextual help
/session list          # See available checkpoints
```

---

## 🔍 Common Issues & Solutions

### Setup & Initialization

#### Issue: "Flow not initialized"
```
Error: .flow/ directory not found
```

**Symptoms:**
- Can't run flow commands
- No .flow/ directory exists

**Solution:**
```bash
/flow-init --type=greenfield    # For new projects
# or
/flow-init --type=brownfield    # For existing projects
```

**Prevention:**
Always run `/flow-init` once per project before using other Flow commands.

---

#### Issue: "Permission denied when creating .flow/"
```
Error: EACCES: permission denied, mkdir '.flow'
```

**Symptoms:**
- Can't create directories
- Permission errors

**Solution:**
```bash
# Check current directory permissions
ls -la

# Ensure you have write access
sudo chown -R $USER:$USER .

# Or run in a directory you own
cd ~/projects/myproject
/flow-init
```

---

#### Issue: "Already initialized"
```
Error: .flow/ directory already exists
```

**Symptoms:**
- `/flow-init` fails
- Directory already present

**Solution:**
This is fine! Flow is already set up.

```bash
# Check status
/status

# If you want to start fresh
rm -rf .flow/
/flow-init
```

---

### Specification Issues

#### Issue: "No specification found"
```
Error: spec.md not found
```

**Symptoms:**
- Can't run `/flow-plan`
- Feature directory exists but empty

**Solution:**
```bash
# Create specification first
/flow-specify "Your feature description"

# Check it was created
ls features/*/spec.md
```

---

#### Issue: "Specification has too many clarifications"
```
Warning: 10+ {CLARIFY: ...} markers found
```

**Symptoms:**
- Many ambiguous points
- Unclear requirements

**Solution:**
```bash
# Resolve clarifications interactively
/flow-clarify

# Or edit spec.md manually to address {CLARIFY: ...} markers
# Then run
/validate
```

**Prevention:**
Provide more detailed feature descriptions to `/flow-specify`.

---

#### Issue: "Can't update spec, plan already exists"
```
Error: plan.md exists, use /flow-update instead
```

**Symptoms:**
- Trying to modify existing feature
- Already have plan/tasks

**Solution:**
```bash
# Use update command for changes
/flow-update "Revised requirements"

# This will:
# - Update spec.md
# - Identify impacted tasks
# - Suggest regenerating plan/tasks
```

---

### Planning Issues

#### Issue: "Plan missing technical details"
```
Warning: Plan lacks architecture decisions
```

**Symptoms:**
- plan.md is too high-level
- Missing component designs

**Solution:**
```bash
# Define architecture first
/flow-blueprint

# Then regenerate plan
/flow-plan

# Or manually enhance plan.md with:
# - Component designs
# - Data models
# - API contracts
```

---

#### Issue: "Plan doesn't align with spec"
```
/validate shows: Plan missing US3 implementation
```

**Symptoms:**
- Validation failures
- User stories not addressed in plan

**Solution:**
```bash
# Regenerate plan
/flow-plan

# Or manually update plan.md to address all user stories
# Then validate
/validate --fix
```

---

### Task Issues

#### Issue: "Tasks out of sync with spec"
```
/validate shows: T007 references non-existent US4
```

**Symptoms:**
- Task validation failures
- Orphaned tasks
- Missing tasks for user stories

**Solution:**
```bash
# Auto-fix formatting
/validate --fix

# If still broken, regenerate tasks
/flow-tasks

# Check result
/validate
```

---

#### Issue: "Task format invalid"
```
Error: Task T005 missing user story reference
```

**Symptoms:**
- Tasks don't match format
- Missing [US#] markers
- No file paths

**Solution:**
```bash
# Auto-fix format issues
/validate --fix

# Correct format is:
# - [ ] T### [P] [US#] Description at path/to/file.ts
#       Additional context
```

**Prevention:**
Always use `/flow-tasks` to generate tasks, don't manually create.

---

#### Issue: "Circular task dependencies"
```
Error: T005 depends on T008 which depends on T005
```

**Symptoms:**
- Can't determine task order
- Implementation blocked

**Solution:**
```bash
# Review task dependencies in tasks.md
# Break the circular reference by:
# 1. Reordering tasks
# 2. Removing unnecessary dependencies
# 3. Splitting tasks

# Then validate
/validate
```

---

### Implementation Issues

#### Issue: "Can't find tasks to implement"
```
Error: tasks.md not found or empty
```

**Symptoms:**
- `/flow-implement` fails
- No tasks available

**Solution:**
```bash
# Generate tasks first
/flow-tasks

# Check they were created
cat features/*/tasks.md

# Then implement
/flow-implement
```

---

#### Issue: "All tasks already complete"
```
Info: 15/15 tasks complete, nothing to implement
```

**Symptoms:**
- Feature appears done
- No remaining work

**Solution:**
This is good! Feature is complete.

```bash
# Validate quality
/validate --strict

# Run checks
flow:checklist

# Create PR
gh pr create

# Start next feature
/flow-specify "Next feature"
```

---

#### Issue: "Implementation stuck on failing test"
```
Error: Tests failing after T008
```

**Symptoms:**
- Task completed but tests fail
- Can't proceed to next task

**Solution:**
```bash
# Fix the failing tests
# Review test output

# Re-run specific task
/flow-implement --task=T008

# Or skip tests temporarily (not recommended)
/flow-implement --skip-tests
```

---

#### Issue: "Task dependencies not met"
```
Error: T010 requires T007 which isn't complete
```

**Symptoms:**
- Can't complete task
- Missing prerequisites

**Solution:**
```bash
# Complete prerequisites first
/flow-implement --task=T007

# Then continue
/flow-implement --task=T010

# Or fix task order in tasks.md
```

---

### Session & State Issues

#### Issue: "Session lost after Claude restart"
```
/status shows: No active session
```

**Symptoms:**
- Lost progress
- Can't find previous work

**Solution:**
```bash
# Restore from checkpoint
/session list
/session restore --checkpoint={timestamp}

# Or resume automatically
/resume
```

**Prevention:**
Always save before ending session:
```bash
/session save --name="end-of-day"
```

---

#### Issue: "Checkpoint corrupted"
```
Error: Cannot read checkpoint file
```

**Symptoms:**
- Restore fails
- Checkpoint unreadable

**Solution:**
```bash
# Try other checkpoints
/session list
/session restore --checkpoint={older-timestamp}

# Or start fresh
/status
# Manually check features/ directory
# Continue from last known state
```

---

#### Issue: "State files out of sync"
```
Warning: current-session.md differs from actual state
```

**Symptoms:**
- Status shows wrong information
- Mismatch between files and session

**Solution:**
```bash
# Validate and fix
/validate --fix

# Manually sync if needed
# Edit .flow-state/current-session.md
# Update to match actual feature state

# Re-save
/session save --force
```

---

### Integration Issues

#### Issue: "JIRA connection failed"
```
Error: Cannot connect to JIRA API
```

**Symptoms:**
- JIRA sync not working
- Authentication failures

**Solution:**
```bash
# Check configuration
cat CLAUDE.md | grep JIRA

# Verify settings:
# FLOW_ATLASSIAN_SYNC=enabled
# FLOW_JIRA_PROJECT_KEY=PROJ

# Check MCP server running
# Re-authenticate if needed

# Disable if not needed
# Set: FLOW_ATLASSIAN_SYNC=disabled
```

---

#### Issue: "Git commits failing"
```
Error: Cannot create git commit
```

**Symptoms:**
- Implementation fails
- No commits created

**Solution:**
```bash
# Check git configuration
git config user.name
git config user.email

# Set if missing
git config user.name "Your Name"
git config user.email "your@email.com"

# Check git status
git status

# Resolve any conflicts
git add .
git commit -m "Manual commit"

# Continue
/flow-implement --continue
```

---

### Validation Issues

#### Issue: "Validation always fails"
```
/validate shows errors even after fixes
```

**Symptoms:**
- Can't pass validation
- Errors persist

**Solution:**
```bash
# Run strict validation to see all issues
/validate --strict

# Fix one by one
# Start with formatting
/validate --fix

# Then manual issues
# Edit files as needed

# Validate again
/validate
```

---

#### Issue: "False positive validation errors"
```
/validate shows: Error in valid task
```

**Symptoms:**
- Validation flags correct content
- Over-sensitive checks

**Solution:**
```bash
# Check if it's really valid
# Review task format carefully

# If truly a false positive:
# Temporarily disable strict mode
/flow-implement --skip-validation

# Report issue if bug
```

---

## 🔧 Advanced Troubleshooting

### Debug Mode

Enable detailed logging:

```bash
# Set in CLAUDE.md
FLOW_DEBUG=true
FLOW_VERBOSE=true

# Then run commands
/status --verbose
/validate --verbose
```

### State Inspection

Manually inspect state:

```bash
# Check session state
cat .flow-state/current-session.md

# Check progress
cat .flow-memory/WORKFLOW-PROGRESS.md

# Check decisions
cat .flow-memory/DECISIONS-LOG.md

# Check feature
cat features/001-*/spec.md
```

### Manual Fixes

Sometimes manual intervention needed:

```bash
# Fix task numbering
# Edit tasks.md
# Renumber: T001, T002, T003...

# Fix user story references
# Update [US1], [US2], etc.

# Fix file paths
# Ensure paths are correct

# Then validate
/validate --fix
```

### Reset & Start Over

Last resort:

```bash
# Backup first
cp -r features/ features.backup/
cp -r .flow-state/ .flow-state.backup/

# Reset state
rm -rf .flow-state/
rm -rf .flow-memory/

# Reinitialize
/flow-init

# Restore features
# Features are preserved
# Just state was reset

# Continue from current state
/status
/flow-implement --continue
```

---

## 🆘 Getting Help

### In-App Help

```bash
/help                           # General help
/help /flow-specify             # Command-specific help
/status                         # Current state
```

### Documentation

- **USER-GUIDE.md** - Complete user guide
- **COMMANDS-QUICK-REFERENCE.md** - Command reference
- **WORKFLOW-EXPANSION-GUIDE.md** - Customization
- **docs/** - Detailed documentation

### Community

- GitHub Issues - Report bugs
- Discussions - Ask questions
- Documentation site - Latest docs

---

## 📊 Diagnostic Checklist

When things go wrong, run through this:

```markdown
- [ ] Run /status - check current state
- [ ] Run /validate - check consistency
- [ ] Check .flow/ exists - ensure initialized
- [ ] Check features/ has content - ensure features exist
- [ ] Check git status - ensure clean state
- [ ] Check permissions - ensure write access
- [ ] Review last command - what was last action?
- [ ] Check session list - any checkpoints?
- [ ] Review error message - what exactly failed?
- [ ] Try /resume - can you recover?
```

---

## 🎯 Prevention Tips

Avoid issues before they happen:

✅ **Initialize properly**: Run `/flow-init` once per project
✅ **Save frequently**: Use `/session save` before breaks
✅ **Validate often**: Run `/validate` after edits
✅ **Check status**: Use `/status` regularly
✅ **Use help**: Don't guess, use `/help`
✅ **Follow workflow**: Spec → Plan → Tasks → Implement
✅ **Commit often**: Small, focused commits
✅ **Read errors**: Error messages are helpful
✅ **Keep backups**: Save checkpoints at milestones
✅ **Test incrementally**: Don't wait till the end

---

**Still stuck?** Check `/help` or review USER-GUIDE.md for detailed walkthroughs.
