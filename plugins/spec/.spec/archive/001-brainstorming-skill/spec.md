---
status: complete
archived: true
archived_date: 2025-11-26
---

# Brainstorming Ideas Skill Specification

**Feature ID**: 001-brainstorming-skill
**Priority**: P2 (Should Have)
**Status**: Clarified
**Created**: 2025-11-20
**Owner**: Development Team

## Overview

A Claude Code skill that helps users systematically brainstorm, organize, and refine ideas for projects, features, or problem-solving. The skill provides structured ideation frameworks, captures ideas efficiently, and helps prioritize outcomes.

## User Stories

### US-001: Initiate Brainstorming Session
**As a** developer
**I want to** start a brainstorming session with a specific topic or problem
**So that I can** generate creative solutions systematically

**Acceptance Criteria:**
- [ ] User can trigger the skill with a topic/problem statement
- [ ] Skill acknowledges the topic and prepares the brainstorming environment
- [ ] Session state is tracked for resume capability
- [ ] Initial context and constraints are captured

### US-002: Select Brainstorming Framework
**As a** user
**I want to** choose from different brainstorming methodologies
**So that I can** use the most appropriate approach for my needs

**Acceptance Criteria:**
- [ ] 4+ frameworks available (Mind Mapping, SCAMPER, Six Thinking Hats, 5 Whys, and more)
- [ ] Each framework has clear description and use cases
- [ ] User can select framework via interactive prompt
- [ ] Default framework is suggested based on problem type

### US-003: Generate and Capture Ideas
**As a** user
**I want to** rapidly generate and capture ideas
**So that I can** build a comprehensive idea pool

**Acceptance Criteria:**
- [ ] Ideas are captured in structured format
- [ ] Support for both individual and batch idea input
- [ ] Ideas are tagged/categorized automatically (Type-based: Feature, Enhancement, Bug Fix, Refactor, Research)
- [ ] No idea is rejected during generation phase
- [ ] Ideas are saved to persistent storage

### US-004: Organize and Group Ideas
**As a** user
**I want to** organize generated ideas into logical groups
**So that I can** identify patterns and themes

**Acceptance Criteria:**
- [ ] Automatic clustering of similar ideas
- [ ] Manual grouping override capability
- [ ] Visual representation of idea relationships using Mermaid diagrams
- [ ] Groups can be named and described
- [ ] Support for hierarchical organization

### US-005: Evaluate and Prioritize Ideas
**As a** user
**I want to** evaluate ideas against criteria and prioritize them
**So that I can** focus on the most promising solutions

**Acceptance Criteria:**
- [ ] Multiple evaluation criteria supported (feasibility, impact, effort)
- [ ] Scoring mechanism using T-shirt sizes (XS, S, M, L, XL) for effort/impact
- [ ] Prioritization matrix generation
- [ ] Top ideas highlighted with rationale
- [ ] Export prioritized list in actionable format

### US-006: Export and Share Results
**As a** user
**I want to** export brainstorming results in various formats
**So that I can** share with team or integrate into workflows

**Acceptance Criteria:**
- [ ] Export to markdown document
- [ ] Export to task list format (compatible with TodoWrite)
- [ ] Export to spec format (compatible with Orbit workflow)
- [ ] Include session metadata and timestamps
- [ ] Shareable summary with key insights

## Technical Requirements

### File Structure
```
.claude/skills/brainstorming/
├── SKILL.md              # Main skill definition
├── templates/
│   ├── frameworks/       # Framework templates
│   │   ├── mindmap.md
│   │   ├── scamper.md
│   │   ├── six-hats.md
│   │   ├── five-whys.md
│   │   └── more-frameworks.md
│   ├── outputs/          # Output format templates
│   │   ├── summary.md
│   │   ├── tasks.md
│   │   └── spec.md
│   └── prompts/          # LLM prompt templates
├── scripts/
│   ├── organize.sh       # Idea organization logic
│   └── evaluate.sh       # Evaluation scoring
└── reference.md          # Technical reference

.brainstorm/              # User project storage
├── sessions/
│   └── {session-id}/
│       ├── ideas.json
│       ├── groups.json
│       ├── evaluation.json
│       └── output.md
└── config.yml            # User preferences
```

### Integration Points

- **Orbit Workflow**: Can feed into spec generation phase
- **TodoWrite**: Can generate task lists from prioritized ideas
- **Task Agent**: Can delegate idea research to spec-researcher
- **MCP Tools**: Optional - skill can leverage available MCP servers when beneficial

### Configuration

```yaml
brainstorming:
  default_framework: "mindmap"
  auto_save: true
  session_timeout: 3600  # seconds
  max_ideas_per_session: 100
  evaluation_criteria:
    - feasibility
    - impact
    - effort
    - innovation
  output_formats:
    - markdown
    - tasks
    - spec
```

## Constraints & Assumptions

- Sessions are ephemeral unless explicitly saved
- Framework selection cannot be changed mid-session
- Ideas are stored locally (no cloud sync initially)
- Evaluation is subjective and user-driven
- Maximum 100 ideas per session for performance

## Success Metrics

- Average ideas generated per session: >20
- Time to first idea: <30 seconds
- Framework utilization: All frameworks used
- Export success rate: >95%
- User satisfaction: Positive feedback on organization

## Dependencies

- Claude Code ≥2.0.0
- Bash ≥4.0 (for scripts)
- Write/Read tools for persistence
- AskUserQuestion for interactivity
- TodoWrite for task export

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Idea overload | High | Limit ideas per session, provide filtering |
| Lost work | High | Auto-save every 5 ideas |
| Poor organization | Medium | Provide reorganization commands |
| Framework confusion | Low | Include framework guide/examples |

## Clarifications Resolved

1. **Frameworks**: Mind Mapping, SCAMPER, Six Thinking Hats, 5 Whys, and additional problem-solving frameworks
2. **Categories**: Type-based classification (Feature, Enhancement, Bug Fix, Refactor, Research)
3. **Visualization**: Mermaid diagrams for idea relationships and mind maps
4. **Scoring**: T-shirt sizes (XS, S, M, L, XL) for effort and impact assessment
5. **MCP Integration**: Optional - skill can leverage available MCP servers when beneficial

## Future Enhancements

- AI-powered idea expansion/refinement
- Collaborative brainstorming sessions
- Historical idea search/reuse
- Integration with external tools (Notion, Jira)
- Voice input support
- Idea validation against requirements

## Acceptance Testing

1. Can initiate session with clear topic
2. Can select from available frameworks
3. Can generate and save 25+ ideas quickly
4. Can organize ideas into 3-5 groups
5. Can evaluate and prioritize top 5 ideas
6. Can export results in all supported formats
7. Can resume interrupted session

---
*Last Updated: 2025-11-20 (Clarifications completed)*
*Next Review: After planning phase*