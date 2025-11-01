---
name: subagents
description: Create and configure Claude Code subagents (specialized AI assistants with dedicated expertise). Use when: 1) User asks to create/configure a subagent or agent, 2) User mentions "subagent", "specialized agent", or task delegation, 3) User wants code review, debugging, testing, or specialized workflows, 4) User needs isolated context for specific tasks, 5) User wants to automate complex multi-step processes. Generates subagent configurations with best practices. (project)
---

# Claude Code Subagents Skill

Create, configure, and manage Claude Code subagents - specialized AI assistants with dedicated expertise and isolated context.

## Core Concepts

**Subagents** are pre-configured AI personalities that Claude Code can delegate tasks to. Each operates independently with:
- Own context window (prevents main conversation pollution)
- Custom system prompt (specialized expertise)
- Configurable tool access (security & focus)
- Reusability across projects

## Workflow

### 1. Understand Requirements

Ask user:
```javascript
{
  "name": "identifier-name",
  "purpose": "What specialized task?",
  "expertise": "Domain knowledge needed",
  "tools": ["Bash", "Read", "Edit", "Grep"],  // Which tools to allow
  "model": "sonnet|opus|haiku",  // Optional
  "scope": "project|user",  // .claude/agents/ or ~/.claude/agents/
  "activation": "proactive|explicit"  // Auto-delegate or manual invoke
}
```

### 2. Review Examples

Load inspiration from example subagents:
```bash
cat EXAMPLES.md  # Code reviewer, debugger, test-runner, etc.
```

### 3. Generate Subagent Configuration

Create Markdown file with YAML frontmatter:

**File location**:
- Project: `.claude/agents/{name}.md`
- User: `~/.claude/agents/{name}.md`

**Structure**:
```markdown
---
name: identifier-name
description: Clear purpose statement for auto-discovery
tools: Read, Grep, Bash  # Optional, defaults to all tools
model: sonnet  # Optional, defaults to sonnet
---

# System Prompt

Detailed instructions for the subagent:
- What is its role?
- What expertise does it have?
- How should it approach tasks?
- What output format should it use?
- What are the quality standards?

[Include specific examples and patterns]
```

Refer to template patterns in `REFERENCE.md`.

### 4. Optimize for Discovery

**For proactive activation**, include in description:
- "Use PROACTIVELY when..."
- Clear trigger conditions
- Specific keywords to match

**For explicit invocation**, make purpose very clear:
- "Specialized for..."
- Detailed capability description

### 5. Test Subagent

Provide test invocation:
```bash
# Explicit invocation
"Use the {name} subagent to {task}"

# Should auto-delegate (if proactive)
"I need to {task that matches description}"
```

### 6. Iterate and Refine

After testing:
- Adjust system prompt clarity
- Refine tool permissions
- Update description triggers
- Add examples to prompt

## Common Subagent Patterns

Load pattern library:
```bash
cat REFERENCE.md  # Subagent patterns and best practices
cat EXAMPLES.md   # Real-world subagent configurations
```

**Quick patterns**:
1. **Code reviewer**: Read, Grep → analyze quality, security, best practices
2. **Debugger**: Read, Grep, Bash → root cause analysis
3. **Test runner**: Bash, Read → run tests, analyze failures, suggest fixes
4. **Documentation writer**: Read, Grep, Write → generate/update docs
5. **Refactoring specialist**: Read, Edit → improve code structure
6. **Security auditor**: Read, Grep → find vulnerabilities
7. **Performance optimizer**: Read, Bash → profile and optimize

## Tool Permissions

**Security principle**: Grant only necessary tools

**Tool categories**:
- **Read-only**: Read, Grep, Glob (safest)
- **Write operations**: Write, Edit (moderate risk)
- **Execution**: Bash, NotebookEdit (requires trust)
- **All tools**: `*` (use sparingly)

Refer to security guidelines in `REFERENCE.md`.

## Output Format

After creating subagent:
```
✅ Subagent created: {name}
📄 Location: {file-path}
🎯 Purpose: {one-line description}
🔧 Tools: {tool-list}
🤖 Model: {model}
🚀 Activation: {proactive|explicit}

🧪 Test with:
  "{example invocation}"

💡 Tips:
  - Use "/agents" to view all configured agents
  - Add "use PROACTIVELY" to description for auto-delegation
  - Iterate on system prompt for better results
```

## Resources

- `EXAMPLES.md` - Real-world subagent configurations (reviewer, debugger, tester)
- `REFERENCE.md` - Complete patterns, best practices, troubleshooting
- `templates/` - Pre-built subagent templates
- `scripts/validate-agent.sh` - Subagent configuration validator

## Remember

- Design focused subagents (single responsibility)
- Write detailed system prompts (specific instructions)
- Limit tool access (security and focus)
- Version control project agents (team collaboration)
- Start with Claude generation, then iterate
- Use `/agents` command to view configured agents
