# Plugin Template

Use this template as a starting point for creating new plugins.

## Directory Structure

```
your-plugin-name/
├── .claude/
│   ├── commands/
│   │   └── your-command.md
│   ├── skills/
│   │   └── your-skill/
│   │       ├── SKILL.md
│   │       ├── examples.md
│   │       └── reference.md
│   └── hooks/
│       └── hooks.json
├── src/
│   └── index.js
├── tests/
│   └── test.js
├── .mcp.json
├── package.json
├── README.md
└── LICENSE
```

## File Templates

### .claude/commands/your-command.md

```markdown
# Your Command Name

Brief description of what this command does

## Usage
```bash
/your-command [options] <arguments>
```

## Options
- `--option1` - Description of option 1
- `--option2=value` - Description of option 2

## Examples
```bash
/your-command example1
/your-command --option1 example2
```

## Implementation
When this command runs, it will:
1. Step 1
2. Step 2
3. Step 3
```

### .claude/skills/your-skill/SKILL.md

```markdown
# Your Skill Name

## Description
What this skill does and when it should be used

## Triggers
- When user says "trigger phrase"
- When user mentions "domain term"
- When context includes [pattern]

## Workflow
1. Initial analysis
2. Processing step
3. Output generation

## Integration Points
- Works with: [other skills]
- Requires: [dependencies]
- Outputs: [format]

## Error Handling
- Common error 1: How to handle
- Common error 2: How to handle
```

### .mcp.json

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
      "description": "What this tool does",
      "parameters": {
        "type": "object",
        "properties": {
          "param1": {
            "type": "string",
            "description": "Parameter description"
          }
        },
        "required": ["param1"]
      }
    }
  ]
}
```

### package.json

```json
{
  "name": "claude-plugin-your-name",
  "version": "1.0.0",
  "description": "Your plugin description",
  "main": "src/index.js",
  "scripts": {
    "test": "jest",
    "build": "webpack",
    "lint": "eslint src/"
  },
  "keywords": ["claude", "plugin", "your-domain"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {},
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
```

### README.md

```markdown
# Your Plugin Name

Brief description of what your plugin does

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

```bash
/plugin install your-plugin@spec-marketplace
```

## Usage

### Basic Usage
```bash
/your-command basic-example
```

### Advanced Usage
```bash
/your-command --advanced complex-example
```

## Commands

### /your-command
Description of the command

**Options:**
- `--option1` - What it does
- `--option2` - What it does

**Examples:**
```bash
/your-command example
```

## Skills

### your-skill
Description of the skill

**Triggers:**
- "trigger phrase"
- "another trigger"

## Configuration

```json
{
  "setting1": "value1",
  "setting2": "value2"
}
```

## Development

```bash
# Clone
git clone <repo>

# Install
npm install

# Test
npm test

# Build
npm run build
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open pull request

## License

MIT

## Author

Your Name (your.email@example.com)
```

### LICENSE

```
MIT License

Copyright (c) 2024 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Quick Start

1. Copy this template directory
2. Rename to your plugin name (kebab-case)
3. Update all placeholder text
4. Implement your functionality
5. Test locally
6. Submit PR

## Checklist

- [ ] Named appropriately (kebab-case)
- [ ] README.md completed
- [ ] LICENSE file added
- [ ] Commands documented
- [ ] Skills documented
- [ ] Examples provided
- [ ] Tests written
- [ ] Locally tested
- [ ] No hardcoded secrets
- [ ] Version set to 1.0.0