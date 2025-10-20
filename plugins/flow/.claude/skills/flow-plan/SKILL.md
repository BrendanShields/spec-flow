---
name: flow:plan
description: Generate technical implementation plans with architecture decisions, technology evaluation, and design artifacts using AI-powered research.
---

# Flow Plan: Technical Planning

Create comprehensive implementation plans with architecture decisions and technical design.

## What This Skill Does

1. Loads specification from `spec.md`
2. **Researches** technical decisions using `flow-researcher` subagent
3. Generates implementation plan with:
   - Architecture patterns
   - Technology stack recommendations
   - Data model design
   - API contracts
   - Integration patterns
4. Validates against project constitution
5. Updates agent context files

## Execution Phases

### Phase 0: Research & Decisions
- Resolve technical unknowns
- Evaluate technology alternatives
- Document decisions in `research.md`
- Create Architecture Decision Records (ADRs)

### Phase 1: Design & Contracts
- Generate `data-model.md` with entities
- Create API contracts in `contracts/`
- Write `quickstart.md` for testing

## Output Artifacts

- `plan.md` - Main implementation plan
- `research.md` - Technical research and decisions
- `data-model.md` - Entity definitions
- `contracts/` - API specifications
- `quickstart.md` - Test scenarios

## Subagents Used

- **flow-researcher**: Researches best practices and evaluates alternatives
- **flow-analyzer**: Analyzes existing code for brownfield projects