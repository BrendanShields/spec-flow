---
name: creating-agents
description: Designs Claude Code subagents (.claude/agents/*.md) with scoped prompts, tool lists, and skills attachments using the subagent framework documentation.
allowed-tools: [Read, Write, Edit, Bash]
---

# Creating Agents

Builds specialized Claude Code subagents per the [subagent guide](https://code.claude.com/docs/en/sub-agents). Focuses on scoping, tool permissions, and documentation so Claude can delegate safely.

## When to use
- Team needs a reusable persona (reviewer, debugger, researcher) with its own workflow.
- Request references `/agents`, tool restrictions, or `permissionMode`.
- We must document when Claude should delegate automatically vs on-demand.
- If another asset (skill/command/hook) might suffice, confirm via `maintaining-workflows`.

## Intake checklist
1. **Purpose & triggers**: Problem space, when to run automatically, and when not to.
2. **Tooling**: Explicit list of tools (Read, Grep, Bash, MCP, etc.) required for the tasks.
3. **Model + permissions**: Preferred model (`sonnet`, `opus`, etc.) and `permissionMode` (`default`, `plan`, etc.).
4. **Supporting skills**: Any skills that should auto-load with the agent (comma-separated list).
5. **Workflow outline**: Steps the agent should follow, escalation paths, logging/reporting expectations.

## Build workflow
1. **File scaffold**
   - Path: `.claude/agents/<agent-name>.md` (lowercase hyphen or snake case).
   - YAML frontmatter fields from the doc: `name`, `description`, `tools`, `model`, `permissionMode`, `skills`.
   - Description should state both expertise and invocation guidance (“Use proactively after …”).
2. **Prompt body**
   - Include sections for mission, step-by-step workflow, decision criteria, and reporting format.
   - Define escalation/stop conditions and when to ask the user for clarification.
   - Reference relevant skills, hooks, or docs (e.g., `docs/patterns/state-management.md`).
3. **Tool discipline**
   - Only grant tools that match the workflow. If shell commands are required, specify `Bash` explicitly.
   - Mention MCP dependencies or credential requirements if applicable.
4. **Testing plan**
   - Provide instructions to invoke the agent explicitly (`Use the <name> subagent…`) and expected outputs.
   - Note how to inspect transcripts (`agent-<id>.jsonl`) per the doc.
5. **Documentation**
   - Update `agents.md` or CLAUDE.md with agent purpose, version, and owner.
   - Remind maintainers to re-run `/agents` after edits to confirm metadata loads correctly.

## Quality checklist
- Frontmatter matches the documented schema.
- Prompt includes clear workflow, guardrails, and success criteria.
- Tool list is minimal yet sufficient; permission mode chosen intentionally.
- Related skills and hooks are referenced for context reuse.
- Testing + rollback steps documented.

## References
- Subagent guide for storage precedence, CLI overrides, and best practices.
- Existing agents in `.claude/agents/` (e.g., `spec-implementer.md`) for tone and structure.
