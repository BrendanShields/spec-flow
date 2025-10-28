# Flow Update Reference

## Command-Line Flags

### `--reconfigure [MCP_NAME]`

Reconfigure an existing MCP integration.

**Usage**:
```bash
flow:update --reconfigure Atlassian
flow:update --reconfigure GitHub
flow:update --reconfigure
```

**With specific MCP**: Reconfigures only that integration
**Without MCP**: Prompts to select which integration to reconfigure

---

### `--disable [MCP_NAME]`

Disable an MCP integration without removing configuration.

**Usage**:
```bash
flow:update --disable Linear
flow:update --disable GitHub
```

**Effects**:
- Sets `FLOW_XXX_SYNC=disabled` in CLAUDE.md
- Preserves configuration values
- Keeps templates
- Skills skip this MCP

**Re-enable**: Use `flow:update --enable [MCP_NAME]`

---

### `--enable [MCP_NAME]`

Re-enable a previously disabled MCP integration.

**Usage**:
```bash
flow:update --enable Linear
```

**Effects**:
- Sets `FLOW_XXX_SYNC=enabled` in CLAUDE.md
- Uses existing configuration
- No re-authentication needed (if token valid)

---

### `--list`

List all configured MCP integrations and their status.

**Usage**:
```bash
flow:update --list
```

**Output**:
```
Configured MCP Integrations:
┌─────────────┬──────────┬─────────────────────────────┐
│ MCP         │ Status   │ Enhances                    │
├─────────────┼──────────┼─────────────────────────────┤
│ Atlassian   │ enabled  │ specify, plan, tasks        │
│ GitHub      │ enabled  │ tasks, implement            │
│ Linear      │ disabled │ specify, tasks, implement   │
│ Sentry      │ enabled  │ specify, discover           │
└─────────────┴──────────┴─────────────────────────────┘

Total: 4 configured (3 active, 1 disabled)
```

---

## MCP Discovery Process

### 1. Detect Connected Servers

```javascript
// Run /mcp command
const mcpOutput = await bash('/mcp');

// Example output:
// Connected MCP Servers:
// - Atlassian
// - github
// - custom-mcp

// Parse output
const connectedServers = parseMcpOutput(mcpOutput);
// ['Atlassian', 'github', 'custom-mcp']
```

---

### 2. Load Known Registry

```javascript
// Read __specification__/extensions.json
const registry = JSON.parse(
  fs.readFileSync('__specification__/extensions.json', 'utf-8')
);

// Example registry:
{
  "knownServers": {
    "Atlassian": {
      "configured": true,
      "configuredAt": "2025-10-20T12:00:00Z"
    }
  }
}
```

---

### 3. Identify New vs Configured

```javascript
// Categorize servers
const newServers = connectedServers.filter(
  server => !registry.knownServers[server]
);

const configured = connectedServers.filter(
  server => registry.knownServers[server]?.configured
);

const unconfigured = connectedServers.filter(
  server =>
    registry.knownServers[server] &&
    !registry.knownServers[server].configured
);

// Results:
// newServers: ['github', 'custom-mcp']
// configured: ['Atlassian']
// unconfigured: []
```

---

### 4. Capability Detection

```javascript
// Query MCP for capabilities (if supported)
const capabilities = await mcp.queryCapabilities(serverName);

// Map capabilities to Flow skills
const enhancements = mapCapabilitiesToSkills(capabilities);

// Example mapping:
{
  capabilities: ['create_issue', 'update_issue', 'add_comment'],
  enhances: {
    'flow:specify': 'Create issues from specs',
    'flow:tasks': 'Create sub-issues for tasks',
    'flow:implement': 'Update issue status'
  }
}
```

---

## Configuration Patterns

### Known MCP Patterns

**Issue Tracking MCPs**:
```json
{
  "pattern": "issue-tracking",
  "examples": ["Atlassian", "Linear", "GitHub Issues"],
  "capabilities": ["create_issue", "update_issue", "comment"],
  "enhances": ["flow:specify", "flow:tasks", "flow:implement"],
  "configuration": {
    "required": ["project_key", "team_id"],
    "optional": ["auto_sync", "status_mapping"]
  }
}
```

**Documentation MCPs**:
```json
{
  "pattern": "documentation",
  "examples": ["Confluence", "Notion", "GitBook"],
  "capabilities": ["create_page", "update_page"],
  "enhances": ["flow:specify", "flow:plan"],
  "configuration": {
    "required": ["space_id", "parent_page"],
    "optional": ["template_id", "auto_publish"]
  }
}
```

**Version Control MCPs**:
```json
{
  "pattern": "version-control",
  "examples": ["GitHub", "GitLab", "Bitbucket"],
  "capabilities": ["create_pr", "create_branch", "add_comment"],
  "enhances": ["flow:implement"],
  "configuration": {
    "required": ["repository"],
    "optional": ["auto_pr", "reviewer_assignment"]
  }
}
```

**Monitoring MCPs**:
```json
{
  "pattern": "monitoring",
  "examples": ["Sentry", "Datadog", "New Relic"],
  "capabilities": ["query_errors", "get_metrics"],
  "enhances": ["flow:specify", "flow:discover"],
  "configuration": {
    "required": ["project_id"],
    "optional": ["error_threshold", "auto_spec"]
  }
}
```

---

## Template Generation

### Template Mapping

Flow automatically generates templates for new integrations:

```javascript
const templateMap = {
  // Issue tracking
  'jira-story-template.md': 'Atlassian',
  'linear-issue-template.md': 'Linear',
  'github-issue-template.md': 'GitHub',

  // Documentation
  'confluence-page.md': 'Atlassian',
  'notion-page.md': 'Notion',

  // Version control
  'github-pr-template.md': 'GitHub',
  'gitlab-mr-template.md': 'GitLab',

  // Custom
  'custom-[name]-template.md': 'custom-mcp'
};
```

---

### Template Generation Logic

```javascript
function generateTemplate(mcpName, pattern) {
  // 1. Identify MCP pattern
  const patternType = detectPattern(mcpName);

  // 2. Load base template
  const baseTemplate = loadBaseTemplate(patternType);

  // 3. Customize for MCP
  const customized = customizeTemplate(baseTemplate, mcpName);

  // 4. Save to __specification__/templates/
  fs.writeFileSync(
    `__specification__/templates/${mcpName}-template.md`,
    customized
  );
}

// Example: GitHub PR template
function generateGitHubPRTemplate() {
  return `# Pull Request: {FEATURE_NAME}

## Summary
{FEATURE_SUMMARY}

## Changes
{CHANGES_SUMMARY}

## Related Issues
- Closes #{JIRA_ID}
- Addresses #{GITHUB_ISSUE}

## Test Plan
{TEST_SCENARIOS}

---
🤖 Generated with Flow
`;
}
```

---

## Skill Enhancement Mapping

### How MCPs Enhance Skills

**flow:specify**:
```javascript
// Without MCP
flow:specify("Feature")
  → Creates local spec.md only

// With JIRA
flow:specify("Feature")
  → Creates spec.md
  → Creates JIRA epic + stories
  → Syncs to Confluence

// With Linear
flow:specify("Feature")
  → Creates spec.md
  → Creates Linear issue
  → Links to spec

// With Sentry
flow:specify("Fix error SENTRY-123")
  → Pulls error context from Sentry
  → Creates spec with stack traces
  → Links affected users
```

---

**flow:tasks**:
```javascript
// Without MCP
flow:tasks
  → Creates tasks.md only

// With JIRA
flow:tasks
  → Creates tasks.md
  → Creates JIRA subtasks
  → Links to parent stories

// With GitHub
flow:tasks
  → Creates tasks.md
  → Syncs to GitHub Project
  → Creates issue per task
```

---

**flow:implement**:
```javascript
// Without MCP
flow:implement
  → Executes tasks
  → Marks complete in tasks.md

// With JIRA
flow:implement
  → Executes tasks
  → Updates JIRA subtask status
  → Adds implementation notes

// With GitHub
flow:implement
  → Executes tasks
  → Updates GitHub Project items
  → Auto-creates PR with context
```

---

## Custom MCP Integration

### Adding Unknown MCPs

When Flow encounters an MCP not in the registry:

1. **Detect Capabilities** (if MCP supports introspection)
2. **Prompt User** for integration details
3. **Generate Registry Entry**
4. **Create Templates** (if applicable)
5. **Update Configuration**

---

### Registry Entry Format

```json
{
  "custom-mcp": {
    "package": "npx custom-mcp@latest",
    "version": "1.0.0",
    "capabilities": [
      "create_task",
      "update_status",
      "get_metrics"
    ],
    "enhances": {
      "flow:tasks": "Sync tasks to custom system",
      "flow:implement": "Update task status on completion",
      "flow:metrics": "Pull custom metrics"
    },
    "configuration": {
      "required": ["api_key", "project_id"],
      "optional": ["webhook_url", "sync_interval"]
    },
    "syncMode": "one-way",
    "templates": [
      "custom-task-template.md"
    ],
    "configuredAt": "2025-10-24T15:30:00Z"
  }
}
```

---

### Integration Configuration Prompts

```javascript
function promptCustomIntegration(mcpName) {
  // 1. Which skills to enhance
  const skills = promptMultiSelect([
    'flow:specify',
    'flow:plan',
    'flow:tasks',
    'flow:implement',
    'Custom integration'
  ]);

  // 2. Sync mode
  const syncMode = promptSelect([
    'One-way (Flow → MCP)',
    'Two-way (bidirectional)',
    'Pull-only (MCP → Flow)'
  ]);

  // 3. Required configuration
  const config = promptConfig(detectRequiredFields(mcpName));

  // 4. Behavioral options
  const behavior = promptOptions({
    autoSync: 'Sync automatically?',
    updateOnComplete: 'Update on task completion?',
    createOnSpecify: 'Create item on specify?'
  });

  return {
    skills,
    syncMode,
    config,
    behavior
  };
}
```

---

## Configuration Reading

### How Skills Read MCP Configuration

```javascript
// Load configuration
function loadFlowConfig() {
  const claudeMd = fs.readFileSync('CLAUDE.md', 'utf-8');
  const config = parseFlowConfig(claudeMd);

  const extensions = JSON.parse(
    fs.readFileSync('__specification__/extensions.json', 'utf-8')
  );

  return { config, extensions };
}

// Check if MCP enabled
function isMcpEnabled(mcpName) {
  const { config } = loadFlowConfig();
  const key = `FLOW_${mcpName.toUpperCase()}_SYNC`;
  return config[key] === 'enabled';
}

// Get MCP configuration
function getMcpConfig(mcpName) {
  const { config, extensions } = loadFlowConfig();

  return {
    enabled: isMcpEnabled(mcpName),
    server: extensions.knownServers[mcpName],
    settings: extractMcpSettings(config, mcpName)
  };
}

// Example usage in flow:specify
async function createJiraStory(spec) {
  if (!isMcpEnabled('Atlassian')) {
    return; // Skip JIRA creation
  }

  const { settings } = getMcpConfig('Atlassian');
  const projectKey = settings.FLOW_JIRA_PROJECT_KEY;

  await mcp.jira.createIssue({
    projectKey,
    issueType: 'Story',
    summary: spec.title,
    description: spec.description
  });
}
```

---

## Backward Compatibility

### Non-Breaking Updates

Flow guarantees backward compatibility:

**Principle 1**: Existing skills work without new MCPs
```javascript
// Skills check if MCP enabled before using
if (isMcpEnabled('GitHub')) {
  await syncToGitHub();
} else {
  // Continue with local-only workflow
}
```

**Principle 2**: Configuration is opt-in
- Default: All new MCPs disabled
- User must explicitly enable
- No automatic behavior changes

**Principle 3**: Disabling MCP doesn't break workflows
```javascript
// Graceful degradation
try {
  if (isMcpEnabled('JIRA')) {
    await syncToJira();
  }
} catch (error) {
  // Continue without JIRA sync
  logger.warn('JIRA sync failed, continuing locally');
}
```

---

## Advanced Configuration

### Priority Order

When multiple MCPs provide same capability (e.g., issue tracking):

```
Priority: JIRA > Linear > GitHub > Custom
```

Configured in CLAUDE.md:
```markdown
FLOW_ISSUE_TRACKING_PRIORITY=JIRA,Linear,GitHub
```

---

### Conditional Integration

Enable MCPs based on conditions:

```markdown
# Development: Local only
FLOW_ATLASSIAN_SYNC=disabled
FLOW_GITHUB_SYNC=enabled

# Staging: GitHub + Sentry
FLOW_GITHUB_SYNC=enabled
FLOW_SENTRY_SYNC=enabled

# Production: All integrations
FLOW_ATLASSIAN_SYNC=enabled
FLOW_GITHUB_SYNC=enabled
FLOW_SENTRY_SYNC=enabled
FLOW_LINEAR_SYNC=enabled
```

Use environment-specific CLAUDE.md or .local.json overrides.

---

### Webhook Configuration

Some MCPs support webhooks for bidirectional sync:

```json
{
  "webhooks": {
    "enabled": true,
    "url": "https://your-server.com/flow-webhook",
    "events": ["issue.updated", "pr.merged"],
    "secret": "WEBHOOK_SECRET_FROM_ENV"
  }
}
```

Flow can receive updates from MCPs and update local specs/tasks.

---

## Testing MCP Integration

### Manual Testing

```bash
# 1. Enable MCP
flow:update

# 2. Create test spec
flow:specify "Test MCP integration"

# 3. Verify MCP received data
# Check JIRA/Linear/GitHub for created item

# 4. Test sync
flow:tasks

# 5. Verify tasks synced
# Check MCP for created subtasks/items

# 6. Test status updates
flow:implement

# 7. Verify status updated in MCP
```

---

### Automated Testing

```bash
# Create test script
cat > test-mcp-integration.sh <<'EOF'
#!/bin/bash

# Test MCP is connected
/mcp | grep -q "GitHub" || exit 1

# Enable MCP
flow:update --enable GitHub

# Create test feature
flow:specify "Test feature for MCP"

# Verify created in MCP
gh issue list | grep -q "Test feature" || exit 1

# Cleanup
gh issue close "Test feature"

echo "✓ MCP integration test passed"
EOF
```

---

## Troubleshooting

### Configuration Debugging

```bash
# View current configuration
grep FLOW_ CLAUDE.md

# View registry
cat __specification__/extensions.json | jq '.knownServers'

# Test MCP connection
/mcp

# Check MCP logs (if available)
tail -f ~/.claude/mcp-logs/[mcp-name].log
```

---

### Common Issues

**Issue**: MCP detected but won't configure
**Cause**: MCP requires authentication first
**Solution**: Use MCP once to trigger auth, then run flow:update

---

**Issue**: Configuration saved but not working
**Cause**: Typo in configuration keys
**Solution**: Validate keys match MCP expectations

---

**Issue**: Multiple MCPs conflicting
**Cause**: Both enabled for same capability
**Solution**: Set priority or disable one

---

## Related Skills

- **flow:init**: Initial MCP setup (run first)
- **flow:specify**: Uses MCP integrations (enhanced by update)
- **flow:tasks**: Uses MCP integrations (enhanced by update)
- **flow:implement**: Uses MCP integrations (enhanced by update)

---

## Version History

- **v1.0**: Initial release with Atlassian support
- **v1.1**: Added GitHub Projects integration
- **v1.2**: Custom MCP support
- **v1.3**: Multi-MCP configuration
- **v2.0**: Enhanced capability detection
