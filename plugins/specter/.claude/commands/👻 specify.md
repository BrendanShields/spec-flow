# /specter-specify

Create a feature specification with prioritized user stories.

## TLDR

```bash
/specter-specify "Add user authentication"        # Create new feature
/specter-specify "JIRA-123" --from-jira          # Import from JIRA
/specter-specify "Feature" --level=project       # Project-level spec
```

## What It Does

Creates structured specification for your feature:
1. Generates user stories with priorities (P1/P2/P3)
2. Defines success criteria
3. Identifies technical constraints
4. Marks ambiguous areas for clarification
5. Creates feature directory with `spec.md`

## When to Use

- Starting a new feature (define what to build)
- Importing from JIRA (pull existing requirements)
- Creating project spec (define entire project vision)
- Updating requirements (use `specter:update` instead)

## Options

**Basic usage:**
```bash
/specter-specify "Description of your feature"
```

**From JIRA:**
```bash
/specter-specify "PROJ-123"
/specter-specify "https://jira.example.com/browse/PROJ-123"
```

**Project-level:**
```bash
/specter-specify "Complete project vision" --level=project
```

**Skip validation (POC):**
```bash
/specter-specify "Quick POC" --skip-validation
```

## Output Structure

Creates feature directory:

```
features/001-{feature-name}/
└── spec.md
```

**spec.md contains:**

```markdown
# Feature: {Name}

## Overview
{High-level description}

## User Stories

### P1 - Must Have
- [ ] **US1**: As a {user}, I want {feature} so that {benefit}
  - **Given** {precondition}
  - **When** {action}
  - **Then** {result}

### P2 - Should Have
- [ ] **US2**: ...

### P3 - Nice to Have
- [ ] **US3**: ...

## Success Criteria
- {Measurable criteria}

## Technical Constraints
- {Technical requirements}

## Clarifications
{CLARIFY: Ambiguous areas marked for review}
```

## Next Steps

After running `/specter-specify`:

1. **Review specification**
   - Read `features/001-{name}/spec.md`
   - Verify user stories are correct
   - Check priorities (P1/P2/P3)

2. **Resolve clarifications** (if any):
   ```bash
   /specter-clarify
   ```

3. **Proceed to planning**:
   ```bash
   /specter-plan
   ```

4. **Check progress**:
   ```bash
   /status
   ```

## JIRA Integration

If JIRA sync enabled (`SPECTER_ATLASSIAN_SYNC=enabled`):

**Create JIRA epic:**
```bash
/specter-specify "Feature" --create-jira
```

**Link to existing JIRA:**
```bash
/specter-specify "Feature" --jira=PROJ-789
```

**Spec frontmatter:**
```yaml
---
jira_id: PROJ-123
jira_url: https://jira.example.com/browse/PROJ-123
synced: true
---
```

## Validation

Checks for:
- Clear user stories
- Defined success criteria
- Priority assignment (P1/P2/P3)
- No obvious conflicts

Skip with `--skip-validation` for POCs.

## Troubleshooting

| Error | Solution |
|-------|----------|
| Feature already exists | Use /specter-update to modify, or delete directory |
| Ambiguous description | Review {CLARIFY:} markers, run /specter-clarify |
| JIRA connection failed | Check SPECTER_JIRA_PROJECT_KEY, verify MCP, check auth |

## Tips

**Good descriptions:**
- "Add user authentication with email/password and JWT tokens"
- "Implement shopping cart with add/remove items and checkout"
- "Create admin dashboard with user management and analytics"

**Poor descriptions:**
- "Make it work" (too vague)
- "Fix the thing" (what thing?)
- "Update stuff" (what updates?)

**Be specific about:**
- What feature you're building
- Who will use it
- Why it's needed
- Key functionality

## Related Commands

- `/specter-clarify` - Resolve ambiguities
- `/specter-plan` - Create technical design
- `/specter-update` - Modify existing spec
- `/status` - Check current state
- `/validate` - Check spec quality

---

**Next:** After specification, run `/specter-clarify` or `/specter-plan`.
