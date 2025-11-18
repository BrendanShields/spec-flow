# Progressive Disclosure Guide

How the workflow skill achieves 88% token efficiency through intelligent content loading.

## Overview

### What is Progressive Disclosure?

Progressive disclosure is a content loading strategy that presents only the information users need at each step, revealing additional detail on demand. Instead of loading all documentation upfront, the workflow skill serves content in layers.

### Why It Matters

**Token Reduction**: 88% fewer tokens loaded per typical workflow execution
- Old approach: 19,500 tokens (all skills, all documentation)
- New approach: 2,316 tokens (router + phase + function guide)
- Savings: 17,184 tokens per session

**Benefits**:
- Faster response times (less content to process)
- Lower API costs (fewer tokens consumed)
- Better context utilization (more room for code)
- Clearer user experience (less overwhelming)

### The 5-Tier System

The workflow skill loads content in 5 distinct tiers, each building on the previous:

```
Tier 1: Router          300 tokens     (always loaded)
Tier 2: Phase Guide     +500 tokens    (loaded when entering phase)
Tier 3: Function Guide  +1,500 tokens  (loaded when running function)
Tier 4: Examples        +3,000 tokens  (--examples flag)
Tier 5: Reference       +2,000 tokens  (--reference flag)
```

## The Five Tiers

### Tier 1: Router Only (300 tokens)

**What**: skill.md - Context-aware navigation and routing

**Contains**:
- Workflow phase overview (5 phases)
- Phase summaries and next steps
- Function quick reference list
- Navigation to detailed documentation

**When Loaded**: Always - this is the entry point for all workflow interactions

**Use Case**: "Where am I in the workflow? What's available?"

**Example**:
```bash
/spec                    # Shows current context, next steps
```

**What You Get**:
- Current phase and progress indication
- Available functions in current phase
- Recommended next action
- Links to phase-specific documentation

**Token Cost**: ~300 tokens

---

### Tier 2: Phase Guide (+500 tokens = 800 total)

**What**: phases/X/readme.md - Detailed phase overview

**Contains**:
- Phase purpose and objectives
- Core workflow functions (⭐ REQUIRED)
- Supporting tools (🔧 AS NEEDED)
- Workflow patterns for this phase
- Exit criteria
- Navigation to function guides

**When Loaded**: When user enters a phase or asks about phase details

**Use Case**: "What happens in the Define phase? What functions are available?"

**Example**:
```bash
/spec                    # Router detects you're in Phase 2
                        # Loads phases/2-define/readme.md
```

**What You Get**:
- Understanding of phase workflow
- Which functions to run (required vs optional)
- Common patterns for this phase
- When to move to next phase

**Token Cost**: Router (300) + Phase Guide (500) = ~800 tokens

---

### Tier 3: Function Guide (+1,500 tokens = 2,300 total)

**What**: guide.md - Core function logic and execution flow

**Contains**:
- What the function does
- When to use it
- Step-by-step execution flow
- Error handling
- Output format
- Integration points
- Templates used

**When Loaded**: Default when running any function

**Use Case**: "Execute the generate function now"

**Example**:
```bash
/spec generate "User authentication"
# Loads: Router + Phase 2 README + generate/guide.md
```

**What You Get**:
- Complete instructions to execute the function
- Error handling and recovery
- What files are created/modified
- What happens next in workflow

**Token Cost**: Router (300) + Phase Guide (500) + Function Guide (1,500) = ~2,300 tokens

**This is the typical usage** - sufficient for 90% of workflow executions.

---

### Tier 4: With Examples (+3,000 tokens = 5,300 total)

**What**: examples.md - Real-world usage scenarios

**Contains**:
- Complete examples (3-5 scenarios)
- Greenfield and brownfield examples
- Different feature types (API, UI, data)
- Full input → execution → output flows
- Common variations and edge cases
- Integration examples (JIRA, Confluence)

**When Loaded**: Add `--examples` flag

**Use Case**: "Show me how this works in practice. I'm learning the pattern."

**Example**:
```bash
/spec generate --examples
# Loads: Router + Phase 2 README + generate/guide.md + generate/examples.md
```

**What You Get**:
- Concrete examples you can adapt
- Pattern recognition for different scenarios
- Understanding of input variations
- Real output samples

**When to Use**:
- First time using a function
- Learning workflow patterns
- Need inspiration for your feature
- Unclear how to structure input
- Want to see edge case handling

**Token Cost**: Tier 3 (2,300) + Examples (3,000) = ~5,300 tokens

---

### Tier 5: With Reference (+2,000 tokens = 7,300 total)

**What**: reference.md - Complete technical API documentation

**Contains**:
- Full spec template structure
- Complete field reference
- All configuration options
- Integration API details
- State file specifications
- Advanced customization
- Template variables
- MCP integration patterns

**When Loaded**: Add `--reference` flag

**Use Case**: "I need all the technical details. I'm troubleshooting or customizing."

**Example**:
```bash
/spec plan --reference
# Loads: Router + Phase 3 README + plan/guide.md + plan/reference.md
```

**What You Get**:
- Complete technical specification
- All available options and parameters
- Advanced configuration details
- Integration APIs
- Customization patterns

**When to Use**:
- Troubleshooting errors
- Customizing templates
- Advanced integrations (JIRA/Confluence)
- Understanding state file formats
- Building custom workflows
- Need complete field reference

**Token Cost**: Tier 3 (2,300) + Reference (2,000) = ~5,300 tokens

---

## Decision Tree: Which Level Do I Need?

Ask yourself these questions:

### "Is this my first time using this function?"
→ **YES**: Add `--examples`
→ **NO**: Continue to next question

### "Am I just executing a normal workflow step?"
→ **YES**: Use default (Tier 3 - no flags)
→ **NO**: Continue to next question

### "Do I need to troubleshoot or customize?"
→ **YES**: Add `--reference`
→ **NO**: Continue to next question

### "Do I just want to understand the workflow phases?"
→ **YES**: Just run `/spec` (Tier 1 + 2)
→ **NO**: Continue to next question

### "Am I getting oriented to the workflow?"
→ **YES**: Just run `/spec` (Tier 1 only)

---

## Token Cost Comparison

### Old System (v2.x)
Loading all 13 separate skills with full documentation:

```
13 skills × 1,500 tokens each = 19,500 tokens
Always loaded, regardless of need
```

### New System (v3.0)
Smart loading based on actual usage:

| Scenario | Tiers Loaded | Token Cost | Reduction |
|----------|--------------|------------|-----------|
| Getting oriented | 1 (Router) | 300 | 98% |
| Understanding phase | 1-2 (Router + Phase) | 800 | 96% |
| Executing function | 1-3 (Default) | 2,300 | 88% |
| Learning patterns | 1-4 (With --examples) | 5,300 | 73% |
| Troubleshooting | 1-5 (With --reference) | 7,300 | 63% |

### Typical Usage Distribution

Based on workflow analysis:
- **60%**: Tier 3 (default execution) - 2,300 tokens
- **20%**: Tier 1-2 (navigation) - 300-800 tokens
- **15%**: Tier 4 (with examples) - 5,300 tokens
- **5%**: Tier 5 (with reference) - 7,300 tokens

**Average**: ~2,316 tokens per interaction (88% reduction from v2.x)

---

## Loading Multiple Tiers

### Can you use both --examples and --reference?

**Yes, but typically not needed.** Each serves a different purpose:

**--examples**: Practical patterns and scenarios
**--reference**: Complete technical documentation

### If you load both:

```bash
/spec generate --examples --reference
```

**Token Cost**: Router (300) + Phase (500) + Guide (1,500) + Examples (3,000) + Reference (2,000) = **7,800 tokens**

**When this makes sense**:
- Comprehensive learning session
- Building training materials
- Deep documentation review
- Plugin development

**When it doesn't**:
- Normal workflow execution (too much information)
- Quick task completion
- Follow-up iterations

### Recommended approach:

Load incrementally based on need:
1. Try default (Tier 3) first
2. Add `--examples` if patterns unclear
3. Add `--reference` if need technical details
4. Load both only for comprehensive study

---

## Examples

### Quick Task Execution (Default)

```bash
/spec generate "Shopping cart feature"
# Loads: Tier 1-3 (2,300 tokens)
# You get: Everything needed to create spec.md
```

### Learning a New Function

```bash
/spec plan --examples
# Loads: Tier 1-4 (5,300 tokens)
# You get: Guide + 5 real-world examples with full outputs
```

### Troubleshooting JIRA Integration

```bash
/spec generate --reference
# Loads: Tier 1-3 + 5 (5,300 tokens)
# You get: Guide + complete JIRA MCP API documentation
```

### Just Getting Oriented

```bash
/spec
# Loads: Tier 1-2 (300-800 tokens)
# You get: Current phase, next steps, available functions
```

### Comprehensive Learning Session

```bash
/spec orchestrate --examples --reference
# Loads: Tier 1-5 (7,800 tokens)
# You get: Complete documentation for full workflow automation
```

---

## Best Practices

### Start Small, Expand As Needed

**❌ Don't do this**:
```bash
/spec generate --examples --reference  # First time using
```

**✅ Do this**:
```bash
/spec generate                         # Try default first
# If unclear...
/spec generate --examples              # Add examples
# If still need details...
/spec generate --reference             # Add reference
```

### Match Flags to Your Goal

| Your Goal | Flags to Use |
|-----------|--------------|
| Complete a workflow step | None (default) |
| Learn a pattern | `--examples` |
| Customize template | `--reference` |
| Troubleshoot error | `--reference` |
| Understand workflow | None (just `/spec`) |
| Build integration | `--reference` |

### Examples for Learning, Reference for Troubleshooting

**Use --examples when**:
- First time using function
- Need inspiration
- Want to see variations
- Learning best practices

**Use --reference when**:
- Something's not working
- Need exact field names
- Customizing templates
- Building integrations
- Advanced configuration

### Trust the Defaults

The default (Tier 3) includes everything needed for **90% of use cases**:
- What the function does
- How to execute it
- What files are created
- Error handling
- Next steps

Only add flags when you genuinely need more detail.

---

## Caching & Performance

### Hub State Caching

The workflow router caches session state to avoid redundant loading:

**On first invocation in session**:
```bash
/spec generate
# Reads: {config.paths.state}/current-session.md
# Reads: {config.paths.memory}/workflow-progress.md
# Caches state in memory
```

**On subsequent invocations**:
```bash
/spec plan
# Uses cached state (doesn't re-read files)
# Updates cache as workflow progresses
```

**Token Savings**: ~2,000 tokens per subsequent function call

### Phase Guide Caching

Once a phase guide is loaded, it stays in context:

```bash
/spec generate          # Loads Phase 2 guide (500 tokens)
/spec clarify           # Reuses Phase 2 guide (0 tokens)
/spec checklist         # Reuses Phase 2 guide (0 tokens)
```

### Progressive Context Building

The system builds context progressively:

```
Session Start: 0 tokens
/spec → +300 (router)
/spec generate → +500 (Phase 2) + 1,500 (generate guide) = 2,300 total
/spec clarify → +1,500 (clarify guide) = 3,800 total (reuses Phase 2)
/spec plan → +500 (Phase 3) + 1,500 (plan guide) = 5,800 total
```

Context reuse across same-phase functions reduces total token overhead.

---

## Summary

Progressive disclosure makes the workflow skill efficient and user-friendly:

**5 Tiers**: Router → Phase → Guide → Examples → Reference
**Default**: Tier 3 (2,300 tokens) - sufficient for 90% of use cases
**Expansion**: Add `--examples` (learning) or `--reference` (troubleshooting)
**Reduction**: 88% fewer tokens vs loading everything upfront

**Rule of thumb**:
- Navigation? → Just `/spec`
- Execution? → Default (no flags)
- Learning? → Add `--examples`
- Troubleshooting? → Add `--reference`

Start with defaults, expand only when needed. The system is optimized for fast, efficient workflow execution while keeping deep documentation available on demand.
