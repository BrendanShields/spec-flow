---
name: agent-coordination
description: Use when orchestrating multiple AI agents, need parallel task execution, coordinating complex workflows, or mentions "multi-agent", "agent coordination", "parallel agents", "hierarchical agents", "dependency graph" - implements 6 coordination strategies (Sequential, Parallel, Hierarchical, DAG, Group Chat, Event-Driven) with config-driven orchestration. Outputs coordinated agent execution plans with dependency tracking and progress monitoring.
allowed-tools: Read, Write, Edit, Bash, Task, AskUserQuestion
---

# Agent Coordination: Multi-Agent Orchestration Strategies

Comprehensive multi-agent coordination system implementing 6 proven orchestration patterns with dependency tracking, parallel execution, and progress monitoring.

## What This Skill Does

- **Analyzes** user requirements to determine optimal coordination strategy
- **Designs** agent coordination plans with dependency graphs
- **Orchestrates** multiple agents using Sequential, Parallel, Hierarchical, DAG, Group Chat, or Event-Driven patterns
- **Tracks** agent execution progress with real-time monitoring
- **Optimizes** execution order using critical path analysis
- **Handles** agent failures with retry logic and dead-letter queues
- **Validates** coordination configuration from `.claude/.spec-config.yml`
- **Reports** comprehensive coordination results with metrics

## When to Use

1. **Complex workflows** requiring multiple specialized agents
2. **Parallel execution** of independent tasks
3. **Hierarchical decomposition** of large problems (supervisor/worker pattern)
4. **Dependency management** between tasks (DAG-based coordination)
5. **Collaborative analysis** requiring multiple agent perspectives (group chat)
6. **Event-driven automation** responding to system events
7. User mentions: "orchestrate agents", "parallel tasks", "multi-agent system"
8. User asks: "how do I coordinate multiple agents?" or "can agents work together?"

## Execution Flow

### Phase 1: Configuration Loading

Read coordination configuration from `.claude/.spec-config.yml`:

```yaml
agents:
  coordination:
    default_pattern: "hierarchical"
    sequential: { enabled: true, handoff_mode: "synchronous" }
    parallel: { enabled: true, max_concurrent_agents: 5 }
    hierarchical: { enabled: true, supervisor_model: "sonnet" }
    dag: { enabled: true, auto_detect_dependencies: true }
    group_chat: { enabled: false, max_agents: 4 }
    event_driven: { enabled: true, event_bus: "memory" }
```

**Actions:**
1. Use Read tool to load `.claude/.spec-config.yml`
2. Parse `agents.coordination` section
3. Identify enabled patterns
4. Extract pattern-specific settings (max_concurrent, models, timeouts)
5. Validate configuration (check for conflicts, missing required fields)

### Phase 2: Strategy Selection

Analyze user request and select optimal coordination pattern:

**Decision Algorithm:**
```
Does task have explicit dependencies?
├─ YES with no parallelism → Sequential Pattern
└─ YES with parallelism possible → DAG Pattern

Are subtasks completely independent?
├─ YES → Parallel Pattern
└─ NO → Check other factors

Does task need decomposition into specialized roles?
├─ YES with supervision → Hierarchical Pattern
└─ NO → Continue evaluation

Does task need collaborative discussion?
├─ YES → Group Chat Pattern
└─ NO → Continue evaluation

Is task triggered by system events?
├─ YES → Event-Driven Pattern
└─ DEFAULT → Use agents.coordination.default_pattern
```

**Ask user for confirmation** using AskUserQuestion if multiple strategies are viable.

### Phase 3: Agent Plan Generation

Create coordination plan based on selected strategy:

#### Sequential Pattern
```markdown
## Sequential Coordination Plan

**Pattern**: Linear chain where each agent processes previous output
**Handoff Mode**: [synchronous|asynchronous from config]
**Checkpoints**: [true|false from config]

### Execution Order:
1. Agent A: [task description]
   - Input: [user request]
   - Output: [intermediate result]
   - Next: Agent B

2. Agent B: [task description]
   - Input: [Agent A output]
   - Output: [refined result]
   - Next: Agent C

3. Agent C: [task description]
   - Input: [Agent B output]
   - Output: [final result]
   - Next: Complete

### Execution:
For each agent sequentially:
- Invoke agent using Task tool with appropriate subagent_type
- Wait for completion (synchronous) or monitor (asynchronous)
- Pass output to next agent in chain
- Insert checkpoint if config enables
```

#### Parallel Pattern
```markdown
## Parallel Coordination Plan

**Pattern**: Independent tasks executed concurrently
**Max Concurrent**: [from config: max_concurrent_agents]
**Collect Strategy**: [all|first|any|majority from config]
**Timeout**: [from config: timeout_per_agent]

### Parallel Agents:
- Agent A: [independent task 1]
- Agent B: [independent task 2]
- Agent C: [independent task 3]
- Agent D: [independent task 4]

### Execution:
1. Invoke all agents concurrently using multiple Task tool calls in single message
2. Monitor completion of each agent
3. Collect results based on strategy:
   - **all**: Wait for all agents, aggregate results
   - **first**: Return first completion, cancel others
   - **any**: Accept any successful completion
   - **majority**: Wait for majority consensus
4. Handle timeouts per agent
```

#### Hierarchical Pattern
```markdown
## Hierarchical Coordination Plan

**Pattern**: Supervisor coordinates worker agents
**Supervisor Model**: [from config: supervisor_model]
**Worker Model**: [from config: worker_model]
**Max Depth**: [from config: max_delegation_depth]
**Review Work**: [from config: supervisor_reviews_work]

### Hierarchy:
```
Supervisor Agent (Level 0)
├─ Worker A: [subtask 1]
│  ├─ Sub-worker A1: [granular task] (if depth < max)
│  └─ Sub-worker A2: [granular task]
├─ Worker B: [subtask 2]
└─ Worker C: [subtask 3]
```

### Execution:
1. Invoke supervisor agent using Task tool (model: [supervisor_model])
   - Supervisor decomposes task into subtasks
   - Supervisor delegates to worker agents
2. Supervisor spawns worker agents (model: [worker_model])
   - Each worker executes specialized subtask
   - Workers may spawn sub-workers (if depth < max_delegation_depth)
3. Supervisor collects worker results
4. If supervisor_reviews_work=true:
   - Supervisor validates each result
   - Supervisor may request revisions
5. Supervisor synthesizes final response
```

#### DAG Pattern
```markdown
## DAG Coordination Plan

**Pattern**: Tasks with dependencies, parallel where possible
**Auto-Detect**: [from config: auto_detect_dependencies]
**Critical Path First**: [from config: critical_path_first]
**Parallel Non-Dependent**: [from config: parallel_non_dependent]

### Dependency Graph:
```
Task A (no dependencies) ─┐
Task B (no dependencies) ─┼─→ Task D (depends on A, B)
Task C (no dependencies) ─┘                │
                                           ├─→ Task F (depends on D, E)
Task E (depends on C) ────────────────────┘
```

### Execution:
1. Build dependency graph:
   - If auto_detect_dependencies=true: Analyze tasks, identify dependencies
   - Otherwise: Use explicit dependencies from user
2. Identify ready tasks (no unmet dependencies)
3. If critical_path_first=true:
   - Calculate critical path (longest dependent chain)
   - Prioritize critical path tasks
4. Execute ready tasks:
   - If parallel_non_dependent=true: Run independent tasks concurrently
   - Otherwise: Run sequentially
5. As tasks complete, mark dependencies as met
6. Repeat steps 2-5 until all tasks complete
```

#### Group Chat Pattern
```markdown
## Group Chat Coordination Plan

**Pattern**: Multiple agents collaborate through shared conversation
**Max Agents**: [from config: max_agents]
**Chat Manager Model**: [from config: chat_manager_model]
**Max Rounds**: [from config: max_rounds]
**Speaker Selection**: [from config: speaker_selection]

### Chat Participants:
- Agent A: [role/expertise]
- Agent B: [role/expertise]
- Agent C: [role/expertise]
- Chat Manager: [orchestrator]

### Execution:
1. Initialize shared conversation thread
2. Chat Manager posts initial problem
3. For each round (max: [max_rounds]):
   - Select next speaker based on [speaker_selection]:
     - **auto**: Chat Manager selects most relevant agent
     - **round_robin**: Agents speak in order
     - **random**: Random agent selection
     - **manual**: User selects speaker
   - Selected agent contributes to conversation
   - All agents observe and update context
4. Chat Manager synthesizes consensus or final decision
5. Output collaborative solution
```

#### Event-Driven Pattern
```markdown
## Event-Driven Coordination Plan

**Pattern**: Agents react to events
**Event Bus**: [from config: event_bus]
**Retry on Failure**: [from config: retry_on_failure]
**Dead Letter Queue**: [from config: dead_letter_queue]

### Event Subscriptions:
- Agent A: [event types]
- Agent B: [event types]
- Agent C: [event types]

### Execution:
1. Initialize event bus ([event_bus]: memory|redis|kafka)
2. Register agent subscriptions:
   - Each agent subscribes to relevant event types
3. Emit triggering event(s)
4. Event bus dispatches to subscribed agents
5. Agents process events independently:
   - If retry_on_failure=true: Retry failed processing
   - If dead_letter_queue=true: Route failed events to DLQ
6. Collect agent responses
7. Emit follow-up events if needed
```

### Phase 4: Agent Invocation

Execute coordination plan using Task tool:

**Sequential:**
```markdown
Sequential invocations with output chaining:

Task tool (subagent_type: agent-a, prompt: "task details", model: haiku)
→ Wait for completion → Extract output
→ Task tool (subagent_type: agent-b, prompt: "task with {agent-a output}", model: haiku)
→ Wait for completion → Extract output
→ Continue chain...
```

**Parallel:**
```markdown
Single message with multiple Task tool calls:

Message:
  Task tool (subagent_type: agent-a, model: haiku)
  Task tool (subagent_type: agent-b, model: haiku)
  Task tool (subagent_type: agent-c, model: haiku)
  Task tool (subagent_type: agent-d, model: haiku)

→ All execute concurrently → Collect results
```

**Hierarchical:**
```markdown
Supervisor spawns workers:

Task tool (subagent_type: supervisor, model: sonnet)
  → Supervisor internally invokes workers:
     Task tool (subagent_type: worker-a, model: haiku)
     Task tool (subagent_type: worker-b, model: haiku)
  → Supervisor reviews and synthesizes
```

**DAG:**
```markdown
Stage-based execution respecting dependencies:

Stage 1 (no dependencies):
  Task tool (subagent_type: task-a, model: haiku)
  Task tool (subagent_type: task-b, model: haiku)
  Task tool (subagent_type: task-c, model: haiku)
→ Wait for Stage 1 completion

Stage 2 (dependencies met):
  Task tool (subagent_type: task-d, prompt: "depends on {a, b}", model: haiku)
  Task tool (subagent_type: task-e, prompt: "depends on {c}", model: haiku)
→ Wait for Stage 2 completion

Stage 3 (all dependencies met):
  Task tool (subagent_type: task-f, prompt: "depends on {d, e}", model: sonnet)
→ Final result
```

### Phase 5: Progress Monitoring

Track agent execution with real-time updates:

1. **Initialize progress tracker:**
   ```markdown
   ## Agent Coordination Progress

   Strategy: [pattern name]
   Total Agents: [count]
   Started: [timestamp]

   ### Status:
   - Agent A: ⏳ Running (started: [time])
   - Agent B: ⏳ Running (started: [time])
   - Agent C: ⏸️  Pending (waiting for: Agent A)
   - Agent D: ⏸️  Pending (waiting for: Agent A, Agent B)
   ```

2. **Update as agents complete:**
   ```markdown
   - Agent A: ✅ Complete (duration: 45s)
   - Agent B: ⏳ Running (elapsed: 32s)
   - Agent C: ⏳ Running (started: [time]) [dependency met]
   - Agent D: ⏸️  Pending (waiting for: Agent B)
   ```

3. **Handle failures:**
   ```markdown
   - Agent B: ❌ Failed (error: timeout after 600s)
     Retry 1/3: ⏳ Running
   ```

### Phase 6: Result Aggregation

Collect and synthesize agent results:

1. **Collect outputs** from all agents (via Task tool results)
2. **Validate completeness** (all required agents completed)
3. **Check quality** (results meet acceptance criteria)
4. **Synthesize** final response:
   - Combine complementary results
   - Resolve conflicts (if any)
   - Highlight consensus findings
   - Note dissenting opinions (for group chat)

### Phase 7: Metrics & Reporting

Generate coordination metrics:

```markdown
## Coordination Results

### Strategy: [pattern name]
### Execution Time: [total duration]
### Agents Involved: [count]

### Performance:
- Total Tasks: [count]
- Successful: [count] ([percentage]%)
- Failed: [count] ([percentage]%)
- Retried: [count]

### Timing:
- Fastest Agent: [name] ([duration])
- Slowest Agent: [name] ([duration])
- Average Duration: [time]
- Critical Path: [task chain] ([total time])

### Parallelism Achieved:
- Concurrent Stages: [count]
- Parallelism Factor: [ratio] (ideal: [max_concurrent])
- Idle Time: [duration]

### Resource Usage:
- Supervisor Tokens: [count] (model: [name])
- Worker Tokens: [count] (model: [name])
- Total Tokens: [count]

### Recommendations:
- [Optimization suggestion 1]
- [Optimization suggestion 2]
```

## Configuration Reference

All coordination behavior is configured via `.claude/.spec-config.yml`:

```yaml
agents:
  coordination:
    default_pattern: "hierarchical"  # Default strategy

    sequential:
      enabled: true
      handoff_mode: "synchronous"    # Wait for each agent
      checkpoint_between_agents: true

    parallel:
      enabled: true
      max_concurrent_agents: 5       # Max parallel executions
      collect_strategy: "all"        # all | first | any | majority
      timeout_per_agent: 600

    hierarchical:
      enabled: true
      supervisor_model: "sonnet"     # Smart coordinator
      worker_model: "haiku"          # Fast execution
      max_delegation_depth: 3
      supervisor_reviews_work: true

    dag:
      enabled: true
      auto_detect_dependencies: true
      critical_path_first: true
      parallel_non_dependent: true

    group_chat:
      enabled: false
      max_agents: 4
      chat_manager_model: "sonnet"
      max_rounds: 10
      speaker_selection: "auto"

    event_driven:
      enabled: true
      event_bus: "memory"
      retry_on_failure: true
      dead_letter_queue: true
```

## Error Handling

### Configuration Errors
- **Missing config file**: Use default settings, warn user
- **Invalid pattern name**: Fall back to default_pattern
- **Conflicting settings**: Resolve with priority order, log warning

### Execution Errors
- **Agent timeout**: Retry if retry_on_failure=true, otherwise fail gracefully
- **Agent failure**: Invoke retry logic, route to DLQ if exhausted
- **Dependency deadlock**: Detect cycles in DAG, report error with graph visualization
- **Resource exhaustion**: Reduce max_concurrent, queue remaining agents

### Recovery Strategies
1. **Automatic retry**: Re-invoke failed agent (up to retry_attempts)
2. **Fallback pattern**: Switch to simpler strategy (e.g., DAG → Sequential)
3. **Graceful degradation**: Complete partial results, report failures
4. **Manual intervention**: Prompt user using AskUserQuestion for decision

## Output Format

When coordination completes, return:

```markdown
# Agent Coordination Complete

## Strategy Used: [Pattern Name]

## Results Summary:
[High-level synthesis of all agent outputs]

## Agent Contributions:
### Agent A ([role]):
[Key findings/output]

### Agent B ([role]):
[Key findings/output]

### Agent C ([role]):
[Key findings/output]

## Coordination Metrics:
- Execution Time: [duration]
- Success Rate: [percentage]%
- Parallelism: [factor]x

## Recommendations:
[Optimization suggestions for future coordinations]

---
See examples.md for coordination pattern examples
See reference.md for advanced configuration and troubleshooting
```

## Integration with Spec Workflow

Agent coordination integrates with Spec workflow phases:

**Initialize Phase**: Auto-detect project tooling, coordinate linters/formatters/type-checkers
**Define Phase**: Coordinate spec-analyzer agents for consistency validation
**Design Phase**: Coordinate spec-researcher agents for parallel technology research
**Build Phase**: Coordinate spec-implementer agents for parallel task execution
**Track Phase**: Coordinate multiple metric collection agents

Example usage in workflow:
```markdown
During Implementation Phase:
1. Load tasks.md with 12 tasks
2. Identify independent tasks (8 have no dependencies)
3. Invoke agent-coordination skill with DAG pattern
4. Coordinate 3 spec-implementer agents in parallel
5. Monitor progress, handle failures
6. Aggregate results, update task status
```

## Related Skills

- **workflow**: Main Spec workflow orchestration
- **spec-implementer**: Parallel task execution (worker agent)
- **spec-researcher**: Research-backed decisions (can be coordinated)
- **spec-analyzer**: Deep consistency validation (can be coordinated)
