# Custom Hooks API

**Version**: 3.1.0
**Last Updated**: 2024-10-31

---

## Overview

Create custom hooks to extend Spec's automation for your specific workflow needs.

## Quick Start

### 1. Create Hook Script

```bash
touch .spec/hooks/custom/my-hook.sh
chmod +x .spec/hooks/custom/my-hook.sh
```

### 2. Implement Hook

```bash
#!/bin/bash
# Custom Hook Example

set -euo pipefail

# Read context from stdin (JSON)
context=$(cat)

# Extract information
command=$(echo "$context" | jq -r '.command // "unknown"')
feature_id=$(echo "$context" | jq -r '.activeFeature.id // ""')

# Your custom logic here
echo "Custom hook executed for command: $command"

exit 0
```

### 3. Register Hook

Edit `.spec/hooks/config.json`:

```json
{
  "hooks": {
    "post-command": {
      "scripts": [
        "core/post-command.sh",
        "custom/my-hook.sh"
      ]
    }
  }
}
```

### 4. Test Hook

```bash
source .spec/lib/hook-runner.sh
context='{"command":"test","activeFeature":{"id":"002"}}'
spec_run_hooks post-command "$context"
```

## Hook Context

Hooks receive JSON context via stdin:

```json
{
  "command": "plan",
  "event": "post-command",
  "timestamp": "2024-10-31T10:30:00Z",
  "activeFeature": {
    "id": "002",
    "name": "feature-name",
    "phase": "planning",
    "progress": 25
  },
  "taskId": "T001",
  "featureId": "002"
}
```

### Context Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Spec command executed |
| `event` | string | Hook event name |
| `timestamp` | ISO8601 | When event occurred |
| `activeFeature` | object | Current feature info |
| `taskId` | string | Task ID (on-task-complete only) |
| `featureId` | string | Feature ID |

## Environment Variables

Hooks have access to:

```bash
SPEC_ROOT="/path/to/project"
SPEC_EVENT="post-command"
SPEC_FEATURE="002"
PATH="/usr/bin:/bin"  # Sandboxed
```

## Examples

### Example 1: Slack Notification

```bash
#!/bin/bash
# .spec/hooks/custom/slack-notify.sh

set -euo pipefail

context=$(cat)
status=$(echo "$context" | jq -r '.activeFeature.status // ""')

if [[ "$status" == "complete" ]]; then
  feature_id=$(echo "$context" | jq -r '.activeFeature.id')
  feature_name=$(echo "$context" | jq -r '.activeFeature.name')

  curl -X POST "${SLACK_WEBHOOK_URL}" \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"✅ Feature $feature_id ($feature_name) complete!\"}"

  echo "Slack notification sent"
fi

exit 0
```

### Example 2: Jira Update

```bash
#!/bin/bash
# .spec/hooks/custom/jira-update.sh

set -euo pipefail

context=$(cat)
task_id=$(echo "$context" | jq -r '.taskId // ""')

if [[ -n "$task_id" ]]; then
  # Get task description
  task_desc=$(jq -r ".taskList[] | select(.id == \"$task_id\") | .description" \
    .spec-state/session.json 2>/dev/null || echo "")

  # Update Jira (example)
  curl -X PUT "https://jira.example.com/rest/api/2/issue/${JIRA_ISSUE_KEY}" \
    -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
    -H 'Content-Type: application/json' \
    -d "{\"fields\":{\"customfield_10001\":\"$task_desc\"}}"

  echo "Jira updated for task $task_id"
fi

exit 0
```

### Example 3: Custom Metrics

```bash
#!/bin/bash
# .spec/hooks/custom/metrics-collector.sh

set -euo pipefail

context=$(cat)
command=$(echo "$context" | jq -r '.command')
timestamp=$(date +%s)

# Log to custom metrics file
echo "$timestamp,$command,1" >> .spec/logs/custom-metrics.csv

echo "Metrics logged"
exit 0
```

### Example 4: Email Notification

```bash
#!/bin/bash
# .spec/hooks/custom/email-notify.sh

set -euo pipefail

context=$(cat)
phase=$(echo "$context" | jq -r '.activeFeature.phase // ""')

if [[ "$phase" == "complete" ]]; then
  feature_name=$(echo "$context" | jq -r '.activeFeature.name')

  echo "Feature $feature_name completed!" | \
    mail -s "Spec: Feature Complete" "${TEAM_EMAIL}"

  echo "Email sent"
fi

exit 0
```

### Example 5: Git Auto-Commit

```bash
#!/bin/bash
# .spec/hooks/custom/auto-commit.sh

set -euo pipefail

context=$(cat)
task_id=$(echo "$context" | jq -r '.taskId // ""')

if [[ -n "$task_id" ]]; then
  task_desc=$(jq -r ".taskList[] | select(.id == \"$task_id\") | .description" \
    .spec-state/session.json 2>/dev/null || echo "Task complete")

  # Auto-commit if AUTO_COMMIT enabled
  if [[ "${AUTO_COMMIT:-false}" == "true" ]]; then
    git add .
    git commit -m "feat: $task_desc [$task_id]" || true
    echo "Auto-committed $task_id"
  fi
fi

exit 0
```

## Best Practices

### 1. Error Handling

Always handle errors gracefully:

```bash
#!/bin/bash
set -euo pipefail

context=$(cat)

# Validate context
if ! echo "$context" | jq empty 2>/dev/null; then
  echo "Invalid JSON context" >&2
  exit 1
fi

# Your logic with error handling
if ! some_command; then
  echo "Command failed, continuing anyway" >&2
  exit 0  # Non-blocking failure
fi
```

### 2. Performance

Keep hooks fast:

```bash
# Good: Fast operation
echo "Quick message"

# Bad: Slow operation without timeout
sleep 10  # Don't do this!
```

### 3. Logging

Log to custom file, not stdout:

```bash
LOG_FILE=".spec/logs/my-hook.log"
echo "[$(date -Iseconds)] Hook executed" >> "$LOG_FILE"
```

### 4. Configuration

Use environment variables for configuration:

```bash
WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "SLACK_WEBHOOK_URL not set" >&2
  exit 0
fi
```

### 5. Testing

Test hooks before deployment:

```bash
# Test with sample context
echo '{"command":"test","activeFeature":{"id":"002"}}' | \
  bash .spec/hooks/custom/my-hook.sh
```

## Hook API Reference

### Reading Context

```bash
# Read full context
context=$(cat)

# Extract specific fields
command=$(echo "$context" | jq -r '.command')
feature_id=$(echo "$context" | jq -r '.activeFeature.id // ""')
phase=$(echo "$context" | jq -r '.activeFeature.phase // ""')
```

### Accessing State Files

```bash
# Read session state
session_file="$SPEC_ROOT/.spec-state/session.json"
current_phase=$(jq -r '.activeFeature.phase' "$session_file")

# Read workflow metrics
workflow_file="$SPEC_ROOT/.spec-memory/workflow.json"
completed_tasks=$(jq -r '.metrics.totalTasksCompleted' "$workflow_file")
```

### Updating State

**Important**: Use `spec_update_state` for atomic updates:

```bash
source "$SPEC_ROOT/.spec/lib/state-sync.sh"

# Update session
spec_update_state .spec-state/session.json \
  '.customField = "value"'
```

### Calling External APIs

```bash
# POST request
curl -X POST "https://api.example.com/notify" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -d '{"message":"Hook executed"}'

# GET request
response=$(curl -s "https://api.example.com/data")
```

## Security Considerations

### Sandboxing

Hooks run in a restricted environment:

- Limited PATH (`/usr/bin:/bin`)
- No network access by default (add if needed)
- Limited environment variables

### Secrets Management

Never hardcode secrets:

```bash
# Bad
API_TOKEN="secret123"

# Good
API_TOKEN="${JIRA_API_TOKEN:?JIRA_API_TOKEN not set}"
```

### Input Validation

Always validate context:

```bash
context=$(cat)

# Validate JSON
if ! echo "$context" | jq empty 2>/dev/null; then
  echo "Invalid context" >&2
  exit 1
fi

# Validate required fields
if ! echo "$context" | jq -e '.command' >/dev/null; then
  echo "Missing required field: command" >&2
  exit 1
fi
```

## Troubleshooting

### Hook Not Running

1. Check registration in `config.json`
2. Verify file is executable: `chmod +x hook.sh`
3. Check hook logs: `cat .spec/logs/hooks.log`

### Hook Failing

1. Run manually with test context
2. Check exit code
3. Add debug logging
4. Verify dependencies available

### Hook Timeout

1. Increase timeout in `config.json`
2. Optimize hook performance
3. Move slow operations to background

## Advanced Patterns

### Conditional Execution

```bash
context=$(cat)
phase=$(echo "$context" | jq -r '.activeFeature.phase')

# Only run in specific phase
if [[ "$phase" != "complete" ]]; then
  exit 0
fi

# Your logic here
```

### Multiple Event Support

```bash
event="${SPEC_EVENT:-unknown}"

case "$event" in
  post-command)
    echo "After command"
    ;;
  on-task-complete)
    echo "Task complete"
    ;;
  *)
    echo "Unknown event: $event"
    ;;
esac
```

### State Machine

```bash
context=$(cat)
current_state=$(jq -r '.customState // "init"' .spec-state/session.json)

case "$current_state" in
  init)
    # Transition to next state
    spec_update_state .spec-state/session.json '.customState = "processing"'
    ;;
  processing)
    # Continue processing
    ;;
esac
```

## Testing Custom Hooks

### Unit Testing

```bash
#!/bin/bash
# test-my-hook.sh

echo "Testing my-hook.sh..."

# Test case 1: Valid context
test_context='{"command":"test","activeFeature":{"id":"002"}}'
if echo "$test_context" | bash .spec/hooks/custom/my-hook.sh; then
  echo "✅ Test 1 passed"
else
  echo "❌ Test 1 failed"
  exit 1
fi

# Test case 2: Invalid context
test_context='invalid json'
if ! echo "$test_context" | bash .spec/hooks/custom/my-hook.sh 2>/dev/null; then
  echo "✅ Test 2 passed (error handling works)"
else
  echo "❌ Test 2 failed (should have errored)"
  exit 1
fi

echo "All tests passed!"
```

## FAQ

**Q: Can hooks modify state files?**
A: Yes, use `spec_update_state` for atomic updates.

**Q: How do I debug hooks?**
A: Add `set -x` at the top, check `.spec/logs/hooks.log`.

**Q: Can I use external commands?**
A: Yes, but PATH is limited. Specify full paths if needed.

**Q: What's the execution order?**
A: Hooks run in the order listed in `config.json`.

**Q: Can hooks fail silently?**
A: Yes, unless `blocking: true` is set.

## See Also

- [HOOKS-USER-GUIDE.md](./HOOKS-USER-GUIDE.md) - Using built-in hooks
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - General troubleshooting

---

**Need help?** Create an issue on GitHub with your hook code and error logs.
