---
name: flow:init
description: Initialize Flow for specification-driven development. Use when 1) Starting new project (greenfield), 2) Adding Flow to existing codebase (brownfield), 3) User says "setup/configure/initialize flow", 4) Reconfiguring after adding MCP servers, 5) Setting up JIRA/Confluence integration. Creates .flow/ directory with templates and configuration.
allowed-tools: Bash, Write, Read, Edit
---

# Flow Init

Initialize Flow project structure with optional MCP integrations (JIRA, Confluence, GitHub, etc.).

## Core Workflow

### 1. MCP Discovery

Detect available MCP servers:
```bash
/mcp  # Lists connected servers
```

Check for known integrations:
- **Atlassian MCP**: JIRA + Confluence
- **GitHub MCP**: Issues, PRs, Projects
- **Linear MCP**: Issue tracking
- **Custom MCPs**: User-defined integrations

### 2. Project Type Selection

**Greenfield**: New project
- Full .flow/ structure
- All templates and scripts
- Architecture blueprint setup

**Brownfield**: Existing codebase
- Minimal .flow/ structure
- Focus on feature-level specs
- Suggest codebase analysis

Prompt: "Is this a greenfield or brownfield project?"

### 3. Integration Configuration

For each detected MCP, prompt for setup:

**Atlassian (if detected)**:
- JIRA Project Key (e.g., "PROJ")
- Confluence Root Page ID (from URL)
- Branch naming preference (prepend JIRA ID?)

**GitHub (if detected)**:
- GitHub Project ID (optional, from project URL)

**Other MCPs**:
- Integration-specific configuration

### 4. Directory Structure Creation

Create standard structure:
```
.flow/
├── product-requirements.md      # Skeleton
├── architecture-blueprint.md    # Skeleton
├── contracts/                   # If API project
│   └── openapi.yaml
├── data-models/
│   └── entities.md
├── scripts/
│   ├── common.sh
│   ├── create-new-feature.sh
│   └── check-prerequisites.sh
├── templates/
│   ├── spec-template.md
│   ├── plan-template.md
│   ├── tasks-template.md
│   └── [integration-specific templates]
└── extensions.json              # MCP registry
```

Copy templates from:
```
plugins/flow/templates/templates/*.md  → .flow/templates/
plugins/flow/templates/scripts/*.sh    → .flow/scripts/
```

### 5. Configuration Storage

**Update CLAUDE.md** with Flow configuration:
```markdown
## Flow Configuration

### Feature Toggles
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
FLOW_BRANCH_PREPEND_JIRA=true

### Workflow Defaults
FLOW_REQUIRE_BLUEPRINT=false
FLOW_REQUIRE_ANALYSIS=false
FLOW_TESTS_REQUIRED=false
```

**Create .flow/extensions.json** with MCP registry:
```json
{
  "version": "1.0",
  "knownServers": {
    "Atlassian": {
      "package": "@modelcontextprotocol/server-atlassian",
      "capabilities": ["jira", "confluence"],
      "enhances": {
        "flow:specify": "Create/update JIRA stories",
        "flow:plan": "Sync to Confluence"
      },
      "configuredAt": "2025-10-24T12:00:00Z"
    }
  }
}
```

### 6. Completion Message

Provide next steps:
```
✓ Flow initialized successfully!

Next steps:
1. Authenticate with [MCP name] (on first use)
2. flow:blueprint (define architecture)
3. flow:specify "Feature description"
```

## Command-Line Flags

**`--type greenfield|brownfield`**
Explicitly set project type, skip prompting.

**`--skip-integrations`**
Skip MCP detection, create minimal local-only setup.

**`--reconfigure`**
Update existing Flow project configuration.
- Detects new MCP servers
- Updates integration settings
- Preserves existing .flow/ content

## Reading Configuration

Other Flow skills read CLAUDE.md:
```javascript
const config = readFlowConfig('CLAUDE.md');

if (config.FLOW_ATLASSIAN_SYNC === 'enabled') {
  const projectKey = config.FLOW_JIRA_PROJECT_KEY;
  // Use Atlassian MCP...
}
```

## API Project Detection

If API project (prompt user):
- Create `.flow/contracts/` directory
- Copy OpenAPI/GraphQL templates
- Add API-specific templates

## Integration Benefits

**Atlassian**:
- Auto-create JIRA epics/stories from specs
- Sync plans to Confluence
- Update JIRA status during implementation

**GitHub**:
- Sync tasks to GitHub Projects
- Auto-create PRs with context

**Linear**:
- Create Linear issues from user stories
- Track sub-issues for tasks

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Basic greenfield setup
- Brownfield project addition
- Enterprise with JIRA/Confluence
- Reconfiguring after adding MCPs
- POC/spike minimal setup
- Troubleshooting common issues

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete flag documentation
- Directory structure details
- Configuration file formats
- MCP detection logic
- Template copying process
- Integration-specific setup
- Advanced configuration options
- Troubleshooting guide

## Related Skills

- **flow:blueprint**: Define architecture (run after init)
- **flow:specify**: Create specifications (uses init's templates)
- **flow:update**: Add MCP integrations later (extends init)
- **flow:discover**: Analyze brownfield projects (pairs with brownfield init)

## Validation

Test this skill:
```bash
scripts/validate.sh
```

Validates: YAML syntax, description format, token count, modular resources, activation patterns.
