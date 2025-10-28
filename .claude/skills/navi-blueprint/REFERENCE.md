# Flow Blueprint Reference

## Complete Blueprint Template

See `__specification__/templates/architecture-blueprint-template.md` for full template.

## ADR Format

```markdown
### ADR-001: [Decision Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Context**: What problem are we solving?
**Decision**: What did we decide?
**Rationale**: Why this choice?
**Consequences**:
  - Positive: [Benefits]
  - Negative: [Trade-offs]
**Alternatives Considered**:
  1. [Option]: [Why rejected]
```

## Command-Line Options

### `--extract`

Extract blueprint from existing codebase.

**Process**:
1. Scan directory structure
2. Analyze package.json/requirements.txt/etc.
3. Identify frameworks and patterns
4. Generate blueprint from discoveries

### `--update`

Update existing blueprint.

**Interactive prompts**:
- What changed?
- Add new principle/guideline?
- Add new ADR?
- Update technology stack?

**Version incrementation**:
- MAJOR: Architecture pattern changed
- MINOR: New guideline added
- PATCH: Clarification/wording fix

## Versioning Guidelines

**When to increment**:

**MAJOR (1.0.0 → 2.0.0)**:
- Monolith → Microservices
- SQL → NoSQL migration
- Complete framework change

**MINOR (1.0.0 → 1.1.0)**:
- Add new principle
- Add API guideline
- Adopt additional technology

**PATCH (1.0.0 → 1.0.1)**:
- Fix typos
- Clarify existing guideline
- Update examples

## Governance Models

**Solo Developer**:
```markdown
## Governance
- Amendment: As needed, document in ADR
- Review: Self-review before commit
```

**Small Team**:
```markdown
## Governance
- Amendment: Team consensus required
- Review: Tech lead approval
- Frequency: Quarterly review
```

**Enterprise**:
```markdown
## Governance
- Amendment: Architecture Review Board approval
- Review: Quarterly mandatory review
- Documentation: All changes require ADR
- Communication: Announce via email + wiki
```

## Integration Patterns

**With flow:init**:
```bash
flow:init               # Creates skeleton
flow:blueprint          # Populates with decisions
```

**With flow:specify**:
```javascript
// Skill reads blueprint for context
const blueprint = readBlueprint();
if (blueprint.apiGuidelines) {
  // Apply versioning strategy to spec
}
```

**With flow:plan**:
```javascript
// Validate plan against blueprint
const blueprint = readBlueprint();
if (plan.usesREST && blueprint.requiresGraphQL) {
  // Ask user for approval to deviate
}
```

## Flat Peer Model

Blueprint is a **peer artifact** in `__specification__/`:
- Not hierarchically enforced
- Features CAN reference for guidance
- Deviations require user approval + documentation
- Manual consistency checks

**Tools help detect drift**:
```bash
flow:analyze  # Checks spec/plan alignment with blueprint
```

## Related Files

- `__specification__/architecture.md`: The blueprint
- `__specification__/templates/architecture-blueprint-template.md`: Template
- `CLAUDE.md`: References blueprint in Flow Configuration

## Troubleshooting

**Extract fails**: Ensure codebase has standard structure
**Version conflicts**: Manually set version in blueprint
**ADR numbering**: Sequential, don't skip numbers

## Best Practices

1. **Start simple**: Don't over-architect initially
2. **Document decisions**: Always add ADR for major choices
3. **Review regularly**: Quarterly for active projects
4. **Keep current**: Update when architecture changes
5. **Share widely**: Ensure team knows blueprint exists
