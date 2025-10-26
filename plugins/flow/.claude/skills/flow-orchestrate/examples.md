# Flow Orchestrate Examples

## 1. Complete Greenfield Project

**User**: "Set up a new e-commerce platform"

**Sequence**:
```
flow:init → Creates .flow/ structure
flow:blueprint → Architecture (microservices) + tech stack (Node/React/PostgreSQL)
flow:specify → Comprehensive spec with P1/P2/P3 stories
flow:clarify → Resolves: payment gateway (Stripe), inventory tracking (Yes)
flow:plan → Technical design, API contracts, data models
flow:analyze → Validates consistency (all checks pass)
flow:tasks → Generates 47 tasks across 5 phases
flow:implement → Executes tasks, creates 12 files, all tests passing
```

**Duration**: ~13 minutes

## 2. Add Feature to Existing Project

**User**: "Add real-time notifications"

**Sequence**:
```
[Skips init - already initialized]
flow:specify → Creates features/002-notifications/spec.md
flow:clarify → Confirms push notifications, 30-day persistence
flow:plan → WebSocket design + notification service architecture
flow:tasks → Generates 18 tasks
flow:implement → Implements with 6 parallel tasks
```

**Duration**: ~8 minutes

## 3. Quick POC Mode

**User**: "Quick POC for AI chatbot"

**Sequence**:
```
flow:init
[Skips blueprint - POC mode]
flow:specify --skip-validation → Minimal spec
[Skips clarify - POC mode]
flow:plan --minimal → Simple technical approach
flow:tasks --simple → 5 basic tasks
flow:implement --skip-checklists → Quick implementation
```

**Duration**: ~3 minutes

## 4. Resume Interrupted Workflow

**User**: "Continue where we left off"

**Sequence**:
```
[Detects state: last completed flow:plan]
flow:tasks → Generate task list
flow:implement → Execute implementation
```

## 5. Selective Orchestration

**User**: "Just do the planning phase"

**Sequence**:
```
flow:specify → Generate spec
flow:clarify → Resolve ambiguities
flow:plan → Create technical plan
[Stops as requested - no implementation]
```

For detailed configuration options and advanced usage, see [REFERENCE.md](./REFERENCE.md).