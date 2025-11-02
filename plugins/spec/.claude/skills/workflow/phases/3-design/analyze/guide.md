---
name: spec:analyze
description: Use when validating consistency across spec/plan/tasks artifacts, checking for gaps or conflicts, ensuring requirements coverage, analyzing feature completeness before implementation, detecting orphaned tasks or missing stories, verifying priority alignment. Performs comprehensive read-only validation and generates categorized issue reports.
allowed-tools: Read, Grep, Bash
---

# Spec Analyze

Validate consistency across specification, plan, and tasks to catch issues before implementation.

## What This Skill Does

- Reads spec.md, plan.md, tasks.md for current feature
- Validates requirement coverage (all stories have tasks)
- Detects gaps (orphaned tasks, unaddressed stories)
- Checks priority alignment (P1 stories have P1 tasks)
- Verifies acceptance criteria coverage
- Analyzes cross-document consistency
- Generates categorized issue report with severity levels
- Uses analyze phaser subagent for deep analysis

## When to Use

Use analyze phase when:
1. Before implementation to catch issues early
2. After spec/plan updates to verify alignment
3. Team handoffs requiring validation
4. Detecting missing requirements or tasks
5. Multi-person teams need consistency checks
6. Requirements changed mid-development
7. Preparing for code review

## Execution Flow

### Phase 1: Load Artifacts

**Load feature documents**:
```bash
# Read current feature from session
Read {config.paths.state}/current-session.md

# Extract feature ID/name
# Load feature artifacts
Read {config.paths.features}/{feature-id}/{config.naming.files.spec}
Read {config.paths.features}/{feature-id}/{config.naming.files.plan}
Read {config.paths.features}/{feature-id}/{config.naming.files.tasks}

# Optional: Load blueprint if exists
Read {config.paths.spec_root}/architecture-blueprint.md
```

### Phase 2: Invoke Analyzer

**Delegate to analyze phaser subagent**:
```markdown
Task analyze phaser with:
- Input: spec.md, plan.md, tasks.md content
- Analysis types: coverage, consistency, priorities, acceptance
- Output: Structured findings with severity
```

**Analyzer performs**:
- Forward coverage (requirements → tasks)
- Backward coverage (tasks → requirements)
- Priority alignment validation
- Acceptance criteria mapping
- Terminology consistency checks
- Blueprint compliance (if present)

### Phase 3: Generate Report

**Consolidate findings**:
```markdown
1. Categorize issues:
   - CRITICAL: Blocks implementation
   - HIGH: Major gaps/conflicts
   - MEDIUM: Quality concerns
   - LOW: Style/minor issues

2. Calculate metrics:
   - Coverage percentages
   - Orphaned items count
   - Priority mismatches

3. Format report (see Output Format)

4. Save to: {config.paths.state}/analysis-report-{timestamp}.md
```

### Phase 4: Provide Recommendations

**Based on findings**:
- CRITICAL issues → MUST fix before proceeding
- HIGH issues → SHOULD fix before implementation
- MEDIUM issues → Consider fixing
- LOW issues → Optional improvements

**Suggest next steps**:
```markdown
If CRITICAL or HIGH issues:
- "Fix gaps with: update phase or tasks phase --update"
- "Resolve conflicts manually, then re-run analyze phase"

If all clear:
- "Validation passed - proceed with: implement phase"
```

## Validation Types

### 1. Coverage Analysis

**Forward coverage** (requirements → tasks):
- Identify user stories without tasks
- Flag acceptance criteria not addressed
- Check non-functional requirements coverage

**Backward coverage** (tasks → requirements):
- Find tasks not mapped to any story
- Detect orphaned implementation work
- Identify scope creep

### 2. Priority Alignment

**Check consistency**:
- P1 stories must have P1 tasks
- P1 stories cannot have only P2/P3 tasks
- Task priorities match story importance

### 3. Acceptance Criteria

**Map criteria to tasks**:
- Each acceptance criterion addressed by ≥1 task
- Tasks specify which criteria they satisfy
- No criteria left unimplemented

### 4. Blueprint Compliance

**If blueprint exists**:
- Check MUST principles followed
- Verify quality gates addressed
- Ensure architectural constraints met
- Flag violations as CRITICAL

### 5. Consistency Checks

**Cross-document validation**:
- Terminology consistent (User vs Account vs Member)
- Component names match between plan/tasks
- Dependencies properly ordered
- No conflicting requirements

## Error Handling

**Missing files**:
```
If spec.md not found:
- Report: "Feature not specified - run generate phase first"
- Exit with error

If plan.md missing:
- Report: "Feature not planned - run plan phase first"
- Exit with error

If tasks.md missing:
- Report: "Tasks not created - run tasks phase first"
- Exit with error
```

**Analysis failures**:
```
If analyze phaser unavailable:
- Fall back to basic checks:
  - Count user stories vs tasks
  - Check priority distribution
  - Simple terminology scan
- Note: "Full analysis unavailable"
```

**Validation errors**:
```
If documents unparseable:
- Report which file has format issues
- Suggest: "Validate YAML frontmatter"
- Provide example of correct format
```

## Output Format

**Analysis report structure**:

```markdown
# Analysis Report: {Feature Name}

**Date**: {timestamp}
**Feature**: {feature-id}
**Status**: ⚠️ Issues Found | ✅ Validation Passed

## Summary

- **CRITICAL**: {count} issues (blocks implementation)
- **HIGH**: {count} issues (major gaps)
- **MEDIUM**: {count} issues (quality concerns)
- **LOW**: {count} issues (minor)

**Recommendation**: {fix critical/proceed/review}

## Issues by Severity

### CRITICAL Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| C1 | Blueprint | TDD required, no test tasks | tasks.md | Add test tasks for each component |
| C2 | Coverage | US1.2 has 0 tasks | spec.md:L45 | Create implementation tasks |

### HIGH Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| H1 | Coverage | Password reset: no tasks | spec.md:L67 | Add reset flow tasks |
| H2 | Priority | P1 story has only P3 tasks | US1.4 | Increase task priorities |

### MEDIUM Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| M1 | Consistency | "User" vs "Account" terminology | Multiple | Standardize to "User" |
| M2 | Acceptance | AC1.3 not addressed | spec.md:L52 | Add validation task |

### LOW Issues

| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| L1 | Style | Inconsistent task numbering | tasks.md | Renumber tasks |

## Metrics

### Coverage
- User Stories: {total} ({with_tasks} with tasks = {percent}%)
- Tasks: {total} ({mapped} mapped to stories = {percent}%)
- Acceptance Criteria: {total} ({addressed} addressed = {percent}%)

### Priority Distribution
- P1 Stories: {count} → P1 Tasks: {count} ({aligned}% aligned)
- P2 Stories: {count} → P2 Tasks: {count} ({aligned}% aligned)
- P3 Stories: {count} → P3 Tasks: {count} ({aligned}% aligned)

### Blueprint Compliance
- MUST Principles: {total} ({compliant} compliant = {percent}%)
- SHOULD Principles: {total} ({compliant} compliant = {percent}%)
- Quality Gates: {total} ({addressed} addressed = {percent}%)

### Consistency
- Terminology Variations: {count} detected
- Orphaned Tasks: {count}
- Unmapped Stories: {count}

## Detailed Findings

{Category-specific details from analyze phaser}

## Recommendations

### Immediate Actions (CRITICAL)
1. {specific fix for C1}
2. {specific fix for C2}

### Important Improvements (HIGH)
1. {specific fix for H1}
2. {specific fix for H2}

### Optional Enhancements (MEDIUM/LOW)
1. {specific fix for M1}
2. {specific fix for L1}

## Next Steps

{context-aware guidance}
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- All-green validation (no issues)
- Coverage gaps detected
- Priority misalignment
- Blueprint violations
- Terminology inconsistencies
- Complex multi-issue scenario

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete validation algorithms
- Coverage calculation formulas
- Priority alignment rules
- Blueprint compliance checking
- Terminology detection patterns
- Report generation logic
- Configuration options
- Subagent integration protocol

## Shared Resources

- `shared/workflow-patterns.md` - Validation patterns
- `shared/state-management.md` - State file access

## Related Skills

- **analyze phaser** (subagent) - Performs deep analysis
- **tasks phase** - Generate/update tasks to fix gaps
- **update phase** - Update spec to resolve conflicts
- **implement phase** - Execute after validation passes
