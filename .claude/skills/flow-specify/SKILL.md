---
name: flow:specify
description: Create detailed specifications from requirements. Use when 1) Starting new feature development, 2) User says "create/add/build feature", 3) Converting requirements to technical specs, 4) Pulling JIRA story into local spec, 5) Need prioritized user stories with acceptance criteria. Creates spec.md with P1/P2/P3 stories.
allowed-tools: Bash, Write, Read, Edit, Task
---

# Flow Specify

Generate complete, high-quality specifications from natural language with minimal clarifications needed.

## Core Workflow

### 1. Setup & Context

Generate feature branch and load context:
- Create short branch name (2-4 words, kebab-case)
- Load project architecture blueprint (if exists)
- Detect project domain from description
- Load domain-specific templates

### 2. AI-Powered Generation

Invoke `flow-researcher` subagent to:
- Analyze description for requirements
- Research similar implementations
- Apply industry best practices
- Generate complete specification content

### 3. Smart Inference

Apply intelligent defaults based on:
- **Project Type**: Greenfield vs brownfield
- **Domain**: E-commerce, SaaS, API, Real-time, etc.
- **Patterns**: Common requirements for domain
- **Blueprint**: Existing project principles (if available)

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

## MCP Integration (Atlassian)

If `FLOW_ATLASSIAN_SYNC=enabled` in CLAUDE.md:

**After spec generation**:
1. Create JIRA epic for feature
2. Create JIRA stories from each user story (P1, P2, P3)
3. Sync to Confluence page under root page ID
4. Store JIRA IDs in spec.md frontmatter
5. Link spec, JIRA, and Confluence bidirectionally

**Bidirectional sync**:
- Can start from JIRA: `flow:specify "https://jira.../PROJ-123"`
- Can start from local: Creates JIRA if enabled (asks first)
- Updates sync in both directions (with approval)
- Local file is source of truth

**What syncs**:
```javascript
// JIRA epic + stories
await mcp.jira.createIssue({
  projectKey: config.FLOW_JIRA_PROJECT_KEY,
  issueType: 'Epic',
  summary: featureName,
  description: featureSummary
});

// Confluence page
await mcp.confluence.createPage({
  parentId: config.FLOW_CONFLUENCE_ROOT_PAGE_ID,
  title: `${featureNumber} - ${featureName}`,
  body: confluenceContent
});
```

## Domain Detection

Automatically detects and applies patterns:

| Domain | Indicators | Auto-Generated |
|--------|-----------|----------------|
| E-commerce | cart, checkout, payment, product | Payment flows, inventory, orders |
| SaaS | subscription, tenant, billing | Multi-tenancy, subscriptions, usage |
| API | endpoint, rest, graphql | Versioning, rate limiting, auth |
| Real-time | websocket, live, streaming | Connection handling, sync patterns |
| Analytics | dashboard, metrics, charts | Data aggregation, visualizations |
| Fintech | transaction, kyc, compliance | Security, audit, regulatory |

## Command Flags

**`--skip-validation`**
Skip quality checklist (POC mode)

**`--update`**
Update existing spec instead of creating new

**`--level=project|feature`**
Explicitly set scope level

## Configuration

Respects config in CLAUDE.md:
```markdown
FLOW_AI_INFERENCE_LEVEL=moderate  # minimal|moderate|aggressive
FLOW_AUTO_RESEARCH=true
FLOW_DOMAIN_DETECTION=true
FLOW_AUTO_VALIDATION=true
FLOW_MAX_CLARIFICATIONS=3
```

## Examples

See [examples.md](./examples.md) for:
- Quick POC (aggressive inference)
- Enterprise feature (full rigor)
- Brownfield addition
- Pulling from JIRA
- Updating existing spec

## Reference

See [reference.md](./reference.md) for:
- Hooks integration details
- Complete configuration options
- Domain detection patterns
- MCP sync strategies
- Subagent invocation details

## Phase Transition (Optional)

After successfully creating the specification, check if interactive transitions are enabled:

```bash
source .flow/scripts/config.sh

if should_prompt_transitions; then
  # Show transition prompt using AskUserQuestion
fi
```

**If transitions enabled**, use AskUserQuestion to ask what to do next:

```json
{
  "questions": [{
    "question": "Specification complete! What would you like to do next?",
    "header": "Next Step",
    "multiSelect": false,
    "options": [
      {
        "label": "Create Plan",
        "description": "Design technical architecture (flow:plan)"
      },
      {
        "label": "Review Spec",
        "description": "Review the specification first"
      },
      {
        "label": "Validate Spec",
        "description": "Check specification quality (flow:analyze)"
      },
      {
        "label": "Exit",
        "description": "Continue later"
      }
    ]
  }]
}
```

**Action based on selection**:
- "Create Plan" → Automatically invoke flow:plan skill
- "Review Spec" → Exit, let user review the spec.md file
- "Validate Spec" → Automatically invoke flow:analyze skill
- "Exit" → Exit gracefully
- "Other" → Ask what command they want to run

## Related Skills

- **flow:clarify**: Resolve spec ambiguities (run after if needed)
- **flow:plan**: Generate technical plan from spec (run next)
- **flow:analyze**: Validate spec consistency

## Subagents Used

- **flow-researcher**: Researches best practices, evaluates alternatives, documents decisions

## Validation

Test this skill:
```bash
scripts/validate.sh
```
