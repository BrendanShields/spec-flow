# Flow Plugin - Instructions for Claude Code

This file provides guidance to Claude Code when working with the Flow plugin.

## Plugin Overview

**Flow** is a specification-driven development workflow plugin that helps developers:
- Define what to build (specifications)
- Design how to build it (technical plans)
- Execute with clear tasks (implementation)
- Track progress across Claude Code sessions
- Maintain decision history

## Plugin Structure

```
plugins/flow/
├── CLAUDE.md                   # This file - plugin instructions
├── README.md                   # User-facing documentation
│
├── docs/                       # Complete user documentation
│   ├── QUICK-START.md         # 5-minute setup
│   ├── USER-GUIDE.md          # Complete user manual  
│   ├── COMMANDS-QUICK-REFERENCE.md
│   ├── TROUBLESHOOTING.md
│   ├── WORKFLOW-EXPANSION-GUIDE.md
│   └── [analysis reports]
│
├── .claude/                    # Claude Code integration
│   ├── commands/              # Slash commands
│   │   ├── flow-init.md
│   │   ├── flow-specify.md
│   │   ├── flow-implement.md
│   │   ├── status.md
│   │   ├── help.md
│   │   ├── session.md
│   │   ├── resume.md
│   │   ├── validate.md
│   │   └── lib/               # Utilities
│   │
│   ├── skills/                # Flow skills (14 total)
│   │   ├── flow-init/
│   │   ├── flow-specify/
│   │   ├── flow-clarify/
│   │   ├── flow-plan/
│   │   ├── flow-tasks/
│   │   ├── flow-implement/
│   │   ├── flow-update/
│   │   ├── flow-blueprint/
│   │   ├── flow-analyze/
│   │   └── [others]
│   │
│   ├── agents/                # Specialized agents
│   │   ├── flow-implementer/
│   │   ├── flow-researcher/
│   │   └── flow-analyzer/
│   │
│   └── hooks/                 # Event hooks
│
├── .flow-state/               # Session state templates
│   └── current-session-template.md
│
├── .flow-memory/              # Memory file templates
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
└── templates/                 # Document templates (to be added)
```

## User Workflow Files

When Flow is used in a project, it creates:

```
User Project/
├── .flow/                     # Project configuration
│   ├── product-requirements.md
│   ├── architecture-blueprint.md
│   ├── templates/
│   └── scripts/
│
├── .flow-state/               # Session tracking (git-ignored)
│   ├── current-session.md
│   └── checkpoints/
│
├── .flow-memory/              # Persistent memory (committed)
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

1. **Initialize** (`/flow-init`) - Set up Flow in project
2. **Specify** (`/flow-specify`) - Create feature specification with user stories
3. **Clarify** (`/flow-clarify`) - Resolve ambiguities (optional)
4. **Plan** (`/flow-plan`) - Create technical design
5. **Tasks** (`/flow-tasks`) - Break into actionable tasks
6. **Implement** (`/flow-implement`) - Execute implementation
7. **Update** (`/flow-update`) - Modify specifications (as needed)

### Priority System

- **P1** (Must Have) - Core functionality, blocks release
- **P2** (Should Have) - Important but can defer
- **P3** (Nice to Have) - Optional enhancements

### State Management

**Session State** (`.flow-state/`):
- Current feature and phase
- Task progress
- Session checkpoints
- Git-ignored (session-specific)

**Persistent Memory** (`.flow-memory/`):
- Workflow progress and metrics
- Architecture decisions
- Planned/completed changes
- Git-committed (project history)

## Command Guidelines

### Slash Commands

Users invoke Flow with slash commands:

```bash
/flow-init                      # Initialize Flow
/flow-specify "Feature"         # Create specification
/flow-plan                      # Technical design
/flow-tasks                     # Task breakdown
/flow-implement                 # Execute
```

### Utility Commands

```bash
/status                         # Check workflow state
/help                           # Context-aware help
/session save                   # Save checkpoint
/resume                         # Continue work
/validate                       # Check consistency
```

## Skill Integration

### When Skills Update State

Skills should update state files:

**`flow:init`**:
- Creates `.flow-state/` and `.flow-memory/`
- Initializes tracking files

**`flow:specify`**:
- Updates `current-session.md` with new feature
- Adds entry to `WORKFLOW-PROGRESS.md`

**`flow:plan`**:
- Updates session phase to "planning"
- Logs architecture decisions to `DECISIONS-LOG.md`

**`flow:tasks`**:
- Updates session phase to "implementation"
- Adds tasks to `CHANGES-PLANNED.md`

**`flow:implement`**:
- Updates task progress in session
- Moves completed tasks to `CHANGES-COMPLETED.md`
- Updates `WORKFLOW-PROGRESS.md`

See `./docs/IMPLEMENTATION-COMPLETE.md` for integration details.

## Documentation References

### For Users

**Getting Started:**
- `./README.md` - Plugin overview
- `./docs/QUICK-START.md` - 5-minute setup
- `./docs/COMMANDS-QUICK-REFERENCE.md` - Command reference

**Complete Guide:**
- `./docs/USER-GUIDE.md` - Full user manual (800+ lines)

**Problem Solving:**
- `./docs/TROUBLESHOOTING.md` - Common issues (500+ lines)

**Customization:**
- `./docs/WORKFLOW-EXPANSION-GUIDE.md` - Extend Flow (750+ lines)

### For Developers

**Technical Details:**
- `./docs/IMPLEMENTATION-COMPLETE.md` - Implementation guide
- `./docs/FINAL-SUMMARY.md` - Complete project overview
- `./docs/COMPREHENSIVE-ANALYSIS-REPORT.md` - Analysis findings

**Integration:**
- `./.claude/skills/SKILL-STATE-INTEGRATION.md` - State integration guide
- `./.claude/commands/lib/state-utils.sh` - State utilities

## Configuration

Flow reads configuration from `CLAUDE.md` in user projects:

```markdown
# Flow Configuration
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
FLOW_AUTO_CHECKPOINT=true
FLOW_VALIDATE_ON_SAVE=true
```

## Best Practices

### When Helping Users

1. **Read context first**: Use `/status` to understand current state
2. **Follow workflow**: Spec → Plan → Tasks → Implement
3. **Update state**: Keep `.flow-state/` and `.flow-memory/` current
4. **Save checkpoints**: Use `/session save` before major operations
5. **Validate often**: Run `/validate` after changes

### File Organization

✅ **Do:**
- Keep user guides in `./docs/`
- Update state files during workflow
- Log decisions to `DECISIONS-LOG.md`
- Maintain session checkpoints

❌ **Don't:**
- Modify user's `features/` directly without workflow
- Skip state updates
- Forget to create checkpoints
- Leave inconsistent state

## Common Patterns

### New Feature Workflow

```bash
/flow-specify "Feature description"
/flow-plan
/flow-tasks
/validate
/flow-implement
/session save
```

### Resume After Interruption

```bash
/resume
/flow-implement --continue
```

### Requirements Changed

```bash
/flow-update "Revised requirements"
/flow-analyze
/flow-tasks --update
/flow-implement --continue
```

## Troubleshooting

When users encounter issues:

1. Check `/status` for current state
2. Run `/validate` to check consistency
3. Review `./docs/TROUBLESHOOTING.md`
4. Check session with `/session list`
5. Use `/help` for context-aware guidance

## Plugin Maintenance

### Adding New Skills

1. Create skill in `.claude/skills/{skill-name}/`
2. Follow structure: SKILL.md, EXAMPLES.md, REFERENCE.md
3. Update state integration guide
4. Add slash command wrapper in `.claude/commands/`

### Updating Documentation

1. User guides → `./docs/`
2. Technical docs → `./docs/`
3. Update cross-references
4. Maintain version compatibility

---

**For complete documentation**: See `./README.md` and `./docs/`

**For user support**: Direct users to `./docs/QUICK-START.md` or `./docs/USER-GUIDE.md`

**For customization**: See `./docs/WORKFLOW-EXPANSION-GUIDE.md`
