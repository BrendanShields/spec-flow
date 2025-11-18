# Claude Code Agent Enablement Guide

> Working notes for building and maintaining Spec Workflow subagents, skills, hooks, and plugins. Use this as the checklist before touching `.claude/` assets or publishing marketplace bundles.

## 1. Operating Principles

- Favor modular assets: each subagent/skill/plugin should solve a single job and live in its own folder (mirrors Claude Code documentation).
- Keep descriptions specific: describe both *what* the asset does and *when* Claude should invoke it so automatic discovery works.
- Treat assets as code: track in git, version them in the description, and test locally before sharing with the team.
- Scope wisely: personal work goes in `~/.claude/**`, team-shared work goes in repo-scoped `.claude/**`, plugin-delivered work ships inside `.claude-plugin/` manifests.

## 2. Agent Skills Playbook

**Storage**
- Personal: `~/.claude/skills/<skill-name>/`
- Project: `.claude/skills/<skill-name>/`
- Plugin-bundled: `<plugin>/skills/<skill-name>/`

**Required structure**
```
my-skill/
├── skill.md                # YAML frontmatter + markdown body
├── reference.md            # optional docs/examples/scripts
└── scripts/, templates/, … # optional support files
```

**skill.md template**
```markdown
---
name: hyphen-case-name          # <=64 chars, lowercase, digits, hyphens
description: Explain task + triggers (<=1024 chars)
allowed-tools: Read, Grep       # optional tool gating
---

# Title

## Instructions
- Enumerate steps Claude should follow

## Examples
- Show representative invocations plus supporting files
```

**Build/Test flow**
1. Create folder + `skill.md` with descriptive trigger text.
2. Add optional assets (examples, scripts, templates) referenced via relative links.
3. Use `allowed-tools` to restrict powerful capabilities (especially Bash/Edit).
4. Validate YAML (frontmatter triple-dash, spaces not tabs) and file paths.
5. Test via `/skills` or by issuing a request that should trigger the skill; inspect `.claude/logs` if Claude skips it.
6. Share by committing `.claude/skills/**` (project scope) or bundling inside plugins.

**Troubleshooting quick hits**
- Claude ignores Skill → tighten description, confirm location, re-run validation.
- Runtime errors → check execute bits on scripts and dependencies listed in description.
- Conflicts → differentiate descriptions with explicit trigger nouns.

## 3. Plugin Guide Rail

**Mental model:** plugins bundle commands, agents, skills, hooks, and MCP servers, then ship via a marketplace or local folder.

**Directory layout**
```
my-plugin/
├── .claude-plugin/plugin.json      # metadata (name, desc, version, author)
├── commands/*.md                   # optional slash commands
├── skills/<skill-name>/skill.md    # optional packaged skills
├── agents/<agent-name>.md          # optional subagents
├── hooks/hooks.json                # optional hook registrations
└── .mcp.json                       # optional MCP server definition
```

**Local quickstart**
1. Scaffold plugin inside a marketplace folder (`marketplace/.claude-plugin/marketplace.json` lists plugins and their paths).
2. Author `.claude-plugin/plugin.json` with schema-compliant metadata.
3. Add at least one capability (e.g., `commands/hello.md`) written in markdown.
4. From the repo root run `claude`, add the marketplace (`/plugin marketplace add ./test-marketplace`), then install your plugin.
5. Restart Claude Code → invoke new command (`/hello`) or review `/help`.

**Installation & team workflows**
- Use `/plugin marketplace add` for local folders or remote catalogs.
- Install with `/plugin install plugin@marketplace`; confirm via `/plugin list`.
- Check marketplace JSON into git so teammates inherit the catalog; include install instructions in project docs.

**Development best practices**
- Keep plugins modular (one concern per plugin).
- Version bump + changelog when updating.
- Co-locate hooks/skills/agents inside plugin for easy sharing.
- Document dependencies (npm, pip, binaries) inside `/help` output and the plugin manifest.

## 4. Hooks Checklist

**What they are:** deterministic shell commands triggered by Claude Code lifecycle events (PreToolUse, PostToolUse, UserPromptSubmit, Notification, Stop, SubagentStop, PreCompact, SessionStart, SessionEnd).

**Creation steps**
1. Run `/hooks`, pick the event (e.g., PreToolUse).
2. Add a matcher (tool name or wildcard) so hook only fires where intended.
3. Attach hook command (shell snippet, script, etc.).
4. Choose storage scope (user settings vs project `.claude/settings.json`).
5. Save, then verify via `/hooks` or by inspecting the JSON entry.
6. Test by triggering the relevant action; check logs for stderr/stdout.

**Security guardrails**
- Hooks run automatically with your credentials—review third-party scripts before enabling.
- Keep hook scripts in repo-controlled paths (`.claude/hooks/`) and make them executable.
- For blocking hooks, exit with non-zero status to stop the tool and provide feedback.

**Common recipes**
- Logging Bash commands:
  ```
  jq -r '"\(.tool_input.command) - \(.tool_input.description // "No description")"' >> ~/.claude/bash-command-log.txt
  ```
- Auto-formatting after Edit/Write:
  ```
  {
    "hooks": {
      "PostToolUse": [{
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/markdown_formatter.py"
        }]
      }]
    }
  }
  ```
- File protection (deny edits to `.env`, lockfiles, `.git/`).

## 5. Subagent Framework

**Concept:** specialized agents with dedicated prompts, tool access, and optional model overrides. Claude delegates automatically when tasks match the subagent description, or you can invoke them explicitly (`Use the code-reviewer subagent…`).

**Storage precedence**
- Project scope: `.claude/agents/*.md` (highest priority if names clash)
- User scope: `~/.claude/agents/*.md`
- Plugin-provided: `<plugin>/agents/*.md`
- Ephemeral: CLI `claude --agents '{ ... }'`

**File format**
```markdown
---
name: code-reviewer
description: Expert reviewer; use after writing or modifying code (PROACTIVE)
tools: Read, Grep, Glob, Bash     # optional (inherits all if omitted)
model: inherit | sonnet | opus | haiku
permissionMode: default|acceptEdits|bypassPermissions|plan|ignore
skills: qa-skill, logging-skill   # optional auto-loaded skills
---

System prompt describing workflow, checklists, escalation rules, etc.
```

**Build flow**
1. Use `/agents` (recommended) to create or edit; confirms tool list and avoids YAML mistakes.
2. For file-based edits, create directories + markdown manually and commit to repo for team agents.
3. Document when Claude should use the agent (include “use proactively/automatically” hints).
4. Limit tools to only what the agent needs; default inherits all including MCP tools.
5. Test by prompting Claude with a scenario that should trigger delegation; inspect the `agentId` returned.

**Management**
- `/agents` UI lists built-in, plugin, user, and project agents; also resolves duplicates.
- CLI flag `claude --agents '{...}'` lets scripts inject temporary agents.
- Built-in Plan subagent handles research during plan mode (Read/Grep/Glob/Bash access on Sonnet); do not delete.

**Advanced**
- Resume work by referencing the logged `agentId` (`Resume agent abc123…`); transcripts stored as `agent-<id>.jsonl`.
- Chain agents by issuing sequential instructions (“Run code-analyzer first, then optimizer”).
- Track performance: each subagent starts with empty context, so weigh latency vs isolation benefits.

**Starter templates**
- Code reviewer (focus on git diff + prioritized issues).
- Debugger (error reproduction + root-cause steps).
- Data scientist (SQL/BigQuery with Bash + Read + Write).

## 6. Putting It All Together

When building workflow assets for this repo:
1. Decide artifact type (Skill vs Subagent vs Hook vs Plugin component).
2. Follow the relevant checklist above to scaffold directories/files.
3. Document dependencies and instructions inside the artifact (markdown, YAML frontmatter).
4. Validate locally (`/skills`, `/agents`, `/hooks`, `/plugin install`) before committing.
5. Record notable versions/changes inside the skill or agent body so Claude knows updates.

Keep this file updated whenever new Claude Code primitives ship or when our internal conventions change.
