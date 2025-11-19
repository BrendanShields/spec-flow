---
name: orbit-lifecycle
description: Runs the end-to-end Orbit workflow (init → spec → clarify/validate → change control → implementation → progress tracking) with embedded templates/scripts so teams keep a single lifecycle skill instead of juggling separate phase guides. Triggers when the user is starting or resuming spec work, referencing specs/tasks/tests, or when `/orbit` recommends lifecycle actions.
allowed-tools: [Read, Write, Edit, Bash, AskUserQuestion, Skill]
---

# Orbit Lifecycle

Single skill that routes through every Orbit phase while keeping the functionality of the retired skills (`initializing-workflow`, `drafting-specifications`, `clarifying-specifications`, `analyzing-specifications`, `updating-specifications`, `implementing-features`, `monitoring-progress`).

## When to Invoke
- `/orbit` surfaced Initialize/Specify/Implement/Track in the UI.
- User says "start orbit", "draft spec", "clarify requirements", "update the spec", "implement tasks", or "show progress".
- Hooks or auto-mode warn about missing `.spec/` assets or incomplete implementation work.

## Intake Checklist
1. **Detect phase** – read `{config.paths.state}/current-session.md` and `.spec/state/next-step.json` when available. If absent, ask the user to pick a branch (Initialize/Define/Clarify/Update/Implement/Track).
2. **Confirm config** – ensure `.spec/.spec-config.yml` exists. Default to `.spec/` paths and prompt when overrides are needed.
3. **Load templates** – the old `/docs/patterns` content now lives in `templates/state/*.md` and [reference.md](reference.md). Read them before creating or repairing files.
4. **Check integrations** – scan `claude.md` for `SPEC_*_SYNC` flags so MCP sync recipes can be offered when relevant.
5. **Lean on hooks** – let `orbit-update-status`, `orbit-prefetch-next-step`, and `orbit-session-summary` maintain `current-session.md`, `next-step.json`, and metrics. Use `scripts/update_state.sh` instead of hand-editing when hooks need a nudge.

## Branches & Execution

### 1. Initialize Project
- Run `scripts/init_state.sh` to create directories and seed markdown from `templates/state/*.md`.
- Offer optional follow-ups (architecture blueprint, hook auto-detect) via AskUserQuestion.
- For brownfield repos, recommend invoking `orbit-planning` or `codebase-analyzer` next.

### 2. Define + Clarify Specification
- Ask for feature summary + priority, then create/update `{features}/{id}/spec.md` using the structure in reference.md §Specifications.
- Scan for `[CLARIFY]` or vague wording. Group the top four items and ask clarifying questions (include recommended answers + trade-offs) before editing.
- For quality gates, delegate to the `specification-analyzer` agent and store checklists under `{feature}/checklists/`.

### 3. Change Control / Updates
- When requirements shift mid-flight, read the existing spec/plan/tasks, apply edits with dated changelog entries, and log architecture decisions in `{config.paths.memory}/architecture/architecture-decision-record.md`.
- Prompt the user if downstream planning must run again (hand off to `orbit-planning`).

### 4. Implement & Track
- Load `{feature}/tasks.md`, pick the next ready task, and trigger `scripts/tdd_cycle.sh` to run the red/green/refactor flow (writes checkpoints, runs tests, updates tasks).
- Delegate deeper execution to the `spec-implementer` subagent when asked; sync state afterwards via `scripts/update_state.sh`.
- For `/spec-track` metrics, read `workflow-progress.md`, `changes-planned.md`, and `changes-completed.md`, then summarize velocity/blockers. Offer MCP sync using the playbooks in reference.md §Integrations.

### 5. Monitor Progress Only
- When the user just wants a status update, skip edits and generate the dashboard from memory/state files. Highlight overdue checkpoints, active blockers, and CTA (Resume Orbit, Enter Auto Mode, etc.).

## Templates & Scripts
- **Templates** – `templates/state/*.md` contain the seeded markdown for session/memory/ADR files. Replace placeholders (`{timestamp}`, `{feature_id}`, `{owner}`) before writing.
- **scripts/init_state.sh** – creates `.spec/` directories, copies template files, and appends ignores.
- **scripts/tdd_cycle.sh** – enforces the TDD workflow and explicit `update_task_completion` calls (mirrors the old `implementing-features` instructions).
- **scripts/update_state.sh** – helper to refresh `current-session.md`, `workflow-progress.md`, and `.spec/state/next-step.json` when hooks are unavailable.

## Parallel Delegation
- Spin up `spec-researcher` while `spec-implementer` (or the main Orbit branch) works so research-backed ADRs land before code starts.
- For large features, run multiple `spec-implementer` sessions (different task groups) in parallel; Orbit hooks merge their summaries automatically via `orbit-aggregate-results`.
- Call out which agent owns which file set so hooks can log accurate provenance in `subagent-summary.md`.

## Validation & Error Handling
- After any run, confirm `current-session.md` frontmatter reflects the new phase + timestamps.
- Append to `changes-planned.md` / `changes-completed.md` even if hook automation fails; the scripts expose functions for direct updates.
- If MCP tools are missing, explain the fallback and point the user at reference.md for manual sync instructions.
- Summarize artifacts touched and decisions made (include next recommended branch).

See [reference.md](reference.md) for the migrated state diagrams, MCP sync recipes, template previews, and troubleshooting playbooks.
