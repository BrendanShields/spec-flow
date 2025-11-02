---
name: spec:clarify
description: Use when resolving ambiguities in specifications - detects [CLARIFY] tags, unclear requirements, vague terms like "fast/scalable/secure", multiple valid approaches needing user preference, numerical values undefined (timeouts/limits/thresholds). Asks targeted questions with recommended options, updates spec.md with clarified requirements.
allowed-tools: Read, Edit, AskUserQuestion
---

# Spec Clarify

Resolve underspecified areas in specifications through intelligent Q&A with best practice recommendations.

## What This Skill Does

- Detects ambiguities in spec.md ([CLARIFY] tags, vague terms, missing details)
- Prioritizes clarifications by impact (blocking → nice-to-have)
- Asks focused questions (max 4 per session) with recommended options
- Updates spec.md with clarified requirements
- Logs decisions to DECISIONS-LOG.md

## When to Use

1. After spec:generate when [CLARIFY] tags present
2. Specification contains vague terms ("fast", "scalable", "user-friendly")
3. Multiple valid approaches need user preference
4. Numerical values undefined (timeouts, limits, thresholds)
5. Implementation choices unclear (library, pattern, architecture)

## Execution Flow

### Phase 1: Detect Ambiguities

**Read specification**:
```
1. Load {config.paths.features}/###-name/{config.naming.files.spec}
2. Scan for explicit markers:
   - [CLARIFY: text]
   - [CLARIFY]
   - [TBD]
   - [TODO]
3. Detect vague terms:
   - Performance: "fast", "quick", "responsive"
   - Scale: "scalable", "high-volume"
   - Quality: "robust", "reliable", "user-friendly"
4. Identify missing specifications:
   - Error handling approach
   - Validation rules
   - Edge case behavior
```

**Extract ambiguities**:
```
For each ambiguity found:
- Category (numerical, choice, scope, priority)
- Context (surrounding requirement text)
- Impact (P0: blocks planning, P1: blocks implementation, P2: polish)
```

### Phase 2: Prioritize Questions

**Sort by impact**:
```
P0 (Blockers):
- Architecture decisions (REST vs GraphQL, SQL vs NoSQL)
- Authentication method (JWT, session, OAuth)
- Core data model choices

P1 (Implementation):
- Performance thresholds (response time < ?ms)
- Error handling strategy (retry count, timeout values)
- Validation rules (password complexity, file size limits)

P2 (Polish):
- UI details (button text, error messages)
- Logging levels
- Edge case behavior
```

**Select top 4**:
```
- Choose highest priority first
- Group related questions
- Limit to 4 questions per session (avoid overwhelm)
```

### Phase 3: Ask Questions

**Question format**:
```
For each selected ambiguity:

1. State context from spec
2. Provide recommended option
3. Explain rationale
4. List alternatives with tradeoffs
5. Use AskUserQuestion tool for answer
```

**Example structure**:
```markdown
Context: Spec mentions "fast response times"

Recommended: < 200ms p95 latency
Rationale: Industry standard for perceived instant response

Alternatives:
A. < 100ms p95 - Perceived instant (requires caching/optimization)
B. < 200ms p95 - Fast (balanced performance/cost)
C. < 500ms p95 - Acceptable (simpler implementation)
```

For workflow patterns, see: shared/workflow-patterns.md

### Phase 4: Update Specification

**For each clarification**:
```
1. Locate ambiguous section in spec.md
2. Replace [CLARIFY: X] with clarified text
3. OR add quantified requirement where vague term was
4. Preserve surrounding context and formatting
```

**Example update**:
```markdown
Before:
Response times should be [CLARIFY: fast enough for users]

After:
Response times must be < 200ms (p95 latency) for API requests
```

**Log decision**:
```
Add entry to {config.paths.memory}/DECISIONS-LOG.md:

## CLR-001: API Response Time Target

Date: 2025-10-31
Context: Feature 002 - API specification
Decision: < 200ms p95 latency requirement
Rationale: Balance between user experience and implementation cost
```

For state management details, see: shared/state-management.md

### Phase 5: Validate & Report

**Check completeness**:
```
1. Scan updated spec.md for remaining [CLARIFY] tags
2. Count resolved vs remaining ambiguities
3. Determine if another clarify session needed
```

**Report results**:
```
Clarifications completed: 4/7
- CLR-001: API response time (< 200ms p95)
- CLR-002: Database choice (PostgreSQL)
- CLR-003: Error retry count (3 retries)
- CLR-004: File upload limit (10MB)

Remaining ambiguities: 3 [CLARIFY] tags
Run /spec-clarify again to resolve remaining items
```

## Error Handling

**No ambiguities found**:
```
- Message: "Specification appears complete, no [CLARIFY] tags found"
- Offer to validate specification anyway
- Exit gracefully
```

**User skips question**:
```
- Record as "Deferred" in DECISIONS-LOG.md
- Keep [CLARIFY] tag in spec.md
- Continue to next question
```

**Invalid answer format**:
```
- Re-ask question with clarification
- Provide examples of valid answers
- Maximum 2 retry attempts
```

## Output Format

**Session summary**:
```
Spec Clarification Complete

Feature: ###-feature-name
Session: 2025-10-31 15:45

Resolved:
✓ Response time requirement (< 200ms p95)
✓ Database selection (PostgreSQL)
✓ Error retry strategy (3 attempts, exponential backoff)
✓ File size limit (10MB)

Updated Files:
- {config.paths.features}/###-name/{config.naming.files.spec} (4 clarifications)
- {config.paths.memory}/DECISIONS-LOG.md (4 new entries)

Remaining: 3 [CLARIFY] tags
Next: Run /spec-clarify again OR proceed to /spec-plan
```

## Examples

See [examples.md](./examples.md) for detailed scenarios

## Reference

See [reference.md](./reference.md) for technical specifications

## Related Skills

- **spec:generate** - Creates initial specification (run before)
- **spec:plan** - Generates technical plan (run after)
- **spec:analyze** - Validates specification completeness
