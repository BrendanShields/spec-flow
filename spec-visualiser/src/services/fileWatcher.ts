import chokidar, { FSWatcher } from 'chokidar';
import * as path from 'path';
import { EventEmitter } from 'events';
import { FileChange } from '../types/spec.js';

export interface WatchOptions {
  debounceDelay?: number;
  ignoreInitial?: boolean;
  persistent?: boolean;
}

export class SpecFileWatcher extends EventEmitter {
  private watcher: FSWatcher | null = null;
  private watchPaths: string[] = [];
  private debounceTimers: Map<string, NodeJS.Timeout> = new Map();

  constructor(
    private projectRoot: string,
    private options: WatchOptions = {}
  ) {
    super();
    this.options.debounceDelay = options.debounceDelay || 300;
    this.options.ignoreInitial = options.ignoreInitial !== false;
    this.options.persistent = options.persistent !== false;
  }

  start(): void {
    if (this.watcher) {
      return;
    }

    // Define paths to watch
    this.watchPaths = [
      path.join(this.projectRoot, '.spec-state', '**/*.md'),
      path.join(this.projectRoot, '.spec-memory', '**/*.md'),
      path.join(this.projectRoot, 'features', '**/*.md'),
      path.join(this.projectRoot, '.spec', '**/*'),
    ];

    this.watcher = chokidar.watch(this.watchPaths, {
      ignored: [
        '**/node_modules/**',
        '**/.git/**',
        '**/dist/**',
        '**/*.log',
      ],
      ignoreInitial: this.options.ignoreInitial,
      persistent: this.options.persistent,
      awaitWriteFinish: {
        stabilityThreshold: 300,
        pollInterval: 100,
      },
    });

    this.watcher
      .on('add', (filepath) => this.handleFileChange(filepath, 'created'))
      .on('change', (filepath) => this.handleFileChange(filepath, 'modified'))
      .on('unlink', (filepath) => this.handleFileChange(filepath, 'deleted'))
      .on('error', (error) => this.emit('error', error))
      .on('ready', () => this.emit('ready'));
  }

  private handleFileChange(
    filepath: string,
    type: 'created' | 'modified' | 'deleted'
  ): void {
    const relativePath = path.relative(this.projectRoot, filepath);

    // Debounce rapid changes
    const existingTimer = this.debounceTimers.get(filepath);
    if (existingTimer) {
      clearTimeout(existingTimer);
    }

    const timer = setTimeout(() => {
      this.debounceTimers.delete(filepath);

      const change: FileChange = {
        path: relativePath,
        type,
        timestamp: new Date(),
      };

      // Emit specific events based on file location
      if (relativePath.includes('.spec-state')) {
        this.emit('state-change', change);
      } else if (relativePath.includes('.spec-memory')) {
        this.emit('memory-change', change);
      } else if (relativePath.includes('features')) {
        this.emit('feature-change', change);
      }

      // Always emit general change event
      this.emit('change', change);

      // Emit specific file type events
      if (relativePath.endsWith('current-session.md')) {
        this.emit('session-update', change);
      } else if (relativePath.endsWith('WORKFLOW-PROGRESS.md')) {
        this.emit('progress-update', change);
      } else if (relativePath.endsWith('DECISIONS-LOG.md')) {
        this.emit('decision-added', change);
      } else if (relativePath.endsWith('CHANGES-PLANNED.md')) {
        this.emit('changes-planned', change);
      } else if (relativePath.endsWith('CHANGES-COMPLETED.md')) {
        this.emit('changes-completed', change);
      } else if (relativePath.includes('/spec.md')) {
        this.emit('spec-update', change);
      } else if (relativePath.includes('/plan.md')) {
        this.emit('plan-update', change);
      } else if (relativePath.includes('/tasks.md')) {
        this.emit('tasks-update', change);
      }
    }, this.options.debounceDelay);

    this.debounceTimers.set(filepath, timer);
  }

  stop(): void {
    if (this.watcher) {
      this.watcher.close();
      this.watcher = null;
    }

    // Clear any pending timers
    for (const timer of this.debounceTimers.values()) {
      clearTimeout(timer);
    }
    this.debounceTimers.clear();

    this.removeAllListeners();
  }

  isWatching(): boolean {
    return this.watcher !== null;
  }

  getWatchedPaths(): string[] {
    return [...this.watchPaths];
  }
}
