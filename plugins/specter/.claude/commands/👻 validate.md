# /specter-validate

Validate workflow consistency and artifact alignment.

## Purpose

Ensures all workflow artifacts (spec, plan, tasks) are consistent and aligned, detecting issues before they cause problems during implementation.

## Usage

```
/specter-validate                   # Check current feature
/specter-validate --fix             # Auto-fix issues
/specter-validate --strict          # Strict validation
/specter-validate --phase=planning  # Validate specific phase
/specter-validate --all             # Validate entire project
```

## Validation Checks

### 1. Artifact Consistency
- Spec → Plan alignment
- Plan → Tasks alignment
- Tasks → Implementation paths

### 2. Workflow Prerequisites
- Required files present (spec.md, plan.md, tasks.md)
- Dependencies properly ordered
- No circular dependencies

### 3. State Consistency
- No orphaned elements
- Priority alignment (P1 → P2 → P3)
- All {CLARIFY} resolved

## Example Output

See [validate-example.md](./examples/validate-example.md) for full output examples.

**Standard validation:**
```
🔍 Validating Workflow
✅ Artifact Consistency           [PASS]
✅ Workflow Prerequisites         [PASS]
⚠️  State Consistency            [WARN] - 2 orphaned tasks
Issues Found: 3 | Severity: Warning | Can Continue: Yes
```

## Validation Rules

| Issue | Valid Format | Invalid Format |
|-------|-------------|----------------|
| Task ID | `T001 [P] [US1]` | Missing task ID |
| Priority | P1 before P2 before P3 | Conflicts |
| Dependencies | T001 → T002 → T003 | Circular |

## Fix Capabilities

**Automatic fixes:** Task IDs, formatting, checkboxes, priority markers, references, duplicates

**Manual required:** {CLARIFY} markers, missing implementations, circular dependencies, logic conflicts

## Options

- `--fix`: Auto-fix issues
- `--strict`: Enable strict mode
- `--phase=PHASE`: Validate specific phase
- `--all`: Validate entire project
- `--quiet`: Errors only
- `--json`: JSON output

## Phase-Specific Validation

| Phase | Checks |
|-------|--------|
| Specification | User stories present, success criteria, priorities |
| Planning | Technical approach, architecture decisions, dependencies |
| Implementation | Task IDs valid, file paths exist, progress tracked |

## Integration Validation

**JIRA:** Ticket exists, status synced, fields mapped, permissions valid

**Git:** Branch naming correct, no conflicts, commits formatted, remote synced

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Orphaned Tasks | Map to story, create new story, or remove |
| Missing Priorities | Review spec, assign based on story, use --fix |
| Circular Dependencies | Review relationships, break reference, reorder |

## Best Practices

- Validate after `specter:specify`, `specter:plan`, `specter:tasks`
- Run before `specter:implement`
- Enable in CLAUDE.md: `SPECTER_VALIDATE_ON_SAVE=true`

## Error Messages

| Error | Action |
|-------|--------|
| No artifacts found | Run `specter:init` or `specter:specify` |
| Validation blocked | Restore from backup or recreate files |
| Spec is empty | Run `specter:specify --update` |

## Performance

- Full validation: < 500ms
- Auto-fix: < 1s
- Strict mode: < 2s
- Large project (50+ features): < 5s

## Related Commands

- `/specter-status` - Check workflow state
- `/specter-resume` - Resume after fixing
- `specter:analyze` - Deep consistency analysis

---

**Next:** After validation, proceed with `specter:implement` or fix reported issues.
