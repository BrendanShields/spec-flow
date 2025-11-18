# Shared: Common Workflow Patterns

This file contains common workflow patterns used across multiple Spec skills.

## Overview

Spec follows a specification-driven development workflow with clear phases. This document defines common patterns that multiple skills reference.

## Core Workflow Phases

```
spec:init → spec:generate → spec:plan → spec:tasks → spec:implement
     ↓           ↓              ↓            ↓             ↓
  Setup      Define What    Design How   Break Down    Execute
```

### Optional Phases

- **spec:clarify** - Resolve ambiguities (after spec:generate if [CLARIFY] tags present)
- **spec:blueprint** - Define architecture (before spec:generate for new projects)
- **spec:update** - Update specs or add MCP integrations (anytime)
- **spec:analyze** - Validate consistency (before spec:implement)
- **spec:orchestrate** - Run full workflow automatically (replaces manual steps)

## Common Patterns

### Pattern 1: Feature Development (Greenfield)

**Use Case**: Adding new feature to existing project

**Workflow**:
```
1. spec:generate "Add user authentication system"
   → Creates {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}

2. spec:clarify (if needed)
   → Resolves any [CLARIFY] tags from spec

3. spec:plan
   → Creates {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} with technical design

4. spec:tasks
   → Creates {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks} with breakdown

5. spec:implement
   → Executes tasks, marks complete in changes-completed.md
```

**Files Created**:
- `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}` (requirements)
- `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan}` (technical design)
- `{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.tasks}` (task list)
- `{config.paths.memory}/decisions-log.md` (updated)
- `{config.paths.memory}/changes-completed.md` (updated)

### Pattern 2: Project Initialization (Brownfield)

**Use Case**: Adding Spec to existing codebase

**Workflow**:
```
1. spec:init --existing
   → Analyzes codebase, creates {config.paths.spec_root}/ structure

2. spec:discover
   → Deep analysis of existing patterns, tech debt

3. spec:blueprint
   → Document current architecture

4. spec:generate "First feature to add"
   → Normal feature workflow continues...
```

**Files Created**:
- `{config.paths.spec_root}/product-requirements.md`
- `{config.paths.spec_root}/architecture-blueprint.md`
- `{config.paths.memory}/*` (state tracking)

### Pattern 3: Requirements Update

**Use Case**: Changing requirements mid-development

**Workflow**:
```
1. spec:update "Change auth to use OAuth instead of JWT"
   → Updates spec.md with new requirements

2. spec:analyze
   → Checks consistency between spec, plan, tasks

3. spec:plan --update
   → Updates plan.md with new technical approach

4. spec:tasks --update
   → Adjusts task list based on new plan

5. spec:implement --continue
   → Continues implementation from current progress
```

**State Updates**:
- Moves old tasks to changes-completed.md
- Adds new tasks to changes-planned.md
- Logs decision in decisions-log.md

### Pattern 4: Full Automation

**Use Case**: Run entire workflow end-to-end

**Workflow**:
```
1. spec:orchestrate "Add payment processing"
   → Runs: generate → plan → tasks → implement
   → Interactive prompts for clarifications
   → Saves checkpoints at each phase
```

**Benefits**:
- Single command for complete workflow
- Automatic phase transitions
- Built-in validation checkpoints
- Progress tracking

### Pattern 5: Parallel Feature Development

**Use Case**: Working on multiple features simultaneously

**Workflow**:
```
# Feature A
1. spec:generate "Add search functionality"
   → Creates {config.paths.features}/{config.naming.feature_directory}/

# Feature B (parallel)
2. spec:generate "Add notification system"
   → Creates {config.paths.features}/{config.naming.feature_directory}/

# Complete Feature A
3. spec:plan (for feature 002)
4. spec:tasks (for feature 002)
5. spec:implement (for feature 002)

# Complete Feature B
6. spec:plan (for feature 003)
7. spec:tasks (for feature 003)
8. spec:implement (for feature 003)
```

**State Management**:
- `{config.paths.state}/current-session.md` tracks active feature
- `{config.paths.memory}/workflow-progress.md` tracks all features
- Each feature has independent directory

## Common Sub-Patterns

### Phase Transition Pattern

**When transitioning between phases**:

```markdown
1. Save current phase checkpoint
   - Write to {config.paths.state}/checkpoints/

2. Update session state
   - Update current-session.md with new phase

3. Update progress tracking
   - Update workflow-progress.md with phase completion

4. Validate prerequisites
   - Check required files exist
   - Validate file format/content

5. Proceed to next phase
```

### Error Recovery Pattern

**When errors occur during workflow**:

```markdown
1. Log error details
   - What failed
   - Current phase
   - Files affected

2. Attempt automatic recovery
   - Retry once with different approach
   - Fall back to previous checkpoint if available

3. If recovery fails:
   - Save current state
   - Notify user with clear error
   - Provide recovery options:
     a. Resume from last checkpoint
     b. Skip to next phase
     c. Restart current phase
     d. Manual intervention
```

### Validation Pattern

**At key workflow checkpoints**:

```markdown
1. Validate file structure
   - Required files exist
   - Files are properly formatted
   - No corrupted content

2. Validate consistency
   - spec.md aligns with plan.md
   - tasks.md covers all plan requirements
   - No orphaned tasks

3. Validate completeness
   - All [CLARIFY] tags resolved
   - All P1 user stories addressed
   - All critical tasks included

4. Report validation results
   - Pass: Continue to next phase
   - Warnings: Show but allow continue
   - Errors: Block until resolved
```

### MCP Integration Pattern

**When external tool integration available**:

```markdown
1. Detect MCP availability
   - Check for MCP tools in context
   - Read claude.md for configuration

2. Ask user preference
   - "Sync with JIRA?" (yes/no/always/never)
   - Remember preference for session

3. Execute with fallback
   - Try MCP operation
   - If fails, continue locally
   - Log both local and MCP artifacts

4. Store references
   - Save JIRA issue key in spec metadata
   - Save Confluence URL in plan metadata
   - Track in workflow-progress.md
```

## State Management Patterns

### Reading State

**Pattern for skills reading state**:

```markdown
1. Load session state
   - Read {config.paths.state}/current-session.md
   - Extract: current feature, current phase, active tasks

2. Load workflow progress
   - Read {config.paths.memory}/workflow-progress.md
   - Extract: all features, completion status

3. Load relevant artifacts
   - If in planning phase: Read spec.md
   - If in tasks phase: Read spec.md + plan.md
   - If in implement phase: Read tasks.md

4. Cache in memory
   - Don't re-read unless explicitly invalidated
```

### Writing State

**Pattern for skills updating state**:

```markdown
1. Read current state first
   - Ensure we have latest version
   - Avoid overwriting concurrent changes

2. Update relevant sections
   - Modify only what changed
   - Preserve other data

3. Write atomically
   - Write to temp file first
   - Move/rename to actual location
   - Prevents corruption from interruption

4. Update timestamp
   - Add "Last Updated" field
   - Track who/what updated (skill name)
```

## Usage in Skills

**When to reference this file**:

```markdown
## In skill.md:

For common workflow patterns, see: `docs/patterns/workflow-patterns.md`
For MCP integration patterns, see: `docs/patterns/integration-patterns.md`
For state management details, see: `docs/patterns/state-management.md`

## When to load:

- User asks about workflow
- User asks "what's next?"
- Skill needs to understand phase transitions
- Error recovery needed
```

## Best Practices

1. **Always validate before phase transition** - Catch errors early
2. **Save checkpoints frequently** - Enable recovery from failures
3. **Update state atomically** - Prevent corruption
4. **Provide clear next steps** - User always knows what to do
5. **Support resumption** - Always allow resuming from any phase
6. **Log decisions** - Maintain audit trail in decisions-log.md
7. **Graceful degradation** - Continue workflow even if MCP fails

## Anti-Patterns to Avoid

❌ **Skipping validation** - Leads to cascading errors
❌ **Not saving checkpoints** - Can't recover from failures
❌ **Hardcoding phase order** - Limits flexibility
❌ **Ignoring state files** - Loses context between sessions
❌ **Blocking on MCP** - Should never prevent workflow
❌ **Overwriting without reading** - Data loss risk

## Related Files

- `docs/patterns/integration-patterns.md` - MCP integration details
- `docs/patterns/state-management.md` - State file specifications
- Individual skill REFERENCEs for skill-specific patterns

---

**Last Updated**: 2025-10-31
**Used By**: All spec:* skills
**Token Size**: ~1,400 tokens
