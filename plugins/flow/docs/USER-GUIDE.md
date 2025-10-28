# Flow Plugin: Complete User Guide

## 📖 Table of Contents

- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Complete Command Reference](#complete-command-reference)
- [Workflows by Persona](#workflows-by-persona)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

---

## Quick Start

### 5-Minute Getting Started

```bash
# 1. Initialize Flow in your project
/flow-init --type=greenfield

# 2. Create your first feature
/flow-specify "Add user login functionality"

# 3. Create technical plan
/flow-plan

# 4. Break down into tasks
/flow-tasks

# 5. Implement
/flow-implement

# 6. Check progress anytime
/status
```

That's it! You're using specification-driven development.

---

## Core Concepts

### What is Flow?

Flow is a specification-driven development workflow for Claude Code that helps you:
- **Define** what to build (spec)
- **Design** how to build it (plan)
- **Execute** with clear tasks (implement)
- **Track** progress across sessions
- **Maintain** decision history

### The Flow Workflow

```
┌──────────────┐
│   Specify    │  What to build? (User stories, requirements)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Clarify    │  Resolve ambiguities (optional)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Plan     │  How to build? (Technical design)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Tasks     │  Break down work (Actionable tasks)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Implement   │  Build it! (Execute tasks)
└──────────────┘
```

### Key Artifacts

| File | Purpose | When Created |
|------|---------|--------------|
| `spec.md` | Feature requirements | `/flow-specify` |
| `plan.md` | Technical design | `/flow-plan` |
| `tasks.md` | Task breakdown | `/flow-tasks` |
| `research.md` | Technical decisions | `/flow-plan` |

All stored in `features/{###-feature-name}/`

### Priority System

- **P1** (Must Have): Core functionality, blocks everything else
- **P2** (Should Have): Important but can defer if needed
- **P3** (Nice to Have): Optional enhancements

User stories and tasks are prioritized to guide implementation order.

---

## Complete Command Reference

### Workflow Commands

#### `/flow-init` - Initialize Flow
```bash
/flow-init                      # Interactive setup
/flow-init --type=greenfield    # New project
/flow-init --type=brownfield    # Existing code
```
**When**: First time using Flow in a project
**Creates**: `.flow/` structure, templates, state management

---

#### `/flow-specify` - Create Specification
```bash
/flow-specify "Feature description"
/flow-specify "JIRA-123" --from-jira
/flow-specify --level=project
```
**When**: Starting a new feature or project
**Creates**: `features/###-name/spec.md` with user stories
**Output**: Prioritized user stories, success criteria, clarifications

---

#### `/flow-clarify` - Resolve Ambiguities
```bash
/flow-clarify
/flow-clarify --question=3
```
**When**: Spec has `{CLARIFY: ...}` markers
**Updates**: `spec.md` with resolved clarifications
**Optional**: Skip if requirements are crystal clear

---

#### `/flow-plan` - Technical Design
```bash
/flow-plan
/flow-plan --minimal           # Skip research phase
```
**When**: After specification is clear
**Creates**: `plan.md` with architecture, components, data models
**Output**: Technical approach, technology choices, API designs

---

#### `/flow-tasks` - Break Down Work
```bash
/flow-tasks
/flow-tasks --filter=P1        # Only P1 tasks
/flow-tasks --simple           # Flat list, no phases
```
**When**: After planning is complete
**Creates**: `tasks.md` with sequenced, actionable tasks
**Output**: T001, T002... with file paths and descriptions

---

#### `/flow-implement` - Execute Tasks
```bash
/flow-implement
/flow-implement --continue     # Resume from last task
/flow-implement --task=T005    # Start from specific task
/flow-implement --mvp-only     # P1 tasks only
```
**When**: Tasks are ready
**Updates**: Marks tasks `[x]` as complete, commits code
**Progress**: Tracked in real-time

---

#### `/flow-update` - Modify Specification
```bash
/flow-update "New requirements"
/flow-update --add-story="New user story"
```
**When**: Requirements change mid-flight
**Updates**: `spec.md`, identifies impacted tasks
**Warning**: May require task regeneration

---

#### `/flow-blueprint` - Define Architecture
```bash
/flow-blueprint
/flow-blueprint --update
```
**When**: Before first feature (recommended) or anytime
**Creates**: `.flow/architecture-blueprint.md`
**Defines**: Architecture patterns, tech stack, standards

---

### Utility Commands

#### `/status` - Check State
```bash
/status
/status --verbose
```
**Shows**: Current feature, phase, progress, next action
**Use**: Frequently to stay oriented

---

#### `/help` - Get Help
```bash
/help                          # Context-aware help
/help /flow-specify            # Specific command help
```
**Shows**: Commands available based on current context
**Use**: When unsure what to do next

---

#### `/session` - Manage Sessions
```bash
/session save
/session save --name="checkpoint"
/session restore
/session list
```
**Purpose**: Preserve work across Claude sessions
**Use**: Before stopping work, before risky operations

---

#### `/resume` - Continue Work
```bash
/resume
/resume --from=checkpoint
```
**Purpose**: Pick up where you left off
**Use**: Start of new Claude session

---

#### `/validate` - Check Consistency
```bash
/validate
/validate --fix               # Auto-fix formatting
/validate --strict            # Strict mode
```
**Purpose**: Ensure workflow artifacts are consistent
**Use**: After manual edits, before implementation

---

### Advanced Commands

#### `/flow-analyze` - Deep Consistency Check
```bash
/flow-analyze
/flow-analyze --fix
```
**When**: After major changes, before shipping
**Checks**: Cross-document consistency, orphaned tasks, conflicts

---

#### `/flow-checklist` - Quality Gates
```bash
/flow-checklist
/flow-checklist --type=security,performance
```
**When**: Before deployment, after implementation
**Validates**: Security, performance, accessibility requirements

---

## Workflows by Persona

### POC Developer (Minimal Workflow)

**Goal**: Quick validation, throw-away code acceptable

```bash
# Minimal setup
/flow-init --type=greenfield

# Quick spec (skip validation)
/flow-specify "Quick POC for X" --skip-validation

# Optional minimal plan
/flow-plan --minimal

# Implement
/flow-implement --skip-checklists
```

**Skip**: Clarify, analyze, checklists, blueprint
**Time**: Hours to 1 day

---

### Solo Developer (Complete Workflow)

**Goal**: Build it right from the start

```bash
# Setup
/flow-init --type=greenfield
/flow-blueprint                        # Define your architecture

# Per feature
/flow-specify "Feature description"
/flow-clarify                          # Optional if clear
/flow-plan
/flow-tasks
/validate                              # Check consistency
/flow-implement

# Save frequently
/session save --name="after-feature-X"
```

**Includes**: All steps, proper planning
**Time**: Days to weeks per feature

---

### Team Developer (Collaborative)

**Goal**: Coordinate with team, maintain quality

```bash
# Setup (once per project)
/flow-init --type=greenfield --integrations=jira,confluence
/flow-blueprint

# Per feature
/flow-specify "Feature from PM"
/flow-clarify                          # PM answers questions
/flow-plan                             # Architect reviews
/flow-analyze                          # Check consistency
/flow-tasks
/flow-checklist --type=security        # Quality gates
/flow-implement

# Share work
/session save --name="handoff-to-teammate"
```

**Includes**: All steps, validation, team handoffs
**Time**: Days to weeks, multiple people

---

### Brownfield Developer (Existing Codebase)

**Goal**: Add features to existing system

```bash
# Setup (analyze existing code)
/flow-init --type=brownfield
# Reviews existing architecture automatically

# Define what exists
/flow-blueprint --extract               # Extract from codebase

# Add new feature
/flow-specify "New feature for existing system"
/flow-plan                              # References existing architecture
/flow-analyze                           # Critical: check compatibility
/flow-tasks                             # May include refactoring tasks
/flow-implement
```

**Key**: Blueprint extraction, analyze for conflicts
**Time**: Longer due to integration needs

---

## Common Patterns

### Pattern 1: Standard Feature Development

```bash
# 1. Define what to build
/flow-specify "User authentication with email/password"

# 2. Check the spec
cat features/001-user-authentication/spec.md

# 3. Clarify if needed
/flow-clarify

# 4. Design the solution
/flow-plan

# 5. Break down work
/flow-tasks

# 6. Validate before implementing
/validate

# 7. Implement
/flow-implement

# 8. Check progress
/status
```

---

### Pattern 2: Interrupted Workflow

```bash
# Day 1
/flow-implement
# Complete 5 tasks
# Session ends

# Day 2
/resume
# Automatically continues from task 6
/flow-implement --continue
```

---

### Pattern 3: Requirements Changed

```bash
# Original work
/flow-specify "Feature A"
/flow-plan
/flow-tasks

# Requirements change
/flow-update "Revised requirements for Feature A"

# Check what's impacted
/flow-analyze
# Shows: 3 tasks no longer align, 2 new tasks needed

# Regenerate tasks
/flow-tasks --update

# Continue
/flow-implement
```

---

### Pattern 4: MVP First, Polish Later

```bash
# Phase 1: MVP (P1 only)
/flow-specify "Complete feature with P1/P2/P3"
/flow-plan
/flow-tasks
/flow-implement --mvp-only              # Only P1 tasks

# Ship MVP, collect feedback

# Phase 2: Polish (P2 features)
/flow-implement --priority=P2

# Phase 3: Nice-to-haves (P3)
/flow-implement --priority=P3
```

---

### Pattern 5: Team Handoff

```bash
# Developer A
/flow-specify "Feature X"
/flow-plan
/flow-tasks
/flow-implement
# Complete tasks 1-5
/session save --name="handoff-to-dev-b"

# Developer B
/session restore --checkpoint=handoff-to-dev-b
/status
# See: 5/15 tasks done, current task is T006
/flow-implement --continue
```

---

## Troubleshooting

### Common Issues

#### "Flow not initialized"
```
Error: .flow/ directory not found

Solution: /flow-init --type=greenfield
```

#### "No active feature"
```
/status shows: No active workflow

Solution: /flow-specify "Your feature"
```

#### "Specification has clarifications"
```
Warning: 3 {CLARIFY: ...} markers found

Solution: /flow-clarify (resolves ambiguities)
Or: Manually edit spec.md to resolve
```

#### "Tasks out of sync"
```
/validate shows: Tasks don't match spec

Solution: /validate --fix (auto-fixes formatting)
Or: /flow-tasks (regenerate tasks)
```

#### "Session lost"
```
Session ended, progress lost?

Solution: /resume (restores from last checkpoint)
Check: /session list (see available checkpoints)
```

#### "Git conflicts"
```
Error: Merge conflicts in tasks.md

Solution:
1. Resolve conflicts manually
2. /validate (check consistency)
3. /flow-implement --continue
```

---

## Advanced Usage

### Custom Workflows

Create custom command sequences:

```bash
# In .claude/commands/my-feature-flow.md
Run these commands in sequence:
1. /flow-specify "$1"
2. /flow-plan
3. /flow-tasks
4. /validate
5. /flow-implement
```

### Integration with Git

```bash
# Flow automatically commits
# But you can customize:

# Before starting
git checkout -b feature/user-auth

# During implementation
# Flow commits each task automatically

# After completion
git push origin feature/user-auth
gh pr create
```

### JIRA Workflows

```bash
# Pull from JIRA
/flow-specify "PROJ-123" --from-jira

# Link to existing JIRA
/flow-specify "Feature" --jira=PROJ-456

# Create JIRA from spec
/flow-specify "Feature" --create-jira

# Auto-sync status
# As tasks complete, JIRA updates automatically
# (if FLOW_ATLASSIAN_SYNC=enabled)
```

### Metrics and Reporting

```bash
# Generate reports (planned)
/flow-report --type=progress
/flow-report --type=velocity
/flow-report --type=decisions

# Check metrics
cat .flow-memory/WORKFLOW-PROGRESS.md
cat .flow-memory/DECISIONS-LOG.md
```

---

## Tips for Success

### Before Starting
✅ Run `/flow-init` once per project
✅ Define blueprint early (`/flow-blueprint`)
✅ Start small (one feature at a time)
✅ Review examples in documentation

### During Development
✅ Use `/status` frequently
✅ Save checkpoints before breaks (`/session save`)
✅ Validate after manual edits (`/validate`)
✅ Keep commits atomic (one task = one commit)

### After Completion
✅ Run full validation (`/validate --strict`)
✅ Check quality gates (`/flow-checklist`)
✅ Review all changes
✅ Document decisions (`DECISIONS-LOG.md`)

### General Best Practices
✅ Write clear, specific feature descriptions
✅ Prioritize ruthlessly (P1 vs P2 vs P3)
✅ Break large features into smaller ones
✅ Commit frequently, push often
✅ Ask for help (`/help`) when unsure

---

## Next Steps

### Learn More
- [QUICK-START.md](./QUICK-START.md) - Fastest way to start
- [IMPLEMENTATION-COMPLETE.md](./docs/IMPLEMENTATION-COMPLETE.md) - Technical details
- [SLASH-COMMANDS-INTEGRATION-GUIDE.md](./docs/SLASH-COMMANDS-INTEGRATION-GUIDE.md) - Integration guide

### Get Help
- `/help` - In-app context-aware help
- [Troubleshooting](#troubleshooting) - Common issues solved
- GitHub Issues - Report bugs or request features

### Contribute
- Review [WORKFLOW-EXPANSION-GUIDE.md](./WORKFLOW-EXPANSION-GUIDE.md) - Extend Flow
- Create custom commands
- Share your workflows

---

**Happy building with Flow!** 🚀

Start with `/flow-init` and `/flow-specify "Your first feature"`