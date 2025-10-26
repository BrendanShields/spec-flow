# Flow Checklist Examples

## 1. UX Checklist

**Input**: Spec for e-commerce product listing page

**Generated Checklist** (`checklists/ux.md`):
```markdown
# UX Requirements Checklist

Purpose: Validate UX requirements are complete, clear, and measurable

## Visual Design

- [ ] CHK001 - Are the number and layout of featured products explicitly specified? [Completeness, Spec §FR-1]
- [ ] CHK002 - Are color scheme and typography requirements defined? [Completeness, Spec §UI-1]
- [ ] CHK003 - Is "modern design" quantified with specific visual examples or style guide? [Clarity, Spec §UI-2]

## Interaction Design

- [ ] CHK004 - Are hover state requirements consistently defined for all interactive elements? [Consistency]
- [ ] CHK005 - Are loading states specified for async operations (search, filter)? [Completeness]
- [ ] CHK006 - Are animation durations quantified (not just "smooth transitions")? [Clarity]

## Accessibility

- [ ] CHK007 - Are keyboard navigation requirements specified for all interactive features? [Coverage, Gap]
- [ ] CHK008 - Are screen reader labels defined for all non-text elements? [Coverage, Spec §A11Y-1]
- [ ] CHK009 - Are WCAG conformance level (A, AA, AAA) and specific criteria specified? [Clarity]

## Responsive Design

- [ ] CHK010 - Are breakpoint definitions specified (not just "mobile-friendly")? [Clarity]
- [ ] CHK011 - Are layout behaviors defined for each breakpoint? [Completeness]

Total: 11 items
```

## 2. API Checklist

**Input**: Spec for REST API

**Generated Checklist** (`checklists/api.md`):
```markdown
# API Requirements Checklist

## Endpoint Design

- [ ] CHK001 - Are all endpoint paths following consistent naming conventions? [Consistency]
- [ ] CHK002 - Are HTTP methods appropriately chosen for each operation? [Completeness]
- [ ] CHK003 - Are versioning strategy requirements explicitly defined? [Completeness, Spec §API-1]

## Request/Response

- [ ] CHK004 - Are request body schemas defined for all POST/PUT/PATCH endpoints? [Completeness]
- [ ] CHK005 - Are response formats consistent across all endpoints? [Consistency]
- [ ] CHK006 - Are pagination requirements specified for list endpoints? [Completeness, Gap]

## Error Handling

- [ ] CHK007 - Are error response formats specified for all failure modes? [Completeness]
- [ ] CHK008 - Are appropriate HTTP status codes defined for each error type? [Completeness]
- [ ] CHK009 - Are error messages user-friendly AND include error codes for debugging? [Clarity]

## Authentication & Authorization

- [ ] CHK010 - Are authentication requirements defined for all protected endpoints? [Coverage]
- [ ] CHK011 - Are authorization rules specified (who can access what)? [Completeness]

Total: 11 items
```

## 3. Security Checklist

**Input**: Healthcare app spec (HIPAA compliance needed)

**Generated Checklist** (`checklists/security.md`):
```markdown
# Security Requirements Checklist

## Authentication

- [ ] CHK001 - Are authentication methods specified with implementation details? [Completeness]
- [ ] CHK002 - Are password requirements quantified (length, complexity, expiration)? [Clarity, Spec §SEC-1]
- [ ] CHK003 - Are MFA requirements defined for sensitive operations? [Coverage, Gap]

## Authorization

- [ ] CHK004 - Are role definitions and permission matrices specified? [Completeness]
- [ ] CHK005 - Are authorization rules defined for all protected resources? [Coverage]

## Data Protection

- [ ] CHK006 - Are encryption requirements specified (at-rest and in-transit)? [Completeness, Spec §SEC-3]
- [ ] CHK007 - Are PII handling requirements defined per HIPAA guidelines? [Coverage, Compliance]
- [ ] CHK008 - Are data retention and deletion policies specified? [Completeness, Gap]

## Audit & Logging

- [ ] CHK009 - Are audit log requirements specified for all sensitive operations? [Completeness]
- [ ] CHK010 - Are log retention periods and access controls defined? [Completeness]

## Compliance

- [ ] CHK011 - Are HIPAA compliance requirements explicitly mapped to features? [Coverage, Compliance]
- [ ] CHK012 - Are security incident response procedures specified? [Completeness, Gap]

Total: 12 items
```

## 4. Performance Checklist

**Input**: Real-time messaging app spec

**Generated Checklist** (`checklists/performance.md`):
```markdown
# Performance Requirements Checklist

## Response Time

- [ ] CHK001 - Are API response time targets quantified with percentiles (p50, p95, p99)? [Clarity, Spec §NFR-1]
- [ ] CHK002 - Is "real-time" messaging quantified with specific latency thresholds? [Clarity, Spec §FR-5]
- [ ] CHK003 - Are timeout values specified for all external service calls? [Completeness, Gap]

## Throughput

- [ ] CHK004 - Are concurrent user capacity requirements specified? [Completeness, Spec §NFR-2]
- [ ] CHK005 - Are message throughput targets defined (messages/second)? [Clarity]

## Resource Usage

- [ ] CHK006 - Are memory usage limits specified for client applications? [Completeness, Gap]
- [ ] CHK007 - Are database query performance targets defined? [Completeness]

## Scalability

- [ ] CHK008 - Are horizontal scaling requirements specified? [Completeness, Spec §NFR-3]
- [ ] CHK009 - Are auto-scaling trigger points defined? [Clarity]

Total: 9 items
```

## 5. Multi-Domain Checklist

**User request**: "Focus on security and performance"

**Generated**: Multiple checklists
- `checklists/security.md` (12 items)
- `checklists/performance.md` (9 items)

Total: 21 items across 2 domains

For detailed checklist patterns and item formulas, see [REFERENCE.md](./REFERENCE.md).
