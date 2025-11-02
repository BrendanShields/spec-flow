/**
 * Abstract base class for all hooks
 */

import { SpecConfig, HookContext, HookExitCode } from '../types';
import { loadConfig } from './config-loader';
import { Logger, createScopedLogger } from './logger';

/**
 * Abstract base class for implementing hooks
 *
 * Provides common functionality:
 * - Configuration loading and caching
 * - Structured logging
 * - Error handling
 * - Exit code management
 */
export abstract class BaseHook {
  protected config: SpecConfig;
  protected logger: ReturnType<typeof createScopedLogger>;
  protected cwd: string;

  constructor(protected hookName: string) {
    this.cwd = process.cwd();

    // Load configuration
    try {
      this.config = loadConfig(this.cwd);
    } catch (error) {
      Logger.error(
        'Failed to load configuration',
        error,
        { hook: hookName }
      );
      this.exit(1);
      // TypeScript doesn't know exit() terminates, so throw to satisfy type checking
      throw new Error('Configuration loading failed');
    }

    // Create scoped logger
    this.logger = createScopedLogger(hookName);
  }

  /**
   * Execute the hook (must be implemented by subclass)
   *
   * @param context - Hook execution context from Claude Code
   * @returns Promise that resolves when hook execution completes
   */
  abstract execute(context: HookContext): Promise<void>;

  /**
   * Run the hook with error handling
   *
   * This is the main entry point that should be called from the hook script.
   * It handles reading input, executing the hook, and managing exit codes.
   */
  async run(): Promise<void> {
    try {
      // Read context from stdin (Claude Code passes context as JSON)
      const input = await this.readInput();
      const context = this.parseContext(input);

      // Execute the hook
      await this.execute(context);

      // Exit successfully
      this.exit(0);
    } catch (error) {
      this.handleError(error);
      this.exit(1);
    }
  }

  /**
   * Read input from stdin
   */
  protected async readInput(): Promise<string> {
    return new Promise((resolve, reject) => {
      let data = '';

      process.stdin.setEncoding('utf8');

      process.stdin.on('data', (chunk) => {
        data += chunk;
      });

      process.stdin.on('end', () => {
        resolve(data);
      });

      process.stdin.on('error', (error) => {
        reject(error);
      });
    });
  }

  /**
   * Parse hook context from input string
   */
  protected parseContext(input: string): HookContext {
    try {
      if (!input.trim()) {
        return {};
      }
      return JSON.parse(input) as HookContext;
    } catch (error) {
      throw new Error(
        `Failed to parse hook context: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Handle errors during hook execution
   */
  protected handleError(error: unknown): void {
    if (error instanceof Error) {
      this.logger.error('Hook execution failed', error);
    } else {
      this.logger.error('Hook execution failed with unknown error', undefined, {
        error: String(error),
      });
    }
  }

  /**
   * Exit the hook process
   *
   * @param code - Exit code (0 for success, 1 for failure)
   */
  protected exit(code: HookExitCode): never {
    process.exit(code);
  }

  /**
   * Validate that required context fields are present
   *
   * @param context - Hook context
   * @param requiredFields - Array of required field names
   * @throws Error if any required field is missing
   */
  protected validateContext(context: HookContext, requiredFields: string[]): void {
    for (const field of requiredFields) {
      if (!(field in context) || context[field] === null || context[field] === undefined) {
        throw new Error(`Required context field missing: ${field}`);
      }
    }
  }
}
