# Agent Integration Patterns

## Standard Integration Points

All Specter agents integrate with the workflow at specific points:

### With specter:specify
- Input: User stories and requirements from spec.md
- Processing: Analyze for implementation approach
- Output: Technical recommendations

### With specter:plan
- Input: Technical design from plan.md
- Processing: Validate architecture decisions
- Output: Implementation strategy

### With specter:tasks
- Input: Task breakdown from tasks.md
- Processing: Optimize task execution order
- Output: Dependency graph

### With specter:implement
- Input: Task list with dependencies
- Processing: Execute implementation
- Output: Completed code and tests

## Hook Integration

Agents interact with hooks for:
- `pre-specify`: Validate prerequisites
- `post-specify`: Update project index
- `track-metrics`: Log AI-generated code
- `save-session`: Checkpoint progress

## Output Files

Standard agent output locations:
- Results: `.specter/agent-results/[agent-name]/`
- Logs: `.specter/logs/[agent-name].log`
- Metrics: `.specter/metrics/[agent-name].json`

## Performance Optimization

All agents should:
- Use parallel processing when possible
- Cache intermediate results
- Implement retry logic with exponential backoff
- Limit context to relevant files only

## Error Recovery

Standard error handling:
1. Retry transient errors (network, rate limits)
2. Fallback to alternative approaches
3. Log failures without blocking workflow
4. Report partial success when applicable

## Configuration

Agents read configuration from:
```javascript
const config = {
  maxRetries: 3,
  parallelTasks: 5,
  timeout: 30000,
  cacheEnabled: true,
  verboseLogging: false
};
```

See implementation details in specific agent reference files.