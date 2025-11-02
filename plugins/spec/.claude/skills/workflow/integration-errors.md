# Integration Error Handling Guide

**Purpose**: Comprehensive guide to handling failures in external integrations (JIRA, Confluence, Linear, GitHub, OpenAPI) during Spec workflow execution.

**Philosophy**: Workflow continues locally when integrations fail. External systems are conveniences, not dependencies.

**Version**: 3.0 | **Last Updated**: 2025-11-02

---

## Overview

### Integration Types Supported

Spec workflow can integrate with external systems via MCP (Model Context Protocol) servers:

1. **JIRA** - Story/epic tracking
2. **Confluence** - Documentation publishing
3. **Linear** - Issue tracking
4. **GitHub** - Issue creation and PR linking
5. **OpenAPI** - API schema validation and documentation

### Graceful Degradation Principle

**Core Design Philosophy**:
- **Local-first**: All artifacts (spec.md, plan.md, tasks.md) are created locally regardless of integration status
- **Non-blocking**: Integration failures generate warnings, not errors
- **Retry-capable**: Failed syncs can be retried after fixing configuration
- **Manual fallback**: Users can manually create external resources from local artifacts

**What This Means**:
```
Integration Success: Local artifacts + External resources
Integration Failure: Local artifacts only (workflow continues)
```

You can always continue your development work. External syncing is a bonus, not a requirement.

---

## Common Integration Failures

### 1. MCP Not Configured

**Error Message**:
```
Warning: MCP integration not configured
SPEC_ATLASSIAN_SYNC not found in CLAUDE.md
Continuing with local workflow only.
```

**What Happened**:
- User's project has no MCP integration configuration
- Workflow attempted to sync but found no config

**Impact**:
- **Local work**: Unaffected - spec.md, plan.md, tasks.md created normally
- **External sync**: Skipped - no JIRA stories or Confluence pages created
- **Workflow**: Continues to next phase without interruption

**When This Occurs**:
- First-time Spec users
- Projects intentionally running local-only
- MCP server not installed or configured

**Resolution**:

**Option 1**: Configure MCP integration (if desired)
```markdown
# Edit CLAUDE.md in project root
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
```

Then re-run the command that failed:
```bash
/spec generate "Feature" --sync
```

**Option 2**: Continue without integration
```bash
# No action needed - workflow already continued
# Local artifacts available in features/###-feature-name/
```

**Option 3**: Manual sync later
```bash
# After configuring MCP, sync existing features
/spec sync --feature=003
```

---

### 2. Authentication Failed

**Error Messages**:
```
Error: MCP authentication failed
JIRA API returned 401 Unauthorized
Check credentials in MCP settings.

Warning: Continuing with local workflow only.
```

```
Error: Confluence authentication failed
Invalid API token or insufficient permissions
```

**What Happened**:
- MCP configuration exists but credentials are invalid
- API token expired or was revoked
- User lacks required permissions in external system

**Impact**:
- **Local work**: Unaffected
- **External sync**: Failed - no resources created
- **Workflow**: Continues locally

**Common Causes**:
1. Expired API tokens
2. Incorrect username/email in configuration
3. Insufficient JIRA/Confluence permissions
4. Account locked or deactivated

**Resolution**:

**Step 1**: Verify credentials in MCP configuration
```bash
# Check MCP settings (location depends on MCP server)
cat ~/.config/claude/mcp.json
# or
cat ~/.mcp/config.json
```

**Step 2**: Update API token
```bash
# For JIRA/Confluence (Atlassian MCP)
# Generate new API token: https://id.atlassian.com/manage/api-tokens

# Update MCP config with new token
# Then restart Claude Code to reload config
```

**Step 3**: Verify permissions
- JIRA: Ensure user can create issues in target project
- Confluence: Ensure user can create pages in target space
- Check with system administrator if needed

**Step 4**: Retry sync
```bash
/spec sync --feature=003
```

**Example Recovery**:
```bash
# 1. Check what failed
cat .spec-state/current-session.md
# Shows: "JIRA sync failed - authentication error"

# 2. Generate new API token
# Visit: https://id.atlassian.com/manage/api-tokens

# 3. Update MCP config
# (Edit MCP configuration file)

# 4. Restart Claude Code
# (Close and reopen)

# 5. Retry sync
/spec sync --feature=003
# Output: "JIRA story PROJ-123 created successfully"
```

---

### 3. Network/Timeout Issues

**Error Messages**:
```
Warning: MCP temporarily unavailable
Request to JIRA API timed out after 30s
Retrying once...

Error: Retry failed - network timeout
Continuing with local workflow only.
```

```
Error: Unable to reach Confluence server
Network error: ECONNREFUSED
Local artifacts saved. Retry sync later.
```

**What Happened**:
- Network connectivity issues
- External API temporarily down or slow
- Firewall blocking API requests
- VPN disconnected (if required)

**Impact**:
- **Local work**: Unaffected - all artifacts saved
- **External sync**: Failed but can be retried
- **Workflow**: Continues normally

**Automatic Retry**:
Workflow automatically retries network failures once:
```
Attempt 1: Failed (timeout)
Attempt 2: Failed (timeout)
→ Fallback to local-only
```

**Resolution**:

**Immediate**:
```bash
# Check network connectivity
ping api.atlassian.com

# Check if VPN required
# Connect to VPN if needed

# Retry sync
/spec sync --feature=003
```

**Later**:
```bash
# Continue working locally
/spec plan
/spec tasks
/spec implement

# Sync when network restored
/spec sync --all-features
```

**Troubleshooting Network Issues**:
```bash
# Test JIRA API directly
curl -u "email@example.com:API_TOKEN" \
  https://your-domain.atlassian.net/rest/api/3/myself

# Expected: JSON with user info
# If fails: Network/auth issue
```

---

### 4. Invalid Configuration

**Error Messages**:
```
Error: MCP config incomplete
Missing required field: SPEC_JIRA_PROJECT_KEY
Cannot sync to JIRA without project key.

Warning: Continuing with local workflow only.
```

```
Error: Invalid Confluence page ID
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456 not found
Check page exists and is accessible.
```

**What Happened**:
- Configuration partially complete
- Required fields missing or incorrect
- Referenced resources (pages, projects) don't exist

**Impact**:
- **Local work**: Unaffected
- **External sync**: Disabled for this run
- **Workflow**: Continues locally

**Common Missing Fields**:

**JIRA Integration**:
```markdown
# Required in CLAUDE.md:
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ        ← Often missing
SPEC_JIRA_API_TOKEN=[token]       ← Or invalid
```

**Confluence Integration**:
```markdown
SPEC_ATLASSIAN_SYNC=enabled
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456  ← Must exist
```

**Linear Integration**:
```markdown
SPEC_LINEAR_SYNC=enabled
SPEC_LINEAR_TEAM_ID=TEAM123       ← Often missing
```

**Resolution**:

**Step 1**: Check current configuration
```bash
cat CLAUDE.md | grep SPEC_
# Shows all Spec-related config
```

**Step 2**: Add missing fields
```markdown
# Edit CLAUDE.md

# For JIRA:
SPEC_JIRA_PROJECT_KEY=MYPROJ

# For Confluence (find page ID in URL):
# URL: https://company.atlassian.net/wiki/spaces/DEV/pages/123456/Title
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456

# For Linear (find in Linear settings):
SPEC_LINEAR_TEAM_ID=TEAM_abc123
```

**Step 3**: Validate configuration
```bash
/spec validate --config
# Checks all required fields present
```

**Step 4**: Retry sync
```bash
/spec sync --feature=003
```

**Example - Finding Confluence Page ID**:
```bash
# Option 1: From URL
# https://company.atlassian.net/wiki/spaces/SPACE/pages/123456/Page-Title
#                                                          ^^^^^^ This is the ID

# Option 2: Using Confluence API
curl -u "email:token" \
  "https://your-domain.atlassian.net/wiki/rest/api/content/123456" \
  | jq .id
```

---

### 5. API Limits / Rate Limiting

**Error Messages**:
```
Warning: JIRA API rate limit exceeded
Limit: 100 requests/minute
Retry after: 45 seconds

Delaying sync... will retry automatically.
```

```
Error: Rate limit exceeded, retry failed
Continuing with local workflow.
Sync manually later: /spec sync --feature=003
```

**What Happened**:
- Too many API requests in short time
- JIRA/Confluence free tier limits reached
- MCP server throttled by external API

**Impact**:
- **Local work**: Unaffected
- **External sync**: Delayed or failed
- **Workflow**: Continues after brief pause

**Common Rate Limits**:
- **JIRA Cloud**: 100 requests/minute per user
- **Confluence Cloud**: 100 requests/minute per user
- **Linear**: 1000 requests/hour
- **GitHub**: 5000 requests/hour (authenticated)

**Automatic Handling**:
```
Rate limit hit → Wait (delay from API header)
Rate limit hit again → Fallback to local
User can retry: /spec sync --later
```

**Resolution**:

**Wait and Retry**:
```bash
# Workflow automatically waits if rate limit provides retry-after
# If still fails, retry manually:

# Wait 1 minute
sleep 60

# Retry sync
/spec sync --feature=003
```

**Batch Sync Later**:
```bash
# Continue workflow locally
/spec plan
/spec tasks

# Sync all at once when rate limit resets
/spec sync --all-features --batch
# Batches requests to stay under limits
```

**Check Rate Limit Status**:
```bash
# For JIRA (via API)
curl -u "email:token" \
  -I https://your-domain.atlassian.net/rest/api/3/myself \
  | grep -i "x-rate-limit"

# Shows:
# x-rate-limit-limit: 100
# x-rate-limit-remaining: 23
# x-rate-limit-reset: 1699564800
```

**Prevention**:
- Use `--batch` flag for multi-feature syncs
- Don't sync every spec change, batch updates
- Upgrade to paid tier if hitting limits frequently

---

## Integration-Specific Failures

### JIRA Integration

#### Story Creation Failed

**Error**:
```
Error: Failed to create JIRA story
Field 'storyPoints' is not on screen for issue type 'Story'

Warning: spec.md created locally without JIRA link.
```

**What Happened**:
- JIRA project has custom field configuration
- Workflow used field not available in project
- Screen configuration doesn't include expected field

**Resolution**:

**Option 1**: Customize JIRA template
```bash
# Copy template
cp workflow/templates/integrations/jira-story-template.md \
   .spec/templates/jira-story-template.md

# Edit to match your JIRA configuration
# Remove fields not in your project
# Add custom fields used by your team
```

**Option 2**: Update JIRA screen configuration
```bash
# In JIRA:
# Project Settings → Issue Types → Story → Configure Screen
# Add missing fields like "Story Points"
```

**Option 3**: Manual creation
```bash
# Create JIRA story manually from spec.md
# Copy user story details from features/003-*/spec.md
# Create story in JIRA UI or CLI
```

#### Epic Linking Failed

**Error**:
```
Error: Cannot link story to epic PROJ-100
Epic not found or user lacks permission

Story PROJ-101 created but not linked to epic.
```

**Resolution**:
```bash
# Verify epic exists
# In JIRA, search for PROJ-100

# If missing, update spec.md with correct epic ID:
nano features/003-*/spec.md
# Update JIRA_EPIC_ID field

# Retry sync
/spec sync --feature=003
```

#### Custom Field Validation Failed

**Error**:
```
Error: Custom field validation failed
Field 'customfield_10001' (Sprint) is required

Cannot create story without required custom fields.
```

**Resolution**:
```markdown
# Add custom fields to CLAUDE.md:
SPEC_JIRA_CUSTOM_FIELD_SPRINT=customfield_10001
SPEC_JIRA_CUSTOM_FIELD_TEAM=customfield_10002

# Or customize jira-story-template.md to include defaults
```

**Fallback**:
```bash
# Workflow creates spec.md locally
# User can manually create JIRA story
# Copy spec.md content to JIRA UI
# Fill custom fields manually
```

---

### Confluence Integration

#### Page Creation Failed - Duplicate Title

**Error**:
```
Error: Confluence page with title "Feature: User Auth" already exists
Cannot create duplicate page in same space.

Suggestion: Update existing page or change title.
```

**Resolution**:

**Option 1**: Update existing page
```bash
/spec generate "Feature" --confluence-update
# Updates existing page instead of creating new
```

**Option 2**: Change feature name
```bash
/spec generate "User Authentication v2"
# Creates new page with unique title
```

**Option 3**: Archive old page
```bash
# In Confluence UI:
# Navigate to old page → More Actions → Archive
# Then retry sync
/spec sync --feature=003
```

#### Permission Denied

**Error**:
```
Error: Permission denied creating Confluence page
User lacks 'Add Page' permission in space 'DEV'

Contact Confluence administrator for permissions.
```

**Resolution**:
```bash
# Contact admin to grant permissions
# Or use different space with write access

# Update config:
# SPEC_CONFLUENCE_SPACE=ALTSPACE (space where you have access)
```

**Temporary Workaround**:
```bash
# Export plan.md as Confluence format
/spec export plan --format=confluence > plan-confluence.md

# Manually paste into Confluence
# Or send to admin to publish
```

#### Space Not Found

**Error**:
```
Error: Confluence space 'INVALID' not found
Check SPEC_CONFLUENCE_SPACE configuration.
```

**Resolution**:
```bash
# List available spaces (via Confluence API or UI)
# Update config with valid space key
nano CLAUDE.md
# Set: SPEC_CONFLUENCE_SPACE=VALID
```

---

### OpenAPI Integration

#### Schema Validation Failed

**Error**:
```
Error: Invalid OpenAPI schema generated
Validation error: Missing required field 'info.version'

openapi.yaml created but may not be valid.
Review and fix before use.
```

**Impact**:
- openapi.yaml file created but has errors
- May not work with Swagger UI or validators
- Local workflow continues

**Resolution**:

**Step 1**: Check validation errors
```bash
# Use OpenAPI validator
npx @openapitools/openapi-generator-cli validate \
  -i features/003-*/openapi.yaml
```

**Step 2**: Fix errors manually
```bash
nano features/003-*/openapi.yaml
# Add missing required fields
# Fix schema syntax
```

**Step 3**: Re-validate
```bash
/spec validate --openapi
```

**Common Issues**:
- Missing `info.version` field
- Invalid parameter types
- Circular schema references
- Missing required endpoint fields

#### Invalid Endpoint Definitions

**Error**:
```
Warning: API endpoint POST /users missing request body schema
OpenAPI spec may be incomplete.

Generated with best-effort. Review and complete manually.
```

**Resolution**:
```bash
# Edit openapi.yaml
# Add missing request body schema:

paths:
  /users:
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'

components:
  schemas:
    CreateUserRequest:
      type: object
      properties:
        email:
          type: string
        name:
          type: string
```

---

## Fallback Behaviors

### What ALWAYS Works (Integration-Independent)

Even if all integrations fail, these operations always succeed:

#### 1. Local Artifact Creation
```bash
/spec generate "Feature"
→ features/003-feature/spec.md created ✓

/spec plan
→ features/003-feature/plan.md created ✓

/spec tasks
→ features/003-feature/tasks.md created ✓
```

#### 2. State Management
```bash
# Session state tracking
.spec-state/current-session.md updated ✓

# Decision logging
.spec-memory/DECISIONS-LOG.md updated ✓

# Progress tracking
.spec-memory/WORKFLOW-PROGRESS.md updated ✓
```

#### 3. Git Operations
```bash
# Branch creation
git checkout -b feature/003-user-auth ✓

# Commits
git add features/003-*
git commit -m "feat: Add user auth spec" ✓
```

#### 4. Validation
```bash
/spec validate
→ Checks spec.md, plan.md, tasks.md consistency ✓
```

#### 5. Local Implementation
```bash
/spec implement
→ Executes tasks from tasks.md ✓
→ Updates code locally ✓
→ Runs tests ✓
```

### Graceful Degradation Examples

**Scenario 1: JIRA Down During Generate**
```bash
/spec generate "User Authentication"

Output:
✓ spec.md created at features/003-user-authentication/spec.md
✗ JIRA sync failed: network timeout
  → Story not created in JIRA
  → Continue with local spec
  → Sync later: /spec sync --feature=003

Next: /spec plan
```

**Scenario 2: Confluence Unavailable During Plan**
```bash
/spec plan

Output:
✓ plan.md created at features/003-user-authentication/plan.md
✗ Confluence publish failed: authentication error
  → Page not created in Confluence
  → Plan available locally
  → Publish later: /spec publish --confluence --feature=003

Next: /spec tasks
```

**Scenario 3: All Integrations Fail**
```bash
/spec orchestrate

Output:
Phase 1: Initialize
✓ .spec/ structure created

Phase 2: Generate Specification
✓ spec.md created
✗ JIRA sync: disabled (no config)
✗ Linear sync: disabled (no config)

Phase 3: Plan
✓ plan.md created
✗ Confluence publish: disabled (no config)
✗ OpenAPI: skipped (no API endpoints detected)

Phase 4: Tasks
✓ tasks.md created
✗ GitHub issues: disabled (no config)

Phase 5: Implement
✓ Implementation complete
✓ All tests passing

Summary:
✓ Feature fully implemented locally
✗ No external syncing (integrations disabled)
→ All artifacts in features/003-user-authentication/
→ Configure integrations to enable sync
```

---

## Best Practices

### 1. Configure Integrations as Optional

**In CLAUDE.md**:
```markdown
# Integration Configuration
# Note: All integrations are optional
# Workflow continues locally if disabled or failing

## JIRA Integration (Optional)
# Uncomment to enable:
# SPEC_ATLASSIAN_SYNC=enabled
# SPEC_JIRA_PROJECT_KEY=PROJ
# SPEC_JIRA_API_TOKEN=[token]

## Confluence Integration (Optional)
# Uncomment to enable:
# SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
```

**Benefits**:
- New users aren't blocked by integration setup
- Team members can opt-in individually
- Local development always works

### 2. Test Integration Setup Separately

**Before Starting Workflow**:
```bash
# Test JIRA connection
/spec test-integration --jira

Output:
✓ JIRA connection successful
✓ Project PROJ accessible
✓ User can create issues
→ Integration ready

# Or:
✗ JIRA connection failed: authentication error
→ Fix credentials before using /spec generate --sync
```

**During Init**:
```bash
/spec init --test-integrations

Output:
Testing configured integrations...
✓ JIRA: Connected
✗ Confluence: Authentication failed
✗ Linear: Not configured
→ 1/3 integrations ready
```

### 3. Don't Depend on External Systems for Core Workflow

**Good Workflow**:
```bash
# 1. Develop locally first
/spec generate "Feature"
/spec plan
/spec tasks
/spec implement

# 2. Sync to external systems when convenient
/spec sync --all-features
```

**Bad Workflow**:
```bash
# Don't block on integration failures
/spec generate "Feature" --require-jira  # ❌ Fails if JIRA down
```

### 4. Keep Local Copies of All Artifacts

**Version Control**:
```bash
# Commit local artifacts
git add features/003-*
git commit -m "feat: Add user auth feature"

# Push to Git
git push origin feature/003-user-auth
```

**Benefits**:
- Work offline
- Integration failures don't lose work
- Git becomes source of truth
- External systems (JIRA, Confluence) are mirrors

### 5. Use Batch Sync for Multiple Features

**Efficient**:
```bash
# Develop multiple features locally
/spec generate "Feature A"
/spec generate "Feature B"
/spec generate "Feature C"

# Sync all at once (respects rate limits)
/spec sync --all-features --batch
```

**Inefficient**:
```bash
# Sync each feature individually
/spec generate "Feature A" --sync
/spec generate "Feature B" --sync
/spec generate "Feature C" --sync
# 3x API calls, higher rate limit risk
```

---

## Troubleshooting Integration Issues

### Debugging Steps

**Step 1**: Check workflow status
```bash
/spec status

Output:
Current Feature: 003-user-authentication
Phase: Implementation
Integrations:
  ✗ JIRA: Last sync failed (auth error)
  ✓ GitHub: Connected
  - Confluence: Not configured
```

**Step 2**: Review error logs
```bash
cat .spec-state/integration-errors.log

Recent errors:
2025-11-02 10:30:15 | JIRA | 401 Unauthorized | Check API token
2025-11-02 10:31:42 | Confluence | Timeout | Network issue
```

**Step 3**: Validate configuration
```bash
/spec validate --config

Results:
✓ SPEC_JIRA_PROJECT_KEY: PROJ
✗ SPEC_JIRA_API_TOKEN: [hidden] (invalid)
✓ SPEC_GITHUB_OWNER: myorg
✓ SPEC_GITHUB_REPO: myrepo
- SPEC_CONFLUENCE_*: Not configured
```

**Step 4**: Test individual integrations
```bash
# Test JIRA
/spec test-integration --jira
→ Diagnoses JIRA-specific issues

# Test Confluence
/spec test-integration --confluence
→ Checks auth, space access, permissions
```

**Step 5**: Check network connectivity
```bash
# Test external API endpoints
ping api.atlassian.com
curl https://api.atlassian.com/health

# Check firewall/proxy
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

### Common Fixes

#### Fix 1: Regenerate API Token

**For JIRA/Confluence**:
```bash
# 1. Visit: https://id.atlassian.com/manage/api-tokens
# 2. Create API Token → Label: "Claude Spec Plugin"
# 3. Copy token
# 4. Update config (MCP settings or CLAUDE.md)
# 5. Restart Claude Code
# 6. Retry: /spec sync --feature=003
```

#### Fix 2: Update Project/Space Keys

**Check valid values**:
```bash
# For JIRA projects
curl -u "email:token" \
  https://your-domain.atlassian.net/rest/api/3/project \
  | jq '.[].key'

Output:
"PROJ"
"DEV"
"OPS"

# Update CLAUDE.md with correct key
```

#### Fix 3: Fix Firewall/Proxy Issues

**Configure proxy**:
```bash
# Set environment variables
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1

# Test connection
curl https://api.atlassian.com
```

#### Fix 4: Downgrade Integration Tier

**If rate limits are issue**:
```bash
# Use manual sync instead of automatic
# Configure in CLAUDE.md:
SPEC_SYNC_MODE=manual  # Not automatic

# Sync explicitly when ready
/spec sync --feature=003
```

---

## Recovery Procedures

### Sync After Fixing Issues

**Scenario**: Integration was broken during `generate`, now fixed.

**Steps**:
```bash
# 1. Verify integration working
/spec test-integration --jira
→ ✓ JIRA: Connected

# 2. Sync existing feature
/spec sync --feature=003

Output:
Syncing feature 003-user-authentication...
✓ Reading spec.md
✓ Creating JIRA story PROJ-123
✓ Linking to epic PROJ-100
✓ Updating spec.md with JIRA link

Success: Feature 003 synced to JIRA
JIRA: https://company.atlassian.net/browse/PROJ-123
```

### Manual Sync Process

**When**: Automation failed, need to sync manually.

**For JIRA Stories**:

**Step 1**: Read local spec.md
```bash
cat features/003-user-authentication/spec.md
```

**Step 2**: Extract user story details
- Epic: User Management
- Story title: "As a user, I want to authenticate..."
- Acceptance criteria: [...list...]
- Priority: P1

**Step 3**: Create JIRA story manually
```bash
# Via JIRA UI or CLI
jira issue create \
  --type=Story \
  --project=PROJ \
  --summary="User Authentication" \
  --description="$(cat features/003-*/spec.md)" \
  --priority=High
```

**Step 4**: Link story ID back to spec.md
```bash
# Edit spec.md frontmatter
nano features/003-user-authentication/spec.md

# Add:
jira_id: PROJ-123
jira_url: https://company.atlassian.net/browse/PROJ-123
```

**For Confluence Pages**:

**Step 1**: Export plan as Confluence format
```bash
/spec export plan --format=confluence --feature=003 > plan-confluence.html
```

**Step 2**: Create page in Confluence UI
- Space: DEV
- Parent: Technical Plans
- Title: "Feature 003: User Authentication - Technical Plan"
- Content: Paste from plan-confluence.html

**Step 3**: Link page ID back
```bash
nano features/003-user-authentication/plan.md

# Add frontmatter:
confluence_page_id: 789012
confluence_url: https://company.atlassian.net/wiki/spaces/DEV/pages/789012
```

### Bulk Re-sync After Outage

**Scenario**: Integration was down for days, now back online.

**Steps**:
```bash
# 1. Find features missing external links
/spec audit --missing-integrations

Output:
Features without JIRA links:
- 003-user-authentication
- 004-password-reset
- 005-2fa

# 2. Sync all at once (batch mode)
/spec sync --features=003,004,005 --batch

Output:
Syncing 3 features...
✓ 003: PROJ-123 created
✓ 004: PROJ-124 created
✓ 005: PROJ-125 created

All features synced successfully.
```

---

## Related Resources

- **Integration Patterns**: `shared/integration-patterns.md` - MCP integration patterns
- **Error Recovery**: `error-recovery.md` - General error handling guide
- **Configuration**: Project CLAUDE.md - Integration configuration examples
- **MCP Documentation**: [Model Context Protocol](https://modelcontextprotocol.com)

---

## Quick Reference

### Integration Error Types

| Error | Impact | Resolution |
|-------|--------|------------|
| MCP not configured | No external sync | Optional - configure or continue locally |
| Authentication failed | Sync blocked | Update credentials, retry |
| Network timeout | Temporary failure | Retry later or continue locally |
| Invalid config | Integration disabled | Fix config fields, retry |
| Rate limit exceeded | Sync delayed | Wait and retry, or batch later |
| JIRA story creation failed | No JIRA link | Create manually or fix template |
| Confluence page exists | No page created | Update existing or change title |
| OpenAPI validation failed | Invalid schema | Fix manually, re-validate |

### Common Commands

```bash
# Test integrations
/spec test-integration --jira
/spec test-integration --confluence

# Validate configuration
/spec validate --config

# Sync after fixing
/spec sync --feature=003
/spec sync --all-features --batch

# Manual export
/spec export plan --format=confluence
/spec export tasks --format=github-issues

# Check status
/spec status
cat .spec-state/integration-errors.log
```

---

**Remember**: Integrations enhance the workflow but never block it. Local artifacts are always created, and external syncing is a convenience. When in doubt, continue locally and sync later.

**Questions?** See error-recovery.md or CLAUDE.md configuration examples.
