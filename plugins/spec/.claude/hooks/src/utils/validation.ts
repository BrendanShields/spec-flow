/**
 * Validation utility functions
 */

import { HookContext } from '../types';

/**
 * Validate that a hook context has required fields
 *
 * @param context - Hook context to validate
 * @param requiredFields - Array of required field names
 * @throws Error if validation fails
 */
export function validateHookContext(context: HookContext, requiredFields: string[]): void {
  if (!context || typeof context !== 'object') {
    throw new Error('Invalid hook context: must be an object');
  }

  for (const field of requiredFields) {
    if (!(field in context) || context[field] === null || context[field] === undefined) {
      throw new Error(`Required context field missing or null: ${field}`);
    }
  }
}

/**
 * Validate that a value is a non-empty string
 *
 * @param value - Value to validate
 * @param fieldName - Name of the field (for error messages)
 * @throws Error if validation fails
 */
export function validateNonEmptyString(value: unknown, fieldName: string): asserts value is string {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`${fieldName} must be a non-empty string`);
  }
}

/**
 * Validate that a value is a positive number
 *
 * @param value - Value to validate
 * @param fieldName - Name of the field (for error messages)
 * @throws Error if validation fails
 */
export function validatePositiveNumber(value: unknown, fieldName: string): asserts value is number {
  if (typeof value !== 'number' || value <= 0 || isNaN(value)) {
    throw new Error(`${fieldName} must be a positive number`);
  }
}

/**
 * Validate that a value is one of the allowed values
 *
 * @param value - Value to validate
 * @param allowedValues - Array of allowed values
 * @param fieldName - Name of the field (for error messages)
 * @throws Error if validation fails
 */
export function validateEnum<T>(
  value: unknown,
  allowedValues: readonly T[],
  fieldName: string
): asserts value is T {
  if (!allowedValues.includes(value as T)) {
    throw new Error(
      `${fieldName} must be one of: ${allowedValues.join(', ')}. Got: ${String(value)}`
    );
  }
}

/**
 * Validate file path format
 *
 * @param filePath - File path to validate
 * @throws Error if validation fails
 */
export function validateFilePath(filePath: unknown): asserts filePath is string {
  if (typeof filePath !== 'string') {
    throw new Error('File path must be a string');
  }

  if (filePath.trim() === '') {
    throw new Error('File path cannot be empty');
  }

  // Check for suspicious patterns (security)
  if (filePath.includes('..')) {
    throw new Error('File path cannot contain ".." (directory traversal)');
  }
}
