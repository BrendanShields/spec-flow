---
name: orbit-planning
description: Consolidates architecture, technical planning, task breakdown, and consistency validation into one Orbit skill with embedded templates/scripts. Use whenever `/orbit` enters design/planning, the user asks for blueprints/tasks, or `/orbit-track` requests validations before implementation.
allowed-tools: [Read, Write, Edit, AskUserQuestion, Bash, Skill]
---

# Orbit Planning

Replaces the individual architecture/plan/task/consistency skills while keeping their functionality intact.

## When to Invoke
- `/orbit` or Orbit Lifecycle escalates to "Plan" or "Tasks".
- User requests "draft architecture", "create technical plan", "break into tasks", or "validate consistency".
- Feature updates require re-planning or spec-plan drift checks.

## Intake Checklist
1. Confirm `{feature}` path exists and load `spec.md` + any prior `plan.md`/`tasks.md`.
2. Read `.spec/architecture/architecture.md` to honor standards; if missing, create via the Architecture branch.
3. Capture constraints (priority, deadlines, integration requirements, hooks) from `claude.md` or current session.
4. Decide which branch to run (Architecture, Plan, Tasks, Consistency) using AskUserQuestion.

## Branches

### 1. Architecture Blueprint
- Use AskUserQuestion to gather stack choices, non-functional requirements, and team constraints.
- Write `{config.paths.spec_root}/architecture/architecture.md` using the template in `templates/architecture-blueprint.md`.
- Record major choices in `architecture-decision-record.md`.
- Delegate deep research (libraries, compliance) to the `spec-researcher` agent when needed.

### 2. Technical Plan
- Read `spec.md` + architecture blueprint.
- Generate `{feature}/plan.md` using `templates/plan.md` (sections: System Architecture, Component Design, Data Models, API Contracts, Implementation Phases, Risks, ADRs).
- For library/stack questions, call `spec-researcher`.
- After writing, update workflow state (planning phase) via Orbit Lifecycle `scripts/update_state.sh`.

### 3. Task Breakdown
- Parse `plan.md` for implementation phases.
- Populate `{feature}/tasks.md` with atomic (1–4 h) tasks using `templates/tasks.md`.
- Include dependencies, estimates, priorities, and a Mermaid diagram if time allows (see `reference.md`).
- Suggest parallel execution groups and mark blockers.

### 4. Consistency Validation
- Run the `consistency-analyzer` subagent (Skill tool) with spec/plan/architecture inputs.
- Store the report as `{feature}/consistency-analysis.md` with PASS/FAIL status and action items.
- If FAIL, return actionable guidance and optionally rerun relevant branches after fixes.

## Templates & Scripts
- `templates/architecture-blueprint.md` – 8-section blueprint skeleton.
- `templates/plan.md` – the merged plan structure used by the retired `drafting-plan` skill.
- `templates/tasks.md` – task table + dependency notes + Mermaid placeholder.
- `scripts/plan_sections.sh` – helper for inserting sections with headings.
- `scripts/task_graph.sh` – simple generator that prints Mermaid syntax from dependency pairs.

## Deliverables
- Updated blueprint/plan/tasks files.
- ADR entries appended to `architecture-decision-record.md`.
- Consistency report with PASS/FAIL gating tasks.
- Summary message describing architecture decisions, plan highlights, critical path, and validation outcome.

Consult [reference.md](reference.md) for the migrated blueprint templates, ADR examples, dependency guidance, and command snippets previously stored in `/docs/patterns`.
