# flow-specify Command

Invoke the `flow:specify` skill to create a feature specification.

## TLDR
```bash
/flow-specify "Add user authentication"        # Create new feature
/flow-specify "JIRA-123" --from-jira          # Import from JIRA
/flow-specify "Feature" --level=project       # Project-level spec
```

## What It Does

Creates a structured specification for your feature:
1. Generates user stories with priorities (P1/P2/P3)
2. Defines success criteria
3. Identifies technical constraints
4. Marks ambiguous areas for clarification
5. Creates feature directory with `spec.md`

## When to Use

- **Starting a new feature** - Define what to build
- **Importing from JIRA** - Pull existing requirements
- **Creating project spec** - Define entire project vision
- **Updating requirements** - Use `flow:update` instead

## Execution

When you run `/flow-specify`, this command invokes the `flow:specify` skill to analyze your description and generate a comprehensive specification.

### Options

**Basic usage:**
```bash
/flow-specify "Description of your feature"
```

**From JIRA:**
```bash
/flow-specify "PROJ-123"
/flow-specify "https://jira.example.com/browse/PROJ-123"
```

**Project-level:**
```bash
/flow-specify "Complete project vision" --level=project
```

**Skip validation:**
```bash
/flow-specify "Quick POC" --skip-validation
```

## Example Usage

### Standard Feature
```bash
/flow-specify "Add user authentication with JWT tokens"

# Creates: features/001-user-authentication/spec.md
# Contains:
# - User stories (P1: Login/logout, P2: 2FA, P3: SSO)
# - Success criteria
# - Technical constraints
# - Clarification markers {CLARIFY: ...}
```

### From JIRA Story
```bash
/flow-specify "PROJ-456" --from-jira

# Pulls JIRA story PROJ-456
# Converts to Flow specification
# Links back to JIRA
# Creates feature directory
```

### Quick POC
```bash
/flow-specify "Test Redis caching" --skip-validation

# Creates minimal spec
# No quality checks
# Fast turnaround for experimentation
```

## Output Structure

The command creates a feature directory:

```
features/001-{feature-name}/
└── spec.md
```

**spec.md** contains:

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

After running `/flow-specify`:

1. **Review the specification**
   - Read `features/001-{name}/spec.md`
   - Verify user stories are correct
   - Check priorities (P1/P2/P3)

2. **Resolve clarifications** (if any):
   ```bash
   /flow-clarify
   ```

3. **Or proceed to planning**:
   ```bash
   /flow-plan
   ```

4. **Check your progress**:
   ```bash
   /status
   ```

## JIRA Integration

If JIRA sync is enabled (`FLOW_ATLASSIAN_SYNC=enabled`):

**Create JIRA epic automatically:**
```bash
/flow-specify "Feature" --create-jira
```

**Link to existing JIRA:**
```bash
/flow-specify "Feature" --jira=PROJ-789
```

**Frontmatter in spec.md:**
```yaml
---
jira_id: PROJ-123
jira_url: https://jira.example.com/browse/PROJ-123
synced: true
---
```

## Validation

The skill checks for:
- ✅ Clear user stories
- ✅ Defined success criteria
- ✅ Priority assignment (P1/P2/P3)
- ✅ No obvious conflicts

**Skip validation** with `--skip-validation` for POCs.

## Troubleshooting

**"Feature already exists"**
```
Error: features/001-name/ already exists

Solution: Use /flow-update to modify existing spec
Or: Delete the feature directory first
Or: Use different feature name
```

**"Ambiguous description"**
```
Warning: Multiple clarifications needed

Solution: Review {CLARIFY: ...} markers in spec
Run: /flow-clarify to resolve them
```

**"JIRA connection failed"**
```
Error: Cannot connect to JIRA

Solution:
- Check FLOW_JIRA_PROJECT_KEY in CLAUDE.md
- Verify MCP server is running
- Check authentication
```

## Tips

**Good descriptions:**
✅ "Add user authentication with email/password and JWT tokens"
✅ "Implement shopping cart with add/remove items and checkout"
✅ "Create admin dashboard with user management and analytics"

**Poor descriptions:**
❌ "Make it work" (too vague)
❌ "Fix the thing" (what thing?)
❌ "Update stuff" (what updates?)

**Be specific about:**
- What feature you're building
- Who will use it
- Why it's needed
- Key functionality

## Related Commands

- `/flow-clarify` - Resolve ambiguities
- `/flow-plan` - Create technical design
- `/flow-update` - Modify existing spec
- `/status` - Check current state
- `/validate` - Check spec quality

---

**Next**: After specification, run `/flow-clarify` or `/flow-plan` to continue.