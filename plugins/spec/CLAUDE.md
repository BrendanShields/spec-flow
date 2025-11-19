# Orbit Plugin - Claude Code Instructions

Specification-driven development workflow plugin:
- Define what to build (specs, user stories)
- Design how to build (plans, ADRs, components)
- Execute with tasks (dependencies, priorities)
- Track progress across sessions
- Maintain decision history + metrics

## Core Features
- TDD mode (3 enforcement levels)
- Specialized subagent library (spec-researcher, consistency-analyzer, specification-analyzer, spec-implementer). Claude autonomously decides when and how to invoke/parallelize them; plugins simply define their prompts and permissions.
- Smart hook auto-detection on init (session/cache/notification hooks)
- **Auto-template initialization** (copies default templates on first run)
- Interactive menu interface (2 commands)
- Progressive disclosure (3-tier lazy loading)
- State caching + AskUserQuestion guidance

### Orbit Skill Family

All workflow automation now lives inside two branded skills:
- **orbit-lifecycle** – Initialization through implementation + tracking with embedded templates/scripts.
- **orbit-planning** – Architecture, technical planning, tasks, and consistency validation.

Commands, hooks, and auto-mode reference these Orbit skills instead of the previous per-phase guides.

## Commands

### `/orbit` - Main Workflow
Primary command. Context-aware menus adapt to state.

**When to use**: Always. Main interface for all work.

**How it works**:
1. Reads `.spec/state/session.json` (single source for phase, feature, timestamps, and `nextAction`).
2. Prints the ASCII Orbit banner + status block so users instantly see the phase, feature, and recommended action.
3. Immediately asks an `AskUserQuestion` block (≤4 options) tailored to the detected state.
4. Claude selects the appropriate Orbit skill (`orbit-lifecycle` or `orbit-planning`) based on the conversation and question result.
5. Skills execute independently and hooks update `session.json`, `activity-log.md`, and `history.md`. `/orbit` then reports completion and highlights the next suggested phase.

**Recommended skills by state** (no manual menus):
- **Not initialized** → `orbit-lifecycle` (Initialize branch), optionally `analyzing-codebase` for brownfield analysis.
- **No feature selected** → `orbit-lifecycle` (Define branch) or `orbit-planning` (Architecture branch) when a blueprint is needed.
- **Specification phase** → `orbit-lifecycle` (Clarify/Quality branches).
- **Planning phase** → `orbit-planning` (Plan → Tasks → Consistency branches).
- **Implementation phase** → `orbit-lifecycle` (Implement branch) or Track branch for status checks.
- **Completed feature** → `orbit-planning` (Consistency branch) for validation or `orbit-lifecycle` (Define branch) to start the next feature.

**Auto Mode**: Say “auto mode” to trigger the `orbit-orchestrator` skill, which chains the standard phases and uses AskUserQuestion only at checkpoints (Continue/Refine/Review/Exit). It resumes automatically if interrupted.

### `/orbit-track` - Metrics/Maintenance
Progress monitoring, quality checks, and spec/plan upkeep.

**When to use**: Check metrics, update specs, run consistency gates, sync to JIRA/Confluence/Linear.

**Flow**:
1. Read `.spec/state/session.json`, `.spec/memory/activity-log.md`, `.spec/archive/history.md`.
2. Print the ASCII Orbit status block.
3. Launch a single AskUserQuestion with options: View Metrics, Update Specification, Check Consistency, Validate Quality.
4. Optional second question to open docs (Specification/Plan/Tasks/All) + choose follow-up action (Just view / View + Validate / View + Update).

## Plugin Structure
```
.claude/
├── commands/
│   ├── orbit.md         # State-aware workflow entry point (ASCII + AskUserQuestion)
│   └── orbit-track.md   # Metrics + maintenance entry point
├── skills/
│   ├── orbit-lifecycle/         # Init/spec/clarify/update/implement/track + templates/scripts
│   ├── orbit-planning/          # Architecture/plan/tasks/consistency + templates/scripts
│   ├── orbit-orchestrator/      # Auto mode orchestration
│   ├── analyzing-codebase/
│   └── creation helpers (creating-*, maintaining-workflows)
├── agents/
│   ├── spec-implementer.md
│   ├── spec-researcher.md
│   ├── codebase-analyzer.md
│   ├── consistency-analyzer.md
│   └── specification-analyzer.md
└── hooks/                       # Event automation (prefetch, summaries, metrics)

.spec/
├── architecture/
│   ├── architecture.md
│   └── architecture-decision-record.md
├── archive/
│   └── history.md               # Hook-appended narratives + snapshots
├── memory/
│   └── activity-log.md          # Append-only events (tasks, blockers, syncs)
└── state/
    ├── session.json             # Feature/phase/nextAction timestamps
    └── auto-mode-session.json   # Auto-mode metadata (if running)
```

### Hooks & Automation
- All hooks live in `.claude/hooks/*.sh` (prefixed with `orbit-` to signal they're workflow-specific) and run with Bash (Git Bash/WSL on Windows).
- Configuration lives in `.spec/.spec-config.yml`. Hooks autogenerate it with sane defaults if missing.
- `SessionStart` hooks prep directories, restore state, run migrations, and ensure `.spec/state/session.json` + `nextAction` exist.
- `UserPromptSubmit` and `Notification` hooks append `[Orbit Workflow Context]` and surface the next recommended action pulled from `session.json`.
- `PostToolUse` hooks update workflow status logs, refresh `session.json.nextAction`, tail `.spec/memory/activity-log.md`, and append summaries to `.spec/archive/history.md`. Treat them as the single source of truth—avoid manual edits unless a recovery script explicitly tells you to.
- Commands/scripts should call the provided helpers (`scripts/update_state.sh`, `orbit-prefetch-next-step`, etc.) instead of duplicating file I/O.

## User Project Files
Config-driven paths from `.spec/.spec-config.yml`:
```
{config.paths.spec_root}/
├── state/ (gitignored)
│   ├── session.json
│   └── auto-mode-session.json
├── memory/ (committed)
│   └── activity-log.md
├── archive/ (committed)
│   └── history.md
├── architecture/
│   ├── architecture.md
│   └── architecture-decision-record.md
└── features/{config.naming.feature_directory}/
    ├── {config.naming.files.spec}
    ├── {config.naming.files.plan}
    └── {config.naming.files.tasks}
```

**Defaults**: `.spec/`, `.spec/state/`, `.spec/memory/`, `.spec/archive/`, `.spec/architecture/`, `.spec/features/`, `###-name/`, `spec.md`, `plan.md`, `tasks.md`

**Note**: All paths (state, memory, features) are relative to `spec_root` by default. Templates now live inside the Orbit skills (`.claude/skills/orbit-lifecycle/templates/` and `.claude/skills/orbit-planning/templates/`).

## Workflow Phases
1. **Initialize** - Setup `{config.paths.spec_root}/`, state, memory files
2. **Generate** - Create spec (user stories, acceptance criteria)
3. **Clarify** - Resolve ambiguities ([CLARIFY] tags)
4. **Plan** - Technical design (architecture, ADRs, components)
5. **Tasks** - Break into actionable tasks (dependencies, priorities)
6. **Implement** - Execute (Claude may delegate to spec-implementer and stream progress)

## Priority System
- **P1** (Must Have) - Core, blocks release
- **P2** (Should Have) - Important, can defer
- **P3** (Nice to Have) - Optional

## State Management
**Session** (`{config.paths.state}/session.json`): Current feature/phase, timestamps, `nextAction` hints. Git-ignored.
**Memory** (`{config.paths.memory}/activity-log.md`): Append-only progress/metrics lines (committed).
**History** (`{config.paths.spec_root}/archive/history.md`): Hook-written session snapshots + subagent summaries (committed).

## Command Behavior

**How commands work**:
1. Read `.spec/state/session.json` for context (phase, feature, `nextAction`).
2. Print the ASCII banner + Orbit status summary (phase, progress, recommended action).
3. Claude automatically invokes the best-matching skill (no menu router).
4. Skills run independently (Read/Write/Edit/Bash/WebSearch) and commit their own files.
5. Hooks log the result, refresh `session.json.nextAction`, append to `activity-log.md`, and write rich notes to `archive/history.md`.

**Skills**:
- `.claude/skills/orbit-lifecycle/` – Project bootstrap, spec definition/clarification, change control, implementation, and tracking (templates + scripts included).
- `.claude/skills/orbit-planning/` – Architecture blueprints, technical plans, task breakdown, consistency validation (templates + scripts included).
- `.claude/skills/analyzing-codebase/` – Brownfield discovery.
- `.claude/skills/orbit-orchestrator/` – Auto Mode (end-to-end Orbit routing).

**State updates by phase**:
- Initialize: Creates dirs, seeds config/session file
- Generate: Updates `session.json.current`, logs "spec created" line to `activity-log.md`
- Plan: Updates phase to "planning", logs ADR entry in `.spec/architecture/architecture-decision-record.md`
- Tasks: Updates phase to "implementation", appends "tasks defined" entries to `activity-log.md`
- Implement: Appends completion/checkpoint lines to `activity-log.md` and writes summaries to `archive/history.md`

**Subagent delegation**:
- Implement → `spec-implementer` (Claude may spawn/resume implementer runs to execute tasks)
- Plan/research → `spec-researcher` (find references, write ADRs)
- Brownfield reconnaissance → `codebase-analyzer`
- Consistency sweeps → `consistency-analyzer`
- Spec validation depth dives → `specification-analyzer`

Orbit encourages running compatible agents in parallel (e.g., `spec-researcher` gathering data while `spec-implementer` executes tasks on other files). `orbit-aggregate-results` writes their outputs into `.spec/archive/history.md`, so don’t serialize work that can safely run concurrently.

## Docs References
**Users**: Run `/help` → Orbit entry
**Hooks**: Inspect `.claude/hooks/*.sh` (inline comments explain behavior)
**Devs**: Orbit skills now embed all docs/templates → open `.claude/skills/orbit-lifecycle/**` and `.claude/skills/orbit-planning/**` (reference files + scripts + templates). Commands reference those assets directly.

## Config
**Location**: `.spec/.spec-config.yml` (auto-generated on init with smart defaults)

**Key paths** (customizable):
```yaml
paths:
  spec_root: ".spec"           # Root directory

  # Simple relative paths (relative to spec_root)
  features: "features"         # → .spec/features
  state: "state"               # → .spec/state
  memory: "memory"             # → .spec/memory
  archive: "archive"           # → .spec/archive

  # Variable interpolation (advanced)
  # features: "{spec_root}/features"     # Explicit with variable
  # state: "{cwd}/.tmp/state"            # Use project root variable
  # memory: "{spec_root}/docs/memory"    # Custom location

  # Explicit or absolute paths
  # features: ".spec/features"     # Explicit (same result)
  # features: "my-features"        # → .spec/my-features
  # features: "../shared-features" # Outside spec_root
  # features: "/absolute/path"     # Absolute path

naming:
  feature_directory: "{id:000}-{slug}"  # 001-feature-name
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
```

**Path Resolution Logic:**
1. **Variable Interpolation** (recommended for maintainability):
   - Supports `{spec_root}`, `{cwd}`, or any `config.paths` key
   - Example: `"{spec_root}/features"` → `.spec/features`
   - Benefit: Change `spec_root` once, all paths update automatically

2. **Simple Relative** (default):
   - Simple name (`"features"`) → Relative to spec_root (`.spec/features`)
   - Clean config, automatic path resolution

3. **Explicit/Absolute**:
   - Starts with spec_root (`.spec/`) → Use as-is from project root
   - Absolute path (`/...`) → Use absolute path
   - Full control for special cases

This gives users full flexibility while keeping defaults clean and maintainable.

**Advanced settings** (from `claude.md` in user projects):
```
SPEC_AUTO_CHECKPOINT=true
SPEC_VALIDATE_ON_SAVE=true
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
SPEC_ORCHESTRATE_MODE=interactive|auto
SPEC_IMPLEMENT_MAX_PARALLEL=3
SPEC_CLARIFY_MAX_QUESTIONS=4
```

## Best Practices

**When helping users**:
1. Always recommend `/orbit` first
2. Let menus guide (don't explain all options)
3. Trust workflow (phase guides handle state)
4. Use `/orbit-track` for progress/metrics
5. Suggest auto mode for speed, checkpoints for control
6. Run compatible subagents in parallel and let Orbit hooks aggregate their results

**Token efficiency**:
- Commands cache state (guides don't re-read)
- Guides load ~1,500 tokens each
- AskUserQuestion adds ~200 tokens
- Auto mode batches efficiently

**Do**:
- Let phase guides handle state
- Invoke workflow skill from commands
- Use AskUserQuestion for choices
- Keep commands menu-focused
- Reference config paths correctly

**Don't**:
- Modify state files from commands
- Bypass menu system
- Re-read cached state
- Create new command files (2 is right)
- Reference old command names

## Common Patterns

**New feature (interactive)**:
```bash
/orbit
# Menu: Initialize Project → Auto Mode
# Prompts for requirements
# Auto-executes: define → design → build (checkpoints)
```

**Resume after interruption**:
```bash
/orbit
# Shows: Current: Implementation, Progress: 8/12 (67%)
# Options: Auto Mode / Continue Building
```

**Check progress**:
```bash
/orbit-track
# Status banner + AskUserQuestion (View Metrics)
# Hooks stream velocity + blockers from activity/history logs
```

## Troubleshooting
1. Run `/orbit` → "❓ Get Help"
2. Run `/orbit-track` → "📊 View Progress"
3. Run `/orbit-track` → "🔍 Analyze Consistency"
4. Check `.spec/state/session.json` manually
5. Use help mode for topic selection

---
Docs: Use `/help`
Support: `/help` → Orbit troubleshooting
