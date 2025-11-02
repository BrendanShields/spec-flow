/**
 * Memory Manager - Centralized State Coordination
 *
 * Singleton class that coordinates all state operations across the Spec workflow system.
 * Ensures atomic transactions, validation, and consistent state updates.
 */

import * as fs from 'fs';
import * as path from 'path';
import { SpecConfig } from '../types/config';
import {
  SessionState,
  WorkflowPhase,
  ProgressEntry,
  DecisionRecord,
  PlannedChange,
  ChangeCompletion,
  PhaseStats,
  StateSnapshot,
  ValidationResult,
  Inconsistency,
  RepairReport,
} from '../types/memory';
import { Transaction, FileOperation } from '../types/transaction';
import { createScopedLogger } from './logger';
import { resolveStateFile, resolveStatePath, resolveFeaturesPath, resolveMemoryFile } from './path-resolver';
import { loadYAML, toYAML } from '../utils/yaml-utils';
import { FileTransactionManager } from '../utils/file-transaction';
import { StateValidator } from '../utils/state-validator';
import { StateHistoryLogger } from '../utils/state-history';
import { SessionMetricsAggregator } from '../utils/session-metrics';

/**
 * MemoryManager singleton class
 *
 * Coordinates all state operations with caching, validation, and atomic transactions.
 */
export class MemoryManager {
  private static instance: MemoryManager | null = null;
  private readonly logger: ReturnType<typeof createScopedLogger>;
  private sessionCache: SessionState | null = null;
  private transactionLog: Transaction[] = [];
  private fileTransactionManager: FileTransactionManager;
  private stateValidator: StateValidator;
  private historyLogger: StateHistoryLogger;
  private metricsAggregator: SessionMetricsAggregator;

  /**
   * Private constructor (use getInstance())
   */
  private constructor(
    private readonly config: SpecConfig,
    private readonly cwd: string // eslint-disable-line @typescript-eslint/no-unused-vars
  ) {
    this.logger = createScopedLogger('memory-manager');

    // Initialize file transaction manager
    const statePath = resolveStatePath(this.config, this.cwd);
    this.fileTransactionManager = new FileTransactionManager(statePath);

    // Initialize state validator
    this.stateValidator = new StateValidator(this.config);

    // Initialize state history logger
    const historyFile = path.join(statePath, '.history', 'state-changes.log');
    this.historyLogger = new StateHistoryLogger(historyFile);

    // Initialize metrics aggregator
    this.metricsAggregator = new SessionMetricsAggregator(this.historyLogger);

    this.logger.info('MemoryManager initialized', { cwd: this.cwd });
  }

  /**
   * Get or create the MemoryManager singleton instance
   *
   * @param config - Spec configuration
   * @param cwd - Current working directory
   * @returns MemoryManager instance
   */
  public static getInstance(config: SpecConfig, cwd: string): MemoryManager {
    if (!MemoryManager.instance) {
      MemoryManager.instance = new MemoryManager(config, cwd);
    }
    return MemoryManager.instance;
  }

  /**
   * Reset the singleton instance (for testing only)
   *
   * @internal
   */
  public static resetInstance(): void {
    MemoryManager.instance = null;
  }

  // ============================================================================
  // Session Management
  // ============================================================================

  /**
   * Get current session state (from cache if available)
   *
   * @returns Current session state or null if not initialized
   */
  public getCurrentSession(): SessionState | null {
    if (this.sessionCache) {
      this.logger.info('Returning cached session state');
      return this.sessionCache;
    }

    this.logger.info('No cached session state available');
    return null;
  }

  /**
   * Update session state with partial updates
   *
   * Merges provided updates into current session state and persists atomically.
   *
   * @param updates - Partial session state to merge
   * @returns Promise that resolves when update completes
   */
  public async updateSession(updates: Partial<SessionState>): Promise<void> {
    this.logger.info('Updating session state', { updates });

    // Get current state or create new one
    const currentState = this.sessionCache || this.createDefaultSessionState();

    // Merge updates
    const newState: SessionState = {
      ...currentState,
      ...updates,
      last_updated: new Date().toISOString(),
    };

    // Validate before updating
    const validation = this.stateValidator.validateSessionState(newState);
    if (!validation.valid) {
      const errorMessages = validation.errors.map((e) => e.message).join(', ');
      throw new Error(`Invalid session state: ${errorMessages}`);
    }

    // Log warnings if any
    if (validation.warnings.length > 0) {
      this.logger.warn('Session state has warnings', {
        warnings: validation.warnings.map((w) => w.message),
      });
    }

    // Log state change to history
    await this.historyLogger.logUpdate(currentState, newState);

    // Update cache
    this.sessionCache = newState;

    this.logger.info('Session state updated in cache');

    // Persist to disk
    await this.persistSession(newState);
  }

  /**
   * Save current session state to disk
   *
   * @returns Promise that resolves when save completes
   */
  public async saveSession(): Promise<void> {
    if (!this.sessionCache) {
      this.logger.warn('No session state to save');
      return;
    }

    this.logger.info('Saving session state');

    await this.persistSession(this.sessionCache);

    this.logger.info('Session state saved successfully');
  }

  /**
   * Restore session state from disk
   *
   * @returns Promise resolving to restored session state or null
   */
  public async restoreSession(): Promise<SessionState | null> {
    this.logger.info('Restoring session state');

    try {
      const sessionPath = resolveStateFile(this.config, 'current-session.md', this.cwd);

      if (!fs.existsSync(sessionPath)) {
        this.logger.info('No session file found');
        return null;
      }

      const state = await this.readSessionFile(sessionPath);

      // Validate restored state
      const validation = this.stateValidator.validateSessionState(state);
      if (!validation.valid) {
        this.logger.error('Restored session state is invalid', {
          errors: validation.errors,
        });

        // Attempt auto-repair
        this.logger.info('Attempting to repair restored session');
        const repairResult = await this.repairState(true);

        if (repairResult.success) {
          this.logger.info('Session state repaired successfully', {
            repairs: repairResult.repairs.length,
          });

          // Reload after repair
          const repairedState = await this.readSessionFile(sessionPath);
          this.sessionCache = repairedState;
          return repairedState;
        } else {
          this.logger.error('Failed to repair session state', {
            errors: repairResult.errors,
          });
          return null;
        }
      }

      // Log validation warnings if any
      if (validation.warnings.length > 0) {
        this.logger.warn('Restored session has warnings', {
          warnings: validation.warnings.map((w) => w.message),
        });
      }

      // Check for inconsistencies
      this.sessionCache = state;
      const inconsistencies = await this.detectInconsistencies();

      if (inconsistencies.length > 0) {
        this.logger.warn('Detected inconsistencies in restored session', {
          count: inconsistencies.length,
          types: inconsistencies.map((i) => i.type),
        });

        // Log each inconsistency
        for (const inconsistency of inconsistencies) {
          this.logger.warn(`Inconsistency: ${inconsistency.type}`, {
            message: inconsistency.message,
            suggestion: inconsistency.suggestion,
          });
        }
      }

      // Calculate session duration if available
      let sessionDuration: number | undefined;
      if (state.started) {
        const duration = Date.now() - new Date(state.started).getTime();
        const hours = Math.floor(duration / (1000 * 60 * 60));
        sessionDuration = hours;
        this.logger.info('Session duration', { hours: hours || '<1' });
      }

      // Log restoration to history
      await this.historyLogger.logRestore(state, {
        hasWarnings: validation.warnings.length > 0,
        hasInconsistencies: inconsistencies.length > 0,
        sessionDuration,
      });

      this.logger.info('Session restored from disk', {
        feature: state.feature,
        phase: state.phase,
        progress: state.progress,
        hasWarnings: validation.warnings.length > 0,
        hasInconsistencies: inconsistencies.length > 0,
      });

      return state;
    } catch (error) {
      this.logger.error('Failed to restore session', error);
      return null;
    }
  }

  // ============================================================================
  // Phase Transitions
  // ============================================================================

  /**
   * Transition workflow phase with validation
   *
   * @param from - Current phase
   * @param to - Target phase
   * @param metadata - Optional metadata for transition
   * @returns Promise that resolves when transition completes
   */
  public async transitionPhase(
    from: WorkflowPhase,
    to: WorkflowPhase,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    this.logger.info('Transitioning phase', { from, to, metadata });

    // Validate transition
    if (!this.isValidTransition(from, to)) {
      const error = `Invalid phase transition: ${from} → ${to}`;
      this.logger.error(error);
      throw new Error(error);
    }

    // Get current state for history logging
    const beforeState = this.getCurrentSession() || this.createDefaultSessionState();

    // Prepare update with transition metadata
    const updates: Partial<SessionState> = {
      phase: to,
      last_updated: new Date().toISOString(),
    };

    // If starting a new phase from 'none', initialize started timestamp
    if (from === 'none' && to !== 'none') {
      updates.started = new Date().toISOString();
    }

    // Update progress percentage based on phase
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
    updates.progress = phaseProgress[to];

    // Update session with transition
    await this.updateSession(updates);

    // Log transition to history
    const afterState = this.getCurrentSession() || this.createDefaultSessionState();
    await this.historyLogger.logTransition(from, to, beforeState, afterState, metadata);

    // Log transition metadata if provided
    if (metadata) {
      this.logger.info('Phase transition metadata', metadata);
    }

    this.logger.info('Phase transition complete', { from, to, progress: updates.progress });
  }

  /**
   * Record phase completion with statistics
   *
   * @param phase - Phase that completed
   * @param stats - Phase statistics
   * @returns Promise that resolves when recording completes
   */
  public async recordPhaseCompletion(
    phase: WorkflowPhase,
    stats: PhaseStats
  ): Promise<void> {
    this.logger.info('Recording phase completion', { phase, stats });

    // Get current session
    const session = this.sessionCache;
    if (!session || !session.feature) {
      this.logger.warn('No active feature for phase completion');
      return;
    }

    // Create progress entry
    const progressEntry: ProgressEntry = {
      feature: session.feature,
      featureName: session.feature, // Will be enhanced with actual name later
      phase,
      progress: session.progress || 0,
      timestamp: new Date().toISOString(),
      completedTasks: stats.tasksCompleted,
      notes: `Phase ${phase} completed in ${this.formatDuration(stats.duration)}`,
    };

    // Append to workflow progress (will be implemented in T007)
    await this.appendWorkflowProgress(progressEntry);

    this.logger.info('Phase completion recorded', { phase, duration: stats.duration });
  }

  /**
   * Format duration in milliseconds to human-readable string
   */
  private formatDuration(ms: number): string {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }

  // ============================================================================
  // Memory File Operations (Append-only)
  // ============================================================================

  /**
   * Append entry to WORKFLOW-PROGRESS.md
   *
   * @param entry - Progress entry to append
   * @returns Promise that resolves when append completes
   */
  public async appendWorkflowProgress(entry: ProgressEntry): Promise<void> {
    this.logger.info('Appending workflow progress', { entry });

    const progressFile = resolveMemoryFile(this.config, 'WORKFLOW-PROGRESS.md', this.cwd);
    const content = this.formatProgressEntry(entry);

    await this.appendToFile(progressFile, content);

    this.logger.info('Workflow progress appended', { feature: entry.feature });
  }

  /**
   * Append ADR to DECISIONS-LOG.md
   *
   * @param adr - Decision record to append
   * @returns Promise that resolves when append completes
   */
  public async appendDecisionLog(adr: DecisionRecord): Promise<void> {
    this.logger.info('Appending decision log', { adr });

    const decisionFile = resolveMemoryFile(this.config, 'DECISIONS-LOG.md', this.cwd);
    const content = this.formatDecisionRecord(adr);

    await this.appendToFile(decisionFile, content);

    this.logger.info('Decision log appended', { adrId: adr.id });
  }

  /**
   * Append planned change to CHANGES-PLANNED.md
   *
   * @param change - Planned change to append
   * @returns Promise that resolves when append completes
   */
  public async appendPlannedChange(change: PlannedChange): Promise<void> {
    this.logger.info('Appending planned change', { change });

    const plannedFile = resolveMemoryFile(this.config, 'CHANGES-PLANNED.md', this.cwd);
    const content = this.formatPlannedChange(change);

    await this.appendToFile(plannedFile, content);

    this.logger.info('Planned change appended', { changeId: change.id });
  }

  /**
   * Mark change as completed and move to CHANGES-COMPLETED.md
   *
   * @param changeId - Change ID to mark complete
   * @param completion - Completion details
   * @returns Promise that resolves when operation completes
   */
  public async markChangeCompleted(
    changeId: string,
    completion: ChangeCompletion
  ): Promise<void> {
    this.logger.info('Marking change completed', { changeId, completion });

    const completedFile = resolveMemoryFile(this.config, 'CHANGES-COMPLETED.md', this.cwd);
    const content = this.formatChangeCompletion(completion);

    // Append to CHANGES-COMPLETED.md
    await this.appendToFile(completedFile, content);

    // TODO: Remove from CHANGES-PLANNED.md (requires parsing and rewriting)
    // For now, we'll leave it in CHANGES-PLANNED and rely on the ID reference

    this.logger.info('Change marked completed', { changeId });
  }

  // ============================================================================
  // State Snapshots
  // ============================================================================

  /**
   * Create state snapshot with optional label
   *
   * @param label - Optional label for snapshot (e.g., "post-planning")
   * @returns Promise resolving to snapshot ID
   */
  public async createSnapshot(label?: string): Promise<string> {
    this.logger.info('Creating state snapshot', { label });

    const snapshotId = this.generateUUID();
    const timestamp = new Date().toISOString();
    const state = this.getCurrentSession();

    if (!state) {
      throw new Error('Cannot create snapshot: no active session');
    }

    // Create snapshot directory
    const statePath = resolveStatePath(this.config, this.cwd);
    const snapshotsDir = path.join(statePath, '.snapshots');
    if (!fs.existsSync(snapshotsDir)) {
      fs.mkdirSync(snapshotsDir, { recursive: true });
    }

    // Create snapshot object
    const snapshot: StateSnapshot = {
      id: snapshotId,
      timestamp,
      label,
      state,
      files: await this.hashRelevantFiles(),
    };

    // Write snapshot
    const snapshotFile = path.join(snapshotsDir, `${snapshotId}.json`);
    fs.writeFileSync(snapshotFile, JSON.stringify(snapshot, null, 2), 'utf8');

    this.logger.info('State snapshot created', {
      snapshotId,
      label,
      filesHashed: snapshot.files.length,
    });

    return snapshotId;
  }

  /**
   * List all available snapshots
   *
   * @returns Promise resolving to array of snapshots
   */
  public async listSnapshots(): Promise<StateSnapshot[]> {
    this.logger.info('Listing snapshots');

    const statePath = resolveStatePath(this.config, this.cwd);
    const snapshotsDir = path.join(statePath, '.snapshots');

    if (!fs.existsSync(snapshotsDir)) {
      return [];
    }

    const files = fs.readdirSync(snapshotsDir).filter((f) => f.endsWith('.json'));
    const snapshots: StateSnapshot[] = [];

    for (const file of files) {
      try {
        const content = fs.readFileSync(path.join(snapshotsDir, file), 'utf8');
        const snapshot = JSON.parse(content) as StateSnapshot;
        snapshots.push(snapshot);
      } catch (error) {
        this.logger.warn('Failed to read snapshot', { file, error });
      }
    }

    // Sort by timestamp, newest first
    snapshots.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

    return snapshots;
  }

  /**
   * Restore state from snapshot
   *
   * @param snapshotId - Snapshot ID to restore
   * @returns Promise that resolves when restore completes
   */
  public async restoreSnapshot(snapshotId: string): Promise<void> {
    this.logger.info('Restoring snapshot', { snapshotId });

    const statePath = resolveStatePath(this.config, this.cwd);
    const snapshotFile = path.join(statePath, '.snapshots', `${snapshotId}.json`);

    if (!fs.existsSync(snapshotFile)) {
      throw new Error(`Snapshot not found: ${snapshotId}`);
    }

    // Read snapshot
    const content = fs.readFileSync(snapshotFile, 'utf8');
    const snapshot = JSON.parse(content) as StateSnapshot;

    // Create backup before restore
    const beforeState = this.getCurrentSession();
    if (beforeState) {
      await this.createBackup('pre-restore');
    }

    // Restore state
    this.sessionCache = snapshot.state;
    await this.persistSession(snapshot.state);

    // Log to history
    await this.historyLogger.logChange('restore', beforeState || {}, snapshot.state, {
      snapshotId,
      snapshotLabel: snapshot.label,
    });

    this.logger.info('Snapshot restored', {
      snapshotId,
      label: snapshot.label,
      timestamp: snapshot.timestamp,
    });
  }

  /**
   * Delete snapshots older than retention period
   *
   * @param retentionDays - Days to retain snapshots
   * @returns Promise resolving to count of deleted snapshots
   */
  public async deleteOldSnapshots(retentionDays: number): Promise<number> {
    this.logger.info('Deleting old snapshots', { retentionDays });

    const statePath = resolveStatePath(this.config, this.cwd);
    const snapshotsDir = path.join(statePath, '.snapshots');

    if (!fs.existsSync(snapshotsDir)) {
      return 0;
    }

    const now = Date.now();
    const retentionMs = retentionDays * 24 * 60 * 60 * 1000;
    const files = fs.readdirSync(snapshotsDir).filter((f) => f.endsWith('.json'));

    let deletedCount = 0;

    for (const file of files) {
      try {
        const filePath = path.join(snapshotsDir, file);
        const content = fs.readFileSync(filePath, 'utf8');
        const snapshot = JSON.parse(content) as StateSnapshot;
        const age = now - new Date(snapshot.timestamp).getTime();

        if (age > retentionMs) {
          fs.unlinkSync(filePath);
          deletedCount++;
          this.logger.info('Deleted old snapshot', {
            id: snapshot.id,
            label: snapshot.label,
            age: Math.floor(age / (24 * 60 * 60 * 1000)) + ' days',
          });
        }
      } catch (error) {
        this.logger.warn('Failed to process snapshot', { file, error });
      }
    }

    this.logger.info('Old snapshots deleted', { count: deletedCount });
    return deletedCount;
  }

  /**
   * Hash relevant files for snapshot integrity
   */
  private async hashRelevantFiles(): Promise<StateSnapshot['files']> {
    const crypto = await import('crypto');
    const files: StateSnapshot['files'] = [];

    // Hash session file
    const sessionFile = resolveStateFile(this.config, 'current-session.md', this.cwd);
    if (fs.existsSync(sessionFile)) {
      const content = fs.readFileSync(sessionFile);
      const hash = crypto.createHash('sha256').update(content).digest('hex');
      files.push({ path: 'current-session.md', hash });
    }

    // Hash memory files
    const memoryFiles = ['WORKFLOW-PROGRESS.md', 'DECISIONS-LOG.md', 'CHANGES-PLANNED.md', 'CHANGES-COMPLETED.md'];
    for (const file of memoryFiles) {
      const filePath = resolveMemoryFile(this.config, file, this.cwd);
      if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath);
        const hash = crypto.createHash('sha256').update(content).digest('hex');
        files.push({ path: file, hash });
      }
    }

    return files;
  }

  // ============================================================================
  // Validation & Recovery
  // ============================================================================

  /**
   * Validate current state against schema
   *
   * @returns Promise resolving to validation result
   */
  public async validateState(): Promise<ValidationResult> {
    this.logger.info('Validating state');

    const session = this.getCurrentSession();

    if (!session) {
      return {
        valid: false,
        errors: [
          {
            field: 'session',
            message: 'Session state is null',
            severity: 'critical',
          },
        ],
        warnings: [],
      };
    }

    return this.stateValidator.validateSessionState(session);
  }

  /**
   * Detect inconsistencies across state and memory files
   *
   * @returns Promise resolving to array of inconsistencies
   */
  public async detectInconsistencies(): Promise<Inconsistency[]> {
    this.logger.info('Detecting inconsistencies');

    const inconsistencies: Inconsistency[] = [];
    const session = this.getCurrentSession();

    if (!session) {
      inconsistencies.push({
        type: 'missing_feature',
        severity: 'critical',
        message: 'Session state is null',
      });
      return inconsistencies;
    }

    // Check for orphaned state (feature directory deleted but session active)
    if (session.feature) {
      const featureDir = path.join(
        resolveFeaturesPath(this.config, this.cwd),
        session.feature
      );

      if (!fs.existsSync(featureDir)) {
        inconsistencies.push({
          type: 'orphaned_state',
          severity: 'error',
          message: `Active feature "${session.feature}" directory not found`,
          field: 'feature',
          suggestion: 'Clear session state or recreate feature directory',
        });
      }
    }

    // Check for invalid phase
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

    if (session.phase && !validPhases.includes(session.phase)) {
      inconsistencies.push({
        type: 'invalid_phase',
        severity: 'error',
        message: `Invalid phase "${session.phase}"`,
        field: 'phase',
        suggestion: `Must be one of: ${validPhases.join(', ')}`,
      });
    }

    // Check timestamp consistency
    if (session.started && session.last_updated) {
      try {
        const started = new Date(session.started).getTime();
        const updated = new Date(session.last_updated).getTime();

        if (updated < started) {
          inconsistencies.push({
            type: 'timestamp_mismatch',
            severity: 'warning',
            message: 'last_updated is before started timestamp',
            field: 'last_updated',
            suggestion: 'Update last_updated to be after started',
          });
        }
      } catch {
        inconsistencies.push({
          type: 'timestamp_mismatch',
          severity: 'error',
          message: 'Invalid timestamp format',
          suggestion: 'Ensure timestamps are valid ISO 8601 strings',
        });
      }
    }

    // Check schema version
    if (session.schema_version && session.schema_version !== this.config.version) {
      inconsistencies.push({
        type: 'schema_mismatch',
        severity: 'warning',
        message: `Schema version ${session.schema_version} does not match config version ${this.config.version}`,
        field: 'schema_version',
        suggestion: 'Run migration utility to update schema',
      });
    }

    // Check feature/phase consistency
    if (session.feature && session.phase === 'none') {
      inconsistencies.push({
        type: 'invalid_phase',
        severity: 'warning',
        message: 'Active feature but phase is "none"',
        field: 'phase',
        suggestion: 'Update phase to match feature progress',
      });
    }

    if (!session.feature && session.phase && session.phase !== 'none') {
      inconsistencies.push({
        type: 'missing_feature',
        severity: 'warning',
        message: `Phase is "${session.phase}" but no active feature`,
        field: 'feature',
        suggestion: 'Set feature or reset phase to "none"',
      });
    }

    return inconsistencies;
  }

  /**
   * Repair state automatically where possible
   *
   * @param autoFix - Whether to automatically apply fixes
   * @returns Promise resolving to repair report
   */
  public async repairState(autoFix = false): Promise<RepairReport> {
    this.logger.info('Repairing state', { autoFix });

    const repairs: RepairReport['repairs'] = [];
    const errors: string[] = [];
    let backupPath: string | undefined;

    try {
      // Create backup before repairs
      if (autoFix) {
        const session = this.getCurrentSession();
        if (session) {
          backupPath = await this.createBackup('pre-repair');
          this.logger.info('Created backup before repair', { backupPath });
        }
      }

      // Detect all inconsistencies
      const inconsistencies = await this.detectInconsistencies();

      if (inconsistencies.length === 0) {
        this.logger.info('No inconsistencies detected');
        return {
          success: true,
          repairs: [
            {
              issue: 'State validation',
              action: 'Validated state - no issues found',
              result: 'fixed',
            },
          ],
          errors: [],
        };
      }

      this.logger.info(`Found ${inconsistencies.length} inconsistencies`, {
        inconsistencies: inconsistencies.map((i) => i.type),
      });

      // Process each inconsistency
      for (const inconsistency of inconsistencies) {
        const repair = await this.repairInconsistency(inconsistency, autoFix);
        repairs.push(repair);

        if (repair.result === 'failed') {
          errors.push(`Failed to repair ${inconsistency.type}: ${inconsistency.message}`);
        }
      }

      // Validate after repairs
      if (autoFix && errors.length === 0) {
        const validation = await this.validateState();
        if (!validation.valid) {
          errors.push('State still invalid after repairs');
          this.logger.warn('State validation failed after repairs', {
            errors: validation.errors,
          });
        }
      }

      const success = errors.length === 0;
      this.logger.info('State repair complete', {
        success,
        repairCount: repairs.length,
        errorCount: errors.length,
      });

      return {
        success,
        repairs,
        errors,
        backupPath,
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error('State repair failed', error);

      return {
        success: false,
        repairs,
        errors: [...errors, errorMessage],
        backupPath,
      };
    }
  }

  /**
   * Repair a single inconsistency
   */
  private async repairInconsistency(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = `${inconsistency.type}: ${inconsistency.message}`;

    // Skip auto-fix for critical issues
    if (inconsistency.severity === 'critical' && !autoFix) {
      return {
        issue,
        action: 'Manual intervention required',
        result: 'skipped',
      };
    }

    try {
      switch (inconsistency.type) {
        case 'orphaned_state':
          return await this.repairOrphanedState(inconsistency, autoFix);

        case 'invalid_phase':
          return await this.repairInvalidPhase(inconsistency, autoFix);

        case 'timestamp_mismatch':
          return await this.repairTimestampMismatch(inconsistency, autoFix);

        case 'schema_mismatch':
          return await this.repairSchemaMismatch(inconsistency, autoFix);

        case 'missing_feature':
          return await this.repairMissingFeature(inconsistency, autoFix);

        default:
          return {
            issue,
            action: 'Unknown inconsistency type',
            result: 'skipped',
          };
      }
    } catch (error) {
      this.logger.error('Failed to repair inconsistency', error, {
        type: inconsistency.type,
      });

      return {
        issue,
        action: `Attempted repair: ${error instanceof Error ? error.message : String(error)}`,
        result: 'failed',
      };
    }
  }

  /**
   * Repair orphaned state (missing feature directory)
   */
  private async repairOrphanedState(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = inconsistency.message;

    if (!autoFix) {
      return {
        issue,
        action: 'Would clear orphaned feature from session',
        result: 'skipped',
      };
    }

    await this.updateSession({ feature: null, phase: 'none' });

    return {
      issue,
      action: 'Cleared orphaned feature from session',
      result: 'fixed',
    };
  }

  /**
   * Repair invalid phase
   */
  private async repairInvalidPhase(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = inconsistency.message;

    if (!autoFix) {
      return {
        issue,
        action: 'Would reset phase to "none"',
        result: 'skipped',
      };
    }

    await this.updateSession({ phase: 'none' });

    return {
      issue,
      action: 'Reset phase to "none"',
      result: 'fixed',
    };
  }

  /**
   * Repair timestamp mismatch
   */
  private async repairTimestampMismatch(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = inconsistency.message;

    if (!autoFix) {
      return {
        issue,
        action: 'Would update last_updated timestamp',
        result: 'skipped',
      };
    }

    await this.updateSession({ last_updated: new Date().toISOString() });

    return {
      issue,
      action: 'Updated last_updated timestamp to current time',
      result: 'fixed',
    };
  }

  /**
   * Repair schema mismatch
   */
  private async repairSchemaMismatch(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = inconsistency.message;

    if (!autoFix) {
      return {
        issue,
        action: 'Would update schema_version to current',
        result: 'skipped',
      };
    }

    await this.updateSession({ schema_version: this.config.version });

    return {
      issue,
      action: `Updated schema_version to ${this.config.version}`,
      result: 'fixed',
    };
  }

  /**
   * Repair missing feature
   */
  private async repairMissingFeature(
    inconsistency: Inconsistency,
    autoFix: boolean
  ): Promise<RepairReport['repairs'][0]> {
    const issue = inconsistency.message;

    if (!autoFix) {
      return {
        issue,
        action: 'Would reset phase to "none"',
        result: 'skipped',
      };
    }

    await this.updateSession({ phase: 'none' });

    return {
      issue,
      action: 'Reset phase to "none" (no active feature)',
      result: 'fixed',
    };
  }

  /**
   * Create backup of current session
   */
  private async createBackup(label: string): Promise<string> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupFilename = `current-session.${label}.${timestamp}.backup`;
    const statePath = resolveStatePath(this.config, this.cwd);
    const backupPath = path.join(statePath, '.backups', backupFilename);

    // Ensure backup directory exists
    const backupDir = path.dirname(backupPath);
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }

    // Copy current session file
    const sessionFile = resolveStateFile(this.config, 'current-session.md', this.cwd);
    if (fs.existsSync(sessionFile)) {
      fs.copyFileSync(sessionFile, backupPath);
      this.logger.info('Created backup', { backupPath });
    }

    return backupPath;
  }

  /**
   * Get state history
   *
   * @param limit - Maximum number of entries to return
   * @returns Promise resolving to history entries
   */
  public async getStateHistory(limit = 50) {
    return this.historyLogger.getRecentHistory(limit);
  }

  /**
   * Get state history statistics
   *
   * @returns Promise resolving to statistics
   */
  public async getHistoryStatistics() {
    return this.historyLogger.getStatistics();
  }

  /**
   * Get comprehensive session metrics
   *
   * @returns Promise resolving to session metrics
   */
  public async getSessionMetrics() {
    return this.metricsAggregator.calculateMetrics();
  }

  /**
   * Get velocity metrics for specified period
   *
   * @param period - Time period ('day', 'week', 'month')
   * @returns Promise resolving to velocity metrics
   */
  public async getVelocityMetrics(period: 'day' | 'week' | 'month' = 'week') {
    return this.metricsAggregator.calculateVelocity(period);
  }

  // ============================================================================
  // Transactions (Advanced)
  // ============================================================================

  /**
   * Begin a new transaction
   *
   * @returns Transaction object
   */
  public beginTransaction(): Transaction {
    const transaction: Transaction = {
      id: this.generateUUID(),
      timestamp: new Date().toISOString(),
      operation: 'update_session',
      files: [],
      status: 'pending',
    };

    this.transactionLog.push(transaction);
    this.logger.info('Transaction begun', { transactionId: transaction.id });

    return transaction;
  }

  /**
   * Commit a transaction atomically
   *
   * @param transaction - Transaction to commit
   * @returns Promise that resolves when commit completes
   */
  public async commitTransaction(transaction: Transaction): Promise<void> {
    this.logger.info('Committing transaction', {
      transactionId: transaction.id,
      files: transaction.files.length,
    });

    try {
      // Execute transaction atomically via FileTransactionManager
      const result = await this.fileTransactionManager.executeTransaction(transaction);

      if (!result.success) {
        transaction.status = 'rolled_back';
        transaction.error = result.error;
        this.logger.error('Transaction failed', undefined, { error: result.error });
        throw new Error(`Transaction failed: ${result.error}`);
      }

      transaction.status = 'committed';
      this.logger.info('Transaction committed successfully', {
        transactionId: transaction.id,
        filesModified: result.filesModified.length,
      });
    } catch (error) {
      transaction.status = 'rolled_back';
      transaction.error = error instanceof Error ? error.message : String(error);
      this.logger.error('Transaction commit failed', error);
      throw error;
    }
  }

  /**
   * Rollback a transaction
   *
   * @param transaction - Transaction to rollback
   * @returns Promise that resolves when rollback completes
   */
  public async rollbackTransaction(transaction: Transaction): Promise<void> {
    this.logger.info('Rolling back transaction', {
      transactionId: transaction.id,
    });

    // FileTransactionManager handles rollback automatically on failure
    // This method is for explicit rollback requests
    transaction.status = 'rolled_back';

    this.logger.info('Transaction rolled back', {
      transactionId: transaction.id,
    });
  }

  /**
   * Execute atomic multi-file update
   *
   * Helper method to create and execute a transaction in one call
   *
   * @param files - File operations to execute
   * @param operation - Operation type
   * @returns Promise that resolves when update completes
   */
  public async atomicUpdate(
    files: FileOperation[],
    operation: Transaction['operation'] = 'update_session'
  ): Promise<void> {
    const transaction = this.beginTransaction();
    transaction.operation = operation;
    transaction.files = files;

    await this.commitTransaction(transaction);
  }

  // ============================================================================
  // Private Helpers
  // ============================================================================

  /**
   * Validate phase transition is allowed
   */
  private isValidTransition(from: WorkflowPhase, to: WorkflowPhase): boolean {
    // Valid transitions (simplified - can be enhanced)
    const validTransitions: Record<WorkflowPhase, WorkflowPhase[]> = {
      none: ['initialize', 'generate'],
      initialize: ['generate', 'none'],
      generate: ['clarify', 'plan', 'none'],
      clarify: ['plan', 'generate'],
      plan: ['tasks', 'generate'],
      tasks: ['implement', 'plan'],
      implement: ['validate', 'tasks'],
      validate: ['complete', 'implement'],
      complete: ['none'], // Can start new feature
    };

    return validTransitions[from]?.includes(to) ?? false;
  }

  /**
   * Create default session state
   */
  private createDefaultSessionState(): SessionState {
    return {
      feature: null,
      phase: null,
      started: null,
      last_updated: new Date().toISOString(),
      schema_version: this.config.version,
      activeWork: {
        currentFeature: null,
        currentTask: null,
      },
      workflowProgress: {
        completedPhases: [],
        taskCompletion: '',
      },
      configState: {
        requireBlueprint: false,
        requireADR: false,
        autoValidate: true,
        autoCheckpoint: true,
      },
      sessionNotes: '',
      blockers: [],
      nextSteps: [],
    };
  }

  /**
   * Generate UUID v4
   */
  private generateUUID(): string {
    // Simple UUID v4 implementation
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }

  /**
   * Persist session state to disk
   */
  private async persistSession(state: SessionState): Promise<void> {
    const sessionPath = resolveStateFile(this.config, 'current-session.md', this.cwd);
    const stateDir = path.dirname(sessionPath);

    // Ensure state directory exists
    if (!fs.existsSync(stateDir)) {
      fs.mkdirSync(stateDir, { recursive: true });
    }

    // Extract frontmatter fields
    const frontmatter = {
      feature: state.feature,
      phase: state.phase,
      started: state.started,
      last_updated: state.last_updated,
      schema_version: state.schema_version,
    };

    // Build markdown content (simplified for now)
    const markdown = this.buildSessionMarkdown(state);

    // Combine frontmatter and markdown
    const yamlFrontmatter = toYAML(frontmatter);
    const content = `---\n${yamlFrontmatter}---\n\n${markdown}`;

    // Write atomically (temp file + rename)
    const tempPath = `${sessionPath}.tmp`;
    fs.writeFileSync(tempPath, content, 'utf8');
    fs.renameSync(tempPath, sessionPath);

    this.logger.info('Session persisted to disk', { path: sessionPath });
  }

  /**
   * Read session state from disk
   */
  private async readSessionFile(sessionPath: string): Promise<SessionState> {
    const content = fs.readFileSync(sessionPath, 'utf8');

    // Split frontmatter and markdown
    const parts = content.split('---\n');
    if (parts.length < 3) {
      throw new Error('Invalid session file format');
    }

    // Parse YAML frontmatter
    const yamlContent = parts[1] || '{}';
    const frontmatter = loadYAML(yamlContent) as Partial<SessionState>;

    // Create session state (with defaults for optional fields)
    const state: SessionState = {
      feature: frontmatter.feature || null,
      phase: frontmatter.phase || null,
      started: frontmatter.started || null,
      last_updated: frontmatter.last_updated || new Date().toISOString(),
      schema_version: frontmatter.schema_version || this.config.version,
      // Legacy fields for backward compatibility
      progress: frontmatter.progress,
      tasksComplete: frontmatter.tasksComplete,
      tasksTotal: frontmatter.tasksTotal,
    };

    return state;
  }

  /**
   * Build markdown content from session state
   */
  private buildSessionMarkdown(state: SessionState): string {
    const lines: string[] = [];

    lines.push('# Current Session State');
    lines.push('');
    lines.push(`**Last Updated**: ${state.last_updated}`);
    lines.push('');

    if (state.feature) {
      lines.push('## Active Feature');
      lines.push(`- Feature: ${state.feature}`);
      lines.push(`- Phase: ${state.phase || 'none'}`);
      lines.push('');
    }

    if (state.sessionNotes) {
      lines.push('## Notes');
      lines.push(state.sessionNotes);
      lines.push('');
    }

    if (state.blockers && state.blockers.length > 0) {
      lines.push('## Blockers');
      state.blockers.forEach(blocker => lines.push(`- ${blocker}`));
      lines.push('');
    }

    if (state.nextSteps && state.nextSteps.length > 0) {
      lines.push('## Next Steps');
      state.nextSteps.forEach(step => lines.push(`${step}`));
      lines.push('');
    }

    return lines.join('\n');
  }

  /**
   * Append content to a file atomically
   */
  private async appendToFile(filePath: string, content: string): Promise<void> {
    // Ensure directory exists
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    // Read existing content if file exists
    let existingContent = '';
    if (fs.existsSync(filePath)) {
      existingContent = fs.readFileSync(filePath, 'utf8');
    }

    // Append new content
    const newContent = existingContent + '\n' + content;

    // Write atomically
    const tempPath = `${filePath}.tmp`;
    fs.writeFileSync(tempPath, newContent, 'utf8');
    fs.renameSync(tempPath, filePath);
  }

  /**
   * Format progress entry for WORKFLOW-PROGRESS.md
   */
  private formatProgressEntry(entry: ProgressEntry): string {
    const lines: string[] = [];
    const timestamp = new Date(entry.timestamp).toLocaleString();

    lines.push(`### ${entry.feature}: ${entry.featureName}`);
    lines.push(`**Phase**: ${entry.phase} (${entry.progress}%)`);
    lines.push(`**Updated**: ${timestamp}`);

    if (entry.completedTasks !== undefined && entry.totalTasks !== undefined) {
      lines.push(`**Tasks**: ${entry.completedTasks}/${entry.totalTasks}`);
    }

    if (entry.notes) {
      lines.push(`**Notes**: ${entry.notes}`);
    }

    lines.push('');
    return lines.join('\n');
  }

  /**
   * Format decision record for DECISIONS-LOG.md
   */
  private formatDecisionRecord(adr: DecisionRecord): string {
    const lines: string[] = [];

    lines.push(`---`);
    lines.push('');
    lines.push(`## ${adr.id}: ${adr.title}`);
    lines.push('');
    lines.push(`**Date**: ${adr.date}`);
    lines.push(`**Status**: ${adr.status}`);
    lines.push(`**Feature**: ${adr.feature}`);
    lines.push('');
    lines.push(`### Context`);
    lines.push(adr.context);
    lines.push('');
    lines.push(`### Decision`);
    lines.push(adr.decision);
    lines.push('');
    lines.push(`### Consequences`);
    lines.push('');
    lines.push(`**Positive**:`);
    adr.consequences.positive.forEach(item => lines.push(`- ${item}`));
    lines.push('');
    lines.push(`**Negative**:`);
    adr.consequences.negative.forEach(item => lines.push(`- ${item}`));
    lines.push('');
    lines.push(`**Neutral**:`);
    adr.consequences.neutral.forEach(item => lines.push(`- ${item}`));
    lines.push('');

    if (adr.alternatives && adr.alternatives.length > 0) {
      lines.push(`### Alternatives Considered`);
      adr.alternatives.forEach((alt, i) => lines.push(`${i + 1}. ${alt}`));
      lines.push('');
    }

    return lines.join('\n');
  }

  /**
   * Format planned change for CHANGES-PLANNED.md
   */
  private formatPlannedChange(change: PlannedChange): string {
    const lines: string[] = [];

    lines.push(`---`);
    lines.push('');
    lines.push(`## ${change.id}: ${change.description}`);
    lines.push('');
    lines.push(`**Feature**: ${change.feature}`);
    lines.push(`**Priority**: ${change.priority}`);
    lines.push(`**Story**: ${change.story}`);
    lines.push(`**Effort**: ${change.estimatedEffort}`);
    lines.push(`**Added**: ${change.added}`);

    if (change.dependencies.length > 0) {
      lines.push(`**Dependencies**: ${change.dependencies.join(', ')}`);
    }

    lines.push('');
    return lines.join('\n');
  }

  /**
   * Format change completion for CHANGES-COMPLETED.md
   */
  private formatChangeCompletion(completion: ChangeCompletion): string {
    const lines: string[] = [];

    lines.push(`---`);
    lines.push('');
    lines.push(`## ${completion.id} ✅`);
    lines.push('');
    lines.push(`**Feature**: ${completion.feature}`);
    lines.push(`**Completed**: ${completion.completed}`);
    lines.push(`**Duration**: ${completion.duration}`);
    lines.push(`**Implemented By**: ${completion.implementedBy}`);
    lines.push('');

    if (completion.filesChanged.length > 0) {
      lines.push(`**Files Changed**:`);
      completion.filesChanged.forEach(file => lines.push(`- ${file}`));
      lines.push('');
    }

    if (completion.testsAdded.length > 0) {
      lines.push(`**Tests Added**:`);
      completion.testsAdded.forEach(test => lines.push(`- ${test}`));
      lines.push('');
    }

    if (completion.commits && completion.commits.length > 0) {
      lines.push(`**Commits**:`);
      completion.commits.forEach(commit => lines.push(`- ${commit}`));
      lines.push('');
    }

    return lines.join('\n');
  }
}

/**
 * Convenience function to get MemoryManager instance
 *
 * @param config - Spec configuration
 * @param cwd - Current working directory
 * @returns MemoryManager instance
 */
export function getMemoryManager(
  config: SpecConfig,
  cwd: string
): MemoryManager {
  return MemoryManager.getInstance(config, cwd);
}
