# Technical Plan: Agent Creation Best Practices Skill

## Architecture

Following the same progressive disclosure pattern:
- SKILL.md: Overview, workflow, quick reference (~180 lines)
- reference.md: Complete configuration details, all fields
- templates/: Ready-to-use agent templates

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Main entry, workflow, agent type comparison | None |
| reference.md | All config fields, tool lists, model options | SKILL.md references |
| templates/reviewer.md | Code review agent template | None |
| templates/researcher.md | Read-only research agent | None |
| templates/specialist.md | Domain expert template | None |

## Design Decisions

### Focus on Custom Agents

Built-in agents (general-purpose, plan, explore) are well-documented. Focus on:
- When to create custom agents
- How to write effective system prompts
- Tool selection principles

### Template Categories

Three common patterns:
1. **Reviewer**: Read-only analysis, feedback generation
2. **Researcher**: Codebase exploration, documentation
3. **Specialist**: Domain-specific tasks (testing, security, etc.)

### Model Selection Guidance

| Task Type | Recommended Model | Reason |
|-----------|-------------------|--------|
| Complex reasoning | opus | Best for nuanced decisions |
| General tasks | sonnet (inherit) | Good balance |
| Quick lookups | haiku | Fast, cost-effective |

## Implementation Phases

1. **Phase 1**: Core SKILL.md with workflow and comparison tables
2. **Phase 2**: Reference documentation with all fields
3. **Phase 3**: Agent templates

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-complicated prompts | Poor agent behavior | Provide simple, focused examples |
| Wrong tool selection | Security/capability issues | Clear guidance on minimal tools |
