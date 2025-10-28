# Lazy Loading System

## How It Works

Instead of loading all instructions upfront, load only what's needed when it's needed.

## Core Loader

```
@lazy-load [topic]
```

Loads detailed instructions for specific topic only when referenced.

## Available Topics

### File Operations
`@lazy-load:file-ops`
- Detailed file reading instructions
- Write verification steps
- Error handling procedures

### Git Workflow
`@lazy-load:git`
- Commit message formatting
- Branch management
- Conflict resolution

### Validation Rules
`@lazy-load:validation`
- Input validation patterns
- Output quality checks
- Error conditions

### Error Handling
`@lazy-load:errors`
- Common error scenarios
- Recovery procedures
- Logging requirements

### Progress Tracking
`@lazy-load:progress`
- Task status updates
- Progress calculation
- Reporting formats

## Usage Examples

### Minimal Initial Load
```
Execute task with @common-patterns.
If error: @lazy-load:errors
If validation needed: @lazy-load:validation
```

### Conditional Loading
```
If user asks about details:
  @lazy-load:[relevant-topic]
Else:
  Continue with minimal instructions
```

## Benefits

- **Initial Load**: ~100 tokens (vs ~1000)
- **With One Topic**: ~300 tokens
- **Full Load**: ~1000 tokens (only when everything needed)

## Integration

Skills should:
1. Start with minimal instructions
2. Reference @lazy-load for details
3. Load only when specific conditions met
4. Cache loaded content for session