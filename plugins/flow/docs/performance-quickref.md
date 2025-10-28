# Performance & Scalability Quick Reference

## Critical Issues (Fix Immediately)

### 1. Directory Enumeration - O(N) Scan
**Location**: `common.sh:find_feature_dir_by_prefix()`  
**Impact**: 165ms per feature at 1000-feature scale  
**Fix**: Replace with cached JSON index lookup  
**Effort**: 2-3 hours  
**ROI**: 80-95% improvement  

### 2. Sequential Agent Spawning
**Location**: `flow:orchestrate` and all major skills  
**Impact**: 5-12 seconds per agent × 300+ spawns/project  
**Fix**: Implement agent pooling or batch operations  
**Effort**: 4-6 hours  
**ROI**: 50-80% improvement  

### 3. Memory Accumulation Risk
**Location**: Grep operations without limits  
**Impact**: OOM potential on 500+ feature projects  
**Fix**: Add `| head -1000` to grep commands  
**Effort**: 1 hour  
**ROI**: Prevents crashes, enables scaling  

---

## High Priority Issues (Next Sprint)

| Issue | Current | Target | Effort |
|-------|---------|--------|--------|
| File I/O (multiple reads) | 200ms+ | 30ms | 1-2h |
| String processing overhead | 850ms | 45ms | 1h |
| Context reloading | 600ms+ | 180ms | 2-3h |
| Grep inefficiency | Unbounded | Limited | 1h |

---

## Scalability Limits

```
Feature Count | Recommendation | Notes
─────────────────────────────────────────────
< 20          | ✅ Perfect      | Baseline performance
20-100        | ✅ Good         | 20+ min workflows
100-500       | ⚠️ Caution      | Multiple min overhead
500-1000      | ❌ Problematic  | Memory/timeout risk
> 1000        | ❌ Redesign     | Architecture needed
```

---

## Performance Baselines

### Single Feature (10-feature project)
- `flow:specify`: ~12 seconds
- `flow:plan`: ~18 seconds (8s agent spawn)
- `flow:implement`: ~45 seconds
- **Total**: ~75 seconds

### 50-Feature Project (Current)
- Total workflow: ~52 minutes
- Agent overhead: 26 minutes (50%)
- I/O overhead: 15 minutes (29%)

### After Quick Wins (50% improvement)
- Total: ~26 minutes
- Effort: < 3 hours

### After Medium-Term (75% improvement)
- Total: ~13 minutes ✅
- Effort: 6-8 hours

---

## Immediate Actions

### This Week
- [ ] Document scalability limits in CLAUDE.md
- [ ] Add grep result limiting (safety)
- [ ] Add performance warnings for 100+ features

### Next Sprint
- [ ] Implement feature registry cache
- [ ] Batch file read operations
- [ ] Native bash string processing
- [ ] Target: 50% improvement

### Following Sprint
- [ ] Context caching system
- [ ] Parallel orchestration
- [ ] Incremental analysis
- [ ] Target: 75% improvement

---

## Testing the Analysis

```bash
# Benchmark current performance
time flow:specify "test feature" --benchmark
time flow:plan --benchmark
time flow:tasks --benchmark

# Test at scale (10, 50, 100 features)
# Measure times and compare to predictions
```

---

## Key Metrics to Monitor

```
Weekly Performance Dashboard:
- Average workflow time (target: < 5min for 50 features)
- Agent spawn count (target: 2-3 per feature)
- File I/O operations (target: < 50 per workflow)
- Context cache hit rate (target: > 80%)
- Memory usage (target: < 50MB for 100 features)
```

---

## Common Performance Anti-Patterns

❌ **Multiple grep calls on same file**
```bash
grep "field1" file
grep "field2" file
grep "field3" file
```

✅ **Single pass, batch extraction**
```bash
content=$(cat file)
field1=$(echo "$content" | grep "field1")
field2=$(echo "$content" | grep "field2")
```

❌ **Subprocess in loop**
```bash
for word in $list; do
    echo "$word" | grep -q pattern
done
```

✅ **Native bash processing**
```bash
for word in $list; do
    [[ "$word" =~ pattern ]] && echo "$word"
done
```

❌ **Uncontrolled grep output**
```bash
grep -r "pattern" .
```

✅ **Result limiting**
```bash
grep -r "pattern" . | head -1000
```

---

## Quick Wins (Next Release)

| Change | Lines | Time | Impact |
|--------|-------|------|--------|
| Cache feature registry | ~50 | 30min | High |
| Batch file reads | ~30 | 20min | High |
| Add grep limits | ~15 | 10min | Critical |
| Native bash branching | ~20 | 20min | Medium |
| Single-pass parsing | ~40 | 25min | Medium |

**Total**: ~155 lines of code, ~2 hours, 40-50% improvement

---

## Resource Allocation

### Performance Engineer (2-3 weeks)
- Week 1: Quick wins + immediate safety fixes
- Week 2: Medium-term optimizations
- Week 3: Testing, measurement, documentation

### Team Communication
- Share performance metrics weekly
- Document breaking points (scalability limits)
- Update CLAUDE.md with limits and recommendations

---

## Related Analysis Documents

- Full analysis: `docs/performance-scalability-analysis.md` (842 lines)
- This document: Quick reference (this file)
- TODO: Performance monitoring dashboard specs
- TODO: Automated benchmarking suite

