# Skill Builder: Technical Reference

## Complete YAML Frontmatter Specification

### Required Fields

#### name
- **Type**: String
- **Format**: Lowercase, hyphenated (kebab-case)
- **Length**: 3-30 characters
- **Examples**: `code-review`, `data-processor`, `test-generator`
- **Anti-patterns**: `MySkill`, `skill_1`, `veryLongSkillNameThatIsHardToRemember`

#### description
- **Type**: String
- **Format**: Complete sentences with trigger conditions
- **Length**: 100-500 characters (optimal: 200-300)
- **Structure**: `[Capability]. Use when: [numbered list]. [Output].`
- **Must Include**:
  - Primary capability (active voice)
  - "Use when:" followed by numbered scenarios
  - Expected output/value

### Optional Fields

#### allowed-tools
- **Type**: Comma-separated string
- **Available Tools**:
  - `Read` - Read files
  - `Write` - Create new files
  - `Edit` - Modify existing files
  - `Bash` - Execute shell commands
  - `Grep` - Search file contents
  - `Glob` - Find files by pattern
  - `WebSearch` - Search the web
  - `WebFetch` - Fetch web content
  - `AskUserQuestion` - Interactive prompts
  - `TodoWrite` - Task management
  - `Skill` - Invoke other skills
  - `Task` - Launch sub-agents

#### model (Rarely Used)
- **Type**: String
- **Options**: `claude-3`, `claude-3.5`, `inherit`
- **Default**: System default
- **Use Case**: When skill requires specific model capabilities

## Description Engineering Patterns

### Formula for Effective Descriptions

```
[PRIMARY_CAPABILITY] + [USE_WHEN_LIST] + [OUTPUT_DESCRIPTION]
```

### Trigger Phrase Categories

#### Direct Triggers
Words/phrases that directly indicate need:
- Action verbs: create, generate, analyze, review, transform
- Domain terms: API, database, deployment, testing
- Tool names: Docker, Kubernetes, React, Python

#### Contextual Triggers
Situations that suggest skill relevance:
- Problem descriptions: "needs to be faster", "having errors"
- Goal statements: "want to build", "need to check"
- Question patterns: "how do I", "can you help with"

#### Proactive Triggers
Patterns for autonomous activation:
- File operations: "After creating files"
- Workflow stages: "Before deployment"
- Error conditions: "When tests fail"

### Description Templates by Category

#### Analysis Skills
```yaml
description: Analyze [WHAT] for [INSIGHTS]. Use when: 1) [ANALYSIS_TYPE] requested, 2) User mentions [DOMAIN_TERMS], 3) [PROBLEM_INDICATORS] detected, 4) Quality check needed, 5) Before [MILESTONE]. Generates [OUTPUT_FORMAT] with [VALUE].
```

#### Generation Skills
```yaml
description: Generate [ARTIFACT_TYPE] from [INPUT_TYPE]. Use when: 1) Creating [ARTIFACTS], 2) User says "[TRIGGER_WORDS]", 3) [CONTEXT] requires [ARTIFACT], 4) Automation of [TASK] needed, 5) [WORKSPEC_STAGE]. Produces [OUTPUT] with [CHARACTERISTICS].
```

#### Transformation Skills
```yaml
description: Transform [SOURCE] to [TARGET] with [OPERATIONS]. Use when: 1) Converting between [FORMATS], 2) [DATA_OPERATION] requested, 3) User mentions [TOOLS/FORMATS], 4) [WORKSPEC_NEED], 5) Optimization required. Outputs [RESULT] in [FORMAT].
```

#### Automation Skills
```yaml
description: Automate [PROCESS] using [METHODS]. Use when: 1) Repetitive [TASK] identified, 2) User requests automation, 3) [TRIGGER_EVENTS] occur, 4) Efficiency improvement needed, 5) [WORKFLOW] standardization. Creates [AUTOMATION_TYPE] with [CAPABILITIES].
```

## Progressive Disclosure Architecture

### Token Budget Management

#### Level 1: Metadata (~100 tokens)
```yaml
name: 20 tokens max
description: 80 tokens max
allowed-tools: Negligible
```

#### Level 2: Core Instructions (~2-5k tokens)
```markdown
# Main heading: 10 tokens
## Subheadings: 5-10 tokens each
- Bullet points: 10-20 tokens per line
Code blocks: 50-200 tokens
Total aim: <5000 tokens
```

#### Level 3: Supporting Files (Unlimited)
- No token cost until accessed
- Can be extensive (10k+ tokens per file)
- Load only what's needed

### Content Distribution Strategy

#### What Goes in skill.md
✅ Include:
- Core execution flow
- Essential decision logic
- Primary error handling
- Critical configuration
- Main output format

❌ Exclude:
- Extensive examples (→ examples.md)
- API documentation (→ reference.md)
- Edge cases (→ reference.md)
- Alternative approaches (→ reference.md)
- Historical context (→ readme.md)

#### What Goes in examples.md
✅ Include:
- 3-5 concrete scenarios
- Input/output pairs
- Common variations
- Edge case handling
- Error scenarios

Structure:
```markdown
## Example N: [Scenario Name]
### Context
[Setup description]
### Input
[User request or trigger]
### Execution
[What skill does]
### Output
[Generated result]
```

#### What Goes in reference.md
✅ Include:
- Complete API documentation
- All configuration options
- Technical specifications
- Advanced patterns
- Troubleshooting guide
- Performance considerations

## File Organization Patterns

### Simple Skill (Single File)
```
skill-name/
└── skill.md
```

### Standard Skill (With Examples)
```
skill-name/
├── skill.md
└── examples.md
```

### Comprehensive Skill (Full Documentation)
```
skill-name/
├── skill.md
├── examples.md
├── reference.md
└── readme.md
```

### Complex Skill (With Resources)
```
skill-name/
├── skill.md
├── examples.md
├── reference.md
├── templates/
│   ├── template1.md
│   └── template2.yaml
├── scripts/
│   ├── analyzer.py
│   └── generator.sh
└── schemas/
    └── config.json
```

## Tool Selection Guidelines

### Minimal Tool Access Patterns

#### Read-Only Analysis
```yaml
allowed-tools: Read, Grep, Glob
```
Use for: Code review, analysis, reporting

#### Content Generation
```yaml
allowed-tools: Write
```
Use for: Creating new files only

#### File Modification
```yaml
allowed-tools: Read, Edit
```
Use for: Updating existing files

#### Full File Operations
```yaml
allowed-tools: Read, Write, Edit
```
Use for: Complete file management

#### Automation
```yaml
allowed-tools: Bash, Write
```
Use for: Script execution, automation

#### Research & Analysis
```yaml
allowed-tools: Read, WebSearch, WebFetch
```
Use for: Research-heavy skills

#### Interactive
```yaml
allowed-tools: AskUserQuestion, Read, Write
```
Use for: User-guided workflows

### Tool Security Matrix

| Tool | Risk Level | Use When | Avoid When |
|------|-----------|----------|------------|
| Read | Low | Always safe | - |
| Write | Medium | Creating new content | Overwriting without check |
| Edit | Medium | Specific updates | Bulk modifications |
| Bash | High | Automation required | User input in commands |
| WebFetch | Medium | External data needed | Untrusted URLs |
| WebSearch | Low | Research required | Sensitive topics |

## Validation Checklist

### YAML Syntax Validation
- [ ] Starts with `---`
- [ ] Ends with `---`
- [ ] Uses spaces (not tabs)
- [ ] Proper indentation (2 spaces)
- [ ] Strings quoted if containing special characters
- [ ] No trailing whitespace

### Description Quality Metrics
- [ ] Contains "Use when:" phrase
- [ ] Lists 3+ specific triggers
- [ ] Under 500 characters
- [ ] Active voice used
- [ ] Output described
- [ ] No vague terms ("helps", "various", "stuff")

### Structural Validation
- [ ] skill.md exists and is valid
- [ ] File paths are correct
- [ ] References to other files work
- [ ] Scripts are executable (if present)
- [ ] Templates are valid (if present)

### Discovery Testing
- [ ] Activates on primary trigger phrase
- [ ] Activates on alternative phrasings
- [ ] Doesn't activate on unrelated phrases
- [ ] Appropriate confidence in activation

## Performance Optimization

### Context Usage Optimization

#### Baseline Metrics
- Metadata: ~100 tokens (always)
- skill.md: 2000-5000 tokens (on activation)
- Each reference: 0 tokens (until needed)

#### Optimization Strategies

1. **Frontload Critical Information**
   - Most important instructions first
   - Defer details to reference files
   - Use bullet points over paragraphs

2. **Lazy Loading Patterns**
   ```markdown
   For detailed configuration, see reference.md
   For examples, see examples.md
   ```

3. **Conditional Loading**
   ```markdown
   If working with [CONDITION], load [FILE]
   ```

### Activation Speed Optimization

#### Fast Activation Patterns
- Short, specific skill names
- Clear trigger phrases in description
- Minimal allowed-tools list
- No complex conditional logic

#### Slow Activation Anti-patterns
- Long, generic names
- Vague descriptions
- All tools allowed
- Complex decision trees

## Evolution Patterns

### Skill Versioning Strategy

#### Version 1.0: MVP
- Basic functionality
- Core use cases only
- Minimal error handling

#### Version 2.0: Robustness
- Error handling added
- Edge cases covered
- Performance improved

#### Version 3.0: Enhancement
- Progressive disclosure
- Advanced features
- Integration capabilities

### Refactoring Triggers

When to refactor a skill:
- Activation rate <50%
- Context usage >7k tokens
- Error rate >10%
- User complaints/confusion
- New use cases emerging

### Migration Path

Old skill structure → New structure:
1. Extract examples → examples.md
2. Extract reference → reference.md
3. Optimize description with "Use when:"
4. Add tool restrictions
5. Test activation patterns
6. Deploy and monitor

## Integration Patterns

### Plugin Skills
Location: `plugin-root/skills/skill-name/`
- Auto-discovered on plugin install
- Namespaced to avoid conflicts
- Can reference plugin resources

### Project Skills
Location: `.claude/skills/skill-name/`
- Shared via version control
- Project-specific customization
- Team-wide consistency

### Personal Skills
Location: `~/.claude/skills/skill-name/`
- User-specific workflows
- Personal productivity tools
- Not shared with team

## Testing Methodologies

### Unit Testing Skills

#### Test Cases Structure
```markdown
## Activation Tests
- Phrase: "..." → Should activate
- Phrase: "..." → Should NOT activate

## Execution Tests
- Input: [...] → Output: [...]
- Edge case: [...] → Handles gracefully

## Integration Tests
- With other skills: Compatible
- With tools: Proper restrictions
```

### Performance Testing

Metrics to track:
- Activation accuracy: >90%
- Task completion: >95%
- Context usage: <5k tokens
- Execution time: <30 seconds
- Error rate: <5%

### User Testing

Validation methods:
1. Have others try trigger phrases
2. Monitor activation patterns
3. Collect feedback on results
4. Track manual vs auto invocation
5. Measure time saved

## Common Pitfalls & Solutions

### Pitfall 1: Over-Scoped Skills
**Problem**: Skill tries to do too much
**Solution**: Split into multiple focused skills

### Pitfall 2: Under-Specified Descriptions
**Problem**: Poor discovery/activation
**Solution**: Add specific "Use when:" scenarios

### Pitfall 3: Context Overflow
**Problem**: Too much in skill.md
**Solution**: Implement progressive disclosure

### Pitfall 4: Missing Error Handling
**Problem**: Fails ungracefully
**Solution**: Add error detection and recovery

### Pitfall 5: Tool Permission Issues
**Problem**: Too many or too few tools
**Solution**: Minimize to required tools only

## Success Metrics

### Quantitative Metrics
- Activation accuracy: % correct activations
- Completion rate: % successful executions
- Context efficiency: Average tokens used
- Time saved: Hours automated
- Error rate: % failures

### Qualitative Metrics
- User satisfaction ratings
- Ease of discovery
- Result quality
- Reusability across projects
- Maintenance burden

### ROI Calculation
```
ROI = (Time Saved × Hourly Rate) / Development Time
Target: >10x return within first month
```