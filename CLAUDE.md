# Orbit Plugin Marketplace

Plugin marketplace for specification-driven development.

## Quick Start

```bash
# Install the Orbit plugin
/plugin install spec

# Start workflow
/orbit
```

## Orbit Plugin v3.0

Specification-driven development where **artifacts are the source of truth**.

### What's New in v3.0

- **Frontmatter State**: Feature status stored in spec.md frontmatter
- **Smart Suggestions**: Context loader suggests next action
- **Feature Archive**: Completed features move to `.spec/archive/`
- **Parallel Execution**: Tasks grouped for concurrent execution
- **Critical Alerts**: Warns before modifying contracts/schemas
- **Brownfield Support**: Auto-generates PRD and TDD

### Commands

```bash
/orbit    # Main entry point - detects state, guides next action
```

### How It Works

Phase is stored in spec.md frontmatter:

```yaml
---
id: 001-feature-name
title: Feature Title
status: implementation  # Phase stored here
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

### Structure

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
│   ├── product-requirements.md
│   └── technical-design.md
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
    └── orbit-*.sh (3 hooks)
```

### Workflow

```
Initialize → Specification → Clarification → Planning → Implementation → Archive
```

Run `/orbit` anytime - it detects where you left off and suggests next action.

## Plugin Development

See `plugins/spec/CLAUDE.md` for plugin internals.

### Plugin Structure

```
your-plugin/
├── .claude/
│   ├── commands/     # Slash commands
│   ├── agents/       # Subagents
│   ├── skills/       # Skills
│   └── hooks/        # Event hooks
├── CLAUDE.md         # Plugin docs
└── plugin.json       # Manifest
```

## Contributing

1. Fork the repository
2. Create plugin in `plugins/your-plugin/`
3. Test with `/plugin install ./plugins/your-plugin`
4. Submit PR
