# Agent Coordination: Technical Reference

Advanced configuration, algorithms, and troubleshooting for multi-agent orchestration.

## Configuration Schema

Complete `.claude/.spec-config.yml` agent coordination schema:

```yaml
agents:
  # Individual agent settings
  implementer:
    strategy: "parallel" | "sequential" | "adaptive" | "dag"
    max_parallel: <integer>              # Max concurrent tasks
    timeout: <seconds>                   # Task timeout
    retry_attempts: <integer>            # Retry count
    dependency_aware: <boolean>          # Enable DAG tracking
    critical_path_optimization: <boolean> # Optimize execution order

  researcher:
    confidence_threshold: <float 0-1>    # Min confidence for auto-decisions
    cache_ttl: <seconds>                 # Cache duration

  analyzer:
    validation_depth: "quick" | "standard" | "deep"
    auto_fix: <boolean>                  # Auto-fix issues

  # Multi-Agent Coordination
  coordination:
    default_pattern: "sequential" | "parallel" | "hierarchical" | "dag" | "group_chat" | "event_driven"

    # Sequential Pattern
    sequential:
      enabled: <boolean>
      handoff_mode: "synchronous" | "asynchronous"
      checkpoint_between_agents: <boolean>

    # Parallel Pattern
    parallel:
      enabled: <boolean>
      max_concurrent_agents: <integer>
      collect_strategy: "all" | "first" | "any" | "majority"
      timeout_per_agent: <seconds>

    # Hierarchical Pattern
    hierarchical:
      enabled: <boolean>
      supervisor_model: "sonnet" | "opus" | "haiku"
      worker_model: "sonnet" | "opus" | "haiku"
      max_delegation_depth: <integer>
      supervisor_reviews_work: <boolean>

    # DAG Pattern
    dag:
      enabled: <boolean>
      auto_detect_dependencies: <boolean>
      critical_path_first: <boolean>
      parallel_non_dependent: <boolean>
      visualization: <boolean>

    # Group Chat Pattern
    group_chat:
      enabled: <boolean>
      max_agents: <integer>
      chat_manager_model: "sonnet" | "opus" | "haiku"
      max_rounds: <integer>
      speaker_selection: "auto" | "round_robin" | "random" | "manual"

    # Event-Driven Pattern
    event_driven:
      enabled: <boolean>
      event_bus: "memory" | "redis" | "kafka"
      retry_on_failure: <boolean>
      dead_letter_queue: <boolean>
```

## Pattern Algorithms

### Sequential Pattern Algorithm

```python
def execute_sequential(agents: List[Agent], config: SequentialConfig) -> Result:
    """
    Execute agents sequentially with output chaining.

    Time Complexity: O(n) where n = number of agents
    Space Complexity: O(1) (only stores current output)
    """
    output = initial_input
    checkpoints = []

    for i, agent in enumerate(agents):
        # Invoke agent with previous output
        result = invoke_agent(agent, output)

        # Handle synchronous/asynchronous handoff
        if config.handoff_mode == "synchronous":
            wait_for_completion(result)
        else:
            monitor_progress(result)

        # Checkpoint between agents
        if config.checkpoint_between_agents and i < len(agents) - 1:
            checkpoint = create_checkpoint(result)
            checkpoints.append(checkpoint)

            # Prompt user to continue or exit
            if not ask_user_continue():
                return partial_result(checkpoints)

        # Chain output to next agent
        output = result.output

    return final_result(output, checkpoints)
```

### Parallel Pattern Algorithm

```python
def execute_parallel(agents: List[Agent], config: ParallelConfig) -> Result:
    """
    Execute agents concurrently with result collection.

    Time Complexity: O(max(t_1, t_2, ..., t_n)) where t_i = time for agent i
    Space Complexity: O(n) for storing all agent results
    """
    # Invoke all agents concurrently
    tasks = []
    for agent in agents[:config.max_concurrent_agents]:
        task = invoke_agent_async(agent)
        tasks.append(task)

    # Collect results based on strategy
    if config.collect_strategy == "all":
        # Wait for all agents
        results = wait_all(tasks, timeout=config.timeout_per_agent)
    elif config.collect_strategy == "first":
        # Return first completion
        result = wait_any(tasks)
        cancel_remaining(tasks)
        return result
    elif config.collect_strategy == "any":
        # Accept any successful completion
        result = wait_any_success(tasks)
        return result
    elif config.collect_strategy == "majority":
        # Wait for majority consensus
        results = wait_majority(tasks, threshold=0.5)

    # Aggregate results
    return aggregate_results(results)
```

### Hierarchical Pattern Algorithm

```python
def execute_hierarchical(task: Task, config: HierarchicalConfig, depth: int = 0) -> Result:
    """
    Execute hierarchical decomposition with supervisor/worker pattern.

    Time Complexity: O(n * log(n)) for balanced decomposition
    Space Complexity: O(d * w) where d = depth, w = workers per level
    """
    if depth >= config.max_delegation_depth:
        # Max depth reached, execute directly
        return execute_task(task)

    # Invoke supervisor to decompose task
    supervisor = create_agent(model=config.supervisor_model)
    subtasks = supervisor.decompose(task)

    # Spawn worker agents for each subtask
    worker_results = []
    for subtask in subtasks:
        worker = create_agent(model=config.worker_model)

        # Recursive delegation if subtask is complex
        if subtask.complexity > threshold and depth < config.max_delegation_depth:
            result = execute_hierarchical(subtask, config, depth + 1)
        else:
            result = worker.execute(subtask)

        worker_results.append(result)

    # Supervisor reviews work
    if config.supervisor_reviews_work:
        reviewed_results = []
        for result in worker_results:
            review = supervisor.review(result)
            if review.needs_revision:
                # Request revision from worker
                revised = worker.revise(result, review.feedback)
                reviewed_results.append(revised)
            else:
                reviewed_results.append(result)
        worker_results = reviewed_results

    # Supervisor synthesizes final result
    return supervisor.synthesize(worker_results)
```

### DAG Pattern Algorithm

```python
def execute_dag(tasks: List[Task], config: DAGConfig) -> Result:
    """
    Execute tasks respecting dependencies with optimal parallelization.

    Time Complexity: O(V + E) where V = tasks, E = dependencies
    Space Complexity: O(V + E) for graph representation
    """
    # Build dependency graph
    graph = build_dependency_graph(tasks)

    # Auto-detect dependencies if enabled
    if config.auto_detect_dependencies:
        inferred_deps = infer_dependencies(tasks)
        graph.add_edges(inferred_deps)

    # Detect cycles (should not exist in DAG)
    if has_cycle(graph):
        raise ValueError("Dependency cycle detected!")

    # Calculate critical path
    critical_path = []
    if config.critical_path_first:
        critical_path = find_critical_path(graph)

    # Topological sort for execution order
    execution_order = topological_sort(graph)

    # Execute tasks in stages
    completed = set()
    results = {}

    while len(completed) < len(tasks):
        # Find ready tasks (dependencies satisfied)
        ready = [t for t in execution_order if dependencies_met(t, completed)]

        if not ready:
            raise ValueError("Deadlock detected!")

        # Prioritize critical path tasks
        if config.critical_path_first:
            ready = sorted(ready, key=lambda t: t in critical_path, reverse=True)

        # Execute ready tasks
        if config.parallel_non_dependent and len(ready) > 1:
            # Execute independent tasks in parallel
            task_results = execute_parallel(ready, config)
        else:
            # Execute sequentially
            task_results = [execute_task(t) for t in ready]

        # Mark completed and store results
        for task, result in zip(ready, task_results):
            completed.add(task)
            results[task] = result

    return aggregate_results(results.values())


def find_critical_path(graph: DependencyGraph) -> List[Task]:
    """
    Find longest path in DAG (critical path).

    Uses dynamic programming to calculate longest path.
    Time Complexity: O(V + E)
    """
    # Calculate longest path to each node
    longest = {}
    for task in topological_sort(graph):
        if not graph.predecessors(task):
            longest[task] = task.duration
        else:
            max_pred = max(longest[pred] for pred in graph.predecessors(task))
            longest[task] = max_pred + task.duration

    # Backtrack to find critical path
    critical_path = []
    current = max(longest, key=longest.get)
    while current:
        critical_path.append(current)
        preds = graph.predecessors(current)
        current = max(preds, key=lambda p: longest[p]) if preds else None

    return list(reversed(critical_path))


def infer_dependencies(tasks: List[Task]) -> List[Tuple[Task, Task]]:
    """
    Auto-detect dependencies between tasks based on input/output analysis.

    Analyzes each task's inputs and outputs to infer dependencies.
    Time Complexity: O(n^2) worst case
    """
    dependencies = []

    for task_a in tasks:
        for task_b in tasks:
            if task_a == task_b:
                continue

            # Check if task_b depends on task_a
            # (task_b's inputs match task_a's outputs)
            if outputs_match_inputs(task_a.outputs, task_b.inputs):
                dependencies.append((task_a, task_b))

    return dependencies
```

### Group Chat Pattern Algorithm

```python
def execute_group_chat(problem: str, agents: List[Agent], config: GroupChatConfig) -> Result:
    """
    Execute multi-agent collaboration through shared conversation.

    Time Complexity: O(r * a) where r = rounds, a = agents
    Space Complexity: O(r * m) where m = message size
    """
    # Initialize chat with manager
    chat_manager = create_agent(model=config.chat_manager_model)
    conversation = [{"speaker": "manager", "message": problem}]

    for round_num in range(config.max_rounds):
        # Select next speaker
        if config.speaker_selection == "auto":
            speaker = chat_manager.select_speaker(conversation, agents)
        elif config.speaker_selection == "round_robin":
            speaker = agents[round_num % len(agents)]
        elif config.speaker_selection == "random":
            speaker = random.choice(agents)
        else:  # manual
            speaker = ask_user_select_speaker(agents)

        # Speaker contributes to conversation
        message = speaker.contribute(conversation)
        conversation.append({"speaker": speaker.name, "message": message})

        # Check for consensus
        if chat_manager.has_consensus(conversation):
            break

    # Manager synthesizes final decision
    return chat_manager.synthesize(conversation)
```

### Event-Driven Pattern Algorithm

```python
def execute_event_driven(events: List[Event], subscriptions: Dict[str, List[Agent]], config: EventDrivenConfig):
    """
    Execute reactive event-driven coordination.

    Time Complexity: O(e * a) where e = events, a = subscribed agents per event
    Space Complexity: O(q) where q = queue size
    """
    # Initialize event bus
    event_bus = create_event_bus(config.event_bus)
    dead_letter_queue = [] if config.dead_letter_queue else None

    # Register agent subscriptions
    for event_type, agents in subscriptions.items():
        for agent in agents:
            event_bus.subscribe(event_type, agent)

    # Process events
    for event in events:
        # Dispatch to subscribed agents
        subscribed = event_bus.get_subscribers(event.type)

        for agent in subscribed:
            try:
                result = agent.handle_event(event)

                # Check for follow-up events
                if result.new_events:
                    for new_event in result.new_events:
                        event_bus.emit(new_event)

            except Exception as error:
                # Retry on failure
                if config.retry_on_failure:
                    for attempt in range(agent.retry_attempts):
                        try:
                            result = agent.handle_event(event)
                            break
                        except Exception:
                            continue
                    else:
                        # All retries exhausted
                        if dead_letter_queue is not None:
                            dead_letter_queue.append((event, agent, error))
                else:
                    # No retry, route to DLQ
                    if dead_letter_queue is not None:
                        dead_letter_queue.append((event, agent, error))
```

## Optimization Strategies

### 1. Critical Path Optimization

Prioritize tasks on the critical path to minimize total execution time:

```python
def optimize_execution_order(tasks: List[Task], graph: DependencyGraph) -> List[Task]:
    """
    Optimize task execution order by prioritizing critical path.

    Tasks on critical path are scheduled first to minimize makespan.
    """
    critical_path = find_critical_path(graph)
    critical_set = set(critical_path)

    # Partition tasks: critical vs non-critical
    critical_tasks = [t for t in tasks if t in critical_set]
    non_critical_tasks = [t for t in tasks if t not in critical_set]

    # Execute critical path first, then non-critical
    return critical_tasks + non_critical_tasks
```

### 2. Load Balancing

Distribute work evenly across agents:

```python
def balance_load(tasks: List[Task], max_agents: int) -> List[List[Task]]:
    """
    Balance task load across agents using bin-packing.

    Uses First-Fit Decreasing (FFD) algorithm.
    """
    # Sort tasks by estimated duration (descending)
    sorted_tasks = sorted(tasks, key=lambda t: t.estimated_duration, reverse=True)

    # Initialize bins (agent workloads)
    bins = [[] for _ in range(max_agents)]
    bin_loads = [0] * max_agents

    # Assign tasks to bins
    for task in sorted_tasks:
        # Find bin with minimum load
        min_bin = bin_loads.index(min(bin_loads))
        bins[min_bin].append(task)
        bin_loads[min_bin] += task.estimated_duration

    return bins
```

### 3. Adaptive Strategy Selection

Dynamically select coordination strategy based on task characteristics:

```python
def select_optimal_strategy(tasks: List[Task]) -> str:
    """
    Analyze tasks and select optimal coordination strategy.
    """
    # Analyze task characteristics
    num_tasks = len(tasks)
    dependencies = analyze_dependencies(tasks)
    parallelism_potential = calculate_parallelism(dependencies)
    complexity = sum(t.complexity for t in tasks)

    # Decision rules
    if dependencies and parallelism_potential > 0.5:
        return "dag"  # Mix of dependencies and parallelism
    elif not dependencies and num_tasks > 3:
        return "parallel"  # Independent tasks
    elif complexity > threshold and num_tasks > 5:
        return "hierarchical"  # Complex decomposition needed
    elif require_collaboration(tasks):
        return "group_chat"  # Multiple perspectives needed
    else:
        return "sequential"  # Simple sequential workflow
```

## Performance Metrics

### Parallelism Factor

Measure achieved parallelism:

```python
def calculate_parallelism_factor(execution_log: List[Event]) -> float:
    """
    Parallelism factor = Total work / Critical path length

    Ideal: max_concurrent_agents
    Actual: Typically 0.5 - 0.8 * ideal due to dependencies
    """
    total_work = sum(task.duration for task in execution_log)
    critical_path_length = find_critical_path(execution_log).total_duration

    return total_work / critical_path_length
```

### Speedup

Measure improvement over sequential execution:

```python
def calculate_speedup(parallel_time: float, sequential_time: float) -> float:
    """
    Speedup = Sequential time / Parallel time

    Ideal: Number of agents (perfect parallelism)
    Typical: 2-4x for 5 agents due to coordination overhead
    """
    return sequential_time / parallel_time
```

### Efficiency

Measure resource utilization:

```python
def calculate_efficiency(speedup: float, num_agents: int) -> float:
    """
    Efficiency = Speedup / Number of agents

    1.0 = Perfect efficiency (no overhead)
    0.5-0.8 = Typical due to coordination overhead
    <0.5 = Too much coordination overhead, consider fewer agents
    """
    return speedup / num_agents
```

## Troubleshooting

### Issue 1: Dependency Deadlock

**Symptom**: DAG execution hangs, no tasks are ready

**Diagnosis**:
```python
def detect_deadlock(graph: DependencyGraph, completed: Set[Task]) -> bool:
    """Check if any tasks can become ready."""
    remaining = graph.nodes - completed
    for task in remaining:
        if all(dep in completed for dep in graph.predecessors(task)):
            return False  # At least one task is ready
    return True  # Deadlock: no tasks can proceed
```

**Solution**:
1. Check for circular dependencies: `has_cycle(graph)`
2. Verify all dependencies are in task list
3. Add missing tasks or remove invalid dependencies

### Issue 2: Agent Timeout

**Symptom**: Agent exceeds timeout, coordination fails

**Diagnosis**:
```python
def analyze_timeout(agent: Agent, task: Task) -> str:
    """Determine timeout cause."""
    if task.complexity > agent.capability:
        return "Task too complex for agent"
    elif task.estimated_duration < actual_duration:
        return "Underestimated task duration"
    else:
        return "Agent performance issue"
```

**Solution**:
1. Increase `timeout_per_agent` in config
2. Use stronger model (haiku → sonnet)
3. Decompose task into smaller subtasks
4. Enable retry with: `retry_on_failure: true`

### Issue 3: Coordination Overhead

**Symptom**: Parallel execution slower than sequential

**Diagnosis**:
```python
def calculate_overhead(parallel_time: float, task_times: List[float]) -> float:
    """Calculate coordination overhead."""
    pure_execution_time = max(task_times)  # Longest task (critical path)
    overhead = parallel_time - pure_execution_time
    return overhead / pure_execution_time * 100  # % overhead
```

**Solution**:
1. Reduce `max_concurrent_agents` (less coordination)
2. Use `collect_strategy: "first"` (don't wait for all)
3. Disable `supervisor_reviews_work` (less back-and-forth)
4. Switch to sequential for simple tasks

### Issue 4: Inconsistent Results

**Symptom**: Different agents produce conflicting outputs

**Diagnosis**:
```python
def detect_conflicts(results: List[Result]) -> List[Conflict]:
    """Find conflicting agent outputs."""
    conflicts = []
    for i, result_a in enumerate(results):
        for result_b in results[i+1:]:
            if result_a.conflicts_with(result_b):
                conflicts.append(Conflict(result_a, result_b))
    return conflicts
```

**Solution**:
1. Use hierarchical pattern with `supervisor_reviews_work: true`
2. Enable group chat for collaborative resolution
3. Use `collect_strategy: "majority"` for voting
4. Add explicit validation step after coordination

### Issue 5: Resource Exhaustion

**Symptom**: System runs out of memory/tokens with many agents

**Diagnosis**:
```python
def estimate_resource_usage(agents: List[Agent], tasks: List[Task]) -> ResourceEstimate:
    """Estimate memory and token usage."""
    context_per_agent = 8000  # tokens
    memory_per_agent = 100  # MB

    total_tokens = len(agents) * context_per_agent * len(tasks)
    total_memory = len(agents) * memory_per_agent

    return ResourceEstimate(tokens=total_tokens, memory=total_memory)
```

**Solution**:
1. Reduce `max_concurrent_agents`
2. Use lighter model: `worker_model: "haiku"`
3. Enable progressive disclosure (load context on-demand)
4. Switch to sequential pattern (lower memory)

## Best Practices

### 1. Pattern Selection

| Characteristic | Recommended Pattern |
|----------------|-------------------|
| No dependencies, need speed | Parallel |
| Strict order required | Sequential |
| Complex decomposition | Hierarchical |
| Some dependencies, some parallelism | DAG |
| Need collaboration | Group Chat |
| Event-triggered | Event-Driven |

### 2. Model Selection

| Role | Recommended Model | Rationale |
|------|------------------|-----------|
| Supervisor | Sonnet | Needs intelligence for decomposition |
| Worker | Haiku | Fast execution, lower cost |
| Chat Manager | Sonnet | Sophisticated speaker selection |
| Simple tasks | Haiku | Cost-effective |
| Complex analysis | Opus | Maximum capability |

### 3. Configuration Tuning

**Start Conservative:**
```yaml
coordination:
  parallel:
    max_concurrent_agents: 3  # Start low
    timeout_per_agent: 300    # 5 minutes
  hierarchical:
    max_delegation_depth: 2   # Shallow hierarchy
```

**Scale Up Based on Metrics:**
- Efficiency > 0.7 → Increase `max_concurrent_agents`
- Timeouts frequent → Increase `timeout_per_agent`
- Overhead < 20% → Enable more features (reviews, checkpoints)

### 4. Error Handling

**Configure Retries:**
```yaml
agents:
  implementer:
    retry_attempts: 3
  coordination:
    event_driven:
      retry_on_failure: true
      dead_letter_queue: true
```

**Monitor DLQ:**
```python
def check_dead_letter_queue(dlq: List[FailedEvent]):
    """Alert if DLQ grows."""
    if len(dlq) > threshold:
        alert("High failure rate in event-driven coordination")
```

## Advanced Topics

### Custom Coordination Patterns

Combine patterns for custom workflows:

```python
def hybrid_coordination(tasks: List[Task]) -> Result:
    """
    Hybrid: Hierarchical decomposition + DAG execution per subtask.
    """
    # Phase 1: Hierarchical decomposition
    supervisor_result = execute_hierarchical(
        task=tasks,
        config=HierarchicalConfig(max_delegation_depth=1)
    )
    subtasks = supervisor_result.subtasks

    # Phase 2: DAG execution for each subtask group
    results = []
    for subtask_group in subtasks:
        dag_result = execute_dag(
            tasks=subtask_group,
            config=DAGConfig(parallel_non_dependent=True)
        )
        results.append(dag_result)

    # Phase 3: Supervisor synthesis
    return supervisor.synthesize(results)
```

### Agent Capability Matching

Match tasks to agents based on capabilities:

```python
def match_agents_to_tasks(tasks: List[Task], agents: List[Agent]) -> Dict[Task, Agent]:
    """
    Optimal task-agent matching using Hungarian algorithm.

    Cost matrix: capability_gap[task][agent]
    Minimize total capability gap.
    """
    cost_matrix = [[calculate_gap(task, agent) for agent in agents] for task in tasks]
    assignments = hungarian_algorithm(cost_matrix)
    return dict(zip(tasks, [agents[i] for i in assignments]))
```

### Coordination Visualization

Generate execution graphs:

```python
def visualize_dag_execution(graph: DependencyGraph, results: ExecutionLog):
    """
    Generate Mermaid diagram of DAG execution with timing.
    """
    diagram = "graph TD\n"
    for task in graph.nodes:
        duration = results.get_duration(task)
        status = results.get_status(task)
        diagram += f"  {task.id}[{task.name}<br/>{duration}s<br/>{status}]\n"

    for src, dst in graph.edges:
        diagram += f"  {src.id} --> {dst.id}\n"

    return diagram
```

---

For usage examples, see examples.md
For basic workflow, see SKILL.md
