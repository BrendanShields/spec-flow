# 👻 Specter v3.0 - Unified Workflow Plugin for Claude Code

**One command. Intelligent routing. Team-ready.**

Specter is a specification-driven development plugin that transforms Claude Code into a complete development workflow system. v3.0 brings massive simplification: **8 commands → 1 unified command** with **84% less token usage** and **built-in team collaboration**.

---

## ✨ What's New in v3.0

### 🎯 Single Unified Command
```bash
# Before (v2.1): Remember 8 different commands
/specter-init, /specter-specify, /specter-plan, /specter-tasks...

# After (v3.0): One command, intelligent routing
/👻                    # Context-aware: knows what to do next
/👻 init               # Explicit: initialize project
/👻 "Your feature"     # Smart: auto-detects specification text
```

### ⚡ 84% Token Reduction
- **v2.1**: ~14,400 tokens per command
- **v3.0**: ~2,250 tokens per command
- **Result**: 3x faster, more efficient conversations

### 👥 Team Collaboration
```bash
/👻 team                   # Team dashboard with locks & assignments
/👻 assign @alice T001     # Assign tasks to team members
/👻 lock 002               # Lock features to prevent conflicts
/👻 master-spec            # Auto-generated consolidated docs
```

### 🎮 Interactive Mode
```bash
/👻 --interactive

# Shows contextual menu based on current phase
# No need to remember commands!
```

---

## 🚀 Quick Start

### Installation
```bash
# Install from marketplace
/plugin install specter@specter-marketplace

# Verify installation
/👻 --help
```

### 5-Minute Workflow

```bash
# 1. Initialize Specter in your project
/👻 init

# 2. Describe what you want to build
/👻 "Add user authentication with OAuth2 and JWT tokens"

# 3. Continue workflow (context-aware)
/👻          # Creates technical plan
/👻          # Breaks into tasks
/👻          # Begins implementation

# Done! 🎉
```

### The Old Way (v2.1) vs The New Way (v3.0)

**Before:**
```bash
/specter-init
/specter-specify "Add user authentication"
/specter-plan
/specter-tasks
/specter-implement
```

**After:**
```bash
/👻 init
/👻 "Add user authentication"
/👻
/👻
/👻
```

**84% fewer tokens. Same powerful workflow.**

---

## 📖 Core Concepts

### Workflow Phases

Specter guides you through a proven development workflow:

```
1. 🎬 Init         → Set up Specter in your project
2. 📝 Specify      → Define what to build (user stories)
3. 🏗️ Plan         → Design how to build it (architecture)
4. ✅ Tasks        → Break down into executable tasks
5. 🚀 Implement    → Execute tasks autonomously
```

At any point, just type `/👻` and Specter continues from where you left off.

### State Management

Specter maintains two types of state:

**Session State** (`.specter-state/`) - Git-ignored, temporary:
- Current feature and phase
- Task progress
- Session checkpoints

**Persistent Memory** (`.specter-memory/`) - Git-committed:
- Workflow history and metrics
- Architecture decisions (ADRs)
- Planned and completed changes

### Feature Organization

Each feature gets its own directory:

```
features/
└── 001-user-authentication/
    ├── spec.md       # What to build
    ├── plan.md       # How to build it
    └── tasks.md      # Step-by-step execution
```

---

## 🎯 Usage Examples

### Starting a New Project

```bash
cd my-new-project
/👻 init --type=greenfield

# Specter creates:
# ✅ .specter/ (config and templates)
# ✅ .specter-state/ (session tracking)
# ✅ .specter-memory/ (persistent memory)
# ✅ features/ (ready for specs)
```

### Adding to Existing Project

```bash
cd my-existing-project
/👻 init --type=brownfield

# Specter analyzes your codebase and adapts
```

### Creating a Feature

```bash
# Method 1: Free text (recommended)
/👻 "Add payment processing with Stripe integration"

# Method 2: Explicit
/👻 specify "Add payment processing"

# Method 3: Interactive
/👻 --interactive
# → Choose "Create new specification"
```

### Continuing Work

```bash
# Check where you left off
/👻 status

# Continue from current phase
/👻

# Or jump to specific phase
/👻 implement --continue
```

### Team Collaboration

```bash
# Check team status
/👻 team

# Lock a feature for yourself
/👻 lock 003

# Assign tasks to team members
/👻 assign @bob T001 T002 T003
/👻 assign @alice T004 T005

# When done, release the lock
/👻 unlock 003
```

### Generate Master Spec

```bash
# Auto-generate consolidated documentation
/👻 master-spec

# Creates .specter/master-spec.md with:
# - Product vision
# - Architecture
# - All features (completed + active + planned)
# - Technical decisions
# - Metrics
```

---

## 🎮 Command Reference

### Initialization
```bash
/👻 init                     # Interactive initialization
/👻 init --type=greenfield   # New project
/👻 init --type=brownfield   # Existing codebase
```

### Workflow Commands
```bash
/👻 "Feature description"    # Create specification
/👻 plan                     # Create technical plan
/👻 tasks                    # Break into tasks
/👻 implement                # Execute implementation
/👻 clarify                  # Resolve ambiguities
/👻 update "changes"         # Update specification
```

### Context-Aware
```bash
/👻                          # Continue from current phase
/👻 --interactive            # Interactive menu
/👻 status                   # Check current state
/👻 --help                   # Context-aware help
```

### Team Features
```bash
/👻 team                     # Team dashboard
/👻 assign @user T001        # Assign task
/👻 lock 002                 # Lock feature
/👻 unlock 002               # Unlock feature
/👻 master-spec              # Generate master specification
```

### Utilities
```bash
/👻 analyze                  # Validate consistency
/👻 metrics                  # Show development metrics
/👻 validate                 # Check for issues
```

### Progressive Disclosure
```bash
/👻 plan --examples          # Load examples too
/👻 tasks --reference        # Load full API reference
```

---

## 🏢 Team Setup

### Enable Team Mode

Add to your project's `CLAUDE.md`:

```markdown
# Specter Configuration
SPECTER_TEAM_MODE=enabled
SPECTER_AUTO_LOCK=true
SPECTER_LOCK_TTL=7200        # 2 hours
```

### Team Workflow

```bash
# Alice starts a feature
cd project
/👻 "Add payment integration"
# → Feature automatically locked to @alice

# Bob tries to work on it
/👻 "Add payment integration"
# ❌ Error: Feature locked by @alice since 2024-10-31 10:30

# Alice assigns tasks
/👻 assign @bob T001 T002
/👻 assign @carol T003 T004

# Team checks status
/👻 team

# Output:
# 📊 Specter Team Status
# ━━━━━━━━━━━━━━━━━━━━━━━━
# 🔒 Active Locks:
#   - Feature 002: @alice
# 👥 Task Assignments:
#   - T001: @bob
#   - T002: @bob
#   - T003: @carol
#   - T004: @carol
```

### Stale Lock Handling

Locks automatically expire after TTL (default 2 hours) or if the process dies:

```bash
# Force unlock (admin only)
/👻 force-unlock 002
```

---

## 📊 Token Efficiency

### How We Achieved 84% Reduction

#### 1. **Lazy Loading**
Only load what you need, when you need it:

```
Tier 1 (Always):    ~500 tokens   (router + context)
Tier 2 (On-demand): ~1,750 tokens (skill core)
Tier 3 (Optional):  ~15,000 tokens (examples + reference)
```

#### 2. **Progressive Disclosure**
Skills split into 3 files:
- `SKILL.md` - Core logic (always loaded)
- `EXAMPLES.md` - Usage examples (load with `--examples`)
- `REFERENCE.md` - Full API docs (load with `--reference`)

#### 3. **Smart Routing**
Single entry point reduces overhead:
- Context detection: ~200 tokens
- Routing logic: ~300 tokens
- vs. 8 separate command files: ~1,200 tokens each

**Result**: From 14,400 to 2,250 tokens per invocation.

---

## 🏗️ Project Structure

### After Initialization

```
your-project/
├── .specter/                      # Configuration (committed)
│   ├── product-requirements.md
│   ├── architecture-blueprint.md
│   ├── master-spec.md             # Auto-generated
│   └── templates/
│
├── .specter-state/                # Session state (git-ignored)
│   ├── session.json               # Source of truth
│   ├── current-session.md         # Human-readable view
│   └── locks/                     # Feature locks
│
├── .specter-memory/               # Persistent memory (committed)
│   ├── workflow.json              # Source of truth
│   ├── WORKFLOW-PROGRESS.md       # Auto-generated
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
│
└── features/                      # Feature artifacts (committed)
    ├── 001-user-auth/
    │   ├── spec.md
    │   ├── plan.md
    │   └── tasks.md
    └── 002-payment-integration/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

### Git Configuration

Add to `.gitignore`:

```gitignore
# Specter session state (temporary, user-specific)
.specter-state/session.json
.specter-state/current-session.md
.specter-state/checkpoints/

# Everything else in .specter/ is committed
```

---

## 🔧 Configuration

### Global Settings (CLAUDE.md)

```markdown
# Specter Configuration

## Basic
SPECTER_AUTO_CHECKPOINT=true        # Auto-save session state
SPECTER_VALIDATE_ON_SAVE=true       # Auto-validate before commits

## Team Mode
SPECTER_TEAM_MODE=enabled
SPECTER_AUTO_LOCK=true               # Auto-lock on feature creation
SPECTER_LOCK_TTL=7200                # Lock timeout (seconds)

## Integrations
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_JIRA_PROJECT_KEY=PROJ
SPECTER_CONFLUENCE_ROOT_PAGE_ID=123456

## Master Spec
SPECTER_MASTER_SPEC_AUTO=true        # Auto-regenerate master spec
SPECTER_MASTER_SPEC_FORMAT=md        # md|html|pdf
```

---

## 📚 Advanced Features

### Shell Completion

Enable tab completion for faster workflows:

**Bash:**
```bash
# Add to ~/.bashrc
source ~/.claude/completion/specter.bash
```

**Zsh:**
```bash
# Add to ~/.zshrc
fpath=(~/.claude/completion $fpath)
autoload -Uz compinit && compinit
```

**Usage:**
```bash
/👻 <TAB>           # Lists all subcommands
/👻 assign @<TAB>   # Lists team members
/👻 impl<TAB>       # Completes to "implement"
```

### Custom Workflows

Extend Specter with custom skills:

```bash
# Create custom skill
mkdir -p .specter/skills/my-custom-skill

# Add SKILL.md, EXAMPLES.md, REFERENCE.md

# Use it
/👻 my-custom-skill
```

### Hooks Integration

Specter supports event hooks for automation:

```json
// .specter/hooks.json
{
  "post-specify": "scripts/notify-team.sh",
  "pre-implement": "scripts/validate-deps.sh",
  "post-complete": "scripts/create-pr.sh"
}
```

---

## 🐛 Troubleshooting

### Command Not Found

**Problem**: `/👻` not recognized

**Solution**:
```bash
/plugin install specter@specter-marketplace
/plugin reload specter
```

### Context Detection Failed

**Problem**: "Cannot determine current phase"

**Solution**:
```bash
# Regenerate session state
/👻 status

# Or reinitialize
/👻 init
```

### Feature Locked

**Problem**: "Feature 002 is locked by @alice"

**Solutions**:
1. Wait for @alice to finish and unlock
2. Contact @alice to release lock
3. Admin: `/👻 force-unlock 002`

### Stale Locks

Locks auto-expire after TTL (default 2h) or if process dies. Manual cleanup:

```bash
# Remove all locks (admin)
rm -rf .specter-state/locks/*.lock
```

---

## 📖 Documentation

- **Quick Start**: This README
- **Migration Guide**: [MIGRATION-V2-TO-V3.md](docs/MIGRATION-V2-TO-V3.md)
- **User Guide**: `/👻 --help --reference`
- **Examples**: `/👻 --examples`
- **Team Guide**: [TEAM-COLLABORATION.md](docs/TEAM-COLLABORATION.md)
- **API Reference**: See individual skill directories

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## 📜 License

MIT License - See [LICENSE](LICENSE)

---

## 🙏 Credits

**Specter v3.0** - Built with Claude Code

**Key Contributors**:
- Workflow design and architecture
- Token optimization strategies
- Team collaboration features
- Master spec generation

---

## 🎉 Quick Reference Card

```bash
# Essential Commands
/👻 init               # Initialize Specter
/👻 "Feature"          # Create specification
/👻                    # Context-aware continue
/👻 status             # Check status
/👻 team               # Team dashboard
/👻 master-spec        # Generate docs
/👻 --interactive      # Interactive menu
/👻 --help             # Context-aware help

# Workflow
init → specify → plan → tasks → implement → done!

# Team
/👻 assign @user T001  # Assign task
/👻 lock 002           # Lock feature
/👻 unlock 002         # Release lock
```

---

**Ready to transform your workflow?** Start with `/👻 init` 🚀

**Questions?** Open an issue: https://github.com/specter/issues

**Migrating from v2.1?** See [Migration Guide](docs/MIGRATION-V2-TO-V3.md)
