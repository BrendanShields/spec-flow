---
name: creating-slash-commands
description: Designs and authors Claude Code slash commands (.claude/commands/*.md) with correct frontmatter, prompts, and tool permissions based on the official slash command guide.
allowed-tools: [Read, Write, Edit, Bash]
---

# Creating Slash Commands

Implements custom `/command` files from the [Slash commands guide](https://code.claude.com/docs/en/slash-commands). Use this skill to turn a frequently repeated instruction into a deterministic command.

## When to use
- The workflow fits in a single Markdown file and should be user-invoked (`/something`) rather than auto-detected.
- Command needs structured arguments, pre-run bash snippets, or deterministic prompts.
- The request references `/commands`, autocomplete hints, or the slash command docs.
- If unsure whether a slash command or skill is best, run `maintaining-workflows` first.

## Intake checklist
1. Capture the desired **command name** (no spaces, referenced as `/name`).
2. Identify **arguments** and whether positional (`$1 $2`) or trailing text fits better.
3. List **required tools** (Bash, Read, etc.) and any bash subcommands that must be explicitly whitelisted via `allowed-tools: Bash(git status:*), ...`.
4. Gather **context snippets** to include (file references with `@path`, bash captures with ``!`cmd``, or static instructions).
5. Confirm **model requirements**, extended thinking, or permission needs.

## Build workflow
1. **Scaffold the file**
   - Path: `.claude/commands/<command>.md`.
   - Frontmatter options from the docs: `description`, `argument-hint`, `allowed-tools`, `model`, `disable-model-invocation`.
   - Keep the description concise (impacts discovery + SlashCommand tool budget).
2. **Author the body**
   - Start with a short heading or summary.
   - Provide clear context sections (e.g., “## Context”, “## Task”, “## Output rules”).
   - Use `@` to inline file contents and ``!`cmd``` to pre-run bash commands as described in the docs.
   - Show argument usage or examples so humans understand what `/command foo bar` does.
3. **Handle arguments**
   - Document usage with `argument-hint` (autocomplete) and inline instructions.
   - For positional arguments, refer to `$1`, `$2` in the prose; for free-form text let Claude parse the tail of the command.
4. **Enforce permissions**
   - Only grant the tools the command actually needs.
   - Consider adding `disable-model-invocation: true` for internal commands that should not auto-run.
5. **Validate**
   - Run `/commands` to confirm metadata is visible.
   - Use `/context` to check the SlashCommand character budget; trim verbosity if budget exceeded.
   - Dry-run the command locally (type `/command sample`) and ensure pre-run bash output and file references resolve.

## Quality checklist
- Command name matches file and is unique.
- Instructions cover success criteria, failure handling, and expected outputs.
- Bash snippets and file references use the documented syntax.
- Argument hints align with actual parsing expectations.
- Permissions + extended thinking keywords (if any) are explicitly noted.

## References
- Slash commands guide (structure, frontmatter, helper syntax).
- `.claude/commands/orbit.md` and `.claude/commands/orbit-track.md` for real examples in this repo.
