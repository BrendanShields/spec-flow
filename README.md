# Spec: Specification-Driven Development for Claude Code

Complete workflow system for building features with specifications, plans, and automated task breakdown.

## ⚡ Quick Start (30 seconds)

```bash
/spec-init                              # Initialize Spec
/spec-specify "Add user authentication" # Create spec
/spec-implement                         # Build it!
```

**That's it!** Spec guides you through the rest.

## 📚 Documentation Index

### 🎯 Start Here (Choose Your Path)

| If you want to... | Read this |
|-------------------|-----------|
| **Get started in 5 minutes** | [QUICK-START.md](./plugins/spec/docs/QUICK-START.md) |
| **See all commands** | [COMMANDS-QUICK-REFERENCE.md](./plugins/spec/docs/COMMANDS-QUICK-REFERENCE.md) ⭐ |
| **Learn everything** | [USER-GUIDE.md](./plugins/spec/docs/USER-GUIDE.md) |
| **Solve a problem** | [TROUBLESHOOTING.md](./plugins/spec/docs/TROUBLESHOOTING.md) |
| **Customize Flow** | [WORKFLOW-EXPANSION-GUIDE.md](./plugins/spec/docs/WORKFLOW-EXPANSION-GUIDE.md) |

### 📖 Complete Documentation

#### User Documentation
- **[QUICK-START.md](./plugins/spec/docs/QUICK-START.md)** - 5-minute setup guide
- **[COMMANDS-QUICK-REFERENCE.md](./plugins/spec/docs/COMMANDS-QUICK-REFERENCE.md)** - All commands (print this!)
- **[USER-GUIDE.md](./plugins/spec/docs/USER-GUIDE.md)** - Complete user manual (800+ lines)
- **[TROUBLESHOOTING.md](./plugins/spec/docs/TROUBLESHOOTING.md)** - Problem solving guide (500+ lines)
- **[WORKFLOW-EXPANSION-GUIDE.md](./plugins/spec/docs/WORKFLOW-EXPANSION-GUIDE.md)** - Customization guide (750+ lines)

#### Project Documentation
- **[WORK-COMPLETED.md](./plugins/spec/docs/WORK-COMPLETED.md)** - Visual summary of all work
- **[USER-COMMANDS-COMPLETE.md](./plugins/spec/docs/USER-COMMANDS-COMPLETE.md)** - Command implementation summary

#### Technical Documentation
- **[FINAL-SUMMARY.md](./plugins/spec/docs/FINAL-SUMMARY.md)** - Complete project overview
- **[IMPLEMENTATION-COMPLETE.md](./plugins/spec/docs/IMPLEMENTATION-COMPLETE.md)** - Implementation details
- **[COMPREHENSIVE-ANALYSIS-REPORT.md](./plugins/spec/docs/COMPREHENSIVE-ANALYSIS-REPORT.md)** - Analysis findings
- **[All Documentation](./plugins/spec/docs/)** - Complete technical documentation

## 🚀 Essential Commands

### Daily Use
```bash
/status              # Where am I? What's next?
/help                # Get context-aware help
/session save        # Save progress
/resume              # Continue after break
```

### Workflow
```bash
/spec-init                      # Initialize (once per project)
/spec-specify "Feature"         # Create specification
/spec-plan                      # Technical design
/spec-tasks                     # Break into tasks
/spec-implement                 # Execute
/validate                       # Check consistency
```

## 🎯 Workflows by Use Case

### Solo Developer
```bash
/spec-init --type=greenfield
/spec-blueprint                 # Define architecture
/spec-specify "Feature"
/spec-plan
/spec-tasks
/spec-implement
/session save                   # Before breaks
```

### Team Collaboration
```bash
/spec-init --integrations=jira
/spec-specify "Feature from PM"
/spec-clarify                   # PM answers questions
/spec-plan                      # Architect reviews
/spec-analyze                   # Check consistency
/spec-implement
/session save --name="handoff"  # Share with teammate
```

### Quick POC
```bash
/spec-init
/spec-specify "POC" --skip-validation
/spec-implement --skip-checklists
# Done!
```

## 📁 What Gets Created

```
Your Project/
├── .spec/                      # Configuration
│   ├── architecture-blueprint.md
│   └── templates/
│
├── .spec-state/                # Session tracking
│   ├── current-session.md
│   └── checkpoints/
│
├── .spec-memory/               # Project memory
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
└── features/                   # Your features
    └── 001-feature-name/
        ├── spec.md             # Requirements
        ├── plan.md             # Technical design
        └── tasks.md            # Task breakdown
```

## ✨ Key Features

### Session Continuity
✅ Never lose work between Claude sessions
✅ Automatic checkpoints
✅ Smart resume from exact interruption point

### Progress Tracking
✅ Real-time metrics and visibility
✅ Velocity tracking
✅ Completion trends

### Decision History
✅ Architecture decisions logged
✅ Rationale preserved
✅ Complete traceability

### Workflow Validation
✅ Consistency checking
✅ Auto-fix formatting issues
✅ Prevents common errors

## 📊 Benefits

| Benefit | Impact |
|---------|--------|
| **Session Continuity** | Never lose context |
| **Progress Visibility** | Always know where you are |
| **Decision Tracking** | Complete history |
| **Quality Assurance** | Automated validation |
| **Team Coordination** | Shared checkpoints |

## 🎓 Learning Path

### Day 1
1. Read [QUICK-START.md](./plugins/spec/docs/QUICK-START.md) (5 min)
2. Print [COMMANDS-QUICK-REFERENCE.md](./plugins/spec/docs/COMMANDS-QUICK-REFERENCE.md)
3. Try: `/spec-init` and `/spec-specify "Test feature"`

### Week 1
1. Read [USER-GUIDE.md](./plugins/spec/docs/USER-GUIDE.md) (sections 1-4)
2. Bookmark [TROUBLESHOOTING.md](./plugins/spec/docs/TROUBLESHOOTING.md)
3. Complete a real feature start-to-finish

### Week 2+
1. Read [WORKFLOW-EXPANSION-GUIDE.md](./plugins/spec/docs/WORKFLOW-EXPANSION-GUIDE.md)
2. Create custom commands
3. Establish team workflows

## 🧭 Guided Onboarding & Discovery
- Use `/spec --interactive` for a guided menu that highlights the current phase, recommended next steps, and links into the relevant docs.
- Run `/spec --help` or `/spec help <command>` for progressive disclosure help that grows with your experience level.
- Reference the [Spec Workflow Enhancements](./docs/WORKFLOW-IMPROVEMENTS.md#guided-onboarding--command-discovery) notes to keep your onboarding checklist aligned with the CLI experience.

## 🛡️ State Management Guarantees
- Validate automation health anytime with `./plugins/spec/scripts/state-management/validate-state.sh`.
- Regenerate Markdown from JSON when drift is detected via `json-to-md.sh session` and `json-to-md.sh workflow`.
- Hooks and docs guarantee that `.spec`, `.spec-state`, and `.spec-memory` stay in sync for both solo and team sessions. See [State-Management Guarantees](./docs/WORKFLOW-IMPROVEMENTS.md#state-management-guarantees).

## 🗺️ Planning at the Right Level
- Feature plans call out integration tests and cross-cutting acceptance criteria in addition to implementation notes.
- Group low-level bash or scripting work under epics; keep the roadmap realistic by focusing on milestone outcomes.
- Review [Task Planning & Realistic Roadmapping](./docs/WORKFLOW-IMPROVEMENTS.md#task-planning--realistic-roadmapping) before splitting new workstreams.

## 🤝 Collaboration Protocols
- Use `.spec-state/session.json` checkpoints before hand-offs, and record ownership changes in commit messages or metrics logs.
- Lease locks instead of hard-locking files; if a teammate is blocked, reclaim after the documented timeout.
- The collaboration guidance in [Spec Workflow Enhancements](./docs/WORKFLOW-IMPROVEMENTS.md#collaboration-workflows) covers conflict resolution and session hand-off tips.

## 📘 Documentation Coverage for the New UX
- Every CLI workflow has a matching deep-dive doc under `plugins/spec/docs/` so the interactive router, dashboards, and troubleshooting flows stay consistent.
- The Spec Visualiser package (`spec-visualiser/`) mirrors CLI naming, ensuring analytics and dashboards use the same language.
- Track updates and new guides through [Documentation Coverage for the New UX](./docs/WORKFLOW-IMPROVEMENTS.md#documentation-coverage-for-the-new-ux).

## 📈 Observability & Feedback Loops
- Enable `.claude/hooks/track-metrics.js` to collect AI vs human metrics in `.spec/.metrics.json` with historical snapshots under `.spec/metrics-history/`.
- Launch `spec-viz metrics` or open the dashboard for live telemetry on tasks, velocity, and hook outcomes.
- Refer to [Observability & Feedback Loops](./docs/WORKFLOW-IMPROVEMENTS.md#observability--feedback-loops) to align instrumentation with success metrics.

## 🔁 Migration & Compatibility
- `/spec` surfaces gentle warnings when legacy commands are used and links to migration docs for clarity.
- Follow the migration checklist and `/spec upgrade --dry-run` workflow before enabling team-wide automation.
- Details live in [Migration & Compatibility Support](./docs/WORKFLOW-IMPROVEMENTS.md#migration--compatibility-support).

## 🆘 Getting Help

```bash
/help                   # In-app help
/status                 # Check current state
```

**Documentation:**
- [TROUBLESHOOTING.md](./plugins/spec/docs/TROUBLESHOOTING.md) - Common issues
- [USER-GUIDE.md](./plugins/spec/docs/USER-GUIDE.md) - Complete guide
- GitHub Issues - Report bugs

## 🔧 Customization

Spec is highly customizable. See [WORKFLOW-EXPANSION-GUIDE.md](./plugins/spec/docs/WORKFLOW-EXPANSION-GUIDE.md) to:
- Create custom commands
- Add new skills
- Define team workflows
- Integrate with tools

## 📈 Project Stats

**Total Documentation**: 30+ files, 18,000+ lines
**Command Coverage**: 14 skills, 8 slash commands
**User Guides**: 5 comprehensive guides
**Analysis Reports**: 8 detailed reports
**Production Ready**: ✅ Yes

## 🎯 Common Use Cases

### New Feature Development
1. `/spec-specify "Feature"`
2. `/spec-plan`
3. `/spec-tasks`
4. `/spec-implement`

### Resume After Break
1. `/resume`
2. `/spec-implement --continue`

### Team Handoff
1. `/session save --name="handoff"`
2. Share checkpoint name
3. Teammate runs `/session restore --checkpoint=handoff`

### Requirements Changed
1. `/spec-update "New requirements"`
2. `/spec-analyze`
3. `/spec-tasks --update`
4. `/spec-implement --continue`

## 🌟 Best Practices

✅ **Initialize once**: Run `/spec-init` per project
✅ **Save frequently**: Use `/session save` before breaks
✅ **Check status**: Run `/status` regularly
✅ **Validate often**: Run `/validate` after edits
✅ **Use help**: Don't guess, use `/help`

## 🔗 Quick Links

- [5-Minute Start](./plugins/spec/docs/QUICK-START.md)
- [Command Reference](./plugins/spec/docs/COMMANDS-QUICK-REFERENCE.md)
- [User Guide](./plugins/spec/docs/USER-GUIDE.md)
- [Troubleshooting](./plugins/spec/docs/TROUBLESHOOTING.md)
- [Customization](./plugins/spec/docs/WORKFLOW-EXPANSION-GUIDE.md)
- [Technical Docs](./plugins/spec/docs/)

## 📞 Support

- `/help` - Built-in help system
- [Troubleshooting Guide](./plugins/spec/docs/TROUBLESHOOTING.md) - Common solutions
- [User Guide](./plugins/spec/docs/USER-GUIDE.md) - Complete documentation
- GitHub Issues - Bug reports and feature requests

---

## 🚀 Get Started Now

```bash
# 1. Initialize
/spec-init

# 2. Create your first feature
/spec-specify "Your feature description"

# 3. Build it
/spec-implement

# 4. Check progress anytime
/status
```

**That's it!** You're using specification-driven development with Spec.

---

**Documentation**: Complete ✅  
**Commands**: Production Ready ✅  
**User Experience**: Optimized ✅  

**Start building:** `/spec-init` then `/spec-specify "Your feature"`
