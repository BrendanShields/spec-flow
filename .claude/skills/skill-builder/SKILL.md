---
name: skill-builder
description: Create and uplift Claude Code skills with best practices for discovery, progressive disclosure, and token efficiency. Use when: 1) User wants to create a new skill, 2) Converting repetitive tasks into reusable skills, 3) Improving existing skill performance, 4) User mentions "skill", "capability", or "automation", 5) Packaging domain expertise for reuse. Generates optimized SKILL.md with modular resources and validation.
allowed-tools: Write, Read, Edit, Bash, AskUserQuestion, WebSearch, Grep, Glob
---

# Skill Builder: Token-Efficient Claude Code Skills

Creates world-class skills optimized for discovery and minimal context usage.

## Resource Organization

When this skill is active, Claude operates within the skill-builder directory context.
All file references use **relative paths** as per Claude Code conventions:
- `templates/` - Skill templates
- `scripts/` - Validation and helper scripts
- `EXAMPLES.md` - Usage scenarios
- `REFERENCE.md` - Technical patterns

## Capabilities

- **Create** new skills from requirements
- **Uplift** existing skills for better performance
- **Validate** skill syntax and activation patterns
- **Optimize** for progressive disclosure and token efficiency

## Workflow

### Phase 1: Analyze Requirements

Determine mode and gather information:

```javascript
// For new skill creation
const requirements = {
  capability: "Single focused function",
  triggers: ["explicit phrases", "contextual mentions"],
  tools: ["required Claude tools"],
  complexity: "minimal|standard|comprehensive"
};

// For skill uplift
const analysis = {
  currentTokens: "wc -w SKILL.md",
  discoveryScore: "grep 'Use when:' SKILL.md",
  modularization: "ls *.md | wc -l",
  bottlenecks: ["verbose sections", "inline examples"]
};
```

### Phase 2: Design & Structure

#### 2.1 Craft Discovery Description

**Formula**: `[CAPABILITY] + [5 TRIGGERS] + [OUTPUT]`

**Pattern** (max 1024 chars):
```yaml
description: [Active verb] [domain objects]. Use when: 1) [explicit trigger], 2) [context trigger], 3) [proactive case], 4) [mention of X], 5) [related task]. [Output type].
```

Load proven patterns:
```bash
cat patterns/descriptions.yaml
```

#### 2.2 Progressive Disclosure Architecture

```
Level 1: Metadata (~100 tokens)
  └─ name + description → Always loaded

Level 2: Core Instructions (~1.5k tokens)
  └─ SKILL.md body → Loaded on activation

Level 3: Resources (unlimited)
  ├─ EXAMPLES.md → Loaded when referenced
  ├─ REFERENCE.md → Loaded for details
  ├─ templates/ → Filesystem access
  └─ scripts/ → Executed, not loaded
```

### Phase 3: Implementation

#### Creating New Skills:

1. **Select template** based on complexity:
   ```bash
   cat templates/{minimal|standard|comprehensive}.md
   ```

2. **Generate core SKILL.md** (<1.5k tokens):
   - Essential workflow only
   - Reference external resources
   - No inline examples

3. **Create modular resources** (in new skill's directory):
   - `EXAMPLES.md`: 3-5 concrete scenarios
   - `REFERENCE.md`: Patterns, troubleshooting
   - `scripts/validate.sh`: Syntax checker

   Reference skill-builder's own resources:
   ```bash
   cat EXAMPLES.md              # For example patterns
   cat templates/standard.md    # For structure reference
   ```

4. **Add uplift metadata** for future optimization

#### Uplifting Existing Skills:

1. **Measure current state**:
   ```bash
   wc -w SKILL.md  # Token count
   grep -c "^##" SKILL.md  # Section count
   ls *.md 2>/dev/null | wc -l  # Modularization
   ```

2. **Extract and modularize**:
   - Move examples → `EXAMPLES.md`
   - Move reference → `REFERENCE.md`
   - Convert patterns → templates
   - Replace inline code → scripts

3. **Optimize description** for discovery (5 numbered triggers)

4. **Validate improvements**:
   ```bash
   scripts/validate.sh --before old.md --after new.md
   ```

### Phase 4: Validation

Run comprehensive checks:
```bash
scripts/validate.sh [target-skill-path]
```

**Validates**:
- ✓ YAML syntax correctness
- ✓ Description under 1024 chars with 5 triggers
- ✓ Name conventions (lowercase-hyphenated)
- ✓ Token usage (<1.5k for core SKILL.md)
- ✓ Progressive disclosure structure

**Test activation patterns**:
1. Primary trigger → Must activate
2. Alternative phrase → Should activate
3. Related concept → May activate
4. Unrelated phrase → Must NOT activate

## Configuration

Ask user preferences:
```javascript
{
  "mode": "create|uplift",
  "name": "skill-name",
  "complexity": "minimal|standard|comprehensive",
  "includeExamples": true,
  "includeReference": true,
  "generateScripts": true,
  "targetPath": ".claude/skills/"
}
```

## Output Format

```
✅ Skill {created|uplifted}: {name}
├── SKILL.md ({tokens} tokens - optimized from {original})
├── EXAMPLES.md (3 scenarios)
├── REFERENCE.md (patterns library)
├── scripts/
│   └── validate.sh
└── README.md

📊 Metrics:
- Discovery strength: 9/10 (5 triggers, clear output)
- Token efficiency: {reduction}% reduction
- Activation accuracy: 95% tested
- Progressive levels: 3 (metadata/core/resources)

📝 Next: mv {name}/ ~/.claude/skills/ && test "{trigger}"
```

## Quick Actions

Access skill-builder resources using relative paths:

```bash
cat EXAMPLES.md              # View example scenarios
cat REFERENCE.md             # Technical patterns & guidelines
ls templates/                # Available templates
scripts/validate.sh .        # Validate a skill
```

Remember: Great skills do ONE thing exceptionally well with minimal tokens.