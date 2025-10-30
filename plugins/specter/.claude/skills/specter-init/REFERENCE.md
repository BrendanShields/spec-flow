# Flow Init Reference

## Command-Line Flags

### `--type greenfield|brownfield`

Explicitly set project type without prompting.

**Greenfield**: New project
- Creates full .specter/ structure
- Prompts for architecture blueprint
- Sets up project-level specs
- Configures all templates

**Brownfield**: Existing codebase
- Creates .specter/ structure
- Focuses on feature-level specs
- Suggests codebase analysis first
- Simplified initial setup

**Example**:
```bash
specter:init --type greenfield
specter:init --type brownfield
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
specter:init --skip-integrations
```

**Result**: Creates minimal .specter/ structure, no MCP configuration.

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
specter:init --reconfigure
```

**Safe**: Preserves existing .specter/ content, only updates configuration.

---

## Directory Structure Created

### Standard Structure (All Projects)

```
.specter/
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
.specter/
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
.specter/
├── extensions.json             # MCP registry
└── templates/
    ├── jira-story-template.md
    └── confluence-page.md
```

---

### With GitHub Integration

If GitHub MCP enabled:

```
.specter/
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
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_GITHUB_SYNC=disabled
SPECTER_BRANCH_PREPEND_JIRA=true
SPECTER_REQUIRE_BLUEPRINT=false
SPECTER_REQUIRE_ANALYSIS=false

### Integration Settings
SPECTER_JIRA_PROJECT_KEY=PROJ
SPECTER_CONFLUENCE_ROOT_PAGE_ID=123456
SPECTER_GITHUB_PROJECT_ID=PVT_123

### Workflow Defaults
SPECTER_TESTS_REQUIRED=false
SPECTER_STORY_FORMAT=bdd
```

**Benefits**:
- Simple text format (no JSON parsing)
- Version controlled
- Team shares same config
- Easy to enable/disable features
- Readable diffs

---

### .specter/extensions.json (MCP Registry)

Tracks available MCP servers and their capabilities:

```json
{
  "version": "1.0",
  "knownServers": {
    "Atlassian": {
      "package": "@modelcontextprotocol/server-atlassian",
      "capabilities": ["jira", "confluence"],
      "enhances": {
        "specter:specify": "Create/update JIRA stories",
        "specter:plan": "Sync to Confluence",
        "specter:tasks": "Create JIRA subtasks"
      },
      "configuredAt": "2025-10-24T12:00:00Z"
    },
    "github": {
      "package": "@modelcontextprotocol/server-github",
      "capabilities": ["issues", "pull-requests", "projects"],
      "enhances": {
        "specter:tasks": "Sync to GitHub Projects",
        "specter:implement": "Auto-create PRs"
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

How MCP capabilities map to Specter skills:

| MCP Capability | Flow Skills Enhanced |
|----------------|---------------------|
| Issue tracking | specter:specify, specter:tasks, specter:implement |
| Documentation | specter:plan, specter:specify |
| Version control | specter:implement (PR creation) |
| Monitoring | specter:specify (error context) |
| Projects | specter:tasks (sync tasks) |

---

## Template Copy Process

### Source to Destination Mapping

```javascript
// Templates copied from plugin to project
const templateMap = {
  // Document templates
  'plugins/specter/templates/templates/spec-template.md':
    '.specter/templates/spec-template.md',

  'plugins/specter/templates/templates/plan-template.md':
    '.specter/templates/plan-template.md',

  'plugins/specter/templates/templates/tasks-template.md':
    '.specter/templates/tasks-template.md',

  // Product/architecture templates
  'plugins/specter/templates/templates/product-requirements-template.md':
    '.specter/templates/product-requirements-template.md',

  'plugins/specter/templates/templates/architecture-blueprint-template.md':
    '.specter/templates/architecture-blueprint-template.md',

  // API templates (if API project)
  'plugins/specter/templates/templates/openapi-template.yaml':
    '.specter/contracts/openapi.yaml',

  // Integration templates (if enabled)
  'plugins/specter/templates/templates/jira-story-template.md':
    '.specter/templates/jira-story-template.md',

  'plugins/specter/templates/templates/confluence-page.md':
    '.specter/templates/confluence-page.md',

  'plugins/specter/templates/templates/github-pr-template.md':
    '.specter/templates/github-pr-template.md'
};

// Scripts copied
const scriptMap = {
  'plugins/specter/templates/scripts/common.sh':
    '.specter/scripts/common.sh',

  'plugins/specter/templates/scripts/create-new-feature.sh':
    '.specter/scripts/create-new-feature.sh',

  'plugins/specter/templates/scripts/check-prerequisites.sh':
    '.specter/scripts/check-prerequisites.sh'
};
```

---

## Skills Reading Configuration

How other Specter skills read CLAUDE.md configuration:

```javascript
// Example from specter:specify
const config = readFlowConfig('CLAUDE.md');

if (config.SPECTER_ATLASSIAN_SYNC === 'enabled') {
  // Use Atlassian MCP for JIRA operations
  const jiraProjectKey = config.SPECTER_JIRA_PROJECT_KEY;
  const confluenceRootPageId = config.SPECTER_CONFLUENCE_ROOT_PAGE_ID;

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
if (config.SPECTER_BRANCH_PREPEND_JIRA === 'true' && jiraId) {
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
- `specter:specify` → JIRA epic + stories, Confluence page
- `specter:plan` → Confluence implementation plan subpage
- `specter:tasks` → JIRA subtasks under stories
- `specter:implement` → JIRA status updates

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
- `specter:tasks` → GitHub project items
- `specter:implement` → Auto-creates PRs with context

---

### Linear

**Prerequisites**:
- Linear MCP installed and connected
- Linear workspace created

**Configuration Collected**:
1. **Linear API Key** (required)
2. **Linear Team ID** (required)

**What Gets Synced**:
- `specter:specify` → Linear issues
- `specter:tasks` → Linear sub-issues
- `specter:implement` → Linear status updates

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
    // Match: SPECTER_VARIABLE_NAME=value
    const match = line.match(/^SPECTER_([A-Z_]+)=(.+)$/);
    if (match) {
      const [, key, value] = match;
      config[`SPECTER_${key}`] = value.trim();
    }
  }

  return config;
}

// Usage
const config = readFlowConfig();
console.log(config.SPECTER_ATLASSIAN_SYNC);  // 'enabled' or 'disabled'
console.log(config.SPECTER_JIRA_PROJECT_KEY); // 'PROJ'
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
4. Run `specter:init --reconfigure` after fixing

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
   specter:init --reconfigure
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
- .specter/templates/ directory empty
- Scripts missing from .specter/scripts/

**Diagnosis**:
```bash
# Check source templates exist
ls -R plugins/specter/templates/

# Check destination directory
ls -la .specter/

# Check for permission issues
ls -la .specter/templates/
```

**Solutions**:
1. **Manual copy**:
   ```bash
   mkdir -p .specter/templates
   cp -r plugins/specter/templates/templates/* .specter/templates/

   mkdir -p .specter/scripts
   cp plugins/specter/templates/scripts/*.sh .specter/scripts/
   chmod +x .specter/scripts/*.sh
   ```

2. **Fix permissions**:
   ```bash
   chmod -R 755 .specter/
   ```

3. **Verify plugin path**:
   ```bash
   # Ensure plugin installed correctly
   ls plugins/specter/.claude/skills/specter-init/SKILL.md
   ```

---

### Issue: .specter/ Already Exists

**Symptoms**:
- "Directory .specter/ already exists" error
- Init refuses to run

**Solutions**:
1. **Use --reconfigure**:
   ```bash
   specter:init --reconfigure
   ```

2. **Backup and recreate** (if corrupted):
   ```bash
   mv .flow .flow.backup
   specter:init
   # Restore any custom content from backup
   ```

---

## Advanced Configuration

### Custom Template Paths

Override default template locations:

```markdown
## Flow Configuration
SPECTER_TEMPLATE_PATH=/custom/templates/
```

Skills will check custom path first, fall back to `.specter/templates/`.

---

### Per-Skill Configuration

Disable specific skills or features:

```markdown
SPECTER_SKIP_BLUEPRINT=true        # Skip blueprint requirement
SPECTER_SKIP_CLARIFY=true          # Skip clarification step
SPECTER_AUTO_JIRA=false            # Don't auto-create JIRA
```

---

### Environment-Specific Config

Different config for dev/staging/prod:

```bash
# Local development (not committed)
.specter/config.local.json

# Shared team config (committed)
CLAUDE.md
```

Skills read both, local overrides shared.

---

## Related Skills

- **specter:blueprint**: Define architecture (created by init)
- **specter:specify**: Create specs (uses init's templates)
- **specter:update**: Add new MCP integrations (extends init)
- **specter:discover**: Analyze brownfield projects (pairs with init)

---

## Version History

- **v1.0**: Initial release with Atlassian MCP support
- **v1.1**: Added GitHub Projects integration
- **v1.2**: Added --reconfigure flag
- **v1.3**: Added brownfield mode
- **v2.0**: Simplified config to CLAUDE.md (removed config.json)
