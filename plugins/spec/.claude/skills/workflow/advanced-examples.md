# Advanced Workflow Examples

## Overview

This guide provides real-world scenarios for advanced state management and troubleshooting. Use these examples when:

- Recovering from interrupted or corrupted workflow sessions
- Managing workflow state across machines or team members
- Debugging state inconsistencies
- Handling complex multi-feature scenarios
- Customizing workflow for team-specific needs

**Prerequisites**: Familiarity with basic workflow commands and state files (WORKFLOW-PROGRESS.md, .workflow-session.json, ACTIVE-CONTEXT.md).

---

## State Management Examples

### Example 1: Manual State Recovery

**Scenario**: Your workflow session crashed mid-implementation, and `.workflow-session.json` is corrupted or missing.

**Problem**: Running `/spec workflow:status` shows:
```
Error: Invalid session state
Cannot parse .workflow-session.json
```

**Recovery Steps**:

```bash
# 1. Backup corrupted state
cp .workflow-session.json .workflow-session.json.backup

# 2. Check WORKFLOW-PROGRESS.md for last known state
cat WORKFLOW-PROGRESS.md
```

**Expected output**:
```markdown
# Workflow Progress

## Feature: User Authentication API
Status: IMPLEMENTING
Phase: Task Execution
Progress: 45%

### Completed Tasks
- [x] T001: Create User model
- [x] T002: Add password hashing
- [x] T003: Create JWT utilities

### In Progress
- [ ] T004: Implement login endpoint (CURRENT)

### Pending
- [ ] T005: Implement logout endpoint
- [ ] T006: Add token refresh
...
```

```bash
# 3. Reconstruct session state
/spec workflow:resume --recover-from=progress

# 4. Verify state reconstruction
/spec workflow:status
```

**What's happening**: The `--recover-from=progress` flag tells the workflow to rebuild session state from WORKFLOW-PROGRESS.md. It:
- Reads completed tasks
- Identifies current phase
- Reconstructs context from ACTIVE-CONTEXT.md
- Creates new session with recovered state

**Verification**:
```bash
# Check session is valid
cat .workflow-session.json | jq '.phase, .currentTask'

# Verify you can continue
/spec workflow:next
```

---

### Example 2: Migrating State Between Machines

**Scenario**: Started work on laptop, now switching to desktop to continue.

**On Laptop** (before leaving):
```bash
# 1. Ensure all state is committed
/spec workflow:checkpoint "Moving to desktop"

# 2. Identify state files to transfer
ls -la | grep -E '(WORKFLOW|ACTIVE|\.workflow)'
```

**Files to copy**:
```
.workflow-session.json          # Current session state
WORKFLOW-PROGRESS.md            # Progress tracking
ACTIVE-CONTEXT.md               # Current context
docs/spec/feature-name.spec.md  # Specification
.workflow-checkpoints/          # Checkpoints (optional)
```

**Transfer command**:
```bash
# Using rsync
rsync -av \
  .workflow-session.json \
  WORKFLOW-PROGRESS.md \
  ACTIVE-CONTEXT.md \
  docs/spec/ \
  .workflow-checkpoints/ \
  user@desktop:/path/to/project/

# Or commit and pull
git add .workflow-session.json WORKFLOW-PROGRESS.md ACTIVE-CONTEXT.md docs/spec/
git commit -m "chore: checkpoint workflow state"
git push
```

**On Desktop**:
```bash
# 1. Pull latest state
git pull

# 2. Validate state consistency
/spec workflow:validate

# 3. Check status
/spec workflow:status
```

**Expected validation output**:
```
✓ Session state valid
✓ Progress tracking in sync
✓ Active context matches session
✓ Specification file exists
✓ All task references valid

Current Phase: IMPLEMENTING
Current Task: T004 - Implement login endpoint
Ready to continue: Yes
```

**Continue working**:
```bash
/spec workflow:next
```

---

### Example 3: Debugging State Inconsistencies

**Scenario**: WORKFLOW-PROGRESS.md shows feature complete, but session shows still in progress.

**Symptoms**:
```bash
/spec workflow:status
# Shows: Phase: IMPLEMENTING, Progress: 85%

grep "Status:" WORKFLOW-PROGRESS.md
# Shows: Status: COMPLETE
```

**Diagnosis**:

```bash
# 1. Compare session state with progress file
jq '.phase, .status' .workflow-session.json
cat WORKFLOW-PROGRESS.md | grep -E "Status:|Phase:"

# 2. Check for timestamp mismatch
jq '.lastUpdated' .workflow-session.json
stat -f "%Sm" WORKFLOW-PROGRESS.md
```

**Output**:
```json
// .workflow-session.json
{
  "phase": "implementing",
  "status": "in_progress",
  "lastUpdated": "2025-11-02T10:30:00Z"
}

// WORKFLOW-PROGRESS.md modified: Nov 2 14:45
```

**Problem identified**: Progress file updated manually or by another process.

**Resolution**:

```bash
# 3. Use diff to see exact differences
diff <(jq -S . .workflow-session.json) \
     <(echo '{"phase":"complete","status":"complete"}' | jq -S .)

# 4. Decide which is correct source of truth

# Option A: Session is correct (progress file was wrong)
/spec workflow:sync --from=session

# Option B: Progress file is correct (session is stale)
/spec workflow:sync --from=progress

# Option C: Manual reconciliation
/spec workflow:reconcile --interactive
```

**Interactive reconciliation**:
```
Inconsistency detected:

Session state:
  Phase: IMPLEMENTING
  Status: IN_PROGRESS
  Current Task: T008
  Completed: 7/10 tasks

Progress file:
  Phase: COMPLETE
  Status: COMPLETE
  Current Task: None
  Completed: 10/10 tasks

Which is correct?
1) Session state (continue implementation)
2) Progress file (mark complete)
3) Manual review

Choice: 3

Showing task completion status:
T001: ✓ Implementation found in src/auth/user.model.ts
T002: ✓ Implementation found in src/auth/hash.ts
...
T008: ✗ No implementation found
T009: ✗ No implementation found
T010: ✗ No implementation found

Recommended: Session state is correct
Accept? (y/n): y

✓ Session state preserved
✓ Progress file updated to match
```

---

### Example 4: Archiving Completed Features

**Scenario**: Project has 50 completed features; state files and git history are getting large.

**Current state**:
```bash
# Check workflow directory size
du -sh .workflow-checkpoints/
# Output: 45M    .workflow-checkpoints/

ls docs/spec/*.spec.md | wc -l
# Output: 52
```

**Archive strategy**:

```bash
# 1. Identify completed features older than 30 days
find docs/spec -name "*.spec.md" -type f -mtime +30 | while read spec; do
  if grep -q "Status: COMPLETE" "$spec"; then
    echo "$spec"
  fi
done > /tmp/completed-specs.txt

# 2. Create archive directory
mkdir -p .workflow-archive/$(date +%Y-%m)

# 3. Archive old completed features
cat /tmp/completed-specs.txt | while read spec; do
  feature_name=$(basename "$spec" .spec.md)

  # Move spec and related files
  mkdir -p ".workflow-archive/$(date +%Y-%m)/$feature_name"
  mv "$spec" ".workflow-archive/$(date +%Y-%m)/$feature_name/"

  # Archive checkpoints if they exist
  if [ -d ".workflow-checkpoints/$feature_name" ]; then
    mv ".workflow-checkpoints/$feature_name" \
       ".workflow-archive/$(date +%Y-%m)/$feature_name/"
  fi

  # Archive progress files
  if [ -f "WORKFLOW-PROGRESS-$feature_name.md" ]; then
    mv "WORKFLOW-PROGRESS-$feature_name.md" \
       ".workflow-archive/$(date +%Y-%m)/$feature_name/"
  fi
done

# 4. Create archive index
cat > ".workflow-archive/$(date +%Y-%m)/INDEX.md" <<EOF
# Archived Features - $(date +%Y-%m)

## Features Archived

$(cat /tmp/completed-specs.txt | while read spec; do
  feature_name=$(basename "$spec" .spec.md)
  echo "- $feature_name"
done)

## Archive Date
$(date)

## Restore Instructions
To restore a feature:
\`\`\`bash
cp -r .workflow-archive/YYYY-MM/feature-name/feature-name.spec.md docs/spec/
\`\`\`
EOF

# 5. Commit archive
git add .workflow-archive/
git commit -m "chore: archive completed features from $(date +%Y-%m)"

# 6. Verify space savings
du -sh .workflow-checkpoints/
# Output: 12M    .workflow-checkpoints/
```

**What to keep**:
- Current active features (any status except COMPLETE)
- Recently completed features (< 30 days)
- Feature templates and documentation

**What to archive**:
- Completed features > 30 days old
- Their checkpoints and progress files
- Related workflow artifacts

---

## Troubleshooting Scenarios

### Example 5: Workflow Stuck in Clarify Loop

**Scenario**: Running `clarify phase` repeatedly finds new issues; clarification never completes.

**Symptoms**:
```bash
# Run 1
/spec clarify
# Output: Found 12 clarification points

# Run 2 (after addressing points)
/spec clarify
# Output: Found 8 clarification points

# Run 3
/spec clarify
# Output: Found 11 clarification points (some new!)
```

**Why this happens**:
- Ambiguous requirements leading to over-clarification
- LLM generating different edge cases each run
- Overly strict validation rules

**Breaking the loop**:

```bash
# 1. Review clarification history
grep "CLARIFICATION" docs/spec/feature-name.spec.md -A 5

# 2. Identify recurring themes
/spec workflow:analyze-clarifications

# 3. Set clarification threshold
/spec clarify --max-iterations=3 --threshold=high

# 4. Or proceed with current state
/spec workflow:override-phase --force-complete-clarify
```

**Expected output**:
```
Clarification Analysis:

Recurring themes:
- Error handling (appeared in 3/3 runs)
- Edge cases for null inputs (appeared in 3/3 runs)
- Performance requirements (appeared in 2/3 runs)
- Internationalization (new each run)

Recommendation:
- Address: Error handling, null inputs
- Defer: Internationalization (add to backlog)
- Accept threshold: HIGH priority issues only

Proceed? (y/n): y

Running clarify with threshold=high, max-iterations=3...
✓ Found 4 high-priority clarifications
✓ No critical blockers
✓ Clarification complete
```

**Manual override** (use sparingly):
```bash
# Document decision
echo "## Clarification Decision" >> docs/spec/feature-name.spec.md
echo "Proceeded with partial clarification due to diminishing returns." >> docs/spec/feature-name.spec.md
echo "Deferred items logged in backlog." >> docs/spec/feature-name.spec.md

# Force phase completion
/spec workflow:set-phase plan --override-validation
```

---

### Example 6: Task Implementation Fails Midway

**Scenario**: `implement phase` fails on task T007 of 15 due to dependency issue.

**Error output**:
```
Implementing tasks...
✓ T001: Create User model
✓ T002: Add password hashing
✓ T003: Create JWT utilities
✓ T004: Implement login endpoint
✓ T005: Implement logout endpoint
✓ T006: Add token refresh
✗ T007: Integrate with Redis for session storage
  Error: Redis client not available
  Cannot import 'redis' module

Remaining tasks: T008-T015
```

**Recovery steps**:

```bash
# 1. Check checkpoint was created
ls -la .workflow-checkpoints/
# Output: checkpoint-before-T007.json

# 2. Install missing dependency
npm install redis
# or add to requirements and reinstall

# 3. Verify dependency available
node -e "require('redis')" && echo "Redis OK"

# 4. Resume from failed task
/spec implement --resume-from=T007

# Or skip problematic task temporarily
/spec implement --skip=T007 --continue
```

**Expected output**:
```
Resuming from task T007...
✓ T007: Integrate with Redis for session storage
✓ T008: Add session cleanup job
✓ T009: Implement rate limiting
...
✓ T015: Add integration tests

Implementation complete: 15/15 tasks
```

**Skipping tasks**:
```bash
# Skip and mark for later
/spec implement --skip=T007 --add-to-backlog

# This creates:
echo "- [ ] T007: Integrate with Redis (DEFERRED - dependency issue)" \
  >> WORKFLOW-PROGRESS.md
```

**Reviewing skipped tasks**:
```bash
# List deferred tasks
grep "DEFERRED" WORKFLOW-PROGRESS.md

# Re-attempt after fixing
/spec implement --only=T007
```

---

### Example 7: Integration Sync Conflict

**Scenario**: Local spec.md updated, but JIRA was also updated externally by team member.

**Detecting conflict**:
```bash
# Sync with JIRA
/spec integrate jira sync

# Output:
Conflict detected:

Local changes:
- Acceptance Criteria updated
- 2 new tasks added (T011, T012)
- Last modified: 2 hours ago

Remote changes (JIRA):
- Description updated by john@company.com
- 1 task marked complete (T008)
- 3 comments added
- Last modified: 30 minutes ago

Cannot auto-merge. Manual resolution required.
```

**Manual merge process**:

```bash
# 1. Export both versions
/spec integrate jira export --output=jira-version.md
cp docs/spec/feature-name.spec.md local-version.md

# 2. Use diff tool
diff -u local-version.md jira-version.md > changes.diff
# Or use visual diff
code --diff local-version.md jira-version.md

# 3. Identify non-conflicting changes
grep "^+" changes.diff | grep -v "^+++"
```

**Manual merge**:
```markdown
<!-- Merged version -->
# Feature: User Authentication API

## Description
<!-- Take JIRA version (more recent, from team member) -->
Enhanced user authentication with OAuth2 support and MFA.
Updated to include enterprise SSO requirements.

## Tasks
- [x] T001: Create User model
- [x] T002: Add password hashing
...
- [x] T008: Add session cleanup (marked complete in JIRA)
...
- [ ] T011: Add OAuth2 flow (new from local)
- [ ] T012: Implement MFA (new from local)

## Comments
<!-- Preserve JIRA comments -->
- john@company.com: "Need to verify SSO provider compatibility"
- jane@company.com: "Security review required before deploy"
```

**Re-sync after resolution**:
```bash
# Update local with merged version
cp merged-version.md docs/spec/feature-name.spec.md

# Push merged version to JIRA
/spec integrate jira push --force-update

# Verify sync
/spec integrate jira status
# Output: ✓ In sync (last synced: just now)
```

---

### Example 8: Multi-Feature Workflow

**Scenario**: Working on 3 features simultaneously (feature-A, feature-B, feature-C).

**Setup**:
```bash
# Create feature branches
git checkout -b feature/user-auth
/spec init --feature="User Authentication API"

git checkout -b feature/payment-integration
/spec init --feature="Payment Integration"

git checkout -b feature/notification-system
/spec init --feature="Notification System"
```

**State isolation strategy**:

```bash
# Use separate session files per feature
# In .gitignore:
echo ".workflow-session-*.json" >> .gitignore

# Switching to feature-A
git checkout feature/user-auth
/spec workflow:load --session=user-auth

# Switching to feature-B
git checkout feature/payment-integration
/spec workflow:load --session=payment-integration
```

**Managing multiple features**:
```bash
# View all active features
/spec workflow:list-all

# Output:
Active Features:
1. User Authentication API
   Branch: feature/user-auth
   Phase: IMPLEMENTING
   Progress: 65%
   Last active: 2 hours ago

2. Payment Integration
   Branch: feature/payment-integration
   Phase: PLANNING
   Progress: 30%
   Last active: 1 day ago

3. Notification System
   Branch: feature/notification-system
   Phase: CLARIFYING
   Progress: 15%
   Last active: 3 hours ago
```

**Quick context switching**:
```bash
# Save current context
/spec workflow:checkpoint "Switching to payment work"

# Switch feature
/spec workflow:switch payment-integration

# Auto-loads:
# - Correct git branch
# - Feature-specific session
# - ACTIVE-CONTEXT for that feature
```

**Daily workflow**:
```bash
# Morning: Review all features
/spec workflow:daily-standup

# Output:
Daily Workflow Summary:

User Authentication (feature/user-auth):
  Yesterday: Completed T007-T009 (login/logout)
  Today: Implement T010-T012 (token refresh)
  Blockers: None

Payment Integration (feature/payment-integration):
  Yesterday: Spec clarification
  Today: Begin task planning
  Blockers: Waiting on Stripe API keys

Notification System (feature/notification-system):
  Yesterday: No activity
  Today: Continue clarification
  Blockers: Need UX mockups
```

---

## Advanced Workflow Patterns

### Example 9: Custom Template Workflow

**Scenario**: Team needs custom spec format with additional sections (Security, Compliance, Performance).

**Creating custom template**:

```bash
# 1. Copy base template
cp /plugins/spec/.claude/skills/workflow/templates/SPEC-TEMPLATE.md \
   team-templates/custom-spec-template.md

# 2. Edit to add sections
cat >> team-templates/custom-spec-template.md <<'EOF'

## Security Requirements
### Authentication
[Authentication approach]

### Authorization
[Authorization model]

### Data Protection
[Encryption, PII handling]

## Compliance Requirements
### Regulations
- [ ] GDPR compliant
- [ ] SOC2 requirements met
- [ ] HIPAA considerations

### Audit Trail
[Logging and audit requirements]

## Performance Requirements
### Latency
- API response time: [target]
- Database query time: [target]

### Throughput
- Requests per second: [target]
- Concurrent users: [target]

### Scalability
[Scaling strategy]
EOF
```

**Testing with validation**:
```bash
# Create validation schema
cat > team-templates/custom-schema.json <<EOF
{
  "requiredSections": [
    "Overview",
    "Tasks",
    "Acceptance Criteria",
    "Security Requirements",
    "Compliance Requirements",
    "Performance Requirements"
  ],
  "requiredFields": {
    "Security Requirements": ["Authentication", "Authorization", "Data Protection"],
    "Compliance Requirements": ["Regulations", "Audit Trail"],
    "Performance Requirements": ["Latency", "Throughput", "Scalability"]
  }
}
EOF

# Test template
/spec init --template=team-templates/custom-spec-template.md \
           --validate-schema=team-templates/custom-schema.json
```

**Rolling out to team**:
```bash
# Add to team config
cat > .claude/settings.json <<EOF
{
  "spec": {
    "defaultTemplate": "team-templates/custom-spec-template.md",
    "validationSchema": "team-templates/custom-schema.json",
    "requiredReviewers": ["security-team", "compliance-team"]
  }
}
EOF

# Commit team templates
git add team-templates/ .claude/settings.json
git commit -m "feat: add custom spec template for team"
git push

# Document usage
cat > team-templates/README.md <<EOF
# Team Spec Templates

## Usage
All new features must use the custom template:
\`\`\`bash
/spec init --template=team-templates/custom-spec-template.md
\`\`\`

## Required Sections
- Security Requirements (reviewed by @security-team)
- Compliance Requirements (reviewed by @compliance-team)
- Performance Requirements

## Validation
Template compliance checked on PR creation.
EOF
```

---

### Example 10: Brownfield Discovery & Planning

**Scenario**: Large existing codebase (500+ files); need to add spec workflow to new features.

**Discovery process**:

```bash
# 1. Analyze existing codebase structure
/spec discover --analyze-codebase

# Output:
Codebase Analysis:

Structure:
- 547 source files
- 12 main modules
- 89 API endpoints
- 234 database models

Patterns detected:
- Framework: Express.js
- Database: PostgreSQL
- Auth: JWT-based
- Testing: Jest + Supertest

Recommendation:
- Create specs for new features only
- Gradually retrofit existing features
- Start with high-change modules
```

**Incremental adoption**:

```bash
# 2. Identify high-change modules
git log --since="3 months ago" --name-only --pretty=format: | \
  sort | uniq -c | sort -rn | head -20

# Output:
42 src/api/users.ts
38 src/api/orders.ts
35 src/services/payment.ts
...

# 3. Create specs for active modules first
/spec init --feature="Users API Refactor" \
           --brownfield \
           --existing-code=src/api/users.ts

# This triggers discovery mode:
Analyzing existing code: src/api/users.ts

Found:
- 12 existing endpoints
- 5 database models referenced
- 3 external integrations
- 89% test coverage

Generate spec from existing code? (y/n): y
```

**Generated spec**:
```markdown
# Feature: Users API Refactor

## Overview
Refactor existing Users API to improve maintainability and add new features.

## Existing Implementation
### Current Endpoints
- GET /api/users (list users)
- GET /api/users/:id (get user)
- POST /api/users (create user)
...

### Current Tests
- ✓ 89% coverage
- Tests location: tests/api/users.test.ts

## Proposed Changes
### New Features
- [ ] Add user search with filters
- [ ] Implement pagination
- [ ] Add user roles management

### Refactoring
- [ ] Extract validation to middleware
- [ ] Standardize error responses
- [ ] Add request logging

## Migration Strategy
- Phase 1: Add new endpoints (no breaking changes)
- Phase 2: Deprecate old endpoints
- Phase 3: Remove deprecated endpoints (v2.0)
```

**Rollout strategy**:
```bash
# Document brownfield approach
cat > docs/SPEC-WORKFLOW-ADOPTION.md <<EOF
# Spec Workflow Adoption Plan

## Phase 1: New Features Only (Months 1-2)
- All new features require spec
- Existing features unchanged
- Team training and onboarding

## Phase 2: High-Change Modules (Months 3-4)
- Create specs for actively developed modules
- Retrofit tests to match specs
- Update documentation

## Phase 3: Critical Modules (Months 5-6)
- Spec critical business logic
- Add missing tests
- Improve coverage

## Phase 4: Full Adoption (Months 7+)
- All changes require spec
- Continuous improvement
- Regular spec reviews
EOF

# Create tracking
cat > docs/SPEC-ADOPTION-PROGRESS.md <<EOF
# Spec Adoption Progress

## New Features (100% spec coverage required)
- [x] User search and filtering
- [x] Notification preferences
- [ ] Advanced reporting (in progress)

## Retrofitted Modules
- [x] Users API (12/12 endpoints documented)
- [ ] Orders API (5/18 endpoints documented)
- [ ] Payments (not started)

## Metrics
- Spec coverage: 35%
- Target: 80% by end of quarter
- Velocity: +5% per sprint
EOF
```

---

## Related Documentation

- [error-recovery.md](./error-recovery.md) - Error handling and recovery
- [workflow-review.md](./workflow-review.md) - Core workflow documentation
- [README.md](./README.md) - Command reference
- [integration-errors.md](./integration-errors.md) - Integration guide

---

**Last Updated**: 2025-11-02
**Maintained By**: Spec Workflow Team
