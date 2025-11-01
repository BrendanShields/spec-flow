# Specification Update Reference

Technical reference for update strategies, migration patterns, and MCP configuration.

## Update Strategies

### Strategy 1: Additive Updates (Low Risk)

**Use when**: Adding new user stories, features, or integrations

**Characteristics**:
- Existing work unaffected
- New tasks added to queue
- No migration needed
- Low risk to timeline

**Process**:
```
1. Append new content to spec.md
2. Add corresponding plan.md sections
3. Add new tasks to tasks.md (queued)
4. Update CHANGES-PLANNED.md
5. Log decision
```

**Example changes**:
- Add new user story
- Add MCP integration
- Add acceptance criteria
- Add optional feature

**Risk level**: 🟢 Low

---

### Strategy 2: Modificative Updates (Medium Risk)

**Use when**: Changing existing requirements or priorities

**Characteristics**:
- Affects existing work
- May require rework
- Possible migration path
- Medium timeline impact

**Process**:
```
1. Identify affected sections in spec.md
2. Update affected content
3. Check plan.md for inconsistencies
4. Check tasks.md for affected tasks
5. Create migration plan if needed
6. Update in-progress work
7. Log decision with impact
```

**Example changes**:
- Change priority (P2 → P1)
- Modify acceptance criteria
- Update user story details
- Change technical approach

**Risk level**: 🟡 Medium

---

### Strategy 3: Breaking Updates (High Risk)

**Use when**: Removing features or fundamental architecture changes

**Characteristics**:
- Breaks existing work
- Requires migration
- Significant rework
- High timeline impact

**Process**:
```
1. Assess full impact across all files
2. Create detailed migration plan
3. Identify point of no return
4. Backup current state (checkpoint)
5. Mark deprecated features
6. Obsolete affected tasks
7. Add migration tasks
8. Communicate risks
9. Log decision with full consequences
```

**Example changes**:
- Remove user story
- Change authentication method
- Replace database system
- Remove third-party integration

**Risk level**: 🔴 High

**Required**:
- Explicit user confirmation
- Detailed migration plan
- Checkpoint before changes
- Clear rollback path

---

## Migration Patterns

### Pattern A: In-Place Update

**When**: Minor changes, backward compatible

**Steps**:
```
1. Update spec.md directly
2. Modify affected plan sections
3. Adjust task descriptions
4. No code migration needed
```

**Example**: Priority change P2 → P1

---

### Pattern B: Parallel Implementation

**When**: Major changes, maintain compatibility during transition

**Steps**:
```
1. Add new approach to spec
2. Keep old approach marked [DEPRECATED]
3. Add tasks for new implementation
4. Add tasks for migration
5. Add tasks for removal of old approach
6. Define cutover criteria
```

**Example**: JWT + Sessions → JWT-only

**Timeline**:
```
Phase 1: Implement new approach (JWT refresh tokens)
Phase 2: Run both approaches in parallel
Phase 3: Migrate users to new approach
Phase 4: Remove old approach (sessions)
```

---

### Pattern C: Big Bang Replacement

**When**: Incompatible changes, no parallel path possible

**Steps**:
```
1. Mark old approach [DEPRECATED]
2. Obsolete all old tasks
3. Add complete new task set
4. Create migration script tasks
5. Define testing strategy
6. Plan rollback procedure
```

**Example**: MySQL → PostgreSQL

**Risks**:
- Downtime required
- All-or-nothing deployment
- Higher failure impact

**Mitigations**:
- Extensive testing
- Backup before migration
- Rehearse migration
- Prepare rollback

---

## MCP Configuration

### JIRA Integration

**Configuration** (in project CLAUDE.md):
```markdown
# Spec Configuration

SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_JIRA_BOARD_ID=123
SPEC_JIRA_AUTO_CREATE=true
SPEC_JIRA_AUTO_UPDATE=true
```

**Spec metadata** (in spec.md frontmatter):
```yaml
---
jira_issue: PROJ-42
jira_url: https://company.atlassian.net/browse/PROJ-42
synced_at: 2025-10-31T15:30:00Z
sync_direction: bidirectional
---
```

**Update operations**:
```javascript
// Create JIRA issue from spec
jira_create_issue({
  project_key: "PROJ",
  issue_type: "Story",
  summary: feature_title,
  description: formatted_user_stories,
  priority: map_priority(spec_priority),
  labels: ["spec-generated", "feature"],
  components: extract_components(spec)
})

// Update JIRA issue when spec changes
jira_update_issue({
  issue_key: "PROJ-42",
  summary: updated_title,
  description: updated_user_stories,
  priority: new_priority,
  comment: "Updated via spec:update - " + change_summary
})

// Sync JIRA status to spec
jira_get_issue("PROJ-42")
→ Update spec metadata with current JIRA status
```

**Priority mapping**:
- P1 (Must Have) → "Highest" or "High"
- P2 (Should Have) → "Medium"
- P3 (Nice to Have) → "Low" or "Lowest"

---

### Confluence Integration

**Configuration**:
```markdown
SPEC_CONFLUENCE_SYNC=enabled
SPEC_CONFLUENCE_SPACE_KEY=DEV
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
SPEC_CONFLUENCE_AUTO_PUBLISH=true
```

**Spec metadata**:
```yaml
---
confluence_page_id: 789012
confluence_url: https://company.atlassian.net/wiki/spaces/DEV/pages/789012
published_at: 2025-10-31T15:30:00Z
---
```

**Update operations**:
```javascript
// Publish spec to Confluence
confluence_create_page({
  space_key: "DEV",
  parent_page_id: 123456,
  title: "[Spec] " + feature_title,
  content: format_as_confluence_storage(spec_content),
  labels: ["spec", "feature", feature_id]
})

// Update Confluence page when spec changes
confluence_update_page({
  page_id: 789012,
  title: "[Spec] " + updated_title,
  content: format_as_confluence_storage(updated_spec),
  version_comment: "Updated via spec:update - " + change_summary
})
```

**Content formatting**:
```javascript
function format_as_confluence_storage(spec_md) {
  return `
    <h1>${feature_title}</h1>
    <ac:structured-macro ac:name="info">
      <ac:rich-text-body>
        <p>Generated by Spec on ${timestamp}</p>
      </ac:rich-text-body>
    </ac:structured-macro>

    <h2>User Stories</h2>
    ${convert_md_to_storage_format(user_stories)}

    <h2>Acceptance Criteria</h2>
    ${convert_md_to_storage_format(acceptance_criteria)}

    <ac:structured-macro ac:name="jira">
      <ac:parameter ac:name="key">${jira_issue}</ac:parameter>
    </ac:structured-macro>
  `
}
```

---

### Linear Integration

**Configuration**:
```markdown
SPEC_LINEAR_SYNC=enabled
SPEC_LINEAR_TEAM_ID=TEAM123
SPEC_LINEAR_AUTO_CREATE=true
```

**Spec metadata**:
```yaml
---
linear_issue_id: abc-123-def
linear_url: https://linear.app/company/issue/TEAM-42
synced_at: 2025-10-31T15:30:00Z
---
```

**Update operations**:
```javascript
// Create Linear issue from spec
linear_create_issue({
  team_id: "TEAM123",
  title: feature_title,
  description: format_linear_description(spec_content),
  priority: map_priority(spec_priority),
  labels: ["spec-generated", "feature"],
  estimate: calculate_story_points(spec)
})

// Update Linear issue when spec changes
linear_update_issue({
  issue_id: "abc-123-def",
  title: updated_title,
  description: updated_description,
  priority: new_priority,
  comment: "Updated via spec:update"
})
```

**Priority mapping**:
- P1 → Urgent (priority: 1)
- P2 → High (priority: 2)
- P3 → Normal (priority: 3)

---

### GitHub Integration

**Configuration**:
```markdown
SPEC_GITHUB_SYNC=enabled
SPEC_GITHUB_REPO=owner/repo
SPEC_GITHUB_AUTO_ISSUE=true
```

**Spec metadata**:
```yaml
---
github_issue: 42
github_url: https://github.com/owner/repo/issues/42
synced_at: 2025-10-31T15:30:00Z
---
```

**Update operations**:
```javascript
// Create GitHub issue from spec
github_create_issue({
  owner: "owner",
  repo: "repo",
  title: feature_title,
  body: format_github_markdown(spec_content),
  labels: ["spec-generated", "feature", priority_label],
  assignees: extract_assignees(spec)
})

// Update GitHub issue when spec changes
github_update_issue({
  owner: "owner",
  repo: "repo",
  issue_number: 42,
  title: updated_title,
  body: updated_content,
  labels: updated_labels
})

// Add comment for updates
github_create_comment({
  owner: "owner",
  repo: "repo",
  issue_number: 42,
  body: "Spec updated: " + change_summary
})
```

---

## Change Impact Analysis

### Impact Assessment Framework

**Questions to answer**:

1. **Scope of change**:
   - How many user stories affected?
   - How many tasks affected?
   - How many files need modification?

2. **Phase impact**:
   - Is spec complete? → Low impact
   - Is plan complete? → Medium impact
   - Are tasks in progress? → High impact
   - Is implementation started? → Very high impact

3. **Risk assessment**:
   - Breaking changes? → High risk
   - Additive changes? → Low risk
   - Priority changes? → Medium risk
   - Technical approach changes? → High risk

4. **Effort estimation**:
   - How many hours for spec update?
   - How many hours for plan update?
   - How many hours for task updates?
   - How many hours for implementation changes?
   - How many hours for migration?

5. **Timeline impact**:
   - Does this add time? How much?
   - Does this save time? How much?
   - Does this shift deadline?

### Impact Report Template

```markdown
## Change Impact Analysis

### Summary
Brief description of proposed change.

### Scope
- **User Stories**: X affected, Y added, Z removed
- **Tasks**: X affected, Y added, Z obsolete
- **Files**: X spec.md, Y plan.md, Z tasks.md

### Phase Status
- **Current Phase**: [spec/plan/tasks/implement]
- **Progress**: X% complete
- **Impact Level**: [Low/Medium/High/Critical]

### Risk Assessment
**Breaking Changes**: [Yes/No]
- Detail any breaking changes

**Dependencies**:
- External: [list external dependencies affected]
- Internal: [list internal dependencies affected]

**Rollback Path**: [Easy/Moderate/Difficult/None]

### Effort Estimation
- **Update spec**: X hours
- **Update plan**: Y hours
- **Update tasks**: Z hours
- **Implementation**: W hours
- **Migration**: V hours
- **Testing**: U hours
- **Total**: T hours

### Timeline Impact
- **Current deadline**: YYYY-MM-DD
- **Time added**: +X hours
- **Time saved**: -Y hours
- **Net change**: +Z hours
- **New deadline**: YYYY-MM-DD

### Recommendations
1. [Action item]
2. [Action item]
3. [Action item]

### Approval Required
- [ ] Product Owner (scope change)
- [ ] Tech Lead (architecture change)
- [ ] Project Manager (timeline change)
```

---

## State Synchronization

### Keeping State Consistent

**Files that must stay in sync**:

```
features/{id}/spec.md ←→ features/{id}/plan.md ←→ features/{id}/tasks.md
                ↓                     ↓                        ↓
        .spec-memory/DECISIONS-LOG.md
                        ↓
        .spec-memory/WORKFLOW-PROGRESS.md
                        ↓
        .spec-memory/CHANGES-PLANNED.md
                        ↓
        .spec-state/current-session.md
```

**Update sequence** (to maintain consistency):

```
1. Update spec.md (source of truth)
2. Check plan.md for affected sections
3. Update plan.md sections as needed
4. Check tasks.md for affected tasks
5. Update tasks.md as needed
6. Update DECISIONS-LOG.md (log decision)
7. Update WORKFLOW-PROGRESS.md (track progress)
8. Update CHANGES-PLANNED.md (task queue)
9. Update current-session.md (active state)
10. If MCP enabled: Sync to external tools
```

**Validation checks**:

```bash
# After update, verify:
1. All user stories in spec have corresponding plan sections
2. All plan sections have corresponding tasks
3. All tasks reference user stories
4. All priorities are valid (P1/P2/P3)
5. All [CLARIFY] tags resolved
6. All metadata fields populated
7. All timestamps current
8. All MCP links valid
```

---

## Error Recovery

### Recovery Procedures

**Corrupted spec.md**:
```
1. Check for checkpoint in .spec-state/checkpoints/
2. Restore from most recent checkpoint
3. Re-apply changes manually
4. Validate format
5. Save new checkpoint
```

**MCP sync failure**:
```
1. Log error details
2. Continue with local updates
3. Mark MCP metadata as "sync_failed"
4. Notify user
5. Retry sync later (manual or auto)
6. Update metadata when sync succeeds
```

**Inconsistent downstream files**:
```
1. Identify inconsistencies (spec vs plan vs tasks)
2. Ask user which is source of truth
3. Options:
   a. Update spec to match reality
   b. Regenerate plan from spec
   c. Regenerate tasks from plan
   d. Manual reconciliation
4. Log resolution in DECISIONS-LOG.md
```

**Conflicting concurrent changes**:
```
1. Detect conflict (git status or file comparison)
2. Show both versions to user
3. Ask user to choose or merge
4. Apply chosen resolution
5. Mark as manually resolved
6. Create checkpoint of resolution
```

---

## Best Practices

### Do's

✅ **Always read before write**: Load current state before updating
✅ **Create checkpoints**: Save state before risky operations
✅ **Log decisions**: Document why changes were made
✅ **Validate consistency**: Check alignment after updates
✅ **Communicate impact**: Tell user what changed and consequences
✅ **Provide next steps**: User always knows what to do next
✅ **Fall back gracefully**: Continue if MCP fails
✅ **Preserve history**: Move obsolete tasks to COMPLETED, don't delete

### Don'ts

❌ **Don't skip validation**: Always check consistency
❌ **Don't overwrite without reading**: Risk data loss
❌ **Don't block on MCP**: Always have local fallback
❌ **Don't delete history**: Mark as obsolete instead
❌ **Don't ignore impact**: Always assess downstream effects
❌ **Don't skip logging**: Decisions must be documented
❌ **Don't make breaking changes without approval**: Get user confirmation

---

## Advanced Patterns

### Batch Updates

**When updating multiple user stories**:

```
1. Collect all changes first
2. Assess combined impact
3. Update spec.md once with all changes
4. Update downstream files once
5. Create single decision log entry
6. Single state update
```

**Benefits**:
- Fewer file writes
- Better performance
- Cleaner history
- Single decision record

---

### Conditional Updates

**Update plan/tasks only if necessary**:

```python
def should_update_plan(spec_changes):
    if spec_changes.type == "priority_change":
        return False  # Priority doesn't affect design
    if spec_changes.type == "acceptance_criteria_clarification":
        return False  # Clarification doesn't change design
    if spec_changes.type == "new_user_story":
        return True   # New story needs design
    if spec_changes.type == "remove_user_story":
        return True   # Removal affects design
    return True  # Default: safer to update

def should_update_tasks(spec_changes):
    if spec_changes.type == "mcp_integration":
        return False  # MCP doesn't affect tasks
    if spec_changes.type == "documentation_update":
        return False  # Docs don't affect tasks
    return True  # Most changes affect tasks
```

---

### Partial Updates

**When only some sections change**:

```
Instead of:
  Read entire plan.md
  Regenerate entire file
  Write entire file

Do:
  Read plan.md
  Identify affected section
  Edit only that section
  Leave rest unchanged
```

**Benefits**:
- Faster updates
- Preserves unrelated content
- Reduces conflict risk
- Better git diffs

---

## Related Documentation

- **Workflow patterns**: See `shared/workflow-patterns.md`
- **MCP integration details**: See `shared/integration-patterns.md`
- **State specifications**: See `shared/state-management.md`
- **Concrete examples**: See `EXAMPLES.md`
- **Core skill**: See `SKILL.md`

---

**Last Updated**: 2025-10-31
**Token Size**: ~2,800 tokens
**Used By**: spec:update skill
