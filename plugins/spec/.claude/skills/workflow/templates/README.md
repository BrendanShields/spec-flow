# Workflow Templates

Reusable templates for spec workflow artifacts, organized by purpose and use case.

## Template Categories

### 1. Feature Artifacts (Core Workflow)

Templates for the main workflow outputs - the three key files generated per feature.

**artifacts/spec-template.md**
- **Purpose**: Feature specification with user stories
- **Phase**: Phase 2 (Define Requirements)
- **Function**: `generate/`
- **Output**: `features/###-name/spec.md`
- **Contains**: User stories (P1/P2/P3), acceptance criteria, business context

**artifacts/plan-template.md**
- **Purpose**: Technical design and architecture decisions
- **Phase**: Phase 3 (Design Solution)
- **Function**: `plan/`
- **Output**: `features/###-name/plan.md`
- **Contains**: Architecture diagrams, data models, API contracts, ADRs, testing strategy

**artifacts/tasks-template.md**
- **Purpose**: Executable task breakdown with dependencies
- **Phase**: Phase 4 (Build Feature)
- **Function**: `tasks/`
- **Output**: `features/###-name/tasks.md`
- **Contains**: Task IDs, priorities, dependencies, estimates, parallel markers

### 2. Project Setup (Initialization)

Templates created once per project during initialization.

**project-setup/product-requirements-template.md**
- **Purpose**: High-level product vision and success metrics
- **Phase**: Phase 1 (Initialize)
- **Function**: `init/`
- **Output**: `.spec/product-requirements.md`
- **Contains**: Product vision, success criteria, KPIs, constraints, stakeholders

**project-setup/architecture-blueprint-template.md**
- **Purpose**: Project-wide architecture standards and decisions
- **Phase**: Phase 1 (Initialize)
- **Function**: `blueprint/`
- **Output**: `.spec/architecture-blueprint.md`
- **Contains**: Tech stack, design patterns, API conventions, security standards, ADRs

### 3. Quality & Validation

Templates for quality assurance and validation processes.

**quality/checklist-template.md**
- **Purpose**: Domain-specific quality validation checklists
- **Phase**: Phase 2 (Define Requirements)
- **Function**: `checklist/`
- **Output**: `features/###-name/checklists/*.md`
- **Contains**: UX checklist, API checklist, security checklist, performance checklist

### 4. Integrations (External Systems)

Templates for syncing with external tools and services via MCP integrations.

**integrations/jira-story-template.md**
- **Purpose**: JIRA-compatible user story format
- **Integration**: Atlassian MCP server
- **Function**: `generate/` (with JIRA sync enabled)
- **Output**: JIRA story via API
- **Contains**: JIRA-specific fields (story points, epic link, labels)

**integrations/confluence-page.md**
- **Purpose**: Confluence documentation page template
- **Integration**: Atlassian MCP server
- **Function**: Any (when publishing to Confluence)
- **Output**: Confluence page via API
- **Contains**: Confluence markup, page hierarchy, metadata

**integrations/openapi-template.yaml**
- **Purpose**: OpenAPI 3.0 specification for API documentation
- **Integration**: API documentation tools
- **Function**: `plan/` (for API-focused features)
- **Output**: `features/###-name/openapi.yaml`
- **Contains**: OpenAPI schema, endpoints, models, authentication

### 5. Internal (Framework Use)

Templates used internally by the workflow framework - not typically edited by users.

**internal/agent-file-template.md**
- **Purpose**: Context file for subagent delegation
- **Usage**: Internal use by `spec:implementer`, `spec:researcher`, `spec:analyzer`
- **Output**: `.spec-state/agent-context.md` (temporary)
- **Contains**: Task context, constraints, expected output format

## Template Organization

```
templates/
├── README.md (this file)
├── artifacts/       ← Core workflow (3 files)
│   ├── spec-template.md
│   ├── plan-template.md
│   └── tasks-template.md
├── project-setup/           ← One-time setup (2 files)
│   ├── product-requirements-template.md
│   └── architecture-blueprint-template.md
├── quality/                 ← Validation (1 file)
│   └── checklist-template.md
├── integrations/            ← External systems (3 files)
│   ├── jira-story-template.md
│   ├── confluence-page.md
│   └── openapi-template.yaml
└── internal/                ← Framework internals (1 file)
    └── agent-file-template.md
```

## Usage by Phase

### Phase 1: Initialize
- `project-setup/product-requirements-template.md` (via `init/`)
- `project-setup/architecture-blueprint-template.md` (via `blueprint/`)

### Phase 2: Define Requirements
- `artifacts/spec-template.md` (via `generate/`)
- `quality/checklist-template.md` (via `checklist/`)

### Phase 3: Design Solution
- `artifacts/plan-template.md` (via `plan/`)
- `integrations/openapi-template.yaml` (optional, for APIs)

### Phase 4: Build Feature
- `artifacts/tasks-template.md` (via `tasks/`)

### Phase 5: Track Progress
- (No templates - uses existing files)

## Template Customization

### Modifying Templates

Templates can be customized per project:

1. **Project-level**: Copy template to `.spec/templates/` and modify
2. **Global**: Edit templates in workflow skill directory
3. **Per-feature**: Manually edit generated files after creation

### Template Variables

Templates use placeholder syntax:
- `{PROJECT_NAME}` - Project name
- `{FEATURE_ID}` - Feature number (e.g., 003)
- `{FEATURE_NAME}` - Feature name
- `{DATE}` - Current date
- `{AUTHOR}` - User name
- `{EPIC_ID}` - Epic identifier (JIRA)

### Adding Custom Templates

To add a new template:

1. Determine category (artifacts, project-setup, quality, integrations, internal)
2. Create template file in appropriate category
3. Use consistent placeholder syntax
4. Document in this README
5. Reference in appropriate phase function

## Integration Setup

### JIRA Integration

To use `jira-story-template.md`:
1. Install Atlassian MCP server
2. Configure in `.spec/config.json`:
   ```json
   {
     "integrations": {
       "jira": {
         "enabled": true,
         "project_key": "PROJ",
         "auto_sync": true
       }
     }
   }
   ```
3. Run `generate/` - automatically creates JIRA stories

### Confluence Integration

To use `confluence-page.md`:
1. Install Atlassian MCP server
2. Configure root page ID in `.spec/config.json`
3. Use `--publish-confluence` flag with workflow functions

### OpenAPI Integration

To use `openapi-template.yaml`:
1. Enable in `plan/` for API features
2. Generated automatically when API design detected
3. Validate with tools like Swagger Editor

## Template Best Practices

### Designing Templates

✅ **Do:**
- Use clear placeholder syntax: `{VARIABLE_NAME}`
- Include inline documentation and examples
- Provide sensible defaults
- Make sections optional with clear markers
- Keep templates focused and concise

❌ **Don't:**
- Hardcode project-specific values
- Include excessive boilerplate
- Mix multiple concerns in one template
- Assume specific tools or integrations

### Using Templates

✅ **Do:**
- Customize templates for your project needs
- Keep customized templates in `.spec/templates/`
- Document custom placeholders
- Version control template changes

❌ **Don't:**
- Edit templates directly during workflow
- Skip template sections without documenting why
- Mix templates from different versions
- Forget to update dependent templates together

## Finding the Right Template

**Need to...**

Create feature specification?
→ `artifacts/spec-template.md`

Design technical solution?
→ `artifacts/plan-template.md`

Break down into tasks?
→ `artifacts/tasks-template.md`

Set up new project?
→ `project-setup/product-requirements-template.md`
→ `project-setup/architecture-blueprint-template.md`

Validate quality?
→ `quality/checklist-template.md`

Sync to JIRA?
→ `integrations/jira-story-template.md`

Document API?
→ `integrations/openapi-template.yaml`

Publish to Confluence?
→ `integrations/confluence-page.md`

## Template Maintenance

Templates are maintained by:
- Workflow skill maintainers (framework templates)
- Project teams (customized templates)

Version compatibility:
- Templates match workflow skill version
- Check version compatibility when updating
- Test customized templates after workflow updates

---

**Total templates**: 11 files across 5 categories
**Core workflow templates**: 3 (spec, plan, tasks)
**Setup templates**: 2 (product requirements, architecture)
**Quality templates**: 1 (checklists)
**Integration templates**: 3 (JIRA, Confluence, OpenAPI)
**Internal templates**: 1 (agent context)
