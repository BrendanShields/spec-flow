# Flow Researcher: Reference Guide

## Research Patterns

### Domain-Specific Research

```javascript
const DOMAIN_PATTERNS = {
  'e-commerce': {
    keywords: ['cart', 'checkout', 'payment', 'inventory', 'shipping'],
    research: [
      'Payment gateway best practices',
      'PCI compliance requirements',
      'Inventory management patterns',
      'Shopping cart persistence strategies'
    ],
    references: [
      'Shopify API design',
      'Stripe integration patterns',
      'Amazon checkout flow'
    ]
  },

  'saas': {
    keywords: ['subscription', 'tenant', 'billing', 'roles', 'permissions'],
    research: [
      'Multi-tenancy architectures',
      'Subscription billing models',
      'RBAC vs ABAC patterns',
      'SaaS metrics and analytics'
    ],
    references: [
      'Salesforce architecture',
      'Auth0 patterns',
      'Stripe billing'
    ]
  },

  'real-time': {
    keywords: ['websocket', 'streaming', 'live', 'push', 'presence'],
    research: [
      'WebSocket vs SSE comparison',
      'Scaling WebSocket connections',
      'Message queuing patterns',
      'Presence system design'
    ],
    references: [
      'Discord architecture',
      'Slack real-time messaging',
      'Socket.io patterns'
    ]
  }
};
```

## Research Strategies

### Strategy 1: Best Practices Extraction
```javascript
async function extractBestPractices(domain, feature) {
  const practices = [];

  // Industry standards
  const standards = await searchIndustryStandards(domain);
  practices.push(...standards);

  // Common patterns
  const patterns = await findCommonPatterns(feature);
  practices.push(...patterns);

  // Anti-patterns to avoid
  const antiPatterns = await identifyAntiPatterns(domain, feature);
  practices.push(...antiPatterns.map(a => ({
    type: 'avoid',
    ...a
  })));

  return practices;
}
```

### Strategy 2: Technology Evaluation
```javascript
async function evaluateTechnologies(requirements) {
  const options = [];

  for (const req of requirements) {
    const techs = await findTechnologies(req);

    for (const tech of techs) {
      const evaluation = {
        name: tech.name,
        pros: await analyzePros(tech, requirements),
        cons: await analyzeCons(tech, requirements),
        maturity: await assessMaturity(tech),
        community: await measureCommunity(tech),
        score: 0
      };

      // Calculate weighted score
      evaluation.score = calculateScore(evaluation, requirements);
      options.push(evaluation);
    }
  }

  return options.sort((a, b) => b.score - a.score);
}
```

### Strategy 3: Security Research
```javascript
async function securityResearch(feature) {
  const findings = {
    vulnerabilities: [],
    mitigations: [],
    bestPractices: [],
    compliance: []
  };

  // OWASP Top 10 relevant items
  findings.vulnerabilities = await checkOWASP(feature);

  // Security best practices
  findings.bestPractices = await getSecurityPractices(feature);

  // Compliance requirements
  if (involvesPersonalData(feature)) {
    findings.compliance.push('GDPR');
    findings.compliance.push('CCPA');
  }

  if (involvesPayment(feature)) {
    findings.compliance.push('PCI-DSS');
  }

  // Specific mitigations
  for (const vuln of findings.vulnerabilities) {
    findings.mitigations.push(await getMitigation(vuln));
  }

  return findings;
}
```

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

### Best Practices Summary
```markdown
## Best Practices for [Feature]

### Industry Standards
1. **Standard**: Description
   - Implementation: How to apply
   - Reference: Link or source

### Common Patterns
1. **Pattern Name**
   - Use when: Conditions
   - Benefits: Why use it
   - Example: Code or diagram

### Anti-patterns to Avoid
1. **Anti-pattern Name**
   - Why it's bad: Explanation
   - Instead use: Alternative
```

## Research Sources

### API Design
- OpenAPI Specification
- REST API Guidelines (Microsoft, Google, Stripe)
- GraphQL Best Practices
- gRPC Patterns

### Architecture
- Martin Fowler's Architecture Patterns
- Cloud Native Patterns
- Microservices.io
- 12-Factor App

### Security
- OWASP Guidelines
- NIST Cybersecurity Framework
- CWE Database
- Security Headers

### Performance
- Web Performance Best Practices
- Database Optimization Guides
- Caching Strategies
- CDN Patterns

## Research Automation

### Web Search Integration
```javascript
async function automatedResearch(topic) {
  const results = {
    articles: [],
    documentation: [],
    examples: [],
    discussions: []
  };

  // Search technical articles
  results.articles = await searchTechnicalArticles(topic);

  // Find official documentation
  results.documentation = await findOfficialDocs(topic);

  // Locate code examples
  results.examples = await searchCodeExamples(topic);

  // Find community discussions
  results.discussions = await searchDiscussions(topic);

  // Synthesize findings
  return synthesizeResearch(results);
}
```

### Pattern Recognition
```javascript
function recognizePatterns(codebase) {
  const patterns = {
    architectural: [],
    design: [],
    coding: []
  };

  // Detect architectural patterns
  if (hasLayeredStructure(codebase)) {
    patterns.architectural.push('Layered Architecture');
  }

  if (hasMicroservices(codebase)) {
    patterns.architectural.push('Microservices');
  }

  // Detect design patterns
  patterns.design = detectDesignPatterns(codebase);

  // Detect coding patterns
  patterns.coding = detectCodingConventions(codebase);

  return patterns;
}
```