---
description: Update readme.md based on current codebase
allowed-tools: Read, Write, Glob, Bash(npm:*)
model: sonnet
---

Current README:
@readme.md

Package configuration:
@package.json

Project structure:
!`tree -L 2 -I 'node_modules|.git|dist|build' . || find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git`

Please update the README to ensure it accurately reflects:

1. **Project Description**
   - Current purpose and features
   - Key capabilities

2. **Installation**
   - Dependencies (from package.json)
   - Setup steps
   - Prerequisites

3. **Usage**
   - Basic usage examples
   - Common commands
   - Configuration options

4. **API Documentation** (if applicable)
   - Endpoints or exported functions
   - Parameters and returns

5. **Development**
   - How to run locally
   - How to run tests
   - How to contribute

Maintain existing structure but update outdated information. Preserve any custom sections.
