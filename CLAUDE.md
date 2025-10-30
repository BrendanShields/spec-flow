# Claude Plugin Marketplace

A comprehensive guide for engineers to manage, develop, and contribute plugins to the Claude Code ecosystem.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Marketplace Overview](#marketplace-overview)
3. [Plugin Development](#plugin-development)
4. [Contributing Plugins](#contributing-plugins)
5. [Marketplace Management](#marketplace-management)
6. [Testing & Validation](#testing--validation)
7. [Best Practices](#best-practices)
8. [API Reference](#api-reference)
9. [Troubleshooting](#troubleshooting)

---

## Quick Start

### For Plugin Users
```bash
# Add this marketplace
/plugin marketplace add claude-code/specter-marketplace

# Browse available plugins
/plugin marketplace list

# Install a plugin
/plugin install specter@specter-marketplace

# Update plugins
/plugin marketplace update specter-marketplace
```

### For Plugin Developers
```bash
# Clone the marketplace
git clone https://github.com/claude-code/specter-marketplace.git
cd specter-marketplace

# Create a new plugin
mkdir -p plugins/your-plugin-name
cd plugins/your-plugin-name

# Initialize plugin structure
touch .claude/commands/your-command.md
touch .claude/skills/your-skill/SKILL.md
touch .mcp.json  # If using MCP integration

# Test locally
/plugin install ./plugins/your-plugin-name

# Submit via PR
git checkout -b feat/add-your-plugin
git add .
git commit -m "feat: Add your-plugin-name plugin"
git push origin feat/add-your-plugin
```

---

## Marketplace Overview

### Architecture
```
specter-marketplace/
├── .claude-plugin/
│   └── marketplace.json        # Marketplace catalog
├── plugins/                    # Plugin collection
│   ├── flow/                   # Example: Flow plugin
│   │   ├── .claude/            # Claude-specific files
│   │   ├── .mcp.json           # MCP configuration
│   │   └── README.md           # Plugin documentation
│   └── your-plugin/            # Your plugin here
├── scripts/                    # Maintenance scripts
│   ├── validate.sh            # Validate marketplace.json
│   ├── test-plugin.sh         # Test individual plugins
│   └── update-versions.sh     # Update plugin versions
├── docs/                       # Documentation
│   ├── PLUGIN-TEMPLATE.md     # Plugin template
│   ├── REVIEW-CHECKLIST.md    # PR review checklist
│   └── API.md                 # API documentation
├── claude.md                   # This file
└── README.md                   # User-facing documentation
```

### Marketplace Configuration

The `.claude-plugin/marketplace.json` file defines the marketplace:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "specter-marketplace",
  "version": "1.2.0",
  "description": "AI-powered development marketplace",
  "owner": {
    "name": "Claude Code Community",
    "email": "plugins@claudecode.dev",
    "url": "https://github.com/claude-code/specter-marketplace"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Clear, concise description",
      "source": "./plugins/plugin-name",
      "category": "development|testing|deployment|utilities",
      "version": "1.0.0",
      "author": {
        "name": "Your Name",
        "email": "your.email@example.com"
      },
      "keywords": ["relevant", "searchable", "terms"],
      "license": "MIT",
      "homepage": "https://github.com/you/plugin",
      "repository": {
        "type": "git",
        "url": "https://github.com/you/plugin.git"
      }
    }
  ]
}
```

---

## Plugin Development

### Plugin Structure

Every plugin must follow this structure:

```
your-plugin/
├── .claude/                    # Claude-specific files (required)
│   ├── commands/              # Slash commands
│   │   └── your-command.md    # Command definition
│   ├── skills/                # Skills (advanced commands)
│   │   └── your-skill/
│   │       ├── SKILL.md       # Skill definition
│   │       ├── examples.md    # Usage examples
│   │       └── reference.md   # Technical reference
│   ├── agents/                # AI agents (optional)
│   │   └── your-agent/
│   │       └── agent.md       # Agent definition
│   └── hooks/                 # Event hooks (optional)
│       └── hooks.json         # Hook configuration
├── .mcp.json                  # MCP server config (optional)
├── src/                       # Source code (if applicable)
├── tests/                     # Test files
├── README.md                  # Plugin documentation (required)
├── LICENSE                    # License file (required)
└── package.json              # Dependencies (if Node.js)
```

### Creating Commands

Commands are user-facing operations starting with `/`. Create in `.claude/commands/`:

```markdown
# your-command.md

<!-- Description shown in help -->
Execute specialized task for your domain

## Usage
/your-command [options] <arguments>

## Options
- `--flag` - Enable specific behavior
- `--param=value` - Set parameter value

## Examples
```bash
/your-command --flag argument
/your-command --param=production deploy
```

## Implementation
<!-- Claude will expand this when command is run -->
<command-implementation>
1. Parse the arguments
2. Execute the main logic
3. Return formatted results
</command-implementation>
```

### Creating Skills

Skills are complex, multi-step operations. Create in `.claude/skills/your-skill/`:

**SKILL.md:**
```markdown
# Your Skill Name

## Triggers
- User says "specific phrase"
- User requests "domain task"
- Context matches pattern

## Progressive Disclosure
<step-1>
Initial simple response
</step-1>

<step-2-if-needed>
More detailed implementation
</step-2-if-needed>

## Examples
[Concrete usage examples]

## Integration Points
- Works with: other-skill
- Requires: specific-tools
- Outputs: expected-format
```

### Creating Agents

Agents are autonomous AI workers. Create in `.claude/agents/your-agent/`:

**agent.md:**
```markdown
# Your Agent

## Purpose
Autonomous execution of specific domain tasks

## Tools Available
- Read, Write, Edit
- Bash, Grep, Glob
- WebSearch, WebFetch

## Workflow
1. Analyze request
2. Plan approach
3. Execute tasks
4. Validate results
5. Report completion

## Error Handling
- Retry logic
- Fallback strategies
- User notification
```

### MCP Integration

For Model Context Protocol servers, create `.mcp.json`:

```json
{
  "name": "your-plugin-mcp",
  "description": "MCP server for your plugin",
  "version": "1.0.0",
  "main": "dist/index.js",
  "requirements": {
    "node": ">=18.0.0"
  },
  "tools": [
    {
      "name": "your_tool",
      "description": "Tool description",
      "parameters": {
        "type": "object",
        "properties": {
          "param": {
            "type": "string",
            "description": "Parameter description"
          }
        },
        "required": ["param"]
      }
    }
  ]
}
```

---

## Contributing Plugins

### Submission Process

1. **Fork & Clone**
   ```bash
   git fork https://github.com/claude-code/specter-marketplace
   git clone https://github.com/YOUR_USERNAME/specter-marketplace
   cd specter-marketplace
   ```

2. **Create Plugin**
   ```bash
   # Use the template
   cp -r docs/plugin-template plugins/your-plugin
   cd plugins/your-plugin
   # Develop your plugin
   ```

3. **Test Locally**
   ```bash
   # Validate structure
   ../../scripts/test-plugin.sh your-plugin

   # Test in Claude
   /plugin install ./plugins/your-plugin
   ```

4. **Update Marketplace**
   ```bash
   # Edit marketplace.json
   code .claude-plugin/marketplace.json
   # Add your plugin entry
   ```

5. **Submit PR**
   ```bash
   git checkout -b feat/add-your-plugin
   git add .
   git commit -m "feat: Add your-plugin plugin

   - Clear description of functionality
   - List key features
   - Note any dependencies"
   git push origin feat/add-your-plugin
   ```

### Review Criteria

Your plugin will be reviewed for:

- **Functionality**: Does it work as described?
- **Documentation**: Clear README and examples?
- **Structure**: Follows required format?
- **Quality**: Clean code, no errors?
- **Security**: No malicious code?
- **License**: Appropriate open-source license?
- **Uniqueness**: Adds value vs existing plugins?

### Versioning

Follow semantic versioning (semver):
- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

Update version in:
1. `marketplace.json` plugin entry
2. Plugin's `package.json` (if applicable)
3. Plugin's README.md

---

## Marketplace Management

### For Maintainers

#### Adding Plugins
```bash
# Review PR
gh pr checkout <PR-number>

# Test plugin
./scripts/test-plugin.sh <plugin-name>

# Validate marketplace
./scripts/validate.sh

# Merge if passing
gh pr merge <PR-number>
```

#### Updating Versions
```bash
# Update all plugin versions
./scripts/update-versions.sh

# Update specific plugin
./scripts/update-versions.sh flow

# Commit changes
git commit -m "chore: Update plugin versions"
```

#### Removing Plugins
```bash
# Archive plugin (keep history)
git mv plugins/old-plugin archived/old-plugin

# Update marketplace.json
# Remove plugin entry

# Document removal
echo "Plugin removed: reason" >> CHANGELOG.md
```

### For Organizations

#### Private Marketplace
```json
// .claude/settings.json in your organization repo
{
  "extraKnownMarketplaces": {
    "internal-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/private-claude-plugins"
      }
    }
  }
}
```

#### Team Standards
```json
// Required plugins for team
{
  "requiredPlugins": [
    "flow@specter-marketplace",
    "code-review@internal-tools",
    "deploy-helper@internal-tools"
  ]
}
```

---

## Testing & Validation

### Local Testing

```bash
# Test plugin structure
./scripts/test-plugin.sh your-plugin

# Test commands
/plugin install ./plugins/your-plugin
/your-command --test

# Test skills
echo "trigger phrase" | claude --test-skill your-skill

# Test MCP integration
npm test --prefix plugins/your-plugin
```

### CI/CD Pipeline

```yaml
# .github/workflows/test-plugins.yml
name: Test Plugins
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate marketplace
        run: ./scripts/validate.sh
      - name: Test plugins
        run: |
          for plugin in plugins/*; do
            ./scripts/test-plugin.sh $(basename $plugin)
          done
```

### Validation Checklist

- [ ] Plugin follows directory structure
- [ ] README.md exists and is comprehensive
- [ ] Commands have proper markdown format
- [ ] Skills include examples and triggers
- [ ] No syntax errors in JSON files
- [ ] License file included
- [ ] Version follows semver
- [ ] Keywords are relevant
- [ ] Description is clear and concise
- [ ] Author information complete

---

## Best Practices

### Plugin Design

1. **Single Responsibility**: Each plugin should do one thing well
2. **Clear Naming**: Use descriptive, kebab-case names
3. **Comprehensive Docs**: Include examples, API reference, troubleshooting
4. **Error Handling**: Gracefully handle edge cases
5. **Performance**: Optimize for Claude's context window
6. **Compatibility**: Test with latest Claude Code version

### Code Quality

```javascript
// Good: Clear, documented functions
/**
 * Process user input and generate response
 * @param {string} input - User command
 * @returns {Promise<string>} - Formatted response
 */
async function processCommand(input) {
  // Validate input
  if (!input || typeof input !== 'string') {
    throw new Error('Invalid input');
  }

  // Process with error handling
  try {
    const result = await executeLogic(input);
    return formatResponse(result);
  } catch (error) {
    logger.error('Command failed:', error);
    return formatError(error);
  }
}
```

### Documentation Standards

```markdown
# Plugin Name

## Overview
Brief description (1-2 sentences)

## Features
- Bullet point list
- Of key capabilities

## Installation
```bash
/plugin install plugin-name@specter-marketplace
```

## Usage

### Basic Example
[Simple use case]

### Advanced Example
[Complex scenario]

## Configuration
[Any settings or options]

## API Reference
[Detailed command/function docs]

## Troubleshooting
[Common issues and solutions]

## Contributing
[How to contribute]

## License
[License type]
```

### Security Guidelines

1. **No Secrets**: Never hardcode API keys or passwords
2. **Input Validation**: Always validate user input
3. **Sandboxing**: Use Claude's sandbox when available
4. **Permissions**: Request minimum required permissions
5. **Dependencies**: Keep dependencies updated
6. **Code Review**: All plugins reviewed before merge

---

## API Reference

### Marketplace API

#### Add Marketplace
```bash
/plugin marketplace add <source>
```
Sources:
- GitHub: `owner/repo`
- Git URL: `https://git.example.com/plugins.git`
- Local: `./path/to/marketplace`

#### List Marketplaces
```bash
/plugin marketplace list
```

#### Update Marketplace
```bash
/plugin marketplace update <name>
```

#### Remove Marketplace
```bash
/plugin marketplace remove <name>
```

### Plugin API

#### Install Plugin
```bash
/plugin install <name>[@<marketplace>]
```

#### List Plugins
```bash
/plugin list [--installed | --available]
```

#### Update Plugin
```bash
/plugin update <name>
```

#### Remove Plugin
```bash
/plugin remove <name>
```

### Development API

#### Test Plugin
```bash
/plugin test <path>
```

#### Validate Plugin
```bash
/plugin validate <path>
```

#### Package Plugin
```bash
/plugin package <path> [--output=<file>]
```

---

## Troubleshooting

### Common Issues

#### Plugin Not Found
```bash
Error: Plugin 'name' not found in marketplace
```
**Solution**: Check spelling, ensure marketplace is added, run update

#### Version Conflicts
```bash
Error: Plugin requires Claude Code version >= 2.0.0
```
**Solution**: Update Claude Code or use older plugin version

#### Installation Fails
```bash
Error: Failed to install plugin dependencies
```
**Solution**: Check network, verify Node.js version, clear cache

#### Command Not Recognized
```bash
Error: Unknown command /your-command
```
**Solution**: Restart Claude, check command file format, verify installation

### Debug Mode

```bash
# Enable debug logging
export CLAUDE_DEBUG=true

# Verbose output
/plugin install <name> --verbose

# Check plugin status
/plugin status <name>

# View logs
cat ~/.claude/logs/plugin-install.log
```

### Getting Help

1. **Documentation**: Check plugin's README.md
2. **Issues**: Search/create GitHub issues
3. **Community**: Join Discord/Slack channels
4. **Support**: Contact plugin author
5. **Maintainers**: Tag @claude-code-team

---

## Appendices

### A. Plugin Categories

- **development**: Code generation, refactoring, analysis
- **testing**: Test generation, runners, coverage
- **deployment**: CI/CD, cloud, containers
- **utilities**: Formatters, linters, converters
- **productivity**: Workflows, automation, shortcuts
- **integrations**: External services, APIs
- **documentation**: Generators, parsers, validators
- **security**: Scanning, auditing, compliance

### B. License Types

Recommended licenses (SPDX identifiers):
- `MIT`: Permissive, widely compatible
- `Apache-2.0`: Patent protection
- `GPL-3.0`: Copyleft, derivative works
- `BSD-3-Clause`: Permissive with attribution
- `ISC`: Simplified MIT-style

### C. Useful Resources

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Plugin Development Guide](https://docs.claude.com/claude-code/plugins)
- [MCP Specification](https://modelcontextprotocol.com)
- [Marketplace Schema](https://anthropic.com/claude-code/marketplace.schema.json)
- [Community Forum](https://community.claude.com)
- [Example Plugins](https://github.com/claude-code/examples)

### D. Changelog

See [CHANGELOG.md](./CHANGELOG.md) for marketplace version history.

---

## Quick Reference Card

```bash
# Essential Commands
/plugin marketplace add <source>        # Add marketplace
/plugin install <name>                  # Install plugin
/plugin list                           # List all plugins
/plugin update <name>                  # Update plugin
/plugin remove <name>                  # Remove plugin

# Development Commands
/plugin test ./path                    # Test local plugin
/plugin validate ./path                # Validate structure
/plugin package ./path                 # Create package

# Maintenance Commands
/plugin marketplace update <name>      # Update catalog
/plugin status <name>                  # Check plugin status
/plugin marketplace list               # List marketplaces
```

---

*Last Updated: 2024*
*Version: 1.0.0*
*Maintainers: Claude Code Community*

For the latest version of this guide, visit:
https://github.com/claude-code/specter-marketplace/blob/main/claude.md