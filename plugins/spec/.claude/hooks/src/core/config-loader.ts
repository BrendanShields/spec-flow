/**
 * Configuration loading and caching
 */

import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import { SpecConfig } from '../types';

let cachedConfig: SpecConfig | null = null;
let cachedConfigPath: string | null = null;

/**
 * Get configuration file path
 */
export function getConfigPath(cwd: string = process.cwd()): string {
  return path.join(cwd, '.claude', '.spec-config.yml');
}

/**
 * Load and parse configuration from .spec-config.yml
 *
 * @param cwd - Current working directory (defaults to process.cwd())
 * @param useCache - Whether to use cached config (default: true)
 * @returns Parsed configuration object
 * @throws Error if config file doesn't exist or is invalid
 */
export function loadConfig(cwd: string = process.cwd(), useCache = true): SpecConfig {
  const configPath = getConfigPath(cwd);

  // Return cached config if available and requested
  if (useCache && cachedConfig && cachedConfigPath === configPath) {
    return cachedConfig;
  }

  if (!fs.existsSync(configPath)) {
    throw new Error(
      `Configuration file not found: ${configPath}. ` +
        'Run initialization first or check your working directory.'
    );
  }

  try {
    const content = fs.readFileSync(configPath, 'utf8');
    const config = yaml.load(content) as SpecConfig;

    // Validate required fields
    validateConfig(config);

    // Cache the config
    cachedConfig = config;
    cachedConfigPath = configPath;

    return config;
  } catch (error) {
    throw new Error(
      `Failed to load configuration from ${configPath}: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Validate configuration structure
 *
 * @param config - Configuration object to validate
 * @throws Error if configuration is invalid
 */
export function validateConfig(config: unknown): asserts config is SpecConfig {
  if (!config || typeof config !== 'object') {
    throw new Error('Configuration must be an object');
  }

  const cfg = config as Partial<SpecConfig>;

  if (!cfg.version) {
    throw new Error('Configuration missing required field: version');
  }

  if (!cfg.paths) {
    throw new Error('Configuration missing required field: paths');
  }

  const requiredPaths = ['spec_root', 'features', 'state', 'memory'];
  for (const pathKey of requiredPaths) {
    if (!(pathKey in cfg.paths)) {
      throw new Error(`Configuration missing required path: ${pathKey}`);
    }
  }

  if (!cfg.naming) {
    throw new Error('Configuration missing required field: naming');
  }

  if (!cfg.project) {
    throw new Error('Configuration missing required field: project');
  }
}

/**
 * Get cached configuration (throws if not loaded yet)
 */
export function getConfig(): SpecConfig {
  if (!cachedConfig) {
    throw new Error(
      'Configuration not loaded yet. Call loadConfig() first.'
    );
  }
  return cachedConfig;
}

/**
 * Clear cached configuration (useful for testing)
 */
export function clearConfigCache(): void {
  cachedConfig = null;
  cachedConfigPath = null;
}

/**
 * Check if configuration file exists
 */
export function configExists(cwd: string = process.cwd()): boolean {
  return fs.existsSync(getConfigPath(cwd));
}
