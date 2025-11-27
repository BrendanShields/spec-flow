# Technical Plan: Suggesting Tooling Skill

## Architecture

The skill follows a three-phase approach:
1. **Analysis** - Examine codebase patterns using lightweight heuristics
2. **Matching** - Map detected patterns to skill/agent templates
3. **Generation** - Use existing skills to create approved tooling

Leverages existing infrastructure:
- `analyzing-codebase` agent patterns for discovery
- `creating-skills` skill for skill generation
- `creating-agents` skill for agent generation

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Main workflow and pattern matching | None |
| reference.md | Detailed pattern catalog | SKILL.md |
| patterns/skills.md | Skill suggestion patterns | reference.md |
| patterns/agents.md | Agent suggestion patterns | reference.md |

## Skill Structure

```
.claude/skills/suggesting-tooling/
├── SKILL.md              # Main workflow (~200 lines)
├── reference.md          # Pattern catalog
└── patterns/
    ├── skills.md         # Skill pattern mappings
    └── agents.md         # Agent pattern mappings
```

## Content Design

### SKILL.md Sections

1. **Frontmatter** - name, description with trigger words
2. **Quick Start** - 3-step analysis flow
3. **Workflow** - Step-by-step with progress tracker
4. **Pattern Detection** - What signals to look for
5. **Suggestion Format** - How to present findings
6. **Generation Flow** - Integration with creating-skills/agents

### Pattern Categories

| Category | Signals | Suggested Tooling |
|----------|---------|-------------------|
| Testing | jest/pytest/mocha present | testing-code skill |
| API | REST routes, GraphQL | api-testing agent |
| Database | Prisma, migrations | db-migration skill |
| Deployment | Dockerfile, CI configs | deploying-code skill |
| Documentation | Many markdown files | documenting-code skill |
| Code Quality | ESLint, Prettier | linting-code skill |
| Security | Auth patterns, JWT | security-review agent |

### Analysis Heuristics

Lightweight checks (no deep analysis):
1. File extension counts (language detection)
2. Config file presence (framework detection)
3. Directory patterns (architecture style)
4. Script commands (workflow detection)
5. Existing .claude/ contents (gap analysis)

### Suggestion Output Format

```markdown
## Tooling Suggestions

### Skills (automate repetitive tasks)

| # | Skill | Rationale | Impact |
|---|-------|-----------|--------|
| 1 | testing-code | Jest detected, no testing skill exists | P1 |
| 2 | deploying-code | Dockerfile present, manual deploys | P2 |

### Agents (delegate complex tasks)

| # | Agent | Rationale | Impact |
|---|-------|-----------|--------|
| 1 | code-reviewer | PR workflow detected, no reviewer | P1 |
| 2 | security-scanner | Auth patterns found, no security agent | P2 |

## Generate?

Select items to generate, or "Skip" to finish.
```

## Implementation Phases

1. **Phase 1: Core Skill**
   - SKILL.md with workflow
   - Basic pattern detection
   - Suggestion output format

2. **Phase 2: Pattern Library**
   - reference.md with full catalog
   - patterns/skills.md mappings
   - patterns/agents.md mappings

3. **Phase 3: Integration**
   - creating-skills invocation
   - creating-agents invocation
   - Generation confirmation flow

## Integration Points

### With analyzing-codebase agent
- Can run analyzing-codebase first for deep analysis
- Or use lightweight built-in heuristics for quick scan

### With creating-skills skill
- Pass detected context as requirements
- Skip requirement gathering (already done)
- Generate directly from pattern template

### With creating-agents skill
- Pass detected context as requirements
- Suggest appropriate tools based on task
- Generate with focused system prompt

## Data Flow

```
User invokes skill
    ↓
Analyze codebase (lightweight)
    ↓
Match patterns to templates
    ↓
Present suggestions
    ↓
User approves subset
    ↓
For each approved skill:
    → Invoke creating-skills with context
    ↓
For each approved agent:
    → Invoke creating-agents with context
    ↓
Report created tooling
```

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-suggesting | User fatigue | Limit to top 3-5 suggestions |
| False positives | Wasted effort | Require explicit approval |
| Pattern mismatch | Wrong tooling | Include rationale for validation |
| Skill/agent bloat | Maintenance burden | Prioritize by impact |
