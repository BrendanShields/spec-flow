---
name: spec:checklist
description: Use when 1) Need validation gates before implementation, 2) Validating requirement quality/completeness, 3) Creating UX/security/API/performance checklists, 4) Enterprise compliance requirements, 5) User mentions "quality checklist" or "requirement validation" - generates domain-specific checklists that test requirement quality before plan phase.
allowed-tools: Read, Write
---

# Quality Checklist Generator

Generate validation checklists that test requirement quality - "unit tests for specifications".

## What This Skill Does

Creates domain-specific checklists that validate:
- **Completeness**: All necessary requirements defined?
- **Clarity**: Specific and measurable (not "fast", "user-friendly")?
- **Consistency**: Aligned patterns and terminology?
- **Testability**: Objectively verifiable acceptance criteria?
- **Coverage**: Edge cases and failure modes addressed?

## When to Use

1. After creating spec in Generate phase
2. Before technical planning in Plan phase
3. For enterprise compliance requirements (HIPAA, GDPR, SOC2)
4. When validating requirements before team approval
5. To identify requirement gaps and ambiguities

## Execution Flow

### Phase 1: Analyze Specification

1. Read feature spec.md using Read tool
2. Identify domains present:
   - UX (visual design, interactions, accessibility)
   - API (endpoints, formats, authentication)
   - Security (auth, encryption, data protection)
   - Performance (response times, scalability)
   - Compliance (regulatory requirements)
3. Extract requirement sections and IDs

### Phase 2: Generate Checklists

For each detected domain, create `checklists/[domain].md`:

**Checklist Item Format**:
```markdown
- [ ] CHK### - [Quality question about requirement]? [Dimension, Spec-Ref]
```

**Quality Dimensions**:
- **Completeness**: Required items present?
- **Clarity**: Specific vs vague terms?
- **Consistency**: Uniform patterns?
- **Measurability**: Objectively testable?
- **Coverage**: Edge cases addressed?
- **Gap**: Missing requirement identified

**Target Item Count**:
- UX: 10-15 items
- API: 10-15 items
- Security: 15-20 items
- Performance: 8-12 items

### Phase 3: Link to Requirements

Each checklist item references:
1. Spec section (§X.Y) or requirement ID
2. Quality dimension being tested
3. Specific question to validate

**Example**:
```markdown
- [ ] CHK001 - Are error response formats defined for all API failure modes? [Completeness, Spec §API-3]
- [ ] CHK002 - Is "fast loading" quantified with timing thresholds (<500ms)? [Clarity, Spec §NFR-2]
- [ ] CHK003 - Are WCAG 2.1 AA criteria specified for accessibility? [Completeness, Spec §UX-5]
```

### Phase 4: Generate Summary

Create `checklists/readme.md`:
- List all generated checklists
- Overall completion status
- Instructions for validation workflow
- Next steps after completion

## Checklist Types

**ux.md** - Visual Design & Interaction:
- Visual consistency (colors, typography, spacing)
- Interactive states (hover, focus, disabled, loading)
- Accessibility (WCAG, keyboard, screen reader)
- Responsive design (breakpoints, mobile-first)
- User flows (navigation, error recovery)

**api.md** - API Design:
- Endpoint definitions (paths, methods, params)
- Request/response schemas
- Error handling (status codes, error formats)
- Authentication/authorization
- Pagination, filtering, sorting
- Versioning strategy

**security.md** - Security & Privacy:
- Authentication mechanisms
- Authorization rules
- Encryption (transit, at-rest)
- PII handling
- Audit logging
- Compliance requirements

**performance.md** - Performance & Scalability:
- Response time thresholds
- Concurrent user capacity
- Database query optimization
- Caching strategy
- Rate limiting

## Output Format

**Directory Structure**:
```
{config.paths.features}/###-feature-name/
├── spec.md
└── checklists/
    ├── readme.md          # Summary and instructions
    ├── ux.md              # UX quality checklist
    ├── api.md             # API quality checklist
    ├── security.md        # Security quality checklist
    └── performance.md     # Performance quality checklist
```

**Progress Tracking**:
- `[ ]` - Not validated
- `[X]` - Validated and complete
- `[~]` - Partially addressed (needs refinement)
- `[?]` - Gap identified (requirement missing)

## Error Handling

**No spec found**: Prompt user to run /spec → "📝 Define Feature" first
**Empty spec**: Cannot generate checklist without requirements
**Invalid domain**: Show available domain types
**File write fails**: Check directory permissions

## Validation Workflow

1. Generate checklists with this skill
2. Review each item against spec.md
3. Mark validated items `[X]`
4. Identify gaps `[?]` and add missing requirements
5. Refine vague requirements for `[~]` items
6. When all items complete, proceed to plan phase

## Examples

See examples.md for:
- UX checklist for e-commerce checkout
- API checklist for REST endpoints
- Security checklist for HIPAA compliance
- Performance checklist for real-time dashboard
- Multi-domain checklist generation

## Templates Used

This function uses the following templates:

**Primary Template**:
- `templates/checklist-template.md` → `{config.paths.features}/###-name/checklists/*.md`

**Purpose**: Provides domain-specific quality validation checklists (UX, API, Security, Performance)

**Customization**:
1. Template structure: `.claude/skills/workflow/templates/checklist-template.md`
2. Modify quality dimensions to match your standards (e.g., add accessibility, localization)
3. checklist/ will use your custom template for all generated checklists

**Template includes**:
- UX checklist (usability, accessibility, responsiveness)
- API checklist (REST standards, error handling, documentation)
- Security checklist (OWASP Top 10, authentication, data protection)
- Performance checklist (load times, resource usage, scalability)
- Custom quality dimensions

**Generated files** (based on feature domain):
- `{config.paths.features}/###-name/checklists/ux-checklist.md`
- `{config.paths.features}/###-name/checklists/api-checklist.md`
- `{config.paths.features}/###-name/checklists/security-checklist.md`
- `{config.paths.features}/###-name/checklists/performance-checklist.md`

**See also**: `templates/readme.md` for complete template documentation

## Reference

See reference.md for:
- Complete quality dimension definitions
- Domain-specific checklist templates
- Validation criteria by checklist type
- Common patterns and anti-patterns
- Configuration options

## Integration

**Before**: Generate phase creates requirements
**After**: Plan phase uses validated requirements
**Related**: Validate phase checks consistency
