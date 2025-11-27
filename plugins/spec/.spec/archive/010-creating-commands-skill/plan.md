# Technical Plan: Slash Command Creation Skill

## Architecture

The skill follows the established skill pattern used by `creating-skills` and `creating-hooks`:
- Main `SKILL.md` with workflow and quick reference
- `reference.md` for detailed best practices
- `templates/` directory for reusable command templates

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Main skill file with workflow steps | None |
| reference.md | Detailed command format, arguments, patterns | SKILL.md |
| templates/basic.md | Simple command template | reference.md |
| templates/with-args.md | Command with argument handling | reference.md |
| templates/workflow.md | Multi-step command with skill/agent integration | reference.md |

## Skill Structure

```
.claude/skills/creating-commands/
├── SKILL.md              # Main entry point (~150 lines)
├── reference.md          # Detailed best practices (~100 lines)
└── templates/
    ├── basic.md          # Simple command
    ├── with-args.md      # Arguments handling
    └── workflow.md       # Skill/agent integration
```

## Content Design

### SKILL.md Sections

1. **Frontmatter** - name, description with trigger words
2. **Quick Start** - 3-step summary for new/review
3. **Workflow** - Step-by-step command creation
4. **Naming Rules** - Format and constraints
5. **Description Best Practices** - When commands appear
6. **Argument Syntax** - $ARGUMENTS, $1, $2, etc.
7. **Example** - Complete basic command

### reference.md Sections

1. **Command File Format** - Full markdown structure
2. **Frontmatter Options** - description, allowed-tools
3. **Argument Patterns** - Positional vs full string
4. **Integration Patterns** - Skills, agents, hooks
5. **Anti-Patterns** - Common mistakes
6. **Validation Checklist** - Pre-save checks

### Template Content

Each template includes:
- Frontmatter with placeholders
- Command prompt structure
- Comments explaining each section
- Example usage

## Implementation Phases

1. **Phase 1: Core Skill** - SKILL.md with workflow and validation
2. **Phase 2: Reference** - Detailed documentation in reference.md
3. **Phase 3: Templates** - All three template files

## Integration Points

- Follows same structure as `creating-skills` and `creating-hooks`
- Can reference existing command examples in `.claude/commands/`
- Works with `orbit-workflow` skill for project commands

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Overlap with creating-skills | Confusion | Clear scope distinction in descriptions |
| Command format changes | Outdated skill | Use official docs as source of truth |
| Template too complex | User confusion | Keep templates minimal, add comments |
