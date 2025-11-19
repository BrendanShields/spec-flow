# Orbit Track

Secondary slash command for Orbit status, metrics, and maintenance. Runs after `/orbit` to inspect progress or trigger targeted upkeep.

## What This Command Does

- Reads `.spec/state/session.json` (phase/feature/next action), `.spec/memory/activity-log.md` (events), and `.spec/archive/history.md` (rich snapshots)
- Prints the Orbit ASCII banner + status block so users see phase/feature instantly
- Presents an `AskUserQuestion` menu (max 4 options) immediately after the summary
- Invokes the correct Orbit skill based on the selection, then surfaces next-step hints

**User Experience**: Zero back-and-forth. Status → AskUserQuestion → selected skill.

## Capabilities

### 📊 Progress Monitoring
- **orbit-lifecycle** (Track branch) – Generate dashboards, velocity trends, forecasts, and bottleneck analysis straight from `session.json` + `activity-log.md`

### 📝 Specification Maintenance
- **orbit-lifecycle** (Update branch) – Modify specs, priorities, and acceptance criteria
- **orbit-lifecycle** (Clarify branch) – Resolve new questions detected in specs or history logs

### 🔍 Quality Validation
- **orbit-lifecycle** (Quality branch) – Run spec quality checklists
- **orbit-planning** (Consistency branch) – Verify spec ↔ plan ↔ tasks alignment

### 📚 Documentation & Sync
- Surface the latest spec/plan/tasks plus ADR decisions (Read tool)
- Trigger MCP syncs (JIRA, Confluence, Linear) when configured

## AskUserQuestion Flow

1. **Summarize first** using the Orbit ASCII banner plus status block:
   ```
     ██████╗ ██████╗ ██████╗ ██╗████████╗
    ██╔═══██╗██╔══██╗██╔══██╗██║╚══██╔══╝
    ██║   ██║██████╔╝██████╔╝██║   ██║
    ██║   ██║██╔══██╗██╔══██╗██║   ██║
    ╚██████╔╝██║  ██║██████╔╝██║   ██║
     ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝   ╚═╝
   **🚀🌑 Orbit Status**
   - Phase: {phase}
   - Feature: {feature or "None"}
   - Next Step: {nextAction.phase} – {nextAction.hint}
   ```
2. **Immediately launch a single-question AskUserQuestion**:
   - Header chip: `TRACK`
   - Question: "What would you like to track or update?"
   - multiSelect: `false`
   - Options (labels ≤5 words, descriptions actionable):
     1. **View Metrics** → Invoke `orbit-lifecycle` (Track branch) – "Velocity, completion %, blockers"
     2. **Update Specification** → `orbit-lifecycle` (Update) – "Adjust requirements & priorities"
     3. **Check Consistency** → `orbit-planning` (Consistency) – "Validate spec ↔ plan ↔ tasks"
     4. **Validate Quality** → `orbit-lifecycle` (Quality) – "Run Orbit gate checklist"

3. **If the user needs documents**, chain a second AskUserQuestion immediately (max 4 options again):
   - Header: `DOCS`
   - Question: "Which document should I open?" (multiSelect: false)
   - Options: Specification / Technical Plan / Tasks / All Docs.
   - Follow-up question: "Next action after viewing?" → `Just view`, `View + Validate`, `View + Update` (call respective skills).

Stick to 1–2 questions per invocation to minimize turns.

## Autonomous Skills Triggered

- **orbit-lifecycle** (Track, Update, Clarify, Quality branches)
- **orbit-planning** (Consistency branch)
- Optional: `analyzing-codebase` when the user wants context before tracking

## State Awareness Checklist

Before composing the status block:
1. Parse `.spec/state/session.json` to capture `current.{id,name,phase,status}` and `nextAction`.
2. Tail `.spec/memory/activity-log.md` for the last 5 events (tasks completed, blockers, syncs).
3. Read the latest section of `.spec/archive/history.md` for context from hooks/subagents.
4. When relevant, open the active feature docs (spec.md, plan.md, tasks.md) and architecture ADRs.

## Integration Examples

```bash
/orbit-track
# → Prints ASCII banner + status
# → AskUserQuestion("What would you like to track or update?", [View Metrics, Update Specification, Check Consistency, Validate Quality])
# User picks "View Metrics" → invoke orbit-lifecycle (Track)
```

```bash
/orbit-track
# → Status
# → AskUserQuestion
# User picks "Update Specification"
# → orbit-lifecycle (Update) runs
```

```bash
/orbit-track
# → Status
# → Ask question about documents (multi-tab)
# User selects Specification + View + Validate
# → Read spec.md, summarize, invoke orbit-planning (Consistency)
```

## Command Flow

1. `/orbit-track` invoked
2. Read `session.json`, `activity-log.md`, `history.md`
3. Print ASCII banner + Orbit status block
4. Ask the user (AskUserQuestion) what to do next
5. Invoke the appropriate Orbit skill based on the selection
6. Hooks update `session.json` and logs; report next recommended step

## Relationship to /orbit

- `/orbit` – Main workflow navigator (define → design → build)
- `/orbit-track` – Tracking and maintenance (monitor → update → validate)

Use `/orbit-track` whenever the user requests progress, metrics, or maintenance activities outside of the main workflow.
