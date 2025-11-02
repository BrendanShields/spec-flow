# Spec Plugin - Claude Code Instructions

Specification-driven development workflow plugin:
- Define what to build (specs, user stories)
- Design how to build (plans, ADRs, components)
- Execute with tasks (dependencies, priorities)
- Track progress across sessions
- Maintain decision history + metrics

## Core Features
- TDD mode (3 enforcement levels)
- Multi-agent coordination (6 strategies: Sequential, Parallel, Hierarchical, DAG, Group Chat, Event-Driven)
- Smart hook auto-detection on init
- **Auto-template initialization** (copies default templates on first run)
- Interactive menu interface (2 commands)
- Progressive disclosure (3-tier lazy loading)
- State caching + AskUserQuestion guidance

## Commands

### `/workflow:spec` - Main Workflow
Primary command. Context-aware menus adapt to state.

**When to use**: Always. Main interface for all work.

**Flow**:
1. Reads `{config.paths.state}/current-session.md` for context
2. AskUserQuestion presents menu
3. Invokes workflow skill
4. Skill loads phase guide (e.g., `phases/2-define/generate/guide.md`)
5. Returns to menu or continues

**Menus by state**:
- Not initialized: Initialize, Learn, Help
- No feature: Auto Mode, Define Feature, Track
- In spec: Auto Mode, Move to Design, Refine, View
- In planning: Auto Mode, Move to Build, Refine, View
- In implementation: Auto Mode, Continue, View Progress, Validate
- Complete: Validate, Metrics, New Feature

**Auto Mode**: Executes phases automatically, AskUserQuestion at checkpoints (Continue/Refine/Review/Exit). Resumes if interrupted.

### `/workflow:track` - Metrics/Maintenance
Progress monitoring, quality checks, spec updates.

**When to use**: Check progress/metrics, update specs, consistency checks, JIRA/Confluence sync.

**Menu**: View Metrics, Update Spec, Analyze Consistency, Quality Checklist, Sync External, View Docs.

## Plugin Structure
```
.claude/
├── commands/
│   ├── workflow:spec.md    # Main workflow
│   └── workflow:track.md   # Tracking
├── skills/workflow/phases/
│   ├── 1-initialize/init/guide.md
│   ├── 2-define/{generate,clarify,checklist}/guide.md
│   ├── 3-design/{plan,blueprint,analyze}/guide.md
│   ├── 4-build/{tasks,implement,discover}/guide.md
│   ├── 5-track/{metrics,update}/guide.md
│   └── shared/{integration,workflow,state}-*.md
├── agents/
│   ├── spec-implementer/   # Parallel execution
│   ├── spec-researcher/    # Research-backed decisions
│   └── spec-analyzer/      # Consistency validation
└── hooks/                  # Event hooks
```

## User Project Files
Config-driven paths from `.claude/.spec-config.yml`:
```
{config.paths.spec_root}/              # Config, requirements, blueprint
{config.paths.state}/                  # Session tracking (git-ignored)
{config.paths.memory}/                 # Persistent memory (committed)
  ├── WORKFLOW-PROGRESS.md
  ├── DECISIONS-LOG.md
  ├── CHANGES-PLANNED.md
  └── CHANGES-COMPLETED.md
{config.paths.features}/{config.naming.feature_directory}/
  ├── {config.naming.files.spec}
  ├── {config.naming.files.plan}
  └── {config.naming.files.tasks}
```

**Defaults**: `.spec/`, `.spec/state/`, `.spec/memory/`, `.spec/features/`, `###-name/`, `spec.md`, `plan.md`, `tasks.md`

**Note**: All paths (state, memory, features) are relative to `spec_root` by default. Templates are stored in the plugin at `.claude/skills/workflow/templates/`.

## Workflow Phases
1. **Initialize** - Setup `{config.paths.spec_root}/`, state, memory files
2. **Generate** - Create spec (user stories, acceptance criteria)
3. **Clarify** - Resolve ambiguities ([CLARIFY] tags)
4. **Plan** - Technical design (architecture, ADRs, components)
5. **Tasks** - Break into actionable tasks (dependencies, priorities)
6. **Implement** - Execute (parallel execution, progress tracking)

## Priority System
- **P1** (Must Have) - Core, blocks release
- **P2** (Should Have) - Important, can defer
- **P3** (Nice to Have) - Optional

## State Management
**Session** (`{config.paths.state}/`): Current feature/phase, task progress, checkpoints. Git-ignored.
**Memory** (`{config.paths.memory}/`): Progress/metrics, decisions (ADRs), planned/completed changes. Git-committed.

## Command Behavior

**How commands work**:
1. Read `{config.paths.state}/current-session.md` for context
2. AskUserQuestion with state-appropriate options
3. User selects
4. Invoke workflow skill → loads phase guide
5. Phase guide executes (Read/Write/Edit/Bash)
6. Updates state files
7. Returns to menu

**Phase guides**:
- `phases/1-initialize/init/guide.md` - Initialize project
- `phases/1-initialize/discover/guide.md` - Brownfield analysis
- `phases/1-initialize/blueprint/guide.md` - Architecture
- `phases/2-define/generate/guide.md` - Create spec
- `phases/2-define/clarify/guide.md` - Resolve ambiguities
- `phases/2-define/checklist/guide.md` - Quality checklists
- `phases/3-design/plan/guide.md` - Technical planning
- `phases/3-design/analyze/guide.md` - Consistency validation
- `phases/4-build/tasks/guide.md` - Task breakdown
- `phases/4-build/implement/guide.md` - Implementation
- `phases/5-track/metrics/guide.md` - Metrics
- `phases/5-track/update/guide.md` - Spec updates
- `phases/5-track/orchestrate/guide.md` - Full workflow automation

**State updates by phase**:
- Initialize: Creates dirs, init tracking
- Generate: Updates `current-session.md`, adds to `WORKFLOW-PROGRESS.md`
- Plan: Updates phase to "planning", logs to `DECISIONS-LOG.md`
- Tasks: Updates to "implementation", adds to `CHANGES-PLANNED.md`
- Implement: Updates progress, moves to `CHANGES-COMPLETED.md`

**Subagent delegation**:
- Implement → `spec-implementer` (parallel execution + progress)
- Plan → `spec-researcher` (research-backed decisions)
- Analyze → `spec-analyzer` (deep consistency validation)

## Docs References
**Users**: `./README.md`
**Hooks**: `.claude/hooks/README.md`
**Devs**: Phase guides (~1,500 tokens each), `.claude/commands/*.md`, `.claude/skills/workflow/phases/shared/*.md`

## Config
**Location**: `.claude/.spec-config.yml` (auto-generated on init with smart defaults)

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

**Advanced settings** (from `CLAUDE.md` in user projects):
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
1. Always recommend `/workflow:spec` first
2. Let menus guide (don't explain all options)
3. Trust workflow (phase guides handle state)
4. Use `/workflow:track` for progress/metrics
5. Suggest auto mode for speed, checkpoints for control

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
/workflow:spec
# Menu: Initialize Project → Auto Mode
# Prompts for requirements
# Auto-executes: define → design → build (checkpoints)
```

**Resume after interruption**:
```bash
/workflow:spec
# Shows: Current: Implementation, Progress: 8/12 (67%)
# Options: Auto Mode / Continue Building
```

**Check progress**:
```bash
/workflow:track
# Menu: View Metrics
# Shows velocity, completion rates
```

## Troubleshooting
1. Run `/workflow:spec` → "❓ Get Help"
2. Run `/workflow:track` → "📊 View Progress"
3. Run `/workflow:track` → "🔍 Analyze Consistency"
4. Check `{config.paths.state}/current-session.md` manually
5. Use help mode for topic selection

---
Docs: `./README.md`
Support: README Quick Start
