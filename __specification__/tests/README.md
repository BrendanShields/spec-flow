# Navi Testing Infrastructure

## Directory Structure

```
tests/
├── unit/           # Unit tests for individual components
├── integration/    # End-to-end workflow tests
├── benchmarks/     # Performance benchmarks
├── metrics/        # Token usage metrics
└── compatibility/  # Backward compatibility tests
```

## Running Tests

### All Tests
```bash
./run-tests.sh
```

### Specific Suite
```bash
./run-tests.sh unit
./run-tests.sh integration
./run-tests.sh benchmarks
```

## Test Categories

### Unit Tests
- Command routing logic
- Token optimization verification
- Parallel processing correctness
- Migration tool functionality

### Integration Tests
- End-to-end workflow execution
- MCP server compatibility
- Cross-platform functionality
- Command deprecation handling

### Performance Benchmarks
- Execution time measurements
- Token usage analysis
- Memory consumption profiling
- Parallel vs sequential comparison

### Compatibility Tests
- Migration from Flow to Navi
- Legacy command support
- Existing project compatibility
- Rollback verification