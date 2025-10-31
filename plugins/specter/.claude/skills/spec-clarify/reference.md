# Spec Clarify - Technical Reference

Complete technical specifications for the clarification workflow.

## [CLARIFY] Tag Format

### Supported Formats

**Explicit markers**:
```markdown
[CLARIFY: specific question or ambiguity]
[CLARIFY]
[TBD: decision needed]
[TODO: clarification required]
```

**Examples**:
```markdown
Response times should be [CLARIFY: fast enough for users]
Authentication method: [CLARIFY]
File size limit: [TBD: discuss with product team]
Error retry count: [TODO: determine based on testing]
```

### Detection Patterns

**Regular expressions**:
```regex
# Explicit tags
\[CLARIFY(?::\s*([^\]]+))?\]
\[TBD(?::\s*([^\]]+))?\]
\[TODO(?::\s*([^\]]+))?\]

# Vague performance terms
\b(fast|quick|slow|performant|responsive|efficient)\b

# Vague scale terms
\b(scalable|high-volume|many|large|small)\b

# Vague quality terms
\b(robust|reliable|secure|user-friendly|intuitive|easy)\b
```

**Context extraction**:
```
For each match:
1. Capture 2 sentences before
2. Capture tagged sentence
3. Capture 2 sentences after
4. Identify section heading
```

---

## Ambiguity Classification

### Category Types

**1. Numerical Ambiguities**

**Indicators**:
- Vague quantifiers: "fast", "large", "many", "few"
- Missing units: "timeout", "limit", "threshold"
- Relative terms: "better than", "faster than"

**Resolution approach**:
- Provide specific numbers with units
- Include percentile metrics (p50, p95, p99)
- Reference industry standards

**Examples**:
```
"fast response" → "< 200ms p95 latency"
"large files" → "up to 10MB"
"many concurrent users" → "10,000 concurrent connections"
```

**2. Choice Ambiguities**

**Indicators**:
- Multiple valid approaches: "authenticate", "store", "process"
- Technology selection: "database", "cache", "message queue"
- Pattern selection: "sync vs async", "REST vs GraphQL"

**Resolution approach**:
- List 2-4 concrete alternatives
- Provide recommendation with rationale
- Include tradeoff analysis

**Examples**:
```
"authenticate users" → Choose: JWT, Session cookies, OAuth2
"database" → Choose: PostgreSQL, MySQL, MongoDB
"API design" → Choose: REST, GraphQL, gRPC
```

**3. Scope Ambiguities**

**Indicators**:
- Action verbs without detail: "delete", "update", "filter", "sort"
- Boundary conditions: "valid", "allowed", "supported"
- Inclusion/exclusion: "handle errors", "support formats"

**Resolution approach**:
- Define exact behavior
- Specify edge cases
- List what's included and excluded

**Examples**:
```
"delete account" → Soft delete with 30-day recovery OR hard delete immediate
"sort results" → By: relevance (default), date, price, alphabetical
"valid email" → RFC 5322 format + domain MX check + no disposables
```

**4. Priority Ambiguities**

**Indicators**:
- "Should have", "could have", "nice to have"
- No explicit priority marking
- Multiple features without ranking

**Resolution approach**:
- Apply MoSCoW method: Must/Should/Could/Won't
- Map to P1/P2/P3 system
- Clarify timeline implications

**Examples**:
```
"nice to have" → P3 (defer to v2.0)
"important feature" → P1 (required for v1.0)
"if time allows" → P2 (include if schedule permits)
```

---

## Question Prioritization Algorithm

### Impact Scoring

**P0 - Architecture Blockers** (must resolve before planning):
```
- Core technology choices (database, framework, architecture style)
- Authentication/authorization approach
- Data model fundamentals
- API contract design (REST vs GraphQL)
- Third-party service dependencies
```

**P1 - Implementation Blockers** (must resolve before coding):
```
- Performance requirements (latency, throughput)
- Error handling strategy
- Validation rules
- Retry/timeout values
- File size limits
- Rate limiting thresholds
```

**P2 - Polish Items** (resolve during/after implementation):
```
- UI copy and messaging
- Logging levels and detail
- Edge case behavior
- Error message formatting
- Optional feature details
```

**P3 - Nice-to-haves** (can defer):
```
- Future enhancement ideas
- Alternative workflow options
- Optimization targets beyond MVP
- Documentation details
```

### Selection Algorithm

```python
def select_questions(ambiguities, max_questions=4):
    # 1. Score each ambiguity
    scored = []
    for amb in ambiguities:
        score = calculate_impact_score(amb)
        scored.append((amb, score))

    # 2. Sort by score (highest first)
    scored.sort(key=lambda x: x[1], reverse=True)

    # 3. Group related questions
    grouped = group_related(scored)

    # 4. Select top groups up to max_questions
    selected = []
    for group in grouped:
        if len(selected) + len(group) <= max_questions:
            selected.extend(group)
        else:
            break

    # 5. Ensure at least P0 questions included
    if not any(q.priority == 'P0' for q in selected):
        p0_questions = [q for q in scored if q.priority == 'P0']
        if p0_questions:
            # Replace lowest priority question with P0
            selected[-1] = p0_questions[0]

    return selected[:max_questions]
```

---

## AskUserQuestion Integration

### Question Structure

**Format for single-choice questions**:
```javascript
{
  question: "What should the [specific aspect] be?",
  header: "Short label (max 12 chars)",
  multiSelect: false,
  options: [
    {
      label: "Option A",
      description: "What this means, pros/cons, when to use"
    },
    {
      label: "Option B (Recommended)",
      description: "Why recommended, tradeoffs"
    },
    {
      label: "Option C",
      description: "Alternative approach, considerations"
    }
  ]
}
```

**Example**:
```javascript
{
  question: "What should the API response time target be?",
  header: "Latency",
  multiSelect: false,
  options: [
    {
      label: "< 100ms p95",
      description: "Perceived instant. Requires CDN, aggressive caching, complex optimization. Best for high-traffic consumer apps."
    },
    {
      label: "< 200ms p95 (Recommended)",
      description: "Industry standard for good UX. Achievable with basic caching and indexing. Balanced cost/performance."
    },
    {
      label: "< 500ms p95",
      description: "Acceptable but noticeable delay. Simpler implementation, lower infrastructure cost. OK for admin tools."
    }
  ]
}
```

### Multi-Select Questions

**When to use**:
- User can choose multiple valid options
- Features are not mutually exclusive
- Asking about included capabilities

**Example**:
```javascript
{
  question: "Which authentication providers should be supported?",
  header: "Auth Methods",
  multiSelect: true,
  options: [
    {
      label: "Email/Password",
      description: "Traditional auth, full control, always recommended"
    },
    {
      label: "Google OAuth",
      description: "Social login, easy signup, requires Google setup"
    },
    {
      label: "GitHub OAuth",
      description: "Developer-focused apps, easy for tech users"
    },
    {
      label: "SAML SSO",
      description: "Enterprise requirement, complex setup"
    }
  ]
}
```

---

## Recommendation Engine

### Best Practice Database

**Performance targets** (web applications):
```yaml
api_latency:
  recommended: "< 200ms p95"
  rationale: "Industry standard, good UX"
  alternatives:
    - value: "< 100ms p95"
      use_case: "Real-time apps, high-traffic consumer"
    - value: "< 500ms p95"
      use_case: "Admin tools, internal systems"

database_query:
  recommended: "< 50ms p95"
  rationale: "Allows API under 200ms with overhead"

file_upload:
  recommended: "10MB"
  rationale: "Handles documents/images, prevents abuse"
```

**Authentication**:
```yaml
method:
  recommended: "JWT with refresh token rotation"
  rationale: "Stateless, scalable, secure, mobile-friendly"
  alternatives:
    - value: "Session cookies"
      use_case: "Simple apps, server-side rendering"
    - value: "OAuth2 only"
      use_case: "Delegated auth, no user database"

token_lifetime:
  recommended: "15min access, 7 day refresh"
  rationale: "Security best practice per OWASP"
```

**Error Handling**:
```yaml
retry_strategy:
  recommended: "3 retries, exponential backoff"
  rationale: "Handles transient failures, prevents thundering herd"

timeout:
  recommended: "30s for API calls, 5s for DB queries"
  rationale: "Reasonable limits, prevents hung requests"
```

### Recommendation Selection Logic

```python
def get_recommendation(ambiguity):
    category = classify_ambiguity(ambiguity)
    context = extract_context(ambiguity)

    # Match against best practice database
    if category == 'performance':
        return get_performance_recommendation(context)
    elif category == 'authentication':
        return get_auth_recommendation(context)
    elif category == 'error_handling':
        return get_error_recommendation(context)
    # ... etc

    # No match - provide generic guidance
    return get_generic_recommendation(category)

def format_recommendation(rec):
    return {
        'recommended_value': rec.value,
        'rationale': rec.reasoning,
        'alternatives': rec.alternatives,
        'references': rec.standards  # OWASP, NIST, RFC, etc.
    }
```

---

## Update Strategy

### Spec.md Modification

**Locate ambiguity**:
```python
def find_ambiguity_location(spec_content, ambiguity):
    # Find exact line number
    lines = spec_content.split('\n')
    for i, line in enumerate(lines):
        if ambiguity.marker in line:
            return {
                'line_number': i,
                'context_start': max(0, i - 2),
                'context_end': min(len(lines), i + 3)
            }
```

**Replace with clarification**:
```python
def update_spec(spec_content, ambiguity, clarification):
    # Replace [CLARIFY: X] with clarified text
    old_text = f"[CLARIFY: {ambiguity.text}]"
    new_text = clarification.resolved_text

    updated = spec_content.replace(old_text, new_text)

    # If just [CLARIFY] without details, replace whole sentence
    if old_text == "[CLARIFY]":
        updated = replace_sentence(spec_content, ambiguity.line, new_text)

    return updated
```

**Example transformations**:
```markdown
# Before
Response times should be [CLARIFY: fast enough for users]

# After
Response times must be < 200ms (p95 latency) under normal load
```

```markdown
# Before
Authentication: [CLARIFY]

# After
Authentication: JWT tokens with refresh token rotation
- Access token: 15 minute lifetime
- Refresh token: 7 day lifetime with automatic rotation
```

### Decision Log Format

**Template**:
```markdown
## CLR-{number}: {Decision Title}

**Date**: {YYYY-MM-DD}
**Status**: Accepted | Deferred | Superseded
**Context**: Feature {###} - {Context description}
**Deciders**: {Who made decision}

### Decision
{Clear statement of what was decided}

### Rationale
{Why this decision was made}
{Reference to best practices/standards}

### Consequences
**Positive**:
- {Benefit 1}
- {Benefit 2}

**Negative**:
- {Tradeoff 1}
- {Tradeoff 2}

**Alternatives Considered**:
- {Alternative 1} (rejected - {reason})
- {Alternative 2} (rejected - {reason})

---
```

**Numbering**:
- Sequential: CLR-001, CLR-002, etc.
- Prefix identifies clarification decisions vs architecture decisions (ADR-xxx)

---

## Validation Checks

### Pre-Clarification Validation

**Check for**:
```
1. spec.md exists and is readable
2. Spec has required sections (User Stories, Acceptance Criteria)
3. At least one ambiguity detected
4. .specter-memory/DECISIONS-LOG.md exists
```

### Post-Clarification Validation

**Verify**:
```
1. All selected ambiguities resolved in spec.md
2. No [CLARIFY] tags remain for resolved items
3. Decision log entries created for each resolution
4. Spec.md still valid markdown format
5. No broken links or references
```

### Completeness Check

```python
def check_completeness(spec_content):
    remaining = find_all_ambiguities(spec_content)

    if len(remaining) == 0:
        return {
            'complete': True,
            'message': 'No ambiguities remaining'
        }
    else:
        p0_remaining = [a for a in remaining if a.priority == 'P0']
        if p0_remaining:
            return {
                'complete': False,
                'blocking': True,
                'message': f'{len(p0_remaining)} P0 ambiguities block planning'
            }
        else:
            return {
                'complete': False,
                'blocking': False,
                'message': f'{len(remaining)} P1/P2 ambiguities can be resolved during implementation'
            }
```

---

## Configuration Options

### Environment Variables

```bash
# Maximum questions per session
SPEC_CLARIFY_MAX_QUESTIONS=4

# Auto-accept recommendations without asking
SPEC_CLARIFY_AUTO_ACCEPT=false

# Clarification depth
SPEC_CLARIFY_DEPTH=normal  # shallow | normal | deep

# Skip P3 questions
SPEC_CLARIFY_SKIP_P3=true
```

### Per-Project Configuration

**In .specter/config.yml**:
```yaml
clarify:
  max_questions: 4
  auto_recommendations: false
  priorities:
    - P0  # Always ask
    - P1  # Always ask
    - P2  # Ask if < 4 questions
    - P3  # Skip unless explicitly requested

  question_format:
    include_rationale: true
    include_alternatives: true
    include_references: true
```

---

## Related Patterns

### Common Clarification Workflows

**Pattern: Quick Clarify** (2-3 P0 questions):
```
spec:generate → spec:clarify (P0 only) → spec:plan
```

**Pattern: Thorough Clarify** (multiple rounds):
```
spec:generate
  → spec:clarify (P0 round)
  → spec:clarify (P1 round)
  → spec:clarify (P2 round)
  → spec:plan
```

**Pattern: Iterative Refinement**:
```
spec:generate
  → spec:clarify
  → spec:plan
  → spec:analyze (finds gaps)
  → spec:clarify (resolve gaps)
  → spec:plan --update
```

### Integration with Other Skills

**spec:analyze**:
- Runs after clarify to validate completeness
- Can trigger additional clarify round if gaps found

**spec:plan**:
- Reads clarified spec.md
- References DECISIONS-LOG.md for context
- May add technical decisions (ADR) to supplement clarifications (CLR)

**spec:update**:
- Can trigger clarify if updates introduce new ambiguities
- Marks superseded clarifications in decision log

---

## Token Optimization Notes

**This reference file**: ~1,800 tokens

**Total skill tokens**:
- SKILL.md: ~1,150 tokens
- examples.md: ~1,900 tokens
- reference.md: ~1,800 tokens
- **Total**: ~4,850 tokens

**Progressive disclosure benefit**:
- Metadata always loaded: ~50 tokens
- Instructions loaded on trigger: ~1,150 tokens
- Examples/reference loaded on demand: ~3,700 tokens

**Compared to original** (spec:clarify):
- Original SKILL.md: ~650 tokens
- New SKILL.md: ~1,150 tokens (+77% detail, still under 1,200 target)
- Total documentation: More comprehensive with better examples
