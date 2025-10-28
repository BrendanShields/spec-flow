# Flow Specify: Reference Guide

## Priority System

### P1 - Must Have (MVP)
- Core functionality
- Critical user journeys
- Security requirements
- Legal/compliance needs

### P2 - Should Have
- Important enhancements
- Performance optimizations
- Extended functionality
- Integration features

### P3 - Nice to Have
- Polish features
- Advanced capabilities
- Future considerations
- Experimental features

## Domain Detection Patterns

| Domain | Auto-Applied Patterns |
|--------|---------------------|
| E-commerce | Cart, payment, inventory, shipping |
| SaaS | Multi-tenancy, subscriptions, roles |
| API | REST/GraphQL, auth, rate limiting |
| Real-time | WebSockets, presence, sync |
| Mobile | Offline-first, push notifications |

## Specification Quality Metrics

### Completeness Score
- User stories: 40%
- Acceptance criteria: 30%
- Edge cases: 20%
- Non-functionals: 10%

### Testability Indicators
- ✅ Specific, measurable criteria
- ✅ Clear input/output definitions
- ✅ Observable behaviors
- ❌ Vague requirements ("fast", "easy")

## Integration Points

### JIRA Sync
```yaml
jira_id: PROJ-123
jira_url: https://company.atlassian.net/browse/PROJ-123
sync_direction: bidirectional
```

### Confluence Documentation
- Specs auto-publish to Confluence
- Maintains version history
- Links to JIRA stories