# flow-implement Command

Invoke the `flow:implement` skill to execute the implementation of your feature.

## TLDR
```bash
/flow-implement                # Start implementation from T001
/flow-implement --continue     # Continue from last checkpoint
/flow-implement --task=T005    # Start from specific task
/flow-implement --mvp-only     # Only implement P1 tasks
```

## What It Does

Executes the implementation based on your task breakdown:
1. Reads `tasks.md` for the task list
2. Implements each task sequentially
3. Marks tasks complete `[x]` as they're done
4. Commits changes incrementally
5. Updates progress tracking
6. Creates checkpoints automatically

## When to Use

- **Ready to build** - After spec, plan, and tasks are done
- **Continuing work** - Resume interrupted implementation
- **Implementing MVP** - Focus on P1 tasks only
- **After spec changes** - Re-implement updated requirements

## Execution

When you run `/flow-implement`, this command invokes the `flow:implement` skill to build your feature task by task.

### Options

**Start from beginning:**
```bash
/flow-implement
```

**Continue from last task:**
```bash
/flow-implement --continue
```

**Start from specific task:**
```bash
/flow-implement --task=T005
```

**MVP only (P1 tasks):**
```bash
/flow-implement --mvp-only
```

**Skip checklists:**
```bash
/flow-implement --skip-checklists
```

## How It Works

### Task Execution Flow

```
1. Read tasks.md
2. Find first incomplete task [ ]
3. Show task details to user
4. Implement the task
5. Run tests (if applicable)
6. Mark task complete [x]
7. Commit changes
8. Update session state
9. Repeat for next task
```

### Example Task

```markdown
- [ ] T003 [P] [US1] Create User model at src/models/user.ts
      Define User entity with email, password, timestamps
      Add validation rules (email format, password strength)
      Export for use in authentication service
```

**Implementation:**
1. Creates `src/models/user.ts`
2. Implements User class/interface
3. Adds validation logic
4. Writes unit tests
5. Marks task: `- [x] T003 ...`

### Progress Tracking

During implementation:
```bash
/status

Feature: 001-user-authentication
Phase: Implementation
Progress: 5/15 tasks (33%)
Current: T006 [US2] Add JWT middleware
```

## Task Format

Tasks must follow this format:
```
- [ ] T### [P] [US#] Description at file/path
      Additional context
      Implementation notes
```

- `T###` - Task ID (sequential)
- `[P]` - Parallelizable (optional, can do concurrently)
- `[US#]` - User story reference
- File path - Where to implement

## User Story Phases

Implementation follows phases from `tasks.md`:

```markdown
## Phase 1: Foundation
- [ ] T001-T005 (database, models, core logic)

## Phase 2: Core Features
- [ ] T006-T010 (main functionality)

## Phase 3: API Layer
- [ ] T011-T015 (endpoints, validation)

## Phase 4: Testing
- [ ] T016-T020 (tests, edge cases)

## Phase 5: Polish
- [ ] T021-T025 (optimization, docs)
```

Each phase builds on the previous one.

## Parallelizable Tasks

Tasks marked with `[P]` can be done concurrently:

```markdown
- [x] T004 [P] [US1] Create user service
- [ ] T005 [P] [US1] Create auth service
- [ ] T006 [P] [US1] Create email service
```

The skill may ask if you want to implement parallel tasks together.

## Checkpointing

Automatic checkpoints are created:
- Before starting implementation
- After completing each phase
- Every 5 tasks
- On errors or interruptions

Manual checkpoint:
```bash
/session save --name="after-phase-2"
```

## Git Integration

Each task completion creates a git commit:

```bash
git commit -m "feat: Create User model (T003)

- Implement User entity with validation
- Add email format checking
- Add password strength rules

[US1] User registration
Task: T003

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Commit pattern:**
- Meaningful commit message
- References task ID
- Links to user story
- Co-author attribution

## Error Handling

### Task Fails
```
Error: Cannot complete T007 - dependency missing

Actions:
1. Review task dependencies
2. Check if prior tasks completed
3. Manually fix issue
4. Continue: /flow-implement --continue
```

### Tests Fail
```
Warning: Tests failing after T008

Actions:
1. Review test output
2. Fix failing tests
3. Re-run: /flow-implement --task=T008
```

### Build Errors
```
Error: Build failed after T010

Actions:
1. Check compilation errors
2. Fix syntax/type issues
3. Verify imports
4. Continue: /flow-implement --continue
```

## Resuming After Interruption

Session 1:
```bash
/flow-implement
> Completed T001, T002, T003
> (Session interrupted)
```

Session 2:
```bash
/resume
> Restored session
> Last completed: T003
> Next task: T004

/flow-implement --continue
> Continuing from T004...
```

## MVP-Only Mode

Focus on P1 (must-have) tasks:

```bash
/flow-implement --mvp-only

# Only implements tasks from P1 user stories
# Skips P2/P3 tasks
# Gets you to shippable state faster
```

Later, implement P2:
```bash
/flow-implement --priority=P2
```

## Validation During Implementation

After each task, checks:
- ✅ Code compiles/runs
- ✅ Tests pass
- ✅ Linting passes
- ✅ No obvious issues

Skip with `--skip-checklists`.

## Example Full Workflow

```bash
# 1. Check you're ready
/status
> Tasks: 0/15 complete
> Ready to implement

# 2. Start implementation
/flow-implement
> Starting with T001: Set up database schema
> [Implementation happens]
> ✅ T001 complete
> Moving to T002...

# 3. Save progress before break
/session save --name="after-database"

# 4. Resume later
/resume
/flow-implement --continue
> Continuing from T003...

# 5. Check progress anytime
/status
> Progress: 8/15 (53%)
> Current: T009
```

## Tips for Success

**Before implementing:**
- ✅ Run `/validate` to check task consistency
- ✅ Review all tasks in `tasks.md`
- ✅ Ensure dependencies are clear
- ✅ Check task order makes sense

**During implementation:**
- ✅ Let the skill work through tasks sequentially
- ✅ Review code after each task
- ✅ Run tests frequently
- ✅ Save checkpoints at phase boundaries

**After implementation:**
- ✅ Run full test suite
- ✅ Review all changes
- ✅ Update documentation
- ✅ Create pull request if ready

## Troubleshooting

**"No tasks found"**
```
Error: tasks.md not found or empty

Solution: Run /flow-tasks first to create task breakdown
```

**"Task dependencies not met"**
```
Error: T007 depends on T005 which isn't complete

Solution:
- Complete T005 first
- Or fix task ordering in tasks.md
- Then: /flow-implement --continue
```

**"All tasks already complete"**
```
Info: All 15 tasks marked as complete

Solution: Feature is done!
- Run /validate to check quality
- Create PR with /pr
- Start next feature with /flow-specify
```

## Related Commands

- `/status` - Check progress
- `/validate` - Verify consistency
- `/session save` - Create checkpoint
- `/resume` - Continue work
- `/flow-update` - Modify spec mid-flight

---

**Next**: After implementation, run `/validate` to check quality, then create PR.