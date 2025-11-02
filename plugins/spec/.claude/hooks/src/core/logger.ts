/**
 * Structured logging for Claude Code hooks
 */

import { HookOutput } from '../types';

/**
 * Log levels
 */
export enum LogLevel {
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
  SUCCESS = 'success',
}

/**
 * Logger class for structured JSON output to Claude Code
 */
export class Logger {
  /**
   * Log an informational message
   */
  static info(message: string, details?: Record<string, unknown>): void {
    this.log({
      type: LogLevel.INFO,
      message,
      ...(details && { details }),
    });
  }

  /**
   * Log a warning message
   */
  static warn(message: string, details?: Record<string, unknown>): void {
    this.log({
      type: LogLevel.WARN,
      message,
      ...(details && { details }),
    });
  }

  /**
   * Log an error message
   */
  static error(message: string, error?: Error | unknown, details?: Record<string, unknown>): void {
    const output: HookOutput = {
      type: LogLevel.ERROR,
      message,
      ...(details && { details }),
    };

    if (error instanceof Error) {
      output.stack = error.stack;
      if (!details) {
        output.details = { error: error.message };
      }
    } else if (error) {
      output.details = { ...details, error: String(error) };
    }

    this.log(output);
  }

  /**
   * Log a success message
   */
  static success(message: string, details?: Record<string, unknown>): void {
    this.log({
      type: LogLevel.SUCCESS,
      message,
      ...(details && { details }),
    });
  }

  /**
   * Log a custom structured output
   */
  static log(output: HookOutput): void {
    console.log(JSON.stringify(output, null, 2));
  }

  /**
   * Log with custom type
   */
  static custom(type: string, message: string, details?: Record<string, unknown>): void {
    this.log({
      type,
      message,
      ...(details && { details }),
    });
  }
}

/**
 * Create a scoped logger with a prefix
 */
export function createScopedLogger(scope: string) {
  return {
    info: (message: string, details?: Record<string, unknown>) =>
      Logger.info(`[${scope}] ${message}`, details),
    warn: (message: string, details?: Record<string, unknown>) =>
      Logger.warn(`[${scope}] ${message}`, details),
    error: (message: string, error?: Error | unknown, details?: Record<string, unknown>) =>
      Logger.error(`[${scope}] ${message}`, error, details),
    success: (message: string, details?: Record<string, unknown>) =>
      Logger.success(`[${scope}] ${message}`, details),
    custom: (type: string, message: string, details?: Record<string, unknown>) =>
      Logger.custom(type, `[${scope}] ${message}`, details),
  };
}
