# Category 1: Skills

Build and manage Claude Code skills - reusable AI capabilities that extend Claude's functionality.

## Purpose

Skills are the building blocks of Claude Code's extensibility. This category provides tools for creating, validating, and managing skills with proper structure, discovery optimization, and progressive disclosure.

## Available Functions

### skill-builder/ 🔧 BUILDER
**Purpose**: Create and improve Claude Code skills
**When**: Need to build new skill, improve discovery, fix activation patterns
**Duration**: 30-90 minutes
**Output**: SKILL.md with proper YAML frontmatter, examples.md, reference.md

**Usage**: Run when creating or refactoring skills - follows Claude Code best practices

## What Are Skills?

**Skills** are markdown files with YAML frontmatter that define:
- **Triggers**: When the skill activates
- **Capabilities**: What the skill can do
- **Tools**: Which Claude Code tools the skill can use
- **Scope**: Project-specific or user-global

## Workflow Pattern

```
Idea → skill-builder/ 🔧 → Validate → Test → Deploy
```

## Skill Structure

Each skill has 3 documentation levels:
- **SKILL.md** (~1,500 tokens) - Core implementation
- **examples.md** (~3,000 tokens) - Usage scenarios
- **reference.md** (~2,000 tokens) - Technical specs

## Key Concepts

### Discovery Optimization
Skills must be discoverable through:
- Clear, trigger-rich descriptions
- Keyword matching
- Context pattern recognition

### Progressive Disclosure
Load only what's needed:
1. SKILL.md (default, ~1,500 tokens)
2. examples.md (when patterns needed, +3,000 tokens)
3. reference.md (when specs needed, +2,000 tokens)

### Best Practices
- ✅ Single responsibility per skill
- ✅ Clear activation triggers
- ✅ Proper tool permissions
- ✅ Comprehensive examples
- ✅ Token-efficient structure

## Templates

See `templates/skills/` for:
- SKILL.md.template
- examples.md.template
- reference.md.template

## Navigation

**Build a skill**: See `skill-builder/guide.md`
**See examples**: See `skill-builder/examples.md`
**Full reference**: See `skill-builder/reference.md`

---

🔧 = Builder tool (create/manage)
