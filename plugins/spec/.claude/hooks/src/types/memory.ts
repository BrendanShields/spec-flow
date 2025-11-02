/**
 * Memory Management Type Definitions
 *
 * Core types for the centralized memory management system
 */

/**
 * Workflow phases in the Spec system
 */
export type WorkflowPhase =
  | 'none'
  | 'initialize'
  | 'generate'
  | 'clarify'
  | 'plan'
  | 'tasks'
  | 'implement'
  | 'validate'
  | 'complete';

/**
 * Feature context information
 */
export interface FeatureContext {
  /** Feature ID (e.g., "001") */
  id: string;
  /** Feature name slug (e.g., "memory-management-improvements") */
  name: string;
  /** Current workflow phase */
  phase: WorkflowPhase;
  /** ISO 8601 timestamp when feature work started */
  started: string;
  /** Optional JIRA key if integration enabled */
  jiraKey?: string;
}

/**
 * Task context information
 */
export interface TaskContext {
  /** Task ID (e.g., "T001") */
  id: string;
  /** Task description */
  description: string;
  /** Associated user story (e.g., "US1.1") */
  userStory: string;
  /** Task execution status */
  status: 'pending' | 'in_progress' | 'complete';
  /** Progress indicator (e.g., "3/10 tasks") */
  progress: string;
}

/**
 * Configuration state
 */
export interface ConfigState {
  /** Whether architecture blueprint is required */
  requireBlueprint: boolean;
  /** Whether ADRs are required for decisions */
  requireADR: boolean;
  /** Whether to auto-validate state on changes */
  autoValidate: boolean;
  /** Whether to auto-checkpoint between phases */
  autoCheckpoint: boolean;
}

/**
 * Phase status in workflow progress
 */
export interface PhaseStatus {
  /** Phase name */
  phase: string;
  /** Whether phase is complete */
  complete: boolean;
  /** Display label */
  label: string;
}

/**
 * Complete session state (maps to current-session.md)
 */
export interface SessionState {
  // YAML frontmatter fields
  /** Active feature ID or null */
  feature: string | null;
  /** Current workflow phase or null */
  phase: WorkflowPhase | null;
  /** ISO 8601 timestamp when session started */
  started: string | null;
  /** ISO 8601 timestamp of last update */
  last_updated: string;
  /** Schema version for migration compatibility */
  schema_version: string;

  // Legacy fields for backward compatibility with existing hooks
  /** Overall progress percentage (0-100) - deprecated, use workflowProgress */
  progress?: number;
  /** Completed tasks count - deprecated, use workflowProgress */
  tasksComplete?: number;
  /** Total tasks count - deprecated, use workflowProgress */
  tasksTotal?: number;

  // Markdown body structured content
  /** Active work context */
  activeWork?: {
    currentFeature: FeatureContext | null;
    currentTask: TaskContext | null;
  };

  /** Workflow progress tracking */
  workflowProgress?: {
    completedPhases: PhaseStatus[];
    taskCompletion: string;
  };

  /** Configuration state */
  configState?: ConfigState;

  /** Session notes (markdown text) */
  sessionNotes?: string;

  /** Current blockers (array of strings) */
  blockers?: string[];

  /** Next steps (array of strings) */
  nextSteps?: string[];
}

/**
 * Memory entry for append-only files
 */
export interface MemoryEntry {
  /** ISO 8601 timestamp */
  timestamp: string;
  /** Entry type */
  type: 'progress' | 'decision' | 'change_planned' | 'change_completed';
  /** Associated feature ID */
  feature: string;
  /** Entry-specific data */
  data: unknown;
}

/**
 * Workflow progress entry
 */
export interface ProgressEntry {
  /** Feature ID */
  feature: string;
  /** Feature name */
  featureName: string;
  /** Current phase */
  phase: WorkflowPhase;
  /** Progress percentage (0-100) */
  progress: number;
  /** ISO 8601 timestamp */
  timestamp: string;
  /** Completed task count */
  completedTasks?: number;
  /** Total task count */
  totalTasks?: number;
  /** Additional notes */
  notes?: string;
}

/**
 * Architecture Decision Record
 */
export interface DecisionRecord {
  /** ADR ID (e.g., "ADR-001") */
  id: string;
  /** Decision title */
  title: string;
  /** Decision date (YYYY-MM-DD) */
  date: string;
  /** Decision status */
  status: 'proposed' | 'accepted' | 'deprecated' | 'superseded';
  /** Feature ID this decision relates to */
  feature: string;
  /** Decision context and rationale */
  context: string;
  /** The decision made */
  decision: string;
  /** Consequences of the decision */
  consequences: {
    positive: string[];
    negative: string[];
    neutral: string[];
  };
  /** Alternatives considered */
  alternatives?: string[];
}

/**
 * Planned change entry
 */
export interface PlannedChange {
  /** Change ID (e.g., "CHG-001") */
  id: string;
  /** Feature ID */
  feature: string;
  /** Priority (P1/P2/P3) */
  priority: 'P1' | 'P2' | 'P3';
  /** Associated user story */
  story: string;
  /** Change description */
  description: string;
  /** Estimated effort */
  estimatedEffort: 'S' | 'M' | 'L' | 'XL';
  /** Dependencies (other change IDs) */
  dependencies: string[];
  /** Date added (YYYY-MM-DD) */
  added: string;
}

/**
 * Completed change entry
 */
export interface ChangeCompletion {
  /** Change ID */
  id: string;
  /** Feature ID */
  feature: string;
  /** Completion date (YYYY-MM-DD) */
  completed: string;
  /** Actual duration */
  duration: string;
  /** Implementer */
  implementedBy: string;
  /** Files modified */
  filesChanged: string[];
  /** Tests added */
  testsAdded: string[];
  /** Commit hashes */
  commits?: string[];
}

/**
 * Phase statistics
 */
export interface PhaseStats {
  /** Phase that completed */
  phase: WorkflowPhase;
  /** Duration in milliseconds */
  duration: number;
  /** Artifacts created */
  artifacts: string[];
  /** Tasks completed count */
  tasksCompleted?: number;
  /** Additional metrics */
  metrics?: Record<string, number>;
}

/**
 * State snapshot
 */
export interface StateSnapshot {
  /** Snapshot UUID */
  id: string;
  /** ISO 8601 timestamp */
  timestamp: string;
  /** Optional label (e.g., "post-planning") */
  label?: string;
  /** Complete session state at time of snapshot */
  state: SessionState;
  /** File hashes for integrity checking */
  files: Array<{
    path: string;
    hash: string; // SHA-256
  }>;
}

/**
 * State inconsistency detected by validation
 */
export interface Inconsistency {
  /** Inconsistency type */
  type: 'orphaned_state' | 'invalid_phase' | 'missing_feature' | 'timestamp_mismatch' | 'schema_mismatch';
  /** Severity level */
  severity: 'critical' | 'error' | 'warning';
  /** Description of the issue */
  message: string;
  /** Affected field or file */
  field?: string;
  /** Suggested fix */
  suggestion?: string;
}

/**
 * Validation error
 */
export interface ValidationError {
  /** Field that failed validation */
  field: string;
  /** Error message */
  message: string;
  /** Error severity */
  severity: 'critical' | 'error';
}

/**
 * Validation warning
 */
export interface ValidationWarning {
  /** Field with warning */
  field: string;
  /** Warning message */
  message: string;
  /** Suggested action */
  suggestion?: string;
}

/**
 * Validation result
 */
export interface ValidationResult {
  /** Whether state is valid */
  valid: boolean;
  /** Validation errors */
  errors: ValidationError[];
  /** Validation warnings */
  warnings: ValidationWarning[];
}

/**
 * State repair report
 */
export interface RepairReport {
  /** Whether repair was successful */
  success: boolean;
  /** Repairs performed */
  repairs: Array<{
    issue: string;
    action: string;
    result: 'fixed' | 'failed' | 'skipped';
  }>;
  /** Backup path if created */
  backupPath?: string;
  /** Errors encountered */
  errors: string[];
}
