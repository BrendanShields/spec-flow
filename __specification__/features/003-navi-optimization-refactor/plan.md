# Technical Implementation Plan: Navi System Optimization

## Executive Summary

This plan outlines the technical approach for refactoring Flow into Navi - a streamlined, efficient specification-driven development system. The refactoring focuses on four core pillars: **Simplification**, **Efficiency**, **Clarity**, and **Performance**.

## Architecture Decisions

### ADR-001: Directory Structure Migration

**Decision**: Migrate from `.flow/` to `__specification__/`

**Rationale**:
- `.flow/` is generic and may conflict with other tools
- `__specification__/` is self-documenting and unique
- Double underscore convention prevents accidental gitignore

**Implementation**:
- Use `git mv` to preserve history
- Create migration script for existing projects
- Maintain symlink for 1-month deprecation period

### ADR-002: Command Consolidation Strategy

**Decision**: Single `/navi` command with intelligent routing

**Rationale**:
- Reduces cognitive load from 15+ commands to 1
- Context-aware suggestions based on workflow phase
- Natural language fallback for unknown commands

**Implementation**:
- Unified command router with phase detection
- Deprecate individual `/flow-*` commands
- Keep subcommands for direct access (`/navi plan`)

### ADR-003: Token Optimization Approach

**Decision**: Implement progressive disclosure and lazy loading

**Rationale**:
- Current skills load entire prompts (500-1000 tokens each)
- 70% of prompt content is rarely used
- Progressive loading can reduce initial token usage by 60%

**Implementation**:
- Core instructions in base prompt (100-200 tokens)
- Detail loading on demand via @references
- Shared utility functions to eliminate duplication

### ADR-004: Parallel Processing Architecture

**Decision**: Event-driven task orchestration with worker pools

**Rationale**:
- Current sequential operations waste 40-60% of time
- File I/O and API calls are primary bottlenecks
- Parallel execution can reduce workflow time by 50%

**Priority Operations for Parallelization**:
1. Multi-file reads during analysis
2. Independent skill executions
3. Documentation generation
4. Test execution
5. File writing operations

## Implementation Phases

### Phase 1: Core Refactoring (Week 1)

#### 1.1 Naming Migration
```bash
# Global find-replace operations
Flow → Navi
flow → navi
.flow/ → __specification__/
FLOW_ → NAVI_
```

#### 1.2 Directory Restructuring
```
__specification__/
├── config/              # System configuration
├── features/            # Feature specifications
│   └── {id}-{name}/
│       ├── spec.md      # Feature specification
│       ├── plan.md      # Technical plan
│       └── tasks.md     # Implementation tasks
├── memory/              # Project memory (persistent)
├── state/               # Session state (ephemeral)
├── templates/           # Document templates
├── scripts/             # Utility scripts
└── docs/                # System documentation
    ├── architecture.md  # Consolidated architecture
    └── requirements.md  # Product requirements
```

#### 1.3 Documentation Consolidation

**Files to Remove**:
- `CLAUDE-FLOW.md` → Merge into main `CLAUDE.md`
- `COMMANDS.md` → Covered by skills
- `architecture-blueprint.md` → Merge into `architecture.md`
- `PRODUCT-REQUIREMENTS.md` → Rename to `requirements.md`

**Naming Convention**:
- All generated `.md` files use lowercase
- No UPPERCASE.md files in `__specification__/`

### Phase 2: Efficiency Optimization (Week 2)

#### 2.1 Command Unification

**New Command Structure**:
```bash
/navi              # Interactive menu (context-aware)
/navi init         # Initialize project
/navi spec "..."   # Create specification
/navi plan         # Generate technical plan
/navi tasks        # Break into tasks
/navi implement    # Execute implementation
/navi status       # Show progress
```

**Deprecation Plan**:
- Keep `/flow` as alias for 30 days
- Show migration message on old command use
- Auto-redirect to new commands

#### 2.2 Token Optimization

**Prompt Refactoring Strategy**:

1. **Extract Common Patterns**:
   ```markdown
   # Before (repeated in each skill)
   "Check if file exists, read it, validate format..."

   # After (shared utility)
   @include common/file-operations
   ```

2. **Progressive Disclosure**:
   ```markdown
   # Base prompt (100 tokens)
   Core functionality only

   # Extended on demand
   @load-details-if-needed
   ```

3. **Context Pruning**:
   - Remove historical context older than 3 operations
   - Compress repetitive information
   - Use references instead of inline content

#### 2.3 Parallel Processing Implementation

**Parallelization Map**:

```python
# Sequential (Current)
read_file(spec)       # 200ms
read_file(plan)       # 200ms
read_file(tasks)      # 200ms
Total: 600ms

# Parallel (Optimized)
parallel([
  read_file(spec),
  read_file(plan),
  read_file(tasks)
])
Total: 200ms (66% reduction)
```

**Target Operations**:
1. **File Operations**: Read/Write/Edit in parallel
2. **Skill Execution**: Independent skills run concurrently
3. **Research Tasks**: Multiple searches in parallel
4. **Validation**: Check multiple conditions simultaneously

### Phase 3: Enhancement Features (Week 3)

#### 3.1 Intelligent Routing

**Implementation**:
```python
# Natural language command interpretation
User: "create a plan for this"
System: Detects context → Routes to /navi plan

User: "what's my progress?"
System: Detects intent → Routes to /navi status
```

#### 3.2 Memory Optimization

**Auto-pruning Strategy**:
- Keep last 5 operations in detail
- Compress older operations to summaries
- Archive completed features
- Intelligent retrieval based on relevance

#### 3.3 Visual Progress Indicators

**Status Display Enhancement**:
```
Feature: User Authentication [████████░░] 80%
├─ Specification  ✅
├─ Planning       ✅
├─ Tasks          ✅
└─ Implementation 🔄 (8/10 tasks)
```

## Migration Tools

### migration-tool.sh

```bash
#!/bin/bash
# Automated migration from Flow to Navi

# 1. Detect Flow installation
# 2. Backup current state
# 3. Migrate directory structure
# 4. Update configurations
# 5. Verify functionality
# 6. Clean up old files
```

### Compatibility Layer

```bash
# Temporary aliases (30-day deprecation)
alias /flow="/navi"
alias /flow-specify="/navi spec"
alias /flow-plan="/navi plan"
# Show deprecation warning
```

## Performance Metrics

### Current Baseline
- Average command execution: 3-5 seconds
- Token usage per operation: 1000-1500
- Sequential operation time: 10-15 seconds
- Memory context size: 8000 tokens

### Target Metrics
- Average command execution: 1-2 seconds (60% faster)
- Token usage per operation: 300-500 (66% reduction)
- Parallel operation time: 3-5 seconds (66% faster)
- Memory context size: 3000 tokens (62% reduction)

## Testing Strategy

### Unit Tests
- Command routing logic
- Token optimization verification
- Parallel processing correctness
- Migration tool functionality

### Integration Tests
- End-to-end workflow execution
- MCP server compatibility
- Cross-platform functionality
- Backward compatibility

### Performance Tests
- Token usage measurement
- Execution time benchmarks
- Memory usage profiling
- Parallel processing efficiency

## Risk Mitigation

### Breaking Changes
- **Risk**: Existing projects break
- **Mitigation**: Compatibility layer + migration tool
- **Rollback**: Keep Flow artifacts for 30 days

### User Adoption
- **Risk**: Users resist change
- **Mitigation**: Clear benefits + smooth migration
- **Support**: Interactive tutorials + documentation

### Performance Regression
- **Risk**: Optimizations cause issues
- **Mitigation**: Comprehensive testing + gradual rollout
- **Monitoring**: Performance metrics dashboard

## Implementation Timeline

### Week 1: Core Refactoring
- Day 1-2: Directory migration and renaming
- Day 3-4: Documentation consolidation
- Day 5: Migration tool development

### Week 2: Optimization
- Day 1-2: Command unification
- Day 3-4: Token optimization
- Day 5: Parallel processing

### Week 3: Polish & Release
- Day 1-2: Testing and bug fixes
- Day 3: Documentation update
- Day 4: Beta release
- Day 5: Feedback incorporation

## Success Validation

### Acceptance Criteria
- [ ] All "Flow" references updated to "Navi"
- [ ] Directory successfully migrated to `__specification__/`
- [ ] Token usage reduced by minimum 30%
- [ ] Parallel operations implemented for key workflows
- [ ] Migration tool successfully converts existing projects
- [ ] No performance regression in any workflow
- [ ] Documentation clear and comprehensive

### Measurement Plan
1. **Before/After Metrics**: Document baseline and improvements
2. **User Testing**: Beta test with 5 existing projects
3. **Performance Profiling**: Automated benchmark suite
4. **Token Analysis**: Track usage across all operations

## Technical Debt Resolution

### Eliminated Redundancies
- Duplicate documentation files
- Overlapping command functionality
- Repeated prompt instructions
- Sequential processing bottlenecks

### Improved Patterns
- DRY principle throughout codebase
- Single source of truth for docs
- Efficient token utilization
- Optimal parallel execution

## Next Steps

After plan approval:
1. Generate detailed implementation tasks
2. Set up testing infrastructure
3. Create migration tool prototype
4. Begin Phase 1 implementation