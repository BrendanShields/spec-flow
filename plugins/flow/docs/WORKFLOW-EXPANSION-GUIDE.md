# Workflow Expansion Guide

## 🎯 Extending Flow for Your Needs

This guide shows you how to customize and expand the Flow workflow system to match your team's specific needs.

## Table of Contents

- [Creating Custom Commands](#creating-custom-commands)
- [Adding New Skills](#adding-new-skills)
- [Custom Templates](#custom-templates)
- [Integration Hooks](#integration-hooks)
- [Workflow Automation](#workflow-automation)
- [Team-Specific Workflows](#team-specific-workflows)

---

## Creating Custom Commands

### Basic Slash Command

Create a new command file in `plugins/flow/.claude/commands/`:

```markdown
# my-command.md

Execute when user types `/my-command`:

1. Check prerequisites
2. Perform actions
3. Display results

## Example

```bash
/my-command
> Action performed successfully
```
```

### Command With Parameters

```markdown
# deploy.md

Execute when user types `/deploy [environment]`:

Parse environment from user input:
- `/deploy staging` → Deploy to staging
- `/deploy production` → Deploy to production
- `/deploy` → Ask which environment

## Actions

1. Validate current feature is complete
2. Run tests
3. Build application
4. Deploy to specified environment
5. Update deployment log

## Example

```bash
/deploy production
> Running tests...
> ✅ All tests passed
> Building application...
> ✅ Build successful
> Deploying to production...
> ✅ Deployed successfully
```
```

### Command That Invokes Skills

```markdown
# feature-complete.md

Execute when user types `/feature-complete`:

1. Check all tasks are complete
2. Run validation: /validate --strict
3. Run quality checks: flow:checklist
4. Generate report
5. Create pull request

This automates the completion workflow.
```

---

## Adding New Skills

### Skill Structure

Create a new skill in `plugins/flow/.claude/skills/my-skill/`:

```
my-skill/
├── SKILL.md          # Core instructions (keep under 100 lines)
├── EXAMPLES.md       # Usage examples
├── REFERENCE.md      # Detailed documentation
└── scripts/
    └── validate.sh   # Optional validation script
```

### SKILL.md Template

```markdown
# My Skill

## Purpose
{What this skill does in one sentence}

## When to Use
- {Situation 1}
- {Situation 2}

## How It Works

1. {Step 1}
2. {Step 2}
3. {Step 3}

## Integration

Updates these state files:
- `.flow-state/current-session.md`
- `.flow-memory/WORKFLOW-PROGRESS.md`

## Example

```bash
my-skill "parameter"
> Output description
```

See EXAMPLES.md for detailed usage.
```

### EXAMPLES.md Template

```markdown
# My Skill Examples

## Basic Usage

```bash
my-skill "simple case"
> Result for simple case
```

## Advanced Usage

```bash
my-skill "complex case" --option=value
> Result with options
```

## Common Patterns

### Pattern 1: {Name}
{Description}

```bash
my-skill "pattern example"
```

### Pattern 2: {Name}
{Description}

```bash
my-skill "another pattern" --flag
```
```

### State Integration

Update `.flow-state/current-session.md`:

```bash
# In your skill implementation

# Update session state
cat >> .flow-state/current-session.md << EOF

## My Skill Execution
Executed: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Parameters: {params}
Result: {result}
EOF
```

Update `.flow-memory/WORKFLOW-PROGRESS.md`:

```bash
# Log progress
echo "| my-skill | $(date +%Y-%m-%d) | {result} |" >> \
    .flow-memory/WORKFLOW-PROGRESS.md
```

---

## Custom Templates

### Creating Templates

Add templates to `.flow/templates/`:

```markdown
# .flow/templates/my-template.md

# {FEATURE_NAME}

## Custom Section 1
{PLACEHOLDER_1}

## Custom Section 2
{PLACEHOLDER_2}

## Generated
Date: {DATE}
Author: {AUTHOR}
```

### Using Templates in Skills

```bash
# In your skill

# Load template
TEMPLATE=$(cat .flow/templates/my-template.md)

# Replace placeholders
OUTPUT=$(echo "$TEMPLATE" |
    sed "s/{FEATURE_NAME}/$FEATURE_NAME/g" |
    sed "s/{PLACEHOLDER_1}/$VALUE_1/g" |
    sed "s/{DATE}/$(date)/g")

# Write to file
echo "$OUTPUT" > output.md
```

### Template Variables

Common variables to support:

```
{FEATURE_NAME}    - Name of the feature
{FEATURE_ID}      - Sequential ID (001, 002...)
{DATE}            - Current date
{TIMESTAMP}       - ISO timestamp
{AUTHOR}          - Git author
{PROJECT_NAME}    - Project name
{JIRA_KEY}        - JIRA project key
{PRIORITY}        - P1/P2/P3
```

---

## Integration Hooks

### Adding Git Hooks

Create `.flow/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit hook for Flow

# Validate workflow consistency
if command -v /validate &> /dev/null; then
    /validate --fix
    if [ $? -ne 0 ]; then
        echo "❌ Validation failed. Fix issues before committing."
        exit 1
    fi
fi

exit 0
```

### Adding Post-Skill Hooks

In `plugins/flow/.claude/hooks/hooks.json`:

```json
{
  "PostToolUse": {
    "pattern": "flow:implement",
    "action": "/session save --auto"
  }
}
```

This auto-saves after every implementation.

### Adding Workflow Triggers

```json
{
  "PostToolUse": {
    "pattern": "flow:tasks",
    "action": "/validate"
  }
}
```

Auto-validates after task generation.

---

## Workflow Automation

### Multi-Command Workflows

Create composite workflows in `.claude/commands/`:

```markdown
# full-feature-flow.md

Execute when user types `/full-feature-flow {description}`:

This automates the complete feature workflow:

1. Create specification
   ```
   flow:specify "{description}"
   ```

2. Validate specification
   ```
   /validate
   ```

3. Create technical plan
   ```
   flow:plan
   ```

4. Generate tasks
   ```
   flow:tasks
   ```

5. Final validation
   ```
   /validate --strict
   ```

6. Save checkpoint
   ```
   /session save --name="ready-to-implement"
   ```

7. Display next steps
   ```
   Next: Run /flow-implement to start building
   ```
```

### Conditional Workflows

```markdown
# smart-continue.md

Execute when user types `/smart-continue`:

1. Check current phase:
   - If no feature: Run /flow-specify
   - If spec only: Run /flow-plan
   - If plan exists: Run /flow-tasks
   - If tasks exist: Run /flow-implement --continue

2. Display status after action
   ```
   /status
   ```

Automatically runs the next appropriate command.
```

### Parallel Execution

```markdown
# parallel-setup.md

Execute when user types `/parallel-setup`:

For tasks marked with [P] (parallelizable):

1. Identify all [P] tasks in current phase
2. Ask user: "Run these 3 tasks in parallel?"
3. If yes, execute simultaneously
4. Track progress for each
5. Merge results
```

---

## Team-Specific Workflows

### Code Review Workflow

```markdown
# review-ready.md

Execute when user types `/review-ready`:

Prepares feature for code review:

1. Validate all tasks complete
   ```
   /validate --strict
   ```

2. Run quality checks
   ```
   flow:checklist --type=all
   ```

3. Generate PR description
   ```
   # Read spec.md, plan.md, tasks.md
   # Create PR template with:
   # - User stories implemented
   # - Technical approach
   # - Testing completed
   # - Screenshots (if UI)
   ```

4. Create pull request
   ```
   gh pr create --fill
   ```

5. Notify team
   ```
   # Post to Slack/Teams
   # Tag reviewers
   ```
```

### Deployment Workflow

```markdown
# deploy-feature.md

Execute when user types `/deploy-feature [env]`:

Deployment automation:

1. Pre-deployment checks
   - All tests passing?
   - No security issues?
   - Documentation updated?

2. Build application
   ```
   npm run build
   # or appropriate build command
   ```

3. Deploy to environment
   ```
   # Environment-specific deployment
   # staging, production, etc.
   ```

4. Post-deployment
   - Update deployment log
   - Run smoke tests
   - Notify stakeholders

5. Update feature status
   ```
   # Mark as deployed in tracking
   ```
```

### Sprint Planning Workflow

```markdown
# sprint-plan.md

Execute when user types `/sprint-plan`:

Sprint planning automation:

1. Review backlog
   ```
   cat .flow-memory/CHANGES-PLANNED.md
   ```

2. Estimate capacity
   ```
   # Based on historical velocity
   cat .flow-memory/WORKFLOW-PROGRESS.md
   ```

3. Select features for sprint
   ```
   # Prioritize P1 items
   # Fill capacity with P2/P3
   ```

4. Generate sprint tasks
   ```
   # Create tasks for selected features
   ```

5. Create sprint document
   ```
   # Sprint goals
   # Committed features
   # Team assignments
   ```
```

---

## Advanced Customizations

### Custom Priority System

Beyond P1/P2/P3, add custom priorities:

```markdown
# In your custom skill

## Priority System

- **P0** (Critical): Production issues, blockers
- **P1** (High): Must have for release
- **P2** (Medium): Should have
- **P3** (Low): Nice to have
- **P4** (Future): Backlog

Tasks marked P0 interrupt current work.
```

### Custom Phases

Add domain-specific phases:

```markdown
# In tasks.md template

## Phase 1: Data Layer
{Database, models, migrations}

## Phase 2: Business Logic
{Services, validation, rules}

## Phase 3: API Layer
{Controllers, routes, middleware}

## Phase 4: Frontend
{Components, pages, state}

## Phase 5: Integration
{End-to-end flows}

## Phase 6: Performance
{Optimization, caching}

## Phase 7: Security
{Auth, validation, sanitization}

## Phase 8: Testing
{Unit, integration, e2e}

## Phase 9: Documentation
{API docs, user guides}

## Phase 10: Deployment
{CI/CD, monitoring}
```

### Domain-Specific Templates

For mobile apps:

```markdown
# templates/mobile-spec.md

## User Stories

### Authentication Flows
- [ ] Login screen
- [ ] Registration
- [ ] Password reset
- [ ] Biometric auth

### Offline Capabilities
- [ ] Offline data sync
- [ ] Conflict resolution
- [ ] Cache management

### Platform Specifics
- [ ] iOS requirements
- [ ] Android requirements
- [ ] Platform parity
```

For data pipelines:

```markdown
# templates/pipeline-spec.md

## Data Flow

### Source
- Type: {DB/API/File}
- Format: {JSON/CSV/Parquet}
- Volume: {records/day}

### Transformations
- [ ] Data cleaning
- [ ] Validation
- [ ] Enrichment
- [ ] Aggregation

### Destination
- Type: {DB/Warehouse/Lake}
- Format: {format}
- Schedule: {frequency}
```

---

## Integration Examples

### Slack Integration

```markdown
# slack-notify.md

Execute when user types `/slack-notify {message}`:

Post workflow updates to Slack:

1. Get webhook URL from environment
2. Format message with workflow context
3. Post to channel

```bash
WEBHOOK_URL=$SLACK_WEBHOOK_URL

curl -X POST $WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d "{
    \"text\": \"Flow Update\",
    \"blocks\": [
      {
        \"type\": \"section\",
        \"text\": {
          \"type\": \"mrkdwn\",
          \"text\": \"*Feature*: $FEATURE_NAME\n*Status*: $STATUS\"
        }
      }
    ]
  }"
```
```

### Monitoring Integration

```markdown
# metrics-track.md

Execute when user types `/metrics-track`:

Send workflow metrics to monitoring:

1. Collect metrics
   - Tasks completed
   - Time taken
   - Error rate

2. Send to monitoring service
   ```bash
   # DataDog, New Relic, etc.
   ```

3. Update dashboard
```

---

## Best Practices

### Command Design
✅ Keep commands focused (one purpose)
✅ Provide clear feedback
✅ Handle errors gracefully
✅ Update state appropriately
✅ Document with examples

### Skill Design
✅ SKILL.md under 100 lines
✅ Defer details to REFERENCE.md
✅ Provide multiple examples
✅ Integration with state management
✅ Clear error messages

### Template Design
✅ Use clear placeholder names
✅ Provide defaults where possible
✅ Comment sections well
✅ Version your templates
✅ Test with real data

### Workflow Design
✅ Start simple, add complexity
✅ Make steps optional where appropriate
✅ Provide escape hatches
✅ Log decisions and changes
✅ Enable resumability

---

## Testing Your Extensions

### Test Checklist

```markdown
# test-my-extension.md

1. Test basic usage
   ```
   /my-command
   # Verify expected output
   ```

2. Test with parameters
   ```
   /my-command --param=value
   # Verify parameter handling
   ```

3. Test error cases
   ```
   /my-command invalid-input
   # Verify graceful error handling
   ```

4. Test state updates
   ```
   cat .flow-state/current-session.md
   # Verify state was updated
   ```

5. Test integration
   ```
   /my-command
   /status
   # Verify workflow integration
   ```
```

---

## Examples Gallery

### Example 1: Database Migration Command

```markdown
# db-migrate.md

Execute when user types `/db-migrate {action}`:

Actions:
- `create` - Create new migration
- `up` - Run pending migrations
- `down` - Rollback last migration
- `status` - Show migration status

```bash
case "$action" in
  create)
    # Generate migration file
    ;;
  up)
    # Run migrations
    ;;
  down)
    # Rollback
    ;;
  status)
    # Show status
    ;;
esac
```
```

### Example 2: Test Coverage Command

```markdown
# coverage-check.md

Execute when user types `/coverage-check`:

1. Run test suite with coverage
2. Generate coverage report
3. Check against threshold (80%)
4. Display results
5. Fail if below threshold

```bash
npm run test:coverage
COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
  echo "❌ Coverage $COVERAGE% below 80% threshold"
  exit 1
fi
```
```

### Example 3: API Documentation Generator

```markdown
# api-docs.md

Execute when user types `/api-docs`:

1. Scan code for API routes
2. Extract OpenAPI annotations
3. Generate OpenAPI spec
4. Generate HTML documentation
5. Deploy to docs site

```bash
# Scan routes
# Generate spec
# Build docs
# Deploy
```
```

---

## Contributing Your Extensions

### Share With Team

1. Document your extension
2. Add examples
3. Test thoroughly
4. Share in team repository

### Submit to Marketplace

1. Create plugin structure
2. Write comprehensive docs
3. Add examples and tests
4. Submit PR to marketplace

---

## Resources

- [USER-GUIDE.md](./USER-GUIDE.md) - Complete user guide
- [Skill Builder](./plugins/flow/.claude/skills/skill-builder/) - Tool for creating skills
- [Command Examples](./plugins/flow/.claude/commands/) - Existing commands
- [Integration Guide](./docs/SLASH-COMMANDS-INTEGRATION-GUIDE.md) - State integration

---

**Start extending Flow today!** Create your first custom command in `.claude/commands/`.