# Configuration System Implementation - Final Plan

**Date**: November 2, 2025
**Status**: ✅ FINAL - Single-file approach
**Principle**: Keep it radically simple

## Decision: Single Config File + One Hook

### ✅ What We're Building

**Single YAML config file** + **One SessionStart hook**:
- `.claude/.spec-config.yml` - All configuration in one editable file
- `session-init.js` - One hook that does everything
- Zero learning curve - just edit YAML
- No CLI, no build system, no complexity
- Auto-installs js-yaml if needed
- Smart defaults with auto-detection

### ❌ What We're NOT Building

- ~~Complex TypeScript infrastructure~~
- ~~Multi-level config hierarchy (7 levels)~~
- ~~CLI with init/show/set/get commands~~
- ~~Separate .spec-config/ directory~~
- ~~Build process (tsc, ts-node, watch mode)~~
- ~~Multiple hook files~~

### Why This is Better

| Aspect | Simple Approach | Complex Approach |
|--------|----------------|------------------|
| Files to maintain | 2 (YAML + hook) | 20+ (TS, config, CLI) |
| User learning curve | Edit YAML | Learn CLI commands |
| Dependencies | js-yaml | TypeScript, Zod, ts-node, etc. |
| Build process | None | npm install, tsc build |
| Setup time | Instant | Minutes |
| Debugging | One file | Multi-level precedence |

---

## Implementation Details

### File 1: Configuration File

**Path**: `plugins/spec/.claude/.spec-config.yml`

```yaml
# Spec Workflow Configuration v3.1.0
# Edit this file to customize paths, naming, and workflow behavior
version: "3.1.0"

# Directory paths (relative to project root)
paths:
  spec_root: ".spec"              # Product requirements, blueprints
  features: "features"            # Feature specifications
  state: ".spec-state"            # Session state (gitignored)
  memory: ".spec-memory"          # Persistent memory (committed)
  templates: ".spec/templates"    # Custom templates

# Naming conventions
naming:
  # Feature directory pattern - variables: {id:000}, {id}, {slug}
  feature_directory: "{id:000}-{slug}"  # e.g., "001-user-auth"

  # Terminology (customize for your domain)
  feature_singular: "feature"     # "Create a new feature"
  feature_plural: "features"      # "List all features"

  # Artifact filenames
  files:
    spec: "spec.md"
    plan: "plan.md"
    tasks: "tasks.md"

# Auto-detected project info (can override)
project:
  type: "app"                     # app | library | monorepo | microservice
  language: "typescript"
  framework: "nextjs"
  build_tool: "turbo"

# Agent behavior
agents:
  implementer:
    strategy: "parallel"          # parallel | sequential | adaptive
    max_parallel: 3
    timeout: 1800                 # seconds
    retry_attempts: 3

  researcher:
    confidence_threshold: 0.75
    cache_ttl: 86400             # seconds

  analyzer:
    validation_depth: "standard"  # quick | standard | deep
    auto_fix: false

# Optional integrations
integrations:
  jira:
    enabled: false
    project_key: ""
    server_url: ""

  confluence:
    enabled: false
    space_key: ""
    root_page_id: ""

# Workflow preferences
workflow:
  auto_checkpoint: true
  validate_on_save: true
  progressive_disclosure: true
```

### File 2: Session Init Hook

**Path**: `plugins/spec/.claude/hooks/session-init.js`

**Dependencies**: Needs js-yaml (auto-installed)

**package.json** (in `.claude/hooks/` for dependencies):
```json
{
  "name": "@spec/hooks",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "dependencies": {
    "js-yaml": "^4.1.0"
  }
}
```

**Hook implementation** (`session-init.js`):

```javascript
#!/usr/bin/env node

/**
 * Session Initialization Hook
 *
 * Runs on SessionStart to:
 * 1. Ensure config exists (create if missing with auto-detection)
 * 2. Validate workflow setup matches config
 * 3. Load last session state
 * 4. Ask user what they want to do next
 *
 * Zero-config experience with smart defaults.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, statSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import yaml from 'js-yaml';

const __dirname = dirname(fileURLToPath(import.meta.url));
const HOOK_DIR = __dirname;
const CLAUDE_DIR = join(HOOK_DIR, '..');
const CONFIG_PATH = join(CLAUDE_DIR, '.spec-config.yml');

// ====================
// Auto-install deps
// ====================
const NODE_MODULES = join(HOOK_DIR, 'node_modules');
if (!existsSync(NODE_MODULES)) {
  try {
    execSync('npm install --silent', {
      cwd: HOOK_DIR,
      stdio: 'pipe'
    });
  } catch (error) {
    console.error('Failed to install hook dependencies');
    process.exit(0);
  }
}

// ====================
// Auto-detection
// ====================
function detectProject(cwd) {
  const pkg = loadJSON(join(cwd, 'package.json'));

  // Detect project type
  let type = 'app';
  if (existsSync(join(cwd, 'pnpm-workspace.yaml')) ||
      existsSync(join(cwd, 'lerna.json')) ||
      existsSync(join(cwd, 'turbo.json'))) {
    type = 'monorepo';
  } else if (pkg?.publishConfig) {
    type = 'library';
  }

  // Detect language
  let language = 'javascript';
  if (existsSync(join(cwd, 'tsconfig.json'))) {
    language = 'typescript';
  }

  // Detect framework
  let framework = null;
  if (existsSync(join(cwd, 'next.config.js')) || existsSync(join(cwd, 'next.config.ts'))) {
    framework = 'nextjs';
  } else if (pkg?.dependencies?.['react']) {
    framework = 'react';
  } else if (pkg?.dependencies?.['vue']) {
    framework = 'vue';
  }

  // Detect build tool
  let build_tool = null;
  if (existsSync(join(cwd, 'turbo.json'))) {
    build_tool = 'turbo';
  } else if (existsSync(join(cwd, 'vite.config.js')) || existsSync(join(cwd, 'vite.config.ts'))) {
    build_tool = 'vite';
  } else if (existsSync(join(cwd, 'webpack.config.js'))) {
    build_tool = 'webpack';
  }

  return { type, language, framework, build_tool };
}

function loadJSON(path) {
  try {
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch {
    return null;
  }
}

// ====================
// Config Management
// ====================
function createDefaultConfig(cwd) {
  const detected = detectProject(cwd);

  const config = {
    version: '3.1.0',
    paths: {
      spec_root: '.spec',
      features: 'features',
      state: '.spec-state',
      memory: '.spec-memory',
      templates: '.spec/templates'
    },
    naming: {
      feature_directory: '{id:000}-{slug}',
      feature_singular: 'feature',
      feature_plural: 'features',
      files: {
        spec: 'spec.md',
        plan: 'plan.md',
        tasks: 'tasks.md'
      }
    },
    project: detected,
    agents: {
      implementer: {
        strategy: 'parallel',
        max_parallel: 3,
        timeout: 1800,
        retry_attempts: 3
      },
      researcher: {
        confidence_threshold: 0.75,
        cache_ttl: 86400
      },
      analyzer: {
        validation_depth: 'standard',
        auto_fix: false
      }
    },
    integrations: {
      jira: { enabled: false, project_key: '', server_url: '' },
      confluence: { enabled: false, space_key: '', root_page_id: '' }
    },
    workflow: {
      auto_checkpoint: true,
      validate_on_save: true,
      progressive_disclosure: true
    }
  };

  return config;
}

function loadConfig() {
  try {
    const content = readFileSync(CONFIG_PATH, 'utf8');
    return yaml.load(content);
  } catch {
    return null;
  }
}

// ====================
// Session State
// ====================
function loadSessionState(config, cwd) {
  const statePath = join(cwd, config.paths.state, 'current-session.md');

  if (!existsSync(statePath)) {
    return null;
  }

  try {
    const content = readFileSync(statePath, 'utf8');

    // Parse session markdown
    const state = {
      feature: null,
      phase: null,
      progress: 0,
      tasksComplete: 0,
      tasksTotal: 0
    };

    content.split('\n').forEach(line => {
      if (line.includes('Current Feature:')) {
        state.feature = line.split(':')[1]?.trim();
      } else if (line.includes('Current Phase:')) {
        state.phase = line.split(':')[1]?.trim();
      } else if (line.includes('Progress:')) {
        const match = line.match(/(\d+)%/);
        state.progress = match ? parseInt(match[1]) : 0;
      } else if (line.includes('Tasks:')) {
        const match = line.match(/(\d+)\/(\d+)/);
        if (match) {
          state.tasksComplete = parseInt(match[1]);
          state.tasksTotal = parseInt(match[2]);
        }
      }
    });

    return state.feature ? state : null;
  } catch {
    return null;
  }
}

// ====================
// Directory Validation
// ====================
function validateDirectories(config, cwd) {
  const dirs = [
    config.paths.spec_root,
    config.paths.features,
    config.paths.state,
    config.paths.memory,
    config.paths.templates
  ];

  const missing = [];

  for (const dir of dirs) {
    const fullPath = join(cwd, dir);
    if (!existsSync(fullPath)) {
      missing.push(dir);
      // Create it
      mkdirSync(fullPath, { recursive: true });
    }
  }

  return missing;
}

// ====================
// AskUserQuestion Payload
// ====================
function buildUserQuestion(config, sessionState) {
  const questions = [];

  if (sessionState) {
    // Has active session - offer to continue
    const tasksRemaining = sessionState.tasksTotal - sessionState.tasksComplete;

    questions.push({
      question: "What would you like to work on?",
      header: "Next Action",
      multiSelect: false,
      options: [
        {
          label: "Continue from last session",
          description: `Resume ${sessionState.feature} (${sessionState.tasksComplete}/${sessionState.tasksTotal} tasks complete, ${tasksRemaining} remaining)`
        },
        {
          label: `Create new ${config.naming.feature_singular}`,
          description: `Start a fresh ${config.naming.feature_singular} specification`
        }
      ]
    });
  } else {
    // No active session - simpler question
    questions.push({
      question: "What would you like to work on?",
      header: "Get Started",
      multiSelect: false,
      options: [
        {
          label: `Create new ${config.naming.feature_singular}`,
          description: `Define a new ${config.naming.feature_singular} specification and plan`
        },
        {
          label: "Set up workflow",
          description: "Initialize Spec workflow (product requirements, architecture blueprint)"
        }
      ]
    });
  }

  return { questions };
}

// ====================
// Main
// ====================
async function main() {
  const cwd = process.cwd();
  let config;
  let isFirstRun = false;

  // 1. Check if config exists
  if (!existsSync(CONFIG_PATH)) {
    // Create default config with auto-detection
    config = createDefaultConfig(cwd);
    const yamlContent = yaml.dump(config, {
      indent: 2,
      lineWidth: 100,
      noRefs: true
    });

    // Add helpful header comment
    const header = `# Spec Workflow Configuration v3.1.0
#
# This file was auto-generated with smart defaults based on your project.
# Feel free to customize paths, naming conventions, and workflow preferences.
#
# Documentation: See plugins/spec/docs/CONFIGURATION.md
#

`;

    writeFileSync(CONFIG_PATH, header + yamlContent, 'utf8');
    isFirstRun = true;

    console.log(JSON.stringify({
      type: 'config-created',
      message: `✨ Created .claude/.spec-config.yml with auto-detected settings`,
      details: {
        project_type: config.project.type,
        language: config.project.language,
        framework: config.project.framework
      },
      suggestion: 'You can customize paths and naming by editing .claude/.spec-config.yml'
    }, null, 2));
  } else {
    // Load existing config
    config = loadConfig();

    if (!config) {
      console.error(JSON.stringify({
        type: 'config-error',
        message: 'Failed to parse .spec-config.yml',
        suggestion: 'Check YAML syntax for errors'
      }));
      process.exit(0);
    }
  }

  // 2. Validate directory structure
  const missingDirs = validateDirectories(config, cwd);
  if (missingDirs.length > 0 && !isFirstRun) {
    console.log(JSON.stringify({
      type: 'directories-created',
      message: `Created missing directories: ${missingDirs.join(', ')}`
    }, null, 2));
  }

  // 3. Load session state
  const sessionState = loadSessionState(config, cwd);

  // 4. Build and output AskUserQuestion
  const questionPayload = buildUserQuestion(config, sessionState);

  console.log(JSON.stringify({
    type: 'ask-user-question',
    ...questionPayload
  }, null, 2));

  process.exit(0);
}

main().catch(error => {
  console.error(JSON.stringify({
    type: 'error',
    message: error.message
  }));
  process.exit(0);
});
```

### File 3: Update hooks.json

**Path**: `plugins/spec/.claude/hooks/hooks.json`

Add the session-init hook at the beginning:

```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "command": "node /Users/dev/dev/tools/marketplace/plugins/spec/.claude/hooks/session-init.js",
      "description": "Initialize session with config and ask user intent"
    },
    {
      "event": "UserPromptSubmit",
      "command": "node /Users/dev/dev/tools/spec-flow/plugins/spec/.claude/hooks/detect-intent.js",
      "description": "Detect user intent and suggest appropriate Spec skills"
    },
    // ... existing hooks
  ]
}
```

---

## Implementation Timeline

### Day 1: Foundation (2-3 hours)
- [x] Create pivot plan
- [ ] Create default `.spec-config.yml` template
- [ ] Create `session-init.js` hook
- [ ] Add `package.json` for js-yaml
- [ ] Update `hooks.json`

### Day 2: Testing & Refinement (2-3 hours)
- [ ] Test first-run experience (no config)
- [ ] Test with existing config
- [ ] Test auto-detection for various project types
- [ ] Test AskUserQuestion integration
- [ ] Refine UX messaging

### Day 3: Documentation (2-3 hours)
- [ ] Create `docs/CONFIGURATION.md` user guide
- [ ] Update `README.md` with configuration section
- [ ] Add examples for common scenarios
- [ ] Create migration guide from hardcoded paths

### Day 4: Integration (2-3 hours)
- [ ] Update workflow skills to read from config
- [ ] Add backward compatibility for CLAUDE.md
- [ ] Test end-to-end workflow
- [ ] Polish and bug fixes

**Total: 4 days** (down from 4 weeks!)

---

## Success Criteria

1. ✅ Single YAML file for all configuration
2. ✅ Zero user setup (auto-creates on first run)
3. ✅ Smart auto-detection (90%+ accuracy)
4. ✅ Clean UX (AskUserQuestion with context)
5. ✅ No build process needed
6. ✅ Easy to customize (edit YAML)
7. ✅ Backward compatible
8. ✅ Well documented

---

## Migration from Complex Plan

### What We're Removing
- Entire `.spec-config/` directory with TypeScript
- CLI commands (init, show, set, get, validate, wizard)
- 7-level config hierarchy
- Zod validation library
- TypeScript build system
- Multiple hook files

### What We're Keeping
- Analysis docs (as specifications)
- Core requirements (paths, naming, agents, etc.)
- Auto-detection logic
- User experience goals

### Why This is Better
- 10x less code to maintain
- 10x faster implementation
- 10x simpler user experience
- Same functionality, zero complexity

---

## Next Steps

1. ✅ Get approval for simplified approach
2. [ ] Create `.spec-config.yml` template
3. [ ] Implement `session-init.js` hook
4. [ ] Test with real projects
5. [ ] Document for users
6. [ ] Ship it!

---

**Status**: ✅ Plan Approved - Ready for 4-Day Implementation
**Complexity**: Simple (2 files vs 20+ files)
**Timeline**: 4 days (vs 4 weeks)
**User Experience**: Superior (zero config, smart defaults)
