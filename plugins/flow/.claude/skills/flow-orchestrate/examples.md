# Flow Orchestrate: Examples

## Example 1: Complete Greenfield Project

**User**: "Set up a new e-commerce platform with user authentication, product catalog, and checkout"

**Orchestration sequence**:
```
1. flow:init --type greenfield
   → Creates .flow/ structure

2. flow:blueprint
   → Interactive: Choose architecture (microservices)
   → Define tech stack (Node.js, React, PostgreSQL)

3. flow:specify "E-commerce platform with auth, catalog, checkout"
   → Generates comprehensive spec with P1/P2/P3 stories

4. flow:clarify
   → Asks: "Payment gateway preference?" → Stripe
   → Asks: "Inventory tracking needed?" → Yes

5. flow:plan
   → Creates technical design
   → API contracts, data models

6. flow:analyze
   → Validates consistency
   → All checks pass

7. flow:tasks
   → Generates 47 tasks across 5 phases

8. flow:implement
   → Executes all tasks with parallel processing
   → 12 files created, all tests passing
```

## Example 2: Add Feature to Existing Project

**User**: "Add real-time notifications to our app"

**Orchestration sequence**:
```
1. [Skip init - already initialized]

2. flow:specify "Real-time notifications"
   → Creates features/002-notifications/spec.md

3. flow:clarify
   → Asks: "Push notifications too?" → Yes
   → Asks: "Notification persistence?" → Yes, 30 days

4. flow:plan
   → WebSocket design
   → Notification service architecture

5. flow:tasks
   → 18 tasks generated

6. flow:implement
   → Implements with 6 parallel tasks
```

## Example 3: Quick POC Mode

**User**: "Quick POC for AI chatbot integration"

**Orchestration with POC mode**:
```
1. flow:init --type greenfield

2. [Skip blueprint - POC mode]

3. flow:specify "AI chatbot" --skip-validation
   → Minimal spec, no quality checks

4. [Skip clarify - POC mode]

5. flow:plan --minimal
   → Simple technical approach

6. flow:tasks --simple
   → 5 basic tasks

7. flow:implement --skip-checklists
   → Quick implementation
```

## Example 4: Resume Interrupted Workflow

**User**: "Continue where we left off"

**Orchestration resumes**:
```
Checking state...
Last completed: flow:plan
Next step: flow:tasks

Resuming from flow:tasks...

1. flow:tasks
   → Generate task list

2. flow:implement
   → Execute implementation
```

## Example 5: Selective Orchestration

**User**: "Just do the planning phase"

**Partial orchestration**:
```
1. flow:specify
   → Generate spec

2. flow:clarify
   → Resolve ambiguities

3. flow:plan
   → Create technical plan

[Stop as requested]
```