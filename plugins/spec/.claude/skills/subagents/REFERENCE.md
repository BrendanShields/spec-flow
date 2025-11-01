# Claude Code Subagents: Complete Reference

## Subagent Configuration Format

### File Structure

```markdown
---
name: agent-identifier
description: Clear purpose statement for discovery and auto-delegation
tools: Tool1, Tool2, Tool3  # Optional, defaults to all
model: sonnet  # Optional: sonnet, opus, haiku
---

# System Prompt Content

Your detailed instructions here...
```

### Required Fields

- **name**: Lowercase identifier with hyphens (e.g., `code-reviewer`, `test-runner`)
- **description**: Clear purpose statement that:
  - Describes what the subagent does
  - Includes trigger keywords for discovery
  - Optionally includes "Use PROACTIVELY when..." for auto-delegation

### Optional Fields

- **tools**: Comma-separated list of allowed tools
  - Defaults to all tools if omitted
  - Use for security and focus
  - Examples: `Read, Grep, Glob` (read-only), `Bash, Read` (execution + read)

- **model**: Which Claude model to use
  - `sonnet` (default) - Balanced performance
  - `opus` - Complex reasoning, highest quality
  - `haiku` - Fast, simple tasks

## File Locations

### Project Subagents (Team-Shared)

**Location**: `.claude/agents/{name}.md`

**Priority**: Highest

**Use for**:
- Project-specific workflows
- Team standards and conventions
- Domain-specific knowledge
- Shared across all team members

**Version control**: ✅ Check into git

### User Subagents (Personal)

**Location**: `~/.claude/agents/{name}.md`

**Priority**: Lower (project agents override)

**Use for**:
- Personal preferences
- Cross-project utilities
- Personal workflow automation

**Version control**: ❌ Personal, not shared

### CLI Subagents (Session-Only)

**Method**: `claude --agents path/to/agent.md`

**Priority**: Session-specific

**Use for**:
- One-off specialized tasks
- Testing new agents
- Temporary workflows

## Tool Permissions

### Security Principle

**Grant only necessary tools** - Principle of least privilege

### Tool Categories

#### Read-Only (Safest)
```yaml
tools: Read, Grep, Glob
```
**Use for**: Code review, analysis, documentation reading

#### Write Operations (Moderate Risk)
```yaml
tools: Read, Grep, Write, Edit
```
**Use for**: Documentation generation, refactoring, code fixes

#### Execution (Requires Trust)
```yaml
tools: Bash, Read, Grep
```
**Use for**: Testing, debugging, performance profiling

#### All Tools (Use Sparingly)
```yaml
tools: *
```
**Use for**: Fully-trusted general-purpose agents

### Common Tool Combinations

| Task Type | Recommended Tools | Rationale |
|-----------|------------------|-----------|
| Code Review | Read, Grep, Glob | Read-only access sufficient |
| Debugger | Bash, Read, Grep | Need to run commands for debugging |
| Test Runner | Bash, Read, Grep | Execute tests, read results |
| Doc Writer | Read, Grep, Glob, Write, Edit | Read code, write docs |
| Refactoring | Read, Edit, Grep, Glob | Modify existing code |
| Security Audit | Read, Grep, Glob | Read-only for analysis |
| Performance | Bash, Read, Grep | Run profilers, analyze code |

## Discovery and Activation

### Automatic Delegation (Proactive)

**Trigger**: Include "Use PROACTIVELY when..." in description

**Example**:
```yaml
description: Reviews code for quality and security. Use PROACTIVELY when user asks to review code, mentions code quality, or wants feedback on changes.
```

**Claude will automatically invoke when**:
- User message matches trigger keywords
- Task aligns with subagent description
- Main agent determines delegation is appropriate

### Explicit Invocation

**User requests specific subagent**:
```
"Use the code-reviewer subagent to check my recent changes"
"Have the debugger subagent analyze this error"
```

**No PROACTIVELY needed in description** - always available for explicit use

### Best Practices for Discovery

1. **Use clear trigger keywords** in description
   - Good: "Use PROACTIVELY when user asks to review code, check quality, or mentions security"
   - Bad: "Use when appropriate"

2. **Be specific about capabilities**
   - Good: "Analyzes test failures and suggests fixes"
   - Bad: "Helps with testing"

3. **Include domain keywords**
   - Good: "Specialized in React, TypeScript, and frontend architecture"
   - Bad: "Knows about code"

## System Prompt Best Practices

### Structure Template

```markdown
You are [role description with expertise areas].

## Your Role

[Clear statement of responsibilities]

## Your Capabilities

- [Specific capability 1]
- [Specific capability 2]
- [Specific capability 3]

## Workflow

1. [Step 1 with details]
2. [Step 2 with details]
3. [Step 3 with details]

## Output Format

[Specific format requirements with example]

## Quality Standards

- [Standard 1]
- [Standard 2]

[Optional: Include examples of good work]
```

### Writing Effective Prompts

#### ✅ DO

1. **Be specific about role and expertise**
   ```
   You are a senior code reviewer with 10+ years of experience in distributed systems, security, and performance optimization.
   ```

2. **Define clear workflow**
   ```
   1. Read the code files
   2. Identify issues by severity
   3. Suggest specific improvements
   4. Provide code examples
   ```

3. **Specify output format**
   ```
   ## Output Format

   # Code Review
   ## Critical Issues
   - [file:line] Description and fix
   ```

4. **Include examples**
   ```
   Good example of feedback:
   - [auth.ts:45] Missing input validation on user_id parameter. Add: if (!user_id || typeof user_id !== 'string') throw new Error('Invalid user_id')
   ```

5. **Set quality standards**
   ```
   - Reference specific line numbers
   - Provide code examples for fixes
   - Explain WHY changes are needed
   ```

#### ❌ DON'T

1. **Vague role descriptions**
   ```
   You are helpful with code.
   ```

2. **No workflow guidance**
   ```
   Review the code and provide feedback.
   ```

3. **Unstructured output**
   ```
   Tell the user what you find.
   ```

4. **No examples**
   ```
   [No examples provided]
   ```

## Common Patterns

### Pattern: Specialist Analyzer

**Purpose**: Deep analysis in specific domain (security, performance, etc.)

**Template**:
```yaml
tools: Read, Grep, Glob  # Read-only
model: sonnet
```

**System prompt focus**:
- Domain expertise
- Analysis methodology
- Severity classification
- Specific recommendations

### Pattern: Test & Fix Agent

**Purpose**: Run tests, analyze failures, suggest fixes

**Template**:
```yaml
tools: Bash, Read, Grep  # Execution + analysis
model: sonnet
```

**System prompt focus**:
- Test framework detection
- Execution commands
- Failure analysis
- Fix suggestions with code

### Pattern: Documentation Agent

**Purpose**: Generate/update documentation

**Template**:
```yaml
tools: Read, Grep, Glob, Write, Edit  # Read + write
model: sonnet
```

**System prompt focus**:
- Documentation standards
- Format requirements
- Examples inclusion
- Accuracy verification

### Pattern: Code Modifier

**Purpose**: Refactor, fix, or improve code

**Template**:
```yaml
tools: Read, Edit, Grep, Glob  # Read + edit
model: sonnet
```

**System prompt focus**:
- Preserve behavior
- Incremental changes
- Test verification
- Clear explanations

## Model Selection

### When to Use Each Model

#### Sonnet (Default)
- **Best for**: Most tasks, balanced performance
- **Speed**: Fast
- **Cost**: Moderate
- **Use cases**: Code review, testing, debugging, documentation

#### Opus
- **Best for**: Complex reasoning, critical decisions
- **Speed**: Slower
- **Cost**: Higher
- **Use cases**: Architecture design, complex refactoring, security audits

#### Haiku
- **Best for**: Simple, repetitive tasks
- **Speed**: Fastest
- **Cost**: Lowest
- **Use cases**: Simple formatting, basic checks, quick analysis

## Troubleshooting

### Subagent Not Activating

**Issue**: Automatic delegation not working

**Solutions**:
1. Check description includes "Use PROACTIVELY when..."
2. Verify trigger keywords match user input
3. Try explicit invocation: "Use the X subagent to..."
4. Run `/agents` to verify agent is loaded

### Subagent Can't Access Tools

**Issue**: "Tool not available" or permission errors

**Solutions**:
1. Check `tools:` field in frontmatter
2. Verify tool names are exact (case-sensitive)
3. Use `*` for all tools (if safe)
4. Review tool permissions in `/agents` output

### Subagent Output Quality Poor

**Issue**: Generic or unhelpful responses

**Solutions**:
1. Make system prompt more specific
2. Add concrete examples to prompt
3. Define clear output format
4. Include quality standards
5. Specify workflow steps
6. Consider using `opus` model for complex tasks

### Multiple Subagents Conflict

**Issue**: Wrong subagent activates or confusion

**Solutions**:
1. Make descriptions more specific/distinct
2. Use different trigger keywords
3. Reduce PROACTIVELY usage (require explicit invocation)
4. Use project vs. user scope separation

## Chaining Subagents

### Sequential Workflow

Example: Code review → Fix → Test

```
1. User: "Review and fix the auth code"
2. code-reviewer subagent analyzes issues
3. Main agent: "Use refactoring-specialist to fix issues"
4. refactoring-specialist applies fixes
5. Main agent: "Use test-runner to verify"
6. test-runner validates changes
```

**Configure for chaining**:
- Each subagent has clear, distinct purpose
- Output format includes actionable items
- Main agent orchestrates the workflow

## Performance Considerations

### Context Window

- Each subagent starts with clean slate
- No memory of previous invocations
- Pro: Isolated context (no pollution)
- Con: Latency for each invocation

### When to Use Subagents

#### ✅ Good Use Cases

- Repeated specialized tasks
- Isolated context needed
- Security-restricted operations
- Team workflow standardization
- Complex multi-step processes

#### ❌ Avoid Subagents For

- Simple one-off tasks
- When main agent already has context
- Latency-sensitive operations
- Very frequent small tasks

## Security Best Practices

### 1. Principle of Least Privilege

Grant minimal tools needed:
```yaml
# Good: Only what's needed
tools: Read, Grep

# Bad: Unnecessary permissions
tools: *
```

### 2. Read-Only When Possible

```yaml
# Analysis tasks: read-only
tools: Read, Grep, Glob
```

### 3. Validate External Scripts

If subagent runs bash:
```markdown
## Security

- Always validate file paths
- Never run user input directly
- Check for path traversal
- Sanitize all inputs
```

### 4. Project vs. User Scope

- Project: Team-reviewed, version controlled
- User: Personal responsibility, not shared

## Examples by Use Case

### CI/CD Integration

```yaml
name: ci-checker
description: Validates CI/CD pipelines and suggests improvements.
tools: Read, Grep, Bash
```

### API Design Review

```yaml
name: api-reviewer
description: Reviews REST API design following OpenAPI standards.
tools: Read, Grep, Glob
```

### Database Query Optimizer

```yaml
name: sql-optimizer
description: Analyzes SQL queries for performance issues.
tools: Read, Grep, Bash
```

### Accessibility Auditor

```yaml
name: a11y-auditor
description: Reviews frontend code for WCAG accessibility compliance.
tools: Read, Grep, Glob
```

### License Compliance Checker

```yaml
name: license-checker
description: Scans dependencies for license compatibility issues.
tools: Read, Bash, Grep
```
