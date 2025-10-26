---
name: flow:checklist
description: Generate quality checklists for requirement validation. Use when 1) Need UX/security/API/performance gates, 2) Enterprise compliance requirements, 3) Before spec approval/signoff, 4) Testing if requirements are well-written, 5) Validating requirement completeness and clarity. Creates domain-specific checklists that validate requirement quality.
allowed-tools: Read, Write, Edit
---

# Flow Checklist

Generate quality checklists that test whether requirements are well-written - "Unit Tests for Requirements".

## Core Philosophy

Checklists validate **REQUIREMENT QUALITY**, not implementation correctness.

✅ **Correct**: "Are error handling requirements defined for all API failure modes?"
❌ **Wrong**: "Verify the API returns 200 status"

**Why**: Checklists run BEFORE implementation to ensure specs are complete, clear, and testable.

## Core Capability

Generates domain-specific checklists validating:
- **Completeness**: All necessary requirements present?
- **Clarity**: Specific and unambiguous (no "fast", "scalable")?
- **Consistency**: Aligned patterns and terminology?
- **Measurability**: Objectively verifiable?
- **Coverage**: All scenarios and edge cases addressed?
- **Gaps**: Missing requirements that should exist?

Creates numbered checklist files (`checklists/[domain].md`) with CHK### IDs.

## Quality Dimensions

| Dimension | Tests | Example |
|-----------|-------|---------|
| **Completeness** | Required items present | "Are request schemas defined for all POST endpoints?" |
| **Clarity** | Specific, not vague | "Is 'fast' quantified with timing thresholds (<500ms)?" |
| **Consistency** | Uniform patterns | "Are error formats consistent across endpoints?" |
| **Measurability** | Objectively testable | "Can 'user-friendly' be measured with usability criteria?" |
| **Coverage** | Edge cases addressed | "Are timeout scenarios specified?" |
| **Gap** | Missing requirement | "Are logging requirements defined? [Gap]" |

## Checklist Types

| Type | Focus | Item Count |
|------|-------|------------|
| **ux.md** | Visual design, interactions, accessibility, responsive | 10-15 |
| **api.md** | Endpoints, formats, errors, auth, pagination | 10-15 |
| **security.md** | Auth, encryption, PII, audit, compliance | 10-20 |
| **performance.md** | Response times, throughput, scalability | 8-12 |

## Item Format

```markdown
- [ ] CHK### - [Question about requirement quality]? [Quality Dimension, Spec §X.Y]
```

**Example**:
```markdown
- [ ] CHK001 - Are API error response formats specified for all failure modes? [Completeness, Spec §API-3]
- [ ] CHK002 - Is "fast loading" quantified with specific timing thresholds? [Clarity, Spec §NFR-2]
- [ ] CHK003 - Are hover states consistently defined for all buttons? [Consistency]
```

## Usage

```bash
# Auto-detect domains from spec
flow:checklist

# Specific domains
flow:checklist --type security,api

# With focus
flow:checklist "Focus on API error handling and authentication"
```

## Workflow

1. **Generate**: `flow:checklist` creates `checklists/[domain].md`
2. **Review**: Check each item against spec
3. **Improve**: Update spec to address `[ ]` items
4. **Complete**: All items `[X]` before `flow:plan`

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- UX checklist for e-commerce page
- API checklist for REST endpoints
- Security checklist for HIPAA compliance
- Performance checklist for real-time app
- Multi-domain checklist generation

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete quality dimension definitions
- Checklist type details and patterns
- Item format specification
- Generation algorithm
- Configuration options (depth, focus)
- Validation rules
- Common patterns by domain
- Usage workflow details

## Related Skills

- **flow:specify**: Create specification (run before)
- **flow:plan**: Technical planning (run after checklist complete)

## Validation

Test this skill:
```bash
scripts/validate.sh
```
