# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code marketplace plugin** that provides specification-driven development workflows for both **greenfield** and **brownfield** projects. Inspired by GitHub's spec-kit, adapted for Claude Code's Skills system with enterprise integration capabilities.

### Key Capabilities

- **Project-level specifications**: Full project specs from PRD to technical blueprint
- **Feature-level workflows**: Add features to existing projects
- **Atlassian integration**: Optional JIRA and Confluence sync
- **Dual storage**: Local GitHub repo (source of truth) + optional cloud sync
- **Flexible rigor**: From quick POCs to enterprise-grade workflows

## Architecture

### Directory Structure

```
.flow/                             # Project-level artifacts (flat peer model)
├── product-requirements.md        # Project-level PRD (WHAT to build)
├── architecture-blueprint.md      # Technical standards (HOW to build)
├── contracts/                     # Interface contracts (if API project)
│   └── openapi.yaml              # API specifications
├── data-models/
│   └── entities.md               # Domain entity definitions
├── scripts/                       # Workflow automation scripts
│   ├── common.sh                 # Shared utilities
│   ├── create-new-feature.sh     # Feature branch initialization
│   └── check-prerequisites.sh    # Validation & context gathering
├── templates/                     # Document templates
│   ├── spec-template.md
│   ├── plan-template.md
│   ├── tasks-template.md
│   ├── product-requirements-template.md
│   ├── architecture-blueprint-template.md
│   ├── openapi-template.yaml
│   ├── jira-story-template.md
│   └── confluence-page.md
└── extensions.json                # MCP integration configs

# Note: This project uses Skills (not slash commands)
# Skills are defined in plugins/flow/.claude/skills/*/SKILL.md

features/                          # Generated per-feature workspaces
└── [###-feature-name]/           # Auto-created by workflows
    ├── spec.md                    # Feature specification (with JIRA frontmatter)
    ├── plan.md                    # Implementation plan
    ├── tasks.md                   # Task breakdown
    ├── research.md                # Technical decisions
    ├── data-model.md              # Entity definitions
    ├── contracts/                 # API contracts (feature-specific)
    └── checklists/                # Quality gates
```

### Artifact Roles & Relationships (Flat Peer Model)

All `.flow/` artifacts are **peers** - no strict hierarchy or enforcement:

| Artifact | Purpose | Authority | JIRA Sync? |
|----------|---------|-----------|------------|
| `product-requirements.md` | Project vision & user stories | Local file | Yes (bidirectional, ask first) |
| `architecture-blueprint.md` | Technical standards & patterns | Local file | No (dev-only) |
| `contracts/openapi.yaml` | API contracts | Local file | No (dev-only) |
| `data-models/entities.md` | Domain entities | Local file | No (dev-only) |
| `features/###/spec.md` | Feature specification | Local file | Yes (bidirectional, ask first) |
| `features/###/plan.md` | Implementation plan | Local file | Confluence optional |

**Key Principles**:
- **Flat model**: No strict hierarchy - features CAN reference .flow/ artifacts for guidance
- **No automatic cascade**: Changing PRD doesn't auto-update features
- **Manual consistency**: Developers ensure alignment (tools help detect issues)
- **User approval**: ALL changes to .flow/ require explicit user confirmation
- **Bidirectional JIRA**: Can start from JIRA or local, sync in both directions

### Configuration (CLAUDE.md)

Configuration stored in this file (CLAUDE.md) as simple variables (see Flow Configuration section below):

```
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456
FLOW_BRANCH_PREPEND_JIRA=true
FLOW_REQUIRE_BLUEPRINT=false
FLOW_REQUIRE_ANALYSIS=false
```

**Benefits**:
- Simple text format (no JSON parsing)
- Version controlled
- Team shares same config
- Easy to enable/disable features

## Persona-Based Workflows

### 1. POC / Spike (Minimal Ceremony)

**Persona**: Senior dev exploring technical feasibility
**Goal**: Quick validation, throwaway code acceptable
**Timeline**: Hours to days

**Workflow**:
```
flow:specify "Quick POC for [idea]" --skip-validation
  → Creates lightweight spec, no clarification markers
  → Optional: flow:plan --minimal
  → Optional: flow:tasks --simple
flow:implement --skip-checklists
```

**Skip**: Constitution, clarify, analyze, checklists
**Keep**: Basic spec (documents what you're testing), minimal tasks

---

### 2. Solo Developer - Greenfield

**Persona**: Individual building new project
**Goal**: Build correctly from start, maintainable long-term
**Timeline**: Weeks to months

**First time** (project setup):
```
flow:init --type greenfield --integrations none
  → Creates .flow/ structure
  → Prompts for blueprint preferences

flow:blueprint
  → Interactive: Define your architecture and development principles
  → Examples: TDD vs test-later, architecture patterns, tech stack, etc.

flow:specify "Complete project description"
  → Creates project-level spec.md
  → All features as prioritized user stories

flow:clarify (optional)
  → Refine ambiguities interactively

flow:plan
  → Full technical design

flow:tasks
  → Dependency-ordered task breakdown

flow:implement
  → Execute incrementally by user story (P1, then P2, then P3...)
```

**Adding features later**:
```
flow:specify "New feature description"
  → Creates feature-level spec in features/###-name/
  → Same workflow but scoped to feature
```

---

### 3. Enterprise Team - Greenfield

**Persona**: Team with PMs, architects, compliance needs
**Goal**: Multi-person coordination, audit trail, governance
**Timeline**: Months to years

**Initial setup**:
```
flow:init --type greenfield --integrations jira,confluence
  → Prompts for JIRA project key
  → Prompts for Confluence root page ID
  → Creates config.json with integration settings

flow:blueprint
  → Team defines architecture and principles
  → Examples: Architecture patterns, security gates, code review, testing standards
  → Version controlled in .flow/architecture-blueprint.md
```

**Per feature workflow**:
```
flow:specify "Feature from product team"
  → Creates spec.md
  → Auto-creates JIRA epic
  → Syncs to Confluence under root page

flow:clarify
  → PM/stakeholder answers clarification questions
  → Updates synced to Confluence

flow:plan
  → Architect reviews plan.md
  → Constitution compliance validated

flow:analyze
  → Critical for multi-person teams
  → Catches inconsistencies before implementation

flow:checklist --type security,compliance
  → Quality gates for regulated industries

flow:implement
  → Branch named: {JIRA-123}-{short-name}
  → Task completion synced to JIRA
```

**Config**: `workflowDefaults.requireAnalysis: true`

---

### 4. Brownfield - Discovery & Documentation

**Persona**: New team member or consultant
**Goal**: Understand existing system, document current state
**Timeline**: Days to weeks of discovery

**Workflow**:
```
flow:init --type brownfield
  → Prompts: "Analyze codebase before proceeding?"

[Codebase analysis phase - not yet implemented]
  → Reads existing code
  → Generates AS-IS documentation
  → Extracts implicit architecture patterns
  → Creates baseline spec.md for current system

flow:constitution --extract
  → Infers constitution from existing patterns
  → Examples: Existing test coverage style, library structure
  → User reviews and approves

[Then proceed with normal feature workflow]
flow:specify "New feature to add"
  → Feature spec references existing architecture
  → Constraints from brownfield analysis
```

**TODO**: Implement brownfield analysis agent that:
- Scans codebase structure
- Identifies patterns (framework, architecture style)
- Generates baseline documentation
- Maps existing features to spec format

---

### 5. Brownfield - Adding Features

**Persona**: Developer on established project
**Goal**: Add capability to existing system consistently
**Timeline**: Days to weeks per feature

**Prerequisites**: Constitution already exists

**Workflow**:
```
flow:specify "New feature description"
  → Spec references existing components
  → Clarification focuses on integration points

flow:clarify
  → Questions about compatibility with existing features
  → Integration points with current architecture

flow:plan
  → Validates against existing constitution
  → Identifies reusable existing components
  → Highlights breaking changes

flow:analyze
  → Critical: checks consistency with existing specs
  → Validates against established patterns

flow:tasks
  → Tasks consider existing code structure
  → May include refactoring tasks for integration

flow:implement
  → Backward compatibility checks
  → Integration with existing features
```

**Key difference**: Constitution is READ-ONLY (use `flow:constitution` to amend if needed)

---

### 6. Spec Changes - Product Pivot

**Persona**: Team dealing with requirement changes mid-flight
**Goal**: Adjust to new direction without losing existing work
**Timeline**: Immediate adjustment needed

**Workflow**:
```
[Edit spec.md directly or use:]
flow:specify --update "Revised requirements"
  → Updates existing spec.md
  → Preserves completed work
  → Adds new user stories or adjusts priorities

flow:clarify
  → Only asks about NEW ambiguities
  → Skips already-clarified sections

flow:plan --update
  → Regenerates plan.md
  → Highlights WHAT CHANGED
  → Flags impacted components

flow:analyze
  → Critical: identifies conflicts between old and new
  → Shows orphaned tasks (no longer needed)
  → Shows new gaps (newly required work)

flow:tasks --update
  → Preserves completed tasks [X]
  → Adjusts incomplete tasks [ ]
  → Adds new tasks for changed requirements

flow:implement --resume
  → Continues from last completed task
  → Skips completed work
```

**Important**: Analyze catches inconsistencies introduced by changes

---

### 7. Spec Changes - Deadline Pressure / Scope Cut

**Persona**: Team under time pressure
**Goal**: Ship P1 functionality, defer rest
**Timeline**: Reduced timeline, need to cut scope

**Workflow**:
```
[Edit spec.md - adjust priorities]
  → Move features from P1 → P2/P3
  → Mark P2/P3 as "Future Scope"
  → Document WHY in spec (deadline, resource constraints)

flow:tasks --filter=P1
  → Regenerates tasks.md with ONLY P1 user stories
  → Clearly marks deferred work

flow:implement --mvp-only
  → Implements P1 tasks only
  → Skips polish phase
  → Minimal viable implementation

[After deadline / when resources available]
flow:tasks --filter=P2
  → Generate tasks for next priority
flow:implement --resume
  → Continue with P2 implementation
```

**Alternative - reduce polish**:
```
tasks.md: Comment out "Polish & Cross-Cutting" phase
  → Skip performance optimization
  → Skip additional logging
  → Skip nice-to-have documentation
```

---

## Command Reference

### Core Workflow Commands

| Command | Required? | When to Use | Can Skip If... |
|---------|-----------|-------------|----------------|
| `flow:constitution` | First time only | Project setup, team agreements | POC, well-established team norms |
| `flow:specify` | **Always** | Create spec (project or feature level) | Never - this is the starting point |
| `flow:clarify` | Optional | Ambiguous requirements, stakeholder input needed | Requirements very clear, solo dev |
| `flow:plan` | Recommended | Technical design needed | Trivial implementation, obvious tech choices |
| `flow:analyze` | Optional | Multi-person teams, complex changes | Solo dev, simple feature |
| `flow:tasks` | Recommended | Need structured breakdown | Very simple change (1-2 files) |
| `flow:checklist` | Optional | Quality gates, compliance needs | POC, low-risk changes |
| `flow:implement` | **Always** | Execute the work | Never - this does the implementation |

### Command Flags & Modes

**Specify**:
- `--skip-validation`: Skip quality checklist (POC mode)
- `--update`: Update existing spec instead of creating new
- `--level=project|feature`: Explicitly set scope level

**Plan**:
- `--minimal`: Skip research phase, use obvious choices
- `--update`: Regenerate plan with change highlighting

**Tasks**:
- `--filter=P1|P2|P3`: Generate tasks for specific priority only
- `--simple`: Flat task list (no phases, no story grouping)
- `--update`: Update existing tasks, preserve completed

**Implement**:
- `--skip-checklists`: Bypass checklist validation
- `--mvp-only`: Only implement P1 user stories
- `--resume`: Continue from last completed task

---

## Workflow Decision Tree

```
START
  ├─ Is this a POC/spike?
  │   └─ YES → Minimal: specify → implement (skip everything else)
  │
  ├─ Is this a new project?
  │   └─ YES → Is it greenfield or brownfield?
  │       ├─ Greenfield → Full workflow with constitution
  │       └─ Brownfield → Discovery first, then feature workflow
  │
  ├─ Are you adding to existing project?
  │   └─ YES → Feature workflow (skip constitution)
  │
  ├─ Are requirements changing?
  │   └─ YES → Update workflow with analyze step
  │
  └─ Are you under deadline pressure?
      └─ YES → Priority-filtered workflow (P1 only)
```

---

## Key Conventions

### User Story Priority System

User stories MUST be prioritized as P1, P2, P3... where:
- **P1** = MVP / highest value / most critical / must ship
- **P2** = Important but can defer
- **P3** = Nice to have / future scope
- Each story is **independently testable** and deliverable
- Stories can be implemented and deployed separately

### Task Format Requirements

```
- [ ] T### [P] [US#] Description with absolute file path
```

- `T###` = Sequential task ID (T001, T002...)
- `[P]` = Parallelizable marker (optional, different files/no dependencies)
- `[US#]` = User story label (US1, US2...) - required for story phases
- Absolute file paths required for all code tasks

### Bash Script Conventions

All `.flow/scripts/*.sh` scripts:
- Use `--json` flag for parseable output
- Run from repository root
- Return JSON with keys: FEATURE_DIR, SPEC_FILE, BRANCH_NAME, etc.
- Single quotes in arguments: use `'I'\''m Groot'` or double quotes

### Branch Naming

**Without JIRA**:
```
###-short-feature-name
```

**With JIRA integration**:
```
PROJ-123-short-feature-name
```

**Directory Naming**: Always sequential `features/###-name/` (JIRA ID in frontmatter)
**Git Branch Naming**: Prepends JIRA ID if linked: `PROJ-123-name`

---

## Architecture Blueprint Philosophy

The architecture blueprint (`.flow/architecture-blueprint.md`) defines **HOW** you build:

- **POC**: Skip or use minimal version (throwaway code)
- **Solo greenfield**: Your personal architecture decisions and standards
- **Team greenfield**: Team agreements on patterns, stack, and practices
- **Brownfield**: Document existing architecture first, then evolve

**Scope**: Broader than old "constitution" concept:
- Core development principles (was constitution)
- Architecture patterns (NEW)
- Technology stack standards (NEW)
- API design guidelines (NEW)
- Data modeling guidelines (NEW)
- Security, performance, testing guidelines (NEW)

**Relationship to features**:
- Flat peer model - features CAN reference for guidance
- NOT strictly enforced - manual consistency
- Deviations require user approval and documentation

**Example content**:
- "Modular monolith architecture"
- "React + Node.js stack"
- "REST APIs with OpenAPI 3.0, URI versioning"
- "PostgreSQL with UUID primary keys"
- "TDD recommended" vs "Tests required but not TDD"

---

## Flow Configuration

### Feature Toggles

The Flow plugin can be configured using variables in this CLAUDE.md file. Skills read these at runtime to adapt their behavior.

```
FLOW_ATLASSIAN_SYNC=enabled          # Enable JIRA/Confluence integration
FLOW_JIRA_PROJECT_KEY=PROJ           # Your JIRA project key
FLOW_CONFLUENCE_ROOT_PAGE_ID=123456  # Confluence parent page ID
FLOW_BRANCH_PREPEND_JIRA=true        # Prepend JIRA ID to branches
```

### Workflow Defaults

```
FLOW_REQUIRE_BLUEPRINT=false         # Enforce blueprint check (flat model - not enforced)
FLOW_REQUIRE_ANALYSIS=false          # Run analyze before implement
FLOW_REQUIRE_CHECKLISTS=false        # Quality gate checklists
FLOW_TESTS_REQUIRED=false            # Block if tests missing
```

### Story Format

```
FLOW_STORY_FORMAT=bdd                # Use BDD (Given/When/Then) format
```

### How Configuration Works

1. **Skills read CLAUDE.md** - When a skill runs, it reads this file to check configuration
2. **Simple enable/disable** - Change `enabled` to `disabled` to turn off features
3. **Version controlled** - Team shares same configuration via git
4. **Project-specific** - Each project can have different settings

### Setting Up Atlassian Integration

The Flow plugin includes the Atlassian MCP server by default (configured in `plugins/flow/.mcp.json`). To enable integration:

1. **Authenticate with Atlassian**:
   - The MCP uses SSO authentication
   - Run any Flow skill that needs Atlassian (e.g., `flow:specify`)
   - You'll be prompted to authenticate via browser

2. **Configure Flow**:
   - Set `FLOW_ATLASSIAN_SYNC=enabled` in this section
   - Set your `FLOW_JIRA_PROJECT_KEY` (e.g., "PROJ")
   - Set your `FLOW_CONFLUENCE_ROOT_PAGE_ID` (get from Confluence page URL)

3. **Use Flow normally**:
   - `flow:specify` will create JIRA stories
   - `flow:plan` will sync to Confluence
   - `flow:tasks` will create JIRA subtasks
   - `flow:implement` will update JIRA status

---

## Atlassian Integration

### When to Enable

✅ **Enable if**:
- Multiple stakeholders need visibility
- Audit trail required (compliance, enterprise)
- Team uses JIRA for sprint planning
- Documentation must be in Confluence

❌ **Skip if**:
- Solo developer
- Small team with GitHub-only workflow
- POC / experimental work
- No organizational JIRA/Confluence instance

### How It Works (Bidirectional Hybrid)

**Two Entry Points**:
1. **Start from JIRA**: `flow:specify "https://jira.../PROJ-123"` pulls JIRA story into local spec
2. **Start from Local**: `flow:specify "Feature description"` can create JIRA story (asks first)

**Bidirectional Sync**:
- Can update in either direction
- User approval ALWAYS required before syncing TO JIRA
- Local file is source of truth, JIRA is visibility/tracking layer

**Traceability**:
- JIRA ID stored in `spec.md` frontmatter: `jira_id: PROJ-123`
- Git branch prepends JIRA ID: `PROJ-123-feature-name`
- Directory stays sequential: `features/001-feature-name/`

**What Syncs**:
- `flow:specify` → Create/update JIRA stories (asks first)
- `flow:plan` → Sync to Confluence (optional)
- `flow:tasks` → Create JIRA subtasks (optional)
- `flow:sync --to-jira` → Push local changes to JIRA (asks first)
- `flow:sync --from-jira PROJ-123` → Pull JIRA changes (shows diff, asks first)

---

## Quality Checklist Philosophy

Checklists are "**Unit Tests for Requirements Writing**":

✅ **Test requirements quality**:
- "Are error handling requirements defined for all API failure modes?"
- "Is 'fast loading' quantified with specific timing thresholds?"
- "Are accessibility requirements specified for all interactive elements?"

❌ **NOT implementation verification**:
- "Verify the button clicks correctly"
- "Test error handling works"
- "Confirm the API returns 200"

**When to use**:
- Enterprise projects (compliance, security)
- Complex domains (healthcare, finance, etc.)
- Team handoffs (QA, architecture review)

**When to skip**:
- POC / spike work
- Internal tools
- Well-understood domains

---

## Migration & Evolution

### From POC to Production

```
1. Started as POC (minimal workflow)
2. POC validated, now productionizing
3. Add rigor incrementally:

flow:constitution --create
  → Define production standards

flow:specify --update --add-validation
  → Add missing requirements, edge cases

flow:clarify
  → Fill gaps from quick POC

flow:plan --full
  → Proper architecture (replace hacky POC plan)

flow:analyze
  → Find POC shortcuts that need fixing

flow:checklist --type security,performance
  → Add production gates

flow:implement --refactor
  → Rebuild with proper practices
```

### From Feature to Platform

When your project grows beyond initial scope:

```
1. Review all features/*/spec.md
2. Create project-level spec.md aggregating patterns
3. Extract shared constitution
4. Update config.json for platform needs
5. Add governance (analyze required, checklists for all features)
```

---

## Error Handling & Recovery

### Common Issues

**"Prerequisites not met"**:
- Run `check-prerequisites.sh --json` to see what's missing
- Follow suggested command to resolve

**"Constitution violation"** (CRITICAL):
- Cannot bypass - must fix spec/plan/tasks OR
- Update constitution if principle itself is wrong

**"Checklist incomplete"**:
- Review failed checklist items
- Update spec to address issues OR
- Approve proceeding anyway (not recommended)

**"Tasks out of sync with spec"**:
- Re-run `flow:analyze` to identify issues
- Re-run `flow:tasks` to regenerate from updated spec

---

## Future Capabilities (Planned)

### Brownfield Analysis Agent
- Automated codebase scanning
- Pattern extraction
- AS-IS documentation generation
- Baseline spec creation

### Skills System Migration
- Converting slash commands to Claude Code Skills
- Enhanced agent capabilities
- Cross-skill orchestration

### Advanced Integrations
- GitHub Projects sync
- Linear integration
- Asana support
- Custom webhook integrations

---

## Quick Start Examples

**Simplest possible (POC)**:
```bash
flow:specify "Quick test of X" --skip-validation
flow:implement --skip-checklists
```

**Solo developer (proper)**:
```bash
flow:init --type greenfield
flow:constitution
flow:specify "Full project description"
flow:plan
flow:tasks
flow:implement
```

**Enterprise (full rigor)**:
```bash
flow:init --type greenfield --integrations jira,confluence
flow:constitution
flow:specify "Feature from product"
flow:clarify
flow:plan
flow:analyze
flow:checklist --type security,compliance,ux
flow:implement
```

**Existing project (add feature)**:
```bash
flow:specify "New feature description"
flow:clarify
flow:plan
flow:tasks
flow:implement
```
