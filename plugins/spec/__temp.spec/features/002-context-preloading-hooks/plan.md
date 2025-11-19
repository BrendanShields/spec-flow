# Technical Plan: Orbit Context Automation Hooks

**Feature ID**: 002-context-preloading-hooks  
**Version**: 2.0.0  
**Status**: Ready for implementation

## 1. Architecture Overview

```
┌─────────────┐      ┌────────────────┐      ┌─────────────────────┐
│ /orbit,     │  →   │ Hook Helpers   │  →   │ State + Memory Data │
│ /orbit-track│      │ (.claude/hooks │      │ (.spec/state/*.json │
│ Commands    │      │  /lib.sh)      │      │  + memory/archive)  │
└─────────────┘      └────────────────┘      └─────────────────────┘
         │                    │                           │
         │ AskUserQuestion    │ session_get/set, logging   │ JSON/Markdown
         ▼                    ▼                           ▼
   Orbit Skills        Orbit Hooks                 CLI Output + Logs
```

- **Single source of truth** – `state/session.json` stores phase, feature metadata, timestamps, and the cached `nextAction`.
- **Append-only memory** – `memory/activity-log.md` receives one line per event; `archive/history.md` collects richer session snapshots.
- **Commands stay read-only** – `/orbit` and `/orbit-track` only read these files; hooks/scripts perform all writes.

## 2. Components

### 2.1 Hook Helper Library (`.claude/hooks/lib.sh`)
- Provide `session_get`, `session_set_value`, `session_append_progress`, `record_next_step` utilities.
- Ensure directories + files exist (`session.json`, `activity-log.md`, `history.md`).
- Offer `append_log_line` helper that timestamps entries.

### 2.2 Hooks
- **orbit-session-init**: seeds config + session, records `session_initialized` event.
- **orbit-restore-session**: summarizes the latest session from `session.json` for onboarding prompts.
- **orbit-append-context**: injects `[Orbit Workflow Context]` block using the latest state.
- **orbit-notify-next-step**: emits JSON summary for idle notifications/resume hints.
- **orbit-update-status**: updates `session.json.current.*`, logs phase transitions, and recomputes `nextAction`.
- **orbit-prefetch-next-step**: caches computed `nextAction` inside `session.json`.
- **orbit-session-summary**: appends markdown blocks to `archive/history.md` including last 5 activities + metrics.
- **orbit-aggregate-results**: writes subagent output to `archive/history.md` and logs the event.
- **orbit-track-metrics**: keeps lightweight tool metrics in `memory/WORKFLOW-METRICS.log` (unchanged).

### 2.3 Commands
- `/orbit`: Reads `session.json`, prints ASCII banner + status block, immediately triggers AskUserQuestion, then invokes lifecycle/planning skills.
- `/orbit-track`: Reads the same files + recent history, prints banner/status, and presents tracking/maintenance options.

## 3. Data Contracts

### session.json
```json
{
  "current": {
    "id": "002-context-preloading-hooks",
    "name": "Orbit Context Automation Hooks",
    "phase": "tasks",
    "status": "in_progress",
    "progress": ["Specification complete", "Plan approved"],
    "priority": "P1"
  },
  "nextAction": {
    "phase": "implementation",
    "hint": "Finish hook updates and verify /orbit-track"
  },
  "timestamps": {
    "started": "2025-11-19T22:50:00Z",
    "lastUpdated": "2025-11-20T00:15:00Z"
  }
}
```

### activity-log.md (append-only)
```
2025-11-20T00:12:11Z phase_transition=planning feature=002-context-preloading-hooks
2025-11-20T00:14:02Z clarification_resolved=Cache removal scope
```

### archive/history.md (hook-generated blocks)
```
## 2025-11-20T00:15:22Z Session Snapshot
- Feature: 002-context-preloading-hooks (Orbit Context Automation Hooks)
- Phase: tasks

### Progress
- Specification complete (6 user stories)
- Technical plan approved

### Recent Activity
```

## 4. Implementation Steps

1. **Update hook helpers** – ensure new files are created/touched, remove references to `current-session.md` & `next-step.json`.
2. **Refactor hooks** – adjust each script listed in §2.2 to use the helper functions and new files.
3. **Refresh scripts/templates** – update Orbit lifecycle scripts (`init_state.sh`, `update_state.sh`) and templates to the JSON + log layout.
4. **Rewrite command docs** – `/orbit` and `/orbit-track` docs should mention ASCII banner, session.json, AskUserQuestion sequencing, and parallel agent guidance.
5. **Docs cleanup** – update `CLAUDE.md`, auto-mode README, and any other references pointing to deleted files.
6. **Validation** – run `/orbit` and `/orbit-track` locally; inspect `session.json`, `activity-log.md`, `archive/history.md`, and verify hook outputs.

## 5. Testing Strategy

- **Unit-like checks**: Execute each hook with mocked JSON input to ensure they exit cleanly and append to the correct files.
- **Command dry runs**: Run `/orbit` followed by `/orbit-track`; confirm ASCII banner + AskUserQuestion ordering and verify that commands never call Write/Edit.
- **Regression**: Ensure auto-mode resume prompts still appear (read `.spec/state/auto-mode-session.json` + `session.json`).
- **Logs**: Tail `activity-log.md` and `archive/history.md` to confirm hooks append entries after every lifecycle run.

## 6. Deliverables

- Updated hook scripts + helper library
- Refreshed Orbit command docs and CLAUDE instructions
- Updated state templates/scripts (JSON/log-based)
- Verified `session.json`, `activity-log.md`, `archive/history.md` containing live data after running `/orbit`
