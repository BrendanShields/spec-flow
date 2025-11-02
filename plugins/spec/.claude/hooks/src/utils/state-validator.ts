/**
 * State Validator
 *
 * JSON Schema-based validation for SessionState and related structures.
 * Provides strict validation rules with detailed error reporting.
 */

import { SessionState, WorkflowPhase, ValidationResult, ValidationError, ValidationWarning } from '../types/memory';
import { SpecConfig } from '../types';

/**
 * JSON Schema for SessionState
 */
const SESSION_STATE_SCHEMA = {
  type: 'object',
  required: ['last_updated', 'schema_version'],
  properties: {
    feature: {
      type: ['string', 'null'],
      pattern: '^[0-9]{3}-[a-z0-9-]+$',
      description: 'Feature ID in format: 001-feature-name',
    },
    phase: {
      type: ['string', 'null'],
      enum: ['none', 'initialize', 'generate', 'clarify', 'plan', 'tasks', 'implement', 'validate', 'complete', null],
      description: 'Current workflow phase',
    },
    started: {
      type: ['string', 'null'],
      format: 'date-time',
      description: 'ISO 8601 timestamp when session started',
    },
    last_updated: {
      type: 'string',
      format: 'date-time',
      description: 'ISO 8601 timestamp of last update',
    },
    schema_version: {
      type: 'string',
      pattern: '^\\d+\\.\\d+\\.\\d+$',
      description: 'Schema version (semver)',
    },
    progress: {
      type: 'number',
      minimum: 0,
      maximum: 100,
      description: 'Overall progress percentage',
    },
    tasksComplete: {
      type: 'number',
      minimum: 0,
      description: 'Completed tasks count',
    },
    tasksTotal: {
      type: 'number',
      minimum: 0,
      description: 'Total tasks count',
    },
  },
};

/**
 * State Validator
 */
export class StateValidator {
  private config: SpecConfig;

  constructor(config: SpecConfig) {
    this.config = config;
  }

  /**
   * Validate session state against schema
   */
  public validateSessionState(state: SessionState): ValidationResult {
    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];

    // Required fields validation
    if (!state.last_updated) {
      errors.push({
        field: 'last_updated',
        message: 'Missing required field: last_updated',
        severity: 'critical',
      });
    }

    if (!state.schema_version) {
      errors.push({
        field: 'schema_version',
        message: 'Missing required field: schema_version',
        severity: 'critical',
      });
    }

    // Feature ID format validation
    if (state.feature && !this.isValidFeatureId(state.feature)) {
      errors.push({
        field: 'feature',
        message: `Invalid feature ID format: ${state.feature}. Expected: 001-feature-name`,
        severity: 'error',
      });
    }

    // Phase validation
    if (state.phase && !this.isValidPhase(state.phase)) {
      errors.push({
        field: 'phase',
        message: `Invalid phase: ${state.phase}`,
        severity: 'error',
      });
    }

    // Timestamp validation
    if (state.started && !this.isValidTimestamp(state.started)) {
      errors.push({
        field: 'started',
        message: `Invalid started timestamp: ${state.started}`,
        severity: 'error',
      });
    }

    if (state.last_updated && !this.isValidTimestamp(state.last_updated)) {
      errors.push({
        field: 'last_updated',
        message: `Invalid last_updated timestamp: ${state.last_updated}`,
        severity: 'error',
      });
    }

    // Schema version validation
    if (state.schema_version && !this.isValidSemver(state.schema_version)) {
      errors.push({
        field: 'schema_version',
        message: `Invalid semver format: ${state.schema_version}`,
        severity: 'error',
      });
    }

    // Progress validation
    if (state.progress !== undefined) {
      if (state.progress < 0 || state.progress > 100) {
        errors.push({
          field: 'progress',
          message: `Progress out of range [0-100]: ${state.progress}`,
          severity: 'error',
        });
      }
    }

    // Task counts validation
    if (state.tasksComplete !== undefined && state.tasksComplete < 0) {
      errors.push({
        field: 'tasksComplete',
        message: `tasksComplete cannot be negative: ${state.tasksComplete}`,
        severity: 'error',
      });
    }

    if (state.tasksTotal !== undefined && state.tasksTotal < 0) {
      errors.push({
        field: 'tasksTotal',
        message: `tasksTotal cannot be negative: ${state.tasksTotal}`,
        severity: 'error',
      });
    }

    if (
      state.tasksComplete !== undefined &&
      state.tasksTotal !== undefined &&
      state.tasksComplete > state.tasksTotal
    ) {
      errors.push({
        field: 'tasksComplete',
        message: `tasksComplete (${state.tasksComplete}) exceeds tasksTotal (${state.tasksTotal})`,
        severity: 'error',
      });
    }

    // Cross-field validation warnings
    if (state.feature && state.phase === 'none') {
      warnings.push({
        field: 'phase',
        message: 'Active feature but phase is "none"',
        suggestion: 'Update phase to reflect feature progress',
      });
    }

    if (!state.feature && state.phase && state.phase !== 'none') {
      warnings.push({
        field: 'feature',
        message: `Phase is "${state.phase}" but no active feature`,
        suggestion: 'Set feature or reset phase to "none"',
      });
    }

    if (state.started && state.last_updated) {
      const started = new Date(state.started).getTime();
      const updated = new Date(state.last_updated).getTime();

      if (updated < started) {
        warnings.push({
          field: 'last_updated',
          message: 'last_updated is before started timestamp',
          suggestion: 'Ensure timestamps are in chronological order',
        });
      }
    }

    if (state.schema_version && state.schema_version !== this.config.version) {
      warnings.push({
        field: 'schema_version',
        message: `Schema version mismatch: state=${state.schema_version}, config=${this.config.version}`,
        suggestion: 'Consider running migration to update schema',
      });
    }

    // Progress/phase consistency
    if (state.phase && state.progress !== undefined) {
      const expectedProgress = this.getExpectedProgress(state.phase);
      const diff = Math.abs(state.progress - expectedProgress);

      if (diff > 15) {
        warnings.push({
          field: 'progress',
          message: `Progress ${state.progress}% inconsistent with phase "${state.phase}" (expected ~${expectedProgress}%)`,
          suggestion: 'Verify progress calculation or phase transition',
        });
      }
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings,
    };
  }

  /**
   * Validate feature ID format
   */
  private isValidFeatureId(featureId: string): boolean {
    // Format: 001-feature-name or 000-slug
    const pattern = /^[0-9]{3}-[a-z0-9-]+$/;
    return pattern.test(featureId);
  }

  /**
   * Validate workflow phase
   */
  private isValidPhase(phase: string): phase is WorkflowPhase {
    const validPhases: WorkflowPhase[] = [
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
    return validPhases.includes(phase as WorkflowPhase);
  }

  /**
   * Validate ISO 8601 timestamp
   */
  private isValidTimestamp(timestamp: string): boolean {
    try {
      const date = new Date(timestamp);
      return !isNaN(date.getTime()) && date.toISOString() === timestamp;
    } catch {
      return false;
    }
  }

  /**
   * Validate semver format
   */
  private isValidSemver(version: string): boolean {
    const pattern = /^\d+\.\d+\.\d+$/;
    return pattern.test(version);
  }

  /**
   * Get expected progress for phase
   */
  private getExpectedProgress(phase: WorkflowPhase): number {
    const phaseProgress: Record<WorkflowPhase, number> = {
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

    return phaseProgress[phase] || 0;
  }

  /**
   * Get JSON Schema for SessionState
   */
  public getSchema(): typeof SESSION_STATE_SCHEMA {
    return SESSION_STATE_SCHEMA;
  }
}

/**
 * Create state validator instance
 */
export function createStateValidator(config: SpecConfig): StateValidator {
  return new StateValidator(config);
}
