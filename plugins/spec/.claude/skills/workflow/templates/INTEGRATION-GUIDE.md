# Template Integration Guide

**Purpose**: Maps workflow templates to the functions that use them, explains auto-loading behavior, and documents the customization process.

**Audience**: Developers using the spec workflow who want to understand or customize templates

**Version**: 3.0 | **Last Updated**: 2025-11-02

---

## Overview

### What Are Templates?

Templates are pre-structured markdown files that provide consistent formatting for workflow artifacts. They contain:
- **Sections**: Organized content areas (Overview, Requirements, etc.)
- **Placeholders**: Variables like `{FEATURE_ID}`, `{DATE}` replaced during generation
- **Examples**: Inline guidance showing what to include
- **Structure**: Standardized hierarchy for readability and tooling

### Why Templates Exist

1. **Consistency**: Every feature follows same specification format
2. **Completeness**: Templates prompt for all necessary sections
3. **Integration**: Standard structure enables tooling (JIRA sync, validation)
4. **Efficiency**: Pre-written structure reduces cognitive load
5. **Customization**: Projects can adapt templates to their standards

### How the Workflow Uses Templates

When you run workflow commands like `/spec generate`, the system:
1. Checks for custom template in `{config.paths.spec_root}/templates/[template-name]`
2. Falls back to plugin default in `workflow/templates/`
3. Loads template content
4. Replaces placeholders with actual values
5. Writes output to target location (e.g., `{config.paths.features}/###-name/{config.naming.files.spec}`)

### Template Categories

- **artifacts/**: Core 3-file workflow (spec, plan, tasks)
- **project-setup/**: One-time initialization (product requirements, architecture)
- **quality/**: Validation and review (checklists)
- **integrations/**: External system formats (JIRA, Confluence, OpenAPI)
- **internal/**: Framework internals (agent context files)

---

## Template-Function Mapping

### Core Workflow Templates (artifacts/)

#### spec-template.md

**Used by**: `generate phase` (Phase 2: Define Requirements)

**Output**: `{config.paths.features}/###-feature-name/{config.naming.files.spec}`

**Auto-loaded**: Yes (every time generate/ runs)

**Purpose**: Feature specification with user stories, acceptance criteria, and requirements

**Variables**:
- `{FEATURE_ID}` - Feature number (e.g., 003)
- `{FEATURE_NAME}` - Feature name (kebab-case)
- `{DATE}` - Current date (YYYY-MM-DD)
- `{JIRA_ID}` - JIRA epic key (if integration enabled)
- `{JIRA_URL}` - JIRA epic URL (if integration enabled)
- `{BRANCH_NAME}` - Git branch name (derived from feature ID/name)

**Customization**:
```bash
# Copy to your project
cp workflow/templates/artifacts/spec-template.md {config.paths.spec_root}/templates/spec-template.md

# Edit sections, add project-specific requirements
# generate/ will automatically use your version
```

**Template sections**:
- Frontmatter (feature metadata, JIRA links)
- Feature overview
- Epics and user stories (P1/P2/P3 prioritization)
- Acceptance criteria (Given/When/Then format)
- Edge cases
- Functional requirements
- Key entities
- Success criteria
- JIRA integration configuration

---

#### plan-template.md

**Used by**: `plan phase` (Phase 3: Design Solution)

**Output**: `{config.paths.features}/###-feature-name/{config.naming.files.plan}`

**Auto-loaded**: Yes (when plan/ runs)

**Purpose**: Technical design with architecture decisions, data models, and implementation strategy

**Variables**:
- `{FEATURE_ID}` - Feature number
- `{FEATURE_NAME}` - Feature name
- `{BRANCH_NAME}` - Git branch name
- `{DATE}` - Current date
- `{SPEC_PATH}` - Path to spec.md (for reference)

**Customization**:
```bash
# Copy template
cp workflow/templates/artifacts/plan-template.md {config.paths.spec_root}/templates/plan-template.md

# Add sections for your architecture standards
# E.g., add "Observability Strategy" section
```

**Template sections**:
- Summary (high-level approach)
- Technical context (language, dependencies, platform)
- Project artifacts (references to blueprints, contracts)
- Blueprint alignment (architecture pattern adherence)
- Project structure (source code organization)
- {config.paths.spec_root}/ updates (approval workflow for shared docs)

**Research integration**: This template works with the `spec:researcher` agent to include research-backed decisions.

---

#### tasks-template.md

**Used by**: `tasks phase` (Phase 4: Build Feature)

**Output**: `{config.paths.features}/###-feature-name/{config.naming.files.tasks}`

**Auto-loaded**: Yes (when tasks/ runs)

**Purpose**: Executable task breakdown with dependencies and GitHub issue tracking

**Variables**:
- `{FEATURE_ID}` - Feature number
- `{FEATURE_NAME}` - Feature name
- `{DATE}` - Current date

**Customization**:
```bash
# Copy template
cp workflow/templates/artifacts/tasks-template.md {config.paths.spec_root}/templates/tasks-template.md

# Customize task naming conventions (e.g., ST-Epic.Story.Task)
# Add team-specific tracking fields
```

**Template sections**:
- Frontmatter (task organization metadata)
- Tracking guidelines (GitHub issues, external trackers)
- Epic/Story/Sub-task hierarchy
- Acceptance criteria summary per story
- Sub-task checklists
- Completion checklist

**Special features**:
- Epic/Story/Sub-task naming: `ST-[Epic#].[Story#].[Sequence]`
- GitHub issue integration (every story → issue with checklist)
- External tracker support (JIRA, etc.)

---

### Project Setup Templates (project-setup/)

#### product-requirements-template.md

**Used by**: `initialize phase` (Phase 1: Initialize)

**Output**: `{config.paths.spec_root}/product-requirements.md`

**Auto-loaded**: Yes (during init/)

**Purpose**: High-level product vision, success metrics, and business goals

**Variables**:
- `{PROJECT_NAME}` - Project name (from git repo or user input)
- `{DATE}` - Current date

**Customization**:
```bash
# After init, edit directly
nano {config.paths.spec_root}/product-requirements.md

# Or replace template before init
cp your-prd-template.md {config.paths.spec_root}/templates/product-requirements-template.md
```

**Template sections**:
- Vision (problem solved, target users)
- Business goals
- User personas
- Epics and user stories (project-level)
- Key entities
- Cross-cutting requirements (security, performance, etc.)
- Success criteria
- Out of scope
- Constraints and assumptions
- Dependencies
- Glossary

**Reference**: This file is referenced by all features for alignment.

---

#### architecture-blueprint-template.md

**Used by**: `blueprint phase` (Phase 1: Initialize - optional)

**Output**: `{config.paths.spec_root}/architecture-blueprint.md`

**Auto-loaded**: Only when blueprint/ is explicitly run

**Purpose**: Project-wide architecture standards and technical decisions

**Variables**:
- `{PROJECT_NAME}` - Project name
- `{DATE}` - Current date

**Customization**:
```bash
# Run blueprint/ to create from template
/spec blueprint

# Then edit
nano {config.paths.spec_root}/architecture-blueprint.md

# Or pre-customize template
cp workflow/templates/project-setup/architecture-blueprint-template.md {config.paths.spec_root}/templates/
```

**Template sections**:
- Tech stack decisions
- Design patterns and conventions
- API design standards
- Data modeling conventions
- Security guidelines
- Performance requirements
- ADR (Architecture Decision Record) framework
- Integration patterns

**Validation**: `plan phase` checks alignment with blueprint and flags deviations for approval.

---

### Quality Templates (quality/)

#### checklist-template.md

**Used by**: `checklist phase` (Phase 2: Define Requirements - optional)

**Output**: `{config.paths.features}/###-feature-name/checklists/[type].md`

**Auto-loaded**: When checklist/ is explicitly run

**Purpose**: Domain-specific quality validation checklists (UX, API, security, performance)

**Variables**:
- `{CHECKLIST_TYPE}` - Type of checklist (UX, API, Security, Performance)
- `{FEATURE_NAME}` - Feature name
- `{DATE}` - Current date
- `{FEATURE_PATH}` - Path to spec.md

**Customization**:
```bash
# Copy template
cp workflow/templates/quality/checklist-template.md {config.paths.spec_root}/templates/checklist-template.md

# Add team-specific checklist items
# E.g., "Accessibility WCAG 2.1 AA compliance"
```

**Dynamic generation**: Unlike other templates, checklist items are generated based on:
- Feature requirements from spec.md
- Technical context from plan.md
- User's specific checklist request

**Template provides**:
- Category structure
- Checkbox format (`- [ ] CHK001 Item description`)
- Notes section for findings
- Sequential numbering for traceability

---

### Integration Templates (integrations/)

#### jira-story-template.md

**Used by**: `generate phase` (when JIRA integration enabled)

**Output**: JIRA story via MCP API (not a file)

**Auto-loaded**: Only if `SPEC_ATLASSIAN_SYNC=enabled` in claude.md

**Purpose**: JIRA-compatible user story format with story points, epic links, and labels

**Variables**:
- `{EPIC_KEY}` - JIRA epic key (e.g., PROJ-123)
- `{STORY_TITLE}` - User story title
- `{STORY_POINTS}` - Estimated story points
- `{PRIORITY}` - JIRA priority (P1/P2/P3 mapped to High/Medium/Low)
- `{LABELS}` - JIRA labels (comma-separated)

**Configuration**:
```markdown
# In claude.md
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
```

**Customization**: Modify template to match your JIRA custom fields:
```bash
cp workflow/templates/integrations/jira-story-template.md {config.paths.spec_root}/templates/
# Edit to add custom fields like "Sprint", "Team", etc.
```

---

#### confluence-page.md

**Used by**: Any workflow function with `--publish-confluence` flag

**Output**: Confluence page via MCP API

**Auto-loaded**: Only if Confluence integration enabled and `--publish-confluence` flag used

**Purpose**: Confluence documentation page template with markup and page hierarchy

**Variables**:
- `{PAGE_TITLE}` - Confluence page title
- `{PARENT_PAGE_ID}` - Parent page ID (from config)
- `{CONTENT}` - Converted markdown content

**Configuration**:
```markdown
# In claude.md
SPEC_ATLASSIAN_SYNC=enabled
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
```

**Customization**: Add Confluence-specific macros or formatting:
```bash
cp workflow/templates/integrations/confluence-page.md {config.paths.spec_root}/templates/
# Add macros like {status}, {info}, etc.
```

---

#### openapi-template.yaml

**Used by**: `plan phase` (when API design detected)

**Output**: `{config.paths.features}/###-feature-name/openapi.yaml`

**Auto-loaded**: Only when plan/ detects API endpoints in requirements

**Purpose**: OpenAPI 3.0 specification for API documentation and contract testing

**Variables**:
- `{API_TITLE}` - API title (derived from feature name)
- `{API_VERSION}` - API version (e.g., 1.0.0)
- `{DESCRIPTION}` - API description

**Customization**:
```bash
cp workflow/templates/integrations/openapi-template.yaml {config.paths.spec_root}/templates/

# Add standard headers, authentication schemes
# Customize schema definitions
```

**Validation**: Can be validated with Swagger Editor or openapi-validator tools.

---

### Internal Templates (internal/)

#### agent-file-template.md

**Used by**: Subagent delegation (implement phaseer, spec:researcher, analyze phaser)

**Output**: `{config.paths.state}/agent-context.md` (temporary)

**Auto-loaded**: Automatically when delegating to subagents

**Purpose**: Context file for subagent delegation with task constraints and expected output format

**Variables**:
- `{AGENT_NAME}` - Agent name (implementer, researcher, analyzer)
- `{TASK_DESCRIPTION}` - Task to perform
- `{CONSTRAINTS}` - Constraints and requirements
- `{OUTPUT_FORMAT}` - Expected output format

**Customization**: Not typically customized (internal use), but can be modified for custom agents:
```bash
cp workflow/templates/internal/agent-file-template.md {config.paths.spec_root}/templates/
# Modify for custom delegation patterns
```

**Lifecycle**: Created before delegation, deleted after subagent completes.

---

## Auto-Loading vs Manual Templates

### Auto-Loaded Templates

These are loaded **automatically** when their associated function runs:

| Template | Function | Trigger |
|----------|----------|---------|
| spec-template.md | generate phase | Every `/spec generate` or `/spec "Feature"` |
| plan-template.md | plan phase | Every `/spec plan` |
| tasks-template.md | tasks phase | Every `/spec tasks` |
| product-requirements-template.md | initialize phase | One-time during `/spec init` |
| agent-file-template.md | Subagent delegation | Automatic when delegating tasks |

**No flags required** - these load by default.

### Manual/Conditional Templates

These load **only when explicitly requested** or when conditions are met:

| Template | Function | Trigger |
|----------|----------|---------|
| architecture-blueprint-template.md | blueprint phase | Explicit `/spec blueprint` |
| checklist-template.md | checklist phase | Explicit `/spec checklist` |
| jira-story-template.md | generate phase | JIRA integration enabled |
| confluence-page.md | Any | `--publish-confluence` flag |
| openapi-template.yaml | plan phase | API endpoints detected |

**Examples**:
```bash
/spec blueprint              # Loads architecture-blueprint-template.md
/spec checklist              # Loads checklist-template.md
/spec plan --publish-confluence  # Loads confluence-page.md
```

---

## Customization Process

### Step 1: Identify Template to Customize

**Find template location**:
```bash
# List all available templates
ls workflow/templates/artifacts/
ls workflow/templates/project-setup/
ls workflow/templates/quality/
ls workflow/templates/integrations/
```

**Or check this guide** under "Template-Function Mapping" above.

### Step 2: Copy to Project

**Create custom templates directory** (if not exists):
```bash
mkdir -p {config.paths.spec_root}/templates/
```

**Copy template**:
```bash
# Example: Customize spec template
cp workflow/templates/artifacts/spec-template.md {config.paths.spec_root}/templates/spec-template.md
```

### Step 3: Modify Template

**Edit with your preferred editor**:
```bash
nano {config.paths.spec_root}/templates/spec-template.md
# Or: code {config.paths.spec_root}/templates/spec-template.md
```

**Common customizations**:
- Add sections (e.g., "Compliance Requirements")
- Remove sections (e.g., remove "Out of Scope")
- Reorder sections
- Add custom placeholders
- Include team-specific guidelines

**Example addition**:
```markdown
## Compliance Requirements

**GDPR**: [Data privacy considerations]
**SOC2**: [Security controls]
**HIPAA**: [Healthcare compliance] (if applicable)
```

### Step 4: Test Customization

**Workflow auto-detects custom template**:
```bash
/spec generate "Test Feature"
# Uses {config.paths.spec_root}/templates/spec-template.md if it exists
# Falls back to workflow/templates/artifacts/spec-template.md otherwise
```

**Verify output**:
```bash
cat {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
# Check that your custom sections appear
```

### Step 5: Validate with /spec validate

**Run validation**:
```bash
/spec validate
```

**Checks**:
- All required sections present
- Placeholders replaced correctly
- Valid markdown structure
- Consistent with other artifacts

### Step 6: Version Control Custom Templates

**Add to git**:
```bash
git add {config.paths.spec_root}/templates/
git commit -m "feat: Add custom spec template with compliance section"
```

**Team consistency**: Custom templates in `{config.paths.spec_root}/templates/` are shared across team.

---

## Template Variables

### Standard Variables

Available in **all templates**:

| Variable | Example | Description |
|----------|---------|-------------|
| `{PROJECT_NAME}` | "marketplace" | Project name (from git repo) |
| `{DATE}` | "2025-11-02" | Current date (YYYY-MM-DD) |
| `{AUTHOR}` | "dev" | Git user.name or system user |

### Feature-Specific Variables

Available in **feature artifact templates** (spec, plan, tasks):

| Variable | Example | Description |
|----------|---------|-------------|
| `{FEATURE_ID}` | "003" | Zero-padded feature number |
| `{FEATURE_NAME}` | "user-authentication" | Kebab-case feature name |
| `{BRANCH_NAME}` | "feature/003-user-authentication" | Git branch name |
| `{SPEC_PATH}` | "{config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}" | Path to spec.md |

### Integration Variables

Available when **integrations are enabled**:

| Variable | Example | Description |
|----------|---------|-------------|
| `{JIRA_ID}` | "PROJ-123" | JIRA epic or story key |
| `{JIRA_URL}` | "https://company.atlassian.net/browse/PROJ-123" | JIRA issue URL |
| `{EPIC_KEY}` | "PROJ-100" | Parent epic key |
| `{CONFLUENCE_PAGE_ID}` | "123456" | Confluence page ID |

### Adding Custom Variables

**In your custom template**, add new placeholders:
```markdown
## Deployment
**Environment**: {TARGET_ENV}
**Region**: {AWS_REGION}
```

**During generation**, replace manually or via config:
```bash
# Option 1: Edit after generation
# Option 2: Add to claude.md config
SPEC_TARGET_ENV=production
SPEC_AWS_REGION=us-east-1
```

**Future enhancement**: Variable replacement can be extended in workflow functions.

---

## Template Validation Rules

### Required Sections

**spec-template.md** must include:
- Feature overview (ID, name, status)
- User stories (at least one)
- Acceptance criteria (for each story)
- Requirements (functional)

**plan-template.md** must include:
- Summary
- Technical context
- Architecture or Data model
- Implementation notes

**tasks-template.md** must include:
- Epic/Story structure
- Sub-task checklists
- Completion checklist

### Placeholder Syntax

**Valid placeholders**:
- `{VARIABLE_NAME}` - All uppercase, underscores for spaces
- `[BRACKETED_VALUE]` - Temporary placeholders (replaced during editing)

**Invalid**:
- `${VARIABLE}` - Shell syntax not supported
- `{{variable}}` - Double braces reserved for Handlebars (not used)
- `%VARIABLE%` - Windows syntax not supported

### Markdown Validation

**Templates must**:
- Use valid markdown syntax
- Start with frontmatter (---) if metadata included
- Use consistent heading levels (# → ## → ###)
- Include checkbox syntax for checklists: `- [ ]`

**Run validation**:
```bash
/spec validate
# Checks all templates for syntax errors
```

---

## Examples of Template Customization

### Example 1: Add Accessibility Section to Spec

**Original** (spec-template.md):
```markdown
## Requirements

### Functional
- **FR-001**: System MUST [capability]
```

**Customized** ({config.paths.spec_root}/templates/spec-template.md):
```markdown
## Requirements

### Functional
- **FR-001**: System MUST [capability]

### Accessibility
- **AR-001**: All interactive elements MUST have ARIA labels
- **AR-002**: Color contrast MUST meet WCAG 2.1 AA standards
- **AR-003**: Keyboard navigation MUST be fully supported
```

**Result**: Every spec.md now includes accessibility requirements section.

---

### Example 2: Add Observability to Plan Template

**Original** (plan-template.md):
```markdown
## Testing Strategy
[Unit, integration, e2e test approach]
```

**Customized** ({config.paths.spec_root}/templates/plan-template.md):
```markdown
## Testing Strategy
[Unit, integration, e2e test approach]

## Observability

**Metrics**:
- Request latency (p50, p95, p99)
- Error rate by endpoint
- Active connections

**Logging**:
- Structured JSON logs
- Log level: INFO (production), DEBUG (development)
- Correlation IDs for request tracing

**Tracing**:
- OpenTelemetry instrumentation
- Trace sampling: 10% (production), 100% (development)
- Spans for all external calls
```

**Result**: Every plan.md includes observability strategy.

---

### Example 3: Custom Task Naming Convention

**Original** (tasks-template.md):
```markdown
#### Sub Tasks
- [ ] ST-1.1.1 Prepare environment
```

**Customized** ({config.paths.spec_root}/templates/tasks-template.md):
```markdown
#### Sub Tasks
- [ ] TASK-{FEATURE_ID}-001 Prepare environment
- [ ] TASK-{FEATURE_ID}-002 Implement component
```

**Result**: Task IDs include feature number for better traceability.

---

### Example 4: JIRA Custom Fields

**Original** (jira-story-template.md):
```markdown
{
  "summary": "{STORY_TITLE}",
  "issuetype": "Story",
  "priority": "{PRIORITY}"
}
```

**Customized** ({config.paths.spec_root}/templates/jira-story-template.md):
```markdown
{
  "summary": "{STORY_TITLE}",
  "issuetype": "Story",
  "priority": "{PRIORITY}",
  "customfield_10001": "{TEAM_NAME}",
  "customfield_10002": "{SPRINT_ID}",
  "labels": ["spec-workflow", "automated"]
}
```

**Result**: JIRA stories include team and sprint information.

---

## Best Practices

### Don't Modify Plugin Templates Directly

**❌ Don't**:
```bash
# Bad: Editing plugin templates directly
nano workflow/templates/artifacts/spec-template.md
# This breaks on plugin updates
```

**✅ Do**:
```bash
# Good: Copy to project and customize
cp workflow/templates/artifacts/spec-template.md {config.paths.spec_root}/templates/
nano {config.paths.spec_root}/templates/spec-template.md
```

**Why**: Plugin updates overwrite workflow templates. Your customizations should live in `{config.paths.spec_root}/templates/`.

---

### Keep Custom Templates in {config.paths.spec_root}/templates/

**Project structure**:
```
{config.paths.spec_root}/
├── templates/               ← Your customizations here
│   ├── spec-template.md
│   ├── plan-template.md
│   └── custom-checklist.md
├── product-requirements.md
└── architecture-blueprint.md
```

**Git tracking**:
```bash
# Commit custom templates
git add {config.paths.spec_root}/templates/
git commit -m "docs: Add custom templates for team standards"
```

---

### Document Customizations

**Add README to {config.paths.spec_root}/templates/**:
```markdown
# Custom Templates

## Modifications

### spec-template.md
- Added "Accessibility Requirements" section (AR-xxx numbering)
- Added "Compliance" section for GDPR/SOC2

### plan-template.md
- Added "Observability Strategy" with metrics/logging/tracing
- Added "Deployment Checklist"

## Team Standards

All specs must include:
- Accessibility requirements (AR-xxx)
- Compliance considerations
- Observability strategy in plans
```

---

### Version Control Custom Templates

**Track changes**:
```bash
git add {config.paths.spec_root}/templates/
git commit -m "feat: Add observability section to plan template"
```

**Review with team**:
```bash
# Pull request for template changes
git checkout -b feat/update-templates
# Make changes
git push origin feat/update-templates
# Create PR for team review
```

---

### Test Templates Before Committing

**Create test feature**:
```bash
/spec generate "Test Template Customization"
# Verify output in {config.paths.features}/{config.naming.feature_directory}/{config.naming.files.spec}
```

**Validate**:
```bash
/spec validate
# Check for errors
```

**Clean up**:
```bash
rm -rf {config.paths.features}/{config.naming.feature_directory}/
# After confirming templates work
```

---

## Troubleshooting

### Template Not Loading

**Symptom**: Custom template not used, default loads instead

**Check**:
1. File name matches exactly (e.g., `spec-template.md`, not `spec.md`)
2. Location is `{config.paths.spec_root}/templates/` (not `{config.paths.spec_root}/template/` or `.spec-templates/`)
3. No syntax errors in template

**Debug**:
```bash
ls -la {config.paths.spec_root}/templates/
# Verify file exists

cat {config.paths.spec_root}/templates/spec-template.md
# Check for syntax errors
```

---

### Variables Not Replaced

**Symptom**: `{FEATURE_ID}` appears literally in generated file

**Causes**:
1. Variable name misspelled (e.g., `{FEATURE-ID}` instead of `{FEATURE_ID}`)
2. Custom variable not supported (workflow doesn't replace it)
3. Placeholder syntax wrong (e.g., `${FEATURE_ID}` instead of `{FEATURE_ID}`)

**Fix**:
```markdown
# Wrong
${FEATURE_ID}

# Correct
{FEATURE_ID}
```

---

### Template Validation Fails

**Symptom**: `/spec validate` reports template errors

**Common issues**:
1. Invalid markdown syntax
2. Missing required sections
3. Malformed frontmatter

**Fix**:
```bash
# Check markdown syntax
cat {config.paths.spec_root}/templates/spec-template.md | markdown-lint

# Compare with default
diff workflow/templates/artifacts/spec-template.md {config.paths.spec_root}/templates/spec-template.md
```

---

## Related Documentation

**Template Reference**: See `templates/readme.md` for complete template catalog

**Workflow Guide**: See `workflow/skill.md` for phase-by-phase workflow

**Customization Examples**: See phase guides (e.g., `phases/2-define/generate/examples.md`)

**Validation**: See `phases/3-design/analyze/guide.md` for validation rules

---

**Questions or issues?** Check workflow documentation or create an issue in the spec plugin repository.
