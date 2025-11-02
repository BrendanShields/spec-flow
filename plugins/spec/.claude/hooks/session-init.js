#!/usr/bin/env node

/**
 * @fileoverview Session Initialization Hook
 *
 * Runs on SessionStart to:
 * 1. Ensure config exists (create if missing with auto-detection)
 * 2. Validate workflow setup matches config
 * 3. Load last session state
 * 4. Ask user what they want to do next via AskUserQuestion
 *
 * Zero-config experience with smart defaults.
 *
 * @requires fs
 * @requires path
 * @requires child_process
 * @requires js-yaml (auto-installed)
 * @author Spec Plugin Team
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const HOOK_DIR = __dirname;
const CLAUDE_DIR = path.join(HOOK_DIR, '..');
const CONFIG_PATH = path.join(CLAUDE_DIR, '.spec-config.yml');

// ====================
// Auto-install dependencies
// ====================
const NODE_MODULES = path.join(HOOK_DIR, 'node_modules');
if (!fs.existsSync(NODE_MODULES)) {
  try {
    // Silent install of js-yaml
    execSync('npm install --silent --no-save js-yaml@^4.1.0', {
      cwd: HOOK_DIR,
      stdio: 'pipe'
    });
  } catch (error) {
    // Fallback: continue without YAML parsing (use JSON instead)
    console.error(JSON.stringify({
      type: 'warning',
      message: 'Failed to install js-yaml dependency. Config features limited.'
    }));
  }
}

// Try to load js-yaml, fallback to JSON if not available
let yaml;
try {
  yaml = require('js-yaml');
} catch {
  yaml = null;
}

// ====================
// Auto-detection utilities
// ====================

/**
 * Load and parse JSON file safely
 */
function loadJSON(filePath) {
  try {
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

/**
 * Check if file exists (case-insensitive for config files)
 */
function findConfigFile(cwd, baseName, extensions = ['.js', '.ts', '.json', '.mjs']) {
  for (const ext of extensions) {
    const filePath = path.join(cwd, baseName + ext);
    if (fs.existsSync(filePath)) return true;
  }
  return false;
}

/**
 * Detect project type, language, framework, and build tool
 */
function detectProject(cwd) {
  const pkg = loadJSON(path.join(cwd, 'package.json'));

  // Detect project type
  let type = 'app';
  if (fs.existsSync(path.join(cwd, 'pnpm-workspace.yaml')) ||
      fs.existsSync(path.join(cwd, 'lerna.json')) ||
      fs.existsSync(path.join(cwd, 'turbo.json'))) {
    type = 'monorepo';
  } else if (pkg?.publishConfig || pkg?.name?.startsWith('@')) {
    type = 'library';
  }

  // Detect language
  let language = 'javascript';
  if (fs.existsSync(path.join(cwd, 'tsconfig.json'))) {
    language = 'typescript';
  } else if (fs.existsSync(path.join(cwd, 'pyproject.toml')) ||
             fs.existsSync(path.join(cwd, 'setup.py'))) {
    language = 'python';
  } else if (fs.existsSync(path.join(cwd, 'go.mod'))) {
    language = 'go';
  } else if (fs.existsSync(path.join(cwd, 'Cargo.toml'))) {
    language = 'rust';
  }

  // Detect framework
  let framework = null;
  if (findConfigFile(cwd, 'next.config')) {
    framework = 'nextjs';
  } else if (findConfigFile(cwd, 'nuxt.config')) {
    framework = 'nuxt';
  } else if (pkg?.dependencies?.['react'] || pkg?.devDependencies?.['react']) {
    framework = 'react';
  } else if (pkg?.dependencies?.['vue'] || pkg?.devDependencies?.['vue']) {
    framework = 'vue';
  } else if (pkg?.dependencies?.['@angular/core']) {
    framework = 'angular';
  } else if (pkg?.dependencies?.['svelte']) {
    framework = 'svelte';
  }

  // Detect build tool
  let build_tool = null;
  if (fs.existsSync(path.join(cwd, 'turbo.json'))) {
    build_tool = 'turbo';
  } else if (findConfigFile(cwd, 'vite.config')) {
    build_tool = 'vite';
  } else if (findConfigFile(cwd, 'webpack.config')) {
    build_tool = 'webpack';
  } else if (findConfigFile(cwd, 'rollup.config')) {
    build_tool = 'rollup';
  } else if (pkg?.scripts?.build?.includes('esbuild')) {
    build_tool = 'esbuild';
  }

  return { type, language, framework, build_tool };
}

// ====================
// Config management
// ====================

/**
 * Create default configuration with auto-detected values
 */
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
        max_parallel: detected.type === 'monorepo' ? 5 : 3,
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

/**
 * Load configuration from YAML file
 */
function loadConfig() {
  try {
    if (!fs.existsSync(CONFIG_PATH)) return null;

    const content = fs.readFileSync(CONFIG_PATH, 'utf8');

    if (yaml) {
      return yaml.load(content);
    } else {
      // Fallback: try to parse as JSON (won't work for YAML, but safe)
      return JSON.parse(content);
    }
  } catch (error) {
    return null;
  }
}

/**
 * Write configuration to YAML file
 */
function writeConfig(config) {
  let content;

  if (yaml) {
    // Use js-yaml to generate YAML
    const yamlContent = yaml.dump(config, {
      indent: 2,
      lineWidth: 100,
      noRefs: true
    });

    // Add helpful header comment
    content = `# Spec Workflow Configuration v3.1.0
#
# This file was auto-generated with smart defaults based on your project.
# Feel free to customize paths, naming conventions, and workflow preferences.
#
# Documentation: See plugins/spec/docs/CONFIGURATION.md
#

${yamlContent}`;
  } else {
    // Fallback: write as JSON with comments
    content = `// Spec Workflow Configuration v3.1.0
// Auto-generated with smart defaults
${JSON.stringify(config, null, 2)}`;
  }

  fs.writeFileSync(CONFIG_PATH, content, 'utf8');
}

// ====================
// Session state management
// ====================

/**
 * Load last session state from .spec-state/current-session.md
 */
function loadSessionState(config, cwd) {
  const statePath = path.join(cwd, config.paths.state, 'current-session.md');

  if (!fs.existsSync(statePath)) {
    return null;
  }

  try {
    const content = fs.readFileSync(statePath, 'utf8');

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
          state.tastsTotal = parseInt(match[2]);
        }
      }
    });

    return state.feature ? state : null;
  } catch {
    return null;
  }
}

// ====================
// Directory validation
// ====================

/**
 * Ensure all configured directories exist
 */
function validateDirectories(config, cwd) {
  const dirs = [
    config.paths.spec_root,
    config.paths.features,
    config.paths.state,
    config.paths.memory,
    config.paths.templates
  ];

  const created = [];

  for (const dir of dirs) {
    const fullPath = path.join(cwd, dir);
    if (!fs.existsSync(fullPath)) {
      try {
        fs.mkdirSync(fullPath, { recursive: true });
        created.push(dir);
      } catch (error) {
        // Silent fail - just note it
      }
    }
  }

  return created;
}

// ====================
// AskUserQuestion builder
// ====================

/**
 * Build AskUserQuestion payload based on session state
 */
function buildUserQuestion(config, sessionState) {
  const questions = [];

  if (sessionState && sessionState.feature) {
    // Has active session - offer to continue
    const tasksRemaining = sessionState.tasksTotal - sessionState.tasksComplete;
    const progressText = `${sessionState.tasksComplete}/${sessionState.tasksTotal} tasks complete`;

    questions.push({
      question: "What would you like to work on?",
      header: "Next Action",
      multiSelect: false,
      options: [
        {
          label: "Continue from last session",
          description: `Resume ${sessionState.feature} (${progressText}, ${tasksRemaining} remaining)`
        },
        {
          label: `Create new ${config.naming.feature_singular}`,
          description: `Start a fresh ${config.naming.feature_singular} specification`
        }
      ]
    });
  } else {
    // No active session - check if workflow is initialized
    const hasWorkflow = fs.existsSync(path.join(process.cwd(), config.paths.spec_root));

    if (hasWorkflow) {
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
            label: "Review workflow status",
            description: `Check existing ${config.naming.feature_plural} and workflow state`
          }
        ]
      });
    } else {
      questions.push({
        question: "What would you like to work on?",
        header: "Get Started",
        multiSelect: false,
        options: [
          {
            label: "Initialize Spec workflow",
            description: "Set up product requirements, architecture blueprint, and templates"
          },
          {
            label: `Create new ${config.naming.feature_singular}`,
            description: `Jump straight to creating a ${config.naming.feature_singular} specification`
          }
        ]
      });
    }
  }

  return { questions };
}

// ====================
// Main execution
// ====================

async function main() {
  try {
    const cwd = process.cwd();
    let config;
    let isFirstRun = false;

    // 1. Check if config exists
    if (!fs.existsSync(CONFIG_PATH)) {
      // Create default config with auto-detection
      config = createDefaultConfig(cwd);
      writeConfig(config);
      isFirstRun = true;

      console.log(JSON.stringify({
        type: 'config-created',
        message: '✨ Created .claude/.spec-config.yml with auto-detected settings',
        details: {
          project_type: config.project.type,
          language: config.project.language,
          framework: config.project.framework || 'none',
          build_tool: config.project.build_tool || 'none'
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
          suggestion: 'Check YAML syntax for errors or delete the file to regenerate'
        }));
        process.exit(0);
      }
    }

    // 2. Validate directory structure
    const createdDirs = validateDirectories(config, cwd);
    if (createdDirs.length > 0 && !isFirstRun) {
      console.log(JSON.stringify({
        type: 'directories-created',
        message: `Created missing directories: ${createdDirs.join(', ')}`
      }, null, 2));
    }

    // 3. Load session state
    const sessionState = loadSessionState(config, cwd);

    // 4. Build and output user question
    // Note: We don't actually call AskUserQuestion here - we just output
    // the information. Claude Code will handle the actual question.
    const questionPayload = buildUserQuestion(config, sessionState);

    // Output summary of session state for Claude
    const summary = {
      type: 'session-initialized',
      config: {
        version: config.version,
        paths: config.paths,
        naming: config.naming,
        project: config.project
      },
      session: sessionState,
      firstRun: isFirstRun
    };

    console.log(JSON.stringify(summary, null, 2));

    // Exit successfully
    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: `Session initialization failed: ${error.message}`,
      stack: error.stack
    }));
    process.exit(0); // Don't block session
  }
}

// Run main function
main();
