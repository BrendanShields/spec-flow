/**
 * Session Metrics Aggregator
 *
 * Calculates workflow metrics from session history:
 * - Velocity (tasks/features per day)
 * - Completion rates
 * - Phase durations
 * - Success patterns
 */

import { StateChangeEntry, StateHistoryLogger } from './state-history';
import { WorkflowPhase } from '../types/memory';

/**
 * Aggregated session metrics
 */
export interface SessionMetrics {
  /** Total session duration in hours */
  totalDuration: number;
  /** Number of state changes */
  totalChanges: number;
  /** Average changes per day */
  velocityChangesPerDay: number;
  /** Phase statistics */
  phaseStats: {
    phase: WorkflowPhase;
    count: number;
    averageDuration: number;
  }[];
  /** Feature completion stats */
  features: {
    total: number;
    completed: number;
    inProgress: number;
    completionRate: number;
  };
  /** Task completion stats */
  tasks: {
    completed: number;
    total: number;
    completionRate: number;
    averageTasksPerFeature: number;
  };
  /** Most common issues */
  issues: {
    type: string;
    count: number;
  }[];
  /** Time of day patterns */
  activityPatterns: {
    hour: number;
    changeCount: number;
  }[];
}

/**
 * Session Metrics Aggregator
 */
export class SessionMetricsAggregator {
  private historyLogger: StateHistoryLogger;

  constructor(historyLogger: StateHistoryLogger) {
    this.historyLogger = historyLogger;
  }

  /**
   * Calculate comprehensive session metrics
   */
  public async calculateMetrics(): Promise<SessionMetrics> {
    const history = await this.historyLogger.getRecentHistory(1000);
    const stats = await this.historyLogger.getStatistics();

    if (history.length === 0) {
      return this.getEmptyMetrics();
    }

    return {
      totalDuration: this.calculateTotalDuration(history),
      totalChanges: history.length,
      velocityChangesPerDay: stats.averageChangesPerDay,
      phaseStats: this.calculatePhaseStats(history),
      features: this.calculateFeatureStats(history),
      tasks: this.calculateTaskStats(history),
      issues: this.calculateIssueStats(history),
      activityPatterns: this.calculateActivityPatterns(history),
    };
  }

  /**
   * Calculate velocity metrics (features/tasks over time)
   */
  public async calculateVelocity(
    period: 'day' | 'week' | 'month' = 'week'
  ): Promise<{
    featuresCompleted: number;
    tasksCompleted: number;
    phasesTransitioned: number;
    averageFeatureTime: number;
    averageTaskTime: number;
  }> {
    const daysInPeriod = period === 'day' ? 1 : period === 'week' ? 7 : 30;
    const startDate = new Date(Date.now() - daysInPeriod * 24 * 60 * 60 * 1000);
    const endDate = new Date();

    const history = await this.historyLogger.getHistoryInRange(startDate, endDate);

    let featuresCompleted = 0;
    let tasksCompleted = 0;
    let phasesTransitioned = 0;
    let totalFeatureTime = 0;
    let totalTaskTime = 0;

    const featureTimes: number[] = [];
    const taskTimes: number[] = [];

    for (const entry of history) {
      if (entry.type === 'transition') {
        phasesTransitioned++;

        if (entry.after.phase === 'complete') {
          featuresCompleted++;

          if (entry.after.started) {
            const featureTime =
              new Date(entry.timestamp).getTime() - new Date(entry.after.started).getTime();
            featureTimes.push(featureTime);
            totalFeatureTime += featureTime;
          }
        }
      }

      if (entry.changedFields.includes('tasksComplete')) {
        const before = (entry.before.tasksComplete as number) || 0;
        const after = (entry.after.tasksComplete as number) || 0;

        if (after > before) {
          const completed = after - before;
          tasksCompleted += completed;

          // Estimate task time (rough approximation)
          const taskTime = (new Date(entry.timestamp).getTime() - new Date(entry.timestamp).getTime()) / completed;
          taskTimes.push(taskTime);
          totalTaskTime += taskTime * completed;
        }
      }
    }

    const averageFeatureTime =
      featureTimes.length > 0 ? totalFeatureTime / featureTimes.length / (1000 * 60 * 60) : 0;
    const averageTaskTime =
      taskTimes.length > 0 ? totalTaskTime / taskTimes.length / (1000 * 60 * 60) : 0;

    return {
      featuresCompleted,
      tasksCompleted,
      phasesTransitioned,
      averageFeatureTime: Math.round(averageFeatureTime * 10) / 10,
      averageTaskTime: Math.round(averageTaskTime * 10) / 10,
    };
  }

  /**
   * Calculate total session duration
   */
  private calculateTotalDuration(history: StateChangeEntry[]): number {
    if (history.length === 0) return 0;

    const firstEntry = history[0];
    const lastEntry = history[history.length - 1];

    if (!firstEntry || !lastEntry) return 0;

    const duration =
      new Date(lastEntry.timestamp).getTime() - new Date(firstEntry.timestamp).getTime();
    return Math.round((duration / (1000 * 60 * 60)) * 10) / 10;
  }

  /**
   * Calculate phase statistics
   */
  private calculatePhaseStats(
    history: StateChangeEntry[]
  ): SessionMetrics['phaseStats'] {
    const phaseCounts: Record<string, { count: number; durations: number[] }> = {};

    let lastPhaseTime: number | null = null;
    let lastPhase: WorkflowPhase | null = null;

    for (const entry of history) {
      const phase = entry.after.phase as WorkflowPhase;

      if (phase && phase !== 'none') {
        if (!phaseCounts[phase]) {
          phaseCounts[phase] = { count: 0, durations: [] };
        }

        phaseCounts[phase].count++;

        // Calculate duration if transitioning from another phase
        if (lastPhase && lastPhase !== phase && lastPhaseTime) {
          const duration = new Date(entry.timestamp).getTime() - lastPhaseTime;
          phaseCounts[lastPhase]?.durations.push(duration);
        }

        lastPhase = phase;
        lastPhaseTime = new Date(entry.timestamp).getTime();
      }
    }

    return Object.entries(phaseCounts).map(([phase, data]) => ({
      phase: phase as WorkflowPhase,
      count: data.count,
      averageDuration:
        data.durations.length > 0
          ? Math.round(
              (data.durations.reduce((a, b) => a + b, 0) / data.durations.length / (1000 * 60 * 60)) * 10
            ) / 10
          : 0,
    }));
  }

  /**
   * Calculate feature statistics
   */
  private calculateFeatureStats(history: StateChangeEntry[]): SessionMetrics['features'] {
    const features = new Set<string>();
    const completedFeatures = new Set<string>();
    let currentFeature: string | null = null;

    for (const entry of history) {
      const feature = entry.after.feature as string;

      if (feature) {
        features.add(feature);
        currentFeature = feature;

        if (entry.after.phase === 'complete') {
          completedFeatures.add(feature);
        }
      }
    }

    const total = features.size;
    const completed = completedFeatures.size;
    const inProgress = currentFeature && !completedFeatures.has(currentFeature) ? 1 : 0;

    return {
      total,
      completed,
      inProgress,
      completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
    };
  }

  /**
   * Calculate task statistics
   */
  private calculateTaskStats(history: StateChangeEntry[]): SessionMetrics['tasks'] {
    let maxTasksComplete = 0;
    let maxTasksTotal = 0;
    const featureTaskCounts: number[] = [];

    for (const entry of history) {
      const tasksComplete = (entry.after.tasksComplete as number) || 0;
      const tasksTotal = (entry.after.tasksTotal as number) || 0;

      if (tasksComplete > maxTasksComplete) {
        maxTasksComplete = tasksComplete;
      }

      if (tasksTotal > maxTasksTotal) {
        maxTasksTotal = tasksTotal;
        featureTaskCounts.push(tasksTotal);
      }
    }

    const averageTasksPerFeature =
      featureTaskCounts.length > 0
        ? Math.round((featureTaskCounts.reduce((a, b) => a + b, 0) / featureTaskCounts.length) * 10) / 10
        : 0;

    return {
      completed: maxTasksComplete,
      total: maxTasksTotal,
      completionRate: maxTasksTotal > 0 ? Math.round((maxTasksComplete / maxTasksTotal) * 100) : 0,
      averageTasksPerFeature,
    };
  }

  /**
   * Calculate issue statistics
   */
  private calculateIssueStats(history: StateChangeEntry[]): SessionMetrics['issues'] {
    const issues: Record<string, number> = {};

    for (const entry of history) {
      if (entry.type === 'repair' && entry.metadata?.repairs) {
        const repairs = entry.metadata.repairs as string[];
        for (const repair of repairs) {
          issues[repair] = (issues[repair] || 0) + 1;
        }
      }
    }

    return Object.entries(issues)
      .map(([type, count]) => ({ type, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);
  }

  /**
   * Calculate activity patterns by hour of day
   */
  private calculateActivityPatterns(
    history: StateChangeEntry[]
  ): SessionMetrics['activityPatterns'] {
    const hourCounts: Record<number, number> = {};

    for (const entry of history) {
      const hour = new Date(entry.timestamp).getHours();
      hourCounts[hour] = (hourCounts[hour] || 0) + 1;
    }

    return Object.entries(hourCounts)
      .map(([hour, count]) => ({ hour: parseInt(hour), changeCount: count }))
      .sort((a, b) => a.hour - b.hour);
  }

  /**
   * Get empty metrics template
   */
  private getEmptyMetrics(): SessionMetrics {
    return {
      totalDuration: 0,
      totalChanges: 0,
      velocityChangesPerDay: 0,
      phaseStats: [],
      features: { total: 0, completed: 0, inProgress: 0, completionRate: 0 },
      tasks: { completed: 0, total: 0, completionRate: 0, averageTasksPerFeature: 0 },
      issues: [],
      activityPatterns: [],
    };
  }
}

/**
 * Create session metrics aggregator
 */
export function createSessionMetricsAggregator(
  historyLogger: StateHistoryLogger
): SessionMetricsAggregator {
  return new SessionMetricsAggregator(historyLogger);
}
