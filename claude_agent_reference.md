# Claude Agent Reference Manual

This manual provides a deep technical reference for building and managing Claude Agents. It covers configuration schemas, API details, and advanced usage patterns for Skills, Sub-agents, Slash Commands, Hooks, and Plugin Marketplaces.

---

## 1. Agent Skills

**Agent Skills** are modular, filesystem-based capabilities that extend Claude's functionality. They use a progressive disclosure architecture to load information only when needed.

### 1.1 Architecture & Loading Levels
Claude operates in a VM with filesystem access. Skills are directories loaded in three stages:
1.  **Level 1: Metadata (Always Loaded)**
    -   **Content**: `name` and `description` from `SKILL.md` frontmatter.
    -   **Cost**: Minimal (system prompt only).
    -   **Function**: Enables discovery. Claude knows *that* the skill exists and *when* to use it.
2.  **Level 2: Instructions (On Trigger)**
    -   **Content**: The body of `SKILL.md`.
    -   **Trigger**: When a user request matches the skill's description.
    -   **Mechanism**: Claude executes `bash: read path/to/SKILL.md`.
3.  **Level 3: Resources & Code (On Demand)**
    -   **Content**: Referenced files (e.g., `FORMS.md`, `schema.sql`) and scripts.
    -   **Trigger**: When instructions in `SKILL.md` explicitly reference them or when Claude decides it needs them.
    -   **Mechanism**: `bash: read ...` or `bash: python script.py`.

### 1.2 `SKILL.md` Schema
Every skill **must** have a `SKILL.md` file with YAML frontmatter.

```markdown
---
name: my-skill-name
description: >
  Detailed description of what this skill does.
  Crucial: Include "Use when..." triggers to help Claude know when to activate it.
allowed-tools: [Read, Grep, Glob, Bash] # Optional: Whitelist tools
---

# My Skill Name

## Instructions
[Step-by-step procedures for Claude]

## Examples
[User query] -> [Expected action/response]
```

**Frontmatter Fields:**
-   **`name`** (Required): Max 64 chars. Lowercase, numbers, hyphens only. No reserved words (`anthropic`, `claude`).
-   **`description`** (Required): Max 1024 chars. No XML tags. **Critical for routing**.
-   **`allowed-tools`** (Optional): List of tools this skill is permitted to use.
    -   Available: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `WebFetch`, `WebSearch`.
    -   Use this to create "safe" skills (e.g., read-only).

### 1.3 Best Practices
-   **Progressive Disclosure**: Don't dump everything in `SKILL.md`. Move reference tables, schemas, and long guides to separate files (`REFERENCE.md`) and link to them.
-   **Executable Code**: Prefer Python scripts for logic.
    -   *Why?* Scripts are deterministic, faster, and their code doesn't consume context tokens (only the output does).
    -   *Pattern*: `scripts/validate_input.py`, `scripts/extract_data.py`.
-   **Context Economy**: Assume Claude is smart. Don't explain generic concepts (e.g., "what is JSON"). Focus on domain specifics.

---

## 2. Sub-agents

**Sub-agents** are specialized instances with isolated context windows. They prevent context pollution in long conversations and allow for role specialization.

### 2.1 Configuration Schema
Agents are defined in `.claude/agents/` (project) or `~/.claude/agents/` (global). Files can be YAML or JSON.

**File: `.claude/agents/my-agent.yml`**
```yaml
name: security-auditor
description: Audits code for security vulnerabilities. Use for security reviews.
tools: # Optional: Defaults to all tools if omitted
  - Read
  - Grep
  - Glob
model: sonnet # Options: 'sonnet', 'opus', 'haiku', 'inherit'
permissionMode: default # Options: 'default', 'bypassPermissions' (use with caution)
skills: # Auto-load these skills for this agent
  - code-analysis
  - vulnerability-db
---
You are a security auditor.
1. Start by mapping the attack surface.
2. Grep for common patterns (SQLi, XSS).
3. Report findings in SARIF format.
```

### 2.2 Configuration Fields
-   **`name`**: Unique identifier.
-   **`description`**: Used by the router to select this agent.
-   **`tools`**: Whitelist of tools.
-   **`model`**:
    -   `sonnet`: Balanced (default).
    -   `opus`: High intelligence, slower/expensive. Good for complex reasoning.
    -   `haiku`: Fast/cheap. Good for simple tasks.
    -   `inherit`: Uses the same model as the parent session.
-   **`permissionMode`**:
    -   `default`: Prompts user for sensitive actions.
    -   `bypassPermissions`: Skips prompts (requires user trust/configuration).
-   **`skills`**: List of skill names to pre-load.

### 2.3 CLI Usage
Define ephemeral agents for scripts or one-off tasks:
```bash
claude --agents '{
  "quick-fix": {
    "description": "Fixes lint errors",
    "prompt": "Fix the errors provided in stdin",
    "model": "haiku"
  }
}'
```

---

## 3. Slash Commands

**Slash Commands** provide immediate control and workflow triggers.

### 3.1 Command Types
1.  **Built-in**:
    -   `/compact`: Force context window compaction.
    -   `/cost`: Show session cost.
    -   `/doctor`: Debug environment issues.
    -   `/mcp`: Manage MCP servers.
    -   `/agents`: Interactive agent management.
2.  **Custom (Markdown)**:
    -   Location: `.claude/commands/` or `~/.claude/commands/`.
    -   File: `command-name.md`.
    -   Content: The text is inserted into the user prompt.
3.  **Plugin & MCP**: Provided dynamically by installed extensions.

### 3.2 SlashCommand Tool
Claude has a `SlashCommand` tool to invoke commands.
-   **Usage**: Claude can decide to run `/test` or `/lint` if those commands exist.
-   **Restriction**: Can be disabled via permissions if you don't want Claude triggering workflows autonomously.

---

## 4. Hooks

**Hooks** enable event-driven automation and policy enforcement.

### 4.1 Event Reference
| Event | Trigger | Input Data | Can Block? |
| :--- | :--- | :--- | :--- |
| **`PreToolUse`** | Before tool execution | Tool name, input args | Yes |
| **`PostToolUse`** | After tool execution | Tool name, input, output, error | No |
| **`PermissionRequest`** | User permission dialog | Request type, details | Yes (Auto-allow/deny) |
| **`UserPromptSubmit`** | User hits enter | Prompt text | Yes |
| **`SessionStart`** | Session init/resume | Session ID, cwd | No |
| **`Notification`** | System alerts | Type (`permission_prompt`, `idle`) | No |

### 4.2 Configuration (`settings.json`)
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python scripts/audit_command.py"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Ping.aiff"
          }
        ]
      }
    ]
  }
}
```

### 4.3 Hook I/O Protocol
Hooks communicate via JSON on `stdin` and `stdout`.

**Input (stdin):**
```json
{
  "event": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "rm -rf /" },
  "context": { ... }
}
```

**Output (stdout):**
-   **Exit Code 0**: Allow / Continue.
-   **Exit Code 1**: Block / Stop.
-   **JSON Output** (Advanced):
    ```json
    {
      "action": "allow", // or "deny", "modify"
      "modified_input": { "command": "ls -la" }, // If modifying
      "message": "Blocked dangerous command" // Feedback to user
    }
    ```

---

## 5. Plugin Marketplaces

**Plugin Marketplaces** enable decentralized distribution of tools.

### 5.1 Marketplace Schema (`marketplace.json`)
```json
{
  "name": "my-org-marketplace",
  "owner": {
    "name": "Platform Engineering",
    "email": "platform@example.com"
  },
  "plugins": [
    {
      "name": "aws-tools",
      "description": "Utilities for AWS management",
      "source": {
        "source": "github",
        "repo": "my-org/aws-claude-plugin",
        "tag": "v1.2.0" // Optional: Pin version
      },
      "version": "1.2.0"
    },
    {
      "name": "local-scripts",
      "source": "./plugins/local-scripts" // Local path support
    }
  ]
}
```

### 5.2 Plugin Structure
A plugin repository/directory should contain a `plugin.json`:
```json
{
  "name": "aws-tools",
  "version": "1.0.0",
  "commands": ["commands/deploy.md"],
  "skills": ["skills/s3-manager"],
  "agents": ["agents/cloud-architect.yml"],
  "mcpServers": {
    "aws-mcp": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-aws"]
    }
  }
}
```

### 5.3 Management Commands
-   `/plugin marketplace add <url>`: Register a marketplace.
-   `/plugin install <name>`: Install a plugin.
-   `/plugin update <name>`: Update to latest version.
