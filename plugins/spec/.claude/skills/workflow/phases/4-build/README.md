# Phase 4: Build Feature

Break down technical plan into executable tasks and implement the feature.

## Purpose

Transform technical plan into actionable tasks with clear dependencies, then execute implementation with progress tracking.

## Core Workflow

### tasks/ ⭐ REQUIRED
**Purpose**: Break down plan into executable tasks
**Invocation**: `/spec tasks`
**When**: Technical plan complete from Phase 3
**Duration**: 20-45 minutes
**Output**: `tasks.md` with task IDs, priorities, dependencies, parallel markers

**Usage**: Always run to create task breakdown - identifies dependencies and parallel work opportunities

### implement/ ⭐ REQUIRED
**Purpose**: Execute implementation tasks with progress tracking
**Invocation**: `/spec implement`
**When**: tasks.md exists with defined tasks
**Duration**: 2-20 hours (varies by feature complexity)
**Output**: Working feature with passing tests, completed tasks

**Usage**: Always run to execute implementation - delegates to implementer subagent for parallel execution

## Workflow Patterns

**Sequential Execution**:
```
tasks/ ⭐ → implement/ ⭐ → All tasks complete
```

**Parallel Execution**:
```
tasks/ ⭐ (identify [P] tasks) → implement/ --parallel ⭐ → All tasks complete
```

**Filtered Implementation**:
```
tasks/ ⭐ → implement/ --filter=P1 ⭐ → Review → implement/ --filter=P2 ⭐
```

**Interrupted Workflow**:
```
tasks/ ⭐ → implement/ ⭐ → [Interruption] → implement/ --continue ⭐
```

## Exit Criteria

Ready to complete Phase 4 when:
- ✅ All P1 tasks completed (implement/ complete)
- ✅ All tests passing
- ✅ Code committed to version control
- ✅ Acceptance criteria satisfied
- ✅ No critical bugs remaining
- ✅ Feature functional in target environment

Optional:
- ⚪ P2 tasks completed (should have)
- ⚪ P3 tasks completed (nice to have)

## Navigation

**Functions in this phase**:
- [tasks/](./tasks/) - Break down into tasks ⭐
- [implement/](./implement/) - Execute implementation ⭐

**Previous phase**: [Phase 3: Design Solution](../3-design/)  
**Next phase**: [Phase 5: Track Progress](../5-track/) OR new feature

---

⭐ = Core workflow (required)  
🔧 = Supporting tool (contextual)
