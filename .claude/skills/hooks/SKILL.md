---
name: hooks
description: Create and configure Claude Code hooks (shell commands that execute at lifecycle events). Use when: 1) User asks to create/add/configure a hook, 2) User mentions "hook", "PreToolUse", "PostToolUse", or event automation, 3) User wants to validate, format, or block tool executions, 4) User needs notifications or session lifecycle automation, 5) User wants to run commands before/after tool usage. Generates hook configurations with security best practices. (project)
---

# Claude Code Hooks Skill

Create, configure, and manage Claude Code hooks - shell commands that execute automatically at specific lifecycle events.

## Core Concepts

**Hooks** provide deterministic control over Claude Code behavior by executing shell commands at specific trigger points (before/after tool use, on user prompts, session start/end, etc.).

**9 Event Types Available**:
- `PreToolUse` - Before tool execution (can block)
- `PostToolUse` - After successful tool completion
- `UserPromptSubmit` - When user submits prompts
- `Notification` - During notification dispatch
- `Stop` - When response finishes
- `SubagentStop` - When subagent completes
- `PreCompact` - Before context compaction
- `SessionStart` - Session begins/resumes
- `SessionEnd` - Session ends

## Workflow

### 1. Understand Requirements

Ask user:
```javascript
{
  "event": "PreToolUse|PostToolUse|UserPromptSubmit|...",
  "purpose": "format|validate|notify|block|log",
  "tools": ["Bash", "Edit", "Write", "*"],  // Which tools to match
  "scope": "project|user",  // .claude/settings.json or ~/.claude/settings.json
  "command": "shell command to execute"
}
```

### 2. Generate Hook Configuration

Read current settings:
```bash
# Project settings
cat .claude/settings.json 2>/dev/null || echo '{}'

# User settings
cat ~/.claude/settings.json 2>/dev/null || echo '{}'
```

Create hook structure using patterns from `REFERENCE.md`.

### 3. Security Validation

**CRITICAL**: Always validate security before writing hooks:
- ✓ Quote all variables: `"$VAR"`
- ✓ Use absolute paths for scripts
- ✓ Avoid sensitive files (`.env`, credentials)
- ✓ Block path traversal (`..` checks)
- ✓ Validate input data
- ✗ Never blindly execute user input

Refer to security checklist in `REFERENCE.md`.

### 4. Write Configuration

Update settings file with new hook:
```bash
# Backup first
cp .claude/settings.json .claude/settings.json.backup

# Update with new hook (use Edit or Write tool)
```

### 5. Test Hook

Provide test command:
```bash
# Test the hook activation
claude --debug  # Run this to see hook execution logs
```

## Common Hook Patterns

Load pattern library:
```bash
cat REFERENCE.md  # Hook patterns and configurations
cat EXAMPLES.md   # Real-world examples
```

**Quick patterns**:
1. **Format on write**: PostToolUse + Edit|Write → run prettier/eslint
2. **Validate before execution**: PreToolUse + Bash → security checks
3. **Add context on prompt**: UserPromptSubmit → inject project info
4. **Notify on completion**: Stop → send notification
5. **Setup environment**: SessionStart → load dependencies

## Output Format

After creating hook:
```
✅ Hook created: {event} for {tools}
📄 Location: {settings-path}
🔍 Matcher: {pattern}
⚙️  Command: {command}

🧪 Test with:
  {test-command}

⚠️  Security check: {passed|review-needed}
```

## Resources

- `EXAMPLES.md` - Real-world hook examples (formatters, validators, notifiers)
- `REFERENCE.md` - Complete hook patterns, security guide, troubleshooting
- `templates/` - Pre-built hook configurations
- `scripts/validate-hook.sh` - Hook syntax validator

## Remember

- Hooks execute with your environment credentials
- Exit code 2 blocks operations (PreToolUse only)
- Hooks receive JSON via stdin
- Always test hooks before committing
- Use `claude --debug` to see hook execution
