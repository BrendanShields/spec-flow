---
name: flow:specify
description: Generate comprehensive specifications from natural language using AI-powered analysis, domain detection, and intelligent defaults. Use for creating project or feature specifications.
---

# Flow Specify: AI-Powered Specification Generation

Generate complete, high-quality specifications from natural language descriptions with minimal clarifications needed.

## When to Use

- Starting a new project (greenfield)
- Adding features to existing projects (brownfield)
- Documenting requirements from stakeholder descriptions
- Creating technical specifications from product descriptions

## What This Skill Does

1. **Analyzes** your natural language description
2. **Detects** project domain (e-commerce, SaaS, API, etc.)
3. **Researches** best practices using the `flow-researcher` subagent
4. **Generates** complete specification with:
   - Prioritized user stories (P1, P2, P3)
   - Functional requirements
   - Success criteria
   - Edge cases
   - Key entities
5. **Validates** quality automatically
6. **Asks** only critical clarifications (max 3)

## Execution Steps

### 1. Setup & Context Loading
- Generate short branch name (2-4 words, kebab-case)
- Create feature branch
- Load project constitution (if exists)
- Detect project domain from description
- Load domain-specific templates

### 2. AI-Powered Generation
**Invoke `flow-researcher` subagent** to:
- Analyze description for requirements
- Research similar implementations
- Apply industry best practices
- Generate complete specification content

### 3. Smart Inference
Apply intelligent defaults based on:
- **Project Type**: Greenfield vs brownfield detection
- **Domain**: E-commerce, SaaS, API, Real-time, etc.
- **Patterns**: Common requirements for detected domain
- **Constitution**: Existing project principles

### 4. User Story Prioritization
Automatically assign priorities:
- **P1**: MVP / Core functionality / Critical path
- **P2**: Important enhancements / Integrations
- **P3**: Nice-to-have / Polish / Advanced features

Each story includes:
- Independent test criteria
- Clear value proposition
- Acceptance scenarios (Given-When-Then)

### 5. Quality Validation
Unless `--skip-validation`:
- Generate requirements checklist
- Validate completeness, clarity, testability
- Auto-fix common issues (up to 3 iterations)
- Mark remaining ambiguities for clarification

### 6. Interactive Clarification
If critical ambiguities remain (max 3):
- Present question with recommended answer
- Provide 3-5 options with implications
- User accepts recommendation or provides custom answer
- Update specification with chosen answer

## Output Structure

```markdown
# Feature Specification: [Name]

**Feature Branch**: `001-feature-name`
**Domain**: [Detected domain]
**AI-Generated**: [Percentage]%

## User Scenarios & Testing (Prioritized)

### User Story 1 - [Title] (Priority: P1)
[Independent, testable user journey]

**Why P1**: [Value justification]
**Independent Test**: [How to test in isolation]
**Acceptance Scenarios**:
- Given [state], When [action], Then [outcome]

## Functional Requirements
- **FR-001**: System MUST [capability]

## Success Criteria
- [Measurable, technology-agnostic outcomes]

## Key Entities
- **[Entity]**: [Purpose and attributes]

## Edge Cases
- [Boundary conditions and error scenarios]
```

## Domain Detection

Automatically detects and applies patterns for:

| Domain | Indicators | Auto-Generated |
|--------|-----------|----------------|
| E-commerce | cart, checkout, payment, product | Payment flows, inventory, orders |
| SaaS | subscription, tenant, billing | Multi-tenancy, subscriptions, usage |
| API | endpoint, rest, graphql | Versioning, rate limiting, auth |
| Real-time | websocket, live, streaming | Connection handling, sync patterns |
| Analytics | dashboard, metrics, charts | Data aggregation, visualizations |
| Fintech | transaction, kyc, compliance | Security, audit, regulatory |

## Hooks Integration

**Pre-specify** (`before:flow:specify`):
- Validates project initialization
- Loads domain templates
- Prepares research context
- Detects brownfield patterns

**Post-specify** (`after:flow:specify`):
- Auto-triggers clarification if needed
- Updates project index
- Syncs with JIRA/Confluence (if configured)
- Records telemetry

## Configuration

Respects `.claude/flow/config.json`:

```json
{
  "ai": {
    "inferenceLevel": "moderate",  // minimal | moderate | aggressive
    "autoResearch": true,
    "domainDetection": true
  },
  "quality": {
    "autoValidation": true,
    "maxClarifications": 3
  },
  "workflow": {
    "projectType": "greenfield"  // or "brownfield"
  }
}
```

## Examples

**Quick POC** (aggressive inference):
```
User: flow:specify "Test Redis caching for session storage"
→ Generates minimal spec, no clarifications, ready to implement
```

**Enterprise Feature** (full rigor):
```
User: flow:specify "Payment processing system with PCI compliance"
→ Detects fintech domain
→ Researches PCI requirements
→ Asks 3 critical security questions
→ Generates comprehensive spec with compliance checklist
```

**Brownfield Addition**:
```
User: flow:specify "Add OAuth2 to existing authentication"
→ Analyzes existing auth code
→ Generates spec compatible with current patterns
→ Highlights integration points
```

## Related Skills

- **flow:clarify**: Resolve specification ambiguities interactively
- **flow:plan**: Generate technical implementation plan from spec
- **flow:analyze**: Validate specification consistency

## Tips for Best Results

1. **Be descriptive**: More context = better inference
2. **Mention domain**: "e-commerce site" helps domain detection
3. **State priorities**: "MVP should include X, Y later" guides prioritization
4. **Reference existing**: "Like Stripe's API" provides patterns
5. **Skip validation for POCs**: Add `--skip-validation` for speed

## Subagents Used

- **flow-researcher**: Researches best practices, evaluates alternatives, documents decisions