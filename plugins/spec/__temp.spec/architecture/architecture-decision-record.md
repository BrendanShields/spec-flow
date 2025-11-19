# Architecture Decision Records

This document captures significant architectural decisions made throughout the project lifecycle.

---

## ADR-001: Event-Based Cache Invalidation for Context Preloading

**Date**: 2025-11-19
**Status**: Accepted
**Feature**: 002-context-preloading-hooks

### Context
The Context Preloading Hook System needs to maintain cache consistency while minimizing overhead. We evaluated multiple cache invalidation strategies:
- Time-based (TTL)
- Manual invalidation
- Event-based invalidation
- Hybrid approaches

### Decision
Implement event-based cache invalidation triggered by:
- File modification events (when available)
- Hook events (PostToolUse, phase transitions)
- Explicit invalidation calls from state updates

### Rationale
- Ensures immediate consistency when files change
- No unnecessary cache refreshes on timer
- Integrates naturally with existing hook system
- Minimal overhead - only invalidates affected entries

### Consequences
- **Positive**: Data freshness guaranteed, efficient resource usage
- **Negative**: More complex implementation, requires event tracking
- **Neutral**: Dependency on hook execution order

---

## ADR-002: Bash-Native Implementation for Hook System

**Date**: 2025-11-19
**Status**: Accepted
**Feature**: 002-context-preloading-hooks

### Context
Claude Code's hook system requires shell script implementation. Options considered:
- Pure Bash implementation
- Python/Node.js with shell wrappers
- Compiled binary with shell interface

### Decision
Implement entirely in Bash 4.0+ with optional jq for JSON processing.

### Rationale
- Native integration with existing hook infrastructure
- No additional runtime dependencies
- Cross-platform compatibility (Linux/macOS/Windows Git Bash)
- Direct access to shell environment variables
- Fast startup (no interpreter initialization)

### Consequences
- **Positive**: Zero dependencies, fast execution, simple deployment
- **Negative**: Limited to Bash capabilities, verbose JSON handling
- **Neutral**: Requires Bash 4.0+ for associative arrays

---

## ADR-003: Smart Auto-Detection for Preload Patterns

**Date**: 2025-11-19
**Status**: Accepted
**Feature**: 002-context-preloading-hooks

### Context
Users need optimal preloading without manual configuration. Approaches evaluated:
- Static configuration files
- User-defined preload rules
- Machine learning models
- Simple pattern detection

### Decision
Implement frequency-based pattern detection that learns from actual usage:
- Track file access sequences
- Build phase-specific patterns
- Update predictions based on hit rate
- No manual configuration required

### Rationale
- Zero configuration for users
- Adapts to individual workflows
- Simple enough to implement in Bash
- Good enough accuracy (>70% hit rate expected)

### Consequences
- **Positive**: Automatic optimization, personalized patterns
- **Negative**: Requires warm-up period, storage overhead
- **Neutral**: Pattern data stays local

---

## ADR-004: Local-Only Metrics Storage

**Date**: 2025-11-19
**Status**: Accepted
**Feature**: 002-context-preloading-hooks

### Context
Performance metrics are valuable but raise privacy concerns. Options:
- Send to external monitoring services
- Optional telemetry with user consent
- Local storage only
- Hybrid approach with opt-in

### Decision
Store all metrics locally in `.spec/state/metrics/` with no external transmission.

### Rationale
- Respects user privacy completely
- No network dependencies
- No consent management needed
- Metrics still available for local analysis
- Aligns with Orbit's local-first philosophy

### Consequences
- **Positive**: Complete privacy, no compliance concerns
- **Negative**: No aggregated insights, no central monitoring
- **Neutral**: Users can manually share if desired

---

## ADR-005: Smart Batching for State Updates

**Date**: 2025-11-19
**Status**: Accepted
**Feature**: 002-context-preloading-hooks

### Context
State updates need to balance responsiveness with I/O efficiency. Strategies:
- Immediate writes for all changes
- Fixed-interval batching
- Size-based batching
- Priority-based batching

### Decision
Implement dual-mode batching:
- **Critical updates** (phase changes, task completion): Write immediately (<100ms)
- **Non-critical updates** (metrics, logs): Batch every 30s or on command completion

### Rationale
- Critical changes visible immediately
- Reduces I/O for frequent small updates
- Configurable thresholds
- Maintains data consistency

### Consequences
- **Positive**: Optimal balance of performance and responsiveness
- **Negative**: More complex state management logic
- **Neutral**: Requires classification of update types

---

## Template for Future ADRs

```markdown
## ADR-XXX: [Decision Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Feature**: [Feature ID and name]

### Context
[Background and problem description]

### Decision
[What was decided]

### Rationale
[Why this decision was made]

### Consequences
- **Positive**: [Benefits]
- **Negative**: [Drawbacks]
- **Neutral**: [Side effects]
```

---

*Last Updated: 2025-11-19*