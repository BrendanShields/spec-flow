# Shared: MCP Integration Patterns

This file contains common MCP (Model Context Protocol) integration patterns used across multiple Spec skills.

## Overview

MCP servers provide external integrations for tools like JIRA, Confluence, Linear, GitHub, and more. Spec skills can leverage MCP servers to:
- Sync specifications with JIRA stories
- Publish documentation to Confluence
- Create GitHub issues from tasks
- Track progress in Linear
- And more...

## Common MCP Servers

### Atlassian (JIRA + Confluence)

**Configuration** (in user's CLAUDE.md):
```markdown
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_JIRA_PROJECT_KEY=PROJ
SPECTER_CONFLUENCE_ROOT_PAGE_ID=123456
```

**Available Tools**:
- `jira_create_issue` - Create JIRA story/task
- `jira_update_issue` - Update existing issue
- `jira_search` - Search for issues
- `confluence_create_page` - Create Confluence page
- `confluence_update_page` - Update page content

**Common Patterns**:

```markdown
## Pattern: Create JIRA Story from Spec

1. Read spec.md for user story details
2. Extract: title, description, acceptance criteria, priority
3. Call jira_create_issue with:
   - project_key: from config
   - issue_type: "Story"
   - summary: user story title
   - description: formatted with acceptance criteria
   - priority: map P1→High, P2→Medium, P3→Low
4. Store returned issue key in spec metadata
5. Update .specter-memory/WORKFLOW-PROGRESS.md with link
```

```markdown
## Pattern: Publish Plan to Confluence

1. Read plan.md with all planning artifacts
2. Format as Confluence-compatible markdown
3. Call confluence_create_page with:
   - space_key: from config
   - parent_page_id: from config
   - title: "[Feature Name] Technical Plan"
   - content: formatted plan with sections
4. Store returned page URL in plan metadata
5. Update .specter-memory/DECISIONS-LOG.md with link
```

### Linear

**Configuration**:
```markdown
SPECTER_LINEAR_SYNC=enabled
SPECTER_LINEAR_TEAM_ID=TEAM123
```

**Available Tools**:
- `linear_create_issue` - Create Linear issue
- `linear_update_issue` - Update issue
- `linear_search` - Search issues

**Common Pattern**:
```markdown
## Pattern: Create Linear Issues from Tasks

1. Read tasks.md for task breakdown
2. For each task with priority P1 or P2:
   - Call linear_create_issue with:
     - team_id: from config
     - title: task title
     - description: task details
     - priority: map P1→Urgent, P2→High, P3→Normal
3. Store returned issue IDs in tasks metadata
4. Track in .specter-memory/CHANGES-PLANNED.md
```

### GitHub

**Available Tools**:
- `github_create_issue` - Create GitHub issue
- `github_create_pr` - Create pull request
- `github_search` - Search issues/PRs

**Common Pattern**:
```markdown
## Pattern: Create GitHub Issues from Tasks

1. Read tasks.md
2. Filter tasks by type (bug, feature, enhancement)
3. For each task:
   - Call github_create_issue with:
     - owner: from git config
     - repo: from git config
     - title: task title
     - body: formatted task description
     - labels: ["spec-generated", priority, type]
4. Link issues in tasks.md
```

## Detection Pattern

**How to detect available MCPs**:

```markdown
1. Check if MCP tools are available in current context
2. Read user's CLAUDE.md for configuration
3. If SPECTER_*_SYNC=enabled, use that integration
4. If no config found, ask user if they want to enable MCP sync
```

**Example Detection Code** (for skills to reference):

```bash
# Check for JIRA MCP
if grep -q "SPECTER_ATLASSIAN_SYNC=enabled" CLAUDE.md 2>/dev/null; then
    echo "JIRA integration available"
    PROJECT_KEY=$(grep "SPECTER_JIRA_PROJECT_KEY" CLAUDE.md | cut -d= -f2)
fi

# Check for Linear MCP
if grep -q "SPECTER_LINEAR_SYNC=enabled" CLAUDE.md 2>/dev/null; then
    echo "Linear integration available"
    TEAM_ID=$(grep "SPECTER_LINEAR_TEAM_ID" CLAUDE.md | cut -d= -f2)
fi
```

## Error Handling

**Common MCP Errors**:

1. **MCP not configured**:
   - Detection: Tool calls fail with "tool not available"
   - Recovery: Continue without MCP, save artifacts locally
   - User message: "MCP integration not configured. Artifacts saved locally."

2. **Authentication failed**:
   - Detection: 401/403 errors
   - Recovery: Prompt user to check credentials
   - User message: "MCP authentication failed. Check your credentials in settings."

3. **Network issues**:
   - Detection: Timeout or connection errors
   - Recovery: Retry once, then fall back to local
   - User message: "MCP temporarily unavailable. Continuing locally."

4. **Invalid configuration**:
   - Detection: Missing required fields
   - Recovery: Ask user for missing config
   - User message: "MCP config incomplete. Need: [missing fields]"

## Best Practices

1. **Always fall back to local**: If MCP fails, continue workflow locally
2. **Ask before syncing**: Get user confirmation before creating external resources
3. **Store links**: Always store MCP resource links in memory files
4. **Batch operations**: Create multiple issues/pages in batch when possible
5. **Validate config**: Check configuration before attempting MCP calls
6. **Graceful degradation**: Never block workflow on MCP failures

## Usage in Skills

**When to reference this file**:

```markdown
## In SKILL.md:

For MCP integration patterns (JIRA, Confluence, Linear, GitHub), see:
`shared/integration-patterns.md`

## When to load:

- User mentions "sync with JIRA"
- User mentions "create Confluence page"
- User mentions "external issue tracker"
- Config file shows SPECTER_*_SYNC=enabled
```

## Related Files

- `shared/workflow-patterns.md` - Common workflow patterns
- `shared/state-management.md` - State file management
- Individual skill REFERENCEs for skill-specific MCP usage

---

**Last Updated**: 2025-10-31
**Used By**: spec:generate, spec:plan, spec:tasks, spec:update, spec:orchestrate
**Token Size**: ~1,200 tokens
