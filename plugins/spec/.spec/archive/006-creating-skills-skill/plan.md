# Technical Plan: Skill Creation Best Practices Skill

## Architecture

The skill uses progressive disclosure to minimize context usage:
- SKILL.md: Overview, workflow, quick reference (~200 lines)
- reference.md: Detailed best practices and anti-patterns
- templates/: Ready-to-use skill templates

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Main entry, workflow, validation checklist | None |
| reference.md | Detailed guidelines, examples | SKILL.md references |
| templates/basic.md | Simple skill template | None |
| templates/advanced.md | Multi-file skill template | None |
| scripts/validate.sh | Validates skill structure | None |

## Skill Behavior

### Create New Skill Flow
1. Ask user for skill purpose and domain
2. Determine complexity (basic vs advanced)
3. Generate skill directory with appropriate template
4. Guide user through customization
5. Validate against best practices

### Review Existing Skill Flow
1. Read SKILL.md and supporting files
2. Check against anti-patterns
3. Validate frontmatter
4. Measure line count
5. Report issues with fixes

## Implementation Phases

1. **Phase 1**: Core SKILL.md with workflow and checklist
2. **Phase 2**: Reference documentation with examples
3. **Phase 3**: Templates and validation script

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skill too large | Poor activation | Keep SKILL.md under 300 lines |
| Too prescriptive | Limits creativity | Provide options, not mandates |
| Outdated practices | Wrong guidance | Link to official docs |
