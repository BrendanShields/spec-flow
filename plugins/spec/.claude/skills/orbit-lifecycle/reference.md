# Orbit Lifecycle Reference

Migrated highlights from `docs/patterns/workflow-patterns.md`, `state-management.md`, and `integration-patterns.md` so the skill stays self-contained.

## State System
```
Project Root/
├── {config.paths.spec_root}/
│   ├── product-requirements.md
│   ├── architecture/
│   │   ├── architecture.md
│   │   └── architecture-decision-record.md
│   └── features/{id}-{slug}/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
├── {config.paths.state}/ (gitignored)
│   ├── current-session.md
│   ├── next-step.json
│   └── checkpoints/*.md
└── {config.paths.memory}/ (committed)
    ├── workflow-progress.md
    ├── changes-planned.md
    ├── changes-completed.md
    └── session-summary.md
```
- **Session state** tracks the active phase + checkpoints.
- **Memory** stores history for metrics, ADRs, and subagent summaries.
- Templates for these files live under `templates/state/` in this skill.

## Feature Lifecycle (Orbit View)
1. **Initialize** – bootstrap `.spec/` using `scripts/init_state.sh`.
2. **Specify** – write or update `spec.md`, prioritize P1/P2/P3, capture `[CLARIFY]` tags.
3. **Clarify** – ask ≤4 focused questions per cycle, update spec, log decisions.
4. **Quality Gate** – invoke `specification-analyzer` to generate checklists; target ≥90 % completion.
5. **Plan + Tasks** – hand off to `orbit-planning` (architecture → plan → tasks) and return here when implementation begins.
6. **Implement** – follow `scripts/tdd_cycle.sh` and, when delegated, the `spec-implementer` agent.
7. **Track** – summarize progress from memory/state, surface blockers, sync externally if necessary.

## MCP / External Sync Recipes
- **JIRA Story Creation**:
  1. Read `{feature}/spec.md`.
  2. Call `jira_create_issue` with summary + acceptance criteria.
  3. Store the issue key in the spec metadata + `workflow-progress.md`.
- **Confluence Plan Publishing**:
  1. Read `{feature}/plan.md`.
  2. Call `confluence_create_page` (title: `[Feature] Technical Plan`).
  3. Append the page URL to `architecture-decision-record.md`.
- **Linear Tasks**:
  1. Read `{feature}/tasks.md`.
  2. Call `linear_create_issue` for P1/P2 tasks.
  3. Record returned IDs inline in `tasks.md`.
- Always gate these recipes behind `SPEC_*_SYNC=enabled` flags in `claude.md`.

## Template Overview
- `templates/state/current-session.md` – frontmatter + sections for phase, tasks, checkpoints.
- `workflow-progress.md` – feature log table with phase timestamps.
- `changes-planned.md` / `changes-completed.md` – rolling change logs.
- `architecture-decision-record.md` – ADR skeleton (Context → Decision → Consequences).

## Scripts
- `init_state.sh` – idempotent creation of directories/files, `.gitignore` update, config bootstrap.
- `tdd_cycle.sh` – functions for `begin_task`, `record_test_run`, `finish_task`, and `update_task_completion` (mirrors the content from the previous `implementing-features` instructions).
- `update_state.sh` – helper to recompute phase metadata + `next-step.json` when hooks are unavailable.

## Troubleshooting
- **State missing** – rerun `scripts/init_state.sh`.
- **Hooks skipped** – call `scripts/update_state.sh phase=<phase> feature=<id>`.
- **Checklist failure** – re-run `specification-analyzer`; mark blockers in `current-session.md`.
- **MCP auth errors** – fall back to local files, instruct user to update credentials.
