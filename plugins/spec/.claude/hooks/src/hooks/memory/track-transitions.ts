#!/usr/bin/env node

/**
 * Track Transitions Hook
 *
 * Triggered on phase transitions to record timing metrics and
 * update workflow progress tracking.
 *
 * This hook automatically:
 * - Records phase start/end times
 * - Calculates phase duration
 * - Updates progress percentage
 * - Logs to WORKFLOW-PROGRESS.md
 * - Records phase completion metrics
 */

import { BaseHook } from '../../core/base-hook';
import { MemoryManager } from '../../core/memory-manager';
import { HookContext, WorkflowPhase } from '../../types';
import { ProgressEntry, PhaseStats } from '../../types/memory';

/**
 * Track Transitions Hook
 *
 * Automatically tracks phase transitions and records metrics
 */
export class TrackTransitionsHook extends BaseHook {
  private memoryManager: MemoryManager;
  private phaseStartTimes: Map<string, number> = new Map();

  // Phase progress percentages
  private readonly PHASE_PROGRESS: Record<WorkflowPhase, number> = {
    none: 0,
    initialize: 10,
    generate: 25,
    clarify: 35,
    plan: 50,
    tasks: 60,
    implement: 80,
    validate: 90,
    complete: 100,
  };

  constructor() {
    super('track-transitions');
    this.memoryManager = MemoryManager.getInstance(this.config, this.cwd);
  }

  async execute(context: HookContext): Promise<void> {
    const { command, args } = context;

    if (!command) return;

    // Detect phase transitions
    const transition = this.detectTransition(command, args as Record<string, unknown>);
    if (!transition) return;

    const { from, to } = transition;

    // Record phase completion
    if (from !== 'none') {
      await this.recordPhaseCompletion(from);
    }

    // Start tracking new phase
    if (to !== 'none' && to !== 'complete') {
      this.startPhaseTracking(to);
    }

    // Update progress
    await this.updateProgress(to);

    this.logger.info('Phase transition tracked', {
      from,
      to,
      progress: this.PHASE_PROGRESS[to],
    });
  }

  /**
   * Detect phase transition from command
   */
  private detectTransition(
    command: string,
    args?: Record<string, unknown>
  ): { from: WorkflowPhase; to: WorkflowPhase } | null {
    const session = this.memoryManager.getCurrentSession();
    if (!session) return null;

    const currentPhase = session.phase || 'none';
    const newPhase = this.extractPhaseFromCommand(command, args);

    if (!newPhase || newPhase === currentPhase) {
      return null;
    }

    return { from: currentPhase, to: newPhase };
  }

  /**
   * Extract target phase from command
   */
  private extractPhaseFromCommand(
    command: string,
    args?: Record<string, unknown>
  ): WorkflowPhase | null {
    // Check explicit phase in args
    if (args?.phase && typeof args.phase === 'string') {
      return args.phase as WorkflowPhase;
    }

    // Infer from command keywords
    if (command.includes('init')) return 'initialize';
    if (command.includes('generate') || command.includes('specify')) return 'generate';
    if (command.includes('clarify')) return 'clarify';
    if (command.includes('plan') || command.includes('design')) return 'plan';
    if (command.includes('tasks') || command.includes('breakdown')) return 'tasks';
    if (command.includes('implement') || command.includes('build')) return 'implement';
    if (command.includes('validate') || command.includes('verify')) return 'validate';
    if (command.includes('complete') || command.includes('finish')) return 'complete';

    return null;
  }

  /**
   * Start tracking a new phase
   */
  private startPhaseTracking(phase: WorkflowPhase): void {
    const now = Date.now();
    this.phaseStartTimes.set(phase, now);
    this.logger.info('Started phase tracking', { phase, timestamp: now });
  }

  /**
   * Record phase completion with metrics
   */
  private async recordPhaseCompletion(phase: WorkflowPhase): Promise<void> {
    const startTime = this.phaseStartTimes.get(phase);
    const endTime = Date.now();
    const duration = startTime ? endTime - startTime : 0;

    const session = this.memoryManager.getCurrentSession();
    if (!session) return;

    // Create phase stats
    const phaseStats: PhaseStats = {
      phase,
      duration,
      artifacts: this.inferArtifacts(phase),
      tasksCompleted: session.tasksComplete,
      metrics: {
        startTime: startTime || 0,
        endTime,
      },
    };

    this.logger.info('Phase completed', {
      phase,
      duration: this.formatDuration(duration),
      artifacts: phaseStats.artifacts.length,
    });

    // Clean up tracking
    this.phaseStartTimes.delete(phase);

    // Record to MemoryManager
    await this.memoryManager.recordPhaseCompletion(phase, phaseStats);
  }

  /**
   * Update progress tracking
   */
  private async updateProgress(phase: WorkflowPhase): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session || !session.feature) return;

    const progressEntry: ProgressEntry = {
      feature: session.feature,
      featureName: this.extractFeatureName(session.feature),
      phase,
      progress: this.PHASE_PROGRESS[phase],
      timestamp: new Date().toISOString(),
      completedTasks: session.tasksComplete,
      totalTasks: session.tasksTotal,
      notes: `Transitioned to ${phase}`,
    };

    await this.memoryManager.appendWorkflowProgress(progressEntry);
  }

  /**
   * Infer artifacts created during phase
   */
  private inferArtifacts(phase: WorkflowPhase): string[] {
    const artifacts: string[] = [];

    switch (phase) {
      case 'initialize':
        artifacts.push('project-requirements.md', 'architecture-blueprint.md');
        break;
      case 'generate':
        artifacts.push('spec.md');
        break;
      case 'clarify':
        artifacts.push('clarifications.md');
        break;
      case 'plan':
        artifacts.push('plan.md', 'ADRs');
        break;
      case 'tasks':
        artifacts.push('tasks.md');
        break;
      case 'implement':
        artifacts.push('source files', 'tests');
        break;
      case 'validate':
        artifacts.push('test results', 'validation report');
        break;
      case 'complete':
        artifacts.push('completion report', 'metrics');
        break;
    }

    return artifacts;
  }

  /**
   * Extract feature name from feature ID
   */
  private extractFeatureName(featureId: string): string {
    // Extract from format: "001-feature-name" -> "feature-name"
    const parts = featureId.split('-');
    return parts.length > 1 ? parts.slice(1).join('-') : featureId;
  }

  /**
   * Format duration in human-readable format
   */
  private formatDuration(ms: number): string {
    if (ms < 1000) return `${ms}ms`;

    const seconds = Math.floor(ms / 1000);
    if (seconds < 60) return `${seconds}s`;

    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    if (minutes < 60) {
      return remainingSeconds > 0 ? `${minutes}m ${remainingSeconds}s` : `${minutes}m`;
    }

    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}m` : `${hours}h`;
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new TrackTransitionsHook();
  await hook.run();
}

main();
