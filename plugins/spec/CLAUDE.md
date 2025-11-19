# Spec Plugin - Claude Code Instructions

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
1. Reads `{config.paths.state}/next-step.json` (cached by hooks) and `{config.paths.state}/current-session.md`.
2. Prints a short state summary plus the recommended next action.
3. Claude selects the appropriate Orbit skill (`orbit-lifecycle` or `orbit-planning`) based on the current conversation.
4. Skills execute independently and update state files when they finish.
5. `/orbit` reports completion and highlights the next suggested phase.

**Recommended skills by state** (no manual menus):
- **Not initialized** → `orbit-lifecycle` (Initialize branch), optionally `analyzing-codebase` for brownfield analysis.
- **No feature selected** → `orbit-lifecycle` (Define branch) or `orbit-planning` (Architecture branch) when a blueprint is needed.
- **Specification phase** → `orbit-lifecycle` (Clarify/Quality branches).
- **Planning phase** → `orbit-planning` (Plan → Tasks → Consistency branches).
- **Implementation phase** → `orbit-lifecycle` (Implement branch) or Track branch for status checks.
- **Completed feature** → `orbit-planning` (Consistency branch) for validation or `orbit-lifecycle` (Define branch) to start the next feature.

**Auto Mode**: Say “auto mode” to trigger the `orbit-orchestrator` skill, which chains the standard phases and uses AskUserQuestion only at checkpoints (Continue/Refine/Review/Exit). It resumes automatically if interrupted.

### `/spec-track` - Metrics/Maintenance
Progress monitoring, quality checks, spec updates.

**When to use**: Check progress/metrics, update specs, consistency checks, JIRA/Confluence sync.

**Menu**: View Metrics, Update Spec, Analyze Consistency, Quality Checklist, Sync External, View Docs.

## Plugin Structure
```
.claude/
├── commands/
│   ├── orbit.md         # State-aware workflow entry point
│   └── spec-track.md    # Metrics + maintenance entry point
├── skills/
│   ├── orbit-lifecycle/          # Init/spec/clarify/update/implement/track + templates/scripts
│   ├── orbit-planning/           # Architecture/plan/tasks/consistency + templates/scripts
│   ├── analyzing-codebase/
│   ├── orbit-orchestrator/
│   └── creation helpers (creating-*, maintaining-workflows)
├── agents/
│   ├── spec-implementer.md
│   ├── spec-researcher.md
│   ├── codebase-analyzer.md
│   ├── consistency-analyzer.md
│   └── specification-analyzer.md
└── hooks/                    # Event automation + migrations

.spec/
├── architecture/
│   ├── architecture.md
│   └── architecture-decision-record.md
├── memory/
│   ├── changes-planned.md
│   ├── changes-completed.md
│   ├── workflow-progress.md
│   ├── session-summary.md
│   └── subagent-summary.md
└── state/
    ├── current-session.md
    └── next-step.json
```

### Hooks & Automation
- All hooks live in `.claude/hooks/*.sh` (prefixed with `orbit-` to signal they're workflow-specific) and run with Bash (Git Bash/WSL on Windows).
- Configuration lives in `.spec/.spec-config.yml`. Hooks autogenerate it with sane defaults if missing.
- `SessionStart` hooks prep directories, restore state, run migrations, and recompute `.spec/state/next-step.json`.
- `UserPromptSubmit` and `Notification` hooks append `[Spec Workflow Context]` and surface the next recommended action pulled from `next-step.json`.
- `PostToolUse` hooks update workflow status logs, refresh the next-step cache, and track metrics. Treat them as the single source of truth for Orbit state—avoid manual file edits unless a recovery script explicitly tells you to.
- Commands/scripts should call the provided helpers (`scripts/update_state.sh`, `orbit-prefetch-next-step`, etc.) instead of duplicating file I/O.

## User Project Files
Config-driven paths from `.spec/.spec-config.yml`:
```
{config.paths.spec_root}/              # Config, requirements, blueprint
{config.paths.state}/                  # Session tracking (git-ignored)
{config.paths.memory}/                 # Persistent memory (committed)
  ├── workflow-progress.md
  ├── changes-planned.md
  └── changes-completed.md
{config.paths.architecture}/           # Architecture docs + ADRs
  ├── architecture.md
  └── architecture-decision-record.md
{config.paths.features}/{config.naming.feature_directory}/
  ├── {config.naming.files.spec}
  ├── {config.naming.files.plan}
  └── {config.naming.files.tasks}
```

**Defaults**: `.spec/`, `.spec/state/`, `.spec/memory/`, `.spec/architecture/`, `.spec/features/`, `###-name/`, `spec.md`, `plan.md`, `tasks.md`

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
**Session** (`{config.paths.state}/`): Current feature/phase, task progress, checkpoints. Git-ignored.
**Memory** (`{config.paths.memory}/`): Progress/metrics, decisions (ADRs), planned/completed changes. Git-committed.

## Command Behavior

**How commands work**:
1. Read `{config.paths.state}/current-session.md` and `next-step.json` for context.
2. Print a short summary (phase, progress, recommended action).
3. Claude automatically invokes the best-matching skill (no menu router).
4. Skills run independently (Read/Write/Edit/Bash/WebSearch) and commit their own files.
5. Hooks log the result, refresh `next-step.json`, and append state metrics.

**Skills**:
- `.claude/skills/orbit-lifecycle/` – Project bootstrap, spec definition/clarification, change control, implementation, and tracking (templates + scripts included).
- `.claude/skills/orbit-planning/` – Architecture blueprints, technical plans, task breakdown, consistency validation (templates + scripts included).
- `.claude/skills/analyzing-codebase/` – Brownfield discovery.
- `.claude/skills/orbit-orchestrator/` – Auto Mode (end-to-end Orbit routing).

**State updates by phase**:
- Initialize: Creates dirs, init tracking
- Generate: Updates `current-session.md`, adds to `workflow-progress.md`
- Plan: Updates phase to "planning", logs to `.spec/architecture/architecture-decision-record.md`
- Tasks: Updates to "implementation", adds to `changes-planned.md`
- Implement: Updates progress, moves to `changes-completed.md`

**Subagent delegation**:
- Implement → `spec-implementer` (Claude may spawn/resume implementer runs to execute tasks)
- Plan/research → `spec-researcher` (find references, write ADRs)
- Brownfield reconnaissance → `codebase-analyzer`
- Consistency sweeps → `consistency-analyzer`
- Spec validation depth dives → `specification-analyzer`

Orbit encourages running compatible agents in parallel (e.g., `spec-researcher` gathering data while `spec-implementer` executes tasks on other files). `orbit-aggregate-results` merges their outputs into `subagent-summary.md`, so don’t serialize work that can safely run concurrently.

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
4. Use `/spec-track` for progress/metrics
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
/spec-track
# Menu: View Metrics
# Shows velocity, completion rates
```

## Troubleshooting
1. Run `/orbit` → "❓ Get Help"
2. Run `/spec-track` → "📊 View Progress"
3. Run `/spec-track` → "🔍 Analyze Consistency"
4. Check `{config.paths.state}/current-session.md` manually
5. Use help mode for topic selection

---
Docs: Use `/help`
Support: `/help` → Orbit troubleshooting
