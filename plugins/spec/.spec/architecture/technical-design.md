# Technical Design Document

**System**: Orbit Plugin
**Version**: 3.0.0
**Generated**: 2025-11-27

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        /orbit command                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ context-loader  │
                    │    (1 call)     │
                    └─────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  Skill   │   │  Agents  │   │  Hooks   │
        │ workflow │   │ (3 total)│   │(3 total) │
        └──────────┘   └──────────┘   └──────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                    ┌─────────────────┐
                    │   .spec/        │
                    │   features/     │
                    │   archive/      │
                    │   architecture/ │
                    └─────────────────┘
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Commands | Markdown | Entry points for workflow |
| Skills | Markdown + YAML | Workflow logic |
| Agents | Markdown + XML | Specialized tasks |
| Hooks | Bash + Python | Event handlers |
| State | JSON + Markdown | Feature tracking |

## Component Details

### Context Loader (`lib/context-loader.sh`)
- **Purpose**: Single-call context gathering
- **Location**: `.claude/hooks/lib/context-loader.sh`
- **Output**: JSON with suggestion, features, artifacts, extensions
- **Performance**: <500ms for typical project

### Orbit Workflow Skill (`orbit-workflow/SKILL.md`)
- **Purpose**: Main workflow orchestration
- **Phases**: initialize → specification → clarification → planning → implementation → complete
- **Features**: Frontmatter management, parallel file creation, archive integration

### Implementing Tasks Agent (`implementing-tasks.md`)
- **Purpose**: Execute tasks from tasks.md
- **Features**: Parallel group execution, critical change alerts, progress tracking
- **Output**: Implementation summary with status per task

### Validating Artifacts Agent (`validating-artifacts.md`)
- **Purpose**: Quality gates between phases
- **Checks**: Completeness, consistency, coverage, breaking changes
- **Output**: Pass/fail report with recommendations

### Analyzing Codebase Agent (`analyzing-codebase.md`)
- **Purpose**: Brownfield project analysis
- **Output**: PRD, TDD, API contract discovery
- **Features**: Stack detection, architecture mapping, health scoring

### Hooks
| Hook | Event | Purpose |
|------|-------|---------|
| `orbit-init.sh` | SessionStart | Initialize directories |
| `orbit-protect.sh` | PreToolUse | Block protected files |
| `orbit-log.sh` | PostToolUse | Log to metrics.md |

## Data Models

### Session State (`state/session.json`)
```json
{
  "feature": "001-feature-name"
}
```

### Feature Frontmatter (spec.md)
```yaml
id: 001-feature-name
title: Feature Title
status: implementation
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 10
  tasks_done: 3
```

### Task Format (tasks.md)
```markdown
## Parallel Group A
- [ ] T001: Description [P1]
- [ ] T002: Description [P1] [critical:api]

## Parallel Group B [depends:A]
- [ ] T003: Description [P1] [depends:T001,T002]
```

## Directory Structure

```
.spec/
├── features/           # Active features
│   └── {id}-{name}/
│       ├── spec.md     # With frontmatter
│       ├── plan.md
│       ├── tasks.md
│       └── metrics.md
├── archive/            # Completed features
├── architecture/       # System docs
│   ├── product-requirements.md
│   └── technical-design.md
└── state/
    └── session.json

.claude/
├── commands/
│   └── orbit.md
├── agents/
│   ├── implementing-tasks.md
│   ├── validating-artifacts.md
│   └── analyzing-codebase.md
├── skills/
│   └── orbit-workflow/
│       └── SKILL.md
└── hooks/
    ├── lib.sh
    ├── lib/
    │   └── context-loader.sh
    ├── orbit-init.sh
    ├── orbit-protect.sh
    └── orbit-log.sh
```

## Integration Points

| Integration | Type | Purpose |
|-------------|------|---------|
| MCP Servers | External | Discovered and offered as tools |
| User Skills | External | Can be invoked from workflow |
| User Agents | External | Can be delegated to |
| OpenAPI | File | Contract validation and sync |

## Design Decisions

### ADR-001: Frontmatter for State
- **Context**: Need to track feature state across sessions
- **Decision**: Store state in spec.md frontmatter
- **Rationale**: Single source of truth, human-readable, diff-friendly

### ADR-002: Archive Completed Features
- **Context**: Feature list grows over time
- **Decision**: Move completed features to `.spec/archive/`
- **Rationale**: Faster context loading, cleaner active list

### ADR-003: Parallel Task Groups
- **Context**: Some tasks can run simultaneously
- **Decision**: Group tasks with dependency annotations
- **Rationale**: Faster implementation, explicit dependencies

---
*This document is maintained by the Orbit workflow*
*Update as architecture evolves*
