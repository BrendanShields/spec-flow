/**
 * Type definitions for session state management
 *
 * Note: Core session types moved to memory.ts for unified memory management system.
 * This file kept for backward compatibility with existing hooks.
 * Import from '../types/memory' for new code.
 */

// Re-export from memory.ts for backward compatibility
export type { SessionState, WorkflowPhase } from './memory';

// Legacy checkpoint interface (deprecated, use StateSnapshot from memory.ts)
export interface Checkpoint {
  timestamp: string;
  phase: string;
  feature: string;
  progress: number;
  snapshot: Record<string, unknown>;
}
