# Claude Code Hooks: Real-World Examples

## Example 1: Auto-Format on File Write

**Scenario**: Automatically run Prettier on any file written or edited.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // empty' | xargs -I {} npx prettier --write '{}' 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers after Edit/Write completes
- Extracts file path from JSON input
- Runs prettier on that file
- Fails gracefully if prettier not installed

---

## Example 2: Block Sensitive File Access

**Scenario**: Prevent Claude from reading `.env` or credentials files.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // empty' | grep -qE '\\.(env|secret|key)$|credentials' && echo '{\"decision\": \"deny\", \"reason\": \"Sensitive file blocked\"}' && exit 2 || exit 0"
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers BEFORE Read/Edit/Write executes
- Checks filename for sensitive patterns
- Exit code 2 blocks the tool execution
- Claude receives denial reason

---

## Example 3: Add Git Context to Every Prompt

**Scenario**: Automatically include git status and recent commits with every user prompt.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"additionalContext\": \"Current git status:\\n'$(git status -s | head -5)'\\n\\nRecent commits:\\n'$(git log --oneline -3)'\"}'"
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers on every user prompt submission
- Output becomes context (not shown to user)
- Claude automatically sees git state
- Helps with commit messages and debugging

---

## Example 4: Session Setup - Load Environment

**Scenario**: Automatically load project dependencies and environment when session starts.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "[ -f package.json ] && npm ci --silent 2>&1 | tail -5 || true",
            "timeout": 300
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers once when session starts
- Installs dependencies if package.json exists
- 5-minute timeout for large installs
- Output shown to user as confirmation

---

## Example 5: Code Quality Gate

**Scenario**: Run linter + tests before allowing commits.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command // empty' | grep -q '^git commit' && (npm run lint && npm test) || exit 0",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers before Bash commands
- Detects git commit commands
- Runs lint + tests before allowing commit
- Blocks commit if checks fail

---

## Example 6: Notification on Completion

**Scenario**: Send desktop notification when Claude finishes a long response.

**Configuration** (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude has finished\" with title \"Claude Code\"' 2>/dev/null || notify-send 'Claude Code' 'Claude has finished' 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers when Claude stops responding
- Uses macOS notification (osascript) or Linux (notify-send)
- Fails gracefully if neither available

---

## Example 7: Subagent Task Logger

**Scenario**: Log all subagent invocations to a file for audit trail.

**Configuration** (`.claude/settings.json`):
```json
{
  "hooks": {
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '\"[\" + (.timestamp // now | todate) + \"] Subagent completed: \" + (.tool_input.description // \"unknown\")' >> .claude/subagent-log.txt"
          }
        ]
      }
    ]
  }
}
```

**Why it works**:
- Triggers after each subagent completes
- Extracts description and timestamp
- Appends to log file for tracking

---

## Example 8: Plugin Integration - Security Scan

**Scenario**: Use a plugin hook to scan code changes for security issues.

**Plugin hook** (`plugins/security-scanner/hooks/hooks.json`):
```json
{
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/security-scan.sh"
        }
      ]
    }
  ]
}
```

**Script** (`plugins/security-scanner/scripts/security-scan.sh`):
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ]; then
  semgrep --config auto "$FILE" --quiet 2>&1 | head -10 || true
fi
```

**Why it works**:
- Plugin provides hook automatically
- Uses `${CLAUDE_PLUGIN_ROOT}` for portability
- Runs security scanner on changed files
- Reports issues without blocking
