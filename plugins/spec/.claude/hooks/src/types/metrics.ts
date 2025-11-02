/**
 * Type definitions for code metrics tracking
 */

export interface MetricsData {
  version: string;
  created: string;
  lastUpdated: string;
  totals: MetricsTotals;
  files: Record<string, FileMetrics>;
  skills: Record<string, number>;
  hourlyActivity: Record<number, number>;
  statistics: Statistics;
}

export interface MetricsTotals {
  aiGeneratedFiles: number;
  aiGeneratedLines: number;
  aiModifiedLines: number;
  humanCreatedFiles: number;
  humanWrittenLines: number;
  humanModifiedLines: number;
  totalOperations: number;
}

export interface FileMetrics {
  created: string;
  lastModified: string;
  aiLines: number;
  humanLines: number;
  totalLines: number;
  modifications: Modification[];
  type: ModificationType;
}

export interface Modification {
  timestamp: string;
  type: ModificationType;
  lines: number;
  tool: string;
  skill: string | null;
}

export type ModificationType =
  | 'ai_created'
  | 'ai_modified'
  | 'human_created'
  | 'human_modified'
  | 'mixed';

export interface Statistics {
  aiPercentage: number;
  humanPercentage: number;
  totalLines: number;
  totalFiles: number;
  averageLinesPerFile: number;
  mostActiveHour: number;
  topSkills: Array<{ skill: string; count: number }>;
  fileTypeDistribution: Record<string, number>;
  generationVelocity: number;
}

export interface Operation {
  timestamp: string;
  file: string;
  type: ModificationType;
  lines: number;
  tool: string;
  skill: string | null;
  hash: string | null;
}

export interface AISignatures {
  spec: string[];
  claude: string[];
  comments: string[];
}
