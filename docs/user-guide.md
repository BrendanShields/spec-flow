# Navi User Guide

> **Version 2.0.0** - The intelligent specification-driven development workflow

## 🚀 Quick Start

Get started with Navi in seconds:

```bash
# Initialize Navi in your project
/navi init

# Or just type /navi - it knows what to do!
/navi
```

That's it! Navi will guide you through everything else.

## 🧭 What is Navi?

Navi is an intelligent workflow navigator that helps you build software through specification-driven development. It understands natural language, suggests next steps, and automates repetitive tasks.

### Key Features

- **🎯 One Command**: Just `/navi` - it figures out what you need
- **💬 Natural Language**: Type what you think: `/navi build this feature`
- **⚡ 60% Faster**: Parallel execution for all operations
- **🧠 Intelligent**: Learns your patterns and suggests next steps
- **📉 37% Less Tokens**: Optimized for AI efficiency

## 📋 Core Workflow

Navi guides you through a proven development workflow:

```
1. Specify → 2. Plan → 3. Tasks → 4. Implement → 5. Validate
```

### 1️⃣ Specify
Define what you want to build:
```bash
/navi specify "user authentication with OAuth"
```

Creates a detailed specification with:
- User stories with priorities (P1, P2, P3)
- Acceptance criteria
- Success metrics

### 2️⃣ Plan
Design the technical approach:
```bash
/navi plan
```

Generates:
- Architecture decisions (ADRs)
- Component design
- Data models
- API contracts

### 3️⃣ Tasks
Break down into actionable tasks:
```bash
/navi tasks
```

Creates:
- Numbered tasks (T001, T002...)
- Dependency mapping
- Parallel execution markers [P]

### 4️⃣ Implement
Execute the implementation:
```bash
/navi implement          # Normal execution
/navi implement --parallel  # 60% faster!
```

Features:
- Autonomous task execution
- Progress tracking
- Error recovery
- Parallel processing

### 5️⃣ Validate
Check everything is correct:
```bash
/navi validate
```

Validates:
- Requirement coverage
- Task completion
- Consistency checks
- Quality gates

## ⚡ Shortcuts & Natural Language

### Single-Letter Shortcuts
- `c` → Continue where you left off
- `b` → Build/implement
- `v` → Validate
- `s` → Status
- `h` → Help

### Natural Language Examples
```bash
/navi start new feature      # → init/specify
/navi build this            # → implement
/navi what's next           # → shows suggestion
/navi check my work         # → validate
/navi show progress         # → status
```

### Just Type /navi!
Navi always knows what to do next:
- No feature? → Suggests init
- Have spec? → Suggests plan
- Have tasks? → Suggests implement
- All done? → Suggests validate

## 📊 Status & Progress

Check your progress anytime:

```bash
/navi status
```

Shows:
```
╔════════════════════════════════════╗
║       NAVI WORKFLOW STATUS         ║
╠════════════════════════════════════╣
║ Feature: User Authentication       ║
║ Phase: implement                    ║
║ Progress: [████████░░] 8/10 (80%)  ║
║                                    ║
║ Next Step: /navi implement         ║
╚════════════════════════════════════╝
```

## 🔄 Migration from Flow

If you're upgrading from Flow to Navi:

### Automatic Migration
```bash
# Run the migration tool
bash __specification__/scripts/migrate-to-navi.sh

# Or with auto-confirm
bash __specification__/scripts/migrate-to-navi.sh --auto
```

### What Changes
- `.flow/` → `__specification__/`
- `flow` commands → `navi` commands
- All your work is preserved!

### Compatibility
- Old `/flow-*` commands still work (with deprecation warnings)
- 30-day transition period
- Rollback available if needed

## 🛠️ Configuration

### Location
`__specification__/config/navi.json`

### Key Settings
```json
{
  "preferences": {
    "interactive_mode": true,    // Visual menus
    "parallel_execution": true,   // 60% faster
    "progressive_disclosure": true // Smart help
  },
  "parallel": {
    "max_workers": 4,            // Concurrent tasks
    "file_operations": 6         // Concurrent files
  }
}
```

### Integrations
- **JIRA**: Sync tasks and progress
- **Confluence**: Publish documentation
- **GitHub**: Create PRs automatically

## 💡 Pro Tips

### Speed Up Your Workflow
1. **Use shortcuts**: `c` instead of `continue`
2. **Natural language**: Say what you think
3. **Parallel mode**: Add `--parallel` for speed
4. **Just /navi**: Let it guide you

### Best Practices
1. **Be specific** in specifications
2. **Mark priorities** (P1, P2, P3)
3. **Use [P] markers** for parallel tasks
4. **Check /navi status** frequently
5. **Trust the suggestions** - Navi learns

### Common Patterns
```bash
# Monday morning - review and plan
/navi status
/navi specify "next feature"

# Deep work time - implement
/navi implement --parallel

# Before break - checkpoint
/navi status

# End of day - validate
/navi validate
```

## 🆘 Troubleshooting

### Navi doesn't know what to do?
```bash
/navi status  # Check current state
/navi help    # Get contextual help
```

### Implementation stuck?
```bash
# Check what's blocking
/navi status

# Try parallel mode
/navi implement --parallel
```

### Need to go back?
```bash
# Rollback migration if needed
bash __specification__/scripts/rollback-migration.sh
```

## 📚 Advanced Features

### Custom Shortcuts
Create your own in `__specification__/config/personal-shortcuts.txt`

### Hooks
Automate actions with `__specification__/hooks/`

### Templates
Customize templates in `__specification__/templates/`

### Parallel Execution
Configure in `__specification__/config/navi.json`:
```json
{
  "parallel": {
    "max_workers": 4,
    "timeout": 120000
  }
}
```

## 📈 Performance

Navi is optimized for speed and efficiency:

- **Token Usage**: 37% reduction
- **Execution Speed**: 60% faster with parallel
- **Learning Curve**: Minutes instead of days
- **Commands**: 1 instead of 15+

## 🎯 Command Reference

### Essential Commands
| Command | Description | Shortcut |
|---------|-------------|----------|
| `/navi` | Auto-continue from context | - |
| `/navi init` | Initialize project | - |
| `/navi specify` | Create specification | - |
| `/navi plan` | Design architecture | - |
| `/navi tasks` | Break into tasks | - |
| `/navi implement` | Execute tasks | `b` |
| `/navi validate` | Check consistency | `v` |
| `/navi status` | Show progress | `s` |
| `/navi help` | Get help | `h` |

### Flags & Options
- `--parallel` - Use parallel execution (60% faster)
- `--auto` - Skip confirmations
- `--verbose` - Show detailed output

## 🌟 What's New in v2.0

### Major Improvements
- **Rebranded**: Flow → Navi
- **Intelligent Routing**: Natural language understanding
- **60% Faster**: Parallel execution everywhere
- **37% Efficient**: Optimized token usage
- **80% Simpler**: One command instead of many
- **Smart Suggestions**: Context-aware next steps
- **Progressive Help**: Shows only what you need

### Technical Enhancements
- Common utility libraries (DRY)
- Worker pool pattern
- Progressive disclosure
- Lazy loading
- Context compression

## 📖 Learn More

- **Examples**: `__specification__/examples/`
- **Templates**: `__specification__/templates/`
- **API Docs**: `docs/api-reference.md`
- **Migration Guide**: `docs/migration-guide.md`

## 💬 Getting Help

1. **In-tool help**: `/navi help`
2. **Documentation**: This guide and others in `docs/`
3. **Issues**: Report at the project repository
4. **Community**: Join discussions

---

**Remember**: When in doubt, just type `/navi` - it knows what to do! 🧭