# Flow Update Examples

## Quick Start

### Detect and Configure New MCP

```bash
flow:update
```

**Result**:
```
Scanning for MCP servers...
✓ Found: Atlassian (configured)
✓ Found: GitHub (NEW!)

Enable GitHub integration? [Y/n]
```

---

## Common Scenarios

### 1. Adding GitHub Projects

**Context**: Started with JIRA, now want GitHub Projects integration

```
User: flow:update

Flow: Scanning for MCP servers...
Flow: ✓ Found: Atlassian MCP (configured)
Flow: ✓ Found: GitHub MCP (new!)

Flow: Enable GitHub Projects integration? [Y/n]
User: Y

Flow: GitHub Project ID (optional):
User: PVT_kwDOABCD123

Flow: Auto-create PRs from flow:implement? [Y/n]
User: Y
```

**Result**:
```
✓ GitHub integration enabled!

Updated:
  CLAUDE.md:
    FLOW_GITHUB_SYNC=enabled
    FLOW_GITHUB_PROJECT_ID=PVT_kwDOABCD123
    FLOW_GITHUB_AUTO_PR=true

  __specification__/extensions.json:
    Added GitHub MCP configuration

Created:
  __specification__/templates/github-pr-template.md

Enhanced skills:
  • flow:tasks - Now syncs to GitHub Projects
  • flow:implement - Now creates PRs automatically

Next: Run flow:tasks to sync existing tasks
```

---

### 2. Adding Linear

**Context**: Switching from JIRA to Linear

```
User: Just added Linear MCP, update Flow

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
```

**Result**:
```
✓ Linear configured!

Updated:
  CLAUDE.md:
    FLOW_LINEAR_SYNC=enabled
    FLOW_LINEAR_TEAM_ID=TEAM-abc123

Created:
  __specification__/templates/linear-issue-template.md

Your next flow:specify will create Linear issues!
```

---

### 3. Custom MCP Integration

**Context**: Created custom MCP for internal tools

```
User: flow:update

Flow: Found new MCP: "company-tracker"
      This server is not in the Flow registry.

      Detected capabilities:
      • create_task
      • update_status
      • get_metrics

      Would you like to add this MCP to Flow? [Y/n]
User: Y

Flow: How should Flow use this MCP?

      Which skills should integrate with "company-tracker"?
      [1] flow:specify
      [2] flow:plan
      [3] flow:tasks
      [4] flow:implement
      [5] Custom integration

User: 3,4

Flow: Task sync behavior?
      [1] One-way (Flow → Tracker)
      [2] Two-way (bidirectional)
User: 1

Flow: Status update on task completion? [Y/n]
User: Y
```

**Result**:
```
✓ Created custom integration!

Updated:
  __specification__/extensions.json:
    {
      "company-tracker": {
        "package": "npx company-tracker@latest",
        "capabilities": ["create_task", "update_status"],
        "enhances": {
          "flow:tasks": "Sync tasks to Tracker",
          "flow:implement": "Update status on completion"
        },
        "syncMode": "one-way",
        "updateOnComplete": true
      }
    }

  CLAUDE.md:
    FLOW_COMPANY_TRACKER_SYNC=enabled

Enhanced skills:
  • flow:tasks - Now syncs to company-tracker
  • flow:implement - Updates tracker status

Test: flow:tasks to verify sync
```

---

### 4. Multiple MCPs at Once

**Context**: Setting up comprehensive toolchain

```
User: flow:update

Flow: Scanning for MCP servers...
Flow: ✓ Found: Atlassian (configured)
Flow: ✓ Found: GitHub (new!)
Flow: ✓ Found: Sentry (new!)
Flow: ✓ Found: Linear (new!)

Flow: Found 3 new MCP servers. Configure all? [Y/n]
User: Y

Flow: === GitHub Integration ===
      [... GitHub configuration ...]
      ✓ GitHub configured

Flow: === Sentry Integration ===
      Sentry Project Name:
User: my-project

Flow: Link errors to specs? [Y/n]
User: Y
      ✓ Sentry configured

Flow: === Linear Integration ===
      [... Linear configuration ...]
      ✓ Linear configured
```

**Result**:
```
✓ Configured 3 new integrations!

Summary:
  • GitHub: Task sync, auto-PR
  • Sentry: Error context in specs
  • Linear: Issue tracking

Updated:
  CLAUDE.md: Added 3 integration configs
  __specification__/extensions.json: 6 total MCPs configured
  __specification__/templates/: 3 new templates

Next: flow:specify to use all integrations
```

---

### 5. Sentry Error Context

**Context**: Want error IDs referenced in specifications

```
User: flow:update

Flow: ✓ Found: Sentry MCP (new!)

Flow: Enable Sentry integration? [Y/n]
User: Y

Flow: Sentry Project:
User: production-app

Flow: How should Flow use Sentry?
      [1] Reference errors in specs
      [2] Create specs from error clusters
      [3] Both
User: 3

Flow: Error threshold for auto-spec?
      (Create spec when error count exceeds threshold)
User: 100
```

**Result**:
```
✓ Sentry integration enabled!

Updated:
  CLAUDE.md:
    FLOW_SENTRY_SYNC=enabled
    FLOW_SENTRY_PROJECT=production-app
    FLOW_SENTRY_AUTO_SPEC_THRESHOLD=100

Enhanced skills:
  • flow:specify - Can reference Sentry error IDs
  • flow:discover - Auto-creates specs for high-volume errors

Example usage:
  flow:specify "Fix error SENTRY-ABC123"
  → Pulls error context, stack traces, affected users
```

---

### 6. Reconfiguring Existing MCP

**Context**: Need to change JIRA project or add capabilities

```
User: flow:update --reconfigure Atlassian

Flow: Current Atlassian configuration:
      JIRA Project Key: OLD-PROJ
      Confluence Root Page: 123456
      Branch prepend: true

Flow: What would you like to update?
      [1] JIRA Project Key
      [2] Confluence Root Page
      [3] Branch naming
      [4] All settings
User: 1

Flow: New JIRA Project Key:
User: NEW-PROJ

Flow: Keep existing Confluence page? [Y/n]
User: Y
```

**Result**:
```
✓ Atlassian reconfigured!

Updated:
  CLAUDE.md:
    FLOW_JIRA_PROJECT_KEY=NEW-PROJ (was: OLD-PROJ)

Preserved:
  FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
  FLOW_BRANCH_PREPEND_JIRA=true

Next flow:specify will use NEW-PROJ
```

---

### 7. Disabling Integration

**Context**: No longer using Linear, want to disable

```
User: flow:update --disable Linear

Flow: Disable Linear integration?
      This will:
      • Stop creating Linear issues
      • Preserve existing configuration (can re-enable)
      • Keep templates for reference

      Confirm? [Y/n]
User: Y
```

**Result**:
```
✓ Linear integration disabled

Updated:
  CLAUDE.md:
    FLOW_LINEAR_SYNC=disabled (was: enabled)

Preserved:
  • Configuration values (for re-enabling)
  • Templates (for reference)
  • __specification__/extensions.json entry

To re-enable: flow:update --enable Linear
```

---

## Advanced Patterns

### Gradual Adoption

**Enable one MCP at a time, test, then add more**:

```bash
# Week 1: Add GitHub
flow:update  # Enable GitHub only
flow:tasks   # Test sync
flow:implement  # Test PR creation

# Week 2: Add Sentry
flow:update  # Enable Sentry
flow:specify "Fix error XYZ"  # Test error context

# Week 3: Add Linear
flow:update  # Enable Linear
flow:specify "New feature"  # Test issue creation
```

---

### Multi-Environment Setup

**Different MCPs per environment**:

```bash
# Development
cd dev/
flow:update  # Enable GitHub only

# Staging
cd ../staging/
flow:update  # Enable GitHub + Sentry

# Production
cd ../prod/
flow:update  # Enable all MCPs (JIRA, GitHub, Sentry, monitoring)
```

Each environment has its own CLAUDE.md configuration.

---

### Team Rollout

**Phased rollout across team**:

1. **Pilot (1-2 devs)**: Full MCP stack
2. **Early adopters (25%)**: GitHub + JIRA
3. **Majority (50%)**: JIRA only
4. **Laggards (remaining)**: No integrations (local-only)

Each developer runs `flow:update` to configure their setup.

---

## Anti-Patterns

### ❌ Don't: Configure MCPs that aren't connected

```bash
flow:update
# User: "Enable JIRA"
# But JIRA MCP not installed/connected
# Result: Configuration saved but won't work
```

**Instead**: Verify with `/mcp` first, then configure.

---

### ❌ Don't: Enable all MCPs without understanding

```bash
# Bad: Enable everything blindly
flow:update  # Press Y to everything
```

**Instead**: Enable incrementally, understand each integration's impact.

---

### ❌ Don't: Hardcode secrets in CLAUDE.md

```bash
# Bad: Commit API keys
FLOW_LINEAR_API_KEY=lin_api_secret123  # Committed to git!
```

**Instead**: Use environment variables or `.local.json` (gitignored).

---

## Troubleshooting

### New MCP Not Detected

**Problem**: Added MCP but flow:update doesn't see it

**Solution**:
```bash
# Verify MCP is running
/mcp

# Check .mcp.json
cat .mcp.json

# Restart Claude Code
# Then: flow:update
```

---

### Integration Not Working After Config

**Problem**: Enabled GitHub but tasks not syncing

**Diagnosis**:
```bash
# Check configuration
grep GITHUB CLAUDE.md

# Verify MCP connection
/mcp | grep -i github

# Test MCP directly
# (depends on MCP implementation)
```

**Solution**:
1. Re-authenticate MCP if needed
2. Verify configuration values correct
3. Check MCP server logs
4. Run `flow:update --reconfigure GitHub`

---

### Configuration Conflicts

**Problem**: Multiple MCPs for same purpose (JIRA + Linear)

**Flow behavior**: Uses first enabled integration
- Priority: FLOW_ATLASSIAN_SYNC > FLOW_LINEAR_SYNC > FLOW_GITHUB_SYNC

**Solution**: Disable one:
```bash
flow:update --disable Linear
# Or manually edit CLAUDE.md
```

---

### Template Generation Failed

**Problem**: New integration templates not created

**Solution**:
```bash
# Manual template creation
cat > __specification__/templates/new-integration-template.md <<'EOF'
# Template content...
EOF

# Or copy from plugin
cp plugins/flow/templates/templates/integration-template.md __specification__/templates/
```

---

### Rollback to Previous Config

**Problem**: New configuration breaking workflow

**Solution**:
```bash
# Revert CLAUDE.md
git diff CLAUDE.md  # See changes
git checkout CLAUDE.md  # Revert

# Or manually edit
vim CLAUDE.md
# Set FLOW_XXX_SYNC=disabled

# Restart skills to reload config
```
