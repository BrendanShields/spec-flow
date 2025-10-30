---
name: specter:clarify
description: Resolve ambiguities in specifications through intelligent Q&A. Use when 1) Spec has unclear requirements marked with [CLARIFY], 2) Need stakeholder input on technical choices, 3) Multiple valid approaches need user preference, 4) After specter:specify if ambiguities found, 5) Vague terms like "fast/scalable/secure" need quantification. Updates spec.md with clarified requirements.
allowed-tools: Read, Edit, AskUserQuestion
---

# Flow Clarify

Identify and resolve underspecified areas in specifications through targeted clarification questions with best practice recommendations.

## Core Capability

Transforms ambiguous specifications into clear, actionable requirements:
- Scans spec.md for ambiguity markers and vague terms
- Prioritizes clarifications by impact (blocking → low)
- Asks maximum 5 focused questions per session
- Provides best practice recommendations
- Updates spec.md incrementally with clarified content
- Validates completeness after clarifications

## Ambiguity Detection

Automatically detects:
- **Explicit markers**: `[NEEDS CLARIFICATION]`, `[TBD]`, `[TODO]`
- **Vague terms**: "fast", "scalable", "user-friendly", "robust"
- **Missing specs**: Error handling, edge cases, validation rules
- **Multiple interpretations**: Delete (soft/hard?), Sort (by what?)

## Question Format

Each question includes:

**Structure**:
```
Q[N]: [Topic]

Recommended: [Best practice answer]
Rationale: [Why this is recommended]

Options:
| Option | Approach | Pros | Cons | When to Use |
|--------|----------|------|------|-------------|
| A | ... | ... | ... | ... |
| B | ... | ... | ... | ... |

Your choice: _____
```

**Example**:
```
Q1: Authentication Method

Recommended: OAuth2 with JWT tokens
Rationale: Industry standard, scalable, stateless

Options:
| Option | Method | Pros | Cons |
|--------|--------|------|------|
| A | OAuth2 + JWT | Scalable, stateless | Complex |
| B | Session-based | Simple | Server state |
| C | API keys | Very simple | No user context |

Your choice: A
```

## Prioritization

Questions ordered by impact:

| Priority | Blocks | Examples |
|----------|--------|----------|
| P0 | Planning | Auth method, API design (REST/GraphQL) |
| P1 | Implementation | Error handling, performance thresholds |
| P2 | Polish | UI details, edge cases |
| P3 | Nice-to-have | Terminology, logging levels |

Asks P0/P1 first, maximum 5 questions per run.

## Update Strategy

After each answer:
1. Locate ambiguous section in spec.md
2. Replace marker with clarified content
3. Preserve surrounding context
4. Update spec version (patch increment)
5. Continue to next question

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- API authentication method clarification
- Performance requirements quantification
- Error handling strategy definition
- Data model field specifications
- File upload approach selection

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete ambiguity detection patterns
- Question prioritization algorithm
- Recommendation engine details
- Update strategy specifics
- Configuration options (`--max-questions`, `--depth`, `--auto-accept`)
- Common clarification patterns by domain

## Related Skills

- **specter:specify**: Create initial specification (run before)
- **specter:plan**: Generate technical plan (run after)
- **specter:analyze**: Validate completeness

## Validation

Test this skill:
```bash
scripts/validate.sh
```
