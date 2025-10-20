---
name: flow:checklist
description: Generate domain-specific quality checklists that act as "unit tests for requirements". Validates requirement quality, not implementation. Creates checklists for UX, security, API, performance, etc.
---

# Flow Checklist: Requirements Quality Validation

Generate checklists that test whether requirements are well-written, not whether code works.

## Core Concept: "Unit Tests for English"

Checklists validate REQUIREMENTS quality:

✅ **CORRECT**: "Are error handling requirements defined for all API failure modes?"
❌ **WRONG**: "Verify the API returns 200 status"

## When to Use

- After specification is complete
- Before implementation starts
- For enterprise/compliance projects
- When multiple stakeholders need validation

## What This Skill Does

1. **Analyzes** specification and domain
2. **Generates** checklist testing requirements quality:
   - **Completeness**: Are all necessary requirements present?
   - **Clarity**: Are requirements specific and unambiguous?
   - **Consistency**: Do requirements align without conflicts?
   - **Measurability**: Can requirements be objectively verified?
   - **Coverage**: Are all scenarios/edge cases addressed?
3. **Creates** checklist file in `checklists/[domain].md`
4. **Numbers** items sequentially (CHK001, CHK002...)

## Checklist Types

| Type | Focus | Example Items |
|------|-------|---------------|
| **ux.md** | UI/UX requirements | "Are visual hierarchy requirements measurable?" |
| **api.md** | API requirements | "Are error response formats specified for all failures?" |
| **security.md** | Security requirements | "Are authentication requirements defined for all protected resources?" |
| **performance.md** | Performance requirements | "Are performance targets quantified with specific metrics?" |

## Item Format

```markdown
- [ ] CHK001 - Are [requirement type] defined for [scenario]? [Quality Dimension, Spec §X.Y]
```

Quality dimensions:
- `[Completeness]` - Missing requirements
- `[Clarity]` - Vague or ambiguous
- `[Consistency]` - Conflicting requirements
- `[Measurability]` - Can't be tested
- `[Coverage]` - Missing scenarios
- `[Gap]` - Requirement doesn't exist

## Examples

**Good Checklist Items** (Testing requirements):
```markdown
- [ ] CHK001 - Are the number and layout of featured items explicitly specified? [Completeness, Spec §FR-1]
- [ ] CHK002 - Is "fast loading" quantified with specific timing thresholds? [Clarity, Spec §NFR-2]
- [ ] CHK003 - Are hover state requirements consistently defined for all interactive elements? [Consistency]
- [ ] CHK004 - Are accessibility requirements specified for keyboard navigation? [Coverage, Gap]
```

**Bad Items** (Testing implementation):
```markdown
❌ - [ ] Verify the button clicks correctly
❌ - [ ] Test API returns 200
❌ - [ ] Confirm page loads fast
```

## Configuration

Interactive clarification asks:
1. **Domain focus** (security, UX, API, performance, etc.)
2. **Depth level** (lightweight, standard, comprehensive)
3. **Specific concerns** (compliance, accessibility, etc.)

## Usage

```bash
# General checklist
flow:checklist

# Specific domain
flow:checklist --type security,compliance

# With focus
flow:checklist "Focus on API error handling and rate limiting"
```

## When to Skip

- POC/spike projects
- Internal tools
- Well-understood domains
- Solo developer with clear requirements

## Related Skills

- **flow:specify**: Create specification (run before)
- **flow:implement**: Execute implementation (validates against checklist)
