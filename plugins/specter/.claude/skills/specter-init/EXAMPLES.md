# Flow Init Examples

## Quick Start

### Minimal Setup (Solo Developer)

```bash
specter:init --skip-integrations
```

**Result**:
```
✓ Flow initialized (standalone mode)
Created:
  .specter/
  ├── product-requirements.md (skeleton)
  ├── architecture-blueprint.md (skeleton)
  ├── scripts/ (bash utilities)
  ├── templates/ (document templates)
  └── data-models/entities.md

Next steps:
  1. specter:blueprint (define architecture)
  2. specter:specify "Your feature"
```

---

## Common Scenarios

### 1. Greenfield Project with JIRA

**Context**: Starting new project, team uses JIRA/Confluence

```
User: specter:init

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

Flow: Is this an API project? [Y/n]
User: Y
```

**Result**:
```
✓ Flow initialized successfully!

Created:
  .specter/
  ├── product-requirements.md
  ├── architecture-blueprint.md
  ├── contracts/
  │   └── openapi.yaml (API contract template)
  ├── data-models/entities.md
  ├── scripts/
  │   ├── common.sh
  │   ├── create-new-feature.sh
  │   └── check-prerequisites.sh
  └── templates/
      ├── spec-template.md
      ├── plan-template.md
      ├── tasks-template.md
      ├── jira-story-template.md
      └── confluence-page.md

Updated:
  CLAUDE.md (Flow configuration added):
    SPECTER_ATLASSIAN_SYNC=enabled
    SPECTER_JIRA_PROJECT_KEY=MYAPP
    SPECTER_CONFLUENCE_ROOT_PAGE_ID=789456123
    SPECTER_BRANCH_PREPEND_JIRA=true

Next steps:
  1. Authenticate with Atlassian MCP (on first use)
  2. specter:blueprint (define architecture)
  3. specter:specify "Complete project description"
```

---

### 2. Brownfield Project (Existing Codebase)

**Context**: Adding Flow to established project, no integrations needed

```
User: specter:init --type brownfield

Flow: Detecting available MCP servers...
Flow: ✓ Found: Atlassian MCP

Flow: Enable Atlassian integration? [Y/n]
User: n

Flow: Creating .specter/ directory structure...
```

**Result**:
```
✓ Flow initialized (no integrations)

Created:
  .specter/
  ├── product-requirements.md (document existing)
  ├── architecture-blueprint.md (extract from code)
  ├── scripts/
  └── templates/

Next steps:
  1. specter:discover (analyze existing codebase)
  2. specter:blueprint --extract (document current architecture)
  3. specter:specify "First feature to add"
```

---

### 3. Adding GitHub Projects Integration Later

**Context**: Started without integrations, now want to add GitHub

```
User: specter:init --reconfigure

Flow: Detected existing .specter/ directory
Flow: Detecting new MCP servers...
Flow: ✓ Found: Atlassian MCP (already configured)
Flow: ✓ Found: GitHub MCP (new!)

Flow: Enable GitHub Projects integration? [Y/n]
User: Y

Flow: GitHub Project ID (optional):
User: PVT_kwDOABCD123
```

**Result**:
```
✓ Configuration updated!

Updated:
  CLAUDE.md:
    SPECTER_GITHUB_SYNC=enabled
    SPECTER_GITHUB_PROJECT_ID=PVT_kwDOABCD123

  .specter/extensions.json:
    Added GitHub MCP configuration

Created:
  .specter/templates/github-pr-template.md

GitHub integration now available in:
  • specter:tasks - Sync to GitHub Projects
  • specter:implement - Auto-create PRs

Next: Run specter:tasks to sync existing tasks
```

---

### 4. POC/Spike Setup (Minimal Ceremony)

**Context**: Quick proof of concept, skip all integrations

```
User: specter:init --skip-integrations --type greenfield

Flow: Skipping MCP detection...
Flow: Creating minimal .specter/ structure...
```

**Result**:
```
✓ Flow initialized (minimal mode)

Created:
  .specter/
  ├── scripts/
  └── templates/

Skipped:
  • Product requirements (POC mode)
  • Architecture blueprint (throwaway code)
  • Integration configs

Next steps:
  specter:specify "Quick POC for [idea]" --skip-validation
  specter:implement --skip-checklists

Note: Use specter:init --reconfigure to add structure later
```

---

### 5. API-First Project

**Context**: Building API platform, need OpenAPI contracts

```
User: specter:init

Flow: Is this a greenfield or brownfield project?
User: greenfield

Flow: Enable Atlassian integration? [Y/n]
User: n

Flow: Is this an API project? [Y/n]
User: Y

Flow: API specification format?
  [1] OpenAPI 3.0 (REST)
  [2] GraphQL Schema
  [3] Both
User: 1
```

**Result**:
```
✓ Flow initialized (API-first mode)

Created:
  .specter/
  ├── contracts/
  │   ├── openapi.yaml (REST API template)
  │   └── README.md (contract documentation)
  ├── data-models/
  │   ├── entities.md
  │   └── api-resources.md
  └── templates/
      ├── endpoint-template.md
      └── resource-template.md

Updated:
  CLAUDE.md:
    SPECTER_API_SPECIFICATION=openapi
    SPECTER_REQUIRE_CONTRACTS=true

Next steps:
  1. specter:blueprint (define API architecture)
  2. Define API contracts in .specter/contracts/openapi.yaml
  3. specter:specify "First API endpoint"
```

---

### 6. Enterprise Team Setup

**Context**: Large team, need governance and compliance

```
User: specter:init --type greenfield

Flow: Detected enterprise environment
Flow: Enable additional governance? [Y/n]
User: Y

Flow: Compliance requirements (comma-separated):
     [SOC2, HIPAA, GDPR, PCI-DSS, none]
User: SOC2,GDPR

Flow: Enable Atlassian integration? [Y/n]
User: Y

[... JIRA/Confluence setup ...]

Flow: Require architecture blueprint? [Y/n]
User: Y

Flow: Require analysis before implementation? [Y/n]
User: Y
```

**Result**:
```
✓ Flow initialized (enterprise mode)

Created:
  .specter/
  ├── compliance/
  │   ├── soc2-checklist.md
  │   └── gdpr-checklist.md
  ├── governance/
  │   └── review-process.md
  └── [standard structure]

Updated:
  CLAUDE.md:
    SPECTER_REQUIRE_BLUEPRINT=true
    SPECTER_REQUIRE_ANALYSIS=true
    SPECTER_REQUIRE_CHECKLISTS=true
    SPECTER_COMPLIANCE=SOC2,GDPR

Workflow enforcements:
  • Blueprint required before features
  • Analysis required before implementation
  • Compliance checklists for all features
  • All changes synced to JIRA/Confluence

Next steps:
  1. specter:blueprint (required - define architecture)
  2. specter:specify "First feature" (will create JIRA)
  3. specter:analyze (required - validate consistency)
```

---

## Advanced Patterns

### Multi-MCP Setup

**Context**: Using multiple MCP servers (JIRA, GitHub, Sentry)

```bash
# Run init multiple times with --reconfigure
specter:init                    # Initial setup with JIRA
specter:init --reconfigure      # Add GitHub
specter:init --reconfigure      # Add Sentry
```

Each reconfigure run detects new MCPs and offers integration.

---

### Custom Templates

**Context**: Team has custom document templates

```bash
specter:init

# After init, replace templates
cp team-templates/*.md .specter/templates/

# Update template references in scripts
vim .specter/scripts/create-new-feature.sh
```

---

### Monorepo Setup

**Context**: Multiple projects in monorepo, each needs Flow

```bash
# Project A
cd packages/api
specter:init --type greenfield
# Creates packages/api/.specter/

# Project B
cd packages/web
specter:init --type greenfield
# Creates packages/web/.specter/

# Shared config at root
cd ../..
ln -s packages/api/.specter/templates .flow-templates
```

---

## Anti-Patterns

### ❌ Don't: Run init multiple times without --reconfigure

```bash
specter:init          # Creates .specter/
specter:init          # ERROR: .specter/ already exists
```

**Instead**:
```bash
specter:init --reconfigure    # Updates existing config
```

---

### ❌ Don't: Commit local-only config

```bash
# Bad: Commit personal API keys
git add .specter/config.local.json

# Good: .gitignore excludes *.local.json
```

---

### ❌ Don't: Skip blueprint for team projects

```bash
# Bad: Team project without architecture doc
specter:init
specter:specify "Feature"      # No shared architecture!
```

**Instead**:
```bash
specter:init
specter:blueprint              # Define team architecture first
specter:specify "Feature"      # Now aligned with blueprint
```

---

## Troubleshooting

### MCP Server Not Detected

**Problem**: "No MCP servers found" but you have them installed

**Solution**:
```bash
# Verify MCP is running
/mcp

# Check .mcp.json exists
cat plugins/specter/.mcp.json

# Restart Claude Code
# Then: specter:init --reconfigure
```

---

### Authentication Failed

**Problem**: Atlassian MCP authentication fails

**Solution**:
```bash
# Clear cache
rm -rf ~/.claude/mcp-cache

# Re-run init
specter:init --reconfigure

# Follow browser SSO prompt
```

---

### Configuration Not Persisting

**Problem**: CLAUDE.md changes not saved

**Solution**:
```bash
# Check file permissions
ls -la CLAUDE.md

# Verify not in .gitignore
cat .gitignore | grep CLAUDE.md

# If needed, create manually
touch CLAUDE.md
chmod 644 CLAUDE.md
```

---

### Templates Not Copying

**Problem**: .specter/templates/ is empty

**Solution**:
```bash
# Verify plugin templates exist
ls plugins/specter/templates/templates/

# Manual copy if needed
cp -r plugins/specter/templates/templates/* .specter/templates/

# Check for file permission issues
chmod -R 755 .specter/
```
