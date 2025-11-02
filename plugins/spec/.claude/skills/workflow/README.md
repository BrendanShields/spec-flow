# Workflow Skill - Spec v3.0 Navigation System

Token-efficient routing system for the complete specification-driven development workflow.

## Overview

The workflow skill is a **lightweight router** (~300 tokens) that provides context-aware navigation through the Spec v3.0 workflow with progressive disclosure architecture.

Instead of loading all 13 skills (~19,500 tokens), this router intelligently loads only what you need when you need it.

## Architecture

```
workflow/
├── SKILL.md                      # Main router (~300 tokens)
│                                 # Always loaded, provides orientation
│
├── ../../docs/                   # Quick reference guides
│   ├── workflow-map.md           # Visual workflow diagram (~600 tokens)
│   ├── skill-index.md            # All 13 skills reference (~800 tokens)
│   └── phase-reference.md        # Phase details and transitions (~900 tokens)
│
├── phases/                       # Phase-specific guides
│   ├── 1-initialize.md           # Phase 1: Initialize (~500 tokens)
│   ├── 2-define.md               # Phase 2: Define (~550 tokens)
│   ├── 3-design.md               # Phase 3: Design (~500 tokens)
│   ├── 4-build.md                # Phase 4: Build (~550 tokens)
│   └── 5-track.md                # Phase 5: Track (~500 tokens)
│
└── [individual skill folders]    # Original 13 skills (loaded on demand)
    ├── spec-init/
    ├── spec-generate/
    ├── spec-clarify/
    ├── spec-plan/
    ├── spec-tasks/
    ├── spec-implement/
    ├── spec-orchestrate/
    ├── spec-discover/
    ├── spec-blueprint/
    ├── spec-update/
    ├── spec-analyze/
    ├── spec-checklist/
    └── spec-metrics/
```

## Token Efficiency

### Before Routing Skill
- **All skills loaded**: ~19,500 tokens
- **Single skill**: ~1,500 tokens (SKILL.md only)
- **With examples**: ~4,500 tokens (+ EXAMPLES.md)
- **Complete skill**: ~6,500 tokens (+ REFERENCE.md)

### With Routing Skill
- **Router only**: ~300 tokens (context and orientation)
- **+ Phase guide**: ~800 tokens (specific phase help)
- **+ Skill detail**: ~2,300 tokens (when needed)
- **+ Examples**: ~5,300 tokens (if stuck)

**Savings**: 81% reduction in default token usage

## Progressive Disclosure Levels

### Level 1: Context (~300 tokens)
**Load**: `workflow/SKILL.md` (router)
**Purpose**: Where am I? What's next?
**Output**:
```
📍 Current Location: Phase 2 (Define Requirements)
🎯 Active Feature: #003-user-authentication
✅ Completed: init, generate
⏳ Current: clarify (2/4 clarifications resolved)
→ Next: spec:plan (after clarifications)
```

### Level 2: Phase Guide (~500-600 tokens)
**Load**: `phases/[N]-[name].md`
**Purpose**: How does this phase work?
**Content**:
- Skills in this phase
- Entry/exit criteria
- Workflow patterns
- Common issues

### Level 3: Skill Detail (~1,500 tokens)
**Load**: `spec-[name]/SKILL.md`
**Purpose**: How do I use this specific skill?
**Content**:
- Execution flow
- Options and flags
- Error handling
- Output format

### Level 4: Examples (~3,000 tokens)
**Load**: `spec-[name]/EXAMPLES.md`
**Purpose**: Show me concrete examples
**Content**:
- Real-world scenarios
- Input/output pairs
- Edge cases
- Common variations

### Level 5: Reference (~2,000 tokens)
**Load**: `spec-[name]/REFERENCE.md`
**Purpose**: Deep technical details
**Content**:
- API specifications
- Configuration options
- Advanced patterns
- Troubleshooting

## Usage Patterns

### Quick Orientation
```
User: "Where am I in the workflow?"

Claude loads: workflow/SKILL.md (~300 tokens)
Shows: Current phase, progress, next steps
```

### Phase Understanding
```
User: "How does the Define phase work?"

Claude loads:
  - workflow/SKILL.md (~300 tokens)
  - phases/2-define.md (~550 tokens)
Total: ~850 tokens

Shows: Phase skills, workflow patterns, exit criteria
```

### Skill Execution
```
User: "How do I run spec:clarify?"

Claude loads:
  - workflow/SKILL.md (~300 tokens)
  - spec-clarify/SKILL.md (~1,500 tokens)
Total: ~1,800 tokens

Shows: Execution flow, options, error handling
```

### Problem Solving
```
User: "I'm stuck with too many [CLARIFY] tags"

Claude loads:
  - workflow/SKILL.md (~300 tokens)
  - spec-clarify/SKILL.md (~1,500 tokens)
  - spec-clarify/EXAMPLES.md (~3,000 tokens)
Total: ~4,800 tokens

Shows: Examples of handling multiple clarifications
```

## Workflow Phases Quick Reference

### Phase 1: Initialize (1-2 hours, one-time)
**Goal**: Setup project infrastructure
**Skills**: init, discover, blueprint
**Output**: `.spec/` structure, architecture docs

### Phase 2: Define (30min-2h per feature)
**Goal**: Create validated specifications
**Skills**: generate, clarify, checklist
**Output**: `spec.md` with user stories

### Phase 3: Design (45min-3h per feature)
**Goal**: Technical design and validation
**Skills**: plan, analyze
**Output**: `plan.md` with ADRs

### Phase 4: Build (2-20h per feature)
**Goal**: Implement and test
**Skills**: tasks, implement
**Output**: Working feature with tests

### Phase 5: Track (ongoing)
**Goal**: Maintain and monitor
**Skills**: update, metrics, orchestrate
**Output**: Updated specs, analytics

## Navigation Commands

**Show current context**:
```
Load: workflow/SKILL.md
Token cost: ~300
```

**Understand workflow**:
```
Load: ../../docs/workflow-map.md
Token cost: ~600
```

**View all skills**:
```
Load: ../../docs/skill-index.md
Token cost: ~800
```

**Phase deep-dive**:
```
Load: phases/[N]-[name].md
Token cost: ~500-600 per phase
```

**Skill details**:
```
Load: spec-[name]/SKILL.md
Token cost: ~1,500 per skill
```

## Design Principles

### 1. Progressive Disclosure
Load only what's needed, when it's needed
- Start minimal (~300 tokens)
- Expand incrementally based on user needs
- Never load all skills at once

### 2. Context Awareness
Router understands where user is in workflow
- Reads `.spec-state/current-session.md`
- Shows relevant next steps
- Provides phase-specific guidance

### 3. Smart Routing
Directs to appropriate documentation
- Quick questions → Router response
- Phase questions → Phase guide
- Skill questions → Skill SKILL.md
- Examples needed → Skill EXAMPLES.md
- Deep dive → Skill REFERENCE.md

### 4. Token Efficiency
Minimize context usage
- Router: 300 tokens (vs 19,500 for all skills)
- Phase guide: 500 tokens (vs 6,500 for 3 skills)
- Skill detail: 1,500 tokens (on demand)
- Examples: 3,000 tokens (when stuck)

### 5. Maintainability
Keep skills independent
- Individual skills unchanged
- Router provides navigation layer
- Phase guides summarize groups
- Navigation docs provide cross-references

## Integration with Existing Skills

The router **does not replace** individual skills. Instead:

1. **Individual skills remain unchanged**
   - Each skill still has SKILL.md, EXAMPLES.md, REFERENCE.md
   - Execution logic stays in individual skills
   - Progressive disclosure within each skill preserved

2. **Router adds navigation layer**
   - Helps users find right skill
   - Provides workflow context
   - Groups skills by phase
   - Shows relationships

3. **Phase guides provide summaries**
   - Aggregate related skills
   - Show workflow patterns
   - Explain phase transitions
   - Quick reference for phase

## Migration from Individual Skills

**Before** (accessing skill directly):
```
User needs clarify → Load spec:clarify SKILL.md (1,500 tokens)
```

**After** (via router):
```
User asks "need to clarify" → Router (300 tokens) → Routes to spec:clarify
```

**Benefit**: Router provides context first, then loads skill

**Before** (uncertain which skill):
```
User: "How do I handle vague requirements?"
Claude: Loads multiple skills to determine (4,500+ tokens)
```

**After** (via router):
```
User: "How do I handle vague requirements?"
Router: Identifies Phase 2, spec:clarify (300 tokens)
Shows: Phase 2 guide (550 tokens) OR spec:clarify SKILL.md (1,500 tokens)
Total: 850 or 1,800 tokens (vs 4,500+)
```

## File Structure Summary

```
workflow/
├── SKILL.md                      # ✅ Main router
├── README.md                     # ✅ This file
│
├── ../../docs/                   # ✅ Quick references
│   ├── workflow-map.md           # ✅ Visual diagram
│   ├── skill-index.md            # ✅ All skills reference
│   └── phase-reference.md        # ✅ Phase details
│
├── phases/                       # ✅ Phase guides
│   ├── 1-initialize.md           # ✅ Phase 1
│   ├── 2-define.md               # ✅ Phase 2
│   ├── 3-design.md               # ✅ Phase 3
│   ├── 4-build.md                # ✅ Phase 4
│   └── 5-track.md                # ✅ Phase 5
│
└── [13 individual skill folders] # ✅ Existing skills (unchanged)
    └── Each with: SKILL.md, EXAMPLES.md, REFERENCE.md
```

## Token Budget Comparison

| Scenario | Before | After | Savings |
|----------|--------|-------|---------|
| Quick orientation | 1,500 | 300 | 80% |
| Phase understanding | 4,500 | 850 | 81% |
| Skill execution | 1,500 | 1,800 | -20%* |
| Problem solving | 6,500 | 4,800 | 26% |
| Complete workflow | 19,500 | 300-5,000† | 75-98% |

\* Skill execution includes router overhead but provides context
† Depends on user's path through progressive disclosure

## Maintenance

### Adding New Skills
1. Create skill in `spec-[name]/` directory
2. Add to `../../docs/skill-index.md`
3. Add to appropriate phase guide
4. Update `workflow/SKILL.md` router references

### Updating Phases
1. Modify `phases/[N]-[name].md`
2. Update `../../docs/phase-reference.md` if transitions change
3. Update `../../docs/workflow-map.md` if flow changes

### Updating Navigation
1. Keep `../../docs/*.md` in sync with skills
2. Update token estimates if files grow
3. Maintain cross-references

## Testing

Validate routing works correctly:
1. **Context detection**: Does router read session state?
2. **Phase routing**: Does it direct to correct phase guide?
3. **Skill routing**: Does it direct to correct skill?
4. **Progressive disclosure**: Does it load incrementally?
5. **Token efficiency**: Are token counts accurate?

## Version

- **Workflow Router**: v1.0
- **Spec Version**: v3.0
- **Architecture**: Progressive Disclosure with 5-Level Loading
- **Token Efficiency**: 81% average reduction

---

**For usage**: Load `workflow/SKILL.md` to start navigation
**For architecture**: This README
**For visual guide**: `../../docs/workflow-map.md`
