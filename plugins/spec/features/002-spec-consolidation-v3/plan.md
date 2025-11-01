# Technical Plan: Spec v3.0 Consolidation

**Feature**: 002-spec-consolidation-v3
**Created**: 2024-10-31
**Target Version**: 3.0.0
**Estimated Duration**: 6 weeks (240 hours)
**Risk Level**: Medium

---

## Executive Summary

Transform Spec from 8 separate commands to a unified `/spec` hub command while achieving 80% token reduction and adding team collaboration features. This is a major architectural evolution requiring careful migration strategy.

**Key Metrics**:
- Commands: 8 → 1 (87.5% reduction)
- Token usage: 88,700 → 17,740 (80% reduction)
- Skills: 14 → 10 (consolidation + efficiency)
- Team features: 0 → 6 (locking, assignments, master spec, etc.)

---

## Architecture Decisions

### ADR-001: Command Router Architecture
**Decision**: Bash case statement with skill delegation (git/docker pattern)

**Implementation**:
```bash
#!/bin/bash
# .claude/commands/spec.md router

case "$1" in
  init|initialize)
    source "$SPEC_ROOT/skills/spec-init/SKILL.md"
    ;;
  ""|help|--help|-h)
    # Context-aware help based on current phase
    show_contextual_help
    ;;
  *)
    # Auto-detect: specification text vs subcommand
    if [[ "$1" =~ ^[a-z-]+$ ]]; then
      route_to_skill "$1" "${@:2}"
    else
      # Free text = specification
      source "$SPEC_ROOT/skills/spec-specify/SKILL.md"
    fi
    ;;
esac
```

**Benefits**:
- Simple, proven pattern
- Fast routing (no external dependencies)
- Easy to debug and extend
- Token-efficient

**Effort**: 8-16 hours

---

### ADR-002: Lazy Loading Strategy
**Decision**: Three-tier progressive disclosure + file-based lazy loading

**Tier 1 - Always Loaded** (~500 tokens):
- Command router
- Context detection
- Basic help

**Tier 2 - On Demand** (~1,750 tokens):
- Skill SKILL.md when invoked
- State management utils
- Common functions

**Tier 3 - Progressive** (~15,000 tokens):
- Skill EXAMPLES.md (only if `--examples` flag)
- Skill REFERENCE.md (only if `--reference` flag)
- Agent definitions (only when launched)

**Implementation**:
```bash
# Lazy load skill
load_skill() {
  local skill=$1
  if [[ ! -v SPEC_SKILLS_LOADED[$skill] ]]; then
    source "$SPEC_ROOT/skills/$skill/SKILL.md"
    SPEC_SKILLS_LOADED[$skill]=1
  fi
}
```

**Token Reduction**:
- Before: 14,400 tokens (all 8 commands + full skill docs)
- After: 2,250 tokens (router + 1 skill core)
- Savings: 84% ✅ (exceeds 80% target)

**Effort**: 24-32 hours

---

### ADR-003: State Management Evolution
**Decision**: Hybrid JSON (source of truth) + auto-generated Markdown (human view)

**Directory Structure**:
```
.spec-state/
├── session.json              # Machine-readable source
├── current-session.md        # Auto-generated view
└── checkpoints/
    └── checkpoint-*.json

.spec-memory/
├── workflow.json             # Source of truth
├── decisions.json
├── changes-planned.json
├── changes-completed.json
├── WORKFLOW-PROGRESS.md      # Auto-generated
├── DECISIONS-LOG.md          # Auto-generated
├── CHANGES-PLANNED.md        # Auto-generated
└── CHANGES-COMPLETED.md      # Auto-generated
```

**JSON Schema** (session.json):
```json
{
  "sessionId": "spec-plugin-dev-001",
  "started": "2024-10-30T00:00:00Z",
  "type": "plugin-development",
  "activeFeature": {
    "id": "002",
    "name": "spec-consolidation-v3",
    "phase": "planning",
    "progress": 25,
    "assignedTo": "@username"
  },
  "features": [
    {
      "id": "001",
      "name": "plugin-stabilization",
      "status": "complete",
      "completedAt": "2024-10-31T00:00:00Z"
    }
  ],
  "tasks": {
    "total": 3,
    "completed": 3,
    "inProgress": 0,
    "remaining": 0
  },
  "environment": {
    "workingDir": "/path/to/project",
    "gitBranch": "main",
    "version": "3.0.0"
  }
}
```

**Auto-Generation**:
```bash
# Generate markdown from JSON
spec_sync_state() {
  jq -r '.activeFeature | "### Active Feature\n**Feature**: \(.name)\n**Status**: \(.phase)"' \
    .spec-state/session.json > .spec-state/current-session.md.tmp
  # ... generate full markdown
  mv .spec-state/current-session.md.tmp .spec-state/current-session.md
}
```

**Benefits**:
- Zero merge conflicts (JSON is structured)
- Git-friendly diffs
- Human-readable views preserved
- Machine-parseable for tooling

**Migration Strategy**:
- Read existing .md files
- Parse into JSON
- Write JSON + regenerate .md
- Verify equivalence
- Switch to JSON source

**Effort**: 32-40 hours

---

### ADR-004: Backward Compatibility
**Decision**: Wrapper scripts + 1-year deprecation period

**Implementation**:
```bash
# .claude/commands/spec-init.md (wrapper)
#!/bin/bash
echo "⚠️  DEPRECATED: /spec-init is deprecated, use '/spec init' instead"
echo "   This wrapper will be removed in v4.0 (2026-01-01)"
echo ""
/spec init "$@"
```

**Deprecation Timeline**:
- **v3.0.0** (2025-01): Wrappers added, deprecation warnings shown
- **v3.1.0** (2025-04): Warnings become more prominent
- **v3.9.0** (2025-10): Final warning with migration guide
- **v4.0.0** (2026-01): Wrappers removed

**Migration Guide**:
```markdown
# Spec v2.1 → v3.0 Migration Guide

## Command Changes
| Old Command | New Command | Notes |
|-------------|-------------|-------|
| /spec-init | /spec init | Wrapper available until v4.0 |
| /spec-specify "X" | /spec "X" | Auto-detects specification |
| /spec-plan | /spec plan | Or just `/spec` in planning phase |
| /spec-tasks | /spec tasks | Or just `/spec` in tasks phase |
| /spec-implement | /spec implement | Or just `/spec` to continue |

## State File Changes
Your existing `.spec-state/*.md` files will be automatically migrated to JSON + MD on first run of v3.0.

Backup created at: `.spec-state-backup-v2.1/`
```

**Auto-Migration**:
```bash
spec_migrate_v2_to_v3() {
  if [[ ! -f .spec-state/session.json ]]; then
    # Backup v2.1 state
    cp -r .spec-state .spec-state-backup-v2.1

    # Parse markdown → JSON
    parse_session_md_to_json .spec-state/current-session.md > .spec-state/session.json

    # Regenerate markdown from JSON (validates round-trip)
    spec_sync_state

    echo "✅ Migrated from v2.1 → v3.0 (backup: .spec-state-backup-v2.1/)"
  fi
}
```

**Effort**: 8-12 hours

---

### ADR-005: Team Collaboration Locking
**Decision**: File-based locking with TTL + PID tracking

**Lock File Structure**:
```json
# .spec-state/locks/feature-002.lock
{
  "featureId": "002",
  "lockedBy": "@alice",
  "lockedAt": "2024-10-31T10:30:00Z",
  "ttl": 7200,
  "pid": 12345,
  "hostname": "alice-macbook.local",
  "reason": "Working on Phase 2 implementation"
}
```

**Locking API**:
```bash
# Acquire lock
spec_lock_feature() {
  local feature_id=$1
  local lock_file=".spec-state/locks/feature-${feature_id}.lock"

  # Check if locked
  if [[ -f "$lock_file" ]]; then
    local locked_by=$(jq -r '.lockedBy' "$lock_file")
    local locked_at=$(jq -r '.lockedAt' "$lock_file")
    local ttl=$(jq -r '.ttl' "$lock_file")
    local pid=$(jq -r '.pid' "$lock_file")

    # Check TTL expiry
    local now=$(date -u +%s)
    local locked_ts=$(date -d "$locked_at" +%s)
    local elapsed=$((now - locked_ts))

    if [[ $elapsed -gt $ttl ]]; then
      echo "⚠️  Stale lock detected (${elapsed}s old), removing..."
      rm "$lock_file"
    elif ! kill -0 "$pid" 2>/dev/null; then
      echo "⚠️  Process $pid not running, removing stale lock..."
      rm "$lock_file"
    else
      echo "❌ Feature $feature_id locked by $locked_by since $locked_at"
      return 1
    fi
  fi

  # Acquire lock
  cat > "$lock_file" <<EOF
{
  "featureId": "$feature_id",
  "lockedBy": "$(git config user.name)",
  "lockedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ttl": 7200,
  "pid": $$,
  "hostname": "$(hostname)",
  "reason": "Working on feature $feature_id"
}
EOF

  echo "✅ Acquired lock on feature $feature_id"
}

# Release lock
spec_unlock_feature() {
  local feature_id=$1
  local lock_file=".spec-state/locks/feature-${feature_id}.lock"

  if [[ -f "$lock_file" ]]; then
    local locked_by=$(jq -r '.lockedBy' "$lock_file")
    local current_user=$(git config user.name)

    if [[ "$locked_by" == "$current_user" ]]; then
      rm "$lock_file"
      echo "✅ Released lock on feature $feature_id"
    else
      echo "❌ Cannot release lock held by $locked_by"
      return 1
    fi
  fi
}

# Force unlock (admin)
spec_force_unlock_feature() {
  local feature_id=$1
  local lock_file=".spec-state/locks/feature-${feature_id}.lock"

  if [[ -f "$lock_file" ]]; then
    local locked_by=$(jq -r '.lockedBy' "$lock_file")
    echo "⚠️  Force unlocking feature $feature_id (was locked by $locked_by)"
    rm "$lock_file"
  fi
}
```

**Team Status Dashboard**:
```bash
spec_team_status() {
  echo "📊 Spec Team Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Active locks
  if [[ -d .spec-state/locks ]]; then
    echo ""
    echo "🔒 Active Locks:"
    for lock in .spec-state/locks/*.lock; do
      local feature=$(jq -r '.featureId' "$lock")
      local user=$(jq -r '.lockedBy' "$lock")
      local since=$(jq -r '.lockedAt' "$lock")
      echo "  - Feature $feature: $user (since $since)"
    done
  fi

  # Task assignments
  echo ""
  echo "👥 Task Assignments:"
  jq -r '.tasks[] | select(.assignedTo) | "  - \(.id): \(.description) (@\(.assignedTo))"' \
    .spec-state/session.json

  # Feature progress
  echo ""
  echo "📈 Feature Progress:"
  jq -r '.features[] | "  - \(.id)-\(.name): \(.status) (\(.progress)%)"' \
    .spec-state/session.json
}
```

**Benefits**:
- Simple, no external dependencies
- TTL prevents indefinite locks
- PID tracking detects stale locks
- Manual override available

**Effort**: 16-24 hours

---

### ADR-006: Master Spec Generation
**Decision**: Incremental aggregation with dependency tracking

**Master Spec Structure**:
```markdown
# Spec Plugin - Master Specification

**Generated**: 2024-10-31 10:30:00
**Version**: 3.0.0
**Features**: 2 active, 1 completed

---

## Product Vision

[Aggregated from .spec/product-requirements.md]

---

## Architecture

[Aggregated from .spec/architecture-blueprint.md]

---

## Features

### ✅ Completed Features

#### Feature 001: Plugin Stabilization
**Completed**: 2024-10-31
**Duration**: 1 day

[Embedded from features/001-plugin-stabilization/spec.md]

---

### 🔄 Active Features

#### Feature 002: Spec Consolidation v3
**Phase**: Planning
**Progress**: 50%
**Assigned**: @alice

[Embedded from features/002-spec-consolidation-v3/spec.md]

---

### 📋 Planned Features

[List from .spec-memory/CHANGES-PLANNED.md]

---

## Technical Decisions

[Aggregated from .spec-memory/DECISIONS-LOG.md]

---

## Metrics

[Aggregated from .spec-memory/WORKFLOW-PROGRESS.md]

---

*Auto-generated by Spec v3.0*
*Do not edit manually - changes will be overwritten*
*Source files: see individual feature directories*
```

**Generation Engine**:
```bash
spec_generate_master_spec() {
  local output=".spec/master-spec.md"
  local temp="$output.tmp"

  # Header
  cat > "$temp" <<EOF
# Spec Plugin - Master Specification

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Version**: $(cat .spec/config/version)
**Features**: $(count_active_features) active, $(count_completed_features) completed

---

EOF

  # Product vision
  echo "## Product Vision" >> "$temp"
  echo "" >> "$temp"
  cat .spec/config/product-requirements.md >> "$temp"
  echo "" >> "$temp"
  echo "---" >> "$temp"
  echo "" >> "$temp"

  # Architecture
  echo "## Architecture" >> "$temp"
  echo "" >> "$temp"
  cat .spec/config/architecture-blueprint.md >> "$temp"
  echo "" >> "$temp"
  echo "---" >> "$temp"
  echo "" >> "$temp"

  # Features - Completed
  echo "## Features" >> "$temp"
  echo "" >> "$temp"
  echo "### ✅ Completed Features" >> "$temp"
  echo "" >> "$temp"
  for feature_dir in features/*/; do
    if is_feature_complete "$feature_dir"; then
      embed_feature_spec "$feature_dir" >> "$temp"
    fi
  done
  echo "" >> "$temp"

  # Features - Active
  echo "### 🔄 Active Features" >> "$temp"
  echo "" >> "$temp"
  for feature_dir in features/*/; do
    if is_feature_active "$feature_dir"; then
      embed_feature_spec "$feature_dir" >> "$temp"
    fi
  done
  echo "" >> "$temp"

  # Features - Planned
  echo "### 📋 Planned Features" >> "$temp"
  echo "" >> "$temp"
  cat .spec-memory/CHANGES-PLANNED.md >> "$temp"
  echo "" >> "$temp"
  echo "---" >> "$temp"
  echo "" >> "$temp"

  # Decisions
  echo "## Technical Decisions" >> "$temp"
  echo "" >> "$temp"
  cat .spec-memory/DECISIONS-LOG.md >> "$temp"
  echo "" >> "$temp"
  echo "---" >> "$temp"
  echo "" >> "$temp"

  # Metrics
  echo "## Metrics" >> "$temp"
  echo "" >> "$temp"
  cat .spec-memory/WORKFLOW-PROGRESS.md >> "$temp"
  echo "" >> "$temp"
  echo "---" >> "$temp"
  echo "" >> "$temp"

  # Footer
  cat >> "$temp" <<EOF

*Auto-generated by Spec v$(cat .spec/config/version)*
*Do not edit manually - changes will be overwritten*
*Source files: see individual feature directories*
EOF

  # Atomic write
  mv "$temp" "$output"

  echo "✅ Generated master spec: $output ($(wc -l < $output) lines)"
}
```

**Auto-Regeneration Triggers**:
- After `/spec-specify` (new feature added)
- After `/spec-implement` completes (feature status changed)
- On-demand with `/spec master-spec`
- Pre-commit hook (optional)

**Benefits**:
- Always up-to-date documentation
- Single source of truth for product
- Easy onboarding (one file to read)
- Audit trail preserved

**Effort**: 24-32 hours

---

## Implementation Phases

### Phase 1: Command Consolidation (2 weeks, 80 hours)

**Objectives**:
- Create unified `/spec` hub command
- Implement intelligent routing
- Add context-aware help
- Maintain backward compatibility wrappers

**Tasks**:
1. Create `.claude/commands/spec.md` router (8h)
2. Implement context detection logic (8h)
3. Add subcommand routing (12h)
4. Create interactive mode menu (16h)
5. Add shell completion scripts (12h)
6. Create deprecation wrappers for old commands (8h)
7. Update all skill references (8h)
8. Write migration guide (8h)

**Deliverables**:
- ✅ Working `/spec` command
- ✅ All subcommands functional
- ✅ Interactive mode working
- ✅ Migration guide complete
- ✅ Backward compat wrappers

**Validation**:
```bash
# Test routing
/spec init
/spec "New feature"
/spec plan
/spec

# Test interactive mode
/spec --interactive

# Test backward compat
/spec-init  # Should warn but work
```

---

### Phase 2: Token Optimization (2 weeks, 80 hours)

**Objectives**:
- Implement three-tier lazy loading
- Achieve 80% token reduction
- Optimize skill file sizes
- Add progressive disclosure

**Tasks**:
1. Implement lazy loading infrastructure (16h)
2. Split skills into SKILL/EXAMPLES/REFERENCE (24h)
3. Consolidate 14 → 10 skills (20h)
4. Add `--examples` and `--reference` flags (8h)
5. Optimize state file templates (8h)
6. Add token usage metrics (4h)

**Deliverables**:
- ✅ Lazy loading system
- ✅ Skills reorganized
- ✅ Token usage < 20,000 per invocation
- ✅ Progressive disclosure working

**Validation**:
```bash
# Measure tokens before/after
spec_measure_tokens /spec-specify  # Before: ~14,400
spec_measure_tokens /spec          # After: ~2,250

# Test progressive disclosure
/spec plan              # Core only
/spec plan --examples   # + examples
/spec plan --reference  # + reference
```

---

### Phase 3: State Management Evolution (1.5 weeks, 60 hours)

**Objectives**:
- Migrate state files to JSON + auto-generated MD
- Ensure zero merge conflicts
- Implement auto-migration from v2.1

**Tasks**:
1. Design JSON schemas (8h)
2. Implement JSON → MD generators (16h)
3. Create auto-migration tool (12h)
4. Update all state read/write code (16h)
5. Add validation and testing (8h)

**Deliverables**:
- ✅ JSON state files as source of truth
- ✅ Auto-generated markdown views
- ✅ Migration from v2.1 working
- ✅ Zero merge conflicts

**Validation**:
```bash
# Test migration
cp -r .spec-state .spec-state-v2.1-backup
/spec  # Triggers auto-migration
diff -r .spec-state-v2.1-backup .spec-state

# Test round-trip
spec_sync_state
diff .spec-state/session.json <(parse_session_md .spec-state/current-session.md)

# Test merge
git checkout -b team-member-1
# ... make changes
git checkout main
git merge team-member-1  # Should have zero conflicts
```

---

### Phase 4: Team Collaboration (1 week, 40 hours)

**Objectives**:
- Implement feature-level locking
- Add task assignment with @username
- Create team status dashboard

**Tasks**:
1. Implement file-based locking (12h)
2. Add TTL and PID tracking (8h)
3. Create task assignment system (8h)
4. Build team status dashboard (8h)
5. Add team-specific documentation (4h)

**Deliverables**:
- ✅ Feature locking working
- ✅ Task assignments functional
- ✅ Team dashboard available
- ✅ Stale lock detection

**Validation**:
```bash
# Test locking
/spec "New feature"  # Acquires lock
# Another team member tries
/spec "New feature"  # Should show locked message

# Test assignments
/spec assign @alice T001
/spec status  # Shows @alice assigned to T001

# Test dashboard
/spec team  # Shows all locks, assignments, progress
```

---

### Phase 5: Master Spec & Polish (1.5 weeks, 60 hours)

**Objectives**:
- Implement master spec auto-generation
- Add comprehensive testing
- Polish user experience
- Update all documentation

**Tasks**:
1. Implement master spec generator (16h)
2. Add auto-regeneration triggers (8h)
3. Create comprehensive test suite (16h)
4. Performance optimization (8h)
5. Update all documentation (8h)
6. Create demo video/tutorial (4h)

**Deliverables**:
- ✅ Master spec auto-generation
- ✅ Comprehensive tests passing
- ✅ Performance benchmarks met
- ✅ Documentation complete
- ✅ Demo materials ready

**Validation**:
```bash
# Test master spec
/spec master-spec
cat .spec/master-spec.md  # Should be comprehensive

# Run test suite
./tests/run-all-tests.sh

# Performance benchmark
time /spec "New feature"  # < 2s
```

---

## Risk Assessment & Mitigation

### HIGH Risks

#### Risk: Token Budget Overrun
**Probability**: Medium
**Impact**: High
**Mitigation**:
- Prototype lazy loading early (Phase 2, Week 1)
- Measure token usage continuously
- Have rollback plan if target not met
- Use `--reference` flags instead of always loading

**Contingency**: If 80% reduction not achievable, scale back to 60% and defer some features to v3.1

---

#### Risk: Merge Conflicts in Team Environment
**Probability**: Medium
**Impact**: High
**Mitigation**:
- JSON state files with structured diffs
- Feature-level locking prevents simultaneous edits
- Git merge driver for JSON files
- Comprehensive testing with multiple team members

**Contingency**: If JSON approach fails, implement operational transformation (OT) for real-time sync

---

### MEDIUM Risks

#### Risk: Backward Compatibility Breaks
**Probability**: Low
**Impact**: High
**Mitigation**:
- Wrapper scripts for all old commands
- 1-year deprecation period
- Auto-migration on first run
- Comprehensive migration guide

**Contingency**: If breaking changes cause issues, extend deprecation to v5.0 (2 years)

---

#### Risk: Feature Locking Complexity
**Probability**: Medium
**Impact**: Medium
**Mitigation**:
- Simple file-based approach (no external deps)
- TTL prevents indefinite locks
- PID tracking detects stale locks
- Force unlock available for admins

**Contingency**: If locking proves problematic, make it opt-in with `SPEC_TEAM_MODE=enabled`

---

#### Risk: Master Spec Parsing Failures
**Probability**: Low
**Impact**: Medium
**Mitigation**:
- Simple concatenation approach (minimal parsing)
- Validation before committing
- Fallback to manual generation

**Contingency**: If auto-generation fails, provide manual template and periodic regeneration script

---

### LOW Risks

#### Risk: Router Performance
**Probability**: Low
**Impact**: Low
**Mitigation**:
- Bash case statements are fast (O(1) routing)
- Minimal overhead vs current approach
- Benchmark during Phase 1

**Contingency**: If performance issues arise, optimize case statement ordering

---

#### Risk: State Migration Data Loss
**Probability**: Very Low
**Impact**: High
**Mitigation**:
- Automatic backup before migration
- Round-trip validation (MD → JSON → MD)
- Dry-run mode for testing
- Rollback script available

**Contingency**: If migration fails, restore from backup and fix issues before retrying

---

## Testing Strategy

### Unit Tests
```bash
tests/
├── unit/
│   ├── test-router.sh           # Command routing logic
│   ├── test-lazy-loading.sh     # Lazy loading mechanism
│   ├── test-state-json.sh       # JSON state management
│   ├── test-locking.sh          # Feature locking
│   └── test-master-spec.sh      # Master spec generation
```

**Coverage Target**: 80% of critical paths

---

### Integration Tests
```bash
tests/
├── integration/
│   ├── test-full-workflow.sh    # Init → Specify → Plan → Tasks → Implement
│   ├── test-team-collab.sh      # Multi-user scenarios
│   ├── test-migration.sh        # v2.1 → v3.0 migration
│   └── test-backward-compat.sh  # Old command wrappers
```

**Scenarios**:
- Single user full workflow
- Team collaboration with locks
- Migration from v2.1
- Backward compatibility

---

### Performance Tests
```bash
tests/
├── performance/
│   ├── benchmark-token-usage.sh # Token reduction validation
│   ├── benchmark-speed.sh       # Command execution speed
│   └── benchmark-memory.sh      # Memory usage
```

**Targets**:
- Token usage: < 20,000 per command
- Command execution: < 2s for routing
- Memory usage: < 100MB

---

### Manual Testing Checklist
- [ ] Install fresh on macOS
- [ ] Install fresh on Linux
- [ ] Migrate existing v2.1 project
- [ ] Multi-user collaboration (2-3 people)
- [ ] All 10 skills functional
- [ ] Interactive mode usable
- [ ] Shell completion working
- [ ] Documentation accurate
- [ ] Error messages helpful
- [ ] Performance acceptable

---

## Success Criteria

### Functional Requirements
- ✅ Single `/spec` command replaces all 8 commands
- ✅ 80% token reduction achieved (< 20,000 tokens per invocation)
- ✅ Team collaboration features working (locking, assignments)
- ✅ Master spec auto-generation functional
- ✅ Backward compatibility maintained
- ✅ Migration from v2.1 seamless

### Non-Functional Requirements
- ✅ Command execution < 2s
- ✅ Zero merge conflicts in team environment
- ✅ All tests passing (unit, integration, performance)
- ✅ Documentation complete and accurate
- ✅ User experience improved (measured via feedback)

### Quality Metrics
- ✅ Test coverage > 80%
- ✅ Zero critical bugs
- ✅ Performance benchmarks met
- ✅ User satisfaction > 4.5/5

---

## Rollout Plan

### Alpha Release (v3.0.0-alpha.1)
**Audience**: Internal testing (Spec plugin development)
**Duration**: 1 week
**Focus**: Bug identification, performance validation

### Beta Release (v3.0.0-beta.1)
**Audience**: Early adopters (5-10 users)
**Duration**: 2 weeks
**Focus**: Team collaboration testing, migration validation

### Release Candidate (v3.0.0-rc.1)
**Audience**: Public beta (50+ users)
**Duration**: 2 weeks
**Focus**: Final bug fixes, documentation polish

### General Availability (v3.0.0)
**Audience**: All users
**Date**: ~6 weeks from start (mid-December 2024)

---

## Dependencies

### Internal
- Feature 001 (plugin-stabilization) must be merged first
- Product requirements and architecture blueprint must be finalized

### External
- None (pure bash/markdown, no external dependencies)

### Tools Required
- Bash 4.0+ (for associative arrays)
- jq 1.6+ (for JSON processing)
- Git 2.0+ (for merge drivers)
- Standard Unix tools (awk, sed, grep)

---

## Team & Resources

### Development Team
- **Primary Developer**: 1 FTE (6 weeks)
- **Code Reviewer**: 0.2 FTE (reviews)
- **Documentation Writer**: 0.5 FTE (concurrent with dev)

### Timeline
- **Week 1-2**: Phase 1 (Command Consolidation)
- **Week 3-4**: Phase 2 (Token Optimization)
- **Week 4-5**: Phase 3 (State Management) - overlaps with Phase 2
- **Week 5**: Phase 4 (Team Collaboration)
- **Week 6**: Phase 5 (Master Spec & Polish)

**Critical Path**: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

**Parallelization Opportunities**:
- Phase 2 & 3 can partially overlap (state work doesn't block token optimization)
- Documentation can be written concurrently with development
- Testing can start as soon as Phase 1 completes

---

## Post-Launch Plan

### v3.1.0 (3 months after v3.0)
- AI-powered task assignment improvements
- Advanced team analytics
- Custom workflow templates

### v3.2.0 (6 months after v3.0)
- MCP server integration
- Visual workflow editor (web-based)
- Real-time collaboration features

### v4.0.0 (12 months after v3.0)
- Remove deprecated wrappers
- Major architecture evolution based on v3.x learnings
- Enterprise features (SSO, audit logs, compliance)

---

## Appendices

### A. Command Mapping (v2.1 → v3.0)

| v2.1 Command | v3.0 Command | Notes |
|--------------|--------------|-------|
| /spec-init | /spec init | Wrapper available |
| /spec-specify "X" | /spec "X" | Auto-detects spec text |
| /spec-plan | /spec plan | Or just `/spec` |
| /spec-tasks | /spec tasks | Or just `/spec` |
| /spec-implement | /spec implement | Or just `/spec` |
| /spec-clarify | /spec clarify | Or `/spec` in spec phase |
| /spec-update | /spec update | Rare, explicit call |
| /spec-analyze | /spec analyze | Or `/spec` with analysis flag |

### B. Skill Consolidation Plan

| Current Skills (14) | Consolidated Skills (10) | Rationale |
|---------------------|--------------------------|-----------|
| spec-init | spec-init | Keep (distinct phase) |
| spec-specify | spec-specify | Keep (core workflow) |
| spec-clarify | → spec-specify | Merge (sub-step of specification) |
| spec-plan | spec-plan | Keep (core workflow) |
| spec-tasks | spec-tasks | Keep (core workflow) |
| spec-implement | spec-implement | Keep (core workflow) |
| spec-update | → spec-specify | Merge (variant of specification) |
| spec-analyze | spec-analyze | Keep (analysis distinct) |
| spec-blueprint | → spec-init | Merge (part of initialization) |
| spec-checklist | → spec-specify | Merge (validation sub-step) |
| spec-discover | → spec-init | Merge (brownfield initialization) |
| spec-metrics | spec-metrics | Keep (reporting distinct) |
| spec-orchestrate | → spec (hub) | Merge (orchestration = hub command) |
| skill-builder | skill-builder | Keep (meta-skill for creating skills) |

**Result**: 14 → 10 skills (29% reduction)

### C. Token Budget Breakdown

**Current (v2.1)**:
```
Commands (8 × 1,261 lines):       10,088 tokens
Skills (14 × 2,931 lines):        41,034 tokens
Agents (3 × 5,000 tokens):        15,000 tokens
State templates:                   5,000 tokens
Hooks & utilities:                 2,500 tokens
Documentation loaded:             15,078 tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL:                            88,700 tokens
```

**Target (v3.0)**:
```
Hub command (1 × 250 lines):         500 tokens
Active skill core:                 1,750 tokens
State utils (lazy loaded):           500 tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL (Tier 1 + Tier 2):          2,250 tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progressive (on --examples):      +5,000 tokens
Progressive (on --reference):     +8,000 tokens
Agent (on launch):               +15,000 tokens
```

**Reduction**: 88,700 → 2,250 = **97.5% reduction** for typical invocation ✅

### D. Migration Script

```bash
#!/bin/bash
# migrate-v2-to-v3.sh

set -euo pipefail

echo "🔄 Spec v2.1 → v3.0 Migration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Backup
echo "📦 Creating backup..."
BACKUP_DIR=".spec-backup-v2.1-$(date +%Y%m%d-%H%M%S)"
cp -r .spec-state "$BACKUP_DIR"
echo "✅ Backup created: $BACKUP_DIR"

# Migrate state files
echo ""
echo "🔧 Migrating state files to JSON..."
for md_file in .spec-state/*.md; do
  json_file="${md_file%.md}.json"
  if [[ ! -f "$json_file" ]]; then
    echo "  - Converting $(basename "$md_file") → $(basename "$json_file")"
    parse_session_md_to_json "$md_file" > "$json_file"
  fi
done

# Regenerate markdown from JSON
echo ""
echo "📝 Regenerating markdown views..."
spec_sync_state

# Validate round-trip
echo ""
echo "✅ Validating migration..."
for json_file in .spec-state/*.json; do
  md_file="${json_file%.json}.md"
  if [[ -f "$md_file" ]]; then
    echo "  - Checking $(basename "$json_file") ↔ $(basename "$md_file")"
    # Round-trip validation
    temp_json=$(mktemp)
    parse_session_md_to_json "$md_file" > "$temp_json"
    if diff -q "$json_file" "$temp_json" >/dev/null 2>&1; then
      echo "    ✅ Valid"
    else
      echo "    ⚠️  Differences detected, manual review needed"
    fi
    rm "$temp_json"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Migration complete!"
echo ""
echo "Your v2.1 state has been backed up to: $BACKUP_DIR"
echo "New JSON state files created in: .spec-state/"
echo ""
echo "Next steps:"
echo "  1. Review the migration with: diff -r $BACKUP_DIR .spec-state"
echo "  2. Test the new commands: /spec"
echo "  3. If everything works, you can remove the backup"
echo ""
echo "To rollback: mv $BACKUP_DIR .spec-state"
```

---

**Plan Created**: 2024-10-31
**Author**: Spec v3.0 Planning Team
**Status**: Ready for Task Breakdown
**Next Step**: `/spec-tasks` to break into executable tasks
