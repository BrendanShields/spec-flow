# Installation Guide

## Quick Install

```bash
# Navigate to the tool directory
cd spec-visualiser

# Install dependencies
npm install

# Build the project
npm run build

# Link globally
npm link

# Verify installation
spec-viz --version
```

## Usage

Once installed, navigate to any Spec project and run:

```bash
# Quick status
spec-viz status

# Interactive dashboard
spec-viz

# Browse specifications
spec-viz specs

# View metrics
spec-viz metrics

# Watch mode
spec-viz watch

# List features
spec-viz list

# Validate project
spec-viz validate
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
npm unlink -g spec-visualiser
# or
npm uninstall -g spec-visualiser
```

## Requirements

- Node.js >= 18.0.0
- npm >= 9.0.0
- A Spec-initialized project to visualize

## Next Steps

Once installed, see:
- [README.md](./README.md) - Full documentation
- [EXAMPLES.md](./EXAMPLES.md) - Usage examples
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development guide
