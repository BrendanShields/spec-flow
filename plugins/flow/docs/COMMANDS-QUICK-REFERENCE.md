# Flow Commands: Quick Reference Card

## 🚀 Essential Commands (Use These Daily)

```bash
/status              # Where am I? What's next?
/help                # Context-aware help
/session save        # Save progress checkpoint
/resume              # Continue from last session
/validate            # Check consistency
```

## 📋 Workflow Commands

### Initialize & Setup
```bash
/flow-init                      # Initialize Flow in project
/flow-init --type=greenfield    # New project setup
/flow-init --type=brownfield    # Existing codebase
/flow-blueprint                 # Define architecture
```

### Feature Development
```bash
/flow-specify "Feature description"     # Create specification
/flow-clarify                           # Resolve ambiguities
/flow-plan                              # Technical design
/flow-tasks                             # Break down work
/flow-implement                         # Execute tasks
```

### Modifications
```bash
/flow-update "New requirements"         # Update specification
/flow-implement --continue              # Resume implementation
/flow-implement --task=T005             # Start from specific task
```

## 🔍 Utility Commands

### Status & Help
```bash
/status                         # Current state & progress
/status --verbose               # Detailed status
/help                           # Context-aware help
/help /flow-specify             # Help for specific command
```

### Session Management
```bash
/session save                   # Save current state
/session save --name="checkpoint"  # Named checkpoint
/session restore                # Restore latest
/session list                   # List checkpoints
/resume                         # Smart resume
```

### Validation
```bash
/validate                       # Check consistency
/validate --fix                 # Auto-fix issues
/validate --strict              # Strict validation
```

## 📊 Quick Workflows

### New Feature (Complete)
```bash
/flow-specify "Feature description"
/flow-clarify                   # if needed
/flow-plan
/flow-tasks
/validate
/flow-implement
```

### New Feature (Fast)
```bash
/flow-specify "Quick feature"
/flow-plan --minimal
/flow-tasks --simple
/flow-implement
```

### Resume After Break
```bash
/resume
/flow-implement --continue
```

### MVP Only
```bash
/flow-specify "Feature with P1/P2/P3"
/flow-tasks
/flow-implement --mvp-only      # P1 tasks only
```

## 🎯 By Persona

### POC Developer
```bash
/flow-init
/flow-specify "POC" --skip-validation
/flow-implement --skip-checklists
```

### Solo Developer
```bash
/flow-init
/flow-blueprint
/flow-specify "Feature"
/flow-plan
/flow-tasks
/flow-implement
/session save
```

### Team Member
```bash
/flow-init --integrations=jira
/flow-specify "Feature"
/flow-clarify
/flow-plan
/flow-analyze
/flow-implement
/session save --name="handoff"
```

## 📁 File Locations

```
.flow/                          # Project config
├── architecture-blueprint.md
└── templates/

.flow-state/                    # Session state
├── current-session.md
└── checkpoints/

.flow-memory/                   # Project memory
├── WORKFLOW-PROGRESS.md
├── DECISIONS-LOG.md
├── CHANGES-PLANNED.md
└── CHANGES-COMPLETED.md

features/###-name/              # Feature artifacts
├── spec.md
├── plan.md
└── tasks.md
```

## 🔗 Command Chains

```bash
# Full feature in one go
/flow-specify "X" && /flow-plan && /flow-tasks && /flow-implement

# Quick check before implementing
/validate && /flow-implement

# Save then implement
/session save && /flow-implement

# Validate after manual edits
/validate --fix && /flow-implement --continue
```

## ⚡ Power User Tips

```bash
# Named checkpoints for milestones
/session save --name="mvp-complete"
/session save --name="before-refactor"

# Filter tasks by priority
/flow-tasks --filter=P1
/flow-implement --mvp-only

# Continue from specific task
/flow-implement --task=T008

# Strict validation before shipping
/validate --strict

# Check progress frequently
/status                         # alias: quickly type /s
```

## 🚨 Troubleshooting

```bash
# Lost? Check status
/status

# Confused? Get help
/help

# Something broken? Validate
/validate --fix

# Session ended? Resume
/resume

# Need to go back? Restore
/session list
/session restore --checkpoint=NAME
```

## 📖 Documentation

- **[USER-GUIDE.md](./USER-GUIDE.md)** - Complete user guide
- **[QUICK-START.md](./QUICK-START.md)** - 5-minute setup
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Problem solving
- **[WORKFLOW-EXPANSION-GUIDE.md](./WORKFLOW-EXPANSION-GUIDE.md)** - Customize Flow

## 🎓 Learning Path

### Day 1: Basics
1. `/flow-init`
2. `/flow-specify "Simple feature"`
3. `/flow-implement`
4. `/status` (frequently)

### Day 2: Full Workflow
1. `/flow-specify` → `/flow-plan` → `/flow-tasks`
2. `/validate`
3. `/flow-implement`
4. `/session save`

### Week 1: Advanced
1. `/flow-blueprint`
2. `/flow-clarify`
3. `/flow-analyze`
4. Custom workflows

## 📌 Remember

✅ Save before breaks: `/session save`
✅ Check status often: `/status`
✅ Validate after edits: `/validate`
✅ Use help when stuck: `/help`
✅ Resume next session: `/resume`

---

**Print this and keep handy!** Most common: `/status`, `/help`, `/session save`, `/resume`
