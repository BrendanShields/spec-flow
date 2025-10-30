# Flow Orchestrate Examples

## 1. Complete Greenfield Project

**User**: "Set up a new e-commerce platform"

**Sequence**:
```
specter:init → Creates .specter/ structure
specter:blueprint → Architecture (microservices) + tech stack (Node/React/PostgreSQL)
specter:specify → Comprehensive spec with P1/P2/P3 stories
specter:clarify → Resolves: payment gateway (Stripe), inventory tracking (Yes)
specter:plan → Technical design, API contracts, data models
specter:analyze → Validates consistency (all checks pass)
specter:tasks → Generates 47 tasks across 5 phases
specter:implement → Executes tasks, creates 12 files, all tests passing
```

**Duration**: ~13 minutes

## 2. Add Feature to Existing Project

**User**: "Add real-time notifications"

**Sequence**:
```
[Skips init - already initialized]
specter:specify → Creates features/002-notifications/spec.md
specter:clarify → Confirms push notifications, 30-day persistence
specter:plan → WebSocket design + notification service architecture
specter:tasks → Generates 18 tasks
specter:implement → Implements with 6 parallel tasks
```

**Duration**: ~8 minutes

## 3. Quick POC Mode

**User**: "Quick POC for AI chatbot"

**Sequence**:
```
specter:init
[Skips blueprint - POC mode]
specter:specify --skip-validation → Minimal spec
[Skips clarify - POC mode]
specter:plan --minimal → Simple technical approach
specter:tasks --simple → 5 basic tasks
specter:implement --skip-checklists → Quick implementation
```

**Duration**: ~3 minutes

## 4. Resume Interrupted Workflow

**User**: "Continue where we left off"

**Sequence**:
```
[Detects state: last completed specter:plan]
specter:tasks → Generate task list
specter:implement → Execute implementation
```

## 5. Selective Orchestration

**User**: "Just do the planning phase"

**Sequence**:
```
specter:specify → Generate spec
specter:clarify → Resolve ambiguities
specter:plan → Create technical plan
[Stops as requested - no implementation]
```

For detailed configuration options and advanced usage, see [REFERENCE.md](./REFERENCE.md).