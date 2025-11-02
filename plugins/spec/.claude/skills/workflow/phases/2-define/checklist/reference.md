# Checklist phase Reference

Technical specifications and templates for quality checklist generation.

---

## Quality Dimensions

### 1. Completeness

**Definition**: All necessary requirements for the domain are defined.

**Test Questions**:
- Are all required items present?
- Are all scenarios covered?
- Are edge cases addressed?
- Are dependencies specified?

**Examples**:
```markdown
GOOD: "Are error response schemas defined for all 4xx and 5xx status codes?"
GOOD: "Are loading states specified for all async operations?"
BAD: "Is the API documented?" (too broad)
```

### 2. Clarity

**Definition**: Requirements are specific, unambiguous, and measurable.

**Vague Terms to Quantify**:
- "Fast" → "<500ms p95 response time"
- "User-friendly" → "SUS score >80, task completion >90%"
- "Secure" → "TLS 1.3, AES-256, OWASP Top 10 mitigations"
- "Scalable" → "Support 10k concurrent users, 100k RPS"
- "Reliable" → "99.9% uptime SLA, <1% error rate"

**Test Questions**:
- Can this be objectively measured?
- Are specific values provided?
- Is terminology defined?
- Are units included?

**Examples**:
```markdown
GOOD: "Is 'fast loading' quantified (<3s LCP, <100ms FID)?"
GOOD: "Is color contrast ratio specified (4.5:1 minimum)?"
BAD: "Is it clear?" (meta-question, not testable)
```

### 3. Consistency

**Definition**: Patterns, terminology, and formats are uniform across requirements.

**Test Questions**:
- Are naming conventions consistent?
- Are error formats aligned?
- Are units uniform?
- Are patterns repeated?

**Examples**:
```markdown
GOOD: "Are timestamp formats consistent (ISO 8601) across all APIs?"
GOOD: "Are button states (default, hover, active, disabled) defined consistently?"
BAD: "Is it consistent?" (not specific enough)
```

### 4. Measurability

**Definition**: Acceptance criteria can be objectively verified.

**Test Questions**:
- Can success be measured?
- Are acceptance criteria testable?
- Are metrics defined?
- Can it be automated?

**Examples**:
```markdown
GOOD: "Are accessibility criteria measurable (WCAG 2.1 AA conformance)?"
GOOD: "Are performance targets testable (Lighthouse score >90)?"
BAD: "Does it meet requirements?" (circular logic)
```

### 5. Coverage

**Definition**: All scenarios, edge cases, and failure modes are addressed.

**Test Questions**:
- Are success paths defined?
- Are error paths specified?
- Are edge cases covered?
- Are timeout scenarios addressed?

**Examples**:
```markdown
GOOD: "Are network failure scenarios specified (offline, slow 3G, timeout)?"
GOOD: "Are concurrent modification conflicts addressed?"
BAD: "Are all cases covered?" (not specific)
```

### 6. Gap

**Definition**: Required information is missing from specification.

**Test Questions**:
- What requirements should exist but don't?
- What industry standards apply?
- What dependencies are unspecified?
- What compliance requirements are missing?

**Examples**:
```markdown
GOOD: "Are rate limiting rules defined? [Gap]"
GOOD: "Is GDPR data retention period specified? [Gap]"
GOOD: "Are database indexes defined for query performance? [Gap]"
```

---

## Checklist Templates

### UX Checklist Template

```markdown
# UX Quality Checklist

## Visual Consistency
- [ ] CHK001 - Are color values explicitly defined (hex codes, CSS variables)? [Completeness]
- [ ] CHK002 - Are typography specifications complete (font, size, weight, line-height)? [Completeness]
- [ ] CHK003 - Are spacing values defined (margins, padding, gaps)? [Completeness]
- [ ] CHK004 - Are visual styles consistent across components? [Consistency]

## Interactive States
- [ ] CHK005 - Are button states defined (default, hover, active, focus, disabled)? [Completeness]
- [ ] CHK006 - Are loading states specified for async operations? [Completeness]
- [ ] CHK007 - Are error states visually defined? [Completeness]

## Accessibility
- [ ] CHK008 - Are WCAG 2.1 AA requirements specified? [Completeness]
- [ ] CHK009 - Is keyboard navigation flow defined? [Completeness]
- [ ] CHK010 - Are ARIA labels specified for screen readers? [Completeness]
- [ ] CHK011 - Is color contrast ratio specified (4.5:1 minimum)? [Clarity]

## Responsive Design
- [ ] CHK012 - Are breakpoints defined (mobile, tablet, desktop)? [Completeness]
- [ ] CHK013 - Are mobile-first layouts specified? [Completeness]
- [ ] CHK014 - Are touch targets sized appropriately (44x44px minimum)? [Clarity]

## User Flows
- [ ] CHK015 - Are navigation paths clearly defined? [Completeness]
- [ ] CHK016 - Are error recovery flows specified? [Coverage]
```

### API Checklist Template

```markdown
# API Quality Checklist

## Endpoint Definitions
- [ ] CHK001 - Are all endpoints listed with methods (GET, POST, PUT, DELETE)? [Completeness]
- [ ] CHK002 - Are URL paths following REST conventions? [Consistency]
- [ ] CHK003 - Are path parameters clearly defined? [Completeness]
- [ ] CHK004 - Are query parameters documented with types and constraints? [Completeness]

## Request/Response Schemas
- [ ] CHK005 - Are request schemas fully defined (fields, types, required, constraints)? [Completeness]
- [ ] CHK006 - Are response schemas specified with all fields? [Completeness]
- [ ] CHK007 - Are field naming conventions consistent (camelCase, snake_case)? [Consistency]
- [ ] CHK008 - Are data types explicitly specified? [Clarity]

## Error Handling
- [ ] CHK009 - Are all error status codes enumerated (400, 401, 403, 404, 422, 500)? [Completeness]
- [ ] CHK010 - Is error response format defined consistently? [Consistency]
- [ ] CHK011 - Are error messages user-friendly and actionable? [Clarity]
- [ ] CHK012 - Are validation error formats specified? [Completeness]

## Authentication/Authorization
- [ ] CHK013 - Is authentication mechanism specified (OAuth2, JWT, API key)? [Completeness]
- [ ] CHK014 - Are authorization rules defined per endpoint? [Completeness]
- [ ] CHK015 - Are token refresh flows specified? [Coverage]

## API Standards
- [ ] CHK016 - Is versioning strategy defined (URL, header)? [Completeness]
- [ ] CHK017 - Is pagination specified for collection endpoints? [Completeness]
- [ ] CHK018 - Are rate limiting rules defined? [Completeness]
- [ ] CHK019 - Are idempotency requirements specified? [Coverage]
- [ ] CHK020 - Is Content-Type handling defined? [Completeness]
```

### Security Checklist Template

```markdown
# Security Quality Checklist

## Encryption
- [ ] CHK001 - Is data in transit encrypted (TLS 1.3 minimum)? [Clarity]
- [ ] CHK002 - Is data at rest encrypted (AES-256)? [Clarity]
- [ ] CHK003 - Are key management procedures defined? [Completeness]
- [ ] CHK004 - Are certificate rotation procedures specified? [Coverage]

## Authentication
- [ ] CHK005 - Is authentication mechanism specified? [Completeness]
- [ ] CHK006 - Are password requirements defined (length, complexity, history)? [Completeness]
- [ ] CHK007 - Is MFA requirement specified? [Completeness]
- [ ] CHK008 - Are account lockout rules defined? [Coverage]
- [ ] CHK009 - Are session timeout rules specified? [Completeness]
- [ ] CHK010 - Is password reset flow secure? [Coverage]

## Authorization
- [ ] CHK011 - Are RBAC roles defined? [Completeness]
- [ ] CHK012 - Are permission rules specified per role? [Completeness]
- [ ] CHK013 - Is principle of least privilege documented? [Completeness]
- [ ] CHK014 - Are resource access controls specified? [Completeness]

## Data Protection
- [ ] CHK015 - Is PII/PHI explicitly classified? [Completeness]
- [ ] CHK016 - Are data retention periods defined? [Completeness]
- [ ] CHK017 - Are data deletion procedures specified? [Coverage]
- [ ] CHK018 - Is data minimization principle applied? [Completeness]

## Audit & Monitoring
- [ ] CHK019 - Are audit log fields specified (who, what, when, IP)? [Completeness]
- [ ] CHK020 - Is audit log retention period defined? [Completeness]
- [ ] CHK021 - Are security monitoring rules defined? [Completeness]
- [ ] CHK022 - Are intrusion detection requirements specified? [Coverage]

## Compliance
- [ ] CHK023 - Are regulatory requirements identified (GDPR, HIPAA, SOC2)? [Completeness]
- [ ] CHK024 - Are compliance controls mapped to requirements? [Completeness]
- [ ] CHK025 - Are breach notification procedures defined? [Coverage]
```

### Performance Checklist Template

```markdown
# Performance Quality Checklist

## Response Times
- [ ] CHK001 - Are initial load time thresholds specified (<3s LCP)? [Clarity]
- [ ] CHK002 - Are API response time SLAs defined (p50, p95, p99)? [Clarity]
- [ ] CHK003 - Are Time to First Byte (TTFB) targets specified? [Completeness]
- [ ] CHK004 - Are Time to Interactive (TTI) metrics defined? [Completeness]

## Throughput
- [ ] CHK005 - Are requests/second targets specified? [Clarity]
- [ ] CHK006 - Are concurrent user capacity requirements defined? [Clarity]
- [ ] CHK007 - Are data transfer volume limits specified? [Completeness]

## Scalability
- [ ] CHK008 - Are horizontal scaling triggers defined? [Completeness]
- [ ] CHK009 - Are auto-scaling policies specified? [Completeness]
- [ ] CHK010 - Are database connection pool sizes defined? [Completeness]

## Optimization
- [ ] CHK011 - Is caching strategy defined (Redis, CDN, browser cache)? [Completeness]
- [ ] CHK012 - Are database indexes specified for queries? [Completeness]
- [ ] CHK013 - Are lazy loading requirements defined? [Coverage]
- [ ] CHK014 - Is asset compression specified (gzip, brotli)? [Completeness]

## Resource Limits
- [ ] CHK015 - Are API rate limits defined per user/endpoint? [Completeness]
- [ ] CHK016 - Are request payload size limits specified? [Completeness]
- [ ] CHK017 - Are timeout values defined for operations? [Completeness]
```

---

## Generation Algorithm

### Step 1: Domain Detection

Scan spec.md for indicators:

**UX Domain**:
- Keywords: UI, interface, design, accessibility, responsive, user experience
- Sections: Visual Design, Interactions, User Stories with UI focus

**API Domain**:
- Keywords: endpoint, REST, GraphQL, request, response, API
- Sections: API Endpoints, Data Schemas, Authentication

**Security Domain**:
- Keywords: authentication, authorization, encryption, PII, PHI, HIPAA, GDPR
- Sections: Security Requirements, Data Protection, Compliance

**Performance Domain**:
- Keywords: performance, speed, response time, scalability, load
- Sections: Non-Functional Requirements, Performance Metrics, SLAs

### Step 2: Requirement Extraction

For each domain, extract:
1. Requirement IDs (US-###, API-###, NFR-###)
2. Acceptance criteria (AC1, AC2, etc.)
3. Specific values mentioned
4. Vague terms used

### Step 3: Checklist Item Generation

For each requirement:

**Completeness Items**:
- Check if all necessary details present
- Target: 40% of items

**Clarity Items**:
- Identify vague terms ("fast", "user-friendly")
- Check if measurable criteria defined
- Target: 30% of items

**Consistency Items**:
- Check alignment with other requirements
- Verify pattern uniformity
- Target: 15% of items

**Coverage Items**:
- Identify missing edge cases
- Check error scenarios
- Target: 15% of items

### Step 4: Gap Identification

Compare spec against domain checklist template:
- Mark items with [?] for missing requirements
- These become explicit gaps to address

### Step 5: Priority Assignment

Implicit priority based on position:
1. Completeness and Gap items first (critical)
2. Clarity items second (important)
3. Consistency and Coverage items third (refinement)

---

## Configuration Options

### Checklist Depth

**Standard** (default):
- 10-15 items per domain
- Focus on critical gaps

**Detailed**:
- 20-30 items per domain
- Include edge cases and nice-to-haves

**Minimal**:
- 5-8 items per domain
- Only critical completeness checks

### Domain Focus

**Auto-detect** (default):
- Scan spec and generate for detected domains

**Explicit**:
```bash
Checklist phase --domains ux,security
```

**Custom Focus**:
```bash
Checklist phase "Focus on API error handling and authentication"
```

---

## Validation Rules

### Valid Checklist Item

MUST include:
1. Checkbox `- [ ]`
2. Unique ID `CHK###`
3. Quality question ending with `?`
4. Quality dimension `[Dimension]`

MAY include:
5. Spec reference `[Dimension, Spec §X.Y]`
6. Status marker `[Gap]`

**Valid**:
```markdown
- [ ] CHK001 - Are error formats defined? [Completeness, Spec §API-3]
- [?] CHK002 - Is MFA required? [Gap]
- [~] CHK003 - Is "fast" quantified? [Clarity]
```

**Invalid**:
```markdown
- Check error handling (missing ID, dimension, question format)
- [ ] Are errors defined (missing ID, dimension)
- [ ] CHK001 - Error handling [Completeness] (not a question)
```

### Valid Checklist File

MUST include:
1. H1 title: `# [Domain] Quality Checklist`
2. At least 5 checklist items
3. Section headers (H2) organizing items
4. Status summary at bottom

---

## Common Patterns by Domain

### UX Patterns

**Vague Visual Terms**:
- "Clean design" → Colors, spacing, typography specified?
- "Modern look" → Design system components defined?
- "Intuitive" → User testing criteria specified?

**Missing Accessibility**:
- Always check WCAG 2.1 AA
- Keyboard navigation
- Screen reader support
- Color contrast ratios

**Responsive Gaps**:
- Breakpoints not defined
- Mobile-first not specified
- Touch targets too small

### API Patterns

**Incomplete Schemas**:
- Missing field types
- No validation rules
- No example payloads

**Inconsistent Errors**:
- Different formats per endpoint
- Missing error codes
- Vague error messages

**Missing Standards**:
- No versioning strategy
- No pagination
- No rate limiting

### Security Patterns

**Vague Security Terms**:
- "Secure" → Specific encryption standards?
- "Protected" → Access controls defined?
- "Compliant" → Specific regulations mapped?

**Missing Controls**:
- Authentication without MFA
- Authorization without RBAC
- Encryption without key management

**Compliance Gaps**:
- HIPAA without BAA
- GDPR without data retention
- SOC2 without audit logs

### Performance Patterns

**Unmeasurable Terms**:
- "Fast" → Specific timing thresholds?
- "Scalable" → Concurrent user capacity?
- "Reliable" → Uptime SLA percentage?

**Missing Targets**:
- No percentile metrics (p95, p99)
- No throughput requirements
- No resource limits

---

## Integration Points

### Before: generate phase

User creates feature specification with requirements.

### After: plan phase

Once all checklist items validated, proceed to technical planning.

### Related: spec:validate

Checks cross-requirement consistency and dependency validation.

---

## Testing

Validate generated checklists:

```bash
# Check format
grep -E "^- \[[ X~?]\] CHK[0-9]{3} - .+\? \[.+\]" checklist.md

# Count items
grep -c "^- \[ \]" checklist.md

# Find gaps
grep "\[?\]" checklist.md

# Check references
grep -oE "Spec §[A-Z]+-[0-9]+" checklist.md
```

---

## Best Practices

### DO

- Generate checklists early (after generate phase)
- Focus on requirement quality, not implementation
- Use specific, testable questions
- Link items to spec sections
- Iterate after spec updates

### DON'T

- Test implementation correctness
- Create vague meta-questions
- Skip gap identification
- Forget to update after spec changes
- Proceed to plan phase with open gaps

---

## Troubleshooting

**Too many gap items**: Spec needs significant refinement before planning.

**All items complete**: Validate manually; may need more detailed checklist.

**No domains detected**: Spec may be too high-level; add specific requirements.

**Duplicate questions**: Merge related items; may indicate spec redundancy.
