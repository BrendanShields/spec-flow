/**
 * State History Logger
 *
 * Tracks all state changes over time for debugging, auditing, and analysis.
 * Maintains an append-only log of state transitions with timestamps and metadata.
 */

import * as fs from 'fs';
import * as path from 'path';
import { SessionState, WorkflowPhase } from '../types/memory';

/**
 * State change entry
 */
export interface StateChangeEntry {
  /** ISO 8601 timestamp */
  timestamp: string;
  /** Change type */
  type: 'update' | 'transition' | 'restore' | 'repair';
  /** Previous state snapshot */
  before: Partial<SessionState>;
  /** New state snapshot */
  after: Partial<SessionState>;
  /** Changed fields */
  changedFields: string[];
  /** Optional metadata */
  metadata?: Record<string, unknown>;
}

/**
 * State History Logger
 */
export class StateHistoryLogger {
  private readonly historyFile: string;
  private readonly maxEntries: number;

  constructor(historyFile: string, maxEntries = 1000) {
    this.historyFile = historyFile;
    this.maxEntries = maxEntries;

    // Ensure directory exists
    const dir = path.dirname(historyFile);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  /**
   * Log a state change
   */
  public async logChange(
    type: StateChangeEntry['type'],
    before: Partial<SessionState>,
    after: Partial<SessionState>,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    const changedFields = this.getChangedFields(before, after);

    const entry: StateChangeEntry = {
      timestamp: new Date().toISOString(),
      type,
      before,
      after,
      changedFields,
      metadata,
    };

    await this.appendEntry(entry);
  }

  /**
   * Log a session update
   */
  public async logUpdate(
    before: SessionState,
    after: SessionState,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    await this.logChange('update', before, after, metadata);
  }

  /**
   * Log a phase transition
   */
  public async logTransition(
    from: WorkflowPhase,
    to: WorkflowPhase,
    before: SessionState,
    after: SessionState,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    await this.logChange('transition', before, after, {
      ...metadata,
      from,
      to,
    });
  }

  /**
   * Log a session restore
   */
  public async logRestore(
    state: SessionState,
    metadata?: Record<string, unknown>
  ): Promise<void> {
    await this.logChange('restore', {}, state, metadata);
  }

  /**
   * Log a state repair
   */
  public async logRepair(
    before: SessionState,
    after: SessionState,
    repairs: string[],
    metadata?: Record<string, unknown>
  ): Promise<void> {
    await this.logChange('repair', before, after, {
      ...metadata,
      repairs,
    });
  }

  /**
   * Get recent history
   */
  public async getRecentHistory(limit = 50): Promise<StateChangeEntry[]> {
    if (!fs.existsSync(this.historyFile)) {
      return [];
    }

    const content = fs.readFileSync(this.historyFile, 'utf8');
    const lines = content.trim().split('\n').filter((l) => l.trim());

    const entries: StateChangeEntry[] = [];
    for (const line of lines.slice(-limit)) {
      try {
        entries.push(JSON.parse(line));
      } catch {
        // Skip malformed entries
      }
    }

    return entries;
  }

  /**
   * Get history for specific feature
   */
  public async getFeatureHistory(featureId: string): Promise<StateChangeEntry[]> {
    const allHistory = await this.getRecentHistory(this.maxEntries);

    return allHistory.filter(
      (entry) => entry.after.feature === featureId || entry.before.feature === featureId
    );
  }

  /**
   * Get history for specific time range
   */
  public async getHistoryInRange(
    startDate: Date,
    endDate: Date
  ): Promise<StateChangeEntry[]> {
    const allHistory = await this.getRecentHistory(this.maxEntries);

    return allHistory.filter((entry) => {
      const entryTime = new Date(entry.timestamp).getTime();
      return entryTime >= startDate.getTime() && entryTime <= endDate.getTime();
    });
  }

  /**
   * Get statistics from history
   */
  public async getStatistics(): Promise<{
    totalChanges: number;
    byType: Record<string, number>;
    byPhase: Record<string, number>;
    averageChangesPerDay: number;
    lastChange: string | null;
  }> {
    const history = await this.getRecentHistory(this.maxEntries);

    if (history.length === 0) {
      return {
        totalChanges: 0,
        byType: {},
        byPhase: {},
        averageChangesPerDay: 0,
        lastChange: null,
      };
    }

    const byType: Record<string, number> = {};
    const byPhase: Record<string, number> = {};

    for (const entry of history) {
      byType[entry.type] = (byType[entry.type] || 0) + 1;

      if (entry.after.phase) {
        byPhase[entry.after.phase] = (byPhase[entry.after.phase] || 0) + 1;
      }
    }

    // Calculate average changes per day
    const firstTimestamp = new Date(history[0]?.timestamp || Date.now()).getTime();
    const lastTimestamp = new Date(
      history[history.length - 1]?.timestamp || Date.now()
    ).getTime();
    const daysDiff = (lastTimestamp - firstTimestamp) / (1000 * 60 * 60 * 24);
    const averageChangesPerDay = daysDiff > 0 ? history.length / daysDiff : history.length;

    return {
      totalChanges: history.length,
      byType,
      byPhase,
      averageChangesPerDay: Math.round(averageChangesPerDay * 10) / 10,
      lastChange: history[history.length - 1]?.timestamp || null,
    };
  }

  /**
   * Clear old history entries
   */
  public async pruneHistory(keepLast = 1000): Promise<number> {
    if (!fs.existsSync(this.historyFile)) {
      return 0;
    }

    const content = fs.readFileSync(this.historyFile, 'utf8');
    const lines = content.trim().split('\n').filter((l) => l.trim());

    if (lines.length <= keepLast) {
      return 0;
    }

    const toKeep = lines.slice(-keepLast);
    fs.writeFileSync(this.historyFile, toKeep.join('\n') + '\n', 'utf8');

    return lines.length - toKeep.length;
  }

  /**
   * Append entry to history file
   */
  private async appendEntry(entry: StateChangeEntry): Promise<void> {
    const line = JSON.stringify(entry) + '\n';

    fs.appendFileSync(this.historyFile, line, 'utf8');

    // Auto-prune if exceeding max entries
    const content = fs.readFileSync(this.historyFile, 'utf8');
    const lines = content.trim().split('\n').filter((l) => l.trim());

    if (lines.length > this.maxEntries) {
      await this.pruneHistory(this.maxEntries);
    }
  }

  /**
   * Get changed fields between two states
   */
  private getChangedFields(
    before: Partial<SessionState>,
    after: Partial<SessionState>
  ): string[] {
    const changed: string[] = [];
    const allKeys = new Set([...Object.keys(before), ...Object.keys(after)]);

    for (const key of allKeys) {
      const beforeVal = (before as any)[key];
      const afterVal = (after as any)[key];

      if (JSON.stringify(beforeVal) !== JSON.stringify(afterVal)) {
        changed.push(key);
      }
    }

    return changed;
  }
}

/**
 * Create state history logger
 */
export function createStateHistoryLogger(
  historyFile: string,
  maxEntries?: number
): StateHistoryLogger {
  return new StateHistoryLogger(historyFile, maxEntries);
}
