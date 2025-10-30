# Flow Checklist Reference

## Core Philosophy: "Unit Tests for Requirements"

Checklists validate REQUIREMENT QUALITY, not implementation correctness.

### Correct Checklist Items

✅ Test the requirements themselves:
- "Are performance targets quantified with specific metrics?"
- "Are error handling requirements defined for all API failure modes?"
- "Is 'fast loading' replaced with measurable thresholds?"

### Incorrect Checklist Items

❌ Test the implementation:
- "Verify API returns 200 status"
- "Test the button clicks correctly"
- "Confirm page loads in <2 seconds"

**Why**: Checklists run BEFORE implementation. They validate that requirements are complete, clear, and testable - not that code works.

## Quality Dimensions

### 1. Completeness

**Definition**: All necessary requirements are present

**Checklist Pattern**:
```markdown
- [ ] CHK### - Are [requirement type] defined for [scenario]? [Completeness]
```

**Examples**:
- "Are request body schemas defined for all POST endpoints?"
- "Are loading states specified for all async operations?"
- "Are error messages defined for all validation failures?"

### 2. Clarity

**Definition**: Requirements are specific, not vague or ambiguous

**Checklist Pattern**:
```markdown
- [ ] CHK### - Is "[vague term]" quantified with specific [measurement]? [Clarity]
```

**Examples**:
- "Is 'fast loading' quantified with specific timing thresholds (<2s FCP)?"
- "Is 'user-friendly' defined with specific UX criteria (3-click checkout)?"
- "Is 'secure' replaced with specific security requirements (OWASP Top 10)?"

### 3. Consistency

**Definition**: Similar requirements use the same patterns/terminology

**Checklist Pattern**:
```markdown
- [ ] CHK### - Are [requirement aspect] consistently defined for all [scope]? [Consistency]
```

**Examples**:
- "Are error response formats consistent across all API endpoints?"
- "Are hover states consistently defined for all interactive elements?"
- "Are naming conventions consistent for all database entities?"

### 4. Measurability

**Definition**: Requirements can be objectively verified

**Checklist Pattern**:
```markdown
- [ ] CHK### - Can [requirement] be objectively measured/tested? [Measurability]
```

**Examples**:
- "Can 'intuitive UI' be replaced with specific usability test criteria?"
- "Can 'scalable' be measured with specific capacity requirements?"
- "Can 'performant' be verified with quantified benchmarks?"

### 5. Coverage

**Definition**: All scenarios, edge cases, and contexts are addressed

**Checklist Pattern**:
```markdown
- [ ] CHK### - Are [requirement type] specified for [edge case]? [Coverage]
```

**Examples**:
- "Are error handling requirements specified for network timeouts?"
- "Are accessibility requirements defined for keyboard-only navigation?"
- "Are authorization rules specified for admin vs regular users?"

### 6. Gap

**Definition**: Requirement doesn't exist but should

**Checklist Pattern**:
```markdown
- [ ] CHK### - [Missing requirement]? [Gap]
```

**Examples**:
- "Are logging requirements specified? [Gap]"
- "Are data retention policies defined? [Gap]"
- "Are rate limiting thresholds specified? [Gap]"

## Checklist Types

### UX/UI Checklist

**Focus Areas**:
- Visual design (layout, colors, typography)
- Interaction design (hover, click, animations)
- Accessibility (WCAG, keyboard navigation, screen readers)
- Responsive design (breakpoints, mobile behavior)
- User flows (step-by-step interactions)

**Common Items**:
```markdown
- [ ] Are visual hierarchy requirements measurable (not "looks good")?
- [ ] Are animation durations quantified (not "smooth")?
- [ ] Are WCAG level and specific criteria defined?
- [ ] Are breakpoints specified with exact pixel values?
```

### API Checklist

**Focus Areas**:
- Endpoint design (naming, methods, versioning)
- Request/response formats
- Error handling
- Authentication/authorization
- Pagination, filtering, sorting

**Common Items**:
```markdown
- [ ] Are endpoint naming conventions consistently applied?
- [ ] Are error response formats specified for all failure modes?
- [ ] Are authentication requirements defined for all protected endpoints?
- [ ] Are pagination parameters consistent across list endpoints?
```

### Security Checklist

**Focus Areas**:
- Authentication methods
- Authorization rules
- Data protection (encryption, PII handling)
- Audit logging
- Compliance (HIPAA, GDPR, SOC 2)

**Common Items**:
```markdown
- [ ] Are encryption requirements specified (at-rest and in-transit)?
- [ ] Are password requirements quantified (length, complexity)?
- [ ] Are PII handling requirements defined per regulations?
- [ ] Are audit log requirements specified for sensitive operations?
```

### Performance Checklist

**Focus Areas**:
- Response time targets
- Throughput requirements
- Resource usage limits
- Scalability thresholds
- Load testing criteria

**Common Items**:
```markdown
- [ ] Are response times quantified with percentiles (p95, p99)?
- [ ] Are concurrent user capacity requirements specified?
- [ ] Are auto-scaling trigger points defined?
- [ ] Are database query performance targets specified?
```

## Item Format Specification

### Complete Format

```markdown
- [ ] CHK### - [Question about requirement quality]? [Quality Dimension, Spec Reference]
```

**Components**:
| Part | Required | Example |
|------|----------|---------|
| Checkbox | Yes | `- [ ]` |
| ID | Yes | `CHK001` |
| Question | Yes | `Are error formats specified for all failures?` |
| Quality Dimension | Yes | `[Completeness]` |
| Spec Reference | Optional | `[Spec §API-2]` |

### Numbering

- Sequential: CHK001, CHK002, CHK003...
- Unique per checklist file
- No gaps
- Starts at CHK001

### Question Formulation

**Pattern**: "Are [requirement aspect] [requirement quality] for [scope]?"

**Examples**:
- "Are pagination parameters **consistently defined** for all list endpoints?"
- "Is 'fast' **quantified** with specific thresholds?"
- "Are error messages **defined** for all validation failures?"

## Generation Algorithm

```javascript
function generateChecklist(spec, domain) {
  const items = [];
  let id = 1;

  // Extract requirements by domain
  const requirements = filterByDomain(spec.requirements, domain);

  // Check completeness
  for (const reqType of getRequiredTypes(domain)) {
    const exists = requirements.some(r => r.type === reqType);
    if (!exists) {
      items.push({
        id: `CHK${pad(id++, 3)}`,
        question: `Are ${reqType} requirements specified?`,
        dimension: 'Gap',
        severity: determineSeverity(reqType)
      });
    }
  }

  // Check clarity (vague terms)
  const vagueTerms = findVagueTerms(requirements);
  for (const term of vagueTerms) {
    items.push({
      id: `CHK${pad(id++, 3)}`,
      question: `Is "${term.word}" quantified with specific ${getMetric(term)}?`,
      dimension: 'Clarity',
      specRef: term.section
    });
  }

  // Check consistency
  const groups = groupSimilarRequirements(requirements);
  for (const group of groups) {
    const inconsistent = checkConsistency(group);
    if (inconsistent) {
      items.push({
        id: `CHK${pad(id++, 3)}`,
        question: `Are ${group.aspect} consistently defined for all ${group.scope}?`,
        dimension: 'Consistency'
      });
    }
  }

  // Domain-specific checks
  items.push(...getDomainSpecificChecks(domain, requirements, id));

  return formatChecklist(domain, items);
}
```

## Configuration

### Checklist Depth

**Lightweight** (5-10 items):
- Critical gaps only
- High-impact clarity issues
- Major consistency problems

**Standard** (10-20 items, default):
- All completeness checks
- Clarity for vague terms
- Consistency across similar requirements
- Coverage for common edge cases

**Comprehensive** (20+ items):
- All standard checks
- Detailed coverage analysis
- Measurability validation
- Minor consistency issues

### Domain Selection

**Single Domain**:
```bash
specter:checklist --type ux
```

**Multiple Domains**:
```bash
specter:checklist --type security,api,performance
```

**Auto-Detect**:
```bash
specter:checklist
```
Analyzes spec and generates checklists for detected domains.

### Focus Areas

Provide specific focus:
```bash
specter:checklist "Focus on API error handling and rate limiting"
```

Generates targeted checklist items for specified focus areas.

## Validation Rules

### Item Quality

Each checklist item must:
1. Ask about requirement quality (not implementation)
2. Be objectively answerable (yes/no or specific value)
3. Reference specific quality dimension
4. Be actionable (can improve requirement based on answer)

**Valid**:
```markdown
✅ - [ ] CHK001 - Are error response formats specified for all API failures? [Completeness]
```

**Invalid**:
```markdown
❌ - [ ] CHK001 - Does the API handle errors correctly?
   (Tests implementation, not requirement quality)

❌ - [ ] CHK002 - Is the API good?
   (Not objective, not actionable)
```

### Checklist Completeness

Checklist should cover:
- ✅ Common requirements for domain
- ✅ Known gaps in typical specs
- ✅ Vague terms from actual spec
- ✅ Consistency across similar items
- ✅ Coverage of edge cases

## Usage Workflow

### 1. Generate Checklist

```bash
specter:checklist --type security
```

Creates `checklists/security.md`

### 2. Review Spec Against Checklist

**Manual Review**:
- Read each checklist item
- Check if requirement meets quality standard
- Mark item as `[X]` if passes, `[ ]` if needs work

**Example**:
```markdown
- [X] CHK001 - Are encryption requirements specified? [Completeness]
      ✓ Spec §SEC-2 defines AES-256 for data at rest

- [ ] CHK002 - Are password requirements quantified? [Clarity]
      ✗ Spec just says "strong passwords", not specific

- [X] CHK003 - Are audit log requirements defined? [Completeness]
      ✓ Spec §SEC-5 specifies what to log
```

### 3. Improve Spec

For each `[ ]` item:
1. Identify the quality issue
2. Update specification to address it
3. Mark item as `[X]`

**Example Fix**:
```markdown
Before: "Users must have strong passwords"

After: "Password requirements:
- Minimum 12 characters
- At least 1 uppercase, 1 lowercase, 1 number, 1 symbol
- Cannot contain username
- Cannot be in common password list (top 10k)
- Must change every 90 days"

Checklist: [X] CHK002 - Are password requirements quantified?
```

### 4. Validate Completion

All items should be `[X]` before proceeding to `specter:plan`.

If items remain `[ ]`:
- **CRITICAL/HIGH gaps**: Must fix
- **MEDIUM**: Consider fixing
- **LOW**: Can defer

## Common Patterns by Domain

### Authentication/Authorization

```markdown
- [ ] Are authentication methods specified with implementation details?
- [ ] Are password/token requirements quantified?
- [ ] Are authorization rules defined for all protected resources?
- [ ] Are session management requirements specified (timeout, refresh)?
```

### Data Validation

```markdown
- [ ] Are input validation rules specified for all fields?
- [ ] Are error messages defined for each validation failure?
- [ ] Are validation timing requirements clear (client/server/both)?
- [ ] Are sanitization requirements specified for user input?
```

### Error Handling

```markdown
- [ ] Are error response formats consistent across all endpoints?
- [ ] Are HTTP status codes appropriate for each error type?
- [ ] Are error messages user-friendly AND debuggable?
- [ ] Are retry logic requirements specified for transient failures?
```

## Troubleshooting

### "Checklist has obvious items"

**Cause**: Spec is already high-quality for that domain

**Result**: Checklist validates this - most items will be `[X]`

**Action**: Consider this confirmation of good spec quality

### "Checklist misses important gap"

**Cause**: Domain-specific patterns not covered

**Action**: Manually add checklist items for project-specific concerns

### "All items marked incomplete"

**Cause**: Spec is very early draft or missing detail

**Action**: Use checklist as guide to flesh out specification

## Related Files

- `spec.md` - Specification being validated (input)
- `checklists/[domain].md` - Generated checklist (output)
- `.specter/templates/checklist-template.md` - Template for custom checklists
