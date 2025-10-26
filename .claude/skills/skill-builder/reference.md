# Skill Builder: Technical Reference

## Description Engineering Patterns

### Formula for Maximum Discovery

```
[ACTION VERB] [DOMAIN] [OBJECTS]. Use when: 1) [EXPLICIT], 2) [CONTEXTUAL], 3) [PROACTIVE], 4) [MENTION], 5) [RELATED]. [OUTPUT].
```

### Proven Description Templates

#### Data Processing
```yaml
description: Process and transform {DATA_TYPE} files with validation and analysis. Use when: 1) User mentions {DATA_TYPE} files, 2) Data transformation or conversion needed, 3) Validation or cleaning required, 4) Analysis or reporting requested, 5) Batch processing mentioned. Outputs processed data with reports.
```

#### Code Analysis
```yaml
description: Analyze {LANGUAGE} code for {ASPECT} with detailed reporting. Use when: 1) Code review or audit requested, 2) {ASPECT} analysis needed, 3) Quality metrics required, 4) Technical debt assessment, 5) Refactoring opportunities mentioned. Generates comprehensive analysis report.
```

#### Automation
```yaml
description: Automate {TASK} workflows with configurable scripts. Use when: 1) User mentions automation or scripting, 2) Repetitive {TASK} described, 3) Batch operations needed, 4) CI/CD integration required, 5) Workflow optimization requested. Creates executable automation scripts.
```

#### Documentation
```yaml
description: Generate {DOC_TYPE} documentation from {SOURCE}. Use when: 1) Documentation requested, 2) {DOC_TYPE} specifically mentioned, 3) Code comments need extraction, 4) API docs required, 5) README or guides needed. Produces markdown documentation.
```

## Progressive Disclosure Architecture

### Token Budget Guidelines

| Component | Target Size | Maximum | Notes |
|-----------|------------|---------|-------|
| Metadata | ~100 tokens | 150 tokens | Name + description only |
| Core SKILL.md | ~1000 tokens | 1500 tokens | Essential workflow |
| EXAMPLES.md | ~2000 tokens | 5000 tokens | 3-5 scenarios |
| REFERENCE.md | Unlimited | - | Loaded on demand |
| Scripts | 0 tokens | - | Executed, not loaded |
| Templates | 0 tokens | - | File system access |

### Modularization Strategy

#### What Goes Where

**SKILL.md (Core)**:
- Primary workflow steps
- Essential decision points
- Critical error handling
- Output format
- Quick reference to resources

**EXAMPLES.md**:
- 3-5 concrete scenarios
- Input → Process → Output
- Edge cases
- Common variations
- Testing patterns

**REFERENCE.md**:
- Detailed specifications
- Configuration schemas
- API documentation
- Troubleshooting guide
- Advanced patterns

**templates/**:
- Boilerplate content
- Output templates
- Configuration samples
- Reusable patterns

**scripts/**:
- Validation logic
- Generation code
- Analysis tools
- Helper utilities

## YAML Frontmatter Specification

### Required Fields

```yaml
---
name: skill-name  # Format: lowercase-with-hyphens
                   # Length: 3-64 characters
                   # Restrictions: No "anthropic" or "claude"
                   # Examples: data-analyzer, code-reviewer

description:       # Format: Single line, no line breaks
                   # Length: 100-1024 characters
                   # Structure: Capability + Use when (1-5) + Output
                   # Must include: "Use when:" with numbered list
---
```

### Optional Fields

```yaml
---
allowed-tools:     # List of Claude tools
                   # Common: Read, Write, Edit, Bash, Grep, Glob
                   # Principle: Minimum required set
                   # Security: Restrict for safety

model:             # Specific model requirement
                   # Values: claude-3, claude-3.5, etc.
                   # Default: Any available model
---
```

## Tool Restriction Patterns

### Common Combinations

```yaml
# Read-only analysis
allowed-tools: Read, Grep, Glob

# Content generation
allowed-tools: Write, Edit

# File processing
allowed-tools: Read, Write, Bash

# Code modification
allowed-tools: Read, Edit, Grep, Glob

# Full automation
allowed-tools: Read, Write, Edit, Bash, Grep, Glob

# Web research
allowed-tools: WebSearch, WebFetch, Write
```

### Security Considerations

**Principle of Least Privilege**:
- Only include tools actually used
- Avoid Bash unless executing scripts
- Restrict Edit for read-only skills
- Limit WebFetch for offline skills

## Activation Pattern Testing

### Test Suite Structure

```markdown
## Activation Tests

### MUST Activate (>95% confidence)
1. "create a skill for X"
2. "build capability to Y"
3. "automate Z task"

### SHOULD Activate (>70% confidence)
1. "I need something that does X"
2. "Can you help with Y repeatedly"
3. "Package this workflow"

### MAY Activate (>40% confidence)
1. "This task comes up often"
2. "Reusable solution for X"
3. Related domain mentions

### MUST NOT Activate
1. Unrelated domains
2. Different tool requests
3. One-time tasks
```

## Skill Quality Metrics

### Discovery Score (0-10)

```javascript
function calculateDiscoveryScore(skill) {
  let score = 0;

  // Description quality (5 points)
  if (skill.description.includes("Use when:")) score += 2;
  if (skill.description.match(/\d\)/g)?.length >= 5) score += 2;
  if (skill.description.length > 200) score += 1;

  // Specificity (3 points)
  if (skill.name.length > 8) score += 1;
  if (!skill.name.includes("helper")) score += 1;
  if (skill.description.includes("Outputs")) score += 1;

  // Structure (2 points)
  if (skill.hasExamples) score += 1;
  if (skill.hasReference) score += 1;

  return score;
}
```

### Token Efficiency Score

```javascript
function calculateEfficiency(skill) {
  const coreTokens = countTokens(skill.md);
  const metadataTokens = countTokens(skill.frontmatter);

  if (coreTokens < 1000) return "Excellent";
  if (coreTokens < 1500) return "Good";
  if (coreTokens < 2500) return "Acceptable";
  return "Needs Optimization";
}
```

## Uplift Optimization Strategies

### Token Reduction Techniques

1. **Extract Examples** (30-50% reduction):
   ```bash
   # Move example sections to EXAMPLES.md
   sed -n '/## Example/,/^##/p' SKILL.md >> EXAMPLES.md
   ```

2. **Externalize Patterns** (20-30% reduction):
   ```bash
   # Move pattern library to REFERENCE.md
   sed -n '/## Patterns/,/^##/p' SKILL.md >> REFERENCE.md
   ```

3. **Script Conversion** (40-60% reduction):
   ```bash
   # Convert inline code to executable scripts
   echo '#!/bin/bash' > scripts/process.sh
   sed -n '/```bash/,/```/p' SKILL.md >> scripts/process.sh
   ```

4. **Template Extraction** (15-25% reduction):
   ```bash
   # Move templates to files
   mkdir -p templates
   # Extract and save each template section
   ```

### Description Enhancement

**Before** (Weak):
```yaml
description: Helps with data processing
```

**After** (Strong):
```yaml
description: Process CSV, JSON, and Excel files with filtering and transformation. Use when: 1) Converting between data formats, 2) Filtering rows by conditions, 3) Aggregating data (sum/avg/count), 4) Data validation needed, 5) User mentions ETL or data pipeline. Outputs cleaned data with validation report.
```

## Common Anti-Patterns to Avoid

### ❌ Don't Do This

1. **Kitchen Sink Skill**:
   ```yaml
   name: do-everything
   description: Handles all tasks  # Too broad
   ```

2. **Vague Triggers**:
   ```yaml
   description: Useful for various things  # No specific triggers
   ```

3. **Monolithic Structure**:
   ```markdown
   # 5000+ tokens in single SKILL.md  # Not modular
   ```

4. **Over-Tooling**:
   ```yaml
   allowed-tools: [ALL TOOLS]  # Security risk
   ```

### ✅ Do This Instead

1. **Single Focus**:
   ```yaml
   name: csv-analyzer
   description: Analyze CSV files...  # Specific capability
   ```

2. **Clear Triggers**:
   ```yaml
   description: ... Use when: 1) CSV analysis, 2) ...  # 5 specific cases
   ```

3. **Modular Structure**:
   ```markdown
   # 1000 tokens in SKILL.md + external resources  # Progressive disclosure
   ```

4. **Minimal Tools**:
   ```yaml
   allowed-tools: Read, Write  # Only what's needed
   ```

## Validation Script Specification

### Core Validation Checks

```bash
#!/bin/bash
# scripts/validate.sh

# 1. YAML Syntax
check_yaml_syntax() {
  # Verify proper frontmatter structure
  grep -q "^---$" SKILL.md || return 1
  grep -q "^name:" SKILL.md || return 1
  grep -q "^description:" SKILL.md || return 1
}

# 2. Description Quality
check_description() {
  # Must include "Use when:" with numbered items
  grep -q "Use when:" SKILL.md || return 1
  grep -c "[0-9])" SKILL.md | [ $(cat) -ge 3 ] || return 1
}

# 3. Token Count
check_token_efficiency() {
  words=$(wc -w < SKILL.md)
  [ $words -lt 2000 ] || echo "Warning: High token count"
}

# 4. File Structure
check_modularization() {
  [ -f "EXAMPLES.md" ] || echo "Missing EXAMPLES.md"
  [ -f "REFERENCE.md" ] || echo "Missing REFERENCE.md"
}
```

## Migration Guide: V1 to V2 Skills

### Upgrade Checklist

- [ ] Extract examples to EXAMPLES.md
- [ ] Move reference material to REFERENCE.md
- [ ] Optimize description with 5 triggers
- [ ] Add "Use when:" numbered list
- [ ] Reduce SKILL.md to <1500 tokens
- [ ] Convert patterns to templates
- [ ] Add validation script
- [ ] Test activation patterns
- [ ] Document in README.md

### Backward Compatibility

Skills maintain compatibility through:
- Same YAML frontmatter format
- Same directory structure
- Same activation mechanism
- Enhanced with additional files (ignored by older versions)