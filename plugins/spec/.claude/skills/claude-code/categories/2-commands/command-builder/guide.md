---
name: slash-commands
description: Create and configure custom Claude Code slash commands for frequently-used prompts and workflows. Use when: 1) User asks to create a slash command, 2) User mentions "slash command", "custom command", or "/command", 3) User has repetitive prompts that could be automated, 4) User wants project-specific or personal shortcuts, 5) User wants to integrate bash commands or file references into prompts. Generates slash command files with best practices. (project)
---

# Claude Code Slash Commands Skill

Create, configure, and manage custom Claude Code slash commands - reusable prompt shortcuts for frequently-used workflows.

## Core Concepts

**Slash commands** are custom prompts stored as markdown files that can be invoked with `/command-name`. They provide:
- Quick access to frequently-used prompts
- Parameter support for dynamic content
- Bash command integration
- File reference capabilities
- Team-shared or personal scope

## Workflow

### 1. Understand Requirements

Ask user:
```javascript
{
  "name": "command-name",  // lowercase-with-hyphens
  "purpose": "What does this command do?",
  "prompt": "The actual prompt text",
  "parameters": ["arg1", "arg2"],  // Optional
  "bashCommands": ["git status"],  // Optional
  "fileReferences": ["@path/to/file"],  // Optional
  "tools": ["Bash", "Read"],  // Optional allowed-tools
  "scope": "project|user"  // .claude/commands/ or ~/.claude/commands/
}
```

### 2. Review Examples

Load inspiration:
```bash
cat EXAMPLES.md  # Real-world slash command examples
```

### 3. Generate Command File

**File location**:
- Project: `.claude/commands/{name}.md` (shared with team)
- User: `~/.claude/commands/{name}.md` (personal)

**Basic structure**:
```markdown
---
description: Brief command overview
argument-hint: [expected args]  # Optional
allowed-tools: Bash(git:*), Read, Write  # Optional
model: sonnet  # Optional
---

Your prompt here with $ARGUMENTS or $1, $2, etc.
```

**Key features**:
- `$ARGUMENTS` - All arguments as single string
- `$1, $2, $3` - Individual positional arguments
- `!command` - Execute bash command, output becomes context
- `@file.txt` - Include file contents
- YAML frontmatter for configuration

Refer to patterns in `REFERENCE.md`.

### 4. Validate Configuration

Check:
- ✓ Command name is lowercase-with-hyphens
- ✓ Description is clear (shown in /help)
- ✓ allowed-tools specified if using Bash
- ✓ argument-hint provided if parameters expected
- ✓ File location is correct

### 5. Test Command

Provide test invocation:
```bash
# Basic usage
/{command-name}

# With arguments
/{command-name} arg1 arg2

# Check command is registered
/help  # Should show your command
```

## Common Command Patterns

Load pattern library:
```bash
cat REFERENCE.md  # Slash command patterns
cat EXAMPLES.md   # Real-world examples
```

**Quick patterns**:
1. **Code review**: `!git diff` + review prompt
2. **Git commit**: `!git status` + commit message generation
3. **Test runner**: `!npm test` + failure analysis
4. **Documentation**: `@readme.md` + update prompt
5. **Refactoring**: Template prompt with file reference
6. **Bug report**: Gather context + format as issue

## Parameter Usage

### All arguments as one ($ARGUMENTS)

```markdown
Fix issue #$ARGUMENTS following our coding standards
```
Usage: `/fix-issue 123 high-priority`
Result: "Fix issue #123 high-priority following..."

### Individual arguments ($1, $2, ...)

```markdown
Review PR #$1 with priority $2 and assign to $3
```
Usage: `/review-pr 456 high alice`
Result: "Review PR #456 with priority high and assign to alice"

## Bash Integration

Execute commands with `!` prefix:

```markdown
---
allowed-tools: Bash(git status:*), Bash(git diff:*)
---

Current git status:
!`git status -s`

Recent changes:
!`git diff --stat`

Please review and suggest commit message.
```

**Security**: Always specify allowed-tools for Bash commands!

## File References

Include file contents with `@` prefix:

```markdown
Review the implementation in @src/utils/helpers.js and compare with @src/utils/helpers.test.js

Suggest improvements.
```

Files are loaded and included in context automatically.

## Output Format

After creating command:
```
✅ Slash command created: /{name}
📄 Location: {file-path}
📝 Description: {description}
🔧 Parameters: {argument-hint or "none"}
🛠️  Tools: {allowed-tools or "default"}

🧪 Test with:
  /{name} {example-args}

💡 View all commands:
  /help
```

## Resources

- `EXAMPLES.md` - Real-world slash command examples (git, testing, docs)
- `REFERENCE.md` - Complete syntax, patterns, best practices
- `templates/` - Pre-built command templates
- `scripts/validate-command.sh` - Command syntax validator

## Slash Commands vs. Skills

**Use slash commands for**:
- Simple, frequently-used prompts
- Quick shortcuts (1-2 sentences)
- Team conventions and standards
- Git workflows and commit messages

**Use Skills for**:
- Complex multi-step workflows
- Requires multiple resources
- Needs automatic discovery
- Sophisticated logic

## Organization

Group related commands in subdirectories:

```
.claude/commands/
├── git/
│   ├── commit.md
│   └── review-pr.md
├── testing/
│   ├── run-tests.md
│   └── fix-tests.md
└── docs/
    └── update-readme.md
```

Subdirectories shown in `/help` output but don't affect command name.

## Remember

- Keep commands simple and focused
- Use descriptive names (lowercase-with-hyphens)
- Always specify allowed-tools for Bash
- Document parameters with argument-hint
- Test commands after creation
- Version control project commands for team sharing
