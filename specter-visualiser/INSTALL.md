# Installation Guide

## Quick Install

```bash
# Navigate to the tool directory
cd specter-visualiser

# Install dependencies
npm install

# Build the project
npm run build

# Link globally
npm link

# Verify installation
specter-viz --version
```

## Usage

Once installed, navigate to any Specter project and run:

```bash
# Quick status
specter-viz status

# Interactive dashboard
specter-viz

# Browse specifications
specter-viz specs

# View metrics
specter-viz metrics

# Watch mode
specter-viz watch

# List features
specter-viz list

# Validate project
specter-viz validate
```

## Troubleshooting

### Module Not Found Errors

If you encounter "Cannot find module" errors, ensure all imports have `.js` extensions:

```typescript
// Correct (ES modules)
import { Something } from './module.js';

// Incorrect
import { Something } from './module';
```

This is required when using `"type": "module"` in package.json.

### Build Errors

If the build fails, try:

```bash
# Clean and rebuild
rm -rf dist node_modules
npm install
npm run build
```

### Permission Errors

If you get permission errors when linking:

```bash
# Use sudo (macOS/Linux)
sudo npm link

# Or install locally
npm install -g .
```

## Development Mode

For development with hot reloading:

```bash
npm run dev
```

## Uninstall

```bash
npm unlink -g specter-visualiser
# or
npm uninstall -g specter-visualiser
```

## Requirements

- Node.js >= 18.0.0
- npm >= 9.0.0
- A Specter-initialized project to visualize

## Next Steps

Once installed, see:
- [README.md](./README.md) - Full documentation
- [EXAMPLES.md](./EXAMPLES.md) - Usage examples
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development guide
