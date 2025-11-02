# Agent Coordination: Examples

Concrete examples of each coordination pattern in real-world scenarios.

## Example 1: Sequential Pattern - Document Processing Pipeline

### Scenario
Process a technical document through multiple stages: extraction → analysis → summarization → formatting

### User Request
"Process this API documentation through extraction, analysis, and summary stages"

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "sequential"
    sequential:
      enabled: true
      handoff_mode: "synchronous"
      checkpoint_between_agents: true
```

**Coordination Plan:**
```markdown
## Sequential Coordination Plan

1. Extractor Agent:
   - Input: Raw API documentation
   - Task: Extract endpoints, parameters, examples
   - Output: Structured data (JSON)

2. Analyzer Agent:
   - Input: Structured data from Extractor
   - Task: Identify patterns, detect inconsistencies
   - Output: Analysis report

3. Summarizer Agent:
   - Input: Analysis report from Analyzer
   - Task: Create executive summary
   - Output: High-level summary

4. Formatter Agent:
   - Input: Summary from Summarizer
   - Task: Format as Markdown with proper sections
   - Output: Final formatted documentation
```

**Task Tool Invocations:**
```markdown
Task 1: Extractor
  subagent_type: general-purpose
  prompt: "Extract all API endpoints, parameters, and examples from this documentation: {doc}"
  → Output: {"endpoints": [...], "parameters": [...]}

Task 2: Analyzer (waits for Task 1)
  subagent_type: general-purpose
  prompt: "Analyze this API structure for patterns and inconsistencies: {Task 1 output}"
  → Output: "Analysis: Found 3 patterns, 2 inconsistencies..."

Task 3: Summarizer (waits for Task 2)
  subagent_type: general-purpose
  prompt: "Create executive summary of this analysis: {Task 2 output}"
  → Output: "Summary: The API follows REST principles..."

Task 4: Formatter (waits for Task 3)
  subagent_type: general-purpose
  prompt: "Format this summary as Markdown documentation: {Task 3 output}"
  → Output: "# API Documentation\n## Summary\n..."
```

**Output:**
```markdown
# Sequential Coordination Complete

## Strategy: Sequential

## Results:
Final formatted API documentation with 4 processing stages completed.

## Agent Contributions:
- Extractor: Identified 12 endpoints, 48 parameters
- Analyzer: Found 3 RESTful patterns, flagged 2 inconsistencies
- Summarizer: Created 200-word executive summary
- Formatter: Generated clean Markdown with proper sections

## Metrics:
- Total Time: 2m 15s
- Success Rate: 100%
- Checkpoints: 3 (between each agent)
```

---

## Example 2: Parallel Pattern - Multi-Language Code Review

### Scenario
Review code changes across Python, TypeScript, and Go files simultaneously

### User Request
"Review these code changes in Python, TypeScript, and Go for security issues"

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "parallel"
    parallel:
      enabled: true
      max_concurrent_agents: 5
      collect_strategy: "all"
      timeout_per_agent: 600
```

**Coordination Plan:**
```markdown
## Parallel Coordination Plan

Independent Tasks (can run concurrently):
- Agent A: Review Python files (security, style, performance)
- Agent B: Review TypeScript files (security, type safety, performance)
- Agent C: Review Go files (security, idioms, performance)

Collect Strategy: "all" (wait for all agents, aggregate results)
```

**Task Tool Invocations (Single Message):**
```markdown
Message with 3 concurrent Task calls:

Task A: Python Reviewer
  subagent_type: general-purpose
  model: haiku
  prompt: "Review Python files for security, style, performance: {python_files}"

Task B: TypeScript Reviewer
  subagent_type: general-purpose
  model: haiku
  prompt: "Review TypeScript files for security, type safety, performance: {ts_files}"

Task C: Go Reviewer
  subagent_type: general-purpose
  model: haiku
  prompt: "Review Go files for security, idioms, performance: {go_files}"

→ All execute concurrently → Collect results
```

**Output:**
```markdown
# Parallel Coordination Complete

## Strategy: Parallel

## Results:
All language-specific reviews completed. Found 5 security issues, 12 style improvements.

## Agent Contributions:
### Python Reviewer:
- Security: 2 SQL injection vulnerabilities (lines 45, 78)
- Style: 5 PEP 8 violations
- Performance: 1 N+1 query issue

### TypeScript Reviewer:
- Security: 1 XSS vulnerability (line 123)
- Type Safety: 3 unsafe 'any' types
- Performance: 2 unnecessary re-renders

### Go Reviewer:
- Security: 2 unchecked errors (lines 34, 56)
- Idioms: 4 non-idiomatic patterns
- Performance: 1 goroutine leak

## Metrics:
- Total Time: 1m 32s (3x faster than sequential)
- Success Rate: 100%
- Parallelism: 3x (3 agents concurrently)
- Speedup: 3.2x vs sequential
```

---

## Example 3: Hierarchical Pattern - Feature Implementation

### Scenario
Implement a complex feature (user authentication) requiring decomposition and supervision

### User Request
"Implement user authentication with JWT tokens, password hashing, and email verification"

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "hierarchical"
    hierarchical:
      enabled: true
      supervisor_model: "sonnet"
      worker_model: "haiku"
      max_delegation_depth: 3
      supervisor_reviews_work: true
```

**Coordination Plan:**
```markdown
## Hierarchical Coordination Plan

Supervisor Agent (sonnet model):
  - Decomposes "user authentication" into subtasks
  - Delegates to specialized worker agents
  - Reviews all work
  - Synthesizes final implementation

Worker Agents (haiku model):
  - Worker A: JWT token generation/validation
  - Worker B: Password hashing (bcrypt)
  - Worker C: Email verification service
  - Worker D: Integration and testing
```

**Task Tool Invocation:**
```markdown
Task: Supervisor
  subagent_type: general-purpose
  model: sonnet
  prompt: "Implement user authentication with JWT, password hashing, email verification.
           Decompose into subtasks, delegate to workers, review their work."

Supervisor internally spawns workers:
  Worker A (JWT): Implement JWT token logic
  Worker B (Hashing): Implement bcrypt password hashing
  Worker C (Email): Implement email verification
  Worker D (Integration): Integrate components, write tests

Supervisor reviews each worker's output:
  - JWT implementation: ✅ Approved (secure algorithm, proper expiry)
  - Password hashing: ✅ Approved (strong salt, appropriate rounds)
  - Email verification: ⚠️ Revision requested (add rate limiting)
  → Worker C revises
  - Email verification (revised): ✅ Approved
  - Integration: ✅ Approved (comprehensive tests)

Supervisor synthesizes final implementation.
```

**Output:**
```markdown
# Hierarchical Coordination Complete

## Strategy: Hierarchical

## Results:
User authentication feature fully implemented with JWT, bcrypt hashing, and email verification.

## Hierarchy:
Supervisor Agent (Sonnet)
├─ JWT Worker: Generated token logic with RS256 algorithm
├─ Hashing Worker: Implemented bcrypt with 12 rounds
├─ Email Worker: Created verification service with rate limiting
└─ Integration Worker: Integrated all components, wrote 15 tests

## Supervisor Review:
- 4 initial submissions
- 1 revision request (email rate limiting)
- 5 approvals
- Final synthesis: Complete authentication system

## Metrics:
- Total Time: 4m 45s
- Worker Time: 3m 20s (4 workers)
- Supervisor Time: 1m 25s (decomposition + review)
- Revisions: 1
- Delegation Depth: 1 (no sub-workers spawned)
```

---

## Example 4: DAG Pattern - Build Pipeline with Dependencies

### Scenario
Execute build pipeline where tasks have dependencies (lint → build → test → deploy)

### User Request
"Run the full build pipeline: lint, type-check, build, unit tests, integration tests, deploy"

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "dag"
    dag:
      enabled: true
      auto_detect_dependencies: true
      critical_path_first: true
      parallel_non_dependent: true
```

**Coordination Plan:**
```markdown
## DAG Coordination Plan

Dependency Graph:
```
Lint (no deps) ────┐
                   ├─→ Build (depends on Lint, TypeCheck)
TypeCheck (no deps)┘      │
                          ├─→ Unit Tests (depends on Build)
                          │         │
                          │         ├─→ Deploy (depends on Unit, Integration)
                          │         │
                          └─→ Integration Tests (depends on Build)
                                    │
                                    └─→ Deploy
```

Critical Path: TypeCheck → Build → Integration Tests → Deploy (longest chain)

Execution Strategy:
- Stage 1: Lint + TypeCheck (parallel)
- Stage 2: Build (waits for Stage 1)
- Stage 3: Unit Tests + Integration Tests (parallel, wait for Build)
- Stage 4: Deploy (waits for all tests)
```

**Task Tool Invocations:**
```markdown
Stage 1 (no dependencies, run in parallel):
  Task A: Lint
    subagent_type: general-purpose
    model: haiku
    prompt: "Run ESLint on all source files"

  Task B: TypeCheck
    subagent_type: general-purpose
    model: haiku
    prompt: "Run TypeScript compiler (tsc --noEmit)"

  → Both run concurrently → Wait for completion

Stage 2 (depends on Lint + TypeCheck):
  Task C: Build
    subagent_type: general-purpose
    model: haiku
    prompt: "Build project (npm run build)"

  → Wait for completion

Stage 3 (depends on Build, run in parallel):
  Task D: Unit Tests
    subagent_type: general-purpose
    model: haiku
    prompt: "Run unit tests (npm test)"

  Task E: Integration Tests
    subagent_type: general-purpose
    model: haiku
    prompt: "Run integration tests (npm run test:integration)"

  → Both run concurrently → Wait for completion

Stage 4 (depends on all tests):
  Task F: Deploy
    subagent_type: general-purpose
    model: sonnet
    prompt: "Deploy to production (verify all checks passed)"
```

**Output:**
```markdown
# DAG Coordination Complete

## Strategy: DAG (Dependency Graph)

## Results:
Full build pipeline executed successfully. All checks passed, deployed to production.

## Execution Timeline:
### Stage 1 (Parallel):
- Lint: ✅ Passed (12s)
- TypeCheck: ✅ Passed (15s) ← Critical Path
→ Stage duration: 15s (parallel)

### Stage 2 (Sequential):
- Build: ✅ Success (32s) ← Critical Path
→ Stage duration: 32s

### Stage 3 (Parallel):
- Unit Tests: ✅ Passed (18s)
- Integration Tests: ✅ Passed (45s) ← Critical Path
→ Stage duration: 45s (parallel)

### Stage 4 (Sequential):
- Deploy: ✅ Deployed (23s) ← Critical Path
→ Stage duration: 23s

## Metrics:
- Total Time: 1m 55s (115s)
- Critical Path: TypeCheck → Build → Integration Tests → Deploy (115s)
- Parallelism Achieved: 2.4x
- Total Task Time: 145s (if sequential)
- Speedup: 1.26x vs sequential
```

---

## Example 5: Group Chat Pattern - Architecture Decision

### Scenario
Multiple agents collaborate to make complex architecture decision

### User Request
"Should we use microservices or monolith for our e-commerce platform? Need perspectives from different angles."

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "group_chat"
    group_chat:
      enabled: true
      max_agents: 4
      chat_manager_model: "sonnet"
      max_rounds: 10
      speaker_selection: "auto"
```

**Coordination Plan:**
```markdown
## Group Chat Coordination Plan

Chat Manager: Architecture Decision Facilitator (sonnet model)

Participants:
- Agent A: Scalability Expert (focuses on performance, scaling)
- Agent B: Operations Expert (focuses on deployment, maintenance)
- Agent C: Developer Experience Expert (focuses on DX, productivity)
- Agent D: Cost Analyst (focuses on infrastructure costs, ROI)

Max Rounds: 10
Speaker Selection: Auto (Chat Manager selects most relevant agent per round)
```

**Execution Flow:**
```markdown
Round 1:
  Chat Manager: "We need to decide: microservices or monolith for e-commerce platform?"
  → Selects: Scalability Expert
  Scalability Expert: "Microservices offer better scalability for e-commerce.
                       Independent scaling of catalog, cart, payment services.
                       However, initial complexity is higher."

Round 2:
  → Selects: Operations Expert
  Operations Expert: "Monolith is simpler to deploy initially. One deployment pipeline.
                      Microservices require orchestration (K8s), service mesh, monitoring.
                      But microservices enable independent deployments (less risk)."

Round 3:
  → Selects: Developer Experience Expert
  DX Expert: "Monolith is faster for initial development. Shared codebase, no service boundaries.
              Microservices slow down development initially but enable team autonomy later.
              For startup, monolith first, migrate to microservices when team grows."

Round 4:
  → Selects: Cost Analyst
  Cost Analyst: "Monolith: Lower initial infra costs (1-2 servers).
                 Microservices: Higher costs (multiple services, orchestration, networking).
                 Break-even point: ~50K users. Above that, microservices cost-effective due to efficient scaling."

Round 5:
  → Selects: Chat Manager
  Chat Manager: "Key question: What's your expected user base in 6 months?"
  [User provides: "10K users initially, 100K in 12 months"]

Round 6:
  → Selects: Scalability Expert
  Scalability Expert: "With 100K users projected, microservices make sense.
                       Start with 'modular monolith' - organized in modules that can extract later."

Round 7:
  → Selects: Operations Expert
  Operations Expert: "Agree. Modular monolith with clear service boundaries.
                      Use Docker from day 1. Prepare for microservices migration."

Round 8:
  → Selects: DX Expert
  DX Expert: "Modular monolith is the sweet spot. Single deployment but organized for future extraction."

Round 9:
  → Selects: Cost Analyst
  Cost Analyst: "Modular monolith optimal. Save costs now, easy migration at 50K users."

Round 10:
  → Selects: Chat Manager (Synthesis)
  Chat Manager: "Consensus reached. Recommendation: Modular Monolith."
```

**Output:**
```markdown
# Group Chat Coordination Complete

## Strategy: Group Chat

## Decision: Modular Monolith (Consensus)

## Rationale:
### Short-term (0-6 months, <50K users):
- ✅ Lower infrastructure costs
- ✅ Faster initial development
- ✅ Simpler operations

### Long-term (6-12 months, approaching 100K users):
- ✅ Clear service boundaries enable extraction
- ✅ Organized for microservices migration
- ✅ Scales to meet projected growth

## Agent Contributions:
### Scalability Expert:
Recommended microservices for scale but suggested modular monolith as pragmatic start

### Operations Expert:
Emphasized operational simplicity initially, with Docker for migration prep

### Developer Experience Expert:
Advocated modular monolith for speed + team autonomy

### Cost Analyst:
Quantified break-even (50K users), validated modular monolith for projected timeline

## Chat Statistics:
- Total Rounds: 10
- Contributions per Agent: 2-3
- Consensus Round: 9 (unanimous agreement)
- Decision Quality: High (all perspectives considered)

## Metrics:
- Total Time: 3m 15s
- Participants: 4 agents + 1 manager
- Consensus Achieved: Yes (round 9)
```

---

## Example 6: Event-Driven Pattern - CI/CD Automation

### Scenario
Automated CI/CD pipeline triggered by events (commit, PR, deploy)

### User Request
"Set up automated pipeline that responds to Git events: lint on commit, full tests on PR, deploy on merge to main"

### Execution

**Configuration:**
```yaml
agents:
  coordination:
    default_pattern: "event_driven"
    event_driven:
      enabled: true
      event_bus: "memory"
      retry_on_failure: true
      dead_letter_queue: true
```

**Coordination Plan:**
```markdown
## Event-Driven Coordination Plan

Event Bus: Memory-based event system

Event Subscriptions:
- Linter Agent: Subscribes to "git.commit" events
- Test Agent: Subscribes to "git.pull_request" events
- Deploy Agent: Subscribes to "git.merge.main" events
- Notifier Agent: Subscribes to all events (for notifications)

Event Flow:
1. Git commits trigger "git.commit" → Linter Agent
2. PR creation triggers "git.pull_request" → Test Agent
3. Merge to main triggers "git.merge.main" → Deploy Agent
4. All events → Notifier Agent (Slack notifications)
```

**Execution Scenarios:**

**Scenario A: Developer commits code**
```markdown
Event: git.commit
  data: { commit_id: "abc123", branch: "feature/auth", files: [...] }

→ Event Bus dispatches to subscribed agents

Linter Agent (subscribed to git.commit):
  Task: Run linter on changed files
  Result: ✅ Passed
  Emits: "lint.success"

Notifier Agent (subscribed to git.commit):
  Task: Send Slack notification
  Message: "Commit abc123 by @dev on feature/auth - Lint: ✅"
```

**Scenario B: Developer creates Pull Request**
```markdown
Event: git.pull_request
  data: { pr_id: 123, branch: "feature/auth → main", commits: [...] }

→ Event Bus dispatches

Test Agent (subscribed to git.pull_request):
  Task: Run full test suite
  Result: ❌ Failed (3 tests failing)
  Retry: Attempt 1/3 (retry_on_failure=true)
  Result: ❌ Failed (still failing)
  → Route to Dead Letter Queue
  Emits: "test.failure"

Notifier Agent (subscribed to git.pull_request):
  Task: Send Slack notification
  Message: "PR #123 by @dev - Tests: ❌ (3 failures)"
  Action: Post comment on PR with test results
```

**Scenario C: PR merged to main**
```markdown
Event: git.merge.main
  data: { pr_id: 123, commit_id: "def456", branch: "feature/auth" }

→ Event Bus dispatches

Deploy Agent (subscribed to git.merge.main):
  Task: Deploy to production
  Steps:
    1. Run pre-deploy checks ✅
    2. Build Docker image ✅
    3. Push to registry ✅
    4. Deploy to K8s ✅
  Result: ✅ Deployed
  Emits: "deploy.success"

Notifier Agent (subscribed to git.merge.main):
  Task: Send Slack notification
  Message: "🚀 Deployed PR #123 to production - feature/auth now live!"
```

**Output:**
```markdown
# Event-Driven Coordination Complete

## Strategy: Event-Driven

## Events Processed: 3
1. git.commit → Linter Agent
2. git.pull_request → Test Agent
3. git.merge.main → Deploy Agent

## Agent Activity:
### Linter Agent:
- Triggered: 1 time (git.commit)
- Success: 1
- Duration: 8s

### Test Agent:
- Triggered: 1 time (git.pull_request)
- Success: 0
- Failures: 1 (routed to DLQ after retries)
- Retries: 3
- Duration: 2m 15s

### Deploy Agent:
- Triggered: 1 time (git.merge.main)
- Success: 1
- Duration: 3m 45s

### Notifier Agent:
- Triggered: 3 times (all events)
- Notifications sent: 3 (Slack)
- Duration: <1s per notification

## Dead Letter Queue:
1 failed event: git.pull_request (test failures)
→ Manual intervention required to fix failing tests

## Metrics:
- Total Events: 3
- Successful Processing: 2/3 (67%)
- Failed (DLQ): 1/3 (33%)
- Average Processing Time: 2m 3s per event
- Retry Rate: 33% (1/3 events retried)
```

---

## Pattern Selection Guide

**Use Sequential when:**
- Tasks must happen in specific order
- Each task requires output from previous task
- Example: Document processing pipeline

**Use Parallel when:**
- Tasks are completely independent
- Need to maximize speed
- Example: Multi-language code review

**Use Hierarchical when:**
- Task requires decomposition
- Need supervision and quality review
- Example: Complex feature implementation

**Use DAG when:**
- Tasks have dependencies but some parallelism possible
- Need to optimize execution order
- Example: Build pipeline

**Use Group Chat when:**
- Need collaborative decision-making
- Multiple perspectives required
- Example: Architecture decisions

**Use Event-Driven when:**
- Tasks triggered by external events
- Need reactive automation
- Example: CI/CD pipelines

---

See reference.md for advanced configuration and troubleshooting.
