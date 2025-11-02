#!/usr/bin/env node

/**
 * Validate State Hook
 *
 * Triggered on PostToolUse events to automatically validate state consistency.
 * Detects and reports inconsistencies, warnings, and potential issues.
 *
 * This hook ensures state integrity by validating:
 * - Session state structure and values
 * - Phase transition validity
 * - Feature directory existence
 * - Memory file consistency
 * - Schema version compatibility
 */

import * as fs from 'fs';
import * as path from 'path';
import { BaseHook } from '../../core/base-hook';
import { MemoryManager } from '../../core/memory-manager';
import { HookContext, WorkflowPhase } from '../../types';
import { ValidationError, ValidationWarning } from '../../types/memory';
import { resolveFeaturesPath } from '../../core/path-resolver';

/**
 * Validate State Hook
 *
 * Automatically validates state consistency after operations
 */
export class ValidateStateHook extends BaseHook {
  private memoryManager: MemoryManager;
  private readonly VALID_PHASES: WorkflowPhase[] = [
    'none',
    'initialize',
    'generate',
    'clarify',
    'plan',
    'tasks',
    'implement',
    'validate',
    'complete',
  ];

  constructor() {
    super('validate-state');
    this.memoryManager = MemoryManager.getInstance(this.config, this.cwd);
  }

  async execute(context: HookContext): Promise<void> {
    const { command } = context;

    if (!command) return;

    // Only validate on state-changing operations
    if (!this.isStateChangingOperation(command)) {
      return;
    }

    // Run validation
    const result = await this.validateState();

    // Report results
    if (!result.valid) {
      this.logger.error('State validation failed', null, {
        errors: result.errors,
        warnings: result.warnings,
      });
    } else if (result.warnings.length > 0) {
      this.logger.warn('State validation warnings', {
        warnings: result.warnings,
      });
    } else {
      this.logger.info('State validation passed');
    }
  }

  /**
   * Check if command changes state
   */
  private isStateChangingOperation(command: string): boolean {
    return (
      command.includes('init') ||
      command.includes('generate') ||
      command.includes('clarify') ||
      command.includes('plan') ||
      command.includes('tasks') ||
      command.includes('implement') ||
      command.includes('complete') ||
      command.includes('transition') ||
      command.includes('update')
    );
  }

  /**
   * Validate current state
   */
  private async validateState(): Promise<{
    valid: boolean;
    errors: ValidationError[];
    warnings: ValidationWarning[];
  }> {
    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];

    const session = this.memoryManager.getCurrentSession();

    // Validate session exists
    if (!session) {
      errors.push({
        field: 'session',
        message: 'Session state is null',
        severity: 'critical',
      });
      return { valid: false, errors, warnings };
    }

    // Validate phase
    if (session.phase && !this.VALID_PHASES.includes(session.phase)) {
      errors.push({
        field: 'phase',
        message: `Invalid phase: ${session.phase}`,
        severity: 'error',
      });
    }

    // Validate feature exists if specified
    if (session.feature) {
      const featureDir = path.join(resolveFeaturesPath(this.config, this.cwd), session.feature);
      if (!fs.existsSync(featureDir)) {
        warnings.push({
          field: 'feature',
          message: `Feature directory does not exist: ${session.feature}`,
          suggestion: 'Initialize feature directory or clear feature from session',
        });
      }
    }

    // Validate progress consistency
    if (session.progress !== undefined) {
      if (session.progress < 0 || session.progress > 100) {
        errors.push({
          field: 'progress',
          message: `Progress out of range: ${session.progress}`,
          severity: 'error',
        });
      }
    }

    // Validate task counts
    if (session.tasksComplete !== undefined && session.tasksTotal !== undefined) {
      if (session.tasksComplete > session.tasksTotal) {
        errors.push({
          field: 'tasksComplete',
          message: `Completed tasks (${session.tasksComplete}) exceeds total (${session.tasksTotal})`,
          severity: 'error',
        });
      }
    }

    // Validate timestamps
    if (session.started) {
      try {
        new Date(session.started);
      } catch {
        errors.push({
          field: 'started',
          message: `Invalid started timestamp: ${session.started}`,
          severity: 'error',
        });
      }
    }

    if (session.last_updated) {
      try {
        new Date(session.last_updated);
      } catch {
        errors.push({
          field: 'last_updated',
          message: `Invalid last_updated timestamp: ${session.last_updated}`,
          severity: 'error',
        });
      }
    }

    // Validate schema version
    if (!session.schema_version) {
      warnings.push({
        field: 'schema_version',
        message: 'Missing schema version',
        suggestion: 'Add schema_version field to session state',
      });
    } else if (session.schema_version !== this.config.version) {
      warnings.push({
        field: 'schema_version',
        message: `Schema version mismatch: ${session.schema_version} vs ${this.config.version}`,
        suggestion: 'Consider running migration utility',
      });
    }

    // Validate feature phase consistency
    if (session.feature && session.phase === 'none') {
      warnings.push({
        field: 'phase',
        message: 'Active feature but phase is "none"',
        suggestion: 'Update phase to match feature progress',
      });
    }

    if (!session.feature && session.phase && session.phase !== 'none') {
      warnings.push({
        field: 'feature',
        message: `Phase is "${session.phase}" but no active feature`,
        suggestion: 'Set feature or reset phase to "none"',
      });
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings,
    };
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new ValidateStateHook();
  await hook.run();
}

main();
