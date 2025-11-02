/**
 * Type definitions for session state management
 */

export interface SessionState {
  feature: string | null;
  phase: WorkflowPhase | null;
  progress: number;
  tasksComplete: number;
  tasksTotal: number;
  lastUpdated?: string;
}

export type WorkflowPhase =
  | 'initialize'
  | 'generate'
  | 'clarify'
  | 'plan'
  | 'tasks'
  | 'implement'
  | 'validate'
  | 'complete';

export interface Checkpoint {
  timestamp: string;
  phase: WorkflowPhase;
  feature: string;
  progress: number;
  snapshot: Record<string, unknown>;
}
