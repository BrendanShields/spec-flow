# Claude Code Slash Commands: Complete Reference

## Command File Structure

### Basic Format

```markdown
---
description: Brief command overview
argument-hint: [expected arguments]
allowed-tools: Tool1, Tool2
model: sonnet
disable-model-invocation: false
---

Your prompt content here with parameters and references.
```

### File Location

**Project commands** (team-shared):
- Location: `.claude/commands/{name}.md`
- Version control: ✅ Check into git
- Scope: All team members
- Priority: Higher than user commands

**User commands** (personal):
- Location: `~/.claude/commands/{name}.md`
- Version control: ❌ Personal only
- Scope: Individual user
- Priority: Lower (project overrides)

### Naming Convention

- Lowercase only
- Hyphens for spaces: `review-pr.md` not `review_pr.md`
- Descriptive: `fix-tests.md` not `ft.md`
- No special characters except hyphens
- Extension must be `.md`

**Command invocation**: `/{filename-without-extension}`

Examples:
- `commit.md` → `/commit`
- `review-pr.md` → `/review-pr`
- `fix-tests.md` → `/fix-tests`

## Frontmatter Fields

### description

**Purpose**: Brief overview shown in `/help` and used by SlashCommand tool

**Required**: No, but strongly recommended

**Example**:
```yaml
description: Generate commit message from current changes
```

**Best practices**:
- Keep under 80 characters
- Clear, actionable description
- Include key functionality

### argument-hint

**Purpose**: Shows expected arguments in autocomplete and help

**Required**: No, but recommended if command takes parameters

**Format**: `<required> [optional]`

**Examples**:
```yaml
argument-hint: <pr-number>
argument-hint: <file-path> [priority]
argument-hint: [tag-from] [tag-to]
```

### allowed-tools

**Purpose**: Specifies which tools the command can use

**Required**: Yes, if using Bash or restricting tool access

**Format**: Comma-separated list with optional command restrictions

**Examples**:
```yaml
# Allow specific tools
allowed-tools: Read, Write, Edit

# Allow Bash with specific commands
allowed-tools: Bash(git:*), Bash(npm test:*)

# Allow all tools (default if omitted)
# allowed-tools: *

# Multiple tools with restrictions
allowed-tools: Bash(git add:*), Bash(git commit:*), Read, Write
```

**Bash command restrictions**:
- `Bash(git:*)` - Allow all git commands
- `Bash(npm test:*)` - Allow only npm test commands
- `Bash(*)` - Allow all bash commands (use cautiously)

### model

**Purpose**: Specify which Claude model to use

**Required**: No, defaults to current conversation model

**Options**: `sonnet`, `opus`, `haiku`

**Examples**:
```yaml
model: sonnet  # Default, balanced
model: opus    # Complex reasoning
model: haiku   # Fast, simple tasks
```

### disable-model-invocation

**Purpose**: Prevent SlashCommand tool from automatically executing this command

**Required**: No, defaults to false

**Use case**: When command should only be manually invoked, not programmatically

**Example**:
```yaml
disable-model-invocation: true
```

## Parameter Substitution

### $ARGUMENTS (All Arguments)

Captures all passed arguments as a single string.

**Template**:
```markdown
Fix issue #$ARGUMENTS following coding standards
```

**Usage**: `/fix-issue 123 high-priority`

**Result**: "Fix issue #123 high-priority following..."

### $1, $2, $3... (Positional Arguments)

Access individual arguments by position.

**Template**:
```markdown
Review PR #$1 with priority $2 and assign to $3
```

**Usage**: `/review-pr 456 high alice`

**Result**: "Review PR #456 with priority high and assign to alice"

### Combining Parameters

```markdown
---
argument-hint: <file> <action> [additional-args]
---

Perform $2 on file: $1

Additional context: $ARGUMENTS
```

**Usage**: `/process src/app.ts refactor clean up code`

**Result**:
- `$1` = src/app.ts
- `$2` = refactor
- `$ARGUMENTS` = src/app.ts refactor clean up code

## Bash Command Integration

### Basic Syntax

Use `!` prefix followed by backticks:

```markdown
!`command here`
```

**Output**: Command output becomes part of the prompt context

### Examples

**Git status**:
```markdown
Current git status:
!`git status -s`
```

**Test results**:
```markdown
Test output:
!`npm test 2>&1 | tail -50`
```

**File listing**:
```markdown
Project structure:
!`tree -L 2 -I 'node_modules|.git'`
```

### Security Requirements

**ALWAYS specify allowed-tools** for Bash commands:

```markdown
---
allowed-tools: Bash(git status:*), Bash(git diff:*)
---

!`git status -s`
!`git diff --stat`
```

**Without allowed-tools**: Command will fail with permission error

### Error Handling

Commands that might fail should use `|| true`:

```markdown
!`npm outdated 2>&1 || true`
```

This prevents command failure from blocking the slash command.

### Piping and Redirection

Supported:
```markdown
!`git log --oneline | head -10`
!`npm test 2>&1 | tail -20`
!`ls -la | grep '^d'`
```

## File Reference Integration

### Basic Syntax

Use `@` prefix followed by file path:

```markdown
@path/to/file.ext
```

**Output**: File contents are loaded and included in context

### Examples

**Single file**:
```markdown
Review this implementation:
@src/utils/helpers.ts
```

**Multiple files**:
```markdown
Compare the implementation and tests:

Implementation:
@src/utils/helpers.ts

Tests:
@src/utils/helpers.test.ts
```

**With parameters**:
```markdown
---
argument-hint: <file-path>
---

Review this file:
@$1
```

### Relative vs. Absolute Paths

**Relative** (recommended):
```markdown
@src/components/Button.tsx
@README.md
@package.json
```

**Absolute**:
```markdown
@/Users/dev/project/src/app.ts
```

**Current directory**:
```markdown
@./config.json
```

### Error Handling

If file doesn't exist, Claude receives an error message. Consider defensive prompting:

```markdown
If the file @$1 exists, review it for...
Otherwise, create it with...
```

## Subdirectory Organization

### Structure

Group related commands:

```
.claude/commands/
├── git/
│   ├── commit.md
│   ├── review-pr.md
│   └── release-notes.md
├── testing/
│   ├── run-tests.md
│   ├── fix-tests.md
│   └── coverage.md
└── docs/
    ├── update-readme.md
    └── api-docs.md
```

### Invocation

Subdirectories **don't affect** command name:

- `.claude/commands/git/commit.md` → `/commit` (not `/git/commit`)
- `.claude/commands/testing/coverage.md` → `/coverage`

### Display

Subdirectories shown in `/help` output for organization:

```
Available Commands:
  /commit (project:git)
  /coverage (project:testing)
  /update-readme (project:docs)
```

## Command Patterns

### Pattern: Git Workflow

```markdown
---
description: Generate conventional commit message
allowed-tools: Bash(git status:*), Bash(git diff:*)
---

Staged changes:
!`git diff --cached`

Generate a conventional commit message (type(scope): description).
```

### Pattern: Test Runner

```markdown
---
description: Run tests and analyze failures
allowed-tools: Bash(npm test:*), Read, Grep
---

!`npm test 2>&1`

Analyze failures and suggest fixes with file:line references.
```

### Pattern: Code Review

```markdown
---
description: Review file for quality and security
argument-hint: <file-path>
allowed-tools: Read, Grep
---

@$1

Review for:
1. Security vulnerabilities
2. Code quality
3. Best practices
4. Performance issues
```

### Pattern: Documentation

```markdown
---
description: Update README with current state
allowed-tools: Read, Write
---

Current README:
@README.md

Current package.json:
@package.json

Update README to match current dependencies and features.
```

### Pattern: Context Gathering

```markdown
---
description: Gather full project context for debugging
allowed-tools: Bash(git:*), Bash(npm:*), Read
---

Git info:
!`git branch --show-current`
!`git log --oneline -5`

Package info:
@package.json

Environment:
!`node --version && npm --version`

[Your debugging question here]
```

## Extended Thinking

Slash commands can trigger extended thinking by including keywords:

```markdown
Analyze this complex algorithm and think deeply about edge cases:
@src/algorithm.ts
```

Extended thinking keywords: "think deeply", "analyze thoroughly", "comprehensive analysis"

## Best Practices

### ✅ DO

1. **Use descriptive names**
   ```
   ✅ review-security.md
   ❌ rs.md
   ```

2. **Add descriptions**
   ```yaml
   description: Review code for security vulnerabilities
   ```

3. **Specify allowed-tools for Bash**
   ```yaml
   allowed-tools: Bash(git:*)
   ```

4. **Document parameters**
   ```yaml
   argument-hint: <file-path> [severity]
   ```

5. **Handle errors gracefully**
   ```markdown
   !`npm outdated 2>&1 || true`
   ```

6. **Keep commands focused**
   - One clear purpose per command
   - Not too complex

7. **Use file references for context**
   ```markdown
   @package.json
   @README.md
   ```

### ❌ DON'T

1. **Don't use complex logic**
   - Slash commands are simple prompts
   - Use Skills for complex workflows

2. **Don't forget allowed-tools**
   ```markdown
   ❌ !`git status` (without allowed-tools)
   ✅ ---
      allowed-tools: Bash(git:*)
      ---
      !`git status`
   ```

3. **Don't use unclear names**
   ```
   ❌ x.md
   ❌ temp.md
   ❌ test123.md
   ```

4. **Don't hardcode user-specific paths**
   ```
   ❌ @/Users/alice/project/...
   ✅ @src/...
   ```

5. **Don't create overly long commands**
   - Keep prompts concise
   - If too complex, use a Skill instead

## Troubleshooting

### Command Not Found

**Issue**: `/command` not recognized

**Solutions**:
1. Check filename: must be `.md` extension
2. Verify location: `.claude/commands/` or `~/.claude/commands/`
3. Run `/help` to see registered commands
4. Restart Claude Code if needed

### Bash Command Fails

**Issue**: "Permission denied" or "Tool not allowed"

**Solutions**:
1. Add `allowed-tools` to frontmatter
2. Specify exact commands: `Bash(git status:*)`
3. Check command syntax in backticks: `!`git status``

### File Reference Not Working

**Issue**: File not loaded or "File not found"

**Solutions**:
1. Check path is relative to project root
2. Verify file exists: use `ls` to check
3. Try absolute path if relative doesn't work
4. Check for typos in filename

### Parameters Not Substituting

**Issue**: `$1` or `$ARGUMENTS` appearing literally

**Solutions**:
1. Verify you're passing arguments: `/command arg1 arg2`
2. Check for typos: `$1` not `$i` or `$one`
3. Ensure no escaping: `$1` not `\$1`

### Command Output Too Long

**Issue**: Bash command output truncated or too verbose

**Solutions**:
1. Pipe to `head` or `tail`: `| head -20`
2. Filter output: `| grep pattern`
3. Suppress stderr: `2>/dev/null`
4. Limit output: `npm test 2>&1 | tail -50`

## Advanced Patterns

### Conditional Logic in Prompt

```markdown
---
argument-hint: <file-path>
---

@$1

If this file is a TypeScript file:
- Check types and interfaces
- Verify strict mode compliance

If this file is a test file:
- Check test coverage
- Verify assertions

Otherwise:
- General code review
```

### Chaining Information

```markdown
---
allowed-tools: Bash(git:*), Read
---

Recent commits:
!`git log --oneline -10`

Changed files:
!`git diff --name-only HEAD~5`

For each changed file, analyze impact and suggest improvements.
```

### Multi-Step Workflow

```markdown
Step 1 - Gather context:
!`git status -s`
@package.json

Step 2 - Run tests:
!`npm test 2>&1 | tail -30`

Step 3 - Based on test results, suggest specific fixes with code examples.
```

## Plugin and MCP Commands

**Plugin commands**: May follow pattern `/plugin:command`

**MCP commands**: Follow pattern `/mcp__<server>__<prompt>`

These are provided by plugins/MCP servers, not custom user commands.

## Slash Commands vs. Skills

| Feature | Slash Commands | Skills |
|---------|---------------|--------|
| Complexity | Simple prompts | Complex workflows |
| File count | Single .md file | Multiple resources |
| Parameters | $ARGUMENTS, $1-$9 | Full JSON config |
| Discovery | Manual invocation | Automatic activation |
| Best for | Quick shortcuts | Sophisticated tasks |
| Learning curve | Low | Higher |

**Use slash commands** for:
- Repetitive prompts
- Git workflows
- Quick checks
- Team conventions

**Use Skills** for:
- Multi-step processes
- Complex logic
- Automatic discovery
- Reusable components
