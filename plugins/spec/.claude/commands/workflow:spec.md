# Workflow Spec

Interactive specification-driven development workflow with guided menus and auto mode.

## What This Does

Single interactive entry point for all Spec operations:

- 🚀 **Auto Mode** - Full automation with checkpoint prompts between phases
- 📝 **Define** - Create feature specifications interactively
- 🎨 **Design** - Technical planning and architecture decisions
- 🔨 **Build** - Task breakdown and implementation execution
- ❓ **Help** - Initialize project, get guidance, or ask questions

Context-aware menus adapt to your current workflow state, guiding you through the right next steps.

## When to Use

- **Starting new work** - Initialize project or create new feature
- **Continuing work** - Resume from where you left off
- **Need guidance** - Not sure what to do next
- **Want automation** - Let Spec handle the full workflow
- **Any time** - This is the main command you'll use

## Implementation

I'll provide an interactive, context-aware menu based on your current workflow state.

### Step 1: Detect Current State

I'll read `{config.paths.state}/current-session.md` to determine:
- Whether Spec is initialized (`.spec/` directory exists)
- Current workflow phase (specification, planning, implementation)
- Active feature and progress
- Available next actions

### Step 2: Present Context-Aware Menu

Based on your state, I'll use AskUserQuestion to show appropriate options:

**🆕 If Not Initialized:**

```
Welcome to Spec Workflow!

You haven't initialized Spec yet. What would you like to do?

Options:
- 🚀 Initialize Project → Set up Spec in this project
- 📚 Learn About Spec → Understand the workflow
- ❓ Ask a Question → Get specific help
```

I'll invoke:
- Initialize → `workflow skill` loads `phases/1-initialize/init/guide.md`
- Learn → Show workflow overview and examples
- Ask → Interactive Q&A about Spec

---

**📋 If Initialized, No Active Feature:**

```
Spec is ready! What would you like to work on?

Options:
- 🚀 Auto Mode → Full automation for new feature
- 📝 Define Feature → Create new specification
- 📊 Track Progress → View metrics and status
- ❓ Get Help → Guidance or questions
```

I'll invoke:
- Auto Mode → Start auto mode flow (see Step 3)
- Define → `workflow skill` loads `phases/2-define/generate/guide.md`
- Track → Show metrics and progress
- Help → Help menu (see Help Mode)

---

**📝 If in Specification Phase:**

```
📍 Current: Specification Phase
Feature: {feature-name}
Status: {spec-status}

What would you like to do next?

Options:
- 🚀 Auto Mode → Continue automatically to design → build
- 🎨 Move to Design → Create technical plan
- 🔄 Refine Specification → Improve quality, resolve [CLARIFY] tags
- 📊 View Specification → Read spec.md
- ❓ Get Help → Specification best practices
```

I'll invoke:
- Auto Mode → Start from design phase
- Design → `workflow skill` loads `phases/3-design/plan/guide.md`
- Refine → `workflow skill` loads `phases/2-define/clarify/guide.md` or `phases/2-define/checklist/guide.md`
- View → Read and display the spec.md file
- Help → Context-specific help

---

**🎨 If in Planning Phase:**

```
📍 Current: Planning Phase
Feature: {feature-name}
Status: {plan-status}

What would you like to do next?

Options:
- 🚀 Auto Mode → Continue automatically to build
- 🔨 Move to Build → Break down into tasks and implement
- 🔄 Refine Design → Review architecture, improve plan
- 📊 View Plan → Read plan.md
- ❓ Get Help → Planning best practices
```

I'll invoke:
- Auto Mode → Start from tasks phase
- Build → `workflow skill` loads `phases/4-build/tasks/guide.md`
- Refine → `workflow skill` loads `phases/3-design/analyze/guide.md`
- View → Read and display the plan.md file
- Help → Context-specific help

---

**🔨 If in Implementation Phase:**

```
📍 Current: Implementation
Feature: {feature-name}
Progress: {completed}/{total} tasks ({percentage}%)

What would you like to do?

Options:
- 🚀 Auto Mode → Continue implementation automatically
- 🔨 Continue Building → Resume task execution
- 🔄 Refine Approach → Improve code quality, add tests
- 📊 View Progress → Detailed task status
- ✅ Validate → Check consistency and quality
- ❓ Get Help → Implementation strategies
```

I'll invoke:
- Auto Mode → Continue implementation with checkpoints
- Continue → `workflow skill` loads `phases/4-build/implement/guide.md` with --continue
- Refine → `workflow skill` loads `phases/3-design/analyze/guide.md` for code review
- View → Show task progress and status
- Validate → `workflow skill` loads `phases/3-design/analyze/guide.md`
- Help → Context-specific help

---

**✅ If Implementation Complete:**

```
🎉 Feature Complete!
Feature: {feature-name}
All tasks completed

What would you like to do next?

Options:
- ✅ Validate & Finalize → Run consistency checks and quality review
- 📊 View Metrics → Development stats and performance
- 📝 Start New Feature → Define next specification
- 📦 Track & Maintain → Update docs, sync external systems
- ❓ Get Help → Next steps guidance
```

I'll invoke:
- Validate → `workflow skill` loads `phases/3-design/analyze/guide.md`
- Metrics → `workflow skill` loads `phases/5-track/metrics/guide.md`
- New Feature → `workflow skill` loads `phases/2-define/generate/guide.md`
- Track → Show tracking menu (similar to /workflow:track)
- Help → Context-specific help

### Step 3: Auto Mode Flow

When user selects **🚀 Auto Mode**, I execute phases with checkpoint prompts:

**Phase Execution Loop:**

1. **Execute Current/Next Phase**
   - Show progress indicator
   - Invoke appropriate workflow skill guide
   - Display completion summary

2. **Checkpoint Prompt** (using AskUserQuestion)
   ```
   Phase {N} Complete: {phase-name}

   {Summary of what was accomplished}

   What would you like to do?

   Options:
   - ✅ Continue to {next-phase} → Proceed automatically
   - 🔄 Refine {current-phase} → Improve before continuing
   - 📊 Review {current-artifact} → View what was created
   - 🛑 Exit Auto Mode → Return to manual control
   ```

3. **Based on Selection:**
   - Continue → Execute next phase, repeat loop
   - Refine → Invoke refinement skill, then re-prompt
   - Review → Display artifact, then re-prompt
   - Exit → Return to main menu

**Auto Mode Phases:**

```
Phase 1: Initialize (if needed)
  ↓ checkpoint
Phase 2: Define → Generate specification
  ↓ checkpoint
Phase 3: Design → Create technical plan
  ↓ checkpoint
Phase 4: Build → Tasks + Implementation
  ↓ checkpoint
Phase 5: Validate → Consistency checks
  ↓ complete
```

### Step 4: Help Mode

When user selects **❓ Help** or **Get Help**:

**If Not Initialized:**
```
How can I help you?

Options:
- 📚 What is Spec? → Overview of spec-driven development
- 🚀 How do I start? → Step-by-step getting started
- 💡 Show examples → See Spec in action
- ❓ Ask a question → Type your specific question
```

**If In Workflow:**
```
Help Topics:

Options:
- 📖 Explain current phase → What is {phase-name}?
- 🎯 What should I do next? → Recommended next steps
- 🔧 Troubleshooting → Common issues and solutions
- 💡 Best practices → Tips for {phase-name}
- 📚 Full workflow → Understand all phases
- ❓ Ask a question → Type your specific question
```

If "Ask a question" selected, I'll use AskUserQuestion with a text input to get their specific question and answer it.

### Step 5: Execute User's Choice

Based on the menu selection, I'll:

1. **Invoke workflow skill** to load the appropriate phase guide
2. **Pass context** from cached state to avoid re-reading
3. **Execute the skill** with the necessary tools (Read, Write, Edit, etc.)
4. **Update state** files after completion
5. **Return to menu** or continue auto mode based on context

## Key Features

**Context Awareness:**
- Menus adapt to your current phase
- Shows relevant options only
- Displays current progress

**Guided Discovery:**
- See all available options
- Understand what each option does
- No need to memorize commands

**Flexible Automation:**
- Auto mode for speed
- Manual control for precision
- Exit/resume at any checkpoint

**Progressive Disclosure:**
- Simple choices at each step
- Detailed information when needed
- Help always available

## Examples

**Example 1: First Time User**

```bash
User: /workflow:spec

Claude presents menu:
  - 🚀 Initialize Project
  - 📚 Learn About Spec
  - ❓ Ask a Question

User selects: Initialize Project

Claude: Initializing Spec workflow...
[Creates .spec/, {config.paths.state}/, {config.paths.memory}/]

Claude presents menu:
  - 🚀 Auto Mode (create new feature)
  - 📝 Define Feature
  - ❓ Get Help

User selects: Auto Mode

Claude: What would you like to build?
[Gathers requirements via AskUserQuestion]

[Executes: Define → Design → Build with checkpoints]
```

**Example 2: Resuming Work**

```bash
User: /workflow:spec

Claude:
  📍 Current: Implementation
  Feature: user-authentication
  Progress: 8/12 tasks (67%)

  Options:
  - 🚀 Auto Mode (continue automatically)
  - 🔨 Continue Building
  - 📊 View Progress

User selects: Auto Mode

Claude: [Continues implementation]
[Checkpoint after each task group]
```

**Example 3: Getting Help**

```bash
User: /workflow:spec

Claude: [Shows menu for current state]

User selects: ❓ Get Help

Claude:
  Help Topics:
  - 📖 Explain current phase
  - 🎯 What should I do next?
  - 🔧 Troubleshooting
  - ❓ Ask a question

User selects: Ask a question

Claude: What would you like to know?

User: How do I handle API authentication in my spec?

Claude: [Provides detailed answer about documenting API auth in specifications]
```

## Integration

This command integrates with:
- **Workflow skill** - Routes to appropriate phase guides
- **Phase guides** - Loads specific guide.md files as needed
- **State management** - Reads/updates `{config.paths.state}/` and `{config.paths.memory}/`
- **Subagents** - Delegates complex tasks (spec:implementer, etc.)

## Benefits

**For New Users:**
- ✅ Discoverable - See all options via menus
- ✅ Guided - Always know what's next
- ✅ Simple - One command to remember

**For Experienced Users:**
- ✅ Fast - Auto mode for speed
- ✅ Flexible - Exit to manual control anytime
- ✅ Powerful - Full workflow automation

**For Everyone:**
- ✅ Context-aware - Menus adapt to your state
- ✅ Recoverable - Resume from any point
- ✅ Helpful - Integrated help system

---

Ready to guide you through specification-driven development! Use `/workflow:spec` anytime you need to work on your project.
