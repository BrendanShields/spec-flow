#!/usr/bin/env node

/**
 * Session Initialization Hook
 *
 * Runs on SessionStart to:
 * 1. Ensure config exists (create if missing with auto-detection)
 * 2. Validate workflow setup matches config
 * 3. Load last session state
 * 4. Output session summary for Claude
 *
 * Zero-config experience with smart defaults.
 */

import * as fs from 'fs';
import * as path from 'path';
import { loadConfig, configExists, getConfigPath } from '../../core/config-loader';
import { resolveStatePath, resolveFeaturesPath, resolveMemoryPath, resolveSpecRoot } from '../../core/path-resolver';
import { Logger } from '../../core/logger';
import { ensureDirectory, readJSON, fileExists } from '../../utils/file-utils';
import { toYAML } from '../../utils/yaml-utils';
import { SpecConfig, ProjectInfo, SessionState } from '../../types';

/**
 * Detect project type, language, framework, and build tool
 */
function detectProject(cwd: string): ProjectInfo {
  const pkgPath = path.join(cwd, 'package.json');
  const pkg = fileExists(pkgPath) ? readJSON<any>(pkgPath) : null;

  // Detect project type
  let type: ProjectInfo['type'] = 'app';
  if (
    fileExists(path.join(cwd, 'pnpm-workspace.yaml')) ||
    fileExists(path.join(cwd, 'lerna.json')) ||
    fileExists(path.join(cwd, 'turbo.json'))
  ) {
    type = 'monorepo';
  } else if (pkg?.publishConfig || pkg?.name?.startsWith('@')) {
    type = 'library';
  }

  // Detect language
  let language = 'javascript';
  if (fileExists(path.join(cwd, 'tsconfig.json'))) {
    language = 'typescript';
  } else if (
    fileExists(path.join(cwd, 'pyproject.toml')) ||
    fileExists(path.join(cwd, 'setup.py'))
  ) {
    language = 'python';
  } else if (fileExists(path.join(cwd, 'go.mod'))) {
    language = 'go';
  } else if (fileExists(path.join(cwd, 'Cargo.toml'))) {
    language = 'rust';
  }

  // Detect framework
  let framework: string | null = null;
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
  let build_tool: string | null = null;
  if (fileExists(path.join(cwd, 'turbo.json'))) {
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

/**
 * Check if config file exists with any extension
 */
function findConfigFile(
  cwd: string,
  baseName: string,
  extensions = ['.js', '.ts', '.json', '.mjs']
): boolean {
  return extensions.some((ext) => fileExists(path.join(cwd, baseName + ext)));
}

/**
 * Create default configuration with auto-detected values
 */
function createDefaultConfig(cwd: string): SpecConfig {
  const detected = detectProject(cwd);

  return {
    version: '3.3.0',
    paths: {
      spec_root: '.spec',
      features: 'features',
      state: 'state',
      memory: '{state}/memory',
    },
    naming: {
      feature_directory: '{id:000}-{slug}',
      feature_singular: 'feature',
      feature_plural: 'features',
      files: {
        spec: 'spec.md',
        plan: 'plan.md',
        tasks: 'tasks.md',
      },
    },
    project: detected,
    agents: {
      implementer: {
        strategy: 'parallel',
        max_parallel: detected.type === 'monorepo' ? 5 : 3,
        timeout: 1800,
        retry_attempts: 3,
      },
      researcher: {
        confidence_threshold: 0.75,
        cache_ttl: 86400,
      },
      analyzer: {
        validation_depth: 'standard',
        auto_fix: false,
      },
    },
    integrations: {
      jira: { enabled: false, project_key: '', server_url: '' },
      confluence: { enabled: false, space_key: '', root_page_id: '' },
    },
    workflow: {
      auto_checkpoint: true,
      validate_on_save: true,
      progressive_disclosure: true,
    },
  };
}

/**
 * Write configuration to YAML file
 */
function writeConfigFile(configPath: string, config: SpecConfig): void {
  const yamlContent = toYAML(config, { indent: 2, lineWidth: 100, noRefs: true });

  const content = `# Spec Workflow Configuration v3.3.0
#
# This file was auto-generated with smart defaults based on your project.
# Feel free to customize paths, naming conventions, and workflow preferences.
#
# Documentation: See plugins/spec/.claude/hooks/README.md
#

${yamlContent}`;

  // Ensure the directory exists before writing
  ensureDirectory(path.dirname(configPath));
  fs.writeFileSync(configPath, content, 'utf8');
}

/**
 * Load session state from current-session.md
 */
function loadSessionState(config: SpecConfig, cwd: string): SessionState | null {
  const statePath = path.join(resolveStatePath(config, cwd), 'current-session.md');

  if (!fileExists(statePath)) {
    return null;
  }

  try {
    const content = fs.readFileSync(statePath, 'utf8');

    const state: SessionState = {
      feature: null,
      phase: null,
      progress: 0,
      tasksComplete: 0,
      tasksTotal: 0,
    };

    content.split('\n').forEach((line) => {
      if (line.includes('Current Feature:')) {
        state.feature = line.split(':')[1]?.trim() || null;
      } else if (line.includes('Current Phase:')) {
        const phase = line.split(':')[1]?.trim() || null;
        if (
          phase === 'initialize' ||
          phase === 'generate' ||
          phase === 'clarify' ||
          phase === 'plan' ||
          phase === 'tasks' ||
          phase === 'implement' ||
          phase === 'validate' ||
          phase === 'complete'
        ) {
          state.phase = phase;
        }
      } else if (line.includes('Progress:')) {
        const match = line.match(/(\d+)%/);
        state.progress = match ? parseInt(match[1] ?? '0') : 0;
      } else if (line.includes('Tasks:')) {
        const match = line.match(/(\d+)\/(\d+)/);
        if (match) {
          state.tasksComplete = parseInt(match[1] ?? '0');
          state.tasksTotal = parseInt(match[2] ?? '0');
        }
      }
    });

    return state.feature ? state : null;
  } catch {
    return null;
  }
}

/**
 * Ensure all configured directories exist
 */
function validateDirectories(config: SpecConfig, cwd: string): string[] {
  const dirs = [
    { key: 'spec_root', path: resolveSpecRoot(config, cwd) },
    { key: 'features', path: resolveFeaturesPath(config, cwd) },
    { key: 'state', path: resolveStatePath(config, cwd) },
    { key: 'memory', path: resolveMemoryPath(config, cwd) },
  ];

  const created: string[] = [];

  for (const { key, path: fullPath } of dirs) {
    if (!fileExists(fullPath)) {
      try {
        ensureDirectory(fullPath);
        created.push(key);
        Logger.info(`Created directory: ${key} at ${fullPath}`);
      } catch (error) {
        Logger.error(`Failed to create directory: ${key} at ${fullPath}`, error);
      }
    }
  }

  return created;
}

/**
 * Main execution
 */
async function main(): Promise<void> {
  try {
    const cwd = process.cwd();
    const configPath = getConfigPath(cwd);
    let config: SpecConfig;
    let isFirstRun = false;

    // 1. Check if config exists
    if (!configExists(cwd)) {
      // Create default config with auto-detection
      config = createDefaultConfig(cwd);
      writeConfigFile(configPath, config);
      isFirstRun = true;

      Logger.custom('config-created', '✨ Created .claude/.spec-config.yml with auto-detected settings', {
        project_type: config.project.type,
        language: config.project.language,
        framework: config.project.framework ?? 'none',
        build_tool: config.project.build_tool ?? 'none',
      });
    } else {
      // Load existing config
      try {
        config = loadConfig(cwd, false); // Don't use cache on init
      } catch (error) {
        Logger.error(
          'Failed to parse .spec-config.yml',
          error,
          {
            suggestion: 'Check YAML syntax for errors or delete the file to regenerate',
          }
        );
        process.exit(0);
      }
    }

    // 2. Validate directory structure
    const createdDirs = validateDirectories(config, cwd);
    if (createdDirs.length > 0 && !isFirstRun) {
      Logger.custom(
        'directories-created',
        `Created missing directories: ${createdDirs.join(', ')}`
      );
    }

    // 3. Load session state
    const sessionState = loadSessionState(config, cwd);

    // 4. Output summary for Claude
    Logger.custom('session-initialized', 'Session initialized', {
      config: {
        version: config.version,
        paths: config.paths,
        naming: config.naming,
        project: config.project,
      },
      session: sessionState,
      firstRun: isFirstRun,
    });

    process.exit(0);
  } catch (error) {
    Logger.error(
      'Session initialization failed',
      error
    );
    process.exit(0); // Don't block session
  }
}

// Run main function
main();
