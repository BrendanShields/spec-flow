---
name: creating-hooks
description: Authors Claude Code lifecycle hooks with correct events, matchers, and security practices using the official hooks guide.
allowed-tools: [Read, Write, Edit, Bash]
---

# Creating Hooks

Implements deterministic automation via Claude Code hooks following the [hooks quickstart](https://code.claude.com/docs/en/hooks-guide) and repository conventions (`.claude/hooks/*.sh`, `.claude/settings*.json`).

## When to use
- Need automation tied to lifecycle events (PreToolUse, PostToolUse, SessionStart, Notification, etc.).
- Want script-level enforcement (formatters, logging, blocking writes) rather than relying on prompting.
- The request references `/hooks`, hook events, matchers, or `.claude/hooks/`.
- Unsure whether a hook or skill/command fits? Consult `maintaining-workflows`.

## Intake checklist
1. **Event trigger**: Which lifecycle event? (`PreToolUse`, `PostToolUse`, `SessionStart`, etc.)
2. **Matcher scope**: Specific tool(s) or wildcard? Document reasoning to avoid unexpected executions.
3. **Action**: Shell snippet or script path? Determine if multi-line script should live under `.claude/hooks/`.
4. **Storage location**: Project (`.claude/settings.json`) vs user (`~/.claude/settings.json`).
5. **Safety**: Required dependencies, permissions, and how to fail (block vs warn).

## Build workflow
1. **Design the command**
   - Favor scripts in `.claude/hooks/` with execute bits set (`chmod +x`).
   - Include inline comments for security-sensitive logic.
   - Accept JSON from stdin when parsing tool inputs (see guide examples).
2. **Edit settings**
   - Open `.claude/settings.json` (project) or instruct the user to edit their global settings.
   - Follow the documented schema: `"hooks": { "<Event>": [ { "matcher": "...", "hooks": [ { "type": "command", "command": "..." } ] } ] }`.
   - For multiple hooks under the same matcher, maintain deterministic order.
3. **Handle security**
   - Mention environment variables or filesystem paths touched.
   - For blocking hooks, exit non-zero and print actionable feedback (guide recommends this).
   - Warn about running third-party scripts and remind users hooks run with their credentials.
4. **Test**
   - Use `/hooks` UI to verify registration or manually inspect settings JSON.
   - Trigger the event (e.g., run `Bash`, `Edit`) and capture stdout/stderr logs.
   - Document failure/rollback steps (remove matcher, disable hook) in `CLAUDE.md` or the hook script header.
5. **Document**
   - Update `.claude/hooks/README.md` or relevant docs with usage instructions.
   - Reference this skill from `maintaining-workflows` if automation choices need auditing.

## Quality checklist
- Matcher is as specific as possible (no accidental `*` unless intended).
- Scripts live in repo-controlled paths, are executable, and log errors clearly.
- Settings JSON remains valid (linted, trailing commas removed).
- Security considerations from the guide (automatic execution, credential scope) are noted.
- Testing + rollback guidance included.

## References
- Hooks guide sections: event list, matcher design, security considerations, debugging.
- Existing repo hooks under `.claude/hooks/` for style and logging patterns.
