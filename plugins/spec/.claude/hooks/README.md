# Spec Plugin Hooks System

Professional TypeScript-based hooks system for the Spec plugin, providing automated workflow support, metrics tracking, validation, and session management.

## Overview

The hooks system extends Claude Code with automated behaviors triggered by various events:

- **Session Management** - Initialize config, restore/save session state
- **Code Quality** - Validate prerequisites, auto-format code
- **Progress Tracking** - Track workflow status, code metrics
- **Result Aggregation** - Combine subagent outputs

All hooks are written in TypeScript with strict type checking, compiled to JavaScript, and executed via Node.js.

## Architecture

### Directory Structure

```
.claude/hooks/
├── src/                      # TypeScript source files
│   ├── types/               # Type definitions
│   │   ├── config.ts        # SpecConfig, paths, naming
│   │   ├── hook-context.ts  # Hook execution context
│   │   ├── session.ts       # Session state types
│   │   ├── metrics.ts       # Metrics data structures
│   │   └── index.ts         # Central exports
│   │
│   ├── core/                # Core infrastructure
│   │   ├── config-loader.ts # Load/cache .spec-config.yml
│   │   ├── path-resolver.ts # Config-driven path resolution
│   │   ├── logger.ts        # Structured JSON logging
│   │   ├── base-hook.ts     # Abstract hook base class
│   │   └── index.ts         # Core exports
│   │
│   ├── utils/               # Utility functions
│   │   ├── file-utils.ts    # File operations
│   │   ├── yaml-utils.ts    # YAML parsing
│   │   ├── validation.ts    # Input validation
│   │   └── index.ts         # Utility exports
│   │
│   └── hooks/               # Hook implementations
│       ├── session/         # Session hooks
│       │   ├── session-init.ts
│       │   ├── restore-session.ts
│       │   ├── save-session.ts
│       │   └── index.ts
│       │
│       ├── validation/      # Validation hooks
│       │   ├── validate-prerequisites.ts
│       │   ├── format-code.ts
│       │   └── index.ts
│       │
│       ├── tracking/        # Tracking hooks
│       │   ├── track-metrics.ts
│       │   ├── update-workflow-status.ts
│       │   └── index.ts
│       │
│       └── aggregation/     # Aggregation hooks
│           ├── aggregate-results.ts
│           └── index.ts
│
├── dist/                    # Compiled JavaScript (git-ignored)
│   └── hooks/               # Compiled hook files
│
├── node_modules/            # Dependencies (git-ignored)
├── package.json             # Project configuration
├── tsconfig.json            # TypeScript configuration
├── .eslintrc.js             # ESLint configuration
├── .prettierrc              # Prettier configuration
└── README.md                # This file
```

### Hook Lifecycle

1. **Event Trigger** - Claude Code triggers hook event (SessionStart, PreToolUse, etc.)
2. **Context Passed** - Event context passed to hook via stdin (JSON)
3. **Hook Executes** - Node.js runs compiled JavaScript hook
4. **Config Loaded** - Hook loads `.spec-config.yml` (cached)
5. **Action Performed** - Hook executes its logic
6. **Output Returned** - Structured JSON output to stdout
7. **Claude Receives** - Claude Code processes hook output

## Hooks Reference

### Session Hooks

#### `session-init.ts`
**Event:** SessionStart
**Purpose:** Initialize project configuration and directory structure

**Features:**
- Auto-detects project type, language, framework, build tool
- Creates `.claude/.spec-config.yml` with smart defaults
- Validates/creates required directories (supports variable interpolation)
- Loads previous session state
- Outputs session summary to Claude

**Note:** Templates are stored in the plugin at `.claude/skills/workflow/templates/` and used as reference by workflow phases.

**Output:**
```json
{
  "type": "session-initialized",
  "message": "Session initialized",
  "details": {
    "config": { "version": "3.3.0", "paths": {...}, ... },
    "session": { "feature": "...", "phase": "...", ... },
    "firstRun": false
  }
}
```

#### `restore-session.ts`
**Event:** SessionStart
**Purpose:** Restore previous session and suggest next steps

**Features:**
- Loads `.spec/.session.json` and `.spec/.state.json`
- Calculates time since last session
- Generates continuation suggestions
- Displays welcome message with context

**Output:**
```json
{
  "type": "session-restored",
  "message": "🔄 Session Restored\n\nLast session: 2 hours ago\n...",
  "details": {
    "hasSession": true,
    "feature": "user-authentication",
    "suggestions": ["Continue working on: user-authentication"]
  }
}
```

#### `save-session.ts`
**Event:** Stop
**Purpose:** Save session state for next startup

**Features:**
- Captures current feature context
- Tracks recently modified files (last hour)
- Counts pending tasks from tasks.md files
- Records environment details
- Writes `.spec/.session.json`

### Validation Hooks

#### `validate-prerequisites.ts`
**Event:** PreToolUse (Skill matcher)
**Purpose:** Validate required tools exist before skill execution

**Features:**
- Checks for Git installation
- Validates node_modules exists
- Warns about missing dependencies
- Non-blocking (logs warnings only)

**Validates:**
- `spec:implement` → Git required
- Build/test commands → node_modules required

#### `format-code.ts`
**Event:** PreToolUse (Write|Edit matcher)
**Purpose:** Auto-format code before write operations

**Features:**
- Detects formatter based on file extension
- Runs Prettier for JS/TS/JSON/CSS/MD
- Runs Black for Python
- Runs gofmt for Go
- Runs rustfmt for Rust
- Silent failure (logs warning on error)

### Tracking Hooks

#### `track-metrics.ts`
**Event:** PostToolUse (Write|Edit matcher)
**Purpose:** Track AI vs human code contributions

**Features:**
- Detects AI-generated code (via `spec:` commands, `spec-` agents)
- Tracks file modifications (AI/human created/modified)
- Calculates statistics (percentages, velocity, top skills)
- Saves metrics to `.spec/.metrics.json`
- Generates dashboard in `.spec/metrics-dashboard.md`
- Historical snapshots in `.spec/metrics-history/`

**Metrics Tracked:**
- AI generated lines/files
- Human written lines/files
- File type distribution
- Skill usage patterns
- Hourly activity
- Generation velocity (lines/hour)

**Key Fix:** All Flow→Spec migration issues resolved:
- Uses `spec:` commands (not `flow:`)
- Uses `spec-` agents (not `flow-`)
- Uses config-driven paths (not `.flow/`)

#### `update-workflow-status.ts`
**Event:** PostToolUse (Skill matcher)
**Purpose:** Update workflow phase and progress

**Features:**
- Extracts workflow phase from command
- Updates `.spec/state/current-session.md`
- Appends to `.spec/memory/WORKFLOW-PROGRESS.md`
- Calculates progress percentage by phase
- Tracks tasks completed/total

**Phases Tracked:**
- initialize (10%), generate (25%), clarify (35%), plan (50%)
- tasks (60%), implement (80%), validate (90%), complete (100%)

### Aggregation Hooks

#### `aggregate-results.ts`
**Event:** SubagentStop
**Purpose:** Aggregate results from multiple subagent executions

**Features:**
- Records each subagent's result (success/failure)
- Calculates aggregate statistics
- Generates summary report
- Saves to `.spec/memory/SUBAGENT-SUMMARY.md`
- Tracks success rate, total duration

## Development

### Prerequisites

- Node.js >= 18.0.0
- npm >= 8.0.0

### Building from Source

```bash
# Install dependencies
npm install

# Compile TypeScript
npm run build

# Watch mode (auto-rebuild on changes)
npm run build:watch

# Clean build artifacts
npm run clean

# Full rebuild
npm run rebuild
```

### Project Commands

```bash
npm run build         # Compile TypeScript → JavaScript
npm run build:watch   # Watch mode with auto-rebuild
npm run clean         # Remove dist/ directory
npm run rebuild       # Clean + build
npm run lint          # Run ESLint
npm run lint:fix      # Auto-fix ESLint issues
npm run format        # Format code with Prettier
npm run type-check    # Type-check without emitting
```

### Creating a New Hook

1. **Create TypeScript file** in appropriate category:
   ```typescript
   // src/hooks/category/my-hook.ts
   import { BaseHook } from '../../core/base-hook';
   import { HookContext } from '../../types';

   export class MyHook extends BaseHook {
     constructor() {
       super('my-hook');
     }

     async execute(context: HookContext): Promise<void> {
       // Hook logic here
       this.logger.info('My hook executed');
     }
   }

   // Main execution
   async function main(): Promise<void> {
     const hook = new MyHook();
     await hook.run();
   }

   main();
   ```

2. **Export from index.ts**:
   ```typescript
   // src/hooks/category/index.ts
   export * from './my-hook';
   ```

3. **Build the project**:
   ```bash
   npm run build
   ```

4. **Register in settings.json**:
   ```json
   {
     "hooks": {
       "EventName": [{
         "hooks": [{
           "type": "command",
           "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/dist/hooks/category/my-hook.js\""
         }]
       }]
     }
   }
   ```

### Using the BaseHook Class

All hooks should extend `BaseHook` for consistency:

```typescript
export class MyHook extends BaseHook {
  constructor() {
    super('hook-name'); // Sets hook name for logging
  }

  async execute(context: HookContext): Promise<void> {
    // Access config (auto-loaded)
    console.log(this.config.version);

    // Access CWD
    console.log(this.cwd);

    // Use scoped logger
    this.logger.info('Message');
    this.logger.warn('Warning', { details: {...} });
    this.logger.error('Error', error);
    this.logger.success('Success!');

    // Validate context
    this.validateContext(context, ['required_field']);

    // Use path resolver (supports variable interpolation)
    const statePath = resolveStatePath(this.config, this.cwd);
    // Automatically handles:
    //   "state" → .spec/state
    //   "{spec_root}/state" → .spec/state
    //   "{cwd}/.tmp/state" → /project/.tmp/state

    const featurePath = resolveFeaturePath(this.config, 1, 'user-auth', this.cwd);
    // → .spec/features/001-user-auth (using naming pattern)

    // Use utilities
    const data = readJSON('file.json');
    writeJSON('output.json', data);
  }
}
```

### Path Resolution with Variables

The path resolver supports three modes for maximum flexibility:

**1. Simple Relative Paths** (recommended default):
```typescript
// Config: state: "state"
resolveStatePath(config, cwd);
// → /project/.spec/state
```

**2. Variable Interpolation** (for maintainability):
```typescript
// Config: features: "{spec_root}/features"
resolveFeaturesPath(config, cwd);
// → /project/.spec/features

// Config: state: "{cwd}/.tmp/state"
resolveStatePath(config, cwd);
// → /project/.tmp/state
```

**3. Explicit/Absolute Paths** (for special cases):
```typescript
// Config: features: "/absolute/path"
resolveFeaturesPath(config, cwd);
// → /absolute/path
```

**Benefits of Variable Interpolation:**
- Change `spec_root` once, all paths update automatically
- Clear intent in configuration
- Support for complex directory structures
- Backward compatible with simple relative paths

### Available Utilities

#### Core Utilities

```typescript
// Config loading
import { loadConfig, configExists, getConfig } from './core/config-loader';

// Path resolution with variable interpolation
import {
  resolvePath,
  resolveStatePath,
  resolveMemoryPath,
  resolveTemplatesPath,
  resolveFeaturesPath,
  resolveSpecRoot,
  resolveFeaturePath,
  resolveStateFile,
  resolveMemoryFile,
  resolveFeatureFile
} from './core/path-resolver';

// Example usage:
const statePath = resolveStatePath(config, cwd);
// With variable interpolation: "{spec_root}/state" → /project/.spec/state
const memoryPath = resolveMemoryPath(config, cwd);
// Simple relative: "memory" → /project/.spec/memory

// Logging
import { Logger, createScopedLogger } from './core/logger';
Logger.info('Message');
Logger.warn('Warning', { details });
Logger.error('Error', error);

// File operations
import {
  readJSON,
  writeJSON,
  readFile,
  writeFile,
  ensureDirectory,
  fileExists,
  listFiles
} from './utils/file-utils';

// YAML operations
import { loadYAML, parseYAML, toYAML, writeYAML } from './utils/yaml-utils';

// Validation
import {
  validateHookContext,
  validateNonEmptyString,
  validateFilePath
} from './utils/validation';
```

## Configuration

Hooks read configuration from `.claude/.spec-config.yml`:

```yaml
version: "3.3.0"
paths:
  spec_root: ".spec"      # Root directory for all spec files

  # Simple relative paths (relative to spec_root)
  features: "features"    # → .spec/features
  state: "state"          # → .spec/state
  memory: "memory"        # → .spec/memory
  templates: "templates"  # → .spec/templates

  # Advanced: Override with explicit or absolute paths
  # features: "my-features"        # → .spec/my-features
  # features: "../shared-features" # Outside spec_root
  # features: "/absolute/path"     # Absolute path

naming:
  feature_directory: "{id:000}-{slug}"  # e.g., 001-user-auth
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"

project:
  type: "app"             # app | library | monorepo | microservice
  language: "typescript"
  framework: "nextjs"
  build_tool: "turbo"

# ... additional config ...
```

**Path Resolution:**

The hooks system supports three ways to specify paths:

1. **Simple Relative Paths** (recommended for most users):
   ```yaml
   features: "features"    # → .spec/features
   state: "state"          # → .spec/state
   ```
   - Resolved relative to `spec_root`
   - Clean, simple configuration
   - Automatically updates if you move spec_root

2. **Variable Interpolation** (for advanced customization):
   ```yaml
   features: "{spec_root}/features"     # Explicit with variable
   state: "{cwd}/.tmp/state"            # Use project root variable
   memory: "{spec_root}/docs/memory"    # Custom location within spec_root
   ```
   - Supported variables: `{spec_root}`, `{cwd}`, or any key from `config.paths`
   - Ensures paths update automatically when base directories change
   - Useful for complex directory structures

3. **Explicit/Absolute Paths** (for special cases):
   ```yaml
   features: ".spec/my-features"        # Explicit from project root
   state: "../shared-state"             # Outside project
   templates: "/absolute/path"          # Absolute path
   ```
   - Full control over exact location
   - Useful for shared directories or specific requirements

**Examples:**
- `"features"` → `.spec/features` (relative to spec_root)
- `"{spec_root}/features"` → `.spec/features` (variable interpolation)
- `".spec/features"` → `.spec/features` (explicit path from project root)
- `"{cwd}/shared"` → `/project/shared` (project root variable)
- `"/absolute"` → `/absolute` (absolute path)

This gives users full flexibility while keeping defaults clean and maintainable.

## TypeScript Configuration

### Strict Mode Enabled

The project uses strict TypeScript settings for maximum type safety:

```json
{
  "strict": true,
  "noImplicitAny": true,
  "strictNullChecks": true,
  "noUnusedLocals": true,
  "noUnusedParameters": true,
  "noImplicitReturns": true
}
```

### Target & Module

- **Target:** ES2020
- **Module:** CommonJS (for Node.js compatibility)
- **Output:** `dist/` directory with source maps

## Code Quality

### ESLint

Configured with TypeScript support and Prettier integration:

```bash
npm run lint       # Check for issues
npm run lint:fix   # Auto-fix issues
```

### Prettier

Code formatting with consistent style:

```bash
npm run format     # Format all files
```

### Type Checking

```bash
npm run type-check  # Check types without building
```

## Troubleshooting

### Hooks Not Running

1. **Check settings.json** - Ensure paths point to `dist/hooks/...`
2. **Rebuild** - Run `npm run build` to recompile
3. **Check Node version** - Requires Node.js >= 18.0.0
4. **View logs** - Hooks output JSON to stdout/stderr

### Build Errors

```bash
# Clean and rebuild
npm run rebuild

# Check for missing dependencies
npm install

# Verify TypeScript version
npx tsc --version
```

### Hook Execution Errors

Hooks exit with code 0 (success) even on errors to avoid blocking Claude Code. Check hook output for error messages:

```json
{
  "type": "error",
  "message": "Error description",
  "details": { "stack": "..." }
}
```

## Best Practices

1. **Extend BaseHook** - Use the base class for all hooks
2. **Type Everything** - Leverage TypeScript's type system
3. **Config-Driven Paths** - Always use path-resolver functions, never hardcode paths
   - Use `resolveStatePath()`, `resolveFeaturesPath()`, etc.
   - Supports simple relative, variable interpolation, and absolute paths
   - Example: `const statePath = resolveStatePath(this.config, this.cwd);`
4. **Structured Logging** - Use Logger class for consistent output
5. **Graceful Failure** - Handle errors, don't block Claude Code
6. **Test Locally** - Build and test before committing
7. **Document Changes** - Update README when adding hooks
8. **Variable Interpolation** - Recommend using `{spec_root}` for paths that should move with spec_root

## Migration Notes

This hooks system was migrated from JavaScript to TypeScript in v3.3.0:

### Key Changes

- **Flow → Spec** - All Flow plugin references replaced with Spec
- **Hardcoded paths** → Config-driven paths via path-resolver with variable interpolation
- **Loose typing** → Strict TypeScript with full type safety
- **No structure** → Professional architecture with BaseHook pattern
- **Manual setup** → Auto-detection and zero-config experience
- **Variable Support** - Added `{spec_root}`, `{cwd}`, and custom variable interpolation

### Backward Compatibility

Old `.js` hooks have been removed. All hooks now use TypeScript compiled versions in `dist/`.

## Contributing

When contributing new hooks:

1. Follow the existing architecture (extend BaseHook)
2. Use TypeScript with strict mode
3. Add proper types for all data structures
4. Include JSDoc comments for public APIs
5. Test compilation (`npm run build`)
6. Ensure ESLint passes (`npm run lint`)
7. Format code (`npm run format`)
8. Update this README with hook documentation

## Resources

- **Spec Plugin Docs** - `plugins/spec/README.md`
- **Claude Code Hooks** - https://docs.claude.com/claude-code/hooks
- **TypeScript Handbook** - https://www.typescriptlang.org/docs/
- **Migration Plan** - `TYPESCRIPT-MIGRATION-PLAN.md`
- **Implementation Status** - `IMPLEMENTATION-STATUS.md`

## License

MIT - See LICENSE file in plugin root directory

---

**Version:** 3.3.0
**Last Updated:** 2025-01-02
**Maintainer:** Spec Plugin Team
