---
name: flow:update
description: Detect newly configured MCP servers and extend Flow with new integrations without breaking existing functionality. Self-modifying skill that adapts Flow to your toolchain.
---

# Flow Update: Extensibility & MCP Discovery

Automatically detect and integrate new MCP servers into Flow workflows without code changes.

## When to Use

- Added new MCP servers to your project
- Want to enable GitHub, Linear, Sentry, or custom MCPs
- Need to update Flow to use new integrations
- Exploring available MCP capabilities

## What This Skill Does

1. **Scans** for MCP servers via `/mcp` command
2. **Compares** against `.flow/extensions.json` registry
3. **Identifies** new or unconfigured servers
4. **Analyzes** capabilities of each MCP
5. **Suggests** Flow skill enhancements
6. **Generates** templates for new integrations
7. **Updates** CLAUDE.md configuration
8. **Non-breaking** - existing functionality preserved

## Execution Workflow

### Phase 1: MCP Discovery

```javascript
// Run MCP command to get connected servers
const mcpServers = await bash('/mcp');

// Parse server list
const connectedServers = parseMcpOutput(mcpServers);

// Load known extensions registry
const registry = await readJson('.flow/extensions.json');

// Identify new servers
const newServers = connectedServers.filter(
  server => !registry.knownServers[server]
);

// Identify unconfigured servers
const unconfigured = connectedServers.filter(
  server => registry.knownServers[server] && !isConfigured(server)
);
```

### Phase 2: Capability Analysis

**For each new MCP server**:
1. Query MCP for capabilities
2. Match capabilities to Flow skills:
   - Issue tracking → `flow:specify`, `flow:tasks`
   - Documentation → `flow:plan`
   - Version control → `flow:implement`
   - Monitoring → `flow:specify` (error context)

3. Generate enhancement suggestions

### Phase 3: Interactive Configuration

```
Flow: Detected new MCP servers!

┌─────────────────────────────────────────────────────────┐
│ GitHub MCP                                              │
├─────────────────────────────────────────────────────────┤
│ Capabilities:                                           │
│ • Create/update issues                                  │
│ • Create pull requests                                  │
│ • Manage projects                                       │
│                                                          │
│ Suggested Flow enhancements:                            │
│ ✓ flow:tasks - Sync tasks to GitHub Projects          │
│ ✓ flow:implement - Auto-create PRs with context       │
│                                                          │
│ Enable GitHub integration? [Y/n]                        │
└─────────────────────────────────────────────────────────┘

User: Y

Flow: Configure GitHub integration:
      GitHub Project ID (optional):
User:

Flow: ✓ GitHub integration enabled!
      Updated: CLAUDE.md, .flow/extensions.json
      Created: plugins/flow/templates/templates/github-pr-template.md
```

### Phase 4: Template Generation

**For each enabled integration**:
1. Check if templates exist in registry
2. Generate templates from patterns:
   - Issue templates (GitHub, Linear, JIRA)
   - PR templates (GitHub, GitLab)
   - Document templates (Notion, Confluence)

3. Save to `plugins/flow/templates/templates/`

### Phase 5: Configuration Updates

**Update CLAUDE.md**:
```markdown
## Flow Configuration

### Feature Toggles
FLOW_ATLASSIAN_SYNC=enabled
FLOW_GITHUB_SYNC=enabled             # NEW
FLOW_GITHUB_PROJECT_ID=PVT_123       # NEW
```

**Update .flow/extensions.json**:
```json
{
  "knownServers": {
    "Atlassian": { ... },
    "github": {                       // NEW
      "package": "@modelcontextprotocol/server-github",
      "capabilities": ["issues", "pull-requests", "projects"],
      "enhances": {
        "flow:tasks": "Sync to GitHub Projects",
        "flow:implement": "Auto-create PRs"
      },
      "configuredAt": "2025-10-20T12:00:00Z"
    }
  }
}
```

## MCP Server Patterns

### Issue Tracking MCPs

**Supported**: JIRA, Linear, GitHub Issues, GitLab Issues

**Enhancements**:
- `flow:specify` - Create issues from user stories
- `flow:tasks` - Create subtasks/sub-issues
- `flow:implement` - Update status on completion

### Documentation MCPs

**Supported**: Confluence, Notion, GitBook

**Enhancements**:
- `flow:specify` - Sync spec to docs
- `flow:plan` - Publish implementation plans
- `flow:constitution` - Share governance docs

### Version Control MCPs

**Supported**: GitHub, GitLab, Bitbucket

**Enhancements**:
- `flow:implement` - Auto-create PRs
- `flow:tasks` - Link to commits/branches
- `flow:analyze` - Check for conflicts

### Monitoring MCPs

**Supported**: Sentry, Datadog, New Relic

**Enhancements**:
- `flow:specify` - Reference error IDs in specs
- `flow:plan` - Include error patterns in planning
- `flow:implement` - Link deployments to tickets

## Custom MCP Integration

### Adding Unknown MCPs

**If MCP not in registry**:
```
Flow: Found new MCP: "custom-mcp"
      This server is not in the Flow registry.

      Detected capabilities:
      • custom_capability_1
      • custom_capability_2

      Would you like to add this MCP to Flow? [Y/n]

User: Y

Flow: How should Flow use this MCP?

      Which skills should integrate with "custom-mcp"?
      [1] flow:specify
      [2] flow:plan
      [3] flow:tasks
      [4] flow:implement
      [5] Custom integration

User: 3,4

Flow: ✓ Created custom integration!
      • flow:tasks will check for custom-mcp
      • flow:implement will use custom capabilities
      • Configuration saved to .flow/extensions.json
```

### Registry Entry Format

```json
{
  "custom-mcp": {
    "package": "npx custom-mcp@latest",
    "capabilities": ["capability_1", "capability_2"],
    "enhances": {
      "flow:tasks": "Custom task sync",
      "flow:implement": "Custom completion hooks"
    },
    "configuration": {
      "required": ["CUSTOM_API_KEY"],
      "optional": ["CUSTOM_PROJECT_ID"]
    },
    "templates": ["custom-template.md"]
  }
}
```

## Non-Breaking Updates

### Backward Compatibility

**Guaranteed**:
- Existing skills work without new MCPs
- Configuration is opt-in
- Disabling MCP doesn't break workflows
- Local-first always works

**Pattern**:
```javascript
// Skills check if MCP is enabled
if (config.FLOW_GITHUB_SYNC === 'enabled') {
  // Use GitHub MCP
  await syncToGitHub();
} else {
  // Local-only workflow (works as before)
  continueLocalWorkflow();
}
```

### Gradual Adoption

**Enable one MCP at a time**:
1. Run `flow:update`
2. Enable one integration
3. Test workflow
4. Enable next integration
5. Repeat

**Rollback**:
- Set `FLOW_XXX_SYNC=disabled` in CLAUDE.md
- Skills automatically skip MCP calls
- No code changes needed

## Examples

### Adding GitHub Projects

```
User: flow:update

Flow: Scanning for MCP servers...
Flow: ✓ Found: Atlassian (configured)
Flow: ✓ Found: GitHub (NEW!)

Flow: Enable GitHub Projects integration? [Y/n]
User: Y

Flow: GitHub Project ID (optional):
User: PVT_kwDOABCD123

Flow: ✓ GitHub integration enabled!

      Enhanced skills:
      • flow:tasks - Now syncs to GitHub Projects
      • flow:implement - Now creates PRs automatically

      Next: Run flow:tasks to sync existing tasks
```

### Reconfiguring After Adding MCP

```
User: I just added Linear MCP, update Flow

Flow: Detected Linear MCP!

Flow: Linear capabilities:
      • Create issues
      • Update issue status
      • Add comments

      Suggested enhancements:
      • Sync user stories to Linear issues
      • Track tasks as Linear sub-issues
      • Update status during implementation

      Enable Linear integration? [Y/n]
User: Y

Flow: Linear API Key:
User: lin_api_...

Flow: Linear Team ID:
User: TEAM-abc123

Flow: ✓ Linear configured!
      Updated CLAUDE.md with configuration
      Created linear-issue-template.md

      Your next flow:specify will create Linear issues!
```

## Configuration Reference

### CLAUDE.md Variables

```
# MCP Integration Toggles
FLOW_ATLASSIAN_SYNC=enabled
FLOW_GITHUB_SYNC=enabled
FLOW_LINEAR_SYNC=disabled
FLOW_SENTRY_SYNC=enabled

# Integration-Specific Config
FLOW_GITHUB_PROJECT_ID=PVT_123
FLOW_LINEAR_TEAM_ID=TEAM-abc
FLOW_SENTRY_PROJECT=my-project
```

### Extension Registry

**Location**: `.flow/extensions.json`

**Purpose**:
- Documents available MCPs
- Maps capabilities to skills
- Stores configuration schema
- Tracks templates

## Related Skills

- **flow:init** - Initial MCP setup during project creation
- **flow:specify** - Uses MCPs for issue/doc creation
- **flow:plan** - Uses MCPs for documentation sync
- **flow:tasks** - Uses MCPs for task management
- **flow:implement** - Uses MCPs for status updates

## Troubleshooting

### "No new MCPs detected"
- Run `/mcp` to verify servers are connected
- Check `.mcp.json` in project root
- Verify MCP package is installed

### "MCP capabilities not detected"
- Some MCPs require authentication first
- Run a skill that uses the MCP to trigger auth
- Then run `flow:update` again

### "Template generation failed"
- Check write permissions in plugins/flow/templates/
- Verify template patterns in .flow/extensions.json
- Manually create template if needed

### "Configuration not persisting"
- Check CLAUDE.md is writable
- Verify .flow/extensions.json exists
- Ensure proper JSON formatting

## Future Enhancements

1. **Auto-discovery**: Detect MCP capabilities automatically
2. **Template marketplace**: Community-contributed templates
3. **Multi-MCP workflows**: Use multiple MCPs together
4. **Smart suggestions**: ML-based integration recommendations
5. **Health checks**: Monitor MCP connectivity and performance
