# Technical Plan: .NET Best Practices Skill

## Architecture

The skill follows Claude's progressive disclosure pattern with a concise main file and detailed reference files. No scripts required - all guidance is declarative.

```
.claude/skills/reviewing-dotnet-code/
├── SKILL.md        # Main instructions (<500 lines)
├── REFERENCE.md    # Detailed naming & style rules
└── EXAMPLES.md     # Before/after code samples
```

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Core workflow, quick reference, triggers | None |
| REFERENCE.md | Comprehensive naming conventions, patterns | SKILL.md links here |
| EXAMPLES.md | Concrete before/after code samples | SKILL.md links here |

## SKILL.md Structure

```markdown
---
name: reviewing-dotnet-code
description: Reviews and generates .NET/C# code following Microsoft conventions.
             Use when reviewing C# files, writing .NET code, or refactoring.
tools:
  - Read
  - Edit
  - Grep
---

# Reviewing .NET Code

## Quick Reference (inline - most common rules)
## Workflow (review steps)
## When to Read Reference Files
## Anti-Patterns to Flag
```

## REFERENCE.md Structure

- Naming Conventions (detailed PascalCase/camelCase rules)
- Type Design Guidelines
- Member Design Guidelines
- Exception Handling Rules
- Async/Await Patterns
- LINQ Best Practices
- Modern C# Features

## EXAMPLES.md Structure

- Input/output pairs for each category
- Before/after refactoring samples
- Common mistakes and fixes

## Key Design Decisions

1. **Gerund naming** (`reviewing-dotnet-code`) per skill best practices
2. **No scripts** - purely declarative guidance
3. **Inline quick reference** - most common rules in SKILL.md
4. **Progressive disclosure** - detailed rules in REFERENCE.md
5. **Concrete examples** - in EXAMPLES.md, not scattered throughout

## Implementation Phases

1. **Phase 1**: Create SKILL.md with core workflow and quick reference
2. **Phase 2**: Create REFERENCE.md with comprehensive rules
3. **Phase 3**: Create EXAMPLES.md with code samples

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| SKILL.md exceeds 500 lines | Performance degradation | Move details to REFERENCE.md |
| Rules conflict with project conventions | Confusion | Add "escape hatch" for .editorconfig |
| Missing modern C# features | Outdated guidance | Focus on C# 10+ patterns |
