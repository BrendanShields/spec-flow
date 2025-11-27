# Technical Plan: Enforce Planning Phase in Workflow

## Problem Analysis

The `validate-phase.sh` script exists and correctly checks prerequisites, but:
1. The skill only says "IMPORTANT" - no actual enforcement
2. The "Implement" section jumps straight to delegation
3. No quick-plan option for simple features

## Architecture

Add enforcement at two levels:
1. **Skill language**: Change from recommendation to requirement
2. **Quick templates**: Make planning fast so it's not skipped

## Components

| Component | Purpose | Change Type |
|-----------|---------|-------------|
| SKILL.md | Add mandatory validation before implement | Edit |
| templates/quick-plan.md | Fast planning template | New |
| templates/quick-tasks.md | Minimal task template | New |

## Implementation Approach

### 1. Strengthen Skill Language

Current (weak):
```
**IMPORTANT**: Before any phase transition, validate prerequisites exist.
```

Proposed (strong):
```
## Phase Gates (MANDATORY)

You MUST call validate-phase.sh before ANY phase transition.
If validation returns `valid:false`, you MUST NOT proceed.
```

### 2. Add Validation to Implementation Section

Before delegating to `implementing-tasks` agent:
```bash
# REQUIRED: Validate before implementation
RESULT=$(bash .claude/skills/orbit-workflow/scripts/validate-phase.sh \
  ".spec/features/{feature}" "implementation")
if [[ $(echo "$RESULT" | jq -r '.valid') != "true" ]]; then
  echo "Cannot implement: $(echo "$RESULT" | jq -r '.suggestion')"
  # Stop and create missing artifact
fi
```

### 3. Quick Planning Templates

For simple features (single file changes, bug fixes):
- **quick-plan.md**: 1-page plan with architecture + tasks inline
- Removes need for separate tasks.md for small scope

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-engineering simple fixes | Friction | Quick templates reduce overhead |
| Breaking existing workflows | Confusion | Document migration path |

## Success Criteria

- [ ] Cannot reach "Implement" without plan.md + tasks.md
- [ ] Quick-plan template available for simple features
- [ ] Clear error messages when validation fails
