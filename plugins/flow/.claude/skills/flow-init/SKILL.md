---
name: flow:init
description: Initialize a new project with Flow workflow configuration, choosing between greenfield or brownfield, and optionally setting up integrations.
---

# Flow Init

Initialize a Flow project with configuration and structure setup, including MCP-based integrations.

## Usage

```
flow:init
flow:init --type greenfield
flow:init --type brownfield
flow:init --reconfigure
```

## What It Does

### Phase 1: MCP Discovery
1. **Detect Available MCP Servers**
   - Run `/mcp` command to list connected MCP servers
   - Check for Atlassian MCP (JIRA/Confluence)
   - Check for other known integrations (GitHub, Linear, etc.)

### Phase 2: Project Type Selection
2. **Determine Project Type**
   - Prompt: "Is this a greenfield or brownfield project?"
   - Greenfield: New project, full workflow
   - Brownfield: Existing codebase, adding Flow

### Phase 3: Integration Configuration
3. **Configure Atlassian Integration** (if detected)
   ```
   ✓ Detected: Atlassian MCP (JIRA & Confluence)

   Enable Atlassian integration? [Y/n]

   JIRA Project Key (e.g., PROJ): ___
   Confluence Root Page ID (from page URL): ___
   Prepend JIRA ID to branch names? [Y/n]
   ```

4. **Configure Additional Integrations** (if detected)
   - GitHub Projects
   - Linear
   - Sentry
   - Custom MCPs

### Phase 4: Directory Structure
5. **Create .specify/ Structure**
   ```
   .specify/
   ├── memory/
   │   └── constitution.md       (from template)
   ├── templates/
   │   ├── spec-template.md
   │   ├── plan-template.md
   │   ├── tasks-template.md
   │   ├── jira-story-template.md
   │   └── confluence-page.md
   └── config.local.json          (gitignored)
   ```

### Phase 5: Configuration Files
6. **Update CLAUDE.md**
   - Add Flow Configuration section if not present
   - Set `FLOW_ATLASSIAN_SYNC=enabled` (if chosen)
   - Set `FLOW_JIRA_PROJECT_KEY=PROJ`
   - Set `FLOW_CONFLUENCE_ROOT_PAGE_ID=123456`
   - Set workflow defaults

7. **Create .gitignore**
   - Add rules for local config files
   - Add rules for secrets

### Phase 6: Authentication Guidance
8. **Guide MCP Authentication**
   ```
   ✓ Configuration saved!

   Next steps:

   1. Authenticate with Atlassian MCP:
      - Run any Flow skill that uses Atlassian (e.g., flow:specify)
      - You'll be prompted to authenticate via browser
      - Uses SSO - no API tokens needed!

   2. Create your first specification:
      flow:specify "Your feature description"

   3. (Optional) Define your project constitution:
      flow:constitution
   ```

## Execution Logic

### MCP Detection

```javascript
// Run MCP command to detect available servers
const mcpOutput = await bash('/mcp');

// Parse connected servers
const connectedServers = parseMcpOutput(mcpOutput);

// Check against .flow/extensions.json
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
```

### Configuration Storage

**CLAUDE.md** (version-controlled):
```
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
FLOW_BRANCH_PREPEND_JIRA=true
```

**Benefits**:
- Simple text format
- Version controlled
- Team shares same config
- Easy to enable/disable features

### Template Copy

```javascript
// Copy templates from plugin to project
const templates = [
  'spec-template.md',
  'plan-template.md',
  'tasks-template.md',
  'jira-story-template.md',
  'confluence-page.md',
  'constitution.md'
];

for (const template of templates) {
  copy(
    `plugins/flow/templates/templates/${template}`,
    `.specify/templates/${template}`
  );
}
```

## Flags & Options

### `--type greenfield|brownfield`
Explicitly set project type without prompting.

### `--reconfigure`
Re-run configuration for existing Flow project. Useful when:
- New MCP servers added
- Changing integration settings
- Updating workflow defaults

### `--skip-integrations`
Skip MCP detection and integration setup. For:
- POC/spike projects
- Solo developers without integrations
- Quick setup

## Integration-Specific Setup

### Atlassian (JIRA + Confluence)

**What you need**:
- JIRA project key (e.g., "PROJ")
- Confluence root page ID (get from page URL)

**How it works**:
1. Flow configures skills to use Atlassian MCP
2. First time you use a skill, SSO authentication prompt
3. Authenticate via browser once
4. All subsequent calls use authenticated session

**What gets synced**:
- `flow:specify` → Creates JIRA epic + stories
- `flow:plan` → Syncs to Confluence pages
- `flow:tasks` → Creates JIRA subtasks
- `flow:implement` → Updates JIRA status

### GitHub Projects

**What you need**:
- GitHub personal access token
- Project board ID (optional)

**What gets synced**:
- `flow:tasks` → GitHub project items
- `flow:implement` → Creates PR automatically

### Linear

**What you need**:
- Linear API key
- Team ID

**What gets synced**:
- `flow:specify` → Linear issues
- `flow:tasks` → Linear sub-issues

## Examples

### Basic Greenfield Setup
```
User: flow:init

Flow: Detecting available MCP servers...
Flow: ✓ Found: Atlassian MCP (JIRA & Confluence)

Flow: Is this a greenfield or brownfield project?
User: greenfield

Flow: Enable Atlassian integration? [Y/n]
User: Y

Flow: JIRA Project Key (e.g., PROJ):
User: MYAPP

Flow: Confluence Root Page ID (from page URL):
User: 789456123

Flow: Prepend JIRA ID to branch names? [Y/n]
User: Y

Flow: Creating .specify/ directory structure...
Flow: Copying templates...
Flow: Updating CLAUDE.md configuration...
Flow: ✓ Flow initialized successfully!

Flow: Next steps:
      1. Authenticate with Atlassian MCP when prompted
      2. Run: flow:specify "Your first feature"
      3. (Optional) Define constitution: flow:constitution
```

### Brownfield Project
```
User: flow:init --type brownfield

Flow: Detecting available MCP servers...
Flow: ✓ Found: Atlassian MCP

Flow: Enable Atlassian integration? [Y/n]
User: n

Flow: Creating .specify/ directory structure...
Flow: ✓ Flow initialized (no integrations)

Flow: Next steps:
      1. Run: flow:specify "First feature to add"
      2. Flow will work with your existing codebase
```

### Quick Setup (No Integrations)
```
User: flow:init --skip-integrations

Flow: Skipping MCP detection...
Flow: Creating .specify/ directory structure...
Flow: ✓ Flow initialized (standalone mode)

Flow: Use flow:init --reconfigure to add integrations later
```

### Reconfigure Existing Project
```
User: flow:init --reconfigure

Flow: Detected existing .specify/ directory
Flow: Detecting new MCP servers...
Flow: ✓ Found: Atlassian MCP (not configured)
Flow: ✓ Found: GitHub MCP (new!)

Flow: Enable GitHub Projects integration? [Y/n]
User: Y

Flow: GitHub Project ID (optional):
User:

Flow: ✓ Configuration updated!
Flow: GitHub integration available in flow:tasks and flow:implement
```

## Implementation Notes

### Reading CLAUDE.md Configuration

Skills should read CLAUDE.md to check if features are enabled:

```javascript
// Read CLAUDE.md
const claudeMd = await readFile('CLAUDE.md');

// Parse configuration
const config = parseFlowConfig(claudeMd);

// Check if Atlassian is enabled
if (config.FLOW_ATLASSIAN_SYNC === 'enabled') {
  // Use Atlassian MCP for JIRA/Confluence operations
  const jiraProjectKey = config.FLOW_JIRA_PROJECT_KEY;
  const confluenceRootPageId = config.FLOW_CONFLUENCE_ROOT_PAGE_ID;

  // Create JIRA story...
}
```

### MCP Authentication

For Atlassian MCP with SSO:
1. First MCP call triggers authentication
2. Browser window opens for SSO login
3. Token stored in Claude Code session
4. Subsequent calls use authenticated session

No need to manage API tokens manually!

## Related Skills

- **flow:specify** - Creates specs, uses MCP if enabled
- **flow:plan** - Creates plans, syncs to Confluence if enabled
- **flow:tasks** - Creates tasks, syncs to JIRA if enabled
- **flow:update** - Adds new MCP integrations to existing Flow project
- **flow:constitution** - Defines project governance

## Troubleshooting

### "MCP server not detected"
- Ensure `.mcp.json` exists in plugin root
- Check MCP server is installed: `npx mcp-remote@latest`
- Run `/mcp` to verify server is connected

### "Authentication failed"
- Clear Claude Code MCP cache
- Re-run flow:init --reconfigure
- Check network/firewall for SSO redirects

### "Configuration not persisting"
- Check CLAUDE.md exists and is writable
- Verify .gitignore doesn't exclude CLAUDE.md
- Ensure proper file permissions

