/**
 * YAML utility functions
 */

import * as yaml from 'js-yaml';
import { readFile, writeFile } from './file-utils';

/**
 * Load and parse a YAML file
 *
 * @param filePath - Path to YAML file
 * @returns Parsed YAML object
 * @throws Error if file doesn't exist or YAML is invalid
 */
export function loadYAML<T = unknown>(filePath: string): T {
  const content = readFile(filePath);
  return parseYAML<T>(content);
}

/**
 * Parse a YAML string
 *
 * @param content - YAML string
 * @returns Parsed object
 * @throws Error if YAML is invalid
 */
export function parseYAML<T = unknown>(content: string): T {
  try {
    return yaml.load(content) as T;
  } catch (error) {
    throw new Error(
      `Failed to parse YAML: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Convert an object to YAML string
 *
 * @param data - Object to convert
 * @param options - YAML dumping options
 * @returns YAML string
 */
export function toYAML(
  data: unknown,
  options: {
    indent?: number;
    lineWidth?: number;
    noRefs?: boolean;
  } = {}
): string {
  return yaml.dump(data, {
    indent: options.indent ?? 2,
    lineWidth: options.lineWidth ?? 100,
    noRefs: options.noRefs ?? true,
  });
}

/**
 * Write an object to a YAML file
 *
 * @param filePath - Path to YAML file
 * @param data - Data to write
 * @param options - YAML dumping options
 */
export function writeYAML(
  filePath: string,
  data: unknown,
  options?: {
    indent?: number;
    lineWidth?: number;
    noRefs?: boolean;
  }
): void {
  const content = toYAML(data, options);
  writeFile(filePath, content);
}
