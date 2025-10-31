import {
  WorkflowMetrics,
  FeatureMetrics,
  Task,
  UserStory,
  Priority,
  FeatureProgress,
  WorkflowPhase,
} from '../types/specter.js';

export class MetricsCalculator {
  calculateFeatureMetrics(
    stories: UserStory[],
    tasks: Task[],
    decisions: number = 0,
    clarifications: number = 0
  ): FeatureMetrics {
    const tasksByPriority: Record<Priority, number> = {
      P1: tasks.filter(t => t.priority === 'P1').length,
      P2: tasks.filter(t => t.priority === 'P2').length,
      P3: tasks.filter(t => t.priority === 'P3').length,
    };

    const storiesByPriority: Record<Priority, number> = {
      P1: stories.filter(s => s.priority === 'P1').length,
      P2: stories.filter(s => s.priority === 'P2').length,
      P3: stories.filter(s => s.priority === 'P3').length,
    };

    const estimatedHours = tasks.reduce(
      (sum, task) => sum + (task.estimatedHours || 0),
      0
    );

    const actualHours = tasks.reduce(
      (sum, task) => sum + (task.actualHours || 0),
      0
    );

    return {
      stories: {
        total: stories.length,
        byPriority: storiesByPriority,
      },
      tasks: {
        total: tasks.length,
        completed: tasks.filter(t => t.status === 'completed').length,
        inProgress: tasks.filter(t => t.status === 'in_progress').length,
        blocked: tasks.filter(t => t.status === 'blocked').length,
        byPriority: tasksByPriority,
      },
      estimatedHours: estimatedHours > 0 ? estimatedHours : undefined,
      actualHours: actualHours > 0 ? actualHours : undefined,
      decisions,
      clarifications,
    };
  }

  calculateWorkflowMetrics(features: FeatureProgress[]): WorkflowMetrics {
    const totalTasks = features.reduce(
      (sum, f) => sum + (f.metrics.tasks.total || 0),
      0
    );

    const completedTasks = features.reduce(
      (sum, f) => sum + (f.metrics.tasks.completed || 0),
      0
    );

    const totalDecisions = features.reduce(
      (sum, f) => sum + (f.metrics.decisions || 0),
      0
    );

    const completedFeatures = features.filter(
      f => f.phase === 'completed'
    ).length;

    const inProgressFeatures = features.filter(
      f => f.phase !== 'completed'
    ).length;

    // Calculate average feature time for completed features
    const completedFeaturesWithDates = features.filter(
      f => f.phase === 'completed' && f.completedDate && f.startDate
    );

    let averageFeatureTime: number | undefined;
    if (completedFeaturesWithDates.length > 0) {
      const totalTime = completedFeaturesWithDates.reduce((sum, f) => {
        const start = new Date(f.startDate).getTime();
        const end = new Date(f.completedDate!).getTime();
        return sum + (end - start);
      }, 0);

      // Convert to hours
      averageFeatureTime = totalTime / completedFeaturesWithDates.length / (1000 * 60 * 60);
    }

    const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return {
      totalFeatures: features.length,
      completedFeatures,
      inProgressFeatures,
      totalTasks,
      completedTasks,
      totalDecisions,
      averageFeatureTime,
      completionRate: Math.round(completionRate * 10) / 10,
    };
  }

  calculateVelocity(features: FeatureProgress[], days: number = 7): number {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const recentTasks = features.reduce((sum, feature) => {
      const featureDate = new Date(feature.startDate);
      if (featureDate >= cutoffDate) {
        return sum + feature.metrics.tasks.completed;
      }
      return sum;
    }, 0);

    return Math.round((recentTasks / days) * 10) / 10;
  }

  calculateHealthScore(
    tasks: Task[],
    phase: WorkflowPhase
  ): { score: number; status: 'healthy' | 'warning' | 'critical'; factors: string[] } {
    let score = 100;
    const factors: string[] = [];

    // Check for blocked tasks
    const blockedTasks = tasks.filter(t => t.status === 'blocked').length;
    if (blockedTasks > 0) {
      const penalty = Math.min(blockedTasks * 15, 40);
      score -= penalty;
      factors.push(`${blockedTasks} blocked task(s)`);
    }

    // Check completion rate
    const completionRate = tasks.length > 0
      ? (tasks.filter(t => t.status === 'completed').length / tasks.length) * 100
      : 0;

    if (phase === 'implementation' && completionRate < 30) {
      score -= 20;
      factors.push('Low completion rate');
    }

    // Check for tasks in progress
    const inProgressTasks = tasks.filter(t => t.status === 'in_progress').length;
    if (inProgressTasks === 0 && phase === 'implementation' && completionRate < 100) {
      score -= 15;
      factors.push('No tasks in progress');
    }

    // Check priority distribution
    const p1Tasks = tasks.filter(t => t.priority === 'P1');
    const p1Completed = p1Tasks.filter(t => t.status === 'completed').length;
    const p1CompletionRate = p1Tasks.length > 0 ? (p1Completed / p1Tasks.length) * 100 : 100;

    if (p1CompletionRate < 50 && completionRate > 50) {
      score -= 10;
      factors.push('P1 tasks lagging behind');
    }

    score = Math.max(0, Math.min(100, score));

    let status: 'healthy' | 'warning' | 'critical';
    if (score >= 70) status = 'healthy';
    else if (score >= 40) status = 'warning';
    else status = 'critical';

    return { score, status, factors };
  }

  calculateEstimateAccuracy(tasks: Task[]): number | null {
    const tasksWithEstimates = tasks.filter(
      t => t.estimatedHours && t.actualHours && t.status === 'completed'
    );

    if (tasksWithEstimates.length === 0) {
      return null;
    }

    const totalEstimated = tasksWithEstimates.reduce(
      (sum, t) => sum + (t.estimatedHours || 0),
      0
    );

    const totalActual = tasksWithEstimates.reduce(
      (sum, t) => sum + (t.actualHours || 0),
      0
    );

    if (totalEstimated === 0) return null;

    const accuracy = (1 - Math.abs(totalActual - totalEstimated) / totalEstimated) * 100;
    return Math.max(0, Math.round(accuracy * 10) / 10);
  }

  getPhaseProgress(phase: WorkflowPhase, tasks: Task[]): number {
    const phaseSteps: Record<WorkflowPhase, number> = {
      initialization: 1,
      specification: 2,
      clarification: 3,
      planning: 4,
      'task-breakdown': 5,
      implementation: 6,
      validation: 7,
      completed: 8,
    };

    const currentStep = phaseSteps[phase];
    const totalSteps = 8;

    // Add task completion percentage for implementation phase
    if (phase === 'implementation' && tasks.length > 0) {
      const completionRate = tasks.filter(t => t.status === 'completed').length / tasks.length;
      return Math.round(((currentStep - 1 + completionRate) / totalSteps) * 100);
    }

    return Math.round((currentStep / totalSteps) * 100);
  }

  getPriorityDistribution(tasks: Task[]): { priority: Priority; count: number; percentage: number }[] {
    const distribution = [
      { priority: 'P1' as Priority, count: 0, percentage: 0 },
      { priority: 'P2' as Priority, count: 0, percentage: 0 },
      { priority: 'P3' as Priority, count: 0, percentage: 0 },
    ];

    tasks.forEach(task => {
      const item = distribution.find(d => d.priority === task.priority);
      if (item) item.count++;
    });

    const total = tasks.length;
    distribution.forEach(item => {
      item.percentage = total > 0 ? Math.round((item.count / total) * 100) : 0;
    });

    return distribution;
  }
}
