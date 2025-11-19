# Orbit Context Automation Hooks

**Feature ID**: 002-context-preloading-hooks  
**Priority**: P1 (Must Have)  
**Owner**: Orbit Workflow Team  
**Created**: 2025-11-19  
**Status**: In Implementation

## Executive Summary

Orbit no longer stores state across multiple markdown files. `state/session.json` is the single source of truth, `memory/activity-log.md` records fast append-only events, and `archive/history.md` captures rich summaries. Feature 002 ensures the hook suite keeps these files up to date so commands and skills no longer re-read or edit scattered documents. Hooks should preload the current state, append workflow context to every prompt, and surface clarifications via AskUserQuestion blocks before Claude starts a phase.

## Problem Statement

- `/orbit` and `/orbit-track` repeatedly read/remove `current-session.md`, `workflow-progress.md`, and similar legacy files.
- Hooks previously wrote to `.spec/state/next-step.json`, forcing commands to juggle multiple caches.
- Clarifying questions were delayed or skipped because state data lived in different places.
- Manual edits to tracking files introduced drift and token waste.

We need the hooks + helper scripts to centralize state reads/writes and drive consistent prompting: status block → AskUserQuestion → skill handoff. The goal is faster context loading, fewer file reads, and deterministic clarifications.

## User Stories

### US-001: Session bootstrap without manual edits
**As a** developer starting `/orbit`  
**I want** SessionStart hooks to seed `session.json`, `activity-log.md`, and `history.md` automatically  
**So that** the command can immediately show the Orbit banner and move to clarification questions

**Acceptance Criteria**
- [ ] `orbit-session-init.sh` ensures `.spec/state/session.json` exists with `current`, `nextAction`, and `timestamps` keys.
- [ ] Hook logs include a `session_initialized` line in `activity-log.md`.
- [ ] No command ever writes a markdown session file; helper scripts call `session_set_value` instead.
- [ ] Documentation updated (`CLAUDE.md`, command docs) to mention the new single-source-of-truth structure.

### US-002: Prompt context preloading
**As a** user invoking `/orbit` or `/orbit-track`  
**I want** `UserPromptSubmit` hooks to append the Orbit context block automatically  
**So that** Claude always sees feature/phase/nextAction before responding

**Acceptance Criteria**
- [ ] `orbit-append-context.sh` reads `session.json` and injects `[Orbit Workflow Context]` with feature, phase, and `nextAction`.
- [ ] The hook respects the ASCII banner requirement (commands print banner + status before questions).
- [ ] Hook only triggers when `/orbit*` commands or the workflow flag is active.
- [ ] No redundant reads of archive/history inside commands—only hooks touch them unless the user explicitly requests docs.

### US-003: Deterministic clarifications via AskUserQuestion
**As a** developer answering requirements  
**I want** `/orbit` to summarize and immediately ask clarifying questions  
**So that** we resolve blockers before Claude starts a phase

**Acceptance Criteria**
- [ ] `/orbit` command instructions emphasize summary → AskUserQuestion flow (≤4 options, automatic "Other").
- [ ] Notification logs show that clarifications were presented before branching into lifecycle skills.
- [ ] The command references `.spec/state/session.json` and does not mention `next-step.json` anywhere.
- [ ] ASCII banner is always present in the initial response.

### US-004: PostToolUse state refresh
**As a** contributor running Orbit skills  
**I want** hooks to record progress and next steps without extra file edits  
**So that** commands and auto-mode see accurate recommendations instantly

**Acceptance Criteria**
- [ ] `orbit-update-status.sh` records phase transitions via `session_set_value` and appends concise lines to `activity-log.md`.
- [ ] `orbit-prefetch-next-step.sh` writes the computed `nextAction` into `session.json`.
- [ ] `orbit-session-summary.sh` appends markdown blocks to `archive/history.md` on Stop/SessionEnd.
- [ ] `orbit-track-metrics.sh` continues logging tool usage to `memory/WORKFLOW-METRICS.log` without touching removed files.

### US-005: Resumable auto-mode guidance
**As a** user pausing auto-mode  
**I want** hooks to store resume hints either in `session.json` or the auto-mode file  
**So that** `/orbit` can immediately ask whether to resume, restart, or go interactive

**Acceptance Criteria**
- [ ] `orbit-session-init.sh` / `orbit-restore-session.sh` inspect `.spec/state/auto-mode-session.json` and embed progress in the AskUserQuestion options.
- [ ] `orbit-notify-next-step.sh` emits JSON with `current`, `next`, and resume hints pulled from `session.json`.
- [ ] Auto-mode documentation references `session.json.nextAction` instead of `NEXT-STEP.json`.
- [ ] Resume prompts also encourage running compatible subagents in parallel (per Orbit doc updates).

## Non-Goals

- Building a separate caching daemon or binary. Everything stays within Bash hooks and helper scripts.
- Persisting history outside `.spec/archive/history.md`.
- Supporting legacy `workflow-progress.md` / `changes-*.md` files.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Hooks fail in fresh repos | `orbit-session-init.sh` + helper scripts source `lib.sh` and bail with clear errors when missing |
| Commands accidentally re-create markdown files | Unit tests + docs call out the new state files and forbid writing markdown session logs |
| Auto-mode references stale docs | Update auto-mode README + hooks so they pull from `session.json` everywhere |

## Success Metrics

- `/orbit` completes the summary + AskUserQuestion step in <150ms (down from ~500ms when reading multiple files).
- `/orbit-track` no longer calls `Read` on more than three files unless the user explicitly requests documents.
- Hooks emit at least one line per significant event in `activity-log.md` and one summary block per session in `archive/history.md`.
- Clarification prompts happen before lifecycle skills 90%+ of the time (measured via AskUserQuestion telemetry in logs).

## Dependencies

- Updated hook helpers in `.claude/hooks/lib.sh` (`session_get`, `session_set_value`, `record_next_step`).
- Orbit command docs referencing ASCII banner + AskUserQuestion sequencing.
- Auto-mode README/skill references updated to mention `session.json` and parallel agent guidance.

## Next Steps

1. Implement the hook + helper changes described above.
2. Update command docs and CLAUDE.md (done in this patch series).
3. Run `/orbit` and `/orbit-track` end-to-end to ensure hooks populate `session.json`, `activity-log.md`, and `archive/history.md` automatically.
