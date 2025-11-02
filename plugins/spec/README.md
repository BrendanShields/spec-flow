# Spec Workflow Plugin

**Version**: 3.3.0
**Status**: Production Ready
**License**: MIT

Specification-driven development workflow for Claude Code with interactive menus, auto mode, and state management.

## Quick Start

### Installation

```bash
# Clone or install via Claude Code plugin manager
/plugin install spec
```

### First Feature in 5 Minutes

```bash
# 1. Initialize Spec in your project
/workflow:spec
# Select: 🚀 Initialize Project

# 2. Create your first feature
/workflow:spec
# Select: 🚀 Auto Mode
# Answer questions about your feature
# Spec handles the rest automatically!
```

That's it! Spec will:
- ✅ Create specification (spec.md)
- ✅ Design technical plan (plan.md)
- ✅ Break down tasks (tasks.md)
- ✅ Guide implementation
- ✅ Track progress

## What is Spec?

Spec is a specification-driven development workflow that helps you:

1. **Define** what you're building (user stories, acceptance criteria)
2. **Design** how to build it (architecture, components, ADRs)
3. **Build** the feature (task breakdown, implementation)
4. **Track** progress (metrics, state management)

All through an **interactive menu system** - no commands to memorize!

## Core Features

### 🎯 Interactive Menus
Context-aware menus adapt to your workflow state:
- **Not Initialized**: Setup options
- **No Feature**: Create or track
- **In Progress**: Continue or refine
- **Complete**: Validate or start next

### 🚀 Auto Mode
One-click full workflow automation:
- Generate specification from requirements
- Create technical design
- Break down into tasks
- Guide implementation
- Checkpoints between phases

### 💾 State Management
Dual-layer state tracking:
- **Session State**: Current work (git-ignored)
- **Memory State**: Persistent history (git-committed)
- **Resume Capability**: Pick up where you left off

### 📊 Progress Tracking
Built-in metrics and monitoring:
- Feature completion rates
- Velocity tracking
- Decision log (ADRs)
- Change history

### 🎨 Flexible Workflow
Choose your style:
- **Auto Mode**: Full automation with checkpoints
- **Manual Mode**: Step-by-step control
- **Hybrid**: Auto mode with pause/refine options

## Commands

### Main Command

**`/workflow:spec`** - Your primary interface

This single command provides context-aware menus for all Spec operations. The menu adapts based on your current state.

### Tracking Command

**`/workflow:track`** - Progress monitoring

View metrics, update specs, analyze consistency, sync with external systems (JIRA, Confluence).

## Workflow Phases

Spec follows a 5-phase workflow:

### 1. Initialize
**Purpose**: Set up project structure and architecture

**Actions**:
- Initialize `.spec/` directory structure
- Create state management files
- Define architecture blueprint (optional)
- Analyze existing codebase (brownfield projects)

### 2. Define
**Purpose**: Create and validate feature specifications

**Actions**:
- Generate specification (spec.md)
- Clarify ambiguities
- Validate requirements quality

**Output**: `spec.md` with user stories and acceptance criteria

### 3. Design
**Purpose**: Create technical plan and validate consistency

**Actions**:
- Plan technical design (plan.md)
- Log architecture decisions (ADRs)
- Validate consistency

**Output**: `plan.md` with architecture and component design

### 4. Build
**Purpose**: Break down and execute implementation

**Actions**:
- Generate tasks (tasks.md)
- Execute implementation
- Track progress

**Output**: Implemented feature with passing tests

### 5. Track
**Purpose**: Maintain specs and monitor progress

**Actions**:
- View metrics and velocity
- Update specifications
- Sync with external systems
- Orchestrate full workflows

## Project Structure

After initialization, your project will have:

```
your-project/
├── .spec/                          # Spec configuration (committed)
│   ├── .spec-config.yml           # Configuration (auto-generated)
│   ├── features/                  # Feature specifications
│   │   └── 001-feature-name/      # Individual features
│   │       ├── spec.md            # Specification
│   │       ├── plan.md            # Technical plan
│   │       └── tasks.md           # Task breakdown
│   └── state/                     # State management
│       ├── current-session.md     # Current work (git-ignored)
│       └── memory/                # Persistent state (committed)
│           ├── WORKFLOW-PROGRESS.md
│           ├── DECISIONS-LOG.md
│           ├── CHANGES-PLANNED.md
│           └── CHANGES-COMPLETED.md
├── .gitignore                     # Updated to ignore .spec/state/
└── ... your code ...
```

## Configuration

Spec uses a simple YAML configuration file (`.spec/.spec-config.yml`) that is auto-generated on first run with smart defaults.

### Default Configuration

```yaml
version: "3.3.0"
paths:
  spec_root: ".spec"
  features: "features"
  state: "state"
  memory: "{state}/memory"
naming:
  feature_directory: "{id:000}-{slug}"
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"
project:
  type: "app"              # Auto-detected: app, library, monorepo
  language: "javascript"   # Auto-detected
  framework: null          # Auto-detected: react, vue, nextjs, etc.
  build_tool: null         # Auto-detected
```

### Customization

Edit `.spec/.spec-config.yml` to customize:
- Directory paths (spec_root, features, state, memory)
- File naming conventions
- Project metadata

All paths support variable interpolation (e.g., `{spec_root}/features`).

## Advanced Features

### TDD Mode
Three enforcement levels for test-driven development:
- **Strict**: Tests before implementation
- **Balanced**: Tests during implementation
- **Flexible**: Tests after implementation

Configure with: `SPEC_TDD_MODE=strict|balanced|flexible` in `CLAUDE.md`

### Multi-Agent Coordination
Built-in support for 6 coordination strategies:
- Sequential, Parallel, Hierarchical
- DAG (dependency graphs)
- Group Chat, Event-Driven

### Smart Hook Auto-Detection
Automatically detects project tooling and offers to create Claude Code hooks for:
- Linters (ESLint, Prettier)
- Type checkers (TypeScript, Flow)
- Test runners (Jest, Vitest, Pytest)
- Build tools (Webpack, Vite, Turbo)

### External Integrations
Optional sync with:
- **JIRA**: Link features to tickets
- **Confluence**: Publish specs and plans
- **GitHub**: Auto-link PRs and issues

Configure via `CLAUDE.md` in your project root.

## Help & Documentation

### In-App Help
From any menu, select **"❓ Get Help"** for context-aware assistance.

### Documentation
- **Quick Start**: `.claude/skills/workflow/quick-start.md`
- **Glossary**: `.claude/skills/workflow/glossary.md`
- **Phase Guides**: `.claude/skills/workflow/phases/*/guide.md`
- **Templates**: `.claude/skills/workflow/templates/README.md`

### Support
- **Issues**: Report at plugin repository
- **Questions**: Use "Ask a Question" in help mode
- **Feedback**: Submit via `/workflow:track` → View Docs

## Best Practices

### For New Users
1. Start with **Auto Mode** - let Spec guide you
2. Review generated specs - ensure they match your intent
3. Use **checkpoints** - refine before continuing
4. Leverage **help mode** - ask questions anytime

### For Teams
1. **Commit memory state** - share decisions and progress
2. **Review specs together** - ensure alignment
3. **Use ADRs** - document architectural choices
4. **Track velocity** - understand team capacity

### For Complex Projects
1. **Initialize with blueprint** - define architecture first
2. **Break into features** - small, focused specs
3. **Use clarify phase** - resolve ambiguities early
4. **Validate often** - run consistency checks

## Troubleshooting

### Common Issues

**Q: `/workflow:spec` shows "not initialized"**
A: Run `/workflow:spec` → Select "🚀 Initialize Project"

**Q: Lost my place in a feature**
A: Run `/workflow:spec` - it will show your current state and options to continue

**Q: Want to start over on a feature**
A: Delete the feature directory in `.spec/features/` and start fresh

**Q: Checkpoints not appearing**
A: Ensure you're in Auto Mode. Manual mode doesn't show automatic checkpoints.

**Q: State files not updating**
A: Check that `.spec/state/` exists and has proper permissions

### Getting Help

1. **In-app**: `/workflow:spec` → "❓ Get Help"
2. **Documentation**: See `.claude/skills/workflow/` guides
3. **Support**: Report issues to plugin maintainers

## Changelog

### v3.3.0 (Current)
- ✨ Interactive menu system with 6 workflow states
- ✨ Auto mode with checkpoints
- ✨ State management with templates
- ✨ Smart hook auto-detection
- ♻️  Refactored to single command interface (`/workflow:spec`)
- 📝 Complete documentation overhaul
- 🐛 Fixed 100% error rate for new users
- ⚡ 22% token reduction

### v3.2.0
- Multi-agent coordination
- TDD mode
- External integrations (JIRA, Confluence)

### v3.1.0
- Initial release

## Contributing

Contributions welcome! Areas for improvement:
- Additional phase guides
- Custom templates
- Integration plugins
- Documentation improvements

## License

MIT License - See LICENSE file for details

---

**Made with ❤️ for specification-driven development**

For the latest updates and detailed guides, see the `.claude/skills/workflow/` directory.
