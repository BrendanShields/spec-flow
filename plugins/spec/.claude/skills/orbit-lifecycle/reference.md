# Orbit Lifecycle Reference

Migrated highlights from `docs/patterns/workflow-patterns.md`, `state-management.md`, and `integration-patterns.md` so the skill stays self-contained.

## State System
```
Project Root/
├── {config.paths.spec_root}/
│   ├── architecture/
│   │   ├── architecture.md
│   │   └── architecture-decision-record.md
│   ├── archive/
│   │   └── history.md
│   ├── memory/
│   │   └── activity-log.md
│   ├── state/
│   │   ├── session.json
│   │   └── auto-mode-session.json
│   └── features/{id}-{slug}/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
```
- **Session state** (`state/session.json`) tracks the active feature, phase, timestamps, and next recommended action.
- **Memory** (`memory/activity-log.md`) stores append-only event lines for hooks and commands.
- **History** (`archive/history.md`) aggregates rich summaries, subagent notes, and checklists (hooks append blocks automatically).
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
  3. Store the issue key in the spec metadata and append a line to `.spec/memory/activity-log.md` for history.
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
- `templates/state/activity-log.md` – seeded header for append-only activity lines.
- `templates/state/history.md` – starter page for hook-written session summaries.
- `templates/state/architecture-decision-record.md` – ADR skeleton (Context → Decision → Consequences).

## Scripts
- `init_state.sh` – idempotent creation of directories/files, `.gitignore` update, config bootstrap.
- `tdd_cycle.sh` – functions for `begin_task`, `record_test_run`, `finish_task`, and `update_task_completion` (mirrors the content from the previous `implementing-features` instructions).
- `update_state.sh` – helper to recompute phase metadata + `next-step.json` when hooks are unavailable.

## Troubleshooting
- **State missing** – rerun `scripts/init_state.sh`.
- **Hooks skipped** – call `scripts/update_state.sh phase=<phase> feature=<id>`.
- **Checklist failure** – re-run `specification-analyzer`; append blockers into `archive/history.md` so hooks keep the authoritative record.
- **MCP auth errors** – fall back to local files, instruct user to update credentials.
