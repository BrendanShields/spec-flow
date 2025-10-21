# 🚀 Flow Quick Start Guide

Welcome to Flow! This guide will get you building in under 5 minutes.

## 📦 Installation (30 seconds)

```bash
# Check if Flow is installed
market:list

# If not installed:
market:install flow
```

## 🎯 Choose Your Adventure

### Option A: "I want Claude to do everything" (Recommended)

Just type what you want to build in natural language:

```bash
"Build a todo app with user authentication"
```

Claude will:
1. ✅ Detect your intent
2. ✅ Suggest using flow:orchestrate
3. ✅ Run the complete workflow automatically
4. ✅ Generate specs, plan, tasks, and implement everything
5. ✅ Save your progress automatically

**That's it! You're done!** ✨

### Option B: "I want to see each step"

Run the orchestrator but with confirmation:

```bash
flow:orchestrate
```

You'll see:
```
📋 Next Step: flow:init
This will initialize your project.
Continue? [Y/n]: Y

📋 Next Step: flow:specify
This will generate specifications.
Continue? [Y/n]: Y

[... and so on ...]
```

### Option C: "I want full control"

Run each skill manually:

```bash
# 1. Initialize your project
flow:init

# 2. Define your architecture (optional but recommended)
flow:blueprint

# 3. Create specifications
flow:specify "Your project description here"

# 4. Generate technical plan
flow:plan

# 5. Create task list
flow:tasks

# 6. Implement!
flow:implement
```

## 🎪 Real Examples

### Example 1: E-commerce Platform (2 minutes)

```bash
"Create an e-commerce platform with products, cart, and checkout"
```

**What happens:**
```
🎯 Intent detected: flow:orchestrate
📊 Starting complete workflow...

✅ Project initialized
✅ Architecture: Microservices with React + Node.js
✅ Specification: 12 user stories (P1: 5, P2: 4, P3: 3)
✅ Plan: API design, database schema, components
✅ Tasks: 47 tasks generated
🚀 Implementation started...

[5 minutes later]

✅ Complete!
   - 23 files created
   - 8 tests passing
   - API documented
   - Ready to run!
```

### Example 2: Add Feature to Existing Project (1 minute)

```bash
"Add real-time notifications"
```

**What happens:**
```
🎯 Intent detected: flow:specify
📝 Generating feature specification...

✅ Feature spec created: features/002-notifications/spec.md
💡 Next step: flow:plan

Continue? [Y]: Y

✅ Technical plan created
✅ 18 tasks generated
🚀 Ready to implement!
```

### Example 3: Quick Prototype (30 seconds)

```bash
flow:specify "Chat interface prototype" --skip-validation
flow:implement --skip-checklists
```

**What happens:**
```
✅ Minimal spec generated (no validation)
🚀 Quick implementation (no quality checks)
⚡ Done in 30 seconds!
```

## 💡 Pro Tips for Beginners

### Tip 1: Let Claude Guide You

Don't memorize skill names! Just describe what you want:

```bash
# Instead of: flow:specify
"I need to create a new feature"

# Instead of: flow:plan
"How should I build this?"

# Instead of: flow:implement
"Let's code this"
```

### Tip 2: Use Session Continuity

You can leave and come back anytime:

```bash
# Monday
"Build a blog platform"
[Work for a while]
[Close terminal]

# Tuesday
[Open terminal]
# Claude remembers where you left off!
"Continue where we left off"
```

### Tip 3: Watch the Progress

Flow shows real-time progress:

```
📊 Implementation Progress
==========================
Completed: ████████░░░░ 67%

Currently running (parallel):
  Creating models...    ███░░ 60%
  Setting up API...     ████░ 80%
  Writing tests...      ██░░░ 40%
```

### Tip 4: Trust the Automation

Flow handles:
- ✅ Code formatting automatically
- ✅ Prerequisite checking
- ✅ Error recovery
- ✅ Parallel execution
- ✅ Progress tracking

## 🎓 Understanding the Workflow

### What Each Step Does

1. **flow:init** - Sets up project structure
2. **flow:blueprint** - Defines how you'll build (architecture, tech stack)
3. **flow:specify** - Defines what you'll build (features, requirements)
4. **flow:plan** - Figures out technical approach
5. **flow:tasks** - Breaks down into specific tasks
6. **flow:implement** - Actually builds everything

### The Magic of Orchestration

`flow:orchestrate` runs ALL these steps automatically in the right order!

## 🔧 Common Scenarios

### "I'm starting a new project"

```bash
"Build a [your project type] application"
# Let orchestration handle everything
```

### "I'm adding to an existing project"

```bash
"Add [feature] to my application"
# Flow detects existing project and adapts
```

### "I want to try different approaches"

```bash
flow:specify "My feature"
flow:plan           # See approach 1
flow:plan --update  # Try different approach
```

### "I want to work on specific priorities"

```bash
flow:tasks --filter=P1    # Only P1 tasks
flow:implement            # Implements P1 first
```

## 🎯 Quick Commands Cheat Sheet

| What You Want | What to Type |
|--------------|--------------|
| Build complete project | `"Build a [description]"` |
| Add new feature | `"Add [feature] to my app"` |
| Check progress | Flow shows automatically |
| Resume work | `"Continue where we left off"` |
| See what's next | `"What's the next step?"` |
| Run everything | `flow:orchestrate` |
| Get help | `"How do I [task]?"` |

## 🚨 If Something Goes Wrong

### "Prerequisites not met"
**Fix**: Just follow the suggestion
```bash
Error: Missing spec.md
Fix: Run flow:specify first
```

### "I don't know what to do next"
**Fix**: Ask Claude
```bash
"What should I do next?"
# Claude will check state and suggest
```

### "I want to start over"
**Fix**: Re-initialize
```bash
flow:init --reconfigure
```

## 🎉 Your First Project in 60 Seconds

Try this right now:

```bash
# Step 1: Type this
"Build a simple blog with posts and comments"

# Step 2: Say yes when asked
Continue with flow:orchestrate? [Y/n]: Y

# Step 3: Watch the magic happen!
# (Grab a coffee, it'll be done when you get back)

# Step 4: Check what was built
ls -la
# You'll see your complete project!
```

## 🏃‍♂️ What's Next?

Once you're comfortable:

1. **Try different project types**: "Build a REST API", "Build a mobile app"
2. **Experiment with options**: `--skip-validation` for speed, `--filter=P1` for priorities
3. **Explore the generated code**: Flow creates production-quality code
4. **Customize your workflow**: Edit CLAUDE.md for preferences

## 💬 Getting Help

- **See examples**: Check `plugins/flow/.claude/skills/*/examples.md`
- **Understand a skill**: Read `plugins/flow/.claude/skills/*/SKILL.md`
- **Check your progress**: Look at `.flow/.state.json`

## 🎊 Welcome to Flow!

You're now ready to build anything. Just describe what you want and let Flow handle the rest!

```bash
# Your journey starts here:
"Build something amazing"
```

Remember: **You don't need to memorize anything**. Just describe what you want to build, and Claude + Flow will guide you through everything! 🚀