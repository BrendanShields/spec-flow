Execute when user types `/help`:

1. Detect current context by checking:
   - Is `__specification__/` or `CLAUDE.md` present?
   - Does `features/` directory exist?
   - What files exist in most recent feature?

2. Based on context, provide targeted help:

**If no __specification__/ directory:**
```
📚 Getting Started with Flow

You haven't initialized Flow yet.

Start with:
• flow:init --type=greenfield (new project)
• flow:init --type=brownfield (existing project)

Then:
• flow:specify "Your feature description"
```

**If __specification__/ exists but no features:**
```
📚 Flow Help - Ready to Start

Flow is initialized. Create your first feature:

• flow:specify "Feature description"
  Creates a new feature specification

• /status - Check current state
• /help flow:specify - Detailed help for specify
```

**If in specification phase (only spec.md):**
```
📚 Flow Help - Specification Phase

Current: Specification complete

Next steps:
• flow:clarify - Resolve ambiguous requirements
• flow:plan - Create technical design
• /status - Check current state
```

**If in planning phase (spec.md + plan.md):**
```
📚 Flow Help - Planning Phase

Current: Technical plan complete

Next steps:
• flow:tasks - Break down into tasks
• flow:update - Modify specification
• /status - View progress
```

**If in implementation (has tasks.md):**
```
📚 Flow Help - Implementation Phase

Current: {n}/{total} tasks complete

Next steps:
• flow:implement --continue - Continue implementation
• /status - Check detailed progress
• /session save - Save checkpoint
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