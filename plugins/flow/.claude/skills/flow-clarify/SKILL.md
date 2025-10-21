---
name: flow:clarify
description: Resolve ambiguities in specifications through intelligent Q&A. Use when: 1) Spec has unclear requirements marked with [CLARIFY], 2) Need stakeholder input on technical choices, 3) Multiple valid approaches need user preference, 4) After flow:specify if ambiguities found. Updates spec.md with clarified requirements.
allowed-tools: Read, Edit, AskUserQuestion
---

# Flow Clarify: Interactive Specification Refinement

Identify and resolve underspecified areas in specifications through targeted clarification questions.

## When to Use

- After `flow:specify` generates a spec with [NEEDS CLARIFICATION] markers
- When requirements are ambiguous or have multiple valid interpretations
- Before moving to planning phase to ensure clarity

## What This Skill Does

1. **Scans** specification for ambiguities
2. **Prioritizes** clarifications by impact 
3. **Asks** maximum 5 questions with smart defaults
4. **Recommends** best practice answers
5. **Updates** spec incrementally
6. **Validates** completeness

## Question Format

Each question includes:
- **Recommended Answer** based on best practices
- **Options Table** with implications
- **User Response** option

## Example

```
Q1: Authentication Method

Recommended: OAuth2 with JWT (industry standard)

| Option | Method | Implications |
|--------|--------|--------------|
| A | OAuth2 + JWT | Scalable, stateless |
| B | Session-based | Simpler, sticky sessions |
| C | API keys | Service-to-service only |

Your choice: [Accept or provide alternative]
```

## Related Skills

- **flow:specify**: Create initial specification
- **flow:plan**: Generate technical plan (after clarify)
