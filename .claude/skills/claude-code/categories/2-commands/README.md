# Category 2: Slash Commands

Create and manage custom Claude Code slash commands - reusable prompt shortcuts for frequently-used workflows.

## Purpose

Slash commands provide quick access to frequently-used prompts with parameter support, bash integration, and file references. This category helps you create, configure, and deploy custom commands.

## Available Functions

### command-builder/ 🔧 BUILDER
**Purpose**: Create custom slash commands
**When**: Need repetitive prompt automation, workflow shortcuts, team-shared commands
**Duration**: 10-30 minutes
**Output**: Slash command markdown file in `.claude/commands/`

**Usage**: Run when you find yourself repeating the same prompts or need team shortcuts

## What Are Slash Commands?

**Slash commands** are markdown files that define reusable prompts:
- Invoked with `/command-name`
- Support parameters: `/deploy {environment}`
- Can integrate bash commands
- Can reference files with `@path/to/file`
- Project-scoped (`.claude/commands/`) or user-scoped (`~/.claude/commands/`)

## Workflow Pattern

```
Repetitive prompt → command-builder/ 🔧 → Test → Share with team
```

## Command Structure

Basic command file:
```markdown
# Command Description

What this command does and when to use it.

## Usage
/command-name [parameters]

## Implementation
The actual prompt that will be executed.
Can include {parameters}, bash commands, and file references.
```

## Key Concepts

### Parameter Support
Commands can accept dynamic inputs:
```
/deploy {environment} {version}
```

### Bash Integration
Commands can run shell commands:
```markdown
First run: `git status`
Then analyze the output...
```

### File References
Commands can reference files:
```markdown
Review the changes in @src/app.ts
```

### Scope Management
- **Project** (`.claude/commands/`): Shared with team, committed to git
- **User** (`~/.claude/commands/`): Personal shortcuts, not committed

## Best Practices
- ✅ Clear, descriptive command names
- ✅ Document parameters and usage
- ✅ Include examples in command file
- ✅ Keep prompts focused and reusable
- ✅ Use meaningful parameter names

## Templates

See `templates/commands/` for examples:
- commit.md - Git commit message generation
- review-pr.md - Pull request review
- fix-tests.md - Test failure analysis
- refactor.md - Code refactoring
- security-check.md - Security audit
- update-readme.md - Documentation updates

## Navigation

**Create command**: See `command-builder/guide.md`
**See examples**: See `command-builder/examples.md`
**Full reference**: See `command-builder/reference.md`

---

🔧 = Builder tool (create/manage)
