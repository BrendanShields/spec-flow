---
name: flow:update
description: Detect and integrate new MCP servers into Flow. Use when 1) New MCP connected and need Flow integration, 2) User says "add/configure [integration]", 3) Extending Flow with Linear/Sentry/GitHub, 4) Auto-adapting workflows to available tools, 5) Checking for new integration capabilities. Evolves with your toolchain.
allowed-tools: Bash, Read, Write, Edit
---

# Flow Update

Automatically detect and integrate new MCP servers into Flow workflows without code changes.

## Core Workflow

### 1. Scan for MCP Servers

Detect all connected MCP servers:
```bash
/mcp  # Lists connected servers
```

Compare against `__specification__/extensions.json` registry to identify:
- **New servers**: Never configured
- **Configured servers**: Already set up
- **Unconfigured servers**: Known but not enabled

### 2. Analyze Capabilities

For each new MCP:
- Query capabilities (if supported by MCP)
- Match to Flow skills:
  - Issue tracking → `flow:specify`, `flow:tasks`, `flow:implement`
  - Documentation → `flow:plan`, `flow:specify`
  - Version control → `flow:implement` (PR creation)
  - Monitoring → `flow:specify` (error context), `flow:discover`
- Generate enhancement suggestions

### 3. Interactive Configuration

Prompt for each new MCP:

**Known MCP** (Atlassian, GitHub, Linear):
```
✓ Detected: GitHub MCP

Capabilities:
• Create/update issues
• Create pull requests
• Manage projects

Suggested Flow enhancements:
✓ flow:tasks - Sync to GitHub Projects
✓ flow:implement - Auto-create PRs

Enable GitHub integration? [Y/n]
```

**Unknown MCP**:
```
Found new MCP: "custom-tracker"

Detected capabilities:
• create_task
• update_status

Which skills should use this MCP?
[1] flow:specify
[2] flow:plan
[3] flow:tasks
[4] flow:implement
[5] Custom integration
```

### 4. Collect Configuration

**Atlassian**:
- JIRA Project Key
- Confluence Root Page ID
- Branch naming preference

**GitHub**:
- GitHub Project ID (optional)
- Auto-PR setting

**Linear**:
- Linear API Key
- Linear Team ID

**Sentry**:
- Sentry Project
- Error threshold for auto-spec

**Custom MCPs**:
- MCP-specific required fields
- Sync mode (one-way, two-way, pull-only)
- Behavioral options

### 5. Update Configuration

**Update CLAUDE.md**:
```markdown
## Flow Configuration

### MCP Integration Toggles
FLOW_ATLASSIAN_SYNC=enabled
FLOW_GITHUB_SYNC=enabled
FLOW_LINEAR_SYNC=disabled
FLOW_SENTRY_SYNC=enabled

### Integration-Specific Config
FLOW_GITHUB_PROJECT_ID=PVT_123
FLOW_LINEAR_TEAM_ID=TEAM-abc
FLOW_SENTRY_PROJECT=my-project
```

**Update __specification__/extensions.json**:
```json
{
  "version": "1.0",
  "knownServers": {
    "github": {
      "package": "@modelcontextprotocol/server-github",
      "capabilities": ["issues", "pull-requests", "projects"],
      "enhances": {
        "flow:tasks": "Sync to GitHub Projects",
        "flow:implement": "Auto-create PRs"
      },
      "configuredAt": "2025-10-24T14:30:00Z"
    }
  }
}
```

### 6. Generate Templates

Create integration-specific templates:
- `jira-story-template.md` (Atlassian)
- `github-pr-template.md` (GitHub)
- `linear-issue-template.md` (Linear)
- `custom-[name]-template.md` (Custom MCPs)

Save to `__specification__/templates/`

### 7. Completion Message

```
✓ GitHub integration enabled!

Enhanced skills:
• flow:tasks - Now syncs to GitHub Projects
• flow:implement - Now creates PRs automatically

Updated:
  CLAUDE.md
  __specification__/extensions.json

Created:
  __specification__/templates/github-pr-template.md

Next: Run flow:tasks to sync existing tasks
```

## Command-Line Flags

**`--reconfigure [MCP_NAME]`**
Update existing MCP configuration.
- With MCP name: Reconfigure that specific integration
- Without: Prompt to select which to reconfigure

**`--disable [MCP_NAME]`**
Disable MCP without removing configuration.
- Sets `FLOW_XXX_SYNC=disabled`
- Preserves config for re-enabling

**`--enable [MCP_NAME]`**
Re-enable previously disabled MCP.
- Sets `FLOW_XXX_SYNC=enabled`
- Uses existing configuration

**`--list`**
Show all configured MCPs and their status.

## MCP Patterns

### Issue Tracking
**Examples**: JIRA, Linear, GitHub Issues
**Enhances**: flow:specify, flow:tasks, flow:implement
**Config**: Project key, team ID

### Documentation
**Examples**: Confluence, Notion
**Enhances**: flow:specify, flow:plan
**Config**: Space ID, parent page

### Version Control
**Examples**: GitHub, GitLab
**Enhances**: flow:implement
**Config**: Repository, auto-PR settings

### Monitoring
**Examples**: Sentry, Datadog
**Enhances**: flow:specify, flow:discover
**Config**: Project ID, error threshold

## Custom MCP Integration

For unknown MCPs:
1. Detect capabilities (if introspection supported)
2. Prompt user for skill mapping
3. Collect MCP-specific configuration
4. Generate registry entry
5. Create templates (if applicable)

**Registry format**:
```json
{
  "custom-mcp": {
    "package": "npx custom-mcp@latest",
    "capabilities": ["create_task", "update_status"],
    "enhances": {
      "flow:tasks": "Description",
      "flow:implement": "Description"
    },
    "configuration": {
      "required": ["api_key", "project_id"],
      "optional": ["webhook_url"]
    }
  }
}
```

## Non-Breaking Updates

**Guaranteed**:
- Existing skills work without new MCPs
- Configuration is opt-in
- Disabling MCP doesn't break workflows
- Local-first always works

**Pattern**:
```javascript
if (config.FLOW_GITHUB_SYNC === 'enabled') {
  await syncToGitHub();
} else {
  // Local workflow (works as before)
  continueLocalWorkflow();
}
```

## Gradual Adoption

Enable one MCP at a time:
1. Run `flow:update`
2. Enable one integration
3. Test workflow
4. Enable next integration
5. Repeat

**Rollback**: Set `FLOW_XXX_SYNC=disabled` in CLAUDE.md

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Adding GitHub Projects
- Adding Linear
- Custom MCP integration
- Multiple MCPs at once
- Sentry error context
- Reconfiguring existing MCP
- Disabling integration
- Troubleshooting

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete flag documentation
- MCP discovery process
- Configuration patterns
- Template generation logic
- Skill enhancement mapping
- Custom MCP integration details
- Backward compatibility guarantees
- Testing MCP integration
- Advanced configuration options

## Related Skills

- **flow:init**: Initial MCP setup (run first)
- **flow:specify**: Enhanced by MCPs (creates JIRA/Linear issues)
- **flow:plan**: Enhanced by MCPs (syncs to Confluence)
- **flow:tasks**: Enhanced by MCPs (syncs to GitHub/JIRA)
- **flow:implement**: Enhanced by MCPs (creates PRs, updates status)

## Validation

Test this skill:
```bash
scripts/validate.sh
```

Validates: YAML syntax, description format, token count, modular resources, activation patterns.
