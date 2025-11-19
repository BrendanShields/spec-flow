---
name: creating-skills
description: Builds new Claude Code Agent Skills end-to-end (metadata, instructions, progressive disclosure assets). Trigger when the user requests a reusable capability packaged as a skill or mentions the skills docs/blog.
allowed-tools: [Read, Write, Edit, Bash]
---

# Creating Skills

Guides Claude through building a complete Agent Skill directory following the official docs:

- [Agent Skills guide](https://code.claude.com/docs/en/skills)
- [Agent Skills overview](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
- [Engineering blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Introducing Agent Skills blog](https://www.claude.com/blog/skills)

## When to use
- The user wants repeatable expertise bundled into `.claude/skills/**`.
- Work requires multi-file references, scripts, or context that outgrows a slash command.
- Documentation specifically cites Skills, progressive disclosure, or onboarding-style instructions.
- Unsure whether a command, hook, skill, or agent is needed? Run `maintaining-workflows` first.

## Intake checklist
1. Clarify the capability: task scope, prerequisites, success signals, failure handling.
2. Capture triggers (phrases, file types, events) and required tools. Default to minimal tools; add Bash only if scaffolding or lookups actually require it.
3. Determine inputs/outputs: state files, templates, scripts, or MCP calls.
4. Identify supporting assets (examples, reference docs, scripts) and how they should be linked from the main skill.
5. Record dependencies (packages, binaries, env vars) so they can be documented in the description per the skills guide.

## Build workflow
1. **Plan the structure**
   - Follow the `my-skill/` layout from the docs (`SKILL.md`, optional `reference.md`, `examples.md`, `scripts/`, `templates/`).
   - Use hyphen-case folder + `name`, keep ≤64 chars.
   - Align metadata with the discovery model: description states *what* + *when* (≤1024 chars), include version note if applicable.
2. **Draft `SKILL.md`**
   - Start with YAML frontmatter (`name`, `description`, optional `allowed-tools`, `model`, `permissionMode`, `skills`).
   - Body sections should mirror the onboarding style outlined in the engineering blog: quick overview, inputs, detailed workflow, fallbacks, validation, and references to linked files.
   - Use progressive disclosure: keep the main file concise, move deep dives to linked files referenced via `[reference.md](reference.md)` etc.
3. **Add supporting files**
   - Create `reference.md`, `examples.md`, or scripts/templates only when referenced.
   - For scripts, set execute bits via `chmod +x` and call out dependencies in `SKILL.md`.
   - Store templates or large docs in subfolders to avoid bloating `SKILL.md`.
4. **Wire into the workflow**
   - If the skill should delegate to subagents, list them in the `skills:` or describe delegation points explicitly.
   - Mention required config or state (`CLAUDE.md`, `.spec/**`, environment vars).
   - Provide verification steps: `/skills`, scenario triggers, or log locations.
5. **Validate**
   - Run `/skills` to ensure Claude discovers the new skill (confirm metadata and allowed tools match expectations).
   - Spot-check progressive disclosure: ensure additional files exist and are linked.
   - Lint YAML (triple-dash separators, spaces not tabs) and confirm hyphen-case naming.

## Quality checklist
- Description explains both capability and triggers.
- Allowed tools are minimal and justified.
- Linked files exist and are referenced once.
- Instructions mention error handling and AskUserQuestion moments when user choices are needed.
- Validation + rollback guidance is present.

## References
- `.claude/skills/` in this repo for working patterns (e.g., `orbit-planning`, `orbit-lifecycle`).
- Docs listed above for metadata rules, progressive disclosure, and distribution guidance.
