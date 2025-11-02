/**
 * File system utility functions
 */

import * as fs from 'fs';
import * as path from 'path';

/**
 * Ensure a directory exists, creating it if necessary
 *
 * @param dirPath - Path to directory
 */
export function ensureDirectory(dirPath: string): void {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

/**
 * Read and parse a JSON file
 *
 * @param filePath - Path to JSON file
 * @returns Parsed JSON object
 * @throws Error if file doesn't exist or JSON is invalid
 */
export function readJSON<T = unknown>(filePath: string): T {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }

  const content = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(content) as T;
}

/**
 * Write an object to a JSON file
 *
 * @param filePath - Path to JSON file
 * @param data - Data to write
 * @param pretty - Whether to pretty-print (default: true)
 */
export function writeJSON(filePath: string, data: unknown, pretty = true): void {
  const content = pretty ? JSON.stringify(data, null, 2) : JSON.stringify(data);

  // Ensure parent directory exists
  ensureDirectory(path.dirname(filePath));

  fs.writeFileSync(filePath, content, 'utf8');
}

/**
 * Read a text file
 *
 * @param filePath - Path to file
 * @returns File contents as string
 * @throws Error if file doesn't exist
 */
export function readFile(filePath: string): string {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }
  return fs.readFileSync(filePath, 'utf8');
}

/**
 * Write a text file
 *
 * @param filePath - Path to file
 * @param content - Content to write
 */
export function writeFile(filePath: string, content: string): void {
  // Ensure parent directory exists
  ensureDirectory(path.dirname(filePath));

  fs.writeFileSync(filePath, content, 'utf8');
}

/**
 * Check if a file exists
 *
 * @param filePath - Path to file
 * @returns true if file exists
 */
export function fileExists(filePath: string): boolean {
  return fs.existsSync(filePath);
}

/**
 * Check if a directory exists
 *
 * @param dirPath - Path to directory
 * @returns true if directory exists
 */
export function directoryExists(dirPath: string): boolean {
  return fs.existsSync(dirPath) && fs.statSync(dirPath).isDirectory();
}

/**
 * List files in a directory
 *
 * @param dirPath - Path to directory
 * @param options - Options for listing
 * @returns Array of file paths
 */
export function listFiles(
  dirPath: string,
  options: { recursive?: boolean; pattern?: RegExp } = {}
): string[] {
  if (!directoryExists(dirPath)) {
    return [];
  }

  const files: string[] = [];

  function traverse(currentPath: string): void {
    const entries = fs.readdirSync(currentPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentPath, entry.name);

      if (entry.isDirectory()) {
        if (options.recursive) {
          traverse(fullPath);
        }
      } else {
        if (!options.pattern || options.pattern.test(entry.name)) {
          files.push(fullPath);
        }
      }
    }
  }

  traverse(dirPath);
  return files;
}

/**
 * Delete a file if it exists
 *
 * @param filePath - Path to file
 */
export function deleteFile(filePath: string): void {
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

/**
 * Copy a file
 *
 * @param sourcePath - Source file path
 * @param destPath - Destination file path
 */
export function copyFile(sourcePath: string, destPath: string): void {
  ensureDirectory(path.dirname(destPath));
  fs.copyFileSync(sourcePath, destPath);
}

/**
 * Copy a directory recursively
 *
 * @param sourcePath - Source directory path
 * @param destPath - Destination directory path
 * @param options - Options for copying
 */
export function copyDirectory(
  sourcePath: string,
  destPath: string,
  options: { overwrite?: boolean; filter?: (path: string) => boolean } = {}
): void {
  const { overwrite = false, filter } = options;

  if (!directoryExists(sourcePath)) {
    throw new Error(`Source directory does not exist: ${sourcePath}`);
  }

  ensureDirectory(destPath);

  const entries = fs.readdirSync(sourcePath, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(sourcePath, entry.name);
    const dstPath = path.join(destPath, entry.name);

    // Apply filter if provided
    if (filter && !filter(srcPath)) {
      continue;
    }

    if (entry.isDirectory()) {
      copyDirectory(srcPath, dstPath, options);
    } else if (entry.isFile()) {
      // Only copy if destination doesn't exist or overwrite is true
      if (!fileExists(dstPath) || overwrite) {
        fs.copyFileSync(srcPath, dstPath);
      }
    }
  }
}

/**
 * Count lines in a file or string
 *
 * @param content - File content or path to file
 * @returns Number of lines
 */
export function countLines(content: string): number {
  if (!content) return 0;
  return content.split('\n').length;
}
