# /specter-implement

Execute implementation of your feature task by task.

## TLDR

```bash
/specter-implement            # Start from T001
/specter-implement --continue # Continue from last checkpoint
/specter-implement --task=T005 # Start from specific task
/specter-implement --mvp-only # Only implement P1 tasks
```

## What It Does

Executes implementation based on tasks.md:
1. Reads `tasks.md` for task list
2. Implements each task sequentially
3. Marks tasks complete as done
4. Commits changes incrementally
5. Creates checkpoints automatically

## When to Use

- Ready to build (after spec, plan, tasks)
- Continuing work (resume interrupted implementation)
- Implementing MVP (focus on P1 tasks only)
- After spec changes (re-implement updated requirements)

## Execution Flow

```
1. Read tasks.md
2. Find first incomplete task [ ]
3. Show task details
4. Implement the task
5. Run tests (if applicable)
6. Mark task complete [x]
7. Commit changes
8. Update session state
9. Repeat for next task
```

## Task Format

```
- [ ] T### [P] [US#] Description at file/path
      Additional context
      Implementation notes
```

- `T###` - Task ID (sequential)
- `[P]` - Parallelizable (optional)
- `[US#]` - User story reference
- File path - Where to implement

## Workflow Phases

Implementation follows phases in `tasks.md`:

| Phase | Tasks | Description |
|-------|-------|-------------|
| Foundation | T001-T005 | Database, models, core logic |
| Core Features | T006-T010 | Main functionality |
| API Layer | T011-T015 | Endpoints, validation |
| Testing | T016-T020 | Tests, edge cases |
| Polish | T021-T025 | Optimization, docs |

## Parallelizable Tasks

Tasks marked with `[P]` can be done concurrently:

```markdown
- [x] T004 [P] [US1] Create user service
- [ ] T005 [P] [US1] Create auth service
- [ ] T006 [P] [US1] Create email service
```

The skill may ask if you want to implement parallel tasks together.

## Checkpointing

Automatic checkpoints created:
- Before starting implementation
- After completing each phase
- Every 5 tasks
- On errors or interruptions

Manual checkpoint: `/session save --name="after-phase-2"`

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

## Error Handling

| Error | Action |
|-------|--------|
| Task dependency missing | Review dependencies, check prior tasks, manually fix issue |
| Tests fail | Review output, fix tests, re-run task |
| Build errors | Check errors, fix syntax/types, verify imports |

## Resuming After Interruption

Session 1:
```bash
/specter-implement
# Completed T001, T002, T003
# (Session interrupted)
```

Session 2:
```bash
/resume
/specter-implement --continue
# Continuing from T004...
```

## MVP-Only Mode

Focus on P1 (must-have) tasks:

```bash
/specter-implement --mvp-only
# Implements only P1 tasks
# Skips P2/P3
# Gets to shippable state faster
```

Later: `/specter-implement --priority=P2`

## Validation During Implementation

After each task, checks:
- Code compiles/runs
- Tests pass
- Linting passes
- No obvious issues

Skip with `--skip-checklists`.

## Example Workflow

```bash
# 1. Check readiness
/status
# Tasks: 0/15 complete

# 2. Start implementation
/specter-implement
# Starting with T001...

# 3. Save progress
/session save --name="after-database"

# 4. Resume later
/resume
/specter-implement --continue

# 5. Check progress
/status
# Progress: 8/15 (53%)
```

## Tips for Success

**Before:** Run `/validate`, review all tasks, ensure dependencies clear, check task order

**During:** Let skill work through tasks, review code after each, run tests frequently, save checkpoints

**After:** Run full test suite, review changes, update docs, create PR

## Options

- `--continue`: Resume from last task
- `--task=T###`: Start from specific task
- `--mvp-only`: Only P1 tasks
- `--priority=P#`: Implement specific priority
- `--skip-checklists`: Skip validation

## Related Commands

- `/status` - Check progress
- `/validate` - Verify consistency
- `/session save` - Create checkpoint
- `/resume` - Continue work
- `specter:update` - Modify spec mid-flight

---

**Next:** After implementation, run `/validate` then create PR.
