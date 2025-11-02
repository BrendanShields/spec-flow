---
name: spec:generate
description: Use when user wants to create specification, generate spec, define requirements, write user stories, start new feature, or says "create spec" - generates detailed feature specifications with prioritized user stories (P1/P2/P3), acceptance criteria, and integration requirements
allowed-tools: Read, Write, Edit, AskUserQuestion, WebSearch, Bash
---

# Specification Generator

Generates comprehensive feature specifications with prioritized user stories, acceptance criteria, and technical requirements.

## What This Skill Does

- Creates structured spec.md files with P1/P2/P3 prioritized user stories
- Generates acceptance criteria for each story
- Identifies and marks ambiguities with [CLARIFY] tags
- Supports both greenfield (new) and brownfield (existing codebase) projects
- Integrates with JIRA/Confluence for requirement tracking
- Analyzes existing codebase to inform specification decisions
- Updates Spec workflow state files

## When to Use

1. User requests "create a spec" or "generate specification"
2. Starting a new feature with user requirements
3. User mentions "user stories", "requirements", "acceptance criteria"
4. Need to document what to build before planning how to build it
5. Converting informal requirements into structured format
6. User says "let's define the requirements"

## Execution Flow

### Phase 1: Understand Context

**Read Project State:**
```bash
# Check if Spec is initialized
Read {config.paths.state}/current-session.md
Read {config.paths.memory}/WORKFLOW-PROGRESS.md
Read {config.paths.spec_root}/product-requirements.md (if exists)
```

**Determine Project Type:**
- Greenfield: No existing codebase, creating from scratch
- Brownfield: Existing code, adding/modifying features

**For Brownfield Projects:**
```bash
# Analyze relevant code
Glob "**/*.{js,ts,py,go,java}" to find relevant files
Read key architecture files
Grep for existing patterns related to feature
```

### Phase 2: Gather Requirements

**Ask Clarifying Questions (if needed):**

Use AskUserQuestion to resolve:
- Feature scope and boundaries
- Priority level (P1 must-have vs P2/P3 nice-to-have)
- User personas and use cases
- Integration points
- Non-functional requirements (performance, security, etc.)

**Research Best Practices (if applicable):**
```bash
# For common patterns
WebSearch "best practices for [feature type]"
WebSearch "[technology] implementation patterns"
```

### Phase 3: Structure Specification

**Create Feature Directory:**
```bash
# Determine next feature number
Bash "ls -d {config.paths.features}/[0-9]* | wc -l"

# Create directory structure
{config.paths.features}/NNN-feature-name/
├── spec.md       # This file
├── plan.md       # Created later by spec:plan
└── tasks.md      # Created later by spec:tasks
```

**Generate spec.md Content:**

Structure:
1. Feature Overview (name, ID, priority, owner)
2. Problem Statement (what problem does this solve?)
3. User Stories (P1/P2/P3 prioritized)
4. Acceptance Criteria (for each story)
5. Technical Requirements
6. Integration Points
7. Non-Functional Requirements
8. Out of Scope (what we're NOT building)
9. Open Questions ([CLARIFY] tags)

### Phase 4: Prioritize User Stories

**Apply Priority Framework:**

**P1 (Must Have):**
- Core functionality required for MVP
- Blocks other features if not implemented
- Critical user need or business requirement
- Example: "As a user, I can log in to access my account"

**P2 (Should Have):**
- Important but can defer to later iteration
- Enhances user experience significantly
- Provides competitive advantage
- Example: "As a user, I can reset my password via email"

**P3 (Nice to Have):**
- Optional enhancements
- Convenience features
- Future considerations
- Example: "As a user, I can customize my profile theme"

### Phase 5: Identify Clarifications

**Mark Ambiguities:**

Use `[CLARIFY: question]` tags for:
- Unclear requirements
- Missing acceptance criteria
- Unspecified edge cases
- Integration details needed
- Performance/scale expectations

Example:
```markdown
### US1.3: Password Reset [P2]
As a user, I can reset my forgotten password via email
so that I can regain access to my account.

**Acceptance Criteria:**
- User receives reset link within 5 minutes [CLARIFY: Email provider SLA?]
- Reset link expires after [CLARIFY: 1 hour? 24 hours?]
```

### Phase 6: Sync External Systems

**JIRA Integration (if enabled):**
```bash
# Check configuration
Read CLAUDE.md for SPEC_ATLASSIAN_SYNC
Read CLAUDE.md for SPEC_JIRA_PROJECT_KEY

# Create JIRA epic via MCP (if configured)
# Link user stories to JIRA tickets
```

**Confluence Integration (if enabled):**
```bash
# Check configuration
Read CLAUDE.md for SPEC_CONFLUENCE_ROOT_PAGE_ID

# Publish spec to Confluence page via MCP
# Update page with specification content
```

### Phase 7: Update Workflow State

**Update current-session.md:**
```markdown
## Active Work
### Current Feature
- **Feature ID**: NNN
- **Feature Name**: feature-name
- **Phase**: specification
- **Started**: {timestamp}
- **JIRA**: {epic_key} (if applicable)

## Workflow Progress
### Completed Phases
- [x] spec:init - Project initialization
- [x] spec:generate - Feature specification
- [ ] spec:clarify - Resolve ambiguities
- [ ] spec:plan - Technical design
```

**Update WORKFLOW-PROGRESS.md:**
```markdown
### Active Features
| Feature | Phase | Progress | Started | ETA | Blocked |
|---------|-------|----------|---------|-----|---------|
| NNN-feature-name | Specification | Spec created | {date} | TBD | No |
```

## Error Handling

**Missing Spec Initialization:**
- Detect: {config.paths.state}/ directory not found
- Action: Inform user to run /spec init first
- Recovery: Provide initialization command

**Incomplete Requirements:**
- Detect: User provides vague description
- Action: Use AskUserQuestion to gather specifics
- Fallback: Create spec with [CLARIFY] tags for gaps

**Existing Spec Conflict:**
- Detect: {config.paths.features}/NNN-feature-name/{config.naming.files.spec} already exists
- Action: Ask user if they want to update or create new
- Options: Update existing, create new feature, cancel

**JIRA/Confluence Sync Failure:**
- Detect: MCP integration error
- Action: Create spec locally, log sync failure
- Recovery: Provide manual sync instructions

## Output Format

**Success Message:**
```
Specification created: {config.paths.features}/NNN-feature-name/{config.naming.files.spec}

Feature: Feature Name
Priority: P1 (Must Have)
User Stories: 5 (P1: 3, P2: 1, P3: 1)
Clarifications: 2 open questions

Next steps:
1. Review spec.md and resolve [CLARIFY] tags if needed
2. Run /spec-clarify to address open questions
3. Run /spec-plan to create technical design

Files created:
- {config.paths.features}/NNN-feature-name/{config.naming.files.spec} (242 lines)

Workflow state updated:
- {config.paths.state}/current-session.md
- {config.paths.memory}/WORKFLOW-PROGRESS.md
```

**Spec.md Preview:**
```markdown
# Feature: Feature Name

**Feature ID**: NNN
**Priority**: P1 (Must Have)
**Owner**: {user}
**Created**: {date}

## Problem Statement
[What problem does this solve?]

## User Stories

### P1 (Must Have)

#### US1.1: Core Functionality
As a [persona], I can [action]
so that [benefit].

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Edge case handled

[Additional stories...]

## Open Questions
1. [CLARIFY: Question 1]
2. [CLARIFY: Question 2]
```

## Integration Points

**With Other Skills:**
- spec:clarify - Resolves [CLARIFY] tags
- spec:plan - Creates technical design from spec
- spec:update - Modifies existing specification
- blueprint:analyze - Validates against architecture

**With External Systems:**
- JIRA - Creates epic and stories
- Confluence - Publishes specification page
- GitHub - Links to issues/PRs

**State Files:**
- Reads: {config.paths.state}/current-session.md, WORKFLOW-PROGRESS.md
- Writes: {config.paths.features}/NNN-feature-name/{config.naming.files.spec}
- Updates: current-session.md, WORKFLOW-PROGRESS.md

## Templates Used

This function uses the following templates:

**Primary Template**:
- `templates/artifacts/spec-template.md` → `{config.paths.features}/###-name/{config.naming.files.spec}`

**Purpose**: Provides structure for feature specifications with user stories, acceptance criteria, and requirements

**Customization**:
1. Copy template to `{config.paths.spec_root}/templates/spec-template.md` in your project
2. Modify sections, add/remove fields as needed
3. generate/ will automatically use your custom template

**Template includes**:
- Feature overview section
- Problem statement
- User story format (P1/P2/P3)
- Acceptance criteria structure
- Technical requirements
- Integration points
- Out of scope section
- Open questions ([CLARIFY] tags)

**See also**: `templates/README.md` for complete template documentation

## Progressive Disclosure

**For Concrete Examples:** See EXAMPLES.md
**For Technical Details:** See REFERENCE.md
**For Template Structure:** See REFERENCE.md → Spec Template
**For JIRA/Confluence Sync:** See REFERENCE.md → External Integrations
