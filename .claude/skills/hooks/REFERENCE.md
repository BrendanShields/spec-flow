# Claude Code Hooks: Complete Reference

## Hook Event Types

| Event | When It Fires | Can Block? | Common Uses |
|-------|---------------|------------|-------------|
| `PreToolUse` | Before tool execution | ✅ Yes (exit 2) | Validation, security checks, approval gates |
| `PostToolUse` | After successful tool completion | ❌ No | Formatters, linters, notifications |
| `UserPromptSubmit` | User submits prompt | ✅ Yes (exit 2) | Add context, validate input, block unsafe prompts |
| `Notification` | Claude needs permission/waiting | ❌ No | Custom notification handling |
| `Stop` | Main agent finishes responding | ⚠️ Special | Add instructions, prevent stopping |
| `SubagentStop` | Subagent task completes | ⚠️ Special | Control subagent behavior, logging |
| `SessionStart` | Session begins/resumes | ❌ No | Setup environment, load context, install deps |
| `SessionEnd` | Session ends | ❌ No | Cleanup, logging, state persistence |
| `PreCompact` | Before context compaction | ❌ No | Custom actions during compaction |

## Configuration Structure

### Basic Pattern

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",  // Only for PreToolUse/PostToolUse
        "hooks": [
          {
            "type": "command",
            "command": "shell-command-here",
            "timeout": 60  // Optional, default 60 seconds
          }
        ]
      }
    ]
  }
}
```

### Matcher Patterns

**Simple string** (exact match, case-sensitive):
```json
"matcher": "Bash"
```

**Pipe-separated** (OR logic):
```json
"matcher": "Edit|Write"
```

**Regex patterns**:
```json
"matcher": "Notebook.*"  // NotebookEdit, NotebookExecute, etc.
```

**Wildcard** (all tools):
```json
"matcher": "*"
```

**MCP tools**:
```json
"matcher": "mcp__.*__.*"  // All MCP tools
"matcher": "mcp__memory__create_entities"  // Specific MCP tool
```

### Input JSON Structure

Hooks receive JSON via stdin with these fields:

**Common fields** (all events):
- `session_id` - Unique session identifier
- `transcript_path` - Path to conversation transcript
- `cwd` - Current working directory
- `hook_event_name` - Event type

**Tool events** (PreToolUse, PostToolUse):
- `tool_name` - Name of the tool
- `tool_input` - Tool parameters (object)
- `tool_response` - Tool output (PostToolUse only)

**Example**:
```json
{
  "session_id": "abc123",
  "cwd": "/Users/dev/project",
  "hook_event_name": "PreToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/Users/dev/project/src/app.js",
    "old_string": "const x = 1",
    "new_string": "const x = 2"
  }
}
```

### Output Control

#### Exit Codes

- **0** - Success
  - `UserPromptSubmit`/`SessionStart`: stdout becomes context (injected into conversation)
  - Other events: stdout shown to user in transcript mode

- **2** - Blocking error (PreToolUse, UserPromptSubmit only)
  - Prevents tool execution
  - stderr fed to Claude for processing

- **Other** - Non-blocking error
  - stderr shown to user
  - Execution continues

#### JSON Output Format

Return structured JSON for advanced control:

```json
{
  "continue": true,
  "stopReason": "optional message",
  "suppressOutput": false,
  "systemMessage": "optional warning",
  "decision": "allow|deny|ask|block|approve",
  "reason": "explanation",
  "hookSpecificOutput": {
    "hookEventName": "EventName",
    "additionalContext": "context to inject",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "reason"
  }
}
```

**Example** (block with reason):
```bash
echo '{
  "decision": "deny",
  "reason": "File contains sensitive data",
  "systemMessage": "⚠️ Access to .env files is restricted"
}'
exit 2
```

## Security Best Practices

### ✅ DO

1. **Always quote variables**:
   ```bash
   FILE="$1"
   cat "$FILE"  # ✅ Correct
   ```

2. **Validate input**:
   ```bash
   FILE=$(jq -r '.tool_input.file_path')
   if [[ "$FILE" == *".."* ]]; then
     echo "Path traversal blocked" >&2
     exit 2
   fi
   ```

3. **Use absolute paths**:
   ```bash
   "${CLAUDE_PROJECT_DIR}/scripts/validate.sh"  # ✅ Portable
   ```

4. **Sanitize before execution**:
   ```bash
   # Extract and validate
   COMMAND=$(jq -r '.tool_input.command')
   if [[ "$COMMAND" =~ ^git\ commit ]]; then
     # Safe to proceed
   fi
   ```

5. **Fail gracefully**:
   ```bash
   prettier --write "$FILE" 2>/dev/null || true
   ```

### ❌ DON'T

1. **Never use unquoted variables**:
   ```bash
   cat $FILE  # ❌ Vulnerable to injection
   ```

2. **Don't blindly execute user input**:
   ```bash
   eval "$USER_INPUT"  # ❌ EXTREMELY DANGEROUS
   ```

3. **Don't expose sensitive files**:
   ```bash
   # ❌ Bad - no filtering
   cat .env

   # ✅ Good - block sensitive files
   [[ "$FILE" =~ \.(env|secret)$ ]] && exit 2
   ```

4. **Don't ignore path traversal**:
   ```bash
   # ❌ Bad - allows ../../../etc/passwd
   cat "$FILE"

   # ✅ Good - validate first
   [[ "$FILE" =~ \.\. ]] && exit 2
   ```

## Hook Pattern Library

### Pattern: Format on Save

```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "FILE=$(jq -r '.tool_input.file_path'); case \"$FILE\" in *.js|*.jsx|*.ts|*.tsx) npx prettier --write \"$FILE\" 2>/dev/null || true ;; *.py) black \"$FILE\" 2>/dev/null || true ;; esac"
        }
      ]
    }
  ]
}
```

### Pattern: Validate Before Commit

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "COMMAND=$(jq -r '.tool_input.command'); if echo \"$COMMAND\" | grep -q 'git commit'; then npm run lint && npm test || exit 2; fi",
          "timeout": 120
        }
      ]
    }
  ]
}
```

### Pattern: Add Context Automatically

```json
{
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo \"Additional context: Project uses React 18.x, TypeScript 5.x, Node 20.x\""
        }
      ]
    }
  ]
}
```

### Pattern: Approve Destructive Operations

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "COMMAND=$(jq -r '.tool_input.command'); if echo \"$COMMAND\" | grep -qE 'rm -rf|git push.*--force|DROP TABLE'; then echo '{\"decision\": \"ask\", \"reason\": \"Destructive operation requires approval\"}'; exit 2; fi"
        }
      ]
    }
  ]
}
```

### Pattern: Session Initialization

```json
{
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "[ -f package.json ] && npm ci --silent || true; [ -f .env.example ] && [ ! -f .env ] && cp .env.example .env || true",
          "timeout": 300
        }
      ]
    }
  ]
}
```

### Pattern: Cleanup on Exit

```json
{
  "SessionEnd": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "rm -f /tmp/claude-session-* 2>/dev/null; git stash -u -m 'Claude session auto-stash' 2>/dev/null || true"
        }
      ]
    }
  ]
}
```

## Environment Variables

Available in hook commands:

- `CLAUDE_PROJECT_DIR` - Absolute path to project root
- `CLAUDE_ENV_FILE` - File path for persisting env vars (SessionStart only)
- `CLAUDE_CODE_REMOTE` - Indicates web vs. local execution

**Example usage**:
```bash
cd "$CLAUDE_PROJECT_DIR" && npm test
```

## Troubleshooting

### Hook Not Firing

1. **Check matcher pattern** (case-sensitive):
   ```bash
   claude --debug  # See which hooks are checked
   ```

2. **Verify JSON syntax**:
   ```bash
   jq . .claude/settings.json  # Should parse without error
   ```

3. **Check hook location**:
   - Project: `.claude/settings.json` (highest priority)
   - User: `~/.claude/settings.json` (lower priority)
   - Plugin: `plugins/*/hooks/hooks.json` (auto-merged)

### Hook Fails Silently

1. **Add debugging**:
   ```bash
   "command": "echo 'Hook fired!' >&2; your-actual-command"
   ```

2. **Check timeout**:
   ```json
   {
     "type": "command",
     "command": "slow-operation",
     "timeout": 300  // Increase if needed
   }
   ```

3. **Test command standalone**:
   ```bash
   echo '{"tool_name":"Edit","tool_input":{"file_path":"test.js"}}' | your-hook-command
   ```

### Permission Denied

```bash
# Make script executable
chmod +x "${CLAUDE_PROJECT_DIR}/scripts/hook.sh"
```

### JSON Parsing Errors

```bash
# Test jq extraction
echo '{"tool_input":{"file_path":"test.js"}}' | jq -r '.tool_input.file_path'
```

## Advanced Patterns

### Conditional Hook Based on File Type

```bash
FILE=$(jq -r '.tool_input.file_path')
case "$FILE" in
  *.ts|*.tsx)
    tsc --noEmit "$FILE" || exit 2
    ;;
  *.py)
    mypy "$FILE" || exit 2
    ;;
  *)
    exit 0
    ;;
esac
```

### Chain Multiple Checks

```bash
FILE=$(jq -r '.tool_input.file_path')

# Check 1: No sensitive files
[[ "$FILE" =~ \.(env|secret|key)$ ]] && exit 2

# Check 2: No path traversal
[[ "$FILE" =~ \.\. ]] && exit 2

# Check 3: Must be in project dir
[[ "$FILE" != "$CLAUDE_PROJECT_DIR"* ]] && exit 2

exit 0
```

### Inject Dynamic Context

```bash
#!/bin/bash
# Get recent git activity
GIT_STATUS=$(git status -s | head -5)
RECENT_COMMITS=$(git log --oneline -3)

# Build context
cat <<EOF
{
  "additionalContext": "Git status:\n${GIT_STATUS}\n\nRecent commits:\n${RECENT_COMMITS}"
}
EOF
```

### Approval with Timeout

```bash
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  # Show warning and wait for approval
  echo "⚠️ Destructive command detected: $COMMAND" >&2
  echo "Approve? (y/N): " >&2
  read -t 10 ANSWER || ANSWER="n"

  if [[ "$ANSWER" != "y" ]]; then
    echo '{"decision": "deny", "reason": "User denied approval"}'
    exit 2
  fi
fi

exit 0
```
