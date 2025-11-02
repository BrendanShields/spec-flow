---
name: spec:update
description: Use when updating specifications, modifying requirements, changing priorities, adding MCP integrations, or incorporating clarifications - updates spec.md and propagates changes through plan.md and tasks.md with migration planning
allowed-tools: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
model: claude-sonnet-4-5
---

# Specification Update

Update existing feature specifications with new requirements, MCP integrations, or priority changes.

## What This Skill Does

- Update spec.md with revised requirements
- Add/remove/modify user stories
- Change story priorities (P1 ↔ P2 ↔ P3)
- Add MCP server integrations (JIRA, Confluence, Linear)
- Incorporate [CLARIFY] resolutions
- Propagate changes to plan.md and tasks.md
- Create migration plan for breaking changes
- Log updates in DECISIONS-LOG.md

## When to Use

1. User says "update spec", "modify requirements", "change specification"
2. User requests MCP integration: "add JIRA sync", "connect to Confluence"
3. User changes priorities: "make this P1", "downgrade to P2"
4. User adds/removes features: "add user story", "remove this requirement"
5. User incorporates feedback: "update based on review", "address comments"
6. Context shows [CLARIFY] tags that need resolution

## Execution Flow

### Phase 1: Understand Update Request

**Read current state**:
```
1. Read {config.paths.state}/current-session.md → get active feature
2. Read {config.paths.features}/{feature-id}/{config.naming.files.spec} → current specification
3. Read {config.paths.memory}/WORKFLOW-PROGRESS.md → feature status
```

**Identify update type**:
- **Requirement change**: Modify user stories, acceptance criteria
- **MCP integration**: Add external tool sync (JIRA, Confluence, Linear)
- **Priority shift**: Change story priorities
- **Scope change**: Add/remove user stories
- **Clarification**: Resolve [CLARIFY] tags with decisions

**Ask clarifying questions** (if needed):
```
Use AskUserQuestion to confirm:
- Which user stories to update?
- Keep existing or replace?
- Impact on in-progress tasks?
- MCP configuration details?
```

### Phase 2: Update Specification

**For requirement changes**:
```
1. Edit {config.paths.features}/{feature-id}/{config.naming.files.spec}
2. Modify affected user stories
3. Update acceptance criteria
4. Adjust priority markers (P1, P2, P3)
5. Add "Updated" note with timestamp
```

**For MCP integration**:
```
1. Read shared/integration-patterns.md for MCP setup
2. Add MCP metadata to spec frontmatter:
   - JIRA: issue_key, project_key
   - Confluence: page_id, space_key
   - Linear: issue_id, team_id
3. Create or update external resources via MCP tools
4. Store returned URLs/IDs in spec
```

**For scope changes**:
```
1. Add new user stories with proper format
2. Remove obsolete stories (mark as deprecated)
3. Renumber if needed (maintain sequence)
4. Update story count in metadata
```

### Phase 3: Propagate Changes

**Check downstream impact**:
```
1. If plan.md exists:
   - Read {config.paths.features}/{feature-id}/{config.naming.files.plan}
   - Identify sections affected by spec changes
   - Flag for update

2. If tasks.md exists:
   - Read {config.paths.features}/{feature-id}/{config.naming.files.tasks}
   - Identify tasks affected by spec changes
   - Flag obsolete tasks
   - Identify new tasks needed
```

**Create migration plan**:
```
For breaking changes:
1. List affected components
2. Estimate effort to update
3. Identify risks
4. Suggest rollout strategy

For additive changes:
1. List new requirements
2. Suggest where to integrate
3. Note dependencies
```

**Update related files**:
```
1. If plan.md needs update:
   - Edit affected technical design sections
   - Add new architecture decisions
   - Mark outdated approaches

2. If tasks.md needs update:
   - Mark completed tasks obsolete
   - Add new tasks for new requirements
   - Adjust task priorities
   - Update task dependencies
```

### Phase 4: Update State

**Log the decision**:
```
1. Append to {config.paths.memory}/DECISIONS-LOG.md:
   - ADR number (auto-increment)
   - Date and context
   - What changed and why
   - Alternatives considered
   - Consequences

2. Update {config.paths.memory}/WORKFLOW-PROGRESS.md:
   - Note spec update
   - Add timestamp
   - Link to updated spec
```

**Update session**:
```
Edit {config.paths.state}/current-session.md:
- Add note about spec update
- If phase affected: update current phase
- If tasks affected: flag for review
```

**Move tasks if needed**:
```
If tasks obsoleted:
1. Read from {config.paths.memory}/CHANGES-PLANNED.md
2. Move obsolete tasks to CHANGES-COMPLETED.md with "obsolete" status
3. Add new tasks to CHANGES-PLANNED.md
```

### Phase 5: Validate & Report

**Run consistency check**:
```
1. Verify spec.md format valid
2. Check all [CLARIFY] tags resolved (if that was the update)
3. Validate MCP metadata (if MCP added)
4. Confirm plan/tasks alignment
```

**Report to user**:
```
Summary of changes:
- What was updated in spec
- Impact on plan and tasks
- New/obsolete tasks
- MCP resources created
- Next recommended action

Format:
✓ Updated spec.md: [summary]
✓ Propagated to plan.md: [changes]
✓ Adjusted tasks.md: [X added, Y removed]
✓ Logged decision: ADR-XXX
→ Next: Run implement phase to continue
```

## Error Handling

**Spec file not found**:
- Check if feature initialized
- Guide user to run generate phase first

**Conflicting changes**:
- Show current spec content
- Ask user which version to keep
- Create backup before overwriting

**MCP integration fails**:
- Continue with local updates
- Log MCP error
- Suggest manual sync later

**Downstream files inconsistent**:
- Flag inconsistencies
- Offer to regenerate (plan phase, tasks phase)
- Allow user to choose: update or regenerate

## Output Format

**Spec Update Summary**:
```markdown
# Specification Updated: Feature {ID} - {Name}

## Changes Made

### User Stories
- **Modified**: US1.2 (priority P2 → P1)
- **Added**: US1.5 (new OAuth requirement)
- **Removed**: US1.3 (deprecated session-based auth)

### MCP Integration
- **JIRA**: Created issue PROJ-123
- **Confluence**: Published to page 456789

### Propagation
- **plan.md**: Updated authentication architecture section
- **tasks.md**: Added 3 tasks, removed 2 obsolete tasks

### State Updates
- **Decision Log**: ADR-015 logged
- **Workflow Progress**: Updated feature status
- **Changes Planned**: 3 new tasks added

## Impact Assessment

**Effort Required**: 8 hours
**Risk Level**: Medium (architecture change)
**Dependencies**: OAuth library integration

## Migration Plan

1. Complete existing JWT tasks (T001-T003)
2. Add OAuth library (T020)
3. Update auth service (T021-T023)
4. Migrate existing users (T024)
5. Deprecate old endpoints (T025)

## Next Steps

→ Review updated spec: {config.paths.features}/{feature-id}/{config.naming.files.spec}
→ Continue implementation: Run implement phase
→ Validate changes: Run analyze phase
```

## Progressive Disclosure

**Core workflow**: See above execution flow

**Common patterns**: See `shared/workflow-patterns.md` (Pattern 3: Requirements Update)

**MCP integration details**: See `shared/integration-patterns.md`

**State file specifications**: See `shared/state-management.md`

**Concrete examples**: See `EXAMPLES.md` (5 update scenarios)

**Technical reference**: See `REFERENCE.md` (migration strategies, update patterns)
