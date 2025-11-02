#!/usr/bin/env node

/**
 * Periodic Snapshot Hook
 *
 * Creates automatic snapshots of session state at key workflow milestones.
 * Implements retention policy to manage snapshot storage.
 *
 * Triggers:
 * - Phase completions (e.g., after planning, before implementation)
 * - Daily automatic snapshots
 * - Manual triggers via command
 */

import { BaseHook } from '../../core/base-hook';
import { MemoryManager } from '../../core/memory-manager';
import { HookContext } from '../../types';

/**
 * Snapshot State Hook
 */
export class SnapshotStateHook extends BaseHook {
  private memoryManager: MemoryManager;
  private readonly RETENTION_DAYS = 30;
  private readonly SNAPSHOT_PHASES = ['generate', 'plan', 'tasks', 'complete'];

  constructor() {
    super('snapshot-state');
    this.memoryManager = MemoryManager.getInstance(this.config, this.cwd);
  }

  async execute(context: HookContext): Promise<void> {
    const { command, args } = context;

    if (!command) return;

    // Check if this is a manual snapshot request
    if (this.isManualSnapshot(command, args as Record<string, unknown>)) {
      await this.createManualSnapshot(args as Record<string, unknown>);
      return;
    }

    // Check if this is a phase completion that warrants a snapshot
    if (this.shouldAutoSnapshot(command)) {
      await this.createAutoSnapshot(command);
    }

    // Cleanup old snapshots (run occasionally)
    if (Math.random() < 0.1) {
      // 10% chance to run cleanup
      await this.cleanupOldSnapshots();
    }
  }

  /**
   * Check if command is a manual snapshot request
   */
  private isManualSnapshot(command: string, args?: Record<string, unknown>): boolean {
    return (
      command.includes('snapshot') ||
      command.includes('checkpoint') ||
      args?.action === 'snapshot'
    );
  }

  /**
   * Check if command should trigger auto-snapshot
   */
  private shouldAutoSnapshot(command: string): boolean {
    return this.SNAPSHOT_PHASES.some((phase) => command.includes(phase));
  }

  /**
   * Create manual snapshot with custom label
   */
  private async createManualSnapshot(args?: Record<string, unknown>): Promise<void> {
    const label = args?.label ? String(args.label) : 'manual';

    try {
      const snapshotId = await this.memoryManager.createSnapshot(label);
      this.logger.success('Manual snapshot created', {
        snapshotId,
        label,
      });
    } catch (error) {
      this.logger.error('Failed to create manual snapshot', error);
    }
  }

  /**
   * Create automatic snapshot at workflow milestone
   */
  private async createAutoSnapshot(_command: string): Promise<void> {
    const session = this.memoryManager.getCurrentSession();
    if (!session || !session.phase) {
      return;
    }

    const label = `auto-${session.phase}`;

    try {
      // Check if we recently created a snapshot for this phase
      const recent = await this.getRecentSnapshotForPhase(session.phase);
      if (recent) {
        const age = Date.now() - new Date(recent.timestamp).getTime();
        const hoursSinceLastSnapshot = age / (1000 * 60 * 60);

        // Skip if snapshot created within last hour
        if (hoursSinceLastSnapshot < 1) {
          this.logger.info('Skipping auto-snapshot (recent snapshot exists)', {
            phase: session.phase,
            hoursSinceLastSnapshot: Math.round(hoursSinceLastSnapshot * 10) / 10,
          });
          return;
        }
      }

      const snapshotId = await this.memoryManager.createSnapshot(label);
      this.logger.success('Auto snapshot created', {
        snapshotId,
        phase: session.phase,
        feature: session.feature,
      });
    } catch (error) {
      this.logger.error('Failed to create auto snapshot', error, {
        phase: session.phase,
      });
    }
  }

  /**
   * Get most recent snapshot for a specific phase
   */
  private async getRecentSnapshotForPhase(phase: string) {
    const snapshots = await this.memoryManager.listSnapshots();
    const phaseLabel = `auto-${phase}`;

    return snapshots.find((s) => s.label === phaseLabel);
  }

  /**
   * Clean up snapshots older than retention period
   */
  private async cleanupOldSnapshots(): Promise<void> {
    try {
      const deleted = await this.memoryManager.deleteOldSnapshots(this.RETENTION_DAYS);

      if (deleted > 0) {
        this.logger.info('Cleaned up old snapshots', {
          deleted,
          retentionDays: this.RETENTION_DAYS,
        });
      }
    } catch (error) {
      this.logger.error('Failed to cleanup old snapshots', error);
    }
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new SnapshotStateHook();
  await hook.run();
}

main();
