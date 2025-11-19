# Technical Plan: Workflow Subagents

**Feature ID**: 001-workflow-subagents
**Version**: 1.0.0
**Created**: 2025-11-19
**Status**: Active

## 1. System Architecture

### 1.1 High-Level Design

```
┌─────────────────────────────────────────────────┐
│                Orbit Orchestrator                │
│              (Main Workflow Controller)          │
└────────────┬────────────────────────┬────────────┘
             │                        │
             ▼                        ▼
    ┌────────────────┐       ┌────────────────┐
    │  Task Manager  │       │ State Manager  │
    │  (Parallelism) │       │ (Persistence)  │
    └────────┬────────┘      └────────┬────────┘
             │                         │
    ┌────────▼─────────────────────────▼────────┐
    │           Subagent Framework               │
    │     (Communication & Lifecycle Mgmt)       │
    └────────┬─────────────────────┬─────────────┘
             │                     │
    ┌────────▼────────┐   ┌───────▼────────┐
    │   Core Agents   │   │ Domain Agents  │
    │  - Implementer  │   │  - Researcher  │
    │  - Analyzer     │   │  - Validator   │
    └─────────────────┘   └────────────────┘
```

### 1.2 Component Responsibilities

**Orbit Orchestrator**
- Workflow phase management
- Subagent invocation decisions
- Progress tracking and reporting
- Error recovery coordination

**Task Manager**
- Dependency graph resolution
- Parallel execution scheduling
- Resource allocation and locking
- Result aggregation

**State Manager**
- Session persistence
- Checkpoint management
- Recovery state tracking
- Inter-agent communication state

**Subagent Framework**
- Lifecycle management (start/stop/restart)
- Message passing protocol
- Permission scoping
- Output streaming and buffering

### 1.3 Communication Patterns

**Request/Response Pattern**
```json
{
  "type": "request",
  "id": "req-001",
  "agent": "spec-implementer",
  "operation": "execute_task",
  "params": {
    "task_id": "T001",
    "context": {}
  }
}
```

**Event Streaming Pattern**
```json
{
  "type": "event",
  "agent": "spec-implementer",
  "event": "progress",
  "data": {
    "task_id": "T001",
    "percent": 45,
    "message": "Running tests..."
  }
}
```

## 2. Component Design

### 2.1 Subagent Definitions

**Location**: `.claude/agents/`

**Structure**:
```markdown
# Agent Name

## Purpose
Single-sentence description

## Tools Available
- Read, Write, Edit
- Bash, Grep, Glob
- Task (for sub-delegation)

## Input Contract
```yaml
task_id: string
feature_dir: path
options:
  parallel: boolean
  retry_count: number
```

## Output Contract
```yaml
status: success|failure|partial
results:
  files_modified: array
  tests_passed: boolean
  errors: array
```

## Workflow
1. Parse input
2. Execute operations
3. Validate results
4. Return structured output
```

### 2.2 Core Subagents

**spec-implementer**
- Purpose: Autonomous code generation and modification
- Tools: Read, Write, Edit, Bash, Grep
- Scope: Single task execution with test validation

**spec-researcher**
- Purpose: Technical research and ADR generation
- Tools: WebSearch, WebFetch, Write
- Scope: Library evaluation, best practices research

**consistency-analyzer**
- Purpose: Cross-artifact validation
- Tools: Read, Grep, Glob
- Scope: Spec/plan/task/code alignment

**specification-analyzer**
- Purpose: Specification quality validation
- Tools: Read, Write
- Scope: Completeness, clarity, testability checks

**codebase-analyzer**
- Purpose: Brownfield project analysis
- Tools: Read, Grep, Glob, Bash
- Scope: Architecture discovery, technical debt assessment

### 2.3 Parallelization Engine

**Dependency Resolution**
```javascript
class TaskGraph {
  constructor(tasks) {
    this.nodes = new Map();
    this.edges = new Map();
    this.buildGraph(tasks);
  }

  getParallelGroups() {
    const levels = [];
    const visited = new Set();
    const inDegree = this.calculateInDegree();

    while (visited.size < this.nodes.size) {
      const ready = [];
      for (const [id, degree] of inDegree) {
        if (degree === 0 && !visited.has(id)) {
          ready.push(id);
        }
      }

      if (ready.length === 0) {
        throw new Error('Circular dependency detected');
      }

      levels.push(ready);
      ready.forEach(id => {
        visited.add(id);
        this.updateInDegree(id, inDegree);
      });
    }

    return levels;
  }
}
```

## 3. Data Models

### 3.1 Subagent Session

```typescript
interface SubagentSession {
  id: string;
  agent: string;
  status: 'pending' | 'running' | 'complete' | 'failed';
  started_at: Date;
  completed_at?: Date;
  input: any;
  output?: any;
  errors?: string[];
  retry_count: number;
  parent_session?: string;
}
```

### 3.2 Task Execution Record

```typescript
interface TaskExecution {
  task_id: string;
  agent_id: string;
  session_id: string;
  started_at: Date;
  duration_ms: number;
  status: 'success' | 'failure' | 'partial';
  files_modified: string[];
  tests_run: number;
  tests_passed: number;
  metrics: {
    lines_added: number;
    lines_removed: number;
    complexity_delta: number;
  };
}
```

### 3.3 Workflow State

```typescript
interface WorkflowState {
  feature_id: string;
  phase: string;
  subagents_active: string[];
  parallel_groups: string[][];
  completed_tasks: string[];
  pending_tasks: string[];
  blocked_tasks: string[];
  checkpoint_state: any;
}
```

## 4. API Contracts

### 4.1 Subagent Invocation API

**Endpoint**: Internal Tool Call
```javascript
// Via Task tool
Task({
  subagent_type: "spec-implementer",
  description: "Execute task T001",
  prompt: "Implement the user authentication module according to task T001 specifications"
})
```

### 4.2 State Management API

**Save State**
```bash
save_subagent_state() {
  local agent_id=$1
  local state=$2
  echo "$state" > ".spec/state/agents/${agent_id}.json"
}
```

**Load State**
```bash
load_subagent_state() {
  local agent_id=$1
  cat ".spec/state/agents/${agent_id}.json" 2>/dev/null || echo "{}"
}
```

### 4.3 Communication Protocol

**Message Format**
```json
{
  "version": "1.0",
  "timestamp": "ISO8601",
  "source": "orchestrator|subagent",
  "target": "subagent_id|orchestrator",
  "type": "request|response|event",
  "payload": {}
}
```

## 5. Implementation Phases

### Phase 1: Foundation (40 hours)
1. Create subagent framework structure
2. Implement basic message passing
3. Set up state persistence
4. Create agent definition templates

### Phase 2: Core Agents (60 hours)
1. Implement spec-implementer agent
2. Implement consistency-analyzer agent
3. Implement specification-analyzer agent
4. Create agent test harness

### Phase 3: Orchestration (50 hours)
1. Build task dependency resolver
2. Implement parallel execution manager
3. Create result aggregation system
4. Add progress tracking

### Phase 4: Integration (40 hours)
1. Integrate with Orbit workflow
2. Update hooks for subagent events
3. Add metrics collection
4. Create monitoring dashboard

### Phase 5: Advanced Features (30 hours)
1. Implement spec-researcher agent
2. Add MCP protocol support
3. Create codebase-analyzer agent
4. Build retry mechanisms

## 6. Risk Analysis

### 6.1 Technical Risks

**Risk**: Context window exhaustion
- **Probability**: Medium
- **Impact**: High
- **Mitigation**: Implement context pruning, use focused agents

**Risk**: Subagent coordination failures
- **Probability**: Medium
- **Impact**: Medium
- **Mitigation**: Robust error handling, automatic retry logic

**Risk**: State corruption
- **Probability**: Low
- **Impact**: High
- **Mitigation**: Atomic writes, backup states, recovery procedures

### 6.2 Performance Risks

**Risk**: Parallel execution overhead
- **Probability**: Low
- **Impact**: Medium
- **Mitigation**: Intelligent batching, resource pooling

**Risk**: Slow subagent startup
- **Probability**: Medium
- **Impact**: Low
- **Mitigation**: Agent pre-warming, state caching

## 7. Architecture Decision Records

### ADR-001: Advisory Validation Mode
**Status**: Accepted
**Context**: Need to balance quality with workflow speed
**Decision**: Implement advisory mode as default, with optional blocking
**Consequences**: Faster workflows but requires discipline to address warnings

### ADR-002: Dependency-Based Parallelization
**Status**: Accepted
**Context**: Need to maximize parallel execution efficiency
**Decision**: Use topological sort for dependency resolution
**Consequences**: Optimal parallelization but requires accurate dependency specification

### ADR-003: JSON State Persistence
**Status**: Accepted
**Context**: Need simple, reliable state management
**Decision**: Use JSON files with atomic writes
**Consequences**: Human-readable states but limited to JSON-serializable data

### ADR-004: Optional MCP Support
**Status**: Accepted
**Context**: Balance integration capabilities with complexity
**Decision**: MCP as optional enhancement with fallback
**Consequences**: Wider compatibility but may miss advanced integrations

## 8. Testing Strategy

### 8.1 Unit Tests
- Subagent message parsing
- Dependency resolution algorithm
- State persistence operations

### 8.2 Integration Tests
- End-to-end subagent invocation
- Parallel execution scenarios
- Error recovery procedures

### 8.3 Performance Tests
- Subagent startup time (<2s)
- Parallel execution speedup (>40%)
- State persistence latency (<500ms)

## 9. Deployment Plan

### 9.1 Rollout Strategy
1. **Alpha**: Internal testing with single subagent
2. **Beta**: Limited release with core agents
3. **GA**: Full release with all agents

### 9.2 Migration Path
1. Existing workflows continue unchanged
2. Opt-in to subagent features via config
3. Gradual migration of skills to agents

## 10. Success Metrics

### 10.1 Performance Metrics
- Workflow completion time: -40% average
- Parallel task execution: >3 concurrent
- Context usage: -30% per workflow

### 10.2 Quality Metrics
- Specification validation coverage: 80%
- Consistency check pass rate: >95%
- Automatic retry success: >70%

### 10.3 User Metrics
- Manual interventions: -60%
- Error recovery time: -50%
- User satisfaction: >4.5/5

---
*End of Technical Plan*