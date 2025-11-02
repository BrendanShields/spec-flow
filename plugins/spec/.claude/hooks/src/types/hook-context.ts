/**
 * Type definitions for hook execution context from Claude Code
 */

export interface HookContext {
  /** Tool that triggered the hook (Write, Edit, Bash, etc.) */
  tool?: string;

  /** Command that was executed (e.g., spec:implement) */
  command?: string | null;

  /** Output from the tool execution */
  output?: string;

  /** File path that was modified (for Write/Edit tools) */
  file_path?: string | null;

  /** Source of the operation (claude, assistant, user) */
  source?: 'claude' | 'assistant' | 'user';

  /** Agent identifier if operation was from an agent */
  agent?: string;

  /** Additional context data */
  [key: string]: unknown;
}

export interface HookOutput {
  type: string;
  message: string;
  details?: Record<string, unknown>;
  suggestion?: string;
  stack?: string;
}

export type HookExitCode = 0 | 1;
