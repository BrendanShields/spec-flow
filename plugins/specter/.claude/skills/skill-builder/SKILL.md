---
name: skill:build
description: Create well-structured Claude Code skills with proper triggering, progressive disclosure, and best practices. Use when: 1) User wants to create a new skill, 2) Converting repetitive tasks into reusable skills, 3) Packaging domain expertise, 4) Building plugin capabilities, 5) Improving workflow automation. Guides through complete skill creation with validation.
allowed-tools: Write, Read, Edit, AskUserQuestion, WebSearch
---

# Skill Builder: Professional Claude Code Skill Creation

Comprehensive skill creation system that follows all Claude Code best practices for discovery, progressive disclosure, and effective context engineering.

## What This Skill Does

1. **Analyzes** requirements to determine skill purpose and triggers
2. **Designs** effective descriptions for autonomous discovery
3. **Structures** content for progressive disclosure
4. **Generates** SKILL.md with proper YAML frontmatter
5. **Creates** supporting files (examples, reference, scripts)
6. **Validates** skill syntax and discoverability
7. **Tests** activation patterns

## Skill Creation Process

### Phase 1: Conceptualization

#### 1.1 Requirement Gathering
```javascript
const skillRequirements = {
  purpose: "What single capability will this skill provide?",
  triggers: "What phrases/contexts should activate it?",
  audience: "Who will use this skill?",
  frequency: "How often will it be used?",
  complexity: "Simple task or multi-step workflow?"
};
```

#### 1.2 Capability Analysis
- **Single Focus**: One skill = one capability (avoid scope creep)
- **Clear Boundaries**: Define what skill does AND doesn't do
- **Trigger Mapping**: List all phrases users might say
- **Context Requirements**: What information is needed?

### Phase 2: Description Engineering

#### 2.1 Description Formula
```
[WHAT] + [WHEN] + [OUTPUT]

WHAT: Primary capability in active voice
WHEN: Specific triggers and use cases (numbered list)
OUTPUT: What the skill produces/creates
```

#### 2.2 Description Patterns

**Strong Descriptions** (Specific & Discoverable):
```yaml
description: Extract data from CSV files, transform columns, and generate reports. Use when: 1) Processing spreadsheet data, 2) User mentions CSV/Excel, 3) Data transformation needed, 4) Creating pivot tables or summaries. Outputs formatted analysis with charts.
```

**Weak Descriptions** (Vague & Undiscoverable):
```yaml
description: Helps with data files  # ❌ Too vague
```

### Phase 3: Progressive Disclosure Design

#### 3.1 Three-Level Architecture

```
Level 1: Metadata (Always Loaded) ~100 tokens
├── name
├── description
└── allowed-tools

Level 2: Instructions (Loaded on Trigger) ~2-5k tokens
└── SKILL.md body content

Level 3: Resources (Loaded on Demand) Unlimited
├── examples.md
├── reference.md
├── templates/
└── scripts/
```

#### 3.2 Content Distribution Strategy

**SKILL.md** (Core Instructions):
- Essential steps
- Primary workflows
- Critical decision points
- Error handling

**examples.md** (Concrete Usage):
- Real-world scenarios
- Input/output pairs
- Edge cases
- Common variations

**reference.md** (Deep Knowledge):
- Technical specifications
- API documentation
- Configuration options
- Advanced patterns

### Phase 4: YAML Frontmatter Generation

#### 4.1 Required Fields
```yaml
---
name: skill-name  # Lowercase, hyphenated, memorable
description: [Comprehensive trigger description]
---
```

#### 4.2 Optional Fields
```yaml
---
name: skill-name
description: [Description with triggers]
allowed-tools: Read, Write, Edit, Bash  # Tool restrictions
model: claude-3  # Model preference (if specific)
---
```

### Phase 5: Skill Content Structure

#### 5.1 SKILL.md Template
```markdown
---
name: [skill-name]
description: [What + When + Output]
allowed-tools: [Tool list or omit for all]
---

# [Skill Display Name]

[One-line purpose statement]

## What This Skill Does

[Bullet list of capabilities]

## When to Use

[Numbered list of specific triggers]

## Execution Flow

### Phase 1: [Phase Name]
[Steps with clear actions]

### Phase 2: [Phase Name]
[Steps with decision points]

## Configuration Options

[Optional parameters and customization]

## Error Handling

[Common issues and recovery]

## Output Format

[What user receives]
```

#### 5.2 Supporting Files Structure

**examples.md**:
```markdown
# [Skill Name]: Examples

## Example 1: [Scenario Name]
### Input
[User request]

### Execution
[What skill does]

### Output
[Result]

## Example 2: [Edge Case]
[Handling unusual scenarios]
```

**reference.md**:
```markdown
# [Skill Name]: Technical Reference

## API Documentation
[Detailed specifications]

## Configuration Schema
[All options explained]

## Best Practices
[Usage recommendations]

## Troubleshooting
[Common problems and solutions]
```

### Phase 6: Implementation Patterns

#### 6.1 Tool Restriction Patterns

**Read-Only Skills**:
```yaml
allowed-tools: Read, Grep, Glob  # Analysis without modification
```

**Generation Skills**:
```yaml
allowed-tools: Write, Edit  # Content creation
```

**Automation Skills**:
```yaml
allowed-tools: Bash, Write  # Script execution
```

#### 6.2 Activation Patterns

**Direct Match**:
- User says exact trigger phrase
- Skill activates immediately

**Contextual Match**:
- Related concepts mentioned
- Skill evaluates relevance
- Activates if confidence high

**Proactive Match**:
- Description includes "use proactively"
- Skill monitors for opportunities
- Suggests itself when relevant

### Phase 7: Validation & Testing

#### 7.1 Syntax Validation
```bash
# Check YAML syntax
- Proper indentation (spaces, not tabs)
- Opening/closing dashes (---)
- Quote special characters
- Valid field names
```

#### 7.2 Discovery Testing
```markdown
## Test Phrases
1. [Primary trigger phrase] → Should activate
2. [Alternative phrasing] → Should activate
3. [Related concept] → Should consider
4. [Unrelated phrase] → Should NOT activate
```

#### 7.3 Progressive Disclosure Verification
- Metadata loads without errors
- Instructions load on activation
- References load when needed
- Scripts execute properly

### Phase 8: Skill Generation

Based on requirements, this skill generates:

1. **Primary SKILL.md** with optimized frontmatter
2. **examples.md** with 3-5 concrete scenarios
3. **reference.md** with technical details
4. **Installation instructions** for skill placement
5. **Test suite** for validation

## Configuration Options

```javascript
{
  "skillBuilder": {
    "style": "comprehensive",  // minimal|standard|comprehensive
    "includeExamples": true,
    "includeReference": true,
    "generateTests": true,
    "validateSyntax": true,
    "optimizeDescription": true
  }
}
```

## Quality Checklist

### Description Quality
- [ ] Includes "Use when:" with numbered scenarios
- [ ] Mentions specific trigger words/concepts
- [ ] Describes output/value clearly
- [ ] Under 500 characters but comprehensive

### Structure Quality
- [ ] Single focused capability
- [ ] Progressive disclosure implemented
- [ ] Examples provided
- [ ] Error handling included

### Technical Quality
- [ ] Valid YAML syntax
- [ ] Appropriate tool restrictions
- [ ] Proper file organization
- [ ] Scripts are executable

## Common Patterns Library

### Pattern 1: Data Processing Skill
```yaml
name: process-data
description: Transform and analyze data files (CSV, JSON, XML). Use when: 1) Converting between formats, 2) Data cleaning needed, 3) Statistical analysis requested, 4) User mentions spreadsheets or datasets. Generates cleaned data with analysis reports.
```

### Pattern 2: Automation Skill
```yaml
name: automate-workflow
description: Create automation scripts for repetitive tasks. Use when: 1) User mentions "automate" or "script", 2) Repetitive task described, 3) Batch processing needed, 4) CI/CD setup requested. Produces executable scripts with documentation.
```

### Pattern 3: Analysis Skill
```yaml
name: analyze-codebase
description: Deep analysis of code structure, patterns, and quality. Use when: 1) Code review requested, 2) Technical debt assessment, 3) Architecture documentation needed, 4) Refactoring opportunities sought. Outputs comprehensive analysis report.
```

## Security Considerations

### Safe Skill Design
- Limit tool access to minimum required
- Validate all inputs
- Avoid external network calls
- Sanitize file paths
- Document security implications

### Distribution Safety
- Include security warnings in README
- Version control all changes
- Test in isolated environment first
- Review bundled scripts for vulnerabilities

## Success Metrics

### Good Skill Indicators
- Activates on intended phrases (>90% accuracy)
- Completes tasks successfully (>95% success)
- Minimal context usage (<5k tokens active)
- Clear value delivery
- Reusable across projects

### Improvement Signals
- Users manually invoke instead of auto-discovery
- Frequent clarification needed
- Task completion requires intervention
- Context overflow issues
- Limited reusability

## Output Format

When creating a skill, this builder produces:

```
Created: [skill-name]/
├── SKILL.md (2.3 KB)
├── examples.md (1.8 KB)
├── reference.md (3.2 KB)
├── scripts/
│   └── helper.sh (0.5 KB)
└── README.md (1.0 KB)

✅ Skill Validated:
- YAML syntax: Valid
- Description: Optimized for discovery
- Structure: Progressive disclosure implemented
- Tools: Appropriately restricted

📝 Next Steps:
1. Move to ~/.claude/skills/ (personal) or .claude/skills/ (project)
2. Test with: "[trigger phrase]"
3. Iterate based on activation patterns
```