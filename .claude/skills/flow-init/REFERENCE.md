# Flow Init Reference

## Command-Line Flags

### `--type greenfield|brownfield`

Explicitly set project type without prompting.

**Greenfield**: New project
- Creates full .flow/ structure
- Prompts for architecture blueprint
- Sets up project-level specs
- Configures all templates

**Brownfield**: Existing codebase
- Creates .flow/ structure
- Focuses on feature-level specs
- Suggests codebase analysis first
- Simplified initial setup

**Example**:
```bash
flow:init --type greenfield
flow:init --type brownfield
```

---

### `--skip-integrations`

Skip MCP detection and integration setup.

**Use when**:
- POC/spike projects
- Solo developers without integrations
- Quick local-only setup
- CI/CD environments

**Example**:
```bash
flow:init --skip-integrations
```

**Result**: Creates minimal .flow/ structure, no MCP configuration.

---

### `--reconfigure`

Re-run configuration for existing Flow project.

**Use when**:
- New MCP servers added
- Changing integration settings
- Updating workflow defaults
- Fixing configuration issues

**Example**:
```bash
flow:init --reconfigure
```

**Safe**: Preserves existing .flow/ content, only updates configuration.

---

## Directory Structure Created

### Standard Structure (All Projects)

```
.flow/
├── product-requirements.md      # Project-level PRD (skeleton)
├── architecture-blueprint.md    # Technical standards (skeleton)
├── data-models/
│   └── entities.md             # Domain entities
├── scripts/
│   ├── common.sh               # Shared utilities
│   ├── create-new-feature.sh   # Feature initialization
│   └── check-prerequisites.sh  # Validation script
└── templates/
    ├── spec-template.md
    ├── plan-template.md
    ├── tasks-template.md
    ├── product-requirements-template.md
    └── architecture-blueprint-template.md
```

### API Project Addition

If API project detected (user confirms):

```
.flow/
└── contracts/
    ├── openapi.yaml            # REST API specification
    └── README.md               # Contract documentation
```

Templates added:
- `endpoint-template.md`
- `resource-template.md`

---

### With Atlassian Integration

If Atlassian MCP enabled:

```
.flow/
├── extensions.json             # MCP registry
└── templates/
    ├── jira-story-template.md
    └── confluence-page.md
```

---

### With GitHub Integration

If GitHub MCP enabled:

```
.flow/
└── templates/
    └── github-pr-template.md
```

---

## Configuration Storage

### CLAUDE.md (Version-Controlled)

Configuration stored as simple text variables in CLAUDE.md:

```markdown
## Flow Configuration

### Feature Toggles
FLOW_ATLASSIAN_SYNC=enabled
FLOW_GITHUB_SYNC=disabled
FLOW_BRANCH_PREPEND_JIRA=true
FLOW_REQUIRE_BLUEPRINT=false
FLOW_REQUIRE_ANALYSIS=false

### Integration Settings
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
FLOW_GITHUB_PROJECT_ID=PVT_123

### Workflow Defaults
FLOW_TESTS_REQUIRED=false
FLOW_STORY_FORMAT=bdd
```

**Benefits**:
- Simple text format (no JSON parsing)
- Version controlled
- Team shares same config
- Easy to enable/disable features
- Readable diffs

---

### .flow/extensions.json (MCP Registry)

Tracks available MCP servers and their capabilities:

```json
{
  "version": "1.0",
  "knownServers": {
    "Atlassian": {
      "package": "@modelcontextprotocol/server-atlassian",
      "capabilities": ["jira", "confluence"],
      "enhances": {
        "flow:specify": "Create/update JIRA stories",
        "flow:plan": "Sync to Confluence",
        "flow:tasks": "Create JIRA subtasks"
      },
      "configuredAt": "2025-10-24T12:00:00Z"
    },
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

---

## MCP Detection Logic

### Discovery Process

```javascript
// 1. Run MCP command to detect connected servers
const mcpOutput = await bash('/mcp');

// 2. Parse connected servers
const connectedServers = parseMcpOutput(mcpOutput);
// Example: ['Atlassian', 'github', 'custom-mcp']

// 3. Check against known integrations
const knownIntegrations = {
  'Atlassian': {
    detected: connectedServers.includes('Atlassian'),
    capabilities: ['jira', 'confluence']
  },
  'github': {
    detected: connectedServers.includes('github'),
    capabilities: ['projects', 'pr']
  }
};

// 4. Identify new vs configured
const newServers = connectedServers.filter(
  server => !registry.knownServers[server]
);

const unconfigured = connectedServers.filter(
  server => registry.knownServers[server] && !isConfigured(server)
);
```

---

### Capability Mapping

How MCP capabilities map to Flow skills:

| MCP Capability | Flow Skills Enhanced |
|----------------|---------------------|
| Issue tracking | flow:specify, flow:tasks, flow:implement |
| Documentation | flow:plan, flow:specify |
| Version control | flow:implement (PR creation) |
| Monitoring | flow:specify (error context) |
| Projects | flow:tasks (sync tasks) |

---

## Template Copy Process

### Source to Destination Mapping

```javascript
// Templates copied from plugin to project
const templateMap = {
  // Document templates
  'plugins/flow/templates/templates/spec-template.md':
    '.flow/templates/spec-template.md',

  'plugins/flow/templates/templates/plan-template.md':
    '.flow/templates/plan-template.md',

  'plugins/flow/templates/templates/tasks-template.md':
    '.flow/templates/tasks-template.md',

  // Product/architecture templates
  'plugins/flow/templates/templates/product-requirements-template.md':
    '.flow/templates/product-requirements-template.md',

  'plugins/flow/templates/templates/architecture-blueprint-template.md':
    '.flow/templates/architecture-blueprint-template.md',

  // API templates (if API project)
  'plugins/flow/templates/templates/openapi-template.yaml':
    '.flow/contracts/openapi.yaml',

  // Integration templates (if enabled)
  'plugins/flow/templates/templates/jira-story-template.md':
    '.flow/templates/jira-story-template.md',

  'plugins/flow/templates/templates/confluence-page.md':
    '.flow/templates/confluence-page.md',

  'plugins/flow/templates/templates/github-pr-template.md':
    '.flow/templates/github-pr-template.md'
};

// Scripts copied
const scriptMap = {
  'plugins/flow/templates/scripts/common.sh':
    '.flow/scripts/common.sh',

  'plugins/flow/templates/scripts/create-new-feature.sh':
    '.flow/scripts/create-new-feature.sh',

  'plugins/flow/templates/scripts/check-prerequisites.sh':
    '.flow/scripts/check-prerequisites.sh'
};
```

---

## Skills Reading Configuration

How other Flow skills read CLAUDE.md configuration:

```javascript
// Example from flow:specify
const config = readFlowConfig('CLAUDE.md');

if (config.FLOW_ATLASSIAN_SYNC === 'enabled') {
  // Use Atlassian MCP for JIRA operations
  const jiraProjectKey = config.FLOW_JIRA_PROJECT_KEY;
  const confluenceRootPageId = config.FLOW_CONFLUENCE_ROOT_PAGE_ID;

  // Create JIRA story
  await mcp.jira.createIssue({
    projectKey: jiraProjectKey,
    issueType: 'Story',
    summary: storyTitle,
    description: storyDescription
  });

  // Create Confluence page
  await mcp.confluence.createPage({
    parentId: confluenceRootPageId,
    title: featureName,
    body: specContent
  });
}

// Branch naming
if (config.FLOW_BRANCH_PREPEND_JIRA === 'true' && jiraId) {
  branchName = `${jiraId}-${featureName}`;
} else {
  branchName = `${featureNumber}-${featureName}`;
}
```

---

## Integration-Specific Setup

### Atlassian (JIRA + Confluence)

**Prerequisites**:
- Atlassian MCP installed and connected
- JIRA project created
- Confluence space created

**Configuration Collected**:
1. **JIRA Project Key** (required)
   - Example: "PROJ", "MYAPP", "ENG"
   - Used for creating stories/epics
   - Must match existing JIRA project

2. **Confluence Root Page ID** (required)
   - Get from Confluence page URL
   - Example: `https://company.atlassian.net/wiki/spaces/PROJ/pages/123456/Root`
   - ID is `123456`
   - All feature docs created under this page

3. **Branch Prepend Setting** (optional)
   - Prepend JIRA ID to branch names
   - Example: `PROJ-123-feature-name` vs `001-feature-name`
   - Useful for JIRA-Git integration

**What Gets Synced**:
- `flow:specify` → JIRA epic + stories, Confluence page
- `flow:plan` → Confluence implementation plan subpage
- `flow:tasks` → JIRA subtasks under stories
- `flow:implement` → JIRA status updates

**Authentication**:
- First MCP call triggers SSO authentication
- Browser window opens for login
- Token stored in Claude Code session
- No manual API token management

---

### GitHub Projects

**Prerequisites**:
- GitHub MCP installed and connected
- GitHub repository linked
- (Optional) GitHub Project board created

**Configuration Collected**:
1. **GitHub Project ID** (optional)
   - Example: `PVT_kwDOABCD123`
   - Get from Project URL
   - If omitted, creates issues without project sync

**What Gets Synced**:
- `flow:tasks` → GitHub project items
- `flow:implement` → Auto-creates PRs with context

---

### Linear

**Prerequisites**:
- Linear MCP installed and connected
- Linear workspace created

**Configuration Collected**:
1. **Linear API Key** (required)
2. **Linear Team ID** (required)

**What Gets Synced**:
- `flow:specify` → Linear issues
- `flow:tasks` → Linear sub-issues
- `flow:implement` → Linear status updates

---

## Configuration Reading Utility

### Parse CLAUDE.md

```javascript
function readFlowConfig(claudeMdPath = 'CLAUDE.md') {
  const content = fs.readFileSync(claudeMdPath, 'utf-8');
  const config = {};

  // Find Flow Configuration section
  const flowConfigStart = content.indexOf('## Flow Configuration');
  if (flowConfigStart === -1) return config;

  // Extract config variables
  const configSection = content.slice(flowConfigStart);
  const lines = configSection.split('\n');

  for (const line of lines) {
    // Match: FLOW_VARIABLE_NAME=value
    const match = line.match(/^FLOW_([A-Z_]+)=(.+)$/);
    if (match) {
      const [, key, value] = match;
      config[`FLOW_${key}`] = value.trim();
    }
  }

  return config;
}

// Usage
const config = readFlowConfig();
console.log(config.FLOW_ATLASSIAN_SYNC);  // 'enabled' or 'disabled'
console.log(config.FLOW_JIRA_PROJECT_KEY); // 'PROJ'
```

---

## Troubleshooting

### Issue: MCP Server Not Detected

**Symptoms**:
- "No MCP servers found" during init
- Integration options not shown

**Diagnosis**:
```bash
# Check if MCP command works
/mcp

# Verify MCP package installed
cat .mcp.json

# Check MCP process running
ps aux | grep mcp
```

**Solutions**:
1. Restart Claude Code
2. Reinstall MCP package: `npx @modelcontextprotocol/server-{name}@latest`
3. Check .mcp.json syntax
4. Run `flow:init --reconfigure` after fixing

---

### Issue: Authentication Failed (Atlassian)

**Symptoms**:
- Browser SSO window doesn't open
- "Authentication failed" error
- Token expired errors

**Solutions**:
1. **Clear MCP cache**:
   ```bash
   rm -rf ~/.claude/mcp-cache
   ```

2. **Check network/firewall**:
   - Ensure SSO redirect URL accessible
   - Check corporate firewall settings
   - Verify VPN not blocking auth flow

3. **Manual re-authentication**:
   ```bash
   flow:init --reconfigure
   # Follow SSO prompt when triggered
   ```

---

### Issue: Configuration Not Persisting

**Symptoms**:
- CLAUDE.md changes not saved
- Config resets after restart

**Diagnosis**:
```bash
# Check file exists and is writable
ls -la CLAUDE.md
# Should show: -rw-r--r--

# Check not in .gitignore
cat .gitignore | grep CLAUDE.md
# Should be empty (CLAUDE.md should NOT be ignored)

# Check for file locks
lsof CLAUDE.md
```

**Solutions**:
1. **Fix permissions**:
   ```bash
   chmod 644 CLAUDE.md
   ```

2. **Create if missing**:
   ```bash
   touch CLAUDE.md
   echo "# Project Documentation" > CLAUDE.md
   ```

3. **Remove from .gitignore** (if present):
   ```bash
   # Edit .gitignore, remove CLAUDE.md line
   vim .gitignore
   ```

---

### Issue: Templates Not Copying

**Symptoms**:
- .flow/templates/ directory empty
- Scripts missing from .flow/scripts/

**Diagnosis**:
```bash
# Check source templates exist
ls -R plugins/flow/templates/

# Check destination directory
ls -la .flow/

# Check for permission issues
ls -la .flow/templates/
```

**Solutions**:
1. **Manual copy**:
   ```bash
   mkdir -p .flow/templates
   cp -r plugins/flow/templates/templates/* .flow/templates/

   mkdir -p .flow/scripts
   cp plugins/flow/templates/scripts/*.sh .flow/scripts/
   chmod +x .flow/scripts/*.sh
   ```

2. **Fix permissions**:
   ```bash
   chmod -R 755 .flow/
   ```

3. **Verify plugin path**:
   ```bash
   # Ensure plugin installed correctly
   ls plugins/flow/.claude/skills/flow-init/SKILL.md
   ```

---

### Issue: .flow/ Already Exists

**Symptoms**:
- "Directory .flow/ already exists" error
- Init refuses to run

**Solutions**:
1. **Use --reconfigure**:
   ```bash
   flow:init --reconfigure
   ```

2. **Backup and recreate** (if corrupted):
   ```bash
   mv .flow .flow.backup
   flow:init
   # Restore any custom content from backup
   ```

---

## Advanced Configuration

### Custom Template Paths

Override default template locations:

```markdown
## Flow Configuration
FLOW_TEMPLATE_PATH=/custom/templates/
```

Skills will check custom path first, fall back to `.flow/templates/`.

---

### Per-Skill Configuration

Disable specific skills or features:

```markdown
FLOW_SKIP_BLUEPRINT=true        # Skip blueprint requirement
FLOW_SKIP_CLARIFY=true          # Skip clarification step
FLOW_AUTO_JIRA=false            # Don't auto-create JIRA
```

---

### Environment-Specific Config

Different config for dev/staging/prod:

```bash
# Local development (not committed)
.flow/config.local.json

# Shared team config (committed)
CLAUDE.md
```

Skills read both, local overrides shared.

---

## Related Skills

- **flow:blueprint**: Define architecture (created by init)
- **flow:specify**: Create specs (uses init's templates)
- **flow:update**: Add new MCP integrations (extends init)
- **flow:discover**: Analyze brownfield projects (pairs with init)

---

## Version History

- **v1.0**: Initial release with Atlassian MCP support
- **v1.1**: Added GitHub Projects integration
- **v1.2**: Added --reconfigure flag
- **v1.3**: Added brownfield mode
- **v2.0**: Simplified config to CLAUDE.md (removed config.json)
