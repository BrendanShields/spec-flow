# Agent Configuration Examples

## Base Configuration

All agents support these base options:

```json
{
  "agent": "specter-[name]",
  "maxRetries": 3,
  "timeout": 30000,
  "parallelTasks": 5,
  "verboseLogging": false,
  "cacheEnabled": true
}
```

## Minimal Configuration

For quick execution with defaults:

```json
{
  "agent": "specter-implementer",
  "tasks": ["T001", "T002", "T003"]
}
```

## Enterprise Configuration

For production environments with monitoring:

```json
{
  "agent": "specter-implementer",
  "maxRetries": 5,
  "timeout": 60000,
  "parallelTasks": 10,
  "verboseLogging": true,
  "cacheEnabled": true,
  "monitoring": {
    "metricsEndpoint": "https://metrics.example.com",
    "alertThreshold": 0.8
  },
  "integrations": {
    "jira": true,
    "github": true,
    "slack": true
  }
}
```

## Retry Strategy

Exponential backoff configuration:

```javascript
{
  retryDelays: [1000, 2000, 4000, 8000, 16000],
  retryableErrors: ['NetworkError', 'TimeoutError', 'RateLimitError'],
  nonRetryableErrors: ['SyntaxError', 'ValidationError']
}
```

## Parallel Execution

Task batching configuration:

```javascript
{
  batchSize: 5,
  maxConcurrent: 10,
  priorityWeights: {
    'P1': 1.0,
    'P2': 0.7,
    'P3': 0.3
  }
}
```