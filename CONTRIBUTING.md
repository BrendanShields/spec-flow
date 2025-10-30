# Contributing to Claude Plugin Marketplace

Thank you for your interest in contributing to the Claude Plugin Marketplace! This guide will help you submit high-quality plugins that benefit the entire Claude Code community.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Submission Guidelines](#submission-guidelines)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites

- Git and GitHub account
- Claude Code installed
- Node.js 18+ (for JavaScript plugins)
- Basic understanding of Claude Code plugin system

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/specter-marketplace.git
   cd specter-marketplace
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/claude-code/specter-marketplace.git
   ```

4. Keep your fork updated:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

## Development Process

### 1. Choose Plugin Type

Decide what type of plugin you're creating:

- **Command Plugin**: Adds new slash commands
- **Skill Plugin**: Adds intelligent automation
- **Agent Plugin**: Adds autonomous workers
- **MCP Plugin**: Integrates with external services
- **Workflow Plugin**: Combines multiple capabilities

### 2. Use the Template

Start with our plugin template:

```bash
cp -r docs/plugin-template plugins/your-plugin-name
cd plugins/your-plugin-name
```

### 3. Implement Your Plugin

Follow the structure:

```
your-plugin-name/
├── .claude/
│   ├── commands/        # Slash commands
│   ├── skills/          # AI skills
│   ├── agents/          # Autonomous agents
│   └── hooks/           # Event hooks
├── src/                 # Source code
├── tests/               # Test files
├── README.md           # Documentation
├── LICENSE             # License file
└── package.json        # Dependencies (if needed)
```

### 4. Document Thoroughly

Your README.md should include:

- Clear description of what the plugin does
- Installation instructions
- Usage examples with expected output
- Configuration options
- Troubleshooting section
- Author and support information

### 5. Test Locally

Test your plugin before submission:

```bash
# Validate structure
./scripts/test-plugin.sh your-plugin-name

# Install locally
/plugin install ./plugins/your-plugin-name

# Test functionality
/your-command test
```

## Submission Guidelines

### Plugin Requirements

#### Required Files
- `README.md` - Comprehensive documentation
- `LICENSE` - Open source license
- `.claude/` - Claude-specific configuration
- At least one command or skill

#### Plugin Naming
- Use lowercase kebab-case: `my-plugin-name`
- Be descriptive but concise
- Avoid generic names like "helper" or "tool"
- Don't use "claude" in the name (it's implied)

#### Version Management
- Start at version `1.0.0`
- Follow [Semantic Versioning](https://semver.org/)
- Update version in all relevant files:
  - `marketplace.json`
  - `package.json` (if applicable)
  - `README.md`

### Quality Standards

#### Documentation
- Write clear, concise descriptions
- Provide real-world examples
- Document all commands and options
- Include screenshots/GIFs if helpful
- Keep README under 1000 lines

#### Code Quality
- Clean, readable code
- Proper error handling
- No console.log in production
- Validated input parameters
- Appropriate logging levels

#### Performance
- Minimize context usage
- Efficient file operations
- Avoid blocking operations
- Cache when appropriate
- Clean up resources

#### Security
- NO hardcoded secrets
- Validate all user input
- Use environment variables
- Request minimum permissions
- Document external calls

## Code Standards

### JavaScript/TypeScript

```javascript
// Good: Clear function with JSDoc
/**
 * Process user command and return response
 * @param {string} input - User input
 * @returns {Promise<string>} Formatted response
 */
async function processCommand(input) {
  // Validate input
  if (!isValidInput(input)) {
    throw new InvalidInputError('Input validation failed');
  }

  try {
    const result = await executeLogic(input);
    return formatResponse(result);
  } catch (error) {
    logger.error('Command processing failed:', error);
    throw new ProcessingError('Failed to process command', { cause: error });
  }
}
```

### Command Files

```markdown
# Command Name

Brief description

## Usage
\`\`\`bash
/command-name [options] <required> [optional]
\`\`\`

## Options
- `--flag` - Description
- `--param=value` - Description

## Examples
\`\`\`bash
/command-name example
/command-name --flag another-example
\`\`\`
```

### Skill Files

```markdown
# Skill Name

## Triggers
- "specific phrase"
- Pattern: /regex pattern/
- Context: When user is doing X

## Workflow
1. Step one
2. Step two
3. Step three

## Error Handling
- Error type 1: How to handle
- Error type 2: How to handle
```

## Testing Requirements

### Unit Tests

Required for plugins with code:

```javascript
describe('Plugin Name', () => {
  test('should handle basic input', async () => {
    const result = await processCommand('test');
    expect(result).toBe('expected output');
  });

  test('should handle errors gracefully', async () => {
    await expect(processCommand(null)).rejects.toThrow('Input validation failed');
  });
});
```

### Integration Tests

Test with Claude Code:

```bash
# Test command execution
/plugin install ./plugins/your-plugin
/your-command test

# Test error handling
/your-command --invalid-option

# Test help
/your-command --help
```

### Validation Script

Must pass validation:

```bash
./scripts/test-plugin.sh your-plugin-name
# Should output: ✅ All tests passed!
```

## Pull Request Process

### 1. Prepare Your Branch

```bash
git checkout -b feat/add-your-plugin-name
git add .
git commit -m "feat: Add your-plugin-name plugin

- Brief description of functionality
- List of key features
- Any special requirements"
```

### 2. Update Marketplace

Edit `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    // ... existing plugins ...
    {
      "name": "your-plugin-name",
      "description": "Clear, concise description under 200 chars",
      "source": "./plugins/your-plugin-name",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Your Name",
        "email": "your.email@example.com"
      },
      "keywords": ["relevant", "search", "terms"],
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

### 3. Validate Everything

```bash
# Validate marketplace
./scripts/validate.sh

# Test your plugin
./scripts/test-plugin.sh your-plugin-name

# Check for common issues
git diff --check
```

### 4. Submit PR

1. Push to your fork:
   ```bash
   git push origin feat/add-your-plugin-name
   ```

2. Create Pull Request on GitHub
3. Fill out the PR template completely
4. Link any related issues
5. Wait for review

### 5. PR Template

```markdown
## Plugin Submission: [Plugin Name]

### Description
Brief description of what your plugin does

### Checklist
- [ ] Plugin follows directory structure
- [ ] README.md is comprehensive
- [ ] LICENSE file included
- [ ] Tests pass locally
- [ ] marketplace.json updated
- [ ] Version set to 1.0.0
- [ ] No hardcoded secrets
- [ ] Validation script passes

### Testing
How you tested the plugin:
- [ ] Installed locally
- [ ] All commands work
- [ ] Error cases handled
- [ ] Documentation examples work

### Screenshots
[If applicable, add screenshots or GIFs]

### Additional Notes
[Any special considerations for reviewers]
```

## Community Guidelines

### Be Respectful
- Constructive feedback only
- Help others improve their plugins
- Credit original authors
- Follow code of conduct

### Be Collaborative
- Share knowledge and expertise
- Review other submissions
- Report issues helpfully
- Suggest improvements

### Be Patient
- Reviews may take time
- Feedback helps quality
- Iterations are normal
- Learning is ongoing

### Communication Channels

- **GitHub Issues**: Bug reports, feature requests
- **Pull Requests**: Code submissions, reviews
- **Discord**: Real-time community chat
- **Forums**: Long-form discussions

## Review Process

Your submission will be reviewed for:

1. **Functionality** - Does it work as described?
2. **Documentation** - Is it well documented?
3. **Structure** - Does it follow standards?
4. **Quality** - Is the code clean and safe?
5. **Value** - Does it add to the ecosystem?

### Review Timeline

- Initial review: 2-3 business days
- Feedback response: As needed
- Final approval: 1-2 days after fixes
- Merge and release: Same day as approval

### Common Rejection Reasons

- Duplicate functionality
- Poor documentation
- Security concerns
- Broken functionality
- Missing required files
- Not following structure

## Getting Help

### Resources

- [Plugin Template](./docs/PLUGIN-TEMPLATE.md)
- [Review Checklist](./docs/REVIEW-CHECKLIST.md)
- [Claude Code Docs](https://docs.claude.com/claude-code)
- [Example Plugins](./plugins/)

### Support

- Open an issue for questions
- Tag @maintainers for urgent items
- Join Discord for real-time help
- Check existing plugins for examples

## License

By contributing, you agree that your contributions will be licensed under the same license as the marketplace (MIT).

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Plugin author field
- Release notes
- Community highlights

Thank you for contributing to the Claude Plugin Marketplace! Your plugins help make Claude Code more powerful for everyone.

---

*Happy coding! 🚀*