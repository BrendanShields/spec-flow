# Flow Update Examples

## Quick Start

### Detect and Configure New MCP

```bash
specter:update
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
User: specter:update

Flow: Scanning for MCP servers...
Flow: ✓ Found: Atlassian MCP (configured)
Flow: ✓ Found: GitHub MCP (new!)

Flow: Enable GitHub Projects integration? [Y/n]
User: Y

Flow: GitHub Project ID (optional):
User: PVT_kwDOABCD123

Flow: Auto-create PRs from specter:implement? [Y/n]
User: Y
```

**Result**:
```
✓ GitHub integration enabled!

Updated:
  CLAUDE.md:
    SPECTER_GITHUB_SYNC=enabled
    SPECTER_GITHUB_PROJECT_ID=PVT_kwDOABCD123
    SPECTER_GITHUB_AUTO_PR=true

  .specter/extensions.json:
    Added GitHub MCP configuration

Created:
  .specter/templates/github-pr-template.md

Enhanced skills:
  • specter:tasks - Now syncs to GitHub Projects
  • specter:implement - Now creates PRs automatically

Next: Run specter:tasks to sync existing tasks
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
    SPECTER_LINEAR_SYNC=enabled
    SPECTER_LINEAR_TEAM_ID=TEAM-abc123

Created:
  .specter/templates/linear-issue-template.md

Your next specter:specify will create Linear issues!
```

---

### 3. Custom MCP Integration

**Context**: Created custom MCP for internal tools

```
User: specter:update

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
      [1] specter:specify
      [2] specter:plan
      [3] specter:tasks
      [4] specter:implement
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
  .specter/extensions.json:
    {
      "company-tracker": {
        "package": "npx company-tracker@latest",
        "capabilities": ["create_task", "update_status"],
        "enhances": {
          "specter:tasks": "Sync tasks to Tracker",
          "specter:implement": "Update status on completion"
        },
        "syncMode": "one-way",
        "updateOnComplete": true
      }
    }

  CLAUDE.md:
    SPECTER_COMPANY_TRACKER_SYNC=enabled

Enhanced skills:
  • specter:tasks - Now syncs to company-tracker
  • specter:implement - Updates tracker status

Test: specter:tasks to verify sync
```

---

### 4. Multiple MCPs at Once

**Context**: Setting up comprehensive toolchain

```
User: specter:update

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
  .specter/extensions.json: 6 total MCPs configured
  .specter/templates/: 3 new templates

Next: specter:specify to use all integrations
```

---

### 5. Sentry Error Context

**Context**: Want error IDs referenced in specifications

```
User: specter:update

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
    SPECTER_SENTRY_SYNC=enabled
    SPECTER_SENTRY_PROJECT=production-app
    SPECTER_SENTRY_AUTO_SPEC_THRESHOLD=100

Enhanced skills:
  • specter:specify - Can reference Sentry error IDs
  • specter:discover - Auto-creates specs for high-volume errors

Example usage:
  specter:specify "Fix error SENTRY-ABC123"
  → Pulls error context, stack traces, affected users
```

---

### 6. Reconfiguring Existing MCP

**Context**: Need to change JIRA project or add capabilities

```
User: specter:update --reconfigure Atlassian

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
    SPECTER_JIRA_PROJECT_KEY=NEW-PROJ (was: OLD-PROJ)

Preserved:
  SPECTER_CONFLUENCE_ROOT_PAGE_ID=123456
  SPECTER_BRANCH_PREPEND_JIRA=true

Next specter:specify will use NEW-PROJ
```

---

### 7. Disabling Integration

**Context**: No longer using Linear, want to disable

```
User: specter:update --disable Linear

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
    SPECTER_LINEAR_SYNC=disabled (was: enabled)

Preserved:
  • Configuration values (for re-enabling)
  • Templates (for reference)
  • .specter/extensions.json entry

To re-enable: specter:update --enable Linear
```

---

## Advanced Patterns

### Gradual Adoption

**Enable one MCP at a time, test, then add more**:

```bash
# Week 1: Add GitHub
specter:update  # Enable GitHub only
specter:tasks   # Test sync
specter:implement  # Test PR creation

# Week 2: Add Sentry
specter:update  # Enable Sentry
specter:specify "Fix error XYZ"  # Test error context

# Week 3: Add Linear
specter:update  # Enable Linear
specter:specify "New feature"  # Test issue creation
```

---

### Multi-Environment Setup

**Different MCPs per environment**:

```bash
# Development
cd dev/
specter:update  # Enable GitHub only

# Staging
cd ../staging/
specter:update  # Enable GitHub + Sentry

# Production
cd ../prod/
specter:update  # Enable all MCPs (JIRA, GitHub, Sentry, monitoring)
```

Each environment has its own CLAUDE.md configuration.

---

### Team Rollout

**Phased rollout across team**:

1. **Pilot (1-2 devs)**: Full MCP stack
2. **Early adopters (25%)**: GitHub + JIRA
3. **Majority (50%)**: JIRA only
4. **Laggards (remaining)**: No integrations (local-only)

Each developer runs `specter:update` to configure their setup.

---

## Anti-Patterns

### ❌ Don't: Configure MCPs that aren't connected

```bash
specter:update
# User: "Enable JIRA"
# But JIRA MCP not installed/connected
# Result: Configuration saved but won't work
```

**Instead**: Verify with `/mcp` first, then configure.

---

### ❌ Don't: Enable all MCPs without understanding

```bash
# Bad: Enable everything blindly
specter:update  # Press Y to everything
```

**Instead**: Enable incrementally, understand each integration's impact.

---

### ❌ Don't: Hardcode secrets in CLAUDE.md

```bash
# Bad: Commit API keys
SPECTER_LINEAR_API_KEY=lin_api_secret123  # Committed to git!
```

**Instead**: Use environment variables or `.local.json` (gitignored).

---

## Troubleshooting

### New MCP Not Detected

**Problem**: Added MCP but specter:update doesn't see it

**Solution**:
```bash
# Verify MCP is running
/mcp

# Check .mcp.json
cat .mcp.json

# Restart Claude Code
# Then: specter:update
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
4. Run `specter:update --reconfigure GitHub`

---

### Configuration Conflicts

**Problem**: Multiple MCPs for same purpose (JIRA + Linear)

**Flow behavior**: Uses first enabled integration
- Priority: SPECTER_ATLASSIAN_SYNC > SPECTER_LINEAR_SYNC > SPECTER_GITHUB_SYNC

**Solution**: Disable one:
```bash
specter:update --disable Linear
# Or manually edit CLAUDE.md
```

---

### Template Generation Failed

**Problem**: New integration templates not created

**Solution**:
```bash
# Manual template creation
cat > .specter/templates/new-integration-template.md <<'EOF'
# Template content...
EOF

# Or copy from plugin
cp plugins/specter/templates/templates/integration-template.md .specter/templates/
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
# Set SPECTER_XXX_SYNC=disabled

# Restart skills to reload config
```
