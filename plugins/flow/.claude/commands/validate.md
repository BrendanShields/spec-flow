Execute when user types `/validate` or `/validate --fix`:

1. Find active feature:
   - Check `.flow-state/current-session.md`
   - Or use most recent in `features/`

2. If no feature found:
```
❌ No feature to validate

Start with:
• flow:specify "Feature description"
```

3. Run validation checks:

**Check 1: File existence**
- spec.md exists? ✅/❌
- If plan phase: plan.md exists? ✅/❌
- If implementation: tasks.md exists? ✅/❌

**Check 2: Task format (if tasks.md exists)**
For each task line, verify:
- Starts with `- [ ]` or `- [x]`
- Has task ID like `T001`
- Has user story ref like `[US1]`
- Has file path (ends with `.js`, `.ts`, etc.)

**Check 3: Consistency**
- Count user stories in spec.md
- Verify all stories have tasks in tasks.md
- Check no orphaned tasks

**Check 4: References**
- File paths in tasks exist or are in valid locations
- No broken cross-references

4. Display results:

**If all passed:**
```
✅ Validation Passed

Checked:
• File structure ✅
• Task formatting ✅
• Consistency ✅
• References ✅

Ready to proceed!
```

**If issues found:**
```
⚠️ Validation Issues

Problems:
1. T007 missing user story reference
2. T012 invalid file path: src/missing.ts
3. User story US3 has no tasks

{if --fix provided}
Auto-fixed:
✅ Added [US1] to T007
✅ Corrected format on 3 tasks

Manual required:
⚠️ Add tasks for US3
⚠️ Verify file path for T012

{/if}

{if --fix not provided}
Run /validate --fix to auto-correct formatting issues
{/if}
```

5. If `--fix` flag:
   - Fix task formatting (checkboxes, spacing)
   - Add missing task IDs (T013, T014, etc.)
   - Correct user story reference format

6. Do NOT auto-fix:
   - Missing implementations
   - Orphaned tasks (ask user)
   - Invalid file paths (user decision needed)

Execute validation and display results with clear pass/fail status.