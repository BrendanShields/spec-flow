# Workflow Quick Start Guide

**Get your first feature built in 5 steps using the /spec command**

---

## Your First Feature (The Essential Path)

### Step 1: Run the Workflow Command

```bash
/spec
```

**What happens**: Claude presents a context-aware menu based on your current state

**First time?** You'll see:
```
Welcome to Spec Workflow!

What would you like to do?
- 🚀 Initialize Project
- 📚 Learn About Spec
- ❓ Ask a Question
```

**Select**: "🚀 Initialize Project"

---

### Step 2: Initialization Complete

After initialization, run `/spec` again.

**You'll see**:
```
Spec is ready! What would you like to work on?
- 🚀 Auto Mode (full automation with checkpoints)
- 📝 Define Feature (manual control)
- 📊 Track Progress
- ❓ Get Help
```

**Select**: "🚀 Auto Mode" for guided automation, OR "📝 Define Feature" for manual control

---

### Step 3: Define Your Feature

**If you selected Auto Mode**: Claude will prompt you for feature details

**If you selected Define Feature**: You'll be guided through specification creation

**Enter your feature description**, for example:
```
User authentication with email/password, JWT tokens, and refresh mechanism
```

**What gets created**:
- `.spec/features/001-your-feature/spec.md` (specification with user stories)
- Automatically tracked in state management

---

### Step 4: Continue Through Phases

After each phase completes, you'll see a **checkpoint**:

```
Phase Complete: [Phase Name]

What was accomplished:
- [Summary of work done]

What would you like to do?
- ✅ Continue to [Next Phase]
- 🔄 Refine [Current Phase]
- 📊 Review [Artifact Created]
- ⏸️ Pause (resume later)
```

**Workflow Phases**:
1. **Define** → Creates `spec.md` (user stories, acceptance criteria)
2. **Design** → Creates `plan.md` (technical architecture, ADRs)
3. **Build** → Creates `tasks.md` → Implements code
4. **Validate** → Quality checks, consistency validation

**At each checkpoint**: Select "Continue" to proceed, or "Pause" to stop and resume later

---

### Step 5: Resume Anytime

If you pause or get interrupted, simply run:

```bash
/spec
```

**You'll see**:
```
📍 Current: [Your Phase]
Feature: [Your Feature Name]
Progress: [X/Y tasks] ([percentage]%)

What would you like to do?
- 🚀 Continue [Current Phase]
- 📊 View Progress
- 🔄 Refine Work
```

The workflow remembers where you left off!

---

## 🎉 Congratulations!

You've just completed your first feature using the Spec workflow!

**What you created**:
- ✅ Feature specification (`spec.md`)
- ✅ Technical plan (`plan.md`)
- ✅ Task breakdown (`tasks.md`)
- ✅ Working implementation

**Next**: Run `/spec` → Select "📝 Define Feature" to start your second feature!

---

## Common Workflows

### Workflow A: Full Automation (Fastest)

```
1. /spec
2. Select: 🚀 Auto Mode
3. Enter feature description
4. At each checkpoint: Select ✅ Continue
5. Done!
```

**Best for**: Quick features, prototyping, straightforward requirements

**Time**: Runs all phases automatically with oversight checkpoints

---

### Workflow B: Manual Control (Most Control)

```
1. /spec
2. Select: 📝 Define Feature
3. Enter feature description
   [spec.md created]
4. /spec
5. Select: Move to Design
   [plan.md created]
6. /spec
7. Select: Move to Build
   [tasks.md created, implementation executes]
8. Done!
```

**Best for**: Complex features, team collaboration, careful review

**Time**: You control pace, can pause/resume at any point

---

### Workflow C: Resume Interrupted Work

```
1. /spec
2. See: "📍 Current: [Phase], Progress: [X%]"
3. Select: 🚀 Continue [Phase]
4. Work resumes from where you left off
```

**Best for**: Long-running features, interrupted sessions

**Time**: No progress lost, seamless resumption

---

## Menu Navigation Guide

### Main Menu States

**Not Initialized**:
```
- 🚀 Initialize Project
- 📚 Learn About Spec
- ❓ Ask a Question
```

**No Active Feature**:
```
- 🚀 Auto Mode
- 📝 Define Feature
- 📊 Track Progress
- ❓ Get Help
```

**In Specification Phase**:
```
- 🚀 Auto Mode (continue automatically)
- 🎨 Move to Design
- 🔄 Refine Specification
- 📊 View Specification
- ❓ Get Help
```

**In Planning Phase**:
```
- 🚀 Auto Mode
- 🔨 Move to Build
- 🔄 Refine Design
- 📊 View Plan
- ❓ Get Help
```

**In Implementation Phase**:
```
- 🚀 Auto Mode
- 🔨 Continue Building
- 📊 View Progress
- ✅ Validate
- ❓ Get Help
```

**Feature Complete**:
```
- ✅ Validate & Finalize
- 📊 View Metrics
- 📝 Start New Feature
- 📦 Track & Maintain
```

---

## Decision Tree: "What Should I Do?"

```
START
│
├─ First time using Spec?
│  └─ Run: /spec → Select "Initialize Project"
│
├─ Want to build a feature?
│  ├─ Quick and automated? → Select "Auto Mode"
│  └─ Want control? → Select "Define Feature" → Step through manually
│
├─ Have incomplete work?
│  └─ Run: /spec → Select "Continue [Phase]"
│
├─ Need to change requirements?
│  └─ Run: /spec → Select "Refine [Current Artifact]"
│
├─ Want to see progress?
│  └─ Run: /spec-track → Select "View Metrics"
│
└─ Stuck or confused?
   └─ Run: /spec → Select "Get Help"
```

---

## When Things Go Wrong

### "I don't see any menus, just text"

**Problem**: Commands aren't presenting interactive menus yet (implementation pending)

**Solution**: This is expected in current version. Menus are being implemented in Phase 1-4 of the refactoring.

**Workaround**: Follow the documented workflow manually using the phase guides

---

### "My workflow state is lost"

**Problem**: State files might be missing or corrupted

**Solution**: Check for `.spec/state/current-session.md`

```bash
# View current state
cat .spec/state/current-session.md

# If missing, reinitialize
/spec → Select "Initialize Project"
```

---

### "I need to change requirements mid-workflow"

**Solution**: Use the Refine option at any checkpoint

```
1. /spec
2. Select: 🔄 Refine [Current Artifact]
3. Make your changes
4. Continue from where you left off
```

---

### "I want to start over"

**Solution**: Begin a new feature

```
1. Complete or archive current feature
2. /spec
3. Select: 📝 Start New Feature
```

---

## Key Concepts (5-Minute Version)

### The Workflow Command

**One command for everything**: `/spec`

- First time: Initializes project
- No feature: Start new feature
- In progress: Resume or continue
- Complete: Start next feature

**Context-aware**: Shows different options based on where you are

---

### Checkpoints

**What**: Decision points requiring your input

**When**: After every phase, after significant work

**Options at each checkpoint**:
- ✅ Continue → Proceed to next step
- 🔄 Refine → Improve current work
- 📊 Review → View what was created
- ⏸️ Pause → Stop here, resume later

**Why**: You maintain control, can review before proceeding

---

### Workflow Phases

1. **Initialize**: Set up project structure (once per project)
2. **Define**: Create feature specification (what to build)
3. **Design**: Create technical plan (how to build)
4. **Build**: Implement and test (build it)
5. **Track**: Monitor and maintain (keep it running)

**Linear flow**: Each phase builds on the previous

---

### File Artifacts

- **spec.md**: WHAT to build (user stories, acceptance criteria)
- **plan.md**: HOW to build it (architecture, design decisions)
- **tasks.md**: STEPS to execute (subtasks, dependencies, priorities)

**Location**: `.spec/features/{feature-id}/`

---

### State Management

- **Session state** (`.spec/state/`): Where you are right now, git-ignored
- **Memory** (`.spec/memory/`): Persistent history, committed to git

**Benefit**: Resume anytime, progress never lost

---

### Priorities

- **P1 (Must Have)**: Core functionality, blocks release
- **P2 (Should Have)**: Important but can defer
- **P3 (Nice to Have)**: Optional enhancements

**Applied to**: User stories, tasks

---

## Examples

### Example 1: Simple Feature (Auto Mode)

```
User: /spec

Claude: [Shows menu]
Spec is ready! What would you like to work on?
- 🚀 Auto Mode
- 📝 Define Feature
- 📊 Track Progress

User: Selects "Auto Mode"

Claude: What would you like to build?

User: "User profile page with avatar upload"

Claude: [Executes workflow]
- ✅ Specification created
- Checkpoint: Continue to Design? [User: Yes]
- ✅ Technical plan created
- Checkpoint: Continue to Build? [User: Yes]
- ✅ Tasks generated
- ✅ Implementation complete

Claude: Feature complete! Start another?
```

**Time**: ~30-60 minutes with checkpoints

---

### Example 2: Complex Feature (Manual Control)

```
User: /spec

Claude: [Menu]

User: Selects "Define Feature"

Claude: What would you like to build?

User: "Payment processing with Stripe integration, including webhooks, refunds, and subscription management"

Claude: [Creates detailed spec.md]

User: [Reviews spec.md, makes manual edits]

User: /spec

Claude: [Menu shows "In Specification Phase"]

User: Selects "Move to Design"

Claude: [Creates plan.md with architecture]

User: [Reviews plan.md, adds ADRs]

User: /spec

User: Selects "Move to Build"

Claude: [Creates tasks.md, starts implementation]
```

**Time**: 2-4 hours with review time

---

### Example 3: Resume Interrupted Work

```
# Yesterday, you started a feature and paused at planning

User: /spec

Claude: [Detects state]
📍 Current: Planning Phase
Feature: user-authentication
Progress: 50% (plan.md created, tasks pending)

What would you like to do?
- 🚀 Continue to Build
- 🔄 Refine Design
- 📊 View Plan

User: Selects "Continue to Build"

Claude: [Resumes from where you left off]
```

**Benefit**: Zero context loss

---

## Pro Tips

### 💡 Tip 1: Use Descriptive Feature Names

**Good**: "User authentication with JWT tokens, refresh mechanism, and password reset flow"

**Bad**: "Auth"

**Why**: Better specifications, clearer plans, easier to resume

---

### 💡 Tip 2: Review at Checkpoints

Don't blindly click Continue. At each checkpoint:
1. Review what was created
2. Make manual edits if needed
3. Then continue

**Workflow supports hybrid automation + manual refinement**

---

### 💡 Tip 3: Use Auto Mode for Speed, Manual for Control

- **Auto Mode**: Quick features, prototypes, familiar patterns
- **Manual Mode**: Complex features, new patterns, learning

**You can switch**: Start in Auto, pause, switch to Manual

---

### 💡 Tip 4: Check Progress Regularly

```
/spec-track → Select "View Metrics"
```

Shows:
- Features in progress
- Completion rates
- Time spent per phase
- Bottlenecks

---

### 💡 Tip 5: Commit Early, Commit Often

```bash
# After spec created
git add .spec/features/001-*/spec.md
git commit -m "feat: Add feature spec"

# After plan created
git add .spec/features/001-*/plan.md
git commit -m "feat: Add technical plan"

# After implementation
git add .spec/features/001-*/ src/
git commit -m "feat: Implement feature"
```

**Benefit**: Checkpoint protection, easy rollback

---

## Next Steps

### Learn More

Run `/spec` → Select "Get Help" for:
- Detailed phase explanations
- Best practices
- Troubleshooting
- Architecture documentation

### Customize

- **Templates**: Edit `.spec/templates/` to customize output format
- **Config**: Modify `.spec/.spec-config.yml` for paths, naming conventions

### Get Help

- **In-session**: `/spec` → "Get Help" → Ask specific question
- **Documentation**: `claude.md` in plugin root
- **Issues**: Report problems at GitHub

---

## Summary: The Essential Workflow

```
1. /spec                                # Start
2. Select: Initialize (first time only)
3. Select: Auto Mode OR Define Feature           # Begin feature
4. Enter: Feature description
5. At checkpoints: Continue OR Refine OR Pause   # Control flow
6. Done: Feature complete, start next!
```

**That's it!** One command, context-aware menus, checkpoint control.

---

**Welcome to Spec Workflow!** 🚀

You now have everything you need to build features systematically. The workflow guides you through specification → design → implementation with oversight at every step.

**Questions?**
- Run `/spec` → "Get Help"
- Read `claude.md` for detailed documentation
- Ask Claude for guidance anytime

*Happy building with Spec!*
