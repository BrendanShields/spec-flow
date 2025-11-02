#!/usr/bin/env node

/**
 * Update Memory Hook
 *
 * Triggered on PostToolUse events to automatically update memory files
 * via MemoryManager. Routes events to appropriate memory operations.
 *
 * This hook enforces centralized state management by intercepting
 * all state-changing operations and routing them through MemoryManager.
 */

import { BaseHook } from '../../core/base-hook';
import { MemoryManager } from '../../core/memory-manager';
import { HookContext, WorkflowPhase } from '../../types';
import {
  ProgressEntry,
  DecisionRecord,
  PlannedChange,
  ChangeCompletion,
} from '../../types/memory';

/**
 * Update Memory Hook
 *
 * Automatically updates memory files based on workflow events
 */
export class UpdateMemoryHook extends BaseHook {
  private memoryManager: MemoryManager;

  constructor() {
    super('update-memory');
    this.memoryManager = MemoryManager.getInstance(this.config, this.cwd);
  }

  async execute(context: HookContext): Promise<void> {
    const { command, args } = context;

    if (!command) return;

    // Ensure args is properly typed
    const safeArgs = (args as Record<string, unknown>) || {};

    // Route based on command type
    if (this.isProgressUpdate(command, safeArgs)) {
      await this.handleProgressUpdate(command, safeArgs);
    } else if (this.isDecisionUpdate(command, safeArgs)) {
      await this.handleDecisionUpdate(command, safeArgs);
    } else if (this.isChangeUpdate(command, safeArgs)) {
      await this.handleChangeUpdate(command, safeArgs);
    } else if (this.isPhaseTransition(command, safeArgs)) {
      await this.handlePhaseTransition(command, safeArgs);
    }
  }

  /**
   * Check if command represents a progress update
   */
  private isProgressUpdate(command: string, args?: Record<string, unknown>): boolean {
    return (
      command.includes('implement') ||
      command.includes('complete') ||
      command.includes('progress') ||
      (args?.type === 'progress' as unknown)
    );
  }

  /**
   * Check if command represents a decision/ADR
   */
  private isDecisionUpdate(command: string, args?: Record<string, unknown>): boolean {
    return (
      command.includes('plan') ||
      command.includes('design') ||
      command.includes('decision') ||
      command.includes('adr') ||
      (args?.type === 'decision' as unknown)
    );
  }

  /**
   * Check if command represents a change planning/completion
   */
  private isChangeUpdate(command: string, args?: Record<string, unknown>): boolean {
    return (
      command.includes('task') ||
      command.includes('change') ||
      (args?.type === 'change' as unknown)
    );
  }

  /**
   * Check if command represents a phase transition
   */
  private isPhaseTransition(command: string, args?: Record<string, unknown>): boolean {
    return (
      command.includes('init') ||
      command.includes('generate') ||
      command.includes('clarify') ||
      command.includes('plan') ||
      command.includes('tasks') ||
      command.includes('implement') ||
      command.includes('validate') ||
      command.includes('complete') ||
      (args?.type === 'transition' as unknown)
    );
  }

  /**
   * Handle progress updates
   */
  private async handleProgressUpdate(
    _command: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session || !session.feature) {
      this.logger.warn('No active feature for progress update');
      return;
    }

    const progressEntry: ProgressEntry = {
      feature: session.feature,
      featureName: this.extractFeatureName(session.feature),
      phase: session.phase || 'none',
      progress: session.progress || 0,
      timestamp: new Date().toISOString(),
      completedTasks: session.tasksComplete,
      totalTasks: session.tasksTotal,
      notes: args?.notes ? String(args.notes) : undefined,
    };

    await this.memoryManager.appendWorkflowProgress(progressEntry);
    this.logger.info('Progress updated', {
      feature: progressEntry.feature,
      progress: progressEntry.progress,
    });
  }

  /**
   * Handle decision/ADR updates
   */
  private async handleDecisionUpdate(
    command: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session || !session.feature) {
      this.logger.warn('No active feature for decision update');
      return;
    }

    // Extract decision information from args
    const decisionId = args?.id ? String(args.id) : this.generateDecisionId();
    const title = args?.title ? String(args.title) : 'Decision from ' + command;
    const context = args?.context ? String(args.context) : '';
    const decision = args?.decision ? String(args.decision) : '';

    const decisionRecord: DecisionRecord = {
      id: decisionId,
      title: title,
      date: new Date().toISOString().split('T')[0] || '',
      status: 'accepted',
      feature: session.feature,
      context: context,
      decision: decision,
      consequences: {
        positive: this.extractList(args?.positives),
        negative: this.extractList(args?.negatives),
        neutral: this.extractList(args?.neutral),
      },
      alternatives: this.extractList(args?.alternatives),
    };

    await this.memoryManager.appendDecisionLog(decisionRecord);
    this.logger.info('Decision logged', {
      id: decisionRecord.id,
      title: decisionRecord.title,
    });
  }

  /**
   * Handle change planning/completion
   */
  private async handleChangeUpdate(
    command: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session || !session.feature) {
      this.logger.warn('No active feature for change update');
      return;
    }

    if (command.includes('complete') || args?.status === 'completed') {
      await this.handleChangeCompletion(session.feature, args);
    } else {
      await this.handleChangePlanning(session.feature, args);
    }
  }

  /**
   * Handle planned change
   */
  private async handleChangePlanning(
    feature: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const changeId = args?.id ? String(args.id) : this.generateChangeId();
    const description = args?.description ? String(args.description) : '';
    const priority = this.extractPriority(args?.priority);

    const plannedChange: PlannedChange = {
      id: changeId,
      feature: feature,
      priority: priority,
      story: args?.story ? String(args.story) : 'TBD',
      description: description,
      estimatedEffort: this.extractEffort(args?.effort),
      dependencies: this.extractList(args?.dependencies),
      added: new Date().toISOString().split('T')[0] || '',
    };

    await this.memoryManager.appendPlannedChange(plannedChange);
    this.logger.info('Change planned', {
      id: plannedChange.id,
      priority: plannedChange.priority,
    });
  }

  /**
   * Handle change completion
   */
  private async handleChangeCompletion(
    feature: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const changeId = args?.id ? String(args.id) : this.generateChangeId();

    const changeCompletion: ChangeCompletion = {
      id: changeId,
      feature: feature,
      completed: new Date().toISOString().split('T')[0] || '',
      duration: args?.duration ? String(args.duration) : 'Unknown',
      implementedBy: args?.implementedBy ? String(args.implementedBy) : 'System',
      filesChanged: this.extractList(args?.files),
      testsAdded: this.extractList(args?.tests),
      commits: this.extractList(args?.commits),
    };

    await this.memoryManager.markChangeCompleted(changeId, changeCompletion);
    this.logger.info('Change completed', {
      id: changeCompletion.id,
      duration: changeCompletion.duration,
    });
  }

  /**
   * Handle phase transitions
   */
  private async handlePhaseTransition(
    command: string,
    args?: Record<string, unknown>
  ): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session) {
      this.logger.warn('No active session for phase transition');
      return;
    }

    const currentPhase = session.phase || 'none';
    const newPhase = this.extractPhaseFromCommand(command, args);

    if (newPhase && newPhase !== currentPhase) {
      await this.memoryManager.transitionPhase(currentPhase, newPhase, args);
      this.logger.info('Phase transition', {
        from: currentPhase,
        to: newPhase,
      });
    }
  }

  /**
   * Extract phase from command
   */
  private extractPhaseFromCommand(
    command: string,
    args?: Record<string, unknown>
  ): WorkflowPhase | null {
    if (args?.phase) {
      return args.phase as WorkflowPhase;
    }

    if (command.includes('init')) return 'initialize';
    if (command.includes('generate') || command.includes('specify')) return 'generate';
    if (command.includes('clarify')) return 'clarify';
    if (command.includes('plan')) return 'plan';
    if (command.includes('tasks')) return 'tasks';
    if (command.includes('implement')) return 'implement';
    if (command.includes('validate')) return 'validate';
    if (command.includes('complete')) return 'complete';

    return null;
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
   * Generate decision ID
   */
  private generateDecisionId(): string {
    const timestamp = new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
    return `ADR-${timestamp}`;
  }

  /**
   * Generate change ID
   */
  private generateChangeId(): string {
    const timestamp = new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
    return `CHG-${timestamp}`;
  }

  /**
   * Extract priority from args
   */
  private extractPriority(value: unknown): 'P1' | 'P2' | 'P3' {
    const str = String(value || 'P2').toUpperCase();
    if (str.includes('P1') || str.includes('HIGH') || str.includes('MUST')) return 'P1';
    if (str.includes('P3') || str.includes('LOW') || str.includes('NICE')) return 'P3';
    return 'P2';
  }

  /**
   * Extract effort from args
   */
  private extractEffort(value: unknown): 'S' | 'M' | 'L' | 'XL' {
    const str = String(value || 'M').toUpperCase();
    if (str.includes('S') || str.includes('SMALL')) return 'S';
    if (str.includes('L') && str.includes('X')) return 'XL';
    if (str.includes('L') || str.includes('LARGE')) return 'L';
    return 'M';
  }

  /**
   * Extract list from args (handles arrays or comma-separated strings)
   */
  private extractList(value: unknown): string[] {
    if (Array.isArray(value)) {
      return value.map((v) => String(v));
    }
    if (typeof value === 'string') {
      return value.split(',').map((s) => s.trim());
    }
    return [];
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new UpdateMemoryHook();
  await hook.run();
}

main();
