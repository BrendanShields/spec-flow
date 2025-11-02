# spec:checklist Examples

Concrete scenarios demonstrating quality checklist generation.

---

## Example 1: UX Checklist for E-commerce Checkout

**Context**: Validating checkout flow requirements

**Spec Section** (spec.md):
```markdown
## User Stories

### US-001: Complete Purchase
As a customer, I want to complete checkout quickly so I can finish my purchase.

**Acceptance Criteria**:
- AC1: Checkout process is fast
- AC2: Payment form is user-friendly
- AC3: Confirmation shown after purchase
```

**Generated Checklist** (checklists/ux.md):
```markdown
# UX Quality Checklist

## Completeness

- [?] CHK001 - Are specific checkout steps defined (cart → info → payment → confirm)? [Gap, US-001]
- [?] CHK002 - Are form field labels and validation rules specified? [Gap, AC2]
- [ ] CHK003 - Are confirmation page elements defined (order #, summary, next steps)? [Completeness, AC3]
- [?] CHK004 - Are error states specified for payment failures? [Gap]

## Clarity

- [~] CHK005 - Is "fast" quantified with timing thresholds (<3s per step)? [Clarity, AC1]
- [~] CHK006 - Is "user-friendly" defined with usability criteria? [Clarity, AC2]
- [ ] CHK007 - Are button labels explicitly specified ("Complete Order" vs "Submit")? [Clarity]

## Accessibility

- [?] CHK008 - Are WCAG 2.1 AA requirements specified? [Gap]
- [?] CHK009 - Is keyboard navigation flow defined? [Gap]
- [?] CHK010 - Are screen reader announcements specified for status changes? [Gap]

## Responsive Design

- [?] CHK011 - Are mobile breakpoints defined (<768px, <480px)? [Gap]
- [?] CHK012 - Is mobile-first layout specified for payment form? [Gap]

**Status**: 2/12 complete, 8 gaps identified, 2 need refinement
```

**Action**: Add missing requirements to spec.md before proceeding to spec:plan.

---

## Example 2: API Checklist for REST Endpoints

**Context**: Validating REST API specification

**Spec Section** (spec.md):
```markdown
## API Endpoints

### POST /api/orders
Create new order

**Request**: Order object
**Response**: Created order

**Errors**: Returns error if invalid
```

**Generated Checklist** (checklists/api.md):
```markdown
# API Quality Checklist

## Completeness

- [~] CHK001 - Is request schema fully defined with all fields, types, constraints? [Completeness, POST /api/orders]
- [~] CHK002 - Is response schema specified with all fields and status codes? [Completeness]
- [ ] CHK003 - Are all error scenarios enumerated (400, 401, 403, 422, 500)? [Completeness]
- [?] CHK004 - Is authentication mechanism specified (Bearer token, API key)? [Gap]
- [?] CHK005 - Are rate limiting rules defined? [Gap]

## Clarity

- [~] CHK006 - Is "order object" fully defined or referenced? [Clarity]
- [~] CHK007 - Is "error if invalid" specified with error response format? [Clarity]

## Consistency

- [?] CHK008 - Are error response formats consistent across all endpoints? [Gap]
- [?] CHK009 - Are field naming conventions specified (camelCase, snake_case)? [Gap]
- [ ] CHK010 - Are timestamp formats consistent (ISO 8601)? [Consistency]

## REST Standards

- [ ] CHK011 - Does POST /api/orders follow REST conventions (201 Created)? [Consistency]
- [?] CHK012 - Are idempotency requirements specified? [Gap]
- [?] CHK013 - Is pagination defined for collection endpoints? [Gap]

**Status**: 1/13 complete, 7 gaps, 5 need refinement
```

**Insight**: API spec lacks critical details. Add schemas, error formats, auth before planning.

---

## Example 3: Security Checklist for HIPAA Compliance

**Context**: Healthcare app with patient data

**Spec Section** (spec.md):
```markdown
## Security Requirements

### SEC-001: Protect Patient Data
Patient information must be secure and comply with HIPAA.

**Acceptance Criteria**:
- AC1: Data is encrypted
- AC2: Access is logged
- AC3: PHI is protected
```

**Generated Checklist** (checklists/security.md):
```markdown
# Security Quality Checklist

## Encryption

- [~] CHK001 - Is encryption specified for data in transit (TLS 1.3)? [Clarity, AC1]
- [~] CHK002 - Is encryption specified for data at rest (AES-256)? [Clarity, AC1]
- [?] CHK003 - Are key management procedures defined? [Gap]

## Authentication

- [?] CHK004 - Is authentication mechanism specified (MFA required)? [Gap]
- [?] CHK005 - Are password complexity requirements defined? [Gap]
- [?] CHK006 - Are session timeout rules specified? [Gap]

## Authorization

- [?] CHK007 - Are RBAC roles defined (doctor, nurse, admin)? [Gap]
- [?] CHK008 - Are permission rules specified per role? [Gap]
- [?] CHK009 - Is principle of least privilege documented? [Gap]

## Audit Logging

- [~] CHK010 - Are audit log fields specified (who, what, when, IP)? [Clarity, AC2]
- [?] CHK011 - Is audit log retention period defined (7 years for HIPAA)? [Gap]
- [?] CHK012 - Are audit log access controls specified? [Gap]

## PHI Protection

- [~] CHK013 - Is PHI explicitly defined and classified? [Clarity, AC3]
- [?] CHK014 - Are data minimization rules specified? [Gap]
- [?] CHK015 - Are breach notification procedures defined? [Gap]
- [?] CHK016 - Is Business Associate Agreement (BAA) requirement documented? [Gap]

## HIPAA Compliance

- [?] CHK017 - Are all 18 HIPAA identifiers addressed? [Gap]
- [?] CHK018 - Is patient consent workflow specified? [Gap]
- [?] CHK019 - Is right-to-access (within 30 days) specified? [Gap]
- [?] CHK020 - Is data portability requirement documented? [Gap]

**Status**: 0/20 complete, 16 gaps, 4 need refinement

**Critical**: Specification lacks HIPAA compliance details. Cannot proceed without addressing all gaps.
```

**Action**: Major spec revision required. Consult compliance team before implementation.

---

## Example 4: Performance Checklist for Real-time Dashboard

**Context**: Real-time analytics dashboard

**Spec Section** (spec.md):
```markdown
## Non-Functional Requirements

### NFR-001: Fast Performance
Dashboard must load quickly and update in real-time.

**Acceptance Criteria**:
- AC1: Fast initial load
- AC2: Real-time updates
- AC3: Handles many users
```

**Generated Checklist** (checklists/performance.md):
```markdown
# Performance Quality Checklist

## Response Times

- [~] CHK001 - Is "fast initial load" quantified (<2s on 3G, <1s on WiFi)? [Clarity, AC1]
- [ ] CHK002 - Are Time to First Byte (TTFB) thresholds specified? [Completeness]
- [ ] CHK003 - Are Time to Interactive (TTI) metrics defined? [Completeness]
- [~] CHK004 - Is "real-time" quantified (<100ms update latency)? [Clarity, AC2]

## Scalability

- [~] CHK005 - Is "many users" quantified (concurrent user count)? [Clarity, AC3]
- [?] CHK006 - Are throughput requirements specified (requests/second)? [Gap]
- [?] CHK007 - Are auto-scaling triggers defined? [Gap]

## Data Optimization

- [?] CHK008 - Are data aggregation intervals specified (1s, 5s, 1m)? [Gap]
- [?] CHK009 - Is caching strategy defined (Redis, CDN)? [Gap]
- [?] CHK010 - Are data retention periods specified? [Gap]

## Resource Limits

- [?] CHK011 - Are API rate limits defined per user/endpoint? [Gap]
- [?] CHK012 - Are WebSocket connection limits specified? [Gap]

**Status**: 2/12 complete, 7 gaps, 3 need refinement
```

**Action**: Replace vague terms with quantified SLAs. Define scalability targets.

---

## Example 5: Multi-Domain Checklist Generation

**Context**: Feature requires UX, API, and security validation

**Command**:
```bash
spec:checklist
```

**Generated Structure**:
```
{config.paths.features}/{config.naming.feature_directory}/
├── spec.md
└── checklists/
    ├── README.md
    ├── ux.md              # 12 items
    ├── api.md             # 15 items
    └── security.md        # 18 items
```

**Summary** (checklists/README.md):
```markdown
# Quality Checklists for Feature 042: User Profile

Generated: 2024-01-15

## Checklists

- **ux.md**: 12 items (3 complete, 6 gaps, 3 refinements needed)
- **api.md**: 15 items (5 complete, 8 gaps, 2 refinements needed)
- **security.md**: 18 items (2 complete, 14 gaps, 2 refinements needed)

## Overall Status

**Total**: 45 items
**Complete**: 10 (22%)
**Gaps**: 28 (62%)
**Needs Refinement**: 7 (16%)

## Next Steps

1. Address all [?] gaps by adding missing requirements to spec.md
2. Refine [~] items with specific, measurable criteria
3. Validate [X] all items before proceeding to spec:plan
4. Re-run spec:checklist after spec updates to verify

## Workflow

```bash
# After addressing gaps
spec:checklist              # Regenerate to verify
spec:validate               # Check consistency
spec:plan                   # Proceed to technical design
```
```

**Insight**: 62% gaps indicates spec needs significant refinement before planning.

---

## Common Patterns

### Pattern 1: Vague Requirements → Clarity Items

**Before**:
```markdown
- AC1: System is fast
```

**Checklist Item**:
```markdown
- [~] CHK001 - Is "fast" quantified with timing thresholds? [Clarity, AC1]
```

**After Refinement**:
```markdown
- AC1: System responds within 500ms for p95, 1s for p99
```

### Pattern 2: Missing Details → Gap Items

**Before**:
```markdown
- AC2: Users can authenticate
```

**Checklist Items**:
```markdown
- [?] CHK002 - Is authentication mechanism specified? [Gap, AC2]
- [?] CHK003 - Are password requirements defined? [Gap]
- [?] CHK004 - Is MFA requirement specified? [Gap]
- [?] CHK005 - Is session management defined? [Gap]
```

### Pattern 3: Consistency Validation

**Multiple Requirements**:
```markdown
- API-1: Returns JSON response
- API-2: Returns data object
```

**Checklist Item**:
```markdown
- [ ] CHK006 - Are response formats consistent across all endpoints? [Consistency, API-1, API-2]
```

---

## Usage Tips

1. **Run early**: After spec:specify, before spec:plan
2. **Address gaps first**: [?] items indicate missing requirements
3. **Quantify vague terms**: Replace "fast", "user-friendly", "secure" with metrics
4. **Iterate**: Re-run after spec updates to track progress
5. **Team validation**: Use checklists for peer review and approval gates
