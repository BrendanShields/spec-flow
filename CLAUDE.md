# Flow Workflow System

Flow is a specification-driven development workflow for Claude Code. Quick reference below, [full docs here](.flow/docs/CLAUDE-FLOW.md).

## Quick Commands

```bash
/flow                    # Interactive workflow menu
/flow init              # Initialize Flow in project
/flow specify "feature" # Create feature specification
/flow plan              # Design technical plan
/flow tasks             # Break into implementation tasks
/flow implement         # Execute implementation
/flow validate          # Check workflow consistency
/flow status            # Show current progress
/flow help              # Context-aware help
```

## Configuration

**Location**: `.flow/config/flow.json`

```bash
# Read config
source .flow/scripts/config.sh
project_type=$(get_flow_config "project.type")

# Update config
set_flow_config "integrations.jira.enabled" "true"
```

**Project Types**:
- **Greenfield**: New projects with full architecture
- **Brownfield**: Existing codebases, feature-focused

**Integrations**: JIRA, Confluence (optional, configured via `/flow init`)

## Directory Structure

```
.flow/
├── config/          # Configuration (flow.json)
├── state/           # Session state (git-ignored)
├── memory/          # Progress, decisions, changes (committed)
├── features/        # Feature specs, plans, tasks (committed)
├── templates/       # Document templates
├── scripts/         # Utility scripts (config.sh, routing.sh, format-output.sh)
└── docs/            # Complete documentation
```

**See**: [.flow/docs/CLAUDE-FLOW.md](.flow/docs/CLAUDE-FLOW.md) for complete documentation.

---

# Claude Code Marketplace Repository

This repository contains Claude Code marketplace plugins. Each plugin is self-contained in the `plugins/` directory.

## Repository Structure

```
spec-flow/                      # Marketplace root
├── plugins/                    # Marketplace plugins
│   └── flow/                   # Flow specification-driven development plugin
│       ├── CLAUDE.md          # Plugin-specific instructions
│       ├── README.md          # Plugin documentation
│       ├── docs/              # Plugin user guides
│       ├── .claude/           # Plugin skills, commands, agents
│       └── templates/         # Plugin templates
│
├── CLAUDE.md                  # This file - marketplace maintenance
└── README.md                  # Marketplace index

```

## Maintenance Guidelines

### Working on Plugins

When working on a plugin, Claude Code should:

1. **Navigate to plugin directory**: `cd plugins/{plugin-name}`
2. **Read plugin CLAUDE.md**: Each plugin has specific instructions
3. **Follow plugin structure**: Respect the plugin's internal organization
4. **Update plugin docs**: Keep plugin documentation in `plugins/{plugin-name}/docs/`

### Plugin Development

Each plugin should be **self-contained**:

✅ **Include in plugin directory:**
- `CLAUDE.md` - Plugin-specific instructions for Claude
- `README.md` - User-facing documentation
- `docs/` - All plugin documentation
- `.claude/` - Skills, commands, agents, hooks
- `templates/` - Plugin-specific templates

❌ **Do NOT put in marketplace root:**
- Plugin user guides
- Plugin-specific documentation
- Plugin examples or tutorials
- Plugin implementation details

### Directory Guidelines

**Marketplace Root** (this directory):
- Marketplace overview
- Plugin index/catalog
- Marketplace-level configuration
- Cross-plugin shared resources (if any)

**Plugin Directory** (`plugins/{name}/`):
- Everything specific to that plugin
- Self-contained and portable
- Can be copied/moved independently
- Complete documentation within

## Current Plugins

### Flow Plugin
**Location**: `plugins/flow/`
**Purpose**: Specification-driven development workflow
**Documentation**: See `plugins/flow/README.md`
**Instructions**: See `plugins/flow/CLAUDE.md`

## Adding New Plugins

1. Create directory: `plugins/{plugin-name}/`
2. Add plugin files:
   ```
   plugins/{plugin-name}/
   ├── CLAUDE.md              # Instructions for Claude
   ├── README.md              # User documentation
   ├── docs/                  # User guides
   └── .claude/               # Skills/commands
   ```
3. Keep plugin self-contained
4. Update this file's plugin list

## Repository Maintenance

### File Organization Rules

1. **Plugin-specific content** → `plugins/{name}/`
2. **Marketplace content** → Root directory
3. **Documentation** → Within respective plugin
4. **Shared utilities** → Consider carefully, prefer duplication

### When to Put Files in Root

Only put files in root that are:
- About the marketplace itself
- Truly shared across all plugins
- Marketplace-level configuration

### Version Control

Each plugin should:
- Version independently
- Have own changelog
- Document breaking changes
- Maintain backward compatibility

## Working with Claude Code

### For Plugin Development

```bash
# Navigate to plugin
cd plugins/flow

# Claude reads plugin CLAUDE.md automatically
# Work within plugin context
```

### For Marketplace Maintenance

```bash
# Stay in root directory
# Update marketplace documentation
# Manage plugin catalog
```

## Best Practices

### Plugin Design
✅ Self-contained plugins
✅ Clear plugin boundaries
✅ Independent versioning
✅ Complete documentation within plugin

### Documentation
✅ User guides in `plugins/{name}/docs/`
✅ Plugin README in `plugins/{name}/README.md`
✅ Marketplace overview in root `README.md`

### Dependencies
✅ Document plugin dependencies
✅ Minimize cross-plugin dependencies
✅ Make plugins portable

## References

- **Flow Plugin Documentation**: `plugins/flow/README.md`
- **Flow Plugin Instructions**: `plugins/flow/CLAUDE.md`
- **Flow User Guides**: `plugins/flow/docs/`

---

**When working on a plugin**: Navigate to `plugins/{plugin-name}` and read its `CLAUDE.md` file.