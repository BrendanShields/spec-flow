# Orbit Plugin v3.0

Specification-driven development workflow. **Artifacts are the source of truth.**

## Quick Start

```bash
/orbit    # Main command - detects state, guides next action
```

## What's New in v3.0

- **Frontmatter State**: Feature status stored in spec.md frontmatter
- **Smart Suggestions**: Context loader suggests next action
- **Feature Archive**: Completed features move to `.spec/archive/`
- **Parallel Execution**: Tasks grouped for concurrent execution
- **Critical Alerts**: Warns before modifying contracts/schemas
- **Brownfield Support**: Auto-generates PRD and TDD

## How It Works

Phase is stored in spec.md frontmatter and detected by context loader:

```yaml
---
id: 001-feature-name
title: Feature Title
status: implementation  # Phase is here
priority: P1
progress:
  tasks_total: 10
  tasks_done: 3
---
```

| Status | Next Action |
|--------|-------------|
| `initialize` | Create spec.md |
| `specification` | Create plan.md |
| `clarification` | Resolve [CLARIFY] tags |
| `planning` | Create tasks.md |
| `implementation` | Execute tasks |
| `complete` | Archive feature |

## Structure

```
.spec/
├── features/           # Active features
│   └── {id}-{name}/
│       ├── spec.md     # With frontmatter state
│       ├── plan.md
│       ├── tasks.md
│       └── metrics.md
├── archive/            # Completed features
├── architecture/
│   ├── product-requirements.md  # PRD
│   └── technical-design.md      # TDD
└── state/
    └── session.json

.claude/
├── commands/orbit.md
├── agents/
│   ├── implementing-tasks.md
│   ├── validating-artifacts.md
│   └── analyzing-codebase.md
├── skills/orbit-workflow/
└── hooks/
    ├── lib.sh
    ├── lib/context-loader.sh
    ├── orbit-init.sh
    ├── orbit-protect.sh
    └── orbit-log.sh
```

## Context Loader

Single call gathers all context:

```bash
bash .claude/hooks/lib/context-loader.sh
```

Returns JSON with:
- `suggestion`: Recommended next action
- `current`: Active feature state and artifacts
- `features.in_progress`: All features needing attention
- `extensions`: Available MCP servers, skills, agents

## Task Format

Tasks support dependencies and parallel groups:

```markdown
## Parallel Group A
- [ ] T001: Create types [P1]
- [ ] T002: Create interfaces [P1]

## Parallel Group B [depends:A]
- [ ] T003: Implement service [P1] [depends:T001,T002] [critical:api]
```

Tags:
- `[P1/P2/P3]` - Priority
- `[depends:X,Y]` - Dependencies
- `[critical:type]` - Requires approval (schema, api, types, auth)
- `[estimate:S/M/L]` - Size estimate

## Agents

| Agent | Purpose |
|-------|---------|
| `implementing-tasks` | Execute tasks with parallel groups |
| `validating-artifacts` | Quality gates, breaking change detection |
| `analyzing-codebase` | Brownfield analysis, PRD/TDD generation |

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `orbit-init` | SessionStart | Initialize directories |
| `orbit-protect` | PreToolUse | Block protected files |
| `orbit-log` | PostToolUse | Log to metrics.md |

## Archive

Completed features move to `.spec/archive/`:

```bash
source .claude/hooks/lib.sh
archive_feature "001-feature-name"
```

Archived features:
- Keep full history
- Searchable for reference
- Don't clutter active list

## Brownfield Projects

Run "Analyze Codebase" from `/orbit` to generate:
- `product-requirements.md` - PRD from code analysis
- `technical-design.md` - TDD with architecture map
- OpenAPI spec discovery/generation

## Helper Functions

```bash
source .claude/hooks/lib.sh

# Feature management
get_feature           # Current feature name
set_feature "001-x"   # Set current feature
archive_feature "x"   # Archive completed feature
search_archive "auth" # Find related archived features

# Frontmatter updates
update_frontmatter "spec.md" "status" "planning"
update_frontmatter_nested "spec.md" "progress" "tasks_done" "5"

# Context
load_context          # Run context-loader.sh
count_tasks "001-x"   # Get task counts
```

## Priority System

- **P1** - Must Have (core functionality)
- **P2** - Should Have (important, can defer)
- **P3** - Nice to Have (optional)
