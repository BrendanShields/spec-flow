# Spec v3.0 - Specification-Driven Development Plugin for Claude Code

**Efficient. Systematic. Production-Ready.**

Spec transforms Claude Code into a complete specification-driven development workflow system. v3.0 brings **81% token efficiency improvement**, **unified command interface**, and **13 specialized skills** for professional software development.

---

## ✨ What's New in v3.0

### ⚡ 81% Token Reduction
- **v2.1**: ~6,800 tokens per skill invocation
- **v3.0**: ~1,283 tokens per skill invocation
- **Result**: Faster execution, more efficient context usage, 3-5x faster workflows

### 🎯 Unified Command Interface
```bash
# Before (v2.1): Multiple command patterns
/spec-init, /spec-specify, /spec-plan...

# After (v3.0): Single hub command with intelligent routing
/spec init                    # Initialize project
/spec "Your feature"          # Create specification
/spec                         # Context-aware: continues from current phase
```

### 🏗️ Progressive Disclosure Architecture
Skills now use 3-tier loading:
- **Tier 1**: Metadata (~100 tokens, always loaded)
- **Tier 2**: Core logic (~1,500 tokens, loaded on trigger)
- **Tier 3**: Examples/Reference (~5,000+ tokens, loaded on demand with flags)

```bash
/spec plan                    # Loads core logic only
/spec plan --examples         # Loads + comprehensive examples
/spec plan --reference        # Loads + full API reference
```

### 📦 State Caching
Hub command reads state files once and caches for entire execution:
- **Before**: Each skill reads state (~2,000 tokens × 5 skills = 10,000 tokens)
- **After**: Hub reads once (~2,000 tokens total)
- **Savings**: 80% reduction in state overhead

---

## 🚀 Quick Start

### Installation
```bash
# Install from Claude Code marketplace
/plugin install spec@spec-marketplace

# Verify installation
/spec --help
```

### 5-Minute Workflow

```bash
# 1. Initialize Spec in your project
/spec init

# 2. Create a feature specification
/spec "Add user authentication with OAuth2 and JWT tokens"

# 3. Generate technical plan
/spec plan

# 4. Break down into tasks
/spec tasks

# 5. Execute implementation
/spec implement

# Done! 🎉
```

### Alternative: Context-Aware Execution

```bash
/spec init
/spec "Add user authentication"
/spec          # Auto-creates plan based on current phase
/spec          # Auto-creates tasks
/spec          # Auto-begins implementation
```

---

## 📖 Core Concepts

### Workflow Phases

Spec guides you through a proven 5-phase development workflow:

```
1. 🎬 init       → Set up Spec in your project
2. 📝 generate   → Define what to build (specifications with user stories)
3. 🏗️  plan      → Design how to build it (technical architecture)
4. ✅ tasks      → Break down into executable tasks with dependencies
5. 🚀 implement  → Execute tasks autonomously with progress tracking
```

At any point, type `/spec` and Spec continues from your current phase.

### 13 Specialized Skills

**Core Workflow** (5 skills):
- `spec:init` - Initialize Spec in projects (greenfield/brownfield)
- `spec:generate` - Create specifications from requirements
- `spec:plan` - Generate technical plans with Architecture Decision Records
- `spec:tasks` - Break plans into executable tasks with dependencies
- `spec:implement` - Execute implementation autonomously

**Supporting Workflow** (4 skills):
- `spec:clarify` - Resolve ambiguities and [CLARIFY] tags
- `spec:blueprint` - Define architecture and technical standards
- `spec:update` - Update specifications and add MCP integrations
- `spec:orchestrate` - Execute complete workflow end-to-end

**Utilities** (4 skills):
- `spec:analyze` - Validate consistency across all artifacts
- `spec:discover` - Analyze existing codebases (brownfield onboarding)
- `spec:checklist` - Generate quality validation checklists
- `spec:metrics` - View development metrics and AI/human code ratios

### State Management

Spec maintains two types of state:

**Session State** (`.spec-state/`) - Git-ignored:
- `current-session.md` - Current feature, phase, progress
- `checkpoints/` - Session recovery points

**Persistent Memory** (`.spec-memory/`) - Git-committed:
- `WORKFLOW-PROGRESS.md` - Feature history and metrics
- `DECISIONS-LOG.md` - Architecture Decision Records (ADRs)
- `CHANGES-PLANNED.md` - Planned changes from tasks
- `CHANGES-COMPLETED.md` - Completed implementation history

### Feature Organization

Each feature gets its own numbered directory:

```
features/
├── 001-user-authentication/
│   ├── spec.md       # What to build (user stories, acceptance criteria)
│   ├── plan.md       # How to build it (architecture, components, ADRs)
│   └── tasks.md      # Step-by-step execution (with dependencies)
└── 002-payment-integration/
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

---

## 🎯 Usage Examples

### Starting a New Project (Greenfield)

```bash
cd my-new-project
/spec init --type=greenfield

# Spec creates:
# ✅ .spec/ (configuration and templates)
# ✅ .spec-state/ (session tracking)
# ✅ .spec-memory/ (persistent memory)
# ✅ features/ (ready for specifications)

# Optional: Define architecture first
/spec blueprint
```

### Adding to Existing Project (Brownfield)

```bash
cd my-existing-project
/spec init --type=brownfield

# Spec analyzes your codebase
/spec discover

# Then define architecture based on analysis
/spec blueprint
```

### Creating a Feature

```bash
# Method 1: Natural language (recommended)
/spec "Add payment processing with Stripe. Support credit cards, ACH, and Apple Pay. Include webhook handling for payment events."

# Method 2: Explicit command
/spec generate "Add payment processing"

# Method 3: From JIRA (requires MCP)
/spec generate --from-jira=PROJ-123
```

### Handling Ambiguities

```bash
# After spec:generate, check for [CLARIFY] tags
/spec clarify

# Spec asks targeted questions with recommended options
# Updates spec.md with clarified requirements
# Logs decisions to DECISIONS-LOG.md
```

### Continuing Work After Interruption

```bash
# Check where you left off
/spec status

# Continue from current phase
/spec

# Or jump to specific phase
/spec implement --continue

# Or resume from last checkpoint
/spec orchestrate --resume
```

### Complete End-to-End Workflow

```bash
# Let Spec run everything automatically
/spec orchestrate

# Walks through: generate → clarify → plan → tasks → implement
# Prompts at decision points
# Creates checkpoints for recovery
# Provides real-time progress tracking
```

---

## 🎮 Command Reference

### Hub Command

```bash
/spec                          # Context-aware: continues from current phase
/spec <subcommand>             # Explicit: runs specific skill
/spec "Text"                   # Smart: detects specification and runs generate
/spec --help                   # Context-aware help
/spec --version                # Show version
```

### Initialization

```bash
/spec init                     # Interactive initialization
/spec init --type=greenfield   # New project
/spec init --type=brownfield   # Existing codebase
/spec blueprint                # Define architecture (before features)
/spec discover                 # Analyze existing codebase
```

### Core Workflow

```bash
/spec generate "Feature"       # Create specification
/spec clarify                  # Resolve ambiguities (optional)
/spec plan                     # Create technical plan
/spec tasks                    # Break into tasks
/spec implement                # Execute implementation

# Or use short form
/spec "Feature description"    # Generates specification
/spec                          # Auto-continues to next phase
```

### Specification Management

```bash
/spec update "Changes"         # Update existing specification
/spec analyze                  # Validate consistency
/spec clarify                  # Resolve [CLARIFY] tags
```

### Implementation Control

```bash
/spec implement                # Execute all tasks
/spec implement --filter=P1    # Execute P1 tasks only
/spec implement --resume       # Resume from interruption
/spec implement --parallel     # Max parallelization
```

### Automation

```bash
/spec orchestrate              # Full workflow automation
/spec orchestrate --auto       # Minimize prompts
/spec orchestrate --resume     # Resume from checkpoint
```

### Utilities

```bash
/spec status                   # Check current state
/spec metrics                  # View development metrics
/spec validate                 # Validate all artifacts
/spec checklist                # Generate quality checklist
```

### Progressive Disclosure

```bash
/spec plan --examples          # Load comprehensive examples
/spec tasks --reference        # Load full API reference
/spec --verbose                # Detailed execution output
```

---

## 🏗️ Project Structure

### After Initialization

```
your-project/
├── .spec/                      # Configuration (git-committed)
│   ├── product-requirements.md   # Product vision and requirements
│   ├── architecture-blueprint.md # Technical architecture (optional)
│   ├── templates/                # Custom templates
│   └── scripts/                  # Custom automation scripts
│
├── .spec-state/                # Session state (git-ignored)
│   ├── current-session.md        # Current feature, phase, progress
│   └── checkpoints/              # Session recovery points
│
├── .spec-memory/               # Persistent memory (git-committed)
│   ├── WORKFLOW-PROGRESS.md      # Feature history and metrics
│   ├── DECISIONS-LOG.md          # Architecture decisions (ADRs + CLRs)
│   ├── CHANGES-PLANNED.md        # Planned changes from tasks.md
│   └── CHANGES-COMPLETED.md      # Implementation history
│
└── features/                      # Feature artifacts (git-committed)
    ├── 001-user-authentication/
    │   ├── spec.md               # User stories, acceptance criteria
    │   ├── plan.md               # Technical design, components, ADRs
    │   └── tasks.md              # Executable tasks with dependencies
    └── 002-payment-integration/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

### Git Configuration

Add to `.gitignore`:

```gitignore
# Spec session state (temporary, machine-specific)
.spec-state/

# Everything else in .spec/ and .spec-memory/ should be committed
```

---

## 🔧 Configuration

### Project Settings (CLAUDE.md)

Add to your project's `CLAUDE.md`:

```markdown
# Spec Configuration

## Basic Settings
SPEC_AUTO_CHECKPOINT=true        # Auto-save session state
SPEC_VALIDATE_ON_SAVE=true       # Auto-validate before task completion

## MCP Integrations (Optional)
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456

## Workflow Preferences
SPEC_ORCHESTRATE_MODE=interactive|auto
SPEC_ORCHESTRATE_SKIP_ANALYZE=false
```

### Skill-Specific Configuration

```markdown
## spec:implement Configuration
SPEC_IMPLEMENT_MAX_PARALLEL=3       # Max parallel tasks
SPEC_IMPLEMENT_AUTO_COMMIT=false    # Auto-commit after tasks

## spec:clarify Configuration
SPEC_CLARIFY_MAX_QUESTIONS=4        # Questions per session
SPEC_CLARIFY_AUTO_ACCEPT=false      # Auto-accept recommendations
```

---

## 📊 Token Efficiency

### How We Achieved 81% Reduction

#### 1. Progressive Disclosure (3-Tier Architecture)

**Tier 1: Metadata** (~100 tokens, always loaded)
- Skill name, description, activation patterns
- Tool requirements, model preferences

**Tier 2: Core Instructions** (~1,500 tokens, loaded on trigger)
- Execution workflow
- Phase-by-phase logic
- State management
- Basic examples

**Tier 3: Extended Resources** (~5,000+ tokens, lazy loaded)
- `EXAMPLES.md` - Comprehensive scenarios (load with `--examples`)
- `REFERENCE.md` - Full technical specs (load with `--reference`)

**Default Usage**: 1,600 tokens (Tier 1 + Tier 2)
**With Examples**: 6,600 tokens (+ Tier 3 examples)
**Full Reference**: 11,600 tokens (+ Tier 3 reference)

#### 2. State Caching

Hub command (`/spec`) loads state once:
- Reads `.spec-state/current-session.md` (1 time)
- Reads `.spec-memory/WORKFLOW-PROGRESS.md` (1 time)
- Caches in memory for entire execution
- Passes cached state to all invoked skills

**Token Savings**: 8,000 tokens per workflow (5-skill average)

#### 3. Shared Resources

Common patterns extracted to shared files:
- `shared/integration-patterns.md` (~1,200 tokens) - MCP integration
- `shared/workflow-patterns.md` (~1,400 tokens) - Common workflows
- `shared/state-management.md` (~1,600 tokens) - State specifications

**Benefit**: Eliminates duplication across 13 skills

#### 4. Smart Content Extraction

Skills only load relevant sections:
- EXAMPLES.md: Load only matching scenarios
- REFERENCE.md: Load only relevant API sections
- Conditional loading based on user flags

**Result**: Average 1,283 tokens per skill (vs 6,800 in v2.1)

---

## 📚 Advanced Features

### MCP Integration

Spec integrates with Model Context Protocol servers:

**JIRA Integration**:
```bash
# Pull JIRA story into specification
/spec generate --from-jira=PROJ-123

# Sync specification back to JIRA
/spec update --sync-jira
```

**Confluence Integration**:
```bash
# Publish architecture blueprint
/spec blueprint --publish-confluence

# Publish completed feature documentation
/spec update --publish-confluence
```

**Linear Integration**:
```bash
# Import Linear issue
/spec generate --from-linear=PROJ-123

# Create Linear tasks from tasks.md
/spec tasks --create-linear
```

### Custom Skills

Extend Spec with project-specific skills:

```bash
# Create custom skill directory
mkdir -p .spec/skills/deploy-validation

# Add SKILL.md with your logic
# Spec auto-discovers and loads it

# Use it
/spec deploy-validation
```

### Hooks Integration

Spec supports event hooks for automation. See [HOOKS-USER-GUIDE.md](docs/HOOKS-USER-GUIDE.md).

```json
// .claude/hooks/hooks.json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "matcher": "Skill",
      "command": "node .spec/hooks/track-metrics.js"
    }
  ]
}
```

### Subagent Delegation

Complex skills delegate to specialized subagents:

- `spec:implement` → `spec:implementer` (parallel task execution)
- `spec:plan` → `spec:researcher` (research-backed decisions)
- `spec:analyze` → `spec:analyzer` (deep consistency validation)

---

## 🐛 Troubleshooting

### Command Not Found

**Problem**: `/spec` not recognized

**Solution**:
```bash
/plugin install spec@spec-marketplace
/plugin reload spec
```

### Context Detection Failed

**Problem**: "Cannot determine current phase"

**Solution**:
```bash
# Regenerate session state
/spec status

# Or reinitialize if corrupted
rm .spec-state/current-session.md
/spec init
```

### Skill Errors

**Problem**: Skill execution fails

**Solution**:
```bash
# Check skill exists
ls .claude/skills/spec-*

# Validate YAML frontmatter
head -10 .claude/skills/spec-generate/SKILL.md

# Re-run with verbose output
/spec generate "Feature" --verbose
```

### State File Corruption

**Problem**: Inconsistent state between files

**Solution**:
```bash
# Validate all state files
/spec validate

# If corruption found, restore from checkpoint
/spec orchestrate --resume

# Or rebuild state manually
/spec analyze
```

### Performance Issues

**Problem**: Slow skill execution

**Solution**:
```bash
# Check token usage
/spec --verbose

# Use lazy loading (don't load examples by default)
/spec plan          # Good: 1,500 tokens
# vs
/spec plan --examples --reference  # Heavy: 6,600 tokens

# Clear cache if needed
rm -rf .spec-state/checkpoints/
```

---

## 📚 Documentation

### Quick Start Guides
- **[Quick Start Guide](.claude/skills/workflow/quick-start.md)** - Get started in 30-60 minutes
- **[README.md](README.md)** - This file - overview and installation

### Core Navigation
- **[Workflow Map](.claude/skills/workflow/navigation/workflow-map.md)** - Visual overview of the 5-phase workflow
- **[Skill Index](.claude/skills/workflow/navigation/skill-index.md)** - Complete command reference for all 13 skills
- **[Phase Reference](.claude/skills/workflow/navigation/phase-reference.md)** - Quick reference for each phase
- **[Complete Index](.claude/skills/workflow/navigation/index.md)** - Full navigation of all 71+ workflow files

### Comprehensive Guides
- **[Error Recovery](.claude/skills/workflow/error-recovery.md)** - Troubleshooting guide (1,169 lines, 9 scenarios)
- **[Glossary](.claude/skills/workflow/glossary.md)** - Complete terminology reference (72 terms)
- **[Agents Guide](.claude/skills/workflow/agents-guide.md)** - Understanding spec-implementer, spec-researcher, spec-analyzer
- **[Progressive Disclosure](.claude/skills/workflow/progressive-disclosure.md)** - Using --examples and --reference flags
- **[Integration Errors](.claude/skills/workflow/integration-errors.md)** - Handling MCP integration failures
- **[Advanced Examples](.claude/skills/workflow/advanced-examples.md)** - 10 real-world advanced scenarios

### Migration & Configuration
- **Migration Guide** - Upgrading from v2.1 to v3.0 _(Coming soon)_
- **Hooks User Guide** - Event hooks and automation _(Coming soon)_
- **Custom Hooks API** - Hooks API reference _(Coming soon)_

### Templates & Reference
- **[Template Integration Guide](.claude/skills/workflow/templates/INTEGRATION-GUIDE.md)** - How templates connect to functions
- **[Templates Overview](.claude/skills/workflow/templates/README.md)** - All 11 templates organized by category
- **[Shared Resources](.claude/skills/shared/)** - State management, integration patterns, workflow patterns

### Quality & Review
- **[Workflow Review](.claude/skills/workflow/workflow-review.md)** - Architecture and design review
- **[Consistency Review Report](.claude/skills/workflow/consistency-review-report.md)** - Documentation quality audit
- **[Link Audit Report](.claude/skills/workflow/link-audit-report.md)** - Link health validation

### Progressive Learning
- **Beginner**: Start with Quick Start → Workflow Map → Error Recovery
- **Intermediate**: Read Skill Index → Phase Reference → Templates
- **Advanced**: Study Agents Guide → Advanced Examples → Integration Errors
- **Customization**: Review Hooks guides → Templates → Shared Resources

---

## 🤝 Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch
3. Follow the skill structure (SKILL.md, EXAMPLES.md, REFERENCE.md)
4. Test with `/spec validate`
5. Submit a pull request

---

## 📜 License

MIT License - See [LICENSE](LICENSE)

---

## 🎉 Quick Reference Card

```bash
# Essential Commands
/spec init                    # Initialize Spec
/spec "Feature description"   # Create specification
/spec                         # Context-aware continue
/spec status                  # Check current state
/spec --help                  # Context-aware help

# Complete Workflow
/spec init
/spec "Your feature"
/spec                         # → Creates plan
/spec                         # → Creates tasks
/spec                         # → Implements

# Or fully automated
/spec init
/spec orchestrate             # Runs entire workflow

# Progressive Disclosure
/spec plan                    # Core only (~1,500 tokens)
/spec plan --examples         # + Examples (~5,000 tokens)
/spec plan --reference        # + Full docs (~10,000 tokens)

# Advanced
/spec implement --filter=P1   # Priority tasks only
/spec analyze                 # Validate consistency
/spec metrics                 # View metrics
/spec orchestrate --resume    # Resume from checkpoint
```

---

## 📊 Performance Comparison

| Metric | v2.1 | v3.0 | Improvement |
|--------|------|------|-------------|
| Tokens per skill | 6,800 | 1,283 | **81% reduction** |
| Workflow tokens | 34,000 | 6,400 | **81% reduction** |
| Skills | 13 | 13 | Same coverage |
| Commands | Multiple | `/spec` hub | Unified |
| Loading strategy | Eager | Progressive | Smarter |
| State overhead | 10,000 | 2,000 | **80% reduction** |
| Execution speed | Baseline | 3-5x faster | **Much faster** |

---

**Ready to transform your workflow?** Start with `/spec init` 🚀

**Questions?** Open an issue: https://github.com/claude-code/spec-marketplace/issues

**Migrating from v2.1?** See [Migration Guide](docs/MIGRATION-V2-TO-V3.md)
