/**
 * Core types for Specter workflow artifacts and state
 */

export type WorkflowPhase =
  | 'initialization'
  | 'specification'
  | 'clarification'
  | 'planning'
  | 'task-breakdown'
  | 'implementation'
  | 'validation'
  | 'completed';

export type Priority = 'P1' | 'P2' | 'P3';

export type TaskStatus =
  | 'pending'
  | 'in_progress'
  | 'blocked'
  | 'completed'
  | 'skipped';

export interface UserStory {
  id: string;
  priority: Priority;
  title: string;
  asA: string;
  iWant: string;
  soThat: string;
  acceptanceCriteria: string[];
  estimatedComplexity?: 'low' | 'medium' | 'high';
  dependencies?: string[];
}

export interface TechnicalDecision {
  id: string;
  date: string;
  context: string;
  decision: string;
  rationale: string;
  consequences: string[];
  alternatives?: string[];
}

export interface Task {
  id: string;
  title: string;
  description: string;
  priority: Priority;
  status: TaskStatus;
  storyId?: string;
  dependencies?: string[];
  estimatedHours?: number;
  actualHours?: number;
  assignee?: string;
  parallel?: boolean;
  filesToModify?: string[];
}

export interface Specification {
  featureId: string;
  featureName: string;
  overview: string;
  userStories: UserStory[];
  outOfScope?: string[];
  technicalConstraints?: string[];
  dependencies?: string[];
  clarifications?: Clarification[];
}

export interface Clarification {
  question: string;
  answer: string;
  date: string;
}

export interface TechnicalPlan {
  featureId: string;
  architecture: {
    components: Component[];
    dataFlow: string;
    integrationPoints: string[];
  };
  decisions: TechnicalDecision[];
  implementation: {
    phases: ImplementationPhase[];
    risks: Risk[];
  };
}

export interface Component {
  name: string;
  type: string;
  responsibilities: string[];
  interfaces?: string[];
  dependencies?: string[];
}

export interface ImplementationPhase {
  name: string;
  description: string;
  tasks: string[];
  deliverables: string[];
}

export interface Risk {
  description: string;
  likelihood: 'low' | 'medium' | 'high';
  impact: 'low' | 'medium' | 'high';
  mitigation: string;
}

export interface SessionState {
  sessionId: string;
  startTime: string;
  lastUpdated: string;
  currentFeature?: {
    id: string;
    name: string;
    directory: string;
  };
  currentPhase: WorkflowPhase;
  tasksProgress: {
    total: number;
    completed: number;
    inProgress: number;
    blocked: number;
  };
  recentActivity: ActivityLog[];
  checkpoints: Checkpoint[];
}

export interface ActivityLog {
  timestamp: string;
  action: string;
  details: string;
  phase: WorkflowPhase;
}

export interface Checkpoint {
  id: string;
  timestamp: string;
  description: string;
  phase: WorkflowPhase;
  gitCommit?: string;
}

export interface WorkflowProgress {
  features: FeatureProgress[];
  totalMetrics: WorkflowMetrics;
}

export interface FeatureProgress {
  id: string;
  name: string;
  phase: WorkflowPhase;
  startDate: string;
  completedDate?: string;
  metrics: FeatureMetrics;
}

export interface FeatureMetrics {
  stories: {
    total: number;
    byPriority: Record<Priority, number>;
  };
  tasks: {
    total: number;
    completed: number;
    inProgress: number;
    blocked: number;
    byPriority: Record<Priority, number>;
  };
  estimatedHours?: number;
  actualHours?: number;
  decisions: number;
  clarifications: number;
}

export interface WorkflowMetrics {
  totalFeatures: number;
  completedFeatures: number;
  inProgressFeatures: number;
  totalTasks: number;
  completedTasks: number;
  totalDecisions: number;
  averageFeatureTime?: number;
  completionRate: number;
}

export interface Change {
  id: string;
  type: 'addition' | 'modification' | 'deletion';
  category: 'feature' | 'bugfix' | 'refactor' | 'documentation' | 'test';
  description: string;
  files: string[];
  storyId?: string;
  taskId?: string;
  timestamp?: string;
  completedBy?: string;
}

export interface SpecterConfig {
  projectRoot: string;
  specterDir: string;
  stateDir: string;
  memoryDir: string;
  featuresDir: string;
  initialized: boolean;
}

export interface FileChange {
  path: string;
  type: 'created' | 'modified' | 'deleted';
  timestamp: Date;
  size?: number;
}

export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

export interface ValidationError {
  file: string;
  message: string;
  severity: 'error';
}

export interface ValidationWarning {
  file: string;
  message: string;
  severity: 'warning';
}

export interface SpecterProject {
  config: SpecterConfig;
  session: SessionState | null;
  progress: WorkflowProgress | null;
  features: Map<string, FeatureData>;
}

export interface FeatureData {
  id: string;
  name: string;
  spec: Specification | null;
  plan: TechnicalPlan | null;
  tasks: Task[];
  status: WorkflowPhase;
}
