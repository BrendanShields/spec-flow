---
name: maintaining-claude-workflows
description: Evaluates workflow requests, recommends whether to build a skill, slash command, hook, or agent, and records best practices drawn from the Claude Code docs.
allowed-tools: [Read, Write, Edit, Bash]
---

# Maintaining Workflows

Decides which Claude Code asset to build next and captures the rationale. Synthesizes the official docs:

- Skills: https://code.claude.com/docs/en/skills, https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview, https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills, https://www.claude.com/blog/skills
- Slash commands: https://code.claude.com/docs/en/slash-commands
- Hooks: https://code.claude.com/docs/en/hooks-guide
- Subagents: https://code.claude.com/docs/en/sub-agents

## When to use
- User/prod owner requests a new workflow capability but the asset type is unclear.
- Need to enforce best practices or prevent redundant assets.
- Before editing `.claude/commands`, `.claude/skills`, `.claude/hooks`, or `.claude/agents`.

## Discovery steps
1. **Read local context**
   - `CLAUDE.md`, `agents.md`, and the Orbit references (`.claude/skills/orbit-lifecycle/reference.md`, `.claude/skills/orbit-planning/reference.md`) to understand current conventions.
   - Existing assets under `.claude/**` for prior art.
2. **Clarify requirements**
   - Trigger style: user-invoked vs automatic.
   - Complexity: single prompt vs multi-file instructions/scripts.
   - Determinism needs: Should automation block/guard actions?
   - Tooling + security constraints.
   - Sharing scope: user only vs team vs plugin.
3. **Map to asset types**

| Asset          | Trigger style                  | Best for                                                                 | Key docs |
| -------------- | ------------------------------ | ------------------------------------------------------------------------ | -------- |
| Slash command  | User-invoked `/command`        | Short, repeatable prompts; quick context snapshots; manual control       | Slash commands guide |
| Skill          | Auto-discovered when relevant  | Multi-step workflows, progressive disclosure, scripts/templates          | Skills docs/blogs |
| Hook           | Lifecycle automation           | Deterministic enforcement before/after tool use, auditing, notifications | Hooks guide |
| Subagent       | Delegated persona              | Long-running or specialized reasoning with custom tool set               | Subagent guide |

If none fit, consider documenting the workflow in `CLAUDE.md` or a standard operating procedure.

## Decision workflow
1. **Triage**: Using the table above, eliminate asset types that clearly don’t fit (e.g., automation needed → hooks).
2. **Assess scope**:
   - If instructions require progressive disclosure or scripts, choose a skill.
   - If user wants an explicit `/keyword`, choose a slash command (ensure it fits single-file budget).
   - If automation needs to run without user intervention, choose a hook.
   - If Claude should delegate to a persona with isolated context/tools, create an agent.
3. **Check dependencies**:
   - Validate required directories exist (`.claude/commands`, `.claude/hooks`, `.claude/skills`, `.claude/agents`).
   - Confirm environment requirements (packages, env vars) are documented.
4. **Recommend + document**:
   - Summarize reasoning (trigger, complexity, risk, doc references).
   - Point to the corresponding creation skill (`creating-slash-commands`, `creating-hooks`, `creating-skills`, `creating-agents`).
   - Update `agents.md` or `CLAUDE.md` with the decision log so future contributors understand the choice.
5. **Handoff**:
   - Invoke/mention the appropriate creation skill.
   - Outline success criteria, validation steps, and owners.

## Quality checklist
- Decision references at least one official doc section.
- Trade-offs documented (e.g., slash command vs skill).
- Resulting action points link to the right creation skill.
- Repository docs (`agents.md`, `CLAUDE.md`) receive an update or TODO.
- Any remaining questions for stakeholders are listed (AskUserQuestion prompts).

## Outputs
- Short recommendation summary.
- Pointer to the chosen creation skill and next steps.
- Optional updates to `agents.md` / `CLAUDE.md` capturing the decision.
