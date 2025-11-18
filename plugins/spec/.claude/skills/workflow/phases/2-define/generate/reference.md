# Specification Generation Reference

Technical documentation for Generate phase skill.

## Complete Spec Template

```markdown
# Feature: [Feature Name]

**Feature ID**: [NNN] (sequential number)
**Priority**: [P1|P2|P3] (Must Have|Should Have|Nice to Have)
**Owner**: [team-name or developer-name]
**Created**: [YYYY-MM-DD]
**Updated**: [YYYY-MM-DD] (if modified)
**JIRA Epic**: [EPIC-123] (if Atlassian integration enabled)
**Confluence Page**: [URL] (if Atlassian integration enabled)

## Problem Statement

[2-4 sentences describing:]
- What problem does this feature solve?
- Who experiences this problem?
- What is the impact of not solving it?
- What is the desired outcome?

## Existing Architecture Context (Brownfield Only)

**Relevant Existing Code:**
- File: path/to/file.ext
  - Description of what it does
  - How this feature integrates with it

**Current Data Models:**
- Model: ModelName
  - Attributes: field1, field2
  - Associations: belongs_to X, has_many Y

**Current Patterns:**
- Pattern used in codebase
- Consistency requirements

## User Stories

### P1 (Must Have)

Core functionality required for MVP. Feature cannot ship without these.

#### US[N].1: [Story Title]
As a [user persona],
I can [action/capability]
so that [benefit/value].

**Acceptance Criteria:**
- [ ] Criterion 1 (specific, testable)
- [ ] Criterion 2 (specific, testable)
- [ ] Edge case 1 handled
- [ ] Edge case 2 handled
- [ ] Error condition 1 handled

**Technical Notes:**
- Implementation considerations
- Performance requirements
- Security considerations

**Dependencies:**
- Depends on: US[N].2
- Blocks: US[N].5

**Estimate:** [S|M|L|XL] (Small: <4h, Medium: 4-8h, Large: 1-2d, XL: 2-5d)

### P2 (Should Have)

Important features that enhance experience but can defer if needed.

#### US[N].4: [Story Title]
[Same format as P1 stories]

### P3 (Nice to Have)

Optional enhancements, convenience features, future considerations.

#### US[N].7: [Story Title]
[Same format as P1 stories]

## Technical Requirements

### Technology Stack
- Language/Framework: [specific versions]
- Database: [type and version]
- External Services: [APIs, SDKs]

### Architecture Decisions

**Decision 1: [Topic]**
- Options considered: A, B, C
- Chosen: B
- Rationale: [why B over A and C]
- Trade-offs: [what we gain/lose]

### Performance Requirements
- Response time: < [N]ms (p95)
- Throughput: [N] requests/second
- Concurrent users: [N]
- Data volume: [size/count]

### Security Requirements
- Authentication: [method]
- Authorization: [RBAC, ABAC, etc]
- Data encryption: [at-rest, in-transit]
- Compliance: [GDPR, HIPAA, SOC2, etc]

### Scalability Requirements
- Horizontal scaling: [yes/no, how]
- Vertical scaling: [limits]
- Caching strategy: [Redis, CDN, etc]
- Database sharding: [if applicable]

## Integration Points

### Internal Integrations
- Service/Component 1: [how it integrates]
- Service/Component 2: [how it integrates]

### External Integrations
- Third-party API 1: [purpose, endpoints, authentication]
- Third-party API 2: [purpose, endpoints, authentication]

### Events/Messages
- Events published: [event-name (payload)]
- Events consumed: [event-name (source)]

### Data Flows
- Input: [source → this feature]
- Output: [this feature → destination]
- Sync vs Async: [pattern used]

## Non-Functional Requirements

### Observability
- Logging: [what to log, level, PII redaction]
- Metrics: [what to measure, thresholds]
- Tracing: [distributed tracing requirements]
- Alerting: [conditions, channels, on-call]

### Reliability
- Availability: [99.9%, 99.99%, etc]
- Error budget: [acceptable error rate]
- Retry logic: [exponential backoff, max attempts]
- Circuit breakers: [where applicable]

### Maintainability
- Code coverage: [minimum percentage]
- Documentation: [API docs, runbooks]
- Testing: [unit, integration, e2e requirements]

### Accessibility
- WCAG level: [A, AA, AAA]
- Screen reader support: [yes/no]
- Keyboard navigation: [requirements]
- Color contrast: [ratios]

### Internationalization
- Languages: [supported locales]
- Date/time formats: [handling]
- Currency: [multi-currency support]
- RTL support: [yes/no]

## Out of Scope

Explicitly document what this feature does NOT include:

- Feature X - deferred to v2 (Feature 045)
- Feature Y - separate epic (Feature 067)
- Feature Z - not applicable for current use case
- Edge case A - acceptable limitation (revisit if users request)

## Open Questions

Mark uncertainties with [CLARIFY: question] for clarify phase phase:

1. [CLARIFY: Specific requirement detail?]
2. [CLARIFY: Performance threshold?]
3. [CLARIFY: Technology choice A or B?]
4. [CLARIFY: Integration point behavior?]
5. [CLARIFY: Edge case handling?]

**Resolution Status:**
- Total questions: [N]
- Resolved: [N] (removed from list)
- Pending: [N] (still in list)

## Dependencies

### External Dependencies
- Third-party service account: [provider, contact]
- API keys/credentials: [what's needed]
- Infrastructure: [servers, databases, etc]

### Internal Dependencies
- Feature ABC must be complete first
- Team X must provide API endpoint
- Design team must deliver mockups

### Team Dependencies
- Backend team: [deliverables]
- Frontend team: [deliverables]
- DevOps team: [deliverables]
- Design team: [deliverables]

## Risks & Mitigation

### Technical Risks
- **Risk**: [description]
  - Probability: [High|Medium|Low]
  - Impact: [High|Medium|Low]
  - Mitigation: [strategy]

### Business Risks
- **Risk**: [description]
  - Probability: [High|Medium|Low]
  - Impact: [High|Medium|Low]
  - Mitigation: [strategy]

### Timeline Risks
- **Risk**: [description]
  - Probability: [High|Medium|Low]
  - Impact: [High|Medium|Low]
  - Mitigation: [strategy]

## Timeline Estimate

### Development Phases
- Specification: [time] (Complete)
- Clarification: [time] (if [CLARIFY] tags exist)
- Planning: [time]
- Implementation: [time]
- Testing: [time]
- Documentation: [time]
- Deployment: [time]

**Total Estimate**: [time]

**Confidence Level**: [High|Medium|Low]
- High: Well-defined, similar to past work
- Medium: Some unknowns, new technology
- Low: Experimental, many dependencies

### Milestones
- Spec complete: [date]
- Implementation start: [date]
- Alpha release: [date]
- Beta release: [date]
- Production release: [date]

## Success Metrics

### Business Metrics
- Metric 1: [target value]
- Metric 2: [target value]

### Technical Metrics
- Performance: [target]
- Reliability: [target]
- Adoption: [target]

### User Metrics
- User satisfaction: [target]
- Feature usage: [target]
- Task completion rate: [target]

### Measurement Plan
- How to collect: [analytics, surveys, logs]
- Baseline: [current state]
- Target: [desired state]
- Timeline: [when to evaluate]

## Rollout Strategy

### Deployment Approach
- [ ] Feature flag controlled
- [ ] Canary deployment (5% → 25% → 100%)
- [ ] Blue/green deployment
- [ ] Rolling deployment

### Rollback Plan
- Trigger conditions: [when to rollback]
- Rollback procedure: [steps]
- Data migration reversal: [if applicable]

### User Communication
- Announcement: [channels, timing]
- Documentation: [what to update]
- Training: [if required]

## Appendices

### Appendix A: User Research
- User interviews: [summary]
- Survey results: [data]
- Analytics insights: [findings]

### Appendix B: Competitive Analysis
- Competitor 1: [how they solve this]
- Competitor 2: [how they solve this]
- Best practices: [industry standards]

### Appendix C: Mockups & Designs
- Figma link: [URL]
- Screenshots: [if applicable]
- User flow diagrams: [if applicable]

### Appendix D: Technical Spikes
- Spike 1: [findings]
- Spike 2: [findings]
- POC results: [learnings]

---

**Specification Status**: [Draft|In Review|Approved|In Progress|Complete]
**Last Reviewed By**: [name]
**Next Review**: [date]
```

## Field Definitions

### Feature ID Format
- **Format**: Sequential 3-digit number (001, 002, 003, etc.)
- **Source**: Count existing {config.paths.features}/ directories + 1
- **Padding**: Always 3 digits with leading zeros
- **Scope**: Per-project sequence (not global)

### Priority Levels

**P1 (Must Have)**:
- Criteria:
  - Core functionality required for MVP
  - Blocks other P1 features if not implemented
  - Critical user need or regulatory requirement
  - Non-negotiable for launch
- Examples:
  - User authentication for secure app
  - Payment processing for e-commerce
  - Data encryption for healthcare app

**P2 (Should Have)**:
- Criteria:
  - Important but can defer 1-2 sprints if needed
  - Significantly enhances UX but not critical
  - Competitive differentiator
  - High user value but workarounds exist
- Examples:
  - Password reset via email
  - Export data to CSV
  - Dark mode theme

**P3 (Nice to Have)**:
- Criteria:
  - Optional enhancements
  - Convenience features
  - Low implementation effort but low user impact
  - Future considerations
- Examples:
  - Profile theme customization
  - Keyboard shortcuts
  - Easter eggs

### User Story Format

**Structure**:
```
As a [specific user persona],
I can [specific action/capability]
so that [specific benefit/value].
```

**Good Examples**:
- "As a mobile user, I can view my order history offline so that I can reference past purchases without internet."
- "As an admin, I can bulk import users from CSV so that I can onboard teams efficiently."

**Bad Examples**:
- "As a user, I want a feature" (too vague)
- "The system should do X" (not user-centric)
- "Implement authentication" (task, not story)

### Acceptance Criteria Format

**Structure**:
- Checkbox list (- [ ])
- Specific, testable conditions
- Positive statements (what it does, not what it doesn't)
- Include edge cases and error conditions

**Good Examples**:
- "User receives password reset email within 60 seconds"
- "Search returns results in < 500ms for 95% of queries"
- "Upload fails gracefully with error message if file > 10MB"

**Bad Examples**:
- "Works correctly" (not specific)
- "Fast search" (not measurable)
- "Handles errors" (not detailed)

### [CLARIFY] Tag Usage

**When to Use**:
- Requirement is ambiguous or incomplete
- Multiple valid interpretations exist
- Technical decision needs stakeholder input
- Performance/scale expectations unspecified
- Business logic unclear

**Format**:
```markdown
[CLARIFY: Specific question requiring resolution?]
```

**Placement**:
- Inline within relevant section
- After related acceptance criteria
- In Open Questions section (aggregated)

**Examples**:
- `[CLARIFY: Password reset link expiry - 1 hour or 24 hours?]`
- `[CLARIFY: Concurrent session limit - 3, 5, or unlimited?]`
- `[CLARIFY: Search technology - Elasticsearch or PostgreSQL full-text?]`

## State File Integration

### Files Read

**`{config.paths.state}/current-session.md`**:
```markdown
## Active Work
### Current Feature
- **Feature ID**: [read to determine next number]
- **Phase**: [check current workflow phase]

## Configuration State
### Flow Settings
SPEC_ATLASSIAN_SYNC=[check if JIRA/Confluence enabled]
SPEC_JIRA_PROJECT_KEY=[for epic creation]
```

**`{config.paths.memory}/workflow-progress.md`**:
```markdown
## Feature Progress Overview
[Read to count existing features, determine next ID]

### Active Features
[Check for existing work on similar features]
```

**`{config.paths.spec_root}/product-requirements.md`** (if exists):
```markdown
[Read to understand overall product vision]
[Check consistency with new feature]
```

### Files Written

**`{config.paths.features}/NNN-feature-name/{config.naming.files.spec}`**:
- Primary output of skill
- Contains complete specification
- Format: See template above

### Files Updated

**`{config.paths.state}/current-session.md`**:
```markdown
## Active Work
### Current Feature
- **Feature ID**: NNN
- **Feature Name**: feature-name
- **Phase**: specification
- **Started**: 2024-10-31
- **JIRA**: PROJ-123 (if created)

## Workflow Progress
### Completed Phases
- [x] initialize phase
- [x] Generate phase ← UPDATED
- [ ] clarify phase
- [ ] plan phase
```

**`{config.paths.memory}/workflow-progress.md`**:
```markdown
### Active Features
| Feature | Phase | Progress | Started | ETA | Blocked |
|---------|-------|----------|---------|-----|---------|
| NNN-feature-name | Specification | Spec created | 2024-10-31 | TBD | No |

### Feature Summary
| Feature | Status | Spec | Plan | Tasks | Impl | Complete |
|---------|--------|------|------|-------|------|----------|
| NNN-feature-name | 🔄 | ✅ | ⏳ | ⏳ | ⏳ | 20% |
```

## External Integrations

### JIRA Integration (via MCP)

**Configuration Check**:
```bash
# Read from project claude.md
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
```

**Epic Creation**:
```javascript
// Via MCP tool (if available)
{
  "tool": "jira_create_epic",
  "parameters": {
    "project": "PROJ",
    "summary": "Feature: Feature Name",
    "description": "[spec.md content formatted for JIRA]",
    "labels": ["spec", "feature-NNN"],
    "priority": "High" // for P1, Medium for P2, Low for P3
  }
}
```

**Story Creation**:
```javascript
// Create story for each user story
{
  "tool": "jira_create_story",
  "parameters": {
    "project": "PROJ",
    "epic": "PROJ-123",
    "summary": "US[N].1: Story Title",
    "description": "[acceptance criteria formatted]",
    "priority": "High|Medium|Low",
    "labels": ["P1|P2|P3", "spec"]
  }
}
```

**Linking**:
- Add JIRA epic key to spec.md frontmatter
- Update current-session.md with JIRA link
- Add comment to JIRA epic with link to spec.md (if possible)

### Confluence Integration (via MCP)

**Configuration Check**:
```bash
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
```

**Page Creation**:
```javascript
{
  "tool": "confluence_create_page",
  "parameters": {
    "space": "DEV",
    "parent_page_id": "123456",
    "title": "Feature NNN: Feature Name",
    "content": "[spec.md converted to Confluence storage format]"
  }
}
```

**Content Formatting**:
- Convert markdown to Confluence storage format
- Add table of contents macro
- Include status macro (Planning, In Progress, Complete)
- Link to JIRA epic

### GitHub Integration

**Issue Creation** (optional):
```bash
gh issue create \
  --title "Feature NNN: Feature Name" \
  --body "$(cat {config.paths.features}/NNN-feature-name/{config.naming.files.spec})" \
  --label "feature,P1,specification"
```

**Branch Creation** (deferred to implementation phase):
```bash
# Not created during Generate phase
# Created later by implement phase
```

## Brownfield Analysis Strategies

### Code Discovery

**Find Relevant Models**:
```bash
Glob "app/models/**/*.rb"
Glob "src/models/**/*.{js,ts}"
Glob "**/*Model.{java,kt}"
```

**Find Relevant Controllers/Services**:
```bash
Glob "app/controllers/**/*.rb"
Glob "src/controllers/**/*.{js,ts}"
Glob "src/services/**/*.{js,ts}"
```

**Find Configuration**:
```bash
Read config/database.yml
Read package.json
Read requirements.txt
Read pom.xml
```

### Pattern Detection

**Search for Existing Patterns**:
```bash
Grep "class.*Controller" --include="*.rb"
Grep "export.*Service" --include="*.ts"
Grep "@Entity" --include="*.java"
```

**Search for Similar Features**:
```bash
# If adding search feature, find existing search
Grep "search|query|find" --include="*.rb"

# If adding authentication, find existing auth
Grep "authenticate|login|session" --include="*.rb"
```

### Architecture Understanding

**Database Schema**:
```bash
Read db/schema.rb
Read migrations/*.sql
Grep "CREATE TABLE" --include="*.sql"
```

**API Endpoints**:
```bash
Grep "get|post|put|delete.*['\"]/" --include="*routes*"
Read config/routes.rb
Read src/routes/*.ts
```

**Dependencies**:
```bash
Read Gemfile
Read package.json
Read requirements.txt
```

## AskUserQuestion Patterns

### Clarifying Scope

```javascript
{
  "questions": [{
    "question": "What is the scope of this feature?",
    "header": "Scope",
    "multiSelect": false,
    "options": [
      {
        "label": "Minimal MVP",
        "description": "Core functionality only, defer enhancements"
      },
      {
        "label": "Full Featured",
        "description": "Complete feature with all enhancements"
      },
      {
        "label": "Phased Approach",
        "description": "MVP now, enhancements in future phases"
      }
    ]
  }]
}
```

### Determining Priority

```javascript
{
  "questions": [{
    "question": "What is the priority of this feature?",
    "header": "Priority",
    "multiSelect": false,
    "options": [
      {
        "label": "P1 (Must Have)",
        "description": "Critical for launch, blocks other work"
      },
      {
        "label": "P2 (Should Have)",
        "description": "Important but can defer if needed"
      },
      {
        "label": "P3 (Nice to Have)",
        "description": "Optional enhancement, low urgency"
      }
    ]
  }]
}
```

### Technology Choices

```javascript
{
  "questions": [{
    "question": "Which search technology should we use?",
    "header": "Technology",
    "multiSelect": false,
    "options": [
      {
        "label": "PostgreSQL FTS",
        "description": "Simpler, no new infrastructure, good for <100k items"
      },
      {
        "label": "Elasticsearch",
        "description": "Powerful, scalable, requires infrastructure setup"
      },
      {
        "label": "Algolia",
        "description": "Managed service, fast, cost scales with usage"
      }
    ]
  }]
}
```

### Integration Decisions

```javascript
{
  "questions": [{
    "question": "Which external integrations are required?",
    "header": "Integrations",
    "multiSelect": true,
    "options": [
      {
        "label": "JIRA",
        "description": "Create epics and stories in JIRA"
      },
      {
        "label": "Confluence",
        "description": "Publish specification to Confluence"
      },
      {
        "label": "Analytics",
        "description": "Track feature usage and metrics"
      },
      {
        "label": "None",
        "description": "No external integrations needed"
      }
    ]
  }]
}
```

## Token Optimization Strategies

### Keep in skill.md (Core)
- YAML frontmatter (name, description, tools)
- What/When/How sections (brief)
- Execution flow (overview)
- Error handling (common cases)
- Output format (examples)
- Progressive disclosure references

### Move to EXAMPLES.md
- Concrete usage scenarios (5+ examples)
- Full spec.md outputs
- Different project types (greenfield, brownfield)
- Edge cases and variations
- Before/after comparisons

### Move to REFERENCE.md
- Complete template structure
- Field definitions
- Integration specifications
- Advanced patterns
- Technical implementation details
- API schemas

### Result
- skill.md: ~1,200 tokens (core guidance)
- EXAMPLES.md: ~2,500 tokens (scenarios)
- REFERENCE.md: ~3,000 tokens (technical)
- Total: ~6,700 tokens (was ~10,000+ in monolithic design)
- Lazy loading: Only skill.md loaded initially

## Validation Checklist

Before completing Generate phase:

- [ ] Feature ID assigned (sequential, 3 digits)
- [ ] Priority set (P1/P2/P3) with rationale
- [ ] Problem statement clear (2-4 sentences)
- [ ] User stories follow format (As/I can/so that)
- [ ] Acceptance criteria specific and testable
- [ ] [CLARIFY] tags used for ambiguities
- [ ] Technical requirements documented
- [ ] Integration points identified
- [ ] Out of scope explicitly stated
- [ ] Success metrics defined
- [ ] Timeline estimated
- [ ] Workflow state files updated
- [ ] External systems synced (if configured)

## Common Pitfalls

**Too Vague**:
- Problem: "Add search feature"
- Solution: Use AskUserQuestion to gather specifics

**Scope Creep**:
- Problem: Feature grows to include 20 user stories
- Solution: Focus on P1 MVP, defer P2/P3 to future

**Missing Context**:
- Problem: Spec doesn't reference existing code
- Solution: Always analyze brownfield projects first

**Unclear Priorities**:
- Problem: Everything marked P1
- Solution: Force-rank, use 60/30/10 rule (60% P1, 30% P2, 10% P3)

**Forgotten Clarifications**:
- Problem: Assumptions made without marking [CLARIFY]
- Solution: When in doubt, add [CLARIFY] tag

## Related Skills

- **clarify phase**: Resolves [CLARIFY] tags via research or user questions
- **plan phase**: Creates technical design from specification
- **update phase**: Modifies existing specification when requirements change
- **blueprint:analyze**: Validates spec against architecture blueprint

## Skill Metadata

- **Category**: Specification & Requirements
- **Complexity**: Medium (multi-step workflow with conditionals)
- **Average Duration**: 10-30 minutes (depending on feature complexity)
- **Typical Output**: 150-400 line spec.md file
- **State Impact**: Updates 2-3 files ({config.paths.state}/, {config.paths.memory}/)
- **External Dependencies**: Optional (JIRA, Confluence via MCP)
