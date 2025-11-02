/**
 * Path resolution utilities for config-driven paths
 */

import * as path from 'path';
import { SpecConfig } from '../types';

/**
 * Interpolate variables in a path string
 * Supports: {spec_root}, {cwd}, and any path key from config.paths
 *
 * @param pathValue - Path string that may contain variables
 * @param config - Spec configuration
 * @param cwd - Current working directory
 * @returns Path with variables interpolated
 */
function interpolateVariables(
  pathValue: string,
  config: SpecConfig,
  cwd: string
): string {
  let result = pathValue;

  // Replace {cwd} with current working directory
  result = result.replace(/\{cwd\}/g, cwd);

  // Replace {spec_root} with spec_root value
  result = result.replace(/\{spec_root\}/g, config.paths.spec_root);

  // Replace any other {path_key} variables from config.paths
  for (const [key, value] of Object.entries(config.paths)) {
    const pattern = new RegExp(`\\{${key}\\}`, 'g');
    result = result.replace(pattern, value);
  }

  return result;
}

/**
 * Resolve a path relative to spec_root if it's not absolute
 *
 * @param config - Spec configuration
 * @param pathKey - Key in config.paths (e.g., 'state', 'memory')
 * @param cwd - Current working directory (defaults to process.cwd())
 * @returns Absolute path
 */
export function resolvePath(
  config: SpecConfig,
  pathKey: keyof SpecConfig['paths'],
  cwd: string = process.cwd()
): string {
  let pathValue = config.paths[pathKey];

  // Interpolate variables (e.g., {spec_root}, {cwd})
  pathValue = interpolateVariables(pathValue, config, cwd);

  // If path is absolute (after interpolation), return as-is
  if (path.isAbsolute(pathValue)) {
    return pathValue;
  }

  // If path starts with spec_root name, resolve from cwd
  if (pathValue.startsWith(config.paths.spec_root)) {
    return path.join(cwd, pathValue);
  }

  // Otherwise, resolve relative to spec_root
  return path.join(cwd, config.paths.spec_root, pathValue);
}

/**
 * Resolve state directory path
 */
export function resolveStatePath(
  config: SpecConfig,
  cwd: string = process.cwd()
): string {
  return resolvePath(config, 'state', cwd);
}

/**
 * Resolve memory directory path
 */
export function resolveMemoryPath(
  config: SpecConfig,
  cwd: string = process.cwd()
): string {
  return resolvePath(config, 'memory', cwd);
}

/**
 * Resolve features directory path
 */
export function resolveFeaturesPath(
  config: SpecConfig,
  cwd: string = process.cwd()
): string {
  return resolvePath(config, 'features', cwd);
}

/**
 * Resolve spec_root directory path
 */
export function resolveSpecRoot(
  config: SpecConfig,
  cwd: string = process.cwd()
): string {
  return path.join(cwd, config.paths.spec_root);
}

/**
 * Resolve a specific file within state directory
 *
 * @param config - Spec configuration
 * @param filename - Filename within state directory
 * @param cwd - Current working directory
 * @returns Absolute path to the file
 */
export function resolveStateFile(
  config: SpecConfig,
  filename: string,
  cwd: string = process.cwd()
): string {
  return path.join(resolveStatePath(config, cwd), filename);
}

/**
 * Resolve a specific file within memory directory
 */
export function resolveMemoryFile(
  config: SpecConfig,
  filename: string,
  cwd: string = process.cwd()
): string {
  return path.join(resolveMemoryPath(config, cwd), filename);
}

/**
 * Resolve feature directory path for a given feature ID and slug
 *
 * @param config - Spec configuration
 * @param featureId - Numeric feature ID
 * @param slug - Feature slug (kebab-case name)
 * @param cwd - Current working directory
 * @returns Absolute path to feature directory
 */
export function resolveFeaturePath(
  config: SpecConfig,
  featureId: number,
  slug: string,
  cwd: string = process.cwd()
): string {
  const featuresDir = resolveFeaturesPath(config, cwd);

  // Generate directory name using naming pattern
  let dirName = config.naming.feature_directory;

  // Replace variables in pattern
  dirName = dirName.replace('{id:000}', featureId.toString().padStart(3, '0'));
  dirName = dirName.replace('{id}', featureId.toString());
  dirName = dirName.replace('{slug}', slug);

  return path.join(featuresDir, dirName);
}

/**
 * Resolve a specific file within a feature directory
 *
 * @param config - Spec configuration
 * @param featureId - Numeric feature ID
 * @param slug - Feature slug
 * @param fileType - Type of file ('spec', 'plan', 'tasks')
 * @param cwd - Current working directory
 * @returns Absolute path to the file
 */
export function resolveFeatureFile(
  config: SpecConfig,
  featureId: number,
  slug: string,
  fileType: 'spec' | 'plan' | 'tasks',
  cwd: string = process.cwd()
): string {
  const featureDir = resolveFeaturePath(config, featureId, slug, cwd);
  const filename = config.naming.files[fileType];
  return path.join(featureDir, filename);
}
