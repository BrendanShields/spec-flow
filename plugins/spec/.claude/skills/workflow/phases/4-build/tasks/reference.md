# Task Breakdown Reference

Technical specifications for task generation, dependency analysis, and format standards.

## Task Format Specification

### Complete Task Structure

```markdown
## Task T###: [Action Verb] [Specific Outcome] [Optional: [P] marker]

- Priority: P1 | P2 | P3
- Estimate: X hours
- Dependencies: T###, T### | None
- Parallel: [P] | (empty)
- Files: path/to/file.ext, path/to/other.ext
- User Story: US#.#
- External: JIRA-123, GH-456 (optional)

**Description**:
1-3 paragraphs explaining what to implement and how. Include:
- What to build
- Technical approach
- Key considerations
- Integration points

**Acceptance Criteria**:
- [ ] Criterion 1 (testable condition)
- [ ] Criterion 2 (observable outcome)
- [ ] Criterion 3 (quality metric)
- [ ] Criterion 4 (edge case handling)

**Technical Notes** (optional):
- API endpoints or data structures
- Third-party dependencies
- Performance considerations
- Security implications
```

### Field Specifications

**Task ID**:
- Format: `T###` where ### is zero-padded 3-digit number (T001, T002, ..., T999)
- Sequential assignment within feature
- Never reuse IDs even if task removed
- Cross-reference in dependencies by ID only

**Action Verbs** (prefer specific over generic):
- ✅ Create, Implement, Build, Add, Refactor, Extract
- ✅ Configure, Integrate, Connect, Deploy, Migrate
- ✅ Write, Test, Validate, Document, Optimize
- ❌ Do, Make, Fix, Handle, Manage, Deal with

**Priority Mapping**:
```
P1 (Must Have):
- Blocks core functionality
- Required for MVP/release
- User story is P1
- Critical path dependency

P2 (Should Have):
- Important but can defer
- Enhances UX significantly
- User story is P2
- Parallel to critical path

P3 (Nice to Have):
- Optional enhancement
- Minimal user impact
- User story is P3
- Can skip if time constrained
```

**Estimate Guidelines**:
- Range: 1-4 hours per task
- If >4 hours: Break into multiple tasks
- If <1 hour: Combine with related task
- Include: coding + testing + documentation
- Exclude: code review time, deployment time

**Dependencies**:
- List task IDs that must complete first
- Use `None` if no dependencies (can start immediately)
- Separate multiple with commas: `T001, T003, T005`
- Verify no circular dependencies (T001 → T003 → T001)

**Parallel Marker**:
- Add `[P]` to task title if can run concurrently with others
- Criteria for parallelism:
  - No shared file modifications
  - Independent codepaths
  - Different team members can execute
  - No sequential data dependencies
- Example: "Task T001: Setup database [P]"

**Files**:
- List files to create or modify
- Use relative paths from project root
- Include test files
- Format: `src/path/file.ext, tests/path/file.test.ext`

**User Story**:
- Map to user story from spec.md
- Format: `US#.#` (e.g., US1.1, US2.3)
- One task can support multiple stories: `US1.1, US1.2`

**External** (optional):
- Issue tracker references
- Format: `JIRA-123` or `GH-456` or `LIN-789`
- Added when MCP sync enabled

## Dependency Analysis Algorithms

### Algorithm 1: Dependency Detection

```python
def analyze_dependencies(task, all_tasks, plan):
    """
    Determine which tasks must complete before this task can start.

    Inputs:
    - task: Current task being analyzed
    - all_tasks: List of all tasks in feature
    - plan: Technical plan document

    Returns:
    - List of task IDs this task depends on
    """
    dependencies = []

    # Check file dependencies
    for other_task in all_tasks:
        if other_task.id == task.id:
            continue

        # If other task creates files this task modifies
        if file_overlap(other_task.creates, task.modifies):
            dependencies.append(other_task.id)

        # If other task provides data this task consumes
        if data_dependency(other_task.outputs, task.inputs):
            dependencies.append(other_task.id)

    # Check plan order
    task_order = extract_order_from_plan(plan)
    for earlier_task_id in task_order:
        if earlier_task_id != task.id and is_before(earlier_task_id, task.id, task_order):
            if not already_in_dependencies(earlier_task_id, dependencies):
                dependencies.append(earlier_task_id)

    # Remove transitive dependencies (A→B→C, keep only A→C if direct)
    dependencies = remove_transitive(dependencies)

    return dependencies
```

### Algorithm 2: Parallel Work Detection

```python
def detect_parallel_groups(tasks):
    """
    Group tasks that can execute concurrently.

    Returns:
    - List of parallel groups, ordered by execution phase
    """
    groups = []
    remaining = tasks.copy()
    completed = set()

    while remaining:
        # Find all tasks with satisfied dependencies
        ready_tasks = [
            task for task in remaining
            if all(dep in completed for dep in task.dependencies)
        ]

        if not ready_tasks:
            # Circular dependency detected
            raise CircularDependencyError(remaining)

        # Check for parallel opportunities
        parallel_group = []
        sequential_group = []

        for task in ready_tasks:
            can_parallelize = True

            for other in parallel_group:
                # Check if tasks conflict
                if files_conflict(task.files, other.files):
                    can_parallelize = False
                    break
                if resource_conflict(task.resources, other.resources):
                    can_parallelize = False
                    break

            if can_parallelize:
                parallel_group.append(task)
            else:
                sequential_group.append(task)

        # Create group
        groups.append({
            'phase': len(groups) + 1,
            'parallel': parallel_group,
            'sequential': sequential_group
        })

        # Mark as completed
        for task in ready_tasks:
            completed.add(task.id)
            remaining.remove(task)

    return groups
```

### Algorithm 3: Critical Path Calculation

```python
def calculate_critical_path(tasks):
    """
    Find the longest path through task dependencies.
    This determines minimum completion time.
    """
    # Build dependency graph
    graph = build_graph(tasks)

    # Calculate earliest start time for each task
    earliest_start = {}
    for task in topological_sort(tasks):
        if not task.dependencies:
            earliest_start[task.id] = 0
        else:
            max_dep_finish = max(
                earliest_start[dep] + get_task(dep).estimate
                for dep in task.dependencies
            )
            earliest_start[task.id] = max_dep_finish

    # Find path with maximum total time
    critical_tasks = []
    current = max(tasks, key=lambda t: earliest_start[t.id] + t.estimate)

    while current:
        critical_tasks.insert(0, current.id)

        # Find predecessor on critical path
        if current.dependencies:
            current = max(
                (get_task(dep) for dep in current.dependencies),
                key=lambda t: earliest_start[t.id] + t.estimate
            )
        else:
            current = None

    total_time = sum(get_task(tid).estimate for tid in critical_tasks)

    return {
        'path': critical_tasks,
        'time': total_time
    }
```

### Algorithm 4: Time Savings Estimation

```python
def estimate_time_savings(tasks, parallel_groups):
    """
    Calculate time saved by parallel execution vs sequential.
    """
    # Sequential time (all tasks one after another)
    sequential_time = sum(task.estimate for task in tasks)

    # Parallel time (max time per group)
    parallel_time = 0
    for group in parallel_groups:
        if group['parallel']:
            # Parallel tasks: max of the group
            parallel_time += max(task.estimate for task in group['parallel'])

        if group['sequential']:
            # Sequential tasks: sum within group
            parallel_time += sum(task.estimate for task in group['sequential'])

    time_saved = sequential_time - parallel_time
    percent_saved = (time_saved / sequential_time) * 100

    return {
        'sequential': sequential_time,
        'parallel': parallel_time,
        'saved': time_saved,
        'percent': percent_saved
    }
```

## Task Generation Patterns

### Pattern 1: CRUD Operations

For create/read/update/delete features:

```
T001: Create [Entity] database schema [P]
T002: Implement POST /api/[entity] endpoint
T003: Implement GET /api/[entity]/:id endpoint [P]
T004: Implement PUT /api/[entity]/:id endpoint [P]
T005: Implement DELETE /api/[entity]/:id endpoint [P]
T006: Add validation middleware
T007: Write API integration tests
```

### Pattern 2: UI Component Tree

For React/Vue component features:

```
T001: Create [Feature]Container parent component [P]
T002: Create [Component]Form child component [P]
T003: Create [Component]List child component [P]
T004: Integrate container with children
T005: Add state management (Redux/Zustand)
T006: Connect to API endpoints
T007: Add loading and error states
T008: Write component unit tests
T009: Add Storybook stories [P]
```

### Pattern 3: Data Pipeline

For ETL/data processing features:

```
T001: Design data schema and transformations [P]
T002: Implement data extraction from source
T003: Implement data transformation logic
T004: Implement data loading to destination
T005: Add data validation checkpoints
T006: Add error handling and retries
T007: Implement monitoring and logging
T008: Add data quality tests
T009: Create pipeline orchestration config [P]
```

### Pattern 4: Integration

For third-party service integrations:

```
T001: Research API documentation [P]
T002: Set up API credentials and config
T003: Create service wrapper/client
T004: Implement core API methods
T005: Add rate limiting and retry logic
T006: Implement webhook handlers (if applicable)
T007: Add error mapping from API to app
T008: Write integration tests with mocks
T009: Test against sandbox environment
T010: Add production monitoring
```

## Validation Rules

### Pre-Generation Validation

Before creating tasks.md, verify:

```python
def validate_prerequisites():
    checks = [
        ('spec.md exists', file_exists('{config.paths.features}/{id}/{config.naming.files.spec}')),
        ('plan.md exists', file_exists('{config.paths.features}/{id}/{config.naming.files.plan}')),
        ('spec has user stories', has_user_stories('spec.md')),
        ('plan has technical approach', has_technical_sections('plan.md')),
        ('no blocking [CLARIFY] tags', no_clarify_tags('spec.md')),
    ]

    failures = [check for check, passed in checks if not passed]

    if failures:
        raise ValidationError(f"Prerequisites not met: {failures}")
```

### Post-Generation Validation

After creating tasks.md, verify:

```python
def validate_tasks(tasks):
    checks = [
        # Completeness
        ('All user stories have tasks', all_stories_covered(tasks)),
        ('All plan sections have tasks', all_plan_steps_covered(tasks)),
        ('Task IDs sequential', task_ids_sequential(tasks)),

        # Dependencies
        ('No circular dependencies', no_circular_deps(tasks)),
        ('All dependencies valid', all_deps_exist(tasks)),
        ('Dependencies respect order', deps_before_tasks(tasks)),

        # Quality
        ('Estimates in range 1-4h', all_estimates_valid(tasks)),
        ('All tasks have acceptance criteria', all_have_criteria(tasks)),
        ('P1 tasks cover critical path', p1_tasks_sufficient(tasks)),

        # Format
        ('Task IDs formatted T###', all_ids_formatted(tasks)),
        ('Priorities valid (P1/P2/P3)', all_priorities_valid(tasks)),
        ('File paths relative', all_paths_relative(tasks)),
    ]

    warnings = []
    errors = []

    for check, passed in checks:
        if not passed:
            if is_blocking(check):
                errors.append(check)
            else:
                warnings.append(check)

    return ValidationResult(errors, warnings)
```

## State File Updates

### CHANGES-PLANNED.md Structure

```markdown
# Changes Planned

**Last Updated**: YYYY-MM-DD HH:MM:SS

## Feature ###: [Feature Name] ([Status])

### Pending Tasks (X tasks)

**T###**: [Task Title]
- Priority: P#
- Estimate: X hours
- Dependencies: T###, T### | None
- Files: path/to/file.ext
- User Story: US#.#
- External: JIRA-### (if applicable)
- Notes: Additional context

[Repeat for each task...]

### Parallel Work Opportunities

**Group #** (description):
- T###: [Title]
- T###: [Title]

**Time Savings**: Sequential = Xh, Parallel = Yh (Z% savings)

---

[Repeat for each feature...]

**Total Planned**: X tasks across Y features
**By Priority**: P1 (X), P2 (Y), P3 (Z)
**Total Estimate**: X hours sequential, Y hours parallel
```

### Update Pattern

```python
def update_changes_planned(feature_id, tasks):
    # Read existing file
    content = read_file('{config.paths.memory}/CHANGES-PLANNED.md')

    # Find or create feature section
    if feature_section_exists(content, feature_id):
        # Replace existing section
        content = replace_section(content, feature_id, format_tasks(tasks))
    else:
        # Append new section
        content = append_section(content, feature_id, format_tasks(tasks))

    # Update timestamp
    content = update_timestamp(content)

    # Write atomically
    write_file('{config.paths.memory}/CHANGES-PLANNED.md', content)
```

## MCP Integration

### External Issue Creation

When MCP tools available:

```python
def create_external_issues(tasks, config):
    """
    Create issues in JIRA/Linear/GitHub via MCP.
    """
    if not mcp_available():
        return None

    # Ask user preference
    if not ask_user("Sync tasks with JIRA?"):
        return None

    issue_refs = {}

    for task in tasks:
        try:
            # Create issue via MCP
            issue = create_jira_issue(
                project=config.jira_project,
                summary=task.title,
                description=format_task_for_jira(task),
                priority=map_priority(task.priority),
                labels=['spec', f'feature-{feature_id}']
            )

            issue_refs[task.id] = issue.key

        except MCPError as e:
            log_error(f"Failed to create issue for {task.id}: {e}")
            # Continue with other tasks

    # Update tasks.md with issue references
    add_external_refs(tasks, issue_refs)

    return issue_refs
```

### Sync Pattern

```markdown
For MCP integration patterns and sync logic, see: `shared/integration-patterns.md`

Common MCP operations:
- create_issue(project, summary, description)
- update_issue(issue_key, fields)
- add_comment(issue_key, comment)
- create_page(space, title, content)
```

## Error Recovery

### Common Errors

**1. Plan not found**:
```
Error: {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.plan} not found

Recovery:
1. Check current phase in {config.paths.state}/current-session.md
2. If phase < "planning", prompt: "Run plan phase first"
3. If phase >= "planning" but plan missing, error is critical
4. Offer: "Regenerate plan with plan phase --force"
```

**2. Circular dependency**:
```
Error: Circular dependency detected: T001 → T003 → T005 → T001

Recovery:
1. Display dependency chain
2. Ask user: "Which dependency should be removed?"
3. Suggest breaking one task into two
4. Show impact of each option
```

**3. No tasks generated**:
```
Warning: 0 tasks generated from plan

Recovery:
1. Check plan.md has technical approach sections
2. Check spec.md has user stories
3. Offer: "Run clarify phase to add missing details"
4. Offer: "Manually create first task to bootstrap"
```

## Related Files

- **workflow-patterns.md**: Phase transition patterns, validation checkpoints
- **state-management.md**: CHANGES-PLANNED.md format, update patterns
- **integration-patterns.md**: MCP sync details, external issue creation
- **SKILL.md**: Core execution logic
- **EXAMPLES.md**: Concrete usage scenarios

---

**Last Updated**: 2025-10-31
**Token Size**: ~2,000 tokens
**Progressive Disclosure**: Loaded on-demand when user needs technical details
