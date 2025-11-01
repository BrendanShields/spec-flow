---
name: skill-builder
description: Use when creating or improving Claude Code skills, need help with YAML frontmatter, skill structure unclear, activation patterns failing, or "where does implementation go?" - provides complete methodology from design to validation. Includes decision algorithms (scope, tool selection, multi-language), validation scripts, cross-reference standards, and testing procedures. Addresses discovery optimization, progressive disclosure, and deployment readiness.
allowed-tools: Write, Read, Edit, AskUserQuestion, WebSearch, Bash
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
description: Use when [TRIGGERS] - [WHAT + HOW]
allowed-tools: [Tool list or omit for all]
---

# [Skill Display Name]

[One-line purpose statement]

## What This Skill Does [REQUIRED]

[Bullet list of capabilities]

## When to Use [REQUIRED]

[Numbered list of specific triggers]

## Execution Flow [REQUIRED]

### Phase 1: [Phase Name]
[Steps with clear actions]

### Phase 2: [Phase Name]
[Steps with decision points]

## Configuration Options [OPTIONAL]

[Optional parameters and customization]
[INCLUDE IF: Skill has user-configurable behavior]

## Error Handling [REQUIRED]

[Common issues and recovery]

## Output Format [REQUIRED]

[What user receives]
```

**Template Section Guide:**
- **[REQUIRED]**: Must include in every skill
- **[OPTIONAL]**: Include only if applicable
- **[OPTIONAL - Include if...]**: Conditional based on skill type

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

### Phase 9: Implementation Guidance

#### 9.1 Where Skill Logic Lives

**Skills are DOCUMENTATION, not EXECUTABLE CODE.**

When Claude loads a skill, it reads the SKILL.md as INSTRUCTIONS to follow. The "implementation" is Claude applying those instructions.

**What Goes Where:**

```
skill-name/
├── SKILL.md          # Instructions for Claude to follow
├── examples.md       # Examples of following those instructions
├── reference.md      # Technical reference for instructions
├── scripts/          # Executable helper scripts (optional)
│   └── helper.sh     # Claude runs via Bash tool
└── templates/        # Reusable templates (optional)
    └── output.md     # Claude fills in and writes
```

**Example - Code Review Skill:**
```markdown
## Execution Flow [REQUIRED]

### Phase 1: Code Discovery
1. Use Glob tool to find changed files: `**/*.{js,ts,py}`
2. Use Read tool to load file contents
3. Identify programming language from extension

### Phase 2: Analysis
1. For each file:
   - Check for security patterns (SQL injection, XSS, hardcoded credentials)
   - Use Grep to find vulnerable patterns
   - Analyze complexity metrics
2. Compile issues list with line numbers

### Phase 3: Report Generation
1. Prioritize issues: Critical > High > Medium > Low
2. Use Write tool to create review-report.md
3. Format with actionable feedback
```

**Key Point**: SKILL.md contains INSTRUCTIONS for using tools, not implementation code.

#### 9.2 When to Include Helper Scripts

Include scripts in `scripts/` directory when:
- Complex parsing logic (parsing API responses, log files)
- External tool invocation (calling linters, formatters)
- Reusable utilities across multiple skills

**Example**: A skill that parses package.json would include `scripts/parse-package.sh`:
```bash
#!/bin/bash
# scripts/parse-dependencies.sh
jq '.dependencies, .devDependencies' package.json | jq -r 'keys[]'
```

SKILL.md then references: "Run scripts/parse-dependencies.sh via Bash tool"

#### 9.3 When to Include Templates

Include templates in `templates/` directory when:
- Consistent output format needed (API docs, reports, configs)
- User wants customizable structure
- Multiple output variations exist

**Example**: Documentation skill includes `templates/api-doc.md`:
```markdown
# {{API_NAME}} API Documentation

## Endpoints
{{ENDPOINTS_LIST}}

## Authentication
{{AUTH_METHOD}}
```

SKILL.md then instructs: "Load templates/api-doc.md, replace {{PLACEHOLDERS}}"

### Phase 10: Cross-Reference Standards

#### 10.1 Standard Reference Phrases

**Referencing examples.md from SKILL.md:**
```markdown
See examples.md for concrete usage scenarios
```

**Referencing reference.md from SKILL.md:**
```markdown
For complete API documentation, see reference.md
For advanced configuration options, see reference.md
For troubleshooting guide, see reference.md
```

**Referencing specific sections:**
```markdown
See examples.md, Example 3 for multi-language handling
See reference.md, Section 2.3 for authentication patterns
```

**When to reference vs inline:**
- **Inline** (in SKILL.md): Core concepts, primary workflow, essential patterns
- **Reference** (link to other files): Extended examples, comprehensive API docs, edge cases

#### 10.2 File Relationship Structure

```
SKILL.md (Core instructions)
├─→ examples.md (Referenced when: user needs concrete example)
├─→ reference.md (Referenced when: detailed specs needed)
├─→ templates/ (Used when: generating output)
└─→ scripts/ (Executed when: helper logic needed)
```

### Phase 11: Scope Boundary Decisions

#### 11.1 Single Responsibility Rule

**One skill = One core capability**

Use this flowchart to detect scope creep:

```
Is this feature request...
├─ Core to primary capability? → Include
├─ Nice-to-have enhancement? → Separate skill
├─ Different domain? → Separate skill
└─ Supporting function? → Include if essential
```

**Examples:**

✅ **Acceptable Scope** (code-reviewer):
- Analyze code style ← Core
- Check security ← Core
- Detect performance issues ← Core
- Generate report ← Supporting function

❌ **Scope Creep** (code-reviewer):
- Fix issues automatically ← Different capability (code-fixer skill)
- Deploy after review ← Different domain (deployment skill)
- Update documentation ← Different domain (doc-generator skill)

#### 11.2 Multi-Language Support Decision

**When multi-language support is OK:**
- Languages serve same purpose (Python/Node/Go APIs all generate OpenAPI docs)
- Detection is straightforward (file extensions)
- Patterns are parallel (similar concepts, different syntax)

**When to split into separate skills:**
- Languages require fundamentally different approaches
- Implementation complexity doubles for each language
- Maintenance burden becomes excessive

**Decision Algorithm:**
```
Do all languages share 80%+ of the workflow?
├─ YES → Multi-language OK in one skill
└─ NO → Create language-specific skills
```

### Phase 12: Validation & Testing

#### 12.1 Discovery Testing

**Test if skill activates on intended phrases:**

Create test file `test-activation.md`:
```markdown
## Test Phrases - Should Activate
- "Create a code review skill"
- "Need to review code for security"
- "Generate code quality report"

## Test Phrases - Should NOT Activate
- "Deploy code to production" (wrong domain)
- "Write unit tests" (different skill)
- "Fix bugs automatically" (different capability)
```

**Manual Testing:**
1. Start new Claude conversation
2. Say each test phrase
3. Check if skill-builder loads in context
4. Document activation accuracy

**Target: 90%+ activation on intended phrases, <5% false positives**

#### 12.2 Application Testing

**Test if skill produces expected output:**

1. Create test scenario with specific requirements
2. Follow skill instructions exactly as documented
3. Check if output matches expected result
4. Identify gaps in instructions

**Example Test Case:**
```markdown
## Test: Create Data Transformer Skill
### Requirements
- Transform CSV to JSON
- Filter by column values
- Support files up to 1GB

### Expected Output
- SKILL.md with proper frontmatter
- Execution flow with Bash/Read/Write tools
- Error handling for large files
- Examples showing CSV → JSON transformation

### Success Criteria
- All [REQUIRED] sections present
- Tool restrictions appropriate
- Description follows formula
- Working file structure created
```

#### 12.3 Validation Checklist

Run this checklist before deploying any skill:

**YAML Validation:**
- [ ] Starts and ends with `---`
- [ ] name: lowercase-with-hyphens (no special characters)
- [ ] description: Starts with "Use when..."
- [ ] description: Under 500 characters
- [ ] allowed-tools: Valid tool names only

**Structure Validation:**
- [ ] All [REQUIRED] sections present
- [ ] Examples provided (3-5 concrete scenarios)
- [ ] Error handling documented
- [ ] Output format specified

**Content Validation:**
- [ ] Single clear capability (not multiple features)
- [ ] Execution flow uses correct tool names
- [ ] No placeholder code (actual instructions provided)
- [ ] Cross-references use standard phrases

**Testing Validation:**
- [ ] Activation phrases tested (90%+ accuracy)
- [ ] Application scenario tested (produces correct output)
- [ ] Instructions followed by someone else (no missing steps)

#### 12.4 Validation Script

Create `scripts/validate-skill.sh`:
```bash
#!/bin/bash
# Validates skill structure and syntax

SKILL_DIR=$1
SKILL_FILE="$SKILL_DIR/SKILL.md"

echo "Validating $SKILL_DIR..."

# Check SKILL.md exists
if [ ! -f "$SKILL_FILE" ]; then
  echo "❌ SKILL.md not found"
  exit 1
fi

# Extract YAML frontmatter
YAML=$(sed -n '/^---$/,/^---$/p' "$SKILL_FILE")

# Check name format
NAME=$(echo "$YAML" | grep '^name:' | cut -d: -f2- | xargs)
if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "❌ Invalid name format: $NAME (use lowercase-with-hyphens)"
  exit 1
fi

# Check description starts with "Use when"
DESC=$(echo "$YAML" | grep '^description:' | cut -d: -f2- | xargs)
if [[ ! "$DESC" =~ ^Use\ when ]]; then
  echo "⚠️  Description should start with 'Use when...'"
fi

# Check for required sections
REQUIRED=("What This Skill Does" "When to Use" "Execution Flow" "Error Handling" "Output Format")
for section in "${REQUIRED[@]}"; do
  if ! grep -q "## $section" "$SKILL_FILE"; then
    echo "❌ Missing required section: $section"
    exit 1
  fi
done

echo "✅ Skill validation passed"
exit 0
```

**Usage:**
```bash
bash scripts/validate-skill.sh path/to/skill-name/
```

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
description: Use when converting data formats (CSV, JSON, XML), cleaning datasets, or performing statistical analysis - transforms and analyzes data files. Triggers: "data conversion", "clean data", "analyze spreadsheet". Generates cleaned data with analysis reports.
```

### Pattern 2: Automation Skill
```yaml
name: automate-workflow
description: Use when user mentions "automate", "script", or describes repetitive tasks - creates automation scripts for workflows. Triggers: batch processing, CI/CD setup, repeated manual steps. Produces executable scripts with documentation.
```

### Pattern 3: Analysis Skill
```yaml
name: analyze-codebase
description: Use when code review requested, technical debt assessment needed, or refactoring opportunities sought - performs deep analysis of code structure, patterns, and quality. Outputs comprehensive analysis report with actionable recommendations.
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

## Common Mistakes

### Mistake 1: Treating Skills as Code
❌ **Wrong**: Writing Python/JavaScript implementation in SKILL.md
✅ **Right**: Writing instructions for Claude to follow using tools

**Example:**
```markdown
❌ BAD:
def extract_endpoints(file_path):
    with open(file_path) as f:
        return parse_routes(f.read())

✅ GOOD:
1. Use Read tool to load file_path
2. Use Grep to find route patterns: @app.route\(['"]([^'"]+)
3. Extract matches and compile into list
```

### Mistake 2: Unclear Section Requirements
❌ **Wrong**: Guessing which sections are needed
✅ **Right**: Following [REQUIRED] and [OPTIONAL] tags in template

### Mistake 3: Scope Creep
❌ **Wrong**: "code-reviewer should also fix bugs and deploy"
✅ **Right**: Use Phase 11 algorithm - if >20% different workflow, separate skill

### Mistake 4: Vague Descriptions
❌ **Wrong**: "description: Helps with code quality"
✅ **Right**: "description: Use when code review requested or security audit needed - analyzes code for style, security, and performance issues. Generates detailed report with line-specific feedback."

### Mistake 5: No Validation
❌ **Wrong**: Creating skill and hoping it works
✅ **Right**: Run validation checklist and test activation phrases before deploying

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