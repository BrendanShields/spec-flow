# Feature 003: Artifact Auto-Update Hooks

**Feature ID**: 003-artifact-auto-update-hooks
**Created**: 2024-10-31
**Priority**: P1
**Target Version**: 3.1.0
**Estimated Duration**: 2 weeks (80 hours)

---

## Product Vision

Automatically maintain consistency across Spec artifacts (session state, workflow progress, decisions log, changes planned/completed) through intelligent hooks that trigger on workflow events, eliminating manual synchronization and ensuring data integrity across team collaboration scenarios.

---

## Problem Statement

### Current Issues

1. **Manual Synchronization**: Users must manually update `.spec-state/` and `.spec-memory/` files after each workflow step
2. **Inconsistency Risk**: Easy to forget updating state files, leading to stale information
3. **Team Drift**: Multiple team members may create conflicting state changes
4. **Cognitive Overhead**: Developers need to remember what to update and when
5. **Error-Prone**: Manual updates can contain mistakes or miss required fields

### User Impact

- 30-45 seconds spent per command manually updating state files
- ~5-10 state update errors per feature (missed fields, wrong format)
- Team collaboration issues due to stale locks or assignments
- Loss of decision history when updates are forgotten
- Reduced trust in Spec's state accuracy

### Business Impact

- Lower adoption due to manual maintenance burden
- Team collaboration features unusable without reliable state
- Documentation drift (master spec becomes outdated)
- Reduced workflow efficiency

---

## Solution Overview

Implement a comprehensive hook system that automatically triggers on Spec command execution to:

1. **Detect Changes**: Monitor workflow state transitions
2. **Update State**: Automatically sync `.spec-state/session.json`
3. **Update Memory**: Automatically sync `.spec-memory/workflow.json`
4. **Regenerate Views**: Auto-generate markdown views from JSON
5. **Validate Consistency**: Ensure all artifacts are in sync
6. **Generate Master Spec**: Trigger regeneration when features change

---

## User Stories

### P1: Must Have

#### US-003.1: Post-Command State Update Hook

**As a** Spec user
**I want** state files to automatically update after each command
**So that** I don't have to manually maintain synchronization

**Acceptance Criteria**:
- ✅ Hook triggers after `/spec` command completion
- ✅ Updates `session.json` with current phase, progress, timestamps
- ✅ Regenerates `current-session.md` from JSON
- ✅ Validates JSON schema before committing
- ✅ Performance impact < 100ms per command
- ✅ Failures are non-blocking but logged

**Example**:
```bash
# User runs command
/spec plan

# Hook automatically:
# 1. Updates session.json (phase: "planning")
# 2. Updates workflow.json (progress metrics)
# 3. Regenerates current-session.md
# 4. Validates consistency
# 5. User sees: "✅ State synchronized"
```

---

#### US-003.2: Feature Completion Hook

**As a** Spec user
**I want** workflow metrics to auto-update when tasks complete
**So that** progress tracking is always accurate

**Acceptance Criteria**:
- ✅ Hook triggers when task marked complete
- ✅ Updates workflow.json with completion data
- ✅ Updates WORKFLOW-PROGRESS.md with metrics
- ✅ Moves task from CHANGES-PLANNED to CHANGES-COMPLETED
- ✅ Updates feature progress percentage
- ✅ Regenerates master spec if feature complete

**Example**:
```bash
# Task completes
/spec implement  # Completes T001

# Hook automatically:
# 1. Marks T001 complete in session.json
# 2. Updates workflow.json (completedTasks++, velocity)
# 3. Moves T001 to CHANGES-COMPLETED.md
# 4. Recalculates feature progress (15/53 = 28%)
# 5. User sees: "✅ T001 complete, 15/53 tasks (28%)"
```

---

#### US-003.3: Decision Capture Hook

**As a** Spec user
**I want** architectural decisions to auto-log to DECISIONS-LOG
**So that** I have a complete decision history

**Acceptance Criteria**:
- ✅ Hook triggers during `/spec plan` phase
- ✅ Detects ADR sections in plan.md
- ✅ Extracts decision title, context, decision, consequences
- ✅ Appends to `.spec-memory/decisions.json`
- ✅ Regenerates DECISIONS-LOG.md
- ✅ Includes timestamp, feature ID, author

**Example**:
```bash
# User creates plan with ADRs
/spec plan

# Hook automatically:
# 1. Parses plan.md for ADR-XXX sections
# 2. Extracts each decision
# 3. Appends to decisions.json:
#    {
#      "id": "ADR-007",
#      "title": "Command Router Architecture",
#      "date": "2024-10-31",
#      "feature": "002",
#      "author": "dev",
#      "decision": "Use bash case statement..."
#    }
# 4. Regenerates DECISIONS-LOG.md
# 5. User sees: "✅ Logged 6 architectural decisions"
```

---

#### US-003.4: Master Spec Regeneration Hook

**As a** Spec user
**I want** the master spec to auto-regenerate when features change
**So that** documentation is always current

**Acceptance Criteria**:
- ✅ Hook triggers after spec, plan, or task changes
- ✅ Triggers when feature completes
- ✅ Aggregates all features into master spec
- ✅ Includes architecture, decisions, metrics
- ✅ Atomic write (temp file + mv)
- ✅ Performance < 2 seconds for 50 features

**Example**:
```bash
# User creates new specification
/spec "Add payment integration"

# Hook automatically:
# 1. Adds feature to workflow.json
# 2. Regenerates master-spec.md:
#    - Product vision
#    - Architecture blueprint
#    - All feature specs
#    - All decisions
#    - Current metrics
# 3. User sees: "✅ Master spec regenerated (2,450 lines)"
```

---

### P2: Should Have

#### US-003.5: Pre-Commit Validation Hook

**As a** Spec user
**I want** validation before git commits
**So that** I never commit inconsistent state

**Acceptance Criteria**:
- ✅ Git pre-commit hook installed on init
- ✅ Validates session.json schema
- ✅ Validates workflow.json schema
- ✅ Checks JSON ↔ MD consistency
- ✅ Validates no stale locks (TTL expired)
- ✅ Blocks commit if validation fails
- ✅ Provides clear error messages

**Example**:
```bash
git commit -m "WIP feature"

# Hook automatically:
# 1. Validates session.json (schema check)
# 2. Validates workflow.json (schema check)
# 3. Checks session.json ↔ current-session.md match
# 4. Checks for expired locks
# 5. If valid: commit proceeds
# 6. If invalid: shows errors and blocks commit
```

---

#### US-003.6: Team Sync Hook

**As a** team member
**I want** automatic conflict detection when pulling changes
**So that** I don't overwrite teammate's work

**Acceptance Criteria**:
- ✅ Git post-merge hook installed on init
- ✅ Detects conflicting feature locks
- ✅ Warns if active feature modified by teammate
- ✅ Suggests resolving conflicts
- ✅ Auto-regenerates markdown from JSON
- ✅ Updates team dashboard

**Example**:
```bash
git pull origin main

# Hook automatically:
# 1. Checks for feature lock conflicts
# 2. Detects if current feature modified
# 3. Shows warning:
#    "⚠️  Feature 002 modified by @alice"
#    "   Your lock may conflict. Consider:"
#    "   - /spec team (view status)"
#    "   - /spec unlock 002 (release your lock)"
# 4. Regenerates all .md from .json
```

---

### P3: Nice to Have

#### US-003.7: Metrics Dashboard Auto-Update

**As a** Spec user
**I want** real-time metrics in my terminal
**So that** I see progress without running status commands

**Acceptance Criteria**:
- ✅ Hook updates terminal title with progress
- ✅ Shows "Feature 002 (28% complete)" in title bar
- ✅ Optional: tmux status bar integration
- ✅ Optional: iTerm2 badge integration
- ✅ Configurable via `SPEC_METRICS_DISPLAY`

**Example**:
```bash
# After any command:
# Terminal title: "Spec: 002-consolidation (28% • 15/53 tasks)"
# tmux status: "[Spec: 002 28%]"
# iTerm badge: "28%"
```

---

#### US-003.8: Hook Customization

**As a** power user
**I want** to add custom hooks
**So that** I can extend Spec for my workflow

**Acceptance Criteria**:
- ✅ Hook directory `.spec/hooks/`
- ✅ Supported events: post-command, pre-commit, post-merge
- ✅ Hooks receive event context (JSON)
- ✅ Hooks can be bash scripts or executables
- ✅ Documentation for writing custom hooks

**Example**:
```bash
# Custom hook: .spec/hooks/post-command/slack-notify.sh
#!/bin/bash
# Notify Slack when feature completes

if jq -e '.activeFeature.status == "complete"' .spec-state/session.json; then
  curl -X POST https://hooks.slack.com/... \
    -d "Feature ${FEATURE_ID} complete!"
fi
```

---

## Non-Functional Requirements

### Performance

- **Hook Execution Time**: < 100ms for typical updates
- **Master Spec Generation**: < 2 seconds for 50 features
- **Pre-Commit Validation**: < 500ms
- **Memory Usage**: < 50MB during hook execution

### Reliability

- **Non-Blocking**: Hook failures don't block workflow commands
- **Atomic Updates**: All state changes are atomic (temp + mv)
- **Error Recovery**: Failed hooks log errors and retry on next command
- **Validation**: Schema validation prevents corrupt state

### Usability

- **Transparent**: Hooks run automatically without user intervention
- **Configurable**: Can disable hooks via environment variables
- **Debuggable**: Verbose mode shows hook execution details
- **Error Messages**: Clear error messages when hooks fail

### Security

- **Sandboxing**: Custom hooks run in restricted environment
- **Input Validation**: All hook inputs validated
- **No External Dependencies**: Core hooks use only bash/jq

---

## Technical Architecture

### Hook System Components

```
.spec/
├── hooks/
│   ├── core/                      # Built-in hooks
│   │   ├── post-command.sh        # After every command
│   │   ├── pre-commit.sh          # Before git commit
│   │   ├── post-merge.sh          # After git pull/merge
│   │   └── on-task-complete.sh    # When task completes
│   ├── custom/                    # User-defined hooks
│   │   └── *.sh                   # Custom scripts
│   └── config.json                # Hook configuration
│
├── lib/
│   ├── hook-runner.sh             # Hook execution engine
│   ├── state-sync.sh              # State synchronization
│   └── validators.sh              # Schema validators
```

### Hook Configuration

```json
{
  "hooks": {
    "post-command": {
      "enabled": true,
      "timeout": 5000,
      "scripts": [
        "core/post-command.sh",
        "custom/notify.sh"
      ]
    },
    "pre-commit": {
      "enabled": true,
      "blocking": true,
      "timeout": 10000,
      "scripts": ["core/pre-commit.sh"]
    },
    "post-merge": {
      "enabled": true,
      "timeout": 5000,
      "scripts": ["core/post-merge.sh"]
    }
  },
  "validation": {
    "schema": true,
    "consistency": true,
    "locks": true
  }
}
```

### Hook Execution Flow

```
User Command
    ↓
/spec <subcommand>
    ↓
Execute Skill Logic
    ↓
Trigger post-command Hook
    ↓
┌─────────────────────────┐
│ Update session.json     │
│ Update workflow.json    │
│ Update decisions.json   │
│ Regenerate .md files    │
│ Validate schemas        │
│ Generate master spec    │
│ Update terminal title   │
└─────────────────────────┘
    ↓
Return to User
```

---

## Success Metrics

### Primary Metrics

- **State Update Automation**: 100% of workflow events auto-update state
- **Time Savings**: 30-45 seconds saved per command (no manual sync)
- **Error Reduction**: 90% fewer state inconsistencies vs manual updates
- **Hook Performance**: 95% of hooks complete in < 100ms

### Secondary Metrics

- **User Satisfaction**: 4.5/5 rating for automatic state management
- **Adoption**: 80% of users enable all hooks
- **Custom Hooks**: 20% of users write custom hooks
- **Support Tickets**: 50% reduction in state-related issues

---

## Dependencies

### Internal

- Feature 002 (Spec v3.0) must be complete (JSON state, skills)
- State management infrastructure (JSON ↔ MD)
- Schema validation system

### External

- `jq` 1.6+ for JSON processing
- `git` 2.0+ for git hooks
- Bash 4.0+ for associative arrays

---

## Risks & Mitigations

### HIGH: Hook Performance Impact

**Risk**: Hooks slow down commands significantly
**Probability**: Medium
**Impact**: High
**Mitigation**:
- Implement hooks asynchronously (background execution)
- Cache validation results
- Lazy regeneration (only when changed)
- Performance budgets enforced in tests

---

### MEDIUM: Hook Failure Cascades

**Risk**: One hook failure breaks subsequent hooks
**Probability**: Medium
**Impact**: Medium
**Mitigation**:
- Isolate hook execution (try/catch)
- Continue on failure, log errors
- Retry failed hooks on next command
- Clear error reporting

---

### LOW: Custom Hook Security

**Risk**: Malicious custom hooks compromise system
**Probability**: Low
**Impact**: Medium
**Mitigation**:
- Sandboxed execution environment
- Whitelist allowed commands
- Require explicit user opt-in for custom hooks
- Code review guidelines in documentation

---

## Open Questions

1. **Async vs Sync**: Should hooks run in background or block command completion?
   - Recommendation: Sync for critical (pre-commit), async for optional (metrics)

2. **Hook Ordering**: How to handle dependencies between hooks?
   - Recommendation: Explicit ordering in config.json

3. **Failure Modes**: Should command fail if hook fails?
   - Recommendation: Only for blocking hooks (pre-commit)

4. **Custom Hook API**: What context should custom hooks receive?
   - Recommendation: Full session.json + workflow.json as stdin

5. **Disable Mechanism**: How to temporarily disable hooks?
   - Recommendation: `SPEC_HOOKS_ENABLED=false` env var

---

## Timeline

- **Week 1**: Hook infrastructure + core hooks (post-command, on-task-complete)
- **Week 2**: Git hooks (pre-commit, post-merge) + custom hook support
- **Testing**: 2 days comprehensive testing
- **Documentation**: 1 day user guide + examples

**Total**: 2 weeks (80 hours)

---

## Next Steps

1. **Create Technical Plan**: Design hook architecture, APIs, and implementation strategy
2. **Break Into Tasks**: Detailed task breakdown with dependencies
3. **Begin Implementation**: Start with core hook infrastructure
4. **Test Thoroughly**: Unit tests, integration tests, performance tests
5. **Document**: User guide, examples, troubleshooting

---

**Specification Status**: ✅ Ready for Planning
**Next Phase**: `/spec plan` to create technical plan
**Created By**: Spec Workflow System
**Last Updated**: 2024-10-31
