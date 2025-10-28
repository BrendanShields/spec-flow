# Flow Clarify Reference

## Ambiguity Detection

### Automatic Detection Patterns

The skill scans specifications for common ambiguity markers:

**Explicit Markers**:
- `[NEEDS CLARIFICATION]`
- `[TBD]`
- `[TODO]`
- `[CLARIFY]`

**Vague Terms**:
| Term | Why Ambiguous | Better Alternative |
|------|---------------|-------------------|
| "fast" | No measurement | "<500ms p95" |
| "scalable" | No threshold | "Handle 10k concurrent users" |
| "user-friendly" | Subjective | "3-click checkout flow" |
| "robust" | Vague quality | "99.9% uptime SLA" |
| "secure" | Undefined scope | "OWASP Top 10 compliant" |
| "soon" | No timeline | "Within 5 seconds" |
| "many" | No quantity | "Up to 100 items" |

**Missing Specifications**:
- Error handling not defined
- Edge cases not addressed
- Non-functional requirements incomplete
- Data validation rules absent
- Authorization rules undefined

**Multiple Valid Interpretations**:
- "Users can delete" (soft delete? hard delete? cascade?)
- "Products are sorted" (by what? ascending/descending?)
- "Images are optimized" (what dimensions? quality? format?)

## Question Prioritization

### Priority Levels

**P0 (Blocking)**: Must clarify before planning
- Authentication/authorization approach
- Core data model structure
- API design fundamentals (REST vs GraphQL)
- Required vs optional features

**P1 (High Impact)**: Clarify before implementation
- Error handling strategies
- Performance thresholds
- Data validation rules
- Third-party integrations

**P2 (Medium Impact)**: Clarify during implementation
- UI/UX details
- Edge case handling
- Optional feature behavior
- Nice-to-have enhancements

**P3 (Low Impact)**: Can defer or use defaults
- Terminology preferences
- Logging detail levels
- Admin interface details
- Internal documentation format

### Selection Algorithm

```javascript
function prioritizeClarifications(ambiguities) {
  const scored = ambiguities.map(amb => ({
    ...amb,
    score: calculatePriority(amb)
  }));

  return scored
    .sort((a, b) => b.score - a.score)
    .slice(0, 5); // Max 5 questions
}

function calculatePriority(ambiguity) {
  let score = 0;

  // Blocking ambiguities (affects architecture)
  if (ambiguity.blocks.includes('planning')) score += 100;
  if (ambiguity.blocks.includes('data-model')) score += 90;
  if (ambiguity.blocks.includes('api-design')) score += 85;

  // High impact (affects implementation)
  if (ambiguity.affects === 'all-features') score += 50;
  if (ambiguity.affects === 'multiple-features') score += 30;

  // User-facing (affects UX)
  if (ambiguity.userFacing) score += 20;

  // Has multiple valid interpretations
  if (ambiguity.interpretations > 1) score += 15;

  return score;
}
```

## Question Format

### Complete Question Structure

```markdown
### Q[N]: [Topic]

**Context**: [Why this needs clarification]

**Recommended**: [Best practice recommendation]
**Rationale**: [Why this is recommended]

**Options**:

| Option | Approach | Pros | Cons | When to Use |
|--------|----------|------|------|-------------|
| A | [Name] | [Benefits] | [Drawbacks] | [Use case] |
| B | [Name] | [Benefits] | [Drawbacks] | [Use case] |
| C | [Name] | [Benefits] | [Drawbacks] | [Use case] |

**Your Choice**: [A/B/C or provide alternative]

**Follow-up** (if needed): [Additional details to specify]
```

### Example Templates

**Authentication Method**:
```markdown
### Q1: Authentication Strategy

**Context**: Spec mentions "secure user login" but doesn't specify method

**Recommended**: OAuth2 with JWT tokens
**Rationale**: Industry standard, scalable, stateless, supports SSO

**Options**:

| Option | Approach | Pros | Cons | When to Use |
|--------|----------|------|------|-------------|
| A | OAuth2 + JWT | Stateless, scalable, refresh tokens | More complex | Multi-device, API-heavy |
| B | Session-based | Simpler, mature | Server state, sticky sessions | Traditional web apps |
| C | API Keys | Very simple | No user context, rotation | Service-to-service |

**Your Choice**: _____
```

**Performance Threshold**:
```markdown
### Q2: API Response Time Target

**Context**: Spec says "fast API" without quantification

**Recommended**: <500ms p95, <1000ms p99
**Rationale**: Industry standard for web APIs, user expectation

**Options**:

| Target | p95 | p99 | Use Case |
|--------|-----|-----|----------|
| A | <500ms | <1000ms | Standard web APIs |
| B | <200ms | <500ms | High-performance/real-time |
| C | <1000ms | <2000ms | Complex queries acceptable |

**Your Choice**: _____

**Follow-up**: What should happen if threshold is exceeded?
- [ ] Log warning
- [ ] Alert operations
- [ ] Trigger auto-scaling
- [ ] Return cached data
```

## Recommendation Engine

### Best Practice Database

```javascript
const recommendations = {
  authentication: {
    default: 'OAuth2 with JWT',
    rationale: 'Industry standard, scalable, stateless',
    alternatives: {
      'session-based': 'When simplicity > scalability',
      'api-keys': 'Service-to-service only'
    }
  },

  apiDesign: {
    default: 'REST with OpenAPI spec',
    rationale: 'Widely understood, excellent tooling',
    alternatives: {
      'graphql': 'When clients need flexible queries',
      'grpc': 'Internal microservices, performance critical'
    }
  },

  errorHandling: {
    default: 'User-friendly messages + error codes',
    rationale: 'UX + debugging support',
    pattern: {
      userMessage: 'Plain English, actionable',
      errorCode: 'For support/debugging',
      recovery: 'Suggest next steps'
    }
  },

  performance: {
    apiResponseTime: {
      p95: '<500ms',
      p99: '<1000ms',
      rationale: 'User expectation for web apps'
    },
    pageLoad: {
      fcp: '<2s',
      tti: '<3s',
      rationale: 'Core Web Vitals standards'
    }
  }
};
```

### Context-Aware Recommendations

```javascript
function getRecommendation(ambiguity, projectContext) {
  const { domain, scale, compliance } = projectContext;

  if (ambiguity.topic === 'authentication') {
    if (compliance.includes('HIPAA')) {
      return {
        recommendation: 'OAuth2 + MFA + audit logging',
        rationale: 'HIPAA compliance requires MFA and audit trail'
      };
    }

    if (scale === 'startup-mvp') {
      return {
        recommendation: 'Session-based auth',
        rationale: 'Faster to implement for MVP, can migrate later'
      };
    }
  }

  return getDefaultRecommendation(ambiguity.topic);
}
```

## Update Strategy

### Incremental Spec Updates

After each question is answered:

1. **Locate ambiguous section** in spec.md
2. **Replace marker** with clarified content
3. **Preserve context** (don't remove surrounding text)
4. **Update version** (increment patch version)
5. **Log change** in spec frontmatter

**Example Update**:

Before:
```markdown
## FR-5: File Upload
Users can upload product images
[NEEDS CLARIFICATION: Upload strategy, size limits, formats]
```

After:
```markdown
## FR-5: File Upload

Users can upload product images via presigned S3 URLs.

**Upload Flow**:
1. Request upload URL from API
2. Upload directly to S3
3. Notify API of completion

**Constraints**:
- Max size: 10MB per file
- Formats: JPEG, PNG, WebP
- Max 5 images per product

**Validation**:
- Server validates file type on notification
- Rejects files exceeding size limit
- Scans for malware before associating with product
```

## Validation After Clarify

### Completeness Check

After all clarifications:

```javascript
function validateCompleteness(spec) {
  const remaining = scanForAmbiguities(spec);

  if (remaining.length === 0) {
    return {
      status: 'COMPLETE',
      message: 'All ambiguities resolved'
    };
  }

  if (remaining.every(amb => amb.priority === 'P3')) {
    return {
      status: 'SUFFICIENT',
      message: 'Critical ambiguities resolved, can proceed',
      remaining: remaining
    };
  }

  return {
    status: 'INCOMPLETE',
    message: 'High-priority ambiguities remain',
    blocking: remaining.filter(amb => ['P0', 'P1'].includes(amb.priority))
  };
}
```

## Configuration

### Maximum Questions

Default: 5 questions per run

Rationale:
- Prevents decision fatigue
- Keeps session focused
- Can run multiple times if needed

Override:
```bash
flow:clarify --max-questions 10
```

### Question Depth

**Shallow** (default): Single-level questions
```
Q: Authentication method?
A: OAuth2
```

**Deep**: Follow-up questions
```
Q1: Authentication method?
A: OAuth2

Q2: Token expiration?
A: 15 min access, 7 day refresh

Q3: Refresh token rotation?
A: Yes, rotate on use
```

Enable:
```bash
flow:clarify --depth deep
```

### Auto-Accept Recommendations

Skip Q&A, use all recommendations:
```bash
flow:clarify --auto-accept
```

Use when:
- Trust best practice recommendations
- Time-constrained
- Can adjust later if needed

## Common Clarification Patterns

### API Design

**Ambiguity**: "API for managing products"

**Clarifications**:
1. REST vs GraphQL vs gRPC?
2. Versioning strategy (URI, header, none)?
3. Authentication method?
4. Pagination approach (offset, cursor, none)?
5. Response format (JSON, XML, both)?

### Error Handling

**Ambiguity**: "Handle errors gracefully"

**Clarifications**:
1. User-facing error messages format?
2. HTTP status codes strategy?
3. Error response structure?
4. Retry logic (automatic, manual, none)?
5. Logging detail level?

### Performance

**Ambiguity**: "System should be performant"

**Clarifications**:
1. API response time target (p95, p99)?
2. Page load time target?
3. Database query performance threshold?
4. Concurrent user capacity?
5. Auto-scaling trigger points?

### Data Validation

**Ambiguity**: "Validate user input"

**Clarifications**:
1. Client-side, server-side, or both?
2. Validation error display approach?
3. Field-level vs form-level validation?
4. Real-time vs on-submit validation?
5. Custom validation messages?

## Related Workflows

### Integration with Other Skills

**After flow:specify**:
```bash
flow:specify "User authentication feature"
# Output: spec.md with [NEEDS CLARIFICATION] markers

flow:clarify
# Resolves ambiguities

flow:plan
# Now has clear spec to work from
```

**Mid-workflow clarification**:
```bash
flow:plan
# Detects ambiguity in spec during planning

flow:clarify
# Resolves newly discovered ambiguity

flow:plan --update
# Regenerates plan with clarified spec
```

## Troubleshooting

### "No ambiguities detected but spec is unclear"

**Cause**: Ambiguities not marked with explicit tags

**Fix**: Add `[NEEDS CLARIFICATION]` markers manually, then run

### "Too many questions generated"

**Cause**: Spec has many ambiguities

**Fix**: Run multiple times, tackle high-priority first

### "Recommendations don't fit project"

**Cause**: Generic recommendations, context not considered

**Fix**: Provide project context: `flow:clarify "Enterprise healthcare app, HIPAA compliant"`

### "Updates not applied to spec"

**Cause**: Edit conflicts or file permission issues

**Fix**: Check spec.md file permissions, ensure not open in editor with unsaved changes

## Best Practices

1. **Clarify early**: Run after flow:specify, before flow:plan
2. **Be specific**: Provide context about project domain/constraints
3. **Review recommendations**: Don't blindly accept, consider your specific needs
4. **Document decisions**: Clarifications become part of spec history
5. **Iterate if needed**: Can run multiple times for different ambiguity sets
