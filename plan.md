# Spec-Flow Quality & Efficiency Improvement Plan

**Date**: 2025-10-24
**Assessment By**: Claude Code (Sonnet 4.5)
**Status**: Phase 1 - Skills Uplift

---

## Executive Summary

Comprehensive assessment of 13 skills, 8 hooks, and 3 agents against Claude Code best practices revealed significant opportunities for optimization:

- **Token Efficiency**: 40-60% reduction possible across all skills
- **Quality**: Missing validation, security hardening needed
- **Discovery**: Inconsistent activation patterns
- **Modularity**: Lack of progressive disclosure architecture

---

## Assessment Findings

### Skills Analysis (13 total)

#### Token Efficiency Metrics

| Skill | Current Lines | Target Lines | Reduction | Priority |
|-------|--------------|--------------|-----------|----------|
| flow-init | 401 | 150 | 63% | HIGH |
| flow-update | 389 | 150 | 61% | HIGH |
| flow-discover | 313 | 150 | 52% | HIGH |
| flow-specify | 280 | 150 | 46% | HIGH |
| flow-metrics | 253 | 150 | 41% | HIGH |
| flow-blueprint | 222 | 150 | 32% | MEDIUM |
| flow-orchestrate | 201 | 150 | 25% | MEDIUM |
| flow-tasks | 155 | 130 | 16% | LOW |
| flow-checklist | 108 | 90 | 17% | LOW |
| flow-plan | 103 | 90 | 13% | LOW |
| flow-analyze | 96 | 80 | 17% | LOW |
| flow-implement | ~160* | 130 | 19% | LOW |
| flow-clarify | 52 | 50 | 4% | LOW |

*Has existing EXAMPLES.md (69 lines) and REFERENCE.md (86 lines)

#### Critical Issues Found

**❌ No Progressive Disclosure**
- Only 3 skills have separate resource files
- 10 skills have ALL content inline in SKILL.md
- Examples, patterns, config embedded directly

**❌ Missing Modular Resources**
- No EXAMPLES.md: 10/13 skills
- No REFERENCE.md: 11/13 skills
- No validate.sh: 13/13 skills (0% coverage)
- No templates/: Most skills lack extracted templates

**⚠️ Inconsistent Discovery Format**
- Not all use "5 numbered Use when" pattern
- Description lengths vary (52-1024 chars)
- Some lack clear output statements

**✅ Good Practices Found**
- flow-implement: Has EXAMPLES.md + REFERENCE.md + examples.md
- flow-specify: Has examples.md + reference.md
- flow-orchestrate: Has examples.md
- All skills use proper YAML frontmatter
- Tool restrictions properly defined

---

### Hooks Analysis (8 total)

#### Hook Inventory

| Hook File | Lines | Event | Purpose |
|-----------|-------|-------|---------|
| detect-intent.js | 198 | UserPromptSubmit | Intent detection |
| format-code.js | 159 | PostToolUse | Auto-formatting |
| post-specify.js | 337 | PostToolUse | Post-spec actions |
| pre-specify.js | 257 | PreToolUse | Pre-spec validation |
| restore-session.js | 141 | SessionStart | Session restore |
| save-session.js | 200 | Stop | Session save |
| track-metrics.js | 507 | PostToolUse | Metrics tracking |
| update-workflow-status.js | 177 | PostToolUse | Status updates |
| validate-prerequisites.js | 186 | PreToolUse | Prerequisite check |

**Total Hook Code**: 2,209 lines

#### Issues Found

**⚠️ Security Concerns** (Need Validation):
- Hardcoded absolute paths in hooks.json
- Need to audit variable quoting in JS files
- Input validation patterns need review
- Path traversal protection needed

**❌ Documentation Gaps**:
- No JSDoc comments in hook files
- No hooks/README.md overview
- No inline documentation of hook behavior
- Missing error handling documentation

**⚠️ Maintainability**:
- No shared utility functions
- Repeated patterns across hooks
- No testing framework for hooks

---

### Agents Analysis (3 total)

#### Agent Metrics

| Agent | Lines | Tools | Status |
|-------|-------|-------|--------|
| flow-researcher | 358 | WebSearch, WebFetch, Read, Write | ❌ Too verbose |
| flow-implementer | 331 | Read, Write, Edit, Glob, Grep, Bash | ❌ Too verbose |
| flow-analyzer | 276 | Read, Glob, Grep, Bash | ❌ Too verbose |

**Target**: <200 lines per agent

#### Issues Found

**❌ No Modular Resources**:
- All patterns inline (should be in reference.md)
- All examples inline (should be in examples.md)
- All configuration inline (should be in reference.md)
- No separation of concerns

**⚠️ Weak Activation Triggers**:
- Only flow-analyzer has "Use PROACTIVELY"
- Descriptions lack numbered trigger conditions
- Not optimized for auto-delegation
- Missing clear activation keywords

**❌ Repetitive Structure**:
- Similar sections across all 3 agents
- Duplicate configuration patterns
- Could extract common patterns

---

## Improvement Plan

### Phase 1: Skills Uplift (13 skills)

**Objective**: Achieve 40-60% token reduction through progressive disclosure

#### Standard Uplift Pattern (Per Skill)

**1. Create EXAMPLES.md** (~30% reduction)
```markdown
# {Skill Name} Examples

## Quick Start
[Simplest usage]

## Common Scenarios
[3-5 real-world examples]

## Advanced Patterns
[Complex use cases]

## Anti-Patterns
[What NOT to do]
```

**2. Create REFERENCE.md** (~20% reduction)
```markdown
# {Skill Name} Reference

## Configuration Options
[All config details]

## Integration Patterns
[MCP, hooks, other skills]

## Troubleshooting
[Common issues and solutions]

## API Reference
[Detailed technical specs]
```

**3. Create templates/** (~10% reduction)
- Extract inline template content
- Create reusable template files
- Document template variables

**4. Create scripts/validate.sh** (quality)
```bash
#!/bin/bash
# Validates SKILL.md syntax, tests activation
```

**5. Optimize SKILL.md Core**
```markdown
---
name: skill-name
description: [Capability] Use when: 1) [trigger], 2) [trigger], 3) [trigger], 4) [trigger], 5) [trigger]. [Output].
allowed-tools: Tool1, Tool2
---

# Skill Name

[Brief overview - 1 paragraph]

## Workflow

[Essential steps only - 5-10 bullet points]

## Output

[What this skill produces]

## Configuration

[Reference to REFERENCE.md for details]

## Examples

[Reference to EXAMPLES.md]

## Related Skills

[Links to related skills]
```

#### Execution Order (Priority-Based)

**Week 1: High Priority (5 skills)**
1. flow-init (401→150 lines, 63% reduction)
2. flow-update (389→150 lines, 61% reduction)
3. flow-discover (313→150 lines, 52% reduction)
4. flow-specify (280→150 lines, 46% reduction)
5. flow-metrics (253→150 lines, 41% reduction)

**Week 2: Medium Priority (3 skills)**
6. flow-blueprint (222→150 lines, 32% reduction)
7. flow-orchestrate (201→150 lines, 25% reduction)
8. flow-implement (optimize existing resources)

**Week 3: Low Priority (5 skills)**
9. flow-tasks (155→130 lines)
10. flow-checklist (108→90 lines)
11. flow-plan (103→90 lines)
12. flow-analyze (96→80 lines)
13. flow-clarify (52→50 lines, add resources)

---

### Phase 2: Hooks Enhancement

**Objective**: Security hardening and documentation

#### Tasks

**1. Security Audit** (All 8 hooks)

Checklist per hook:
- [ ] All variables quoted: `"$VAR"` not `$VAR`
- [ ] No hardcoded absolute paths
- [ ] Input validation present
- [ ] Path traversal protection (`..` checks)
- [ ] Error handling documented
- [ ] Exit codes correct (2 = block, 1 = error, 0 = success)

**2. Add JSDoc Documentation**

Template:
```javascript
/**
 * Hook: {name}
 * Event: {event}
 * Purpose: {description}
 *
 * Input: JSON via stdin
 * Output: JSON to stdout
 * Exit Codes: 0=success, 1=error, 2=block
 *
 * @example
 * echo '{"tool":"Bash","params":{}}' | node hook.js
 */
```

**3. Create hooks/README.md**

Content:
- Hook system overview
- Event types explained
- Security best practices
- Testing hooks
- Common patterns

**4. Extract Common Utilities**

Create `hooks/lib/utils.js`:
- Input validation helpers
- Path sanitization
- JSON parsing with fallbacks
- Error handling wrappers

---

### Phase 3: Agents Optimization

**Objective**: Reduce verbosity, improve activation

#### Per-Agent Uplift Pattern

**1. Extract reference.md** (~40% reduction)

Move to `agents/{name}/reference.md`:
- Configuration options
- Pattern libraries
- Integration points
- Performance optimization
- Metrics & telemetry
- Future enhancements

**2. Streamline agent.md**

Keep only:
- Core capabilities (5-8 bullet points)
- Essential workflow
- Output format
- Integration with skills

Remove:
- Detailed patterns
- Configuration details
- Examples
- Future plans

**3. Improve Activation**

Update descriptions:
```yaml
description: [Capability]. Use PROACTIVELY when: 1) [auto-trigger], 2) [context], 3) [mention]. Use EXPLICITLY for: 4) [manual case], 5) [specific task]. [Output type].
```

**4. Add examples.md**

Create `agents/{name}/examples.md`:
- 3-5 invocation examples
- Expected inputs
- Expected outputs
- Common patterns

#### Agent-Specific Plans

**flow-researcher (358→180 lines)**
- Extract: Research strategies, domain patterns, source lists
- Extract: Intelligence features, caching, trend analysis
- Keep: Core capabilities, research outputs, workflow

**flow-implementer (331→180 lines)**
- Extract: Execution strategies, patterns, error recovery details
- Extract: Performance optimization, metrics, configuration
- Keep: Core capabilities, parallel execution, progress tracking

**flow-analyzer (276→150 lines)**
- Extract: Pattern recognition details, analysis pipeline, metrics
- Extract: Configuration, performance optimization
- Keep: Core capabilities, execution modes, output formats

---

### Phase 4: Infrastructure (Optional)

**Objective**: Shared utilities and testing

#### Create Shared Infrastructure

**1. Validation Framework**

`scripts/validate-skill.sh`:
- YAML syntax validation
- Description format check
- Token count verification
- Activation pattern testing

**2. Testing Framework**

`scripts/test-activation.sh`:
- Test primary triggers
- Test alternative phrases
- Test negative cases
- Generate activation report

**3. Template Library**

`templates/skill/`:
- minimal-skill.md
- standard-skill.md
- comprehensive-skill.md
- EXAMPLES-template.md
- REFERENCE-template.md

**4. Documentation**

Update main README.md:
- New structure conventions
- Progressive disclosure benefits
- How to create/maintain skills
- Testing guidelines

---

## Success Metrics

### Token Efficiency

- ✅ All SKILL.md files <150 lines (currently: 5/13)
- ✅ Average reduction: 40-60% (currently: 0%)
- ✅ Total token savings: ~50,000 tokens

### Quality

- ✅ All skills have EXAMPLES.md (currently: 3/13)
- ✅ All skills have REFERENCE.md (currently: 2/13)
- ✅ All skills have validate.sh (currently: 0/13)
- ✅ All hooks pass security audit (currently: 0/8)
- ✅ All agents <200 lines (currently: 0/3)

### Discovery

- ✅ All descriptions use 5-trigger format (currently: ~50%)
- ✅ All descriptions <512 chars (currently: ~80%)
- ✅ Activation accuracy >95% (needs measurement)

### Maintainability

- ✅ JSDoc coverage: 100% of hooks
- ✅ Testing framework in place
- ✅ Shared utilities extracted
- ✅ Documentation complete

---

## Implementation Approach

### Incremental Strategy

**Process**: Uplift 2-3 skills at a time, validate, then continue

**Validation Steps** (Per Skill):
1. Extract content to EXAMPLES.md and REFERENCE.md
2. Optimize core SKILL.md
3. Test activation with common phrases
4. Measure token reduction
5. Verify functionality unchanged
6. Update related documentation

### Testing Protocol

**Before Uplift**:
- Document current token count
- Test activation patterns
- Record example interactions

**After Uplift**:
- Verify token reduction
- Re-test activation patterns
- Confirm functionality preserved
- Update metrics

### Risk Mitigation

**Backup**: Git branch for each phase
**Rollback**: Can revert per-skill if issues
**Testing**: Comprehensive activation testing
**Documentation**: Track all changes

---

## Timeline Estimate

| Phase | Tasks | Estimated Time | Dependencies |
|-------|-------|----------------|--------------|
| Phase 1 (Week 1) | 5 high-priority skills | 10-12 hours | None |
| Phase 1 (Week 2) | 3 medium-priority skills | 6-8 hours | Week 1 |
| Phase 1 (Week 3) | 5 low-priority skills | 6-8 hours | Week 2 |
| Phase 2 | All 8 hooks | 8-10 hours | Phase 1 complete |
| Phase 3 | All 3 agents | 6-8 hours | Phase 1 complete |
| Phase 4 | Infrastructure | 4-6 hours | All phases |

**Total Estimated Time**: 40-52 hours

---

## Appendix

### Best Practices from Meta-Skills

#### From skill-builder:

**Discovery Formula**: `[CAPABILITY] + [5 TRIGGERS] + [OUTPUT]`

**Progressive Disclosure**:
```
Level 1: Metadata (100 tokens) - Always loaded
Level 2: Core (1.5k tokens) - Loaded on activation
Level 3: Resources (unlimited) - Loaded when referenced
```

**Token Target**: Core SKILL.md <1.5k tokens (~150-200 lines)

#### From hooks:

**Security Checklist**:
- Quote all variables
- Validate input data
- Use relative paths
- Check for path traversal
- Document exit codes

**Event Types**:
- PreToolUse (can block with exit 2)
- PostToolUse (after success)
- UserPromptSubmit (on input)
- SessionStart/End
- SubagentStop

#### From subagents:

**Agent Design**:
- Single focused responsibility
- Clear system prompt
- Minimal tool permissions
- Proactive activation triggers

**Description Pattern**:
```
[Capability]. Use PROACTIVELY when: [conditions].
Use EXPLICITLY for: [manual cases]. [Output].
```

---

## Next Steps

1. ✅ Create this plan.md
2. ⏳ Start Phase 1, Week 1 (flow-init)
3. ⏳ Measure baseline metrics
4. ⏳ Implement uplift pattern
5. ⏳ Validate and iterate

---

**Last Updated**: 2025-10-24
**Version**: 1.0
**Status**: Ready for execution
