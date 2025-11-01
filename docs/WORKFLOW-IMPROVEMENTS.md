# Spec Workflow Enhancements

This document captures the improvements applied to the Spec workflow so teams can adopt consistent practices across onboarding, automation, and collaboration.

## Guided Onboarding & Command Discovery
- `/spec --interactive` now presents a guided menu with the current phase, next-step recommendations, and quick links to context-specific docs.
- The `spec` command automatically explains available subcommands when invoked without arguments, and `/spec --help` renders progressive disclosure help so newcomers see only what they need.
- Added onboarding checklist to the README covering quick-start, guided flows, and troubleshooting entry points for fast setup.

## State-Management Guarantees
- Introduced `plugins/spec/scripts/state-management/validate-state.sh` to audit `.spec`, `.spec-state`, and `.spec-memory` directories, ensuring JSON ↔ Markdown parity and reporting drift.
- `json-to-md.sh` now targets `.spec` directories and provides regeneration instructions when validation flags issues.
- Hooks callouts recommend running validation after merges to maintain automated guarantees.

## Task Planning & Realistic Roadmapping
- Documentation encourages grouping related subtasks into epics while keeping acceptance criteria per milestone.
- Plan templates highlight integration tests and cross-cutting acceptance criteria alongside implementation notes.
- README includes guidance on when to consolidate vs. split tasks, reducing micromanagement without losing coverage.

## Collaboration Workflows
- Collaboration guidelines emphasize lock leasing, task ownership hand-offs, and the use of `.spec-state` checkpoints for asynchronous updates.
- Hooks emit auditable entries in `.spec/metrics-history/` so multiple contributors can review who performed which automation step.
- README now outlines conflict-resolution playbooks and session-handoff best practices for distributed teams.

## Documentation Coverage for the New UX
- README quick-start tables link to updated docs under `plugins/spec/docs/` so users can find the same flows reflected in the CLI.
- Added onboarding notes highlighting the interactive router, progressive help, and the location of troubleshooting guides.
- Spec Visualiser README reflects the new naming and command set, aligning UI messaging with CLI language.

## Observability & Feedback Loops
- The metrics hook (`.claude/hooks/track-metrics.js`) writes consolidated snapshots to `.spec/.metrics.json` and archives history for trend analysis.
- Spec Visualiser surfaces metrics dashboards, status views, and watchers focused on `.spec` artifacts for real-time monitoring.
- README instructions now call out the analytics touchpoints (CLI metrics view, hook outputs, and visualiser dashboards) so teams can verify goals like token reduction.

## Migration & Compatibility Support
- Router command provides compatibility warnings and links to migration docs whenever legacy commands are invoked.
- Documentation describes the one-year deprecation window, recommended wrappers, and `/spec upgrade --dry-run` flow for safe rollout.
- Hooks include optional tasks to detect legacy directories (`.navi`, `.legacy`) and prompt teams to run migration scripts.

Refer to the main README for entry points and the Spec Visualiser package for richer UX around dashboards, metrics, and watchers.
