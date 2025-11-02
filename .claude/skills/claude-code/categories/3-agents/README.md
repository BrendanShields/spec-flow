# Category 3: Subagents

Create and configure Claude Code subagents - specialized AI assistants with dedicated expertise and isolated context.

## Purpose

Subagents enable task delegation to specialized AI personalities that operate independently with their own context windows, custom prompts, and tool access. This category helps you design, configure, and deploy subagents.

## Available Functions

### agent-builder/ 🔧 BUILDER
**Purpose**: Create and configure subagents
**When**: Need specialized expertise, code review, debugging, testing, isolated context
**Duration**: 20-60 minutes
**Output**: Subagent configuration file in `.claude/agents/`

**Usage**: Run when you need dedicated AI assistance for specific tasks

## What Are Subagents?

**Subagents** are pre-configured AI personalities with:
- **Isolated context**: Own conversation history, prevents main context pollution
- **Custom system prompt**: Specialized expertise and behavior
- **Configurable tools**: Specific tool access for security and focus
- **Model selection**: Choose sonnet/opus/haiku based on task complexity
- **Activation patterns**: Proactive (auto-delegate) or explicit (manual invoke)

## Workflow Pattern

```
Need specialized task → agent-builder/ 🔧 → Test → Deploy
```

## Subagent Structure

Configuration file with YAML frontmatter:
```markdown
---
name: agent-name
description: When and why to use this agent
model: sonnet
allowed-tools: ["Read", "Edit", "Bash"]
---

# Agent System Prompt

You are a specialized assistant for [domain].
Your expertise includes...

## Your Responsibilities
- Task 1
- Task 2

## Your Constraints
- Don't do X
- Always do Y
```

## Key Concepts

### Context Isolation
Each subagent has its own conversation:
- Prevents context window pollution
- Enables parallel work
- Maintains focus on specific task

### Tool Access Control
Limit tools for security and focus:
- Code reviewer: Read, Grep (no Write)
- Debugger: Read, Bash, Edit
- Test runner: Bash, Read

### Model Selection
Choose appropriate model:
- **Haiku**: Fast, simple tasks (formatting, simple analysis)
- **Sonnet**: Balanced, most tasks (code review, refactoring)
- **Opus**: Complex reasoning (architecture design, debugging)

### Activation Patterns
- **Proactive**: Claude automatically delegates matching tasks
- **Explicit**: User manually invokes with command

## Use Cases

### Code Review
Dedicated reviewer with focus on:
- Code quality and best practices
- Security vulnerabilities
- Performance issues
- Documentation gaps

### Debugging
Specialized debugger that:
- Analyzes stack traces
- Tests hypotheses systematically
- Suggests fixes with explanations

### Test Generation
Test-focused agent that:
- Generates comprehensive test suites
- Covers edge cases
- Follows testing patterns

### Refactoring
Code improvement specialist:
- Identifies code smells
- Suggests design patterns
- Maintains behavior while improving structure

## Best Practices
- ✅ Single expertise domain per agent
- ✅ Clear activation triggers
- ✅ Minimal tool permissions
- ✅ Detailed system prompts
- ✅ Expected output format

## Templates

See `templates/agents/` for examples:
- code-reviewer.md - Code quality review agent
- debugger.md - Systematic debugging assistant
- test-runner.md - Test execution and analysis

## Navigation

**Create agent**: See `agent-builder/guide.md`
**See examples**: See `agent-builder/examples.md`
**Full reference**: See `agent-builder/reference.md`

---

🔧 = Builder tool (create/manage)
