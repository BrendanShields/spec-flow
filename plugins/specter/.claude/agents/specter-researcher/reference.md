# Flow Researcher: Reference Guide

## Research Patterns

**Domain-Specific Research:** E-commerce (payment, PCI, inventory) | SaaS (multi-tenancy, billing, RBAC) | Real-time (WebSocket, SSE, presence)

## Research Strategies

**Best Practices Extraction:** Industry standards → Common patterns → Anti-patterns

**Technology Evaluation:** Find candidates → Analyze pros/cons → Assess maturity/community → Score

**Security Research:** OWASP vulnerabilities → Best practices → Compliance (GDPR, CCPA, PCI-DSS)

## Research Templates

### Technology Comparison Matrix
```markdown
| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Scalability | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Learning Curve | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Community | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Cost | Free | $$$ | $ |
| **Score** | **18/25** | **18/25** | **19/25** |
```

**Best Practices Summary:** Industry standards → Common patterns → Anti-patterns to avoid

## Research Sources

**API Design:** OpenAPI, REST guidelines (Microsoft, Google, Stripe), GraphQL, gRPC
**Architecture:** Martin Fowler patterns, Cloud Native, Microservices.io, 12-Factor
**Security:** OWASP, NIST framework, CWE database, Security headers
**Performance:** Web performance, DB optimization, caching, CDN patterns

## Research Automation

**Web Search:** Technical articles → Official docs → Code examples → Community discussions

**Pattern Recognition:** Architectural patterns (layered, microservices) → Design patterns → Coding conventions