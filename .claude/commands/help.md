Execute when user types `/help`:

1. Detect current context by checking:
   - Is `__specification__/` or `CLAUDE.md` present?
   - Does `features/` directory exist?
   - What files exist in most recent feature?
   - Current workflow phase and progress

2. Based on context, provide simplified, targeted help:

**If no __specification__/ directory:**
```
🧭 Getting Started with Navi

You haven't initialized Navi yet.

Quick Start:
→ /navi init

This sets up Navi in your project.
After that, just type /navi to continue.
```

**If __specification__/ exists but no features:**
```
🧭 Navi Ready!

What to do next:
→ /navi specify "Your feature description"

Example:
/navi specify "User authentication with OAuth"

Tip: Just type /navi for guided help
```

**If in specification phase (only spec.md):**
```
🧭 Specification Complete ✓

Your next step:
→ /navi plan

This will create the technical design.
```

**If in planning phase (spec.md + plan.md):**
```
🧭 Plan Complete ✓

Your next step:
→ /navi tasks

This breaks the plan into tasks.
```

**If in implementation (has tasks.md):**
```
⚡ Implementation Progress

Tasks: {completed}/{total} complete

Continue:
→ /navi implement
→ /navi implement --parallel (60% faster)

Check progress:
→ /navi status
```

3. Always include these commands:
```
Core Commands:
• /status - Show current workflow state
• /help - This help (context-aware)
• /session save - Save progress
• /resume - Continue from last checkpoint
• /validate - Check consistency

Skills:
• flow:init - Initialize project
• flow:specify - Create specification
• flow:clarify - Resolve ambiguities
• flow:plan - Technical design
• flow:tasks - Break down work
• flow:implement - Build features
```

4. If user provides a skill name (e.g., `/help flow:specify`), show detailed help for that skill by reading its SKILL.md or EXAMPLES.md file.

Display the appropriate help based on current context.