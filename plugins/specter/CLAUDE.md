# Specter Plugin - Instructions for Claude Code

This file provides guidance to Claude Code when working with the Specter plugin.

## Plugin Overview

**Specter v3.0** is a specification-driven development workflow plugin that helps developers:
- Define what to build (specifications with user stories)
- Design how to build it (technical plans with ADRs)
- Execute with clear tasks (implementation with dependencies)
- Track progress across Claude Code sessions
- Maintain decision history and metrics

**Key v3.0 Features**:
- 81% token efficiency improvement
- Unified `/spec` hub command with intelligent routing
- Progressive disclosure architecture (3-tier lazy loading)
- State caching (80% reduction in state overhead)
- 13 specialized skills

## Plugin Structure

```
plugins/specter/
├── CLAUDE.md                   # This file - plugin instructions
├── README.md                   # User-facing documentation
│
├── docs/                       # Complete user documentation
│   ├── MIGRATION-V2-TO-V3.md  # Migration guide
│   ├── HOOKS-USER-GUIDE.md    # Event hooks guide
│   └── CUSTOM-HOOKS-API.md    # Hooks API reference
│
├── .claude/                    # Claude Code integration
│   ├── commands/               # Slash commands
│   │   ├── spec.md            # Unified hub command
│   │   └── router.sh          # Command routing logic
│   │
│   ├── skills/                # Specter skills (13 total)
│   │   ├── spec-init/         # Initialize project
│   │   ├── spec-generate/     # Create specifications
│   │   ├── spec-clarify/      # Resolve ambiguities
│   │   ├── spec-plan/         # Technical design
│   │   ├── spec-tasks/        # Task breakdown
│   │   ├── spec-implement/    # Execute implementation
│   │   ├── spec-update/       # Update specifications
│   │   ├── spec-blueprint/    # Define architecture
│   │   ├── spec-orchestrate/  # Full workflow automation
│   │   ├── spec-analyze/      # Validate consistency
│   │   ├── spec-discover/     # Brownfield analysis
│   │   ├── spec-checklist/    # Quality checklists
│   │   ├── spec-metrics/      # Development metrics
│   │   └── shared/            # Shared resources
│   │       ├── integration-patterns.md
│   │       ├── workflow-patterns.md
│   │       └── state-management.md
│   │
│   ├── agents/                # Specialized agents
│   │   ├── spec-implementer/  # Parallel task execution
│   │   ├── spec-researcher/   # Research-backed decisions
│   │   └── spec-analyzer/     # Deep consistency validation
│   │
│   └── hooks/                 # Event hooks
│       ├── hooks.json
│       └── [hook scripts]
│
├── .specter-state/            # Session state templates
│   └── current-session-template.md
│
├── .specter-memory/           # Memory file templates
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
└── templates/                 # Document templates
```

## User Workflow Files

When Specter is used in a project, it creates:

```
User Project/
├── .specter/                     # Project configuration
│   ├── product-requirements.md
│   ├── architecture-blueprint.md
│   ├── templates/
│   └── scripts/
│
├── .specter-state/               # Session tracking (git-ignored)
│   ├── current-session.md
│   └── checkpoints/
│
├── .specter-memory/              # Persistent memory (committed)
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
└── features/                  # Feature artifacts
    └── ###-feature-name/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

## Key Concepts

### Workflow Phases

1. **Initialize** (`/spec init`) - Set up Specter in project
2. **Generate** (`/spec generate` or `/spec "Feature"`) - Create feature specification
3. **Clarify** (`/spec clarify`) - Resolve ambiguities (optional)
4. **Plan** (`/spec plan`) - Create technical design
5. **Tasks** (`/spec tasks`) - Break into actionable tasks
6. **Implement** (`/spec implement`) - Execute implementation

### Priority System

- **P1** (Must Have) - Core functionality, blocks release
- **P2** (Should Have) - Important but can defer
- **P3** (Nice to Have) - Optional enhancements

### State Management

**Session State** (`.specter-state/`):
- Current feature and phase
- Task progress
- Session checkpoints
- Git-ignored (session-specific)

**Persistent Memory** (`.specter-memory/`):
- Workflow progress and metrics
- Architecture decisions (ADRs)
- Planned/completed changes
- Git-committed (project history)

## Command Guidelines

### Hub Command

Users invoke Specter with the unified `/spec` command:

```bash
/spec init                    # Initialize Specter
/spec "Feature description"   # Create specification
/spec                         # Context-aware: continues from current phase
/spec plan                    # Explicit: run specific phase
/spec --help                  # Context-aware help
```

**Routing Logic**:
- `/spec` alone → Context-aware continuation
- `/spec init|generate|plan|tasks|implement|...` → Explicit skill invocation
- `/spec "Text with spaces"` → Smart: detects specification text, runs generate

### Core Workflow Commands

```bash
/spec init                    # Initialize project
/spec generate "Feature"      # Create specification
/spec "Feature"               # Shorthand for generate
/spec clarify                 # Resolve [CLARIFY] tags
/spec plan                    # Create technical plan
/spec tasks                   # Break into tasks
/spec implement               # Execute implementation
```

### Supporting Commands

```bash
/spec update "Changes"        # Update specification
/spec blueprint               # Define architecture
/spec orchestrate             # Full workflow automation
/spec analyze                 # Validate consistency
/spec discover                # Brownfield analysis
/spec metrics                 # Show development metrics
/spec checklist               # Generate quality checklists
/spec validate                # Validate all artifacts
/spec status                  # Check current state
```

### Progressive Disclosure Flags

```bash
/spec plan --examples         # Load EXAMPLES.md (~3,000 extra tokens)
/spec tasks --reference       # Load REFERENCE.md (~2,000 extra tokens)
/spec --verbose               # Detailed execution output
```

## Skill Integration

### When Skills Update State

Skills should update state files appropriately:

**`spec:init`**:
- Creates `.specter/`, `.specter-state/`, `.specter-memory/`
- Initializes tracking files

**`spec:generate`**:
- Updates `current-session.md` with new feature
- Adds entry to `WORKFLOW-PROGRESS.md`

**`spec:plan`**:
- Updates session phase to "planning"
- Logs architecture decisions to `DECISIONS-LOG.md`

**`spec:tasks`**:
- Updates session phase to "implementation"
- Adds tasks to `CHANGES-PLANNED.md`

**`spec:implement`**:
- Updates task progress in session
- Moves completed tasks to `CHANGES-COMPLETED.md`
- Updates `WORKFLOW-PROGRESS.md`

### Subagent Delegation

Complex skills delegate to specialized subagents:

- `spec:implement` → `spec:implementer` (parallel task execution with progress tracking)
- `spec:plan` → `spec:researcher` (research-backed technical decisions)
- `spec:analyze` → `spec:analyzer` (deep consistency validation across artifacts)

See individual agent directories in `.claude/agents/spec-*/`

## Documentation References

### For Users

**Getting Started:**
- `./README.md` - Plugin overview and quick start
- `./docs/MIGRATION-V2-TO-V3.md` - Migration from v2.1

**Advanced:**
- `./docs/HOOKS-USER-GUIDE.md` - Event hooks guide
- `./docs/CUSTOM-HOOKS-API.md` - Hooks API reference

### For Developers

**Skill Documentation** (each skill has 3 files):
- `SKILL.md` - Core logic and workflow (~1,500 tokens)
- `EXAMPLES.md` - Comprehensive usage scenarios (~3,000 tokens)
- `REFERENCE.md` - Full technical reference (~2,000 tokens)

**Load with flags**:
```bash
/spec plan                    # Loads SKILL.md only
/spec plan --examples         # Loads SKILL.md + EXAMPLES.md
/spec plan --reference        # Loads SKILL.md + REFERENCE.md
```

**Shared Resources**:
- `.claude/skills/shared/integration-patterns.md` - MCP integration patterns
- `.claude/skills/shared/workflow-patterns.md` - Common workflow patterns
- `.claude/skills/shared/state-management.md` - State file specifications

## Configuration

Specter reads configuration from `CLAUDE.md` in user projects:

```markdown
# Specter Configuration

## Basic Settings
SPECTER_AUTO_CHECKPOINT=true        # Auto-save session state
SPECTER_VALIDATE_ON_SAVE=true       # Auto-validate before completion

## MCP Integrations (Optional)
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_JIRA_PROJECT_KEY=PROJ
SPECTER_CONFLUENCE_ROOT_PAGE_ID=123456

## Workflow Preferences
SPECTER_ORCHESTRATE_MODE=interactive|auto
SPECTER_ORCHESTRATE_SKIP_ANALYZE=false

## Skill-Specific
SPEC_IMPLEMENT_MAX_PARALLEL=3       # Max parallel tasks
SPEC_CLARIFY_MAX_QUESTIONS=4        # Questions per session
```

## Best Practices

### When Helping Users

1. **Read context first**: Use `/spec status` to understand current state
2. **Follow workflow**: generate → clarify → plan → tasks → implement
3. **Update state**: Keep `.specter-state/` and `.specter-memory/` current
4. **Use progressive disclosure**: Don't load --examples unless needed
5. **Validate often**: Run `/spec validate` after changes

### Token Efficiency

**v3.0 Achievements**:
- 81% token reduction per skill (6,800 → 1,283 tokens)
- 80% state overhead reduction (10,000 → 2,000 tokens)
- 3-5x faster execution

**Best Practices**:
- Default: Use skills without flags (1,500 tokens)
- Examples: Add `--examples` when user needs patterns (6,600 tokens)
- Reference: Add `--reference` for full API docs (11,600 tokens)
- State: Hub caches state, don't re-read in skills

### File Organization

✅ **Do:**
- Keep user guides in `./docs/`
- Update state files during workflow
- Log decisions to `DECISIONS-LOG.md`
- Maintain session checkpoints
- Use skill naming: `spec:*` (not `specter:*`)

❌ **Don't:**
- Modify user's `features/` directly without workflow
- Skip state updates
- Forget to create checkpoints
- Leave inconsistent state
- Use old `specter-*` command names

## Common Patterns

### New Feature Workflow

```bash
/spec init
/spec "Feature description"
/spec plan
/spec tasks
/spec validate
/spec implement
```

### Resume After Interruption

```bash
/spec status
/spec                         # Context-aware continue
# OR
/spec implement --continue
```

### Requirements Changed

```bash
/spec update "Revised requirements"
/spec analyze
/spec tasks --update
/spec implement --continue
```

### Full Automation

```bash
/spec orchestrate
# Runs: generate → clarify → plan → tasks → implement
# With prompts at decision points
```

## Troubleshooting

When users encounter issues:

1. Check `/spec status` for current state
2. Run `/spec validate` to check consistency
3. Review skill-specific EXAMPLES.md: `/spec <command> --examples`
4. Check session state: `cat .specter-state/current-session.md`
5. Use verbose mode: `/spec <command> --verbose`

## Version Information

- **Current Version**: 3.0.0
- **Command Interface**: `/spec` hub with subcommands
- **Skills**: 13 specialized skills (spec:*)
- **Agents**: 3 specialized agents (spec-*)
- **Token Efficiency**: 81% reduction vs v2.1
- **Migration**: See docs/MIGRATION-V2-TO-V3.md

---

**For complete documentation**: See `./README.md` and `./docs/`

**For user support**: Direct users to README.md Quick Start section

**For migration**: See docs/MIGRATION-V2-TO-V3.md
