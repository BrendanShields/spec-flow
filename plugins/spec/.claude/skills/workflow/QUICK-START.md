# Workflow Quick Start Guide

**Get your first feature built in 5 commands** | ⏱️ 5-30 minutes

---

## Your First Feature (The Essential Path)

### Step 1: Initialize Your Project (5 minutes)

```bash
/spec init
```

**What it does**: Creates `.spec/` directories, initializes state tracking, sets up workflow structure

**You'll get**:
- `.spec/` configuration directory
- `.spec-state/` session tracking (git-ignored)
- `.spec-memory/` persistent memory (committed)
- `features/` directory for your work

**Skip if**: You've already initialized (run once per project)

---

### Step 2: Create Your Specification (15-30 minutes)

```bash
/spec generate "User authentication with email/password"
```

**What it does**: Creates detailed feature specification with user stories, acceptance criteria, priorities

**You'll get**:
- `features/001-user-authentication/spec.md`
- P1/P2/P3 prioritized user stories
- Acceptance criteria for each story
- [CLARIFY] tags for ambiguous requirements

**Pro tip**: Be specific in your feature description. More detail = better spec.

---

### Step 3: Create Technical Plan (30-60 minutes)

```bash
/spec plan
```

**What it does**: Transforms spec into technical design with architecture decisions

**You'll get**:
- `features/001-user-authentication/plan.md`
- Architecture diagrams
- Data models and schemas
- API contracts
- ADRs (Architecture Decision Records)
- Security considerations
- Testing strategy

**Note**: Uses research agent for best practices

---

### Step 4: Break Into Tasks (15-30 minutes)

```bash
/spec tasks
```

**What it does**: Breaks technical plan into executable tasks with dependencies

**You'll get**:
- `features/001-user-authentication/tasks.md`
- Task IDs (T001, T002, etc.)
- Clear dependencies (T002 → T001)
- Priority markers (P1/P2/P3)
- Parallel work indicators [P]
- Estimated effort

---

### Step 5: Implement (2-20 hours, varies by feature)

```bash
/spec implement
```

**What it does**: Executes implementation tasks with progress tracking

**You'll get**:
- Working code
- Passing tests
- Completed tasks
- Updated state tracking

**Note**: Uses implementer agent for parallel execution

---

## 🎉 Congratulations!

You've just completed your first feature using the Spec workflow!

**What you created**:
- ✅ Feature specification (`spec.md`)
- ✅ Technical plan (`plan.md`)
- ✅ Task breakdown (`tasks.md`)
- ✅ Working implementation

**Next**: Start your second feature with `/spec generate "Next feature"`

---

## Common Paths

### Path A: Full Automation (Fastest)

```bash
/spec init
/spec orchestrate
```

**Time**: 3-25 hours (full feature cycle)
**Best for**: Quick prototyping, straightforward features
**Note**: Runs generate → clarify → plan → tasks → implement automatically

---

### Path B: Iterative (Most Control)

```bash
/spec init
/spec generate "Feature"
/spec clarify              # Optional: resolve ambiguities
/spec plan
/spec analyze              # Optional: validate consistency
/spec tasks
/spec implement
```

**Time**: 4-26 hours (with validation steps)
**Best for**: Complex features, team collaboration
**Note**: Full control at each phase

---

### Path C: Brownfield (Existing Codebase)

```bash
/spec discover             # Analyze existing code (30-60 min)
/spec init
/spec blueprint            # Document architecture (45-90 min)
/spec generate "Feature"
# ... continue with Path B
```

**Time**: +2-3 hours upfront analysis
**Best for**: Adding Spec to existing project
**Note**: Discovery informs better architecture decisions

---

## Quick Reference

### Core Commands (Sequential)

| Command | Purpose | Duration | Phase |
|---------|---------|----------|-------|
| `/spec init` | Setup project | 15-30 min | 1: Initialize |
| `/spec generate "..."` | Create spec | 20-45 min | 2: Define |
| `/spec plan` | Technical design | 30-90 min | 3: Design |
| `/spec tasks` | Task breakdown | 20-45 min | 4: Build |
| `/spec implement` | Execute code | 2-20 hours | 4: Build |

### Supporting Tools (Optional)

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/spec discover` | Analyze existing code | Brownfield projects |
| `/spec blueprint` | Document architecture | Need architecture docs |
| `/spec clarify` | Resolve ambiguities | [CLARIFY] tags present |
| `/spec checklist` | Quality validation | Enterprise/compliance |
| `/spec analyze` | Validate consistency | Complex features |
| `/spec update` | Modify specs | Requirements change |
| `/spec metrics` | View progress | Track development |
| `/spec orchestrate` | Full automation | Want hands-off |

---

## Decision Tree: "What Command Do I Run?"

```
START
│
├─ First time? → /spec init
│
├─ Have a project already?
│  ├─ Existing code? → /spec discover → /spec init
│  └─ New project? → /spec init
│
├─ Want to build a feature?
│  ├─ No spec yet? → /spec generate "description"
│  ├─ Have spec, no plan? → /spec plan
│  ├─ Have plan, no tasks? → /spec tasks
│  └─ Have tasks? → /spec implement
│
├─ Need to change requirements? → /spec update "changes"
│
├─ Want to automate everything? → /spec orchestrate
│
└─ Check progress? → /spec metrics
```

---

## When Things Go Wrong

### "I'm stuck in clarify with too many questions"

**Solution**: Skip for now
```bash
/spec plan  # Continue workflow, [CLARIFY] tags remain
```

Later: Return to clarify after seeing plan context

---

### "My implementation failed midway"

**Solution**: Resume from where you left off
```bash
/spec implement --continue
```

Or restart specific task:
```bash
/spec implement --task=T003
```

---

### "I need to change requirements"

**Solution**: Update and propagate changes
```bash
/spec update "New requirements description"
/spec analyze              # Validate changes
/spec tasks --update       # Update task breakdown
/spec implement --continue # Continue implementation
```

---

### "I don't know where I am"

**Solution**: Check status
```bash
/spec status
```

Shows:
- Current phase
- Current feature
- Completed steps
- Next recommended action

---

### "I want to see everything"

**Solution**: Load workflow map
```bash
# In conversation, ask:
"Show me the complete workflow map"
```

Or read: `navigation/workflow-map.md`

---

## Key Concepts (5-Minute Version)

### Priorities

- **P1 (Must Have)**: Core functionality, blocks release
- **P2 (Should Have)**: Important but can defer
- **P3 (Nice to Have)**: Optional enhancements

### Workflow Phases

1. **Initialize**: Set up project structure
2. **Define**: Create feature specifications
3. **Design**: Create technical plans
4. **Build**: Implement and test
5. **Track**: Monitor and maintain

### File Artifacts

- **spec.md**: What to build (user stories, acceptance criteria)
- **plan.md**: How to build it (architecture, design decisions)
- **tasks.md**: Step-by-step implementation (dependencies, estimates)

### Markers

- **⭐ CORE**: Required, sequential workflow
- **🔧 TOOL**: Optional, contextual support
- **[CLARIFY]**: Ambiguous requirement needs resolution
- **[P]**: Task can run in parallel

---

## Examples

### Example 1: Simple Feature (Quick)

```bash
# 1. Initialize (once)
/spec init

# 2. Feature in one go
/spec orchestrate
# When prompted: "User profile page with avatar upload"
# Wait 4-8 hours, feature complete
```

**Time**: ~6 hours total
**Best for**: Straightforward features

---

### Example 2: Complex Feature (Controlled)

```bash
# 1. Initialize (once)
/spec init

# 2. Detailed spec
/spec generate "Payment processing with Stripe integration"

# 3. Review spec.md, resolve ambiguities
/spec clarify

# 4. Technical planning with research
/spec plan

# 5. Validate design
/spec analyze

# 6. Break into tasks
/spec tasks

# 7. Implement step-by-step
/spec implement
```

**Time**: ~15 hours total
**Best for**: Critical features, team collaboration

---

### Example 3: Brownfield Addition

```bash
# 1. Analyze existing code
/spec discover

# 2. Initialize with context
/spec init

# 3. Document existing architecture
/spec blueprint

# 4. Plan feature in context
/spec generate "Add OAuth to existing auth system"

# 5. Continue normal workflow
/spec plan
/spec tasks
/spec implement
```

**Time**: ~18 hours total (includes analysis)
**Best for**: Existing codebases

---

## Pro Tips

### 💡 Tip 1: Use Descriptive Feature Names

**Good**: `/spec generate "User authentication with JWT tokens and refresh mechanism"`
**Bad**: `/spec generate "Auth"`

More detail → better specifications

### 💡 Tip 2: Review Before Moving Forward

After each phase:
1. Read the generated file
2. Make manual edits if needed
3. Then proceed to next phase

Workflow supports manual refinement!

### 💡 Tip 3: Use [CLARIFY] Tags Strategically

Don't block on every ambiguity:
- Critical ambiguities? → Run `/spec clarify`
- Minor details? → Leave [CLARIFY], continue workflow

### 💡 Tip 4: Check Progress Regularly

```bash
/spec metrics
```

Shows:
- Features in progress
- Completion rates
- Time spent per phase
- Bottlenecks

### 💡 Tip 5: Commit Early, Commit Often

Workflow creates multiple checkpoints:
```bash
# After spec
git add features/001-*/spec.md
git commit -m "feat: Add user auth spec"

# After plan
git add features/001-*/plan.md
git commit -m "feat: Add user auth technical plan"
```

Checkpoint protection!

---

## Next Steps

### Learn More

- **Glossary**: `GLOSSARY.md` - Understand terminology
- **Error Recovery**: `ERROR-RECOVERY.md` - Troubleshooting guide
- **Workflow Map**: `navigation/workflow-map.md` - Visual guide
- **Full Review**: `WORKFLOW-REVIEW.md` - Comprehensive analysis

### Customize

- **Templates**: Edit `.spec/templates/` to customize output
- **Architecture**: Run `/spec blueprint` to define standards
- **Hooks**: Set up event hooks for automation

### Get Help

- **In-session**: Ask "What should I do next?"
- **Documentation**: Read `README.md` in plugin root
- **Support**: Check `ERROR-RECOVERY.md` for common issues

---

## Summary: Your First 5 Commands

```bash
1. /spec init                                    # Setup (once)
2. /spec generate "Your feature description"     # What to build
3. /spec plan                                    # How to build
4. /spec tasks                                   # Break it down
5. /spec implement                               # Build it
```

**Time**: 5-30 minutes reading + 4-26 hours execution
**Output**: Complete, working feature
**Next**: Start feature #2!

---

**Welcome to Spec Workflow!** 🚀

You now have everything you need to get started. Pick your path above and begin building!

**Questions?**
- Read the Glossary for terms
- Check Error Recovery if stuck
- Ask Claude for guidance anytime

*Happy building!*
