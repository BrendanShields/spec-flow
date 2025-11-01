# Spec - Unified Specification Workflow Hub

Single entry point for specification-driven development. Intelligently routes to appropriate skills with context awareness and lazy loading.

## Usage

```bash
/spec                           # Context-aware: shows status and next actions
/spec init                      # Initialize spec workflow in project
/spec "Feature description"     # Generate specification (auto-detects free text)
/spec generate "Description"    # Explicit specification generation
/spec plan                      # Create technical plan
/spec tasks                     # Break down into tasks
/spec implement                 # Execute implementation
/spec --help                    # Show detailed help
/spec --interactive             # Interactive menu mode
```

## Quick Examples

```bash
# Initialize new project
/spec init

# Generate specification (both work)
/spec "Add user authentication with OAuth2"
/spec generate "Add user authentication with OAuth2"

# Continue workflow (context-aware)
/spec          # Auto-continues from current phase

# Explicit phase control
/spec plan
/spec tasks
/spec implement

# Get help
/spec --help
/spec status
```

## Smart Routing

The `/spec` command routes based on:
1. **Explicit subcommands** (e.g., `/spec init`)
2. **Free text** (auto-generates specification)
3. **Current context** (continues from current phase)
4. **No arguments** (shows status + asks next action)

## Progressive Loading Strategy

**Lazy loading** minimizes token usage:

- **Always**: Router + context (~500 tokens)
- **On invoke**: Core skill instructions (~1,500 tokens)
- **With --examples**: Load EXAMPLES.md (~2,800 tokens)
- **With --help**: Load full documentation (~7,500 tokens)

**Result**: 85% token reduction vs monolithic approach

## Workflow Phases

```
init → generate → plan → tasks → implement
  ↓       ↓         ↓        ↓         ↓
Setup   Define   Design  Breakdown  Execute
```

### Optional Phases

- `clarify` - Resolve ambiguities after generate
- `blueprint` - Define architecture before generate
- `update` - Modify specifications anytime
- `analyze` - Validate consistency before implement

## Subcommands

| Command | Skill | Description | Example |
|---------|-------|-------------|---------|
| **init** | spec:init | Initialize workflow | `/spec init` |
| **(text)** | spec:generate | Create specification | `/spec "Add search"` |
| **generate** | spec:generate | Explicit generate | `/spec generate "..."` |
| **clarify** | spec:clarify | Resolve ambiguities | `/spec clarify` |
| **plan** | spec:plan | Technical design | `/spec plan` |
| **tasks** | spec:tasks | Task breakdown | `/spec tasks` |
| **implement** | spec:implement | Execute tasks | `/spec implement` |
| **blueprint** | spec:blueprint | Architecture docs | `/spec blueprint` |
| **update** | spec:update | Update specs | `/spec update "..."` |
| **analyze** | spec:analyze | Validate consistency | `/spec analyze` |
| **metrics** | spec:metrics | Show progress | `/spec metrics` |
| **status** | (built-in) | Show current state | `/spec status` |

## Flags

- `--help` - Show detailed help for current phase
- `--examples` - Load and show examples
- `--verbose` - Detailed output
- `--interactive` - Interactive menu mode
- `--continue` - Resume from interruption

## Command Behavior

When `/spec` is invoked, the router:

### 1. Load State (Cached)

**Read once, cache for entire command**:
```bash
# State cache (loaded at command start)
CURRENT_SESSION=$(cat .spec-state/current-session.md 2>/dev/null)
WORKFLOW_PROGRESS=$(cat .spec-memory/WORKFLOW-PROGRESS.md 2>/dev/null)
PROJECT_CONFIG=$(cat CLAUDE.md 2>/dev/null)

# Parse cached state
CURRENT_FEATURE=$(parse_session "$CURRENT_SESSION" "Active Feature")
CURRENT_PHASE=$(parse_session "$CURRENT_SESSION" "Phase")
CURRENT_PROGRESS=$(parse_session "$CURRENT_SESSION" "Progress")
```

**Token Savings**: Read state once (2,000 tokens) vs per-skill (10,000+ tokens)

### 2. Detect Intent

```bash
# Detect what user wants
if [[ "$1" == "init" ]]; then
    INTENT="initialize"
elif [[ "$1" == "generate" ]] || [[ "$1" == "\""* ]]; then
    INTENT="generate-spec"
elif [[ "$1" == "plan" ]]; then
    INTENT="create-plan"
elif [[ "$1" == "tasks" ]]; then
    INTENT="breakdown-tasks"
elif [[ "$1" == "implement" ]]; then
    INTENT="execute-implementation"
elif [[ -z "$1" ]]; then
    INTENT="context-aware-continue"
else
    INTENT="unknown"
fi
```

### 3. Route to Skill

**Pass cached state to skill** (avoid re-reading):

```markdown
Invoke skill: spec:${PHASE}

Context (pre-loaded):
- Current feature: ${CURRENT_FEATURE}
- Current phase: ${CURRENT_PHASE}
- Progress: ${CURRENT_PROGRESS}
- Session data: ${CURRENT_SESSION}
- Workflow data: ${WORKFLOW_PROGRESS}

Do NOT re-read state files - use provided context.
```

### 4. Progressive Disclosure

**Load additional resources only when requested**:

```bash
if [[ "$@" == *"--examples"* ]]; then
    # Load EXAMPLES.md for current skill
    cat .claude/skills/spec-${PHASE}/EXAMPLES.md
fi

if [[ "$@" == *"--help"* ]]; then
    # Load REFERENCE.md for current skill
    cat .claude/skills/spec-${PHASE}/REFERENCE.md
fi

if [[ "$@" == *"--verbose"* ]]; then
    # Load shared resources
    cat .claude/skills/shared/workflow-patterns.md
    cat .claude/skills/shared/state-management.md
fi
```

### 5. Interactive Mode

When no arguments or `--interactive`:

```markdown
Use AskUserQuestion tool to present context-aware options:

**If uninitialized**:
- Initialize spec workflow
- Learn about spec-driven development
- See example project

**If in generate phase**:
- Continue to planning
- Clarify requirements
- Update specification
- Check status

**If in plan phase**:
- Continue to tasks
- Update plan
- Review architecture decisions
- Check status

**If in tasks phase**:
- Begin implementation
- Review task breakdown
- Update tasks
- Check status

**If in implement phase**:
- Continue implementation
- Check task progress
- Switch tasks
- Commit current work
```

## Context-Aware Help

```bash
/spec --help
```

**In generate phase**:
```
📝 Current Phase: SPECIFICATION

You've created a specification. Next steps:

1. /spec plan
   Create technical design from specification
   Duration: ~5-10 minutes

2. /spec clarify
   Resolve any [CLARIFY] tags in spec
   Required if ambiguities present

3. /spec update "changes"
   Modify the specification
   Use when requirements change

Current Feature: 002-user-authentication
Progress: Specification complete, ready for planning

Examples: /spec --examples
Detailed help: /spec plan --help
```

**In implement phase**:
```
⚡ Current Phase: IMPLEMENTATION

You're executing tasks. Available commands:

1. /spec implement
   Continue implementation from current task
   Progress: 15/23 tasks (65%)

2. /spec status
   Check detailed task status
   Shows: in-progress, queued, blocked

3. /spec analyze
   Validate implementation consistency
   Checks: spec alignment, no orphaned code

Current Feature: 002-user-authentication
Tasks Remaining: 8 tasks (P1: 3, P2: 5)
Estimated: 4-6 hours

Examples: /spec --examples
```

## State Caching Benefits

**Traditional approach** (v2.1):
```
Command invoked
  ├─ Skill loads state (2,000 tokens)
  ├─ Skill loads workflow (2,000 tokens)
  ├─ Skill loads config (500 tokens)
  └─ Total: 4,500 tokens overhead PER SKILL
```

**Optimized approach** (v3.0):
```
Command invoked
  ├─ Hub loads state ONCE (2,000 tokens)
  ├─ Hub caches in memory
  ├─ Skill receives cached data (0 tokens)
  └─ Total: 2,000 tokens overhead for ENTIRE WORKFLOW
```

**Savings**: 55% reduction in state-related tokens

## Skill Mapping

| Subcommand | Routes To | Core Tokens | +Examples | +Full Docs |
|------------|-----------|-------------|-----------|------------|
| init | spec:init | ~1,500 | ~4,300 | ~7,800 |
| generate | spec:generate | ~1,500 | ~4,300 | ~7,500 |
| clarify | spec:clarify | ~1,200 | ~3,000 | ~5,800 |
| plan | spec:plan | ~1,400 | ~3,800 | ~7,200 |
| tasks | spec:tasks | ~1,300 | ~3,600 | ~6,900 |
| implement | spec:implement | ~1,200 | ~3,400 | ~6,500 |

**Average**: 1,350 tokens core, 3,733 tokens with examples, 6,950 tokens full

## Backward Compatibility

**Old commands still work** (v3.x only):

```bash
/spec-init        →  /spec init
/spec-specify "X" →  /spec "X"
/spec-plan        →  /spec plan
/spec-tasks       →  /spec tasks
/spec-implement   →  /spec implement
```

**Deprecation warnings shown**. Removed in v4.0.

## Examples by Use Case

### Starting Fresh
```bash
cd my-project
/spec init
/spec "Add user authentication system"
/spec plan
/spec tasks
/spec implement
```

### Mid-Workflow
```bash
# Check status
/spec status

# Continue from current phase
/spec

# Or explicit phase
/spec implement --continue
```

### With Learning
```bash
# Get examples before starting
/spec generate --examples

# Show examples of planning
/spec plan --examples

# Get full documentation
/spec implement --help
```

### Troubleshooting
```bash
# Validate consistency
/spec analyze

# Show detailed status
/spec status --verbose

# Get help for current phase
/spec --help
```

## Token Efficiency Comparison

| Metric | v2.1 (Old) | v3.0 (New) | Improvement |
|--------|------------|------------|-------------|
| Hub overhead | 0 (no hub) | 500 tokens | N/A |
| State reads | 4,500/skill | 2,000/workflow | 55% ↓ |
| Skill load | 10,000 (mono) | 1,500 (core) | 85% ↓ |
| With examples | 10,000 (incl) | 3,733 (lazy) | 63% ↓ |
| Full docs | 10,000 (incl) | 6,950 (lazy) | 31% ↓ |
| **Avg per command** | **14,500** | **2,000** | **86% ↓** |

## Shared Resources

The hub loads shared resources when needed:

- `shared/integration-patterns.md` - MCP integration
- `shared/workflow-patterns.md` - Common workflows
- `shared/state-management.md` - State specifications

**Loaded only with** `--verbose` or when skill explicitly requests.

## Related Commands

- `/status` - Check workflow state
- `/help` - Context-aware help
- `/validate` - Validate consistency

---

## IMPORTANT: Implementation

When this command executes:

### 1. State Caching

```bash
#!/bin/bash
# Cache state at command start
cache_state() {
    export CACHED_SESSION=$(cat .spec-state/current-session.md 2>/dev/null || echo "")
    export CACHED_PROGRESS=$(cat .spec-memory/WORKFLOW-PROGRESS.md 2>/dev/null || echo "")
    export CACHED_CONFIG=$(cat CLAUDE.md 2>/dev/null || echo "")
    export STATE_CACHED=true
}

# Parse cached state
get_current_feature() {
    echo "$CACHED_SESSION" | grep "Active Feature:" | cut -d: -f2 | xargs
}

get_current_phase() {
    echo "$CACHED_SESSION" | grep "Phase:" | cut -d: -f2 | xargs
}

get_progress() {
    echo "$CACHED_SESSION" | grep "Progress:" | cut -d: -f2 | xargs
}
```

### 2. Intent Detection

```markdown
Analyze user input:
- Explicit subcommand? → Route to skill
- Free text (quoted)? → Route to spec:generate
- No arguments? → Show status + AskUserQuestion
- --help flag? → Show context-aware help
- --interactive? → Show interactive menu
```

### 3. Skill Invocation

```markdown
Pass cached state to skill invocation:

---
Skill: spec:${PHASE}

Pre-loaded Context (do not re-read):
${CACHED_SESSION}

${CACHED_PROGRESS}

Workflow Command: ${INTENT}
Arguments: ${ARGS}

Execute the workflow phase using the provided context.
---
```

### 4. Progressive Loading

```markdown
if flag --examples present:
    Load and show: .claude/skills/spec-${PHASE}/EXAMPLES.md

if flag --help present:
    Load and show: .claude/skills/spec-${PHASE}/REFERENCE.md

if flag --verbose present:
    Load shared resources:
    - shared/workflow-patterns.md
    - shared/integration-patterns.md
    - shared/state-management.md
```

### 5. Context-Aware Response

```markdown
If no arguments (interactive mode):
1. Parse current phase from CACHED_SESSION
2. Show brief status summary
3. Use AskUserQuestion with phase-appropriate options
4. Execute chosen option immediately
```

---

**Spec v3.0** - Token-efficient, context-aware specification workflow.

**Quick start**: `/spec init` → `/spec "Your feature"` → `/spec` → `/spec` → Done! 🚀

---

*Last Updated: 2025-10-31*
*Token Efficiency: 86% reduction vs v2.1*
*Progressive Disclosure: Load only what's needed*
