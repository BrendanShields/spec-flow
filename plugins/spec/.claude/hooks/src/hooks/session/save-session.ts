#!/usr/bin/env node

/**
 * Session Save Hook
 *
 * Saves workflow state at session end for continuity across sessions.
 * Captures current feature context, pending tasks, and environment details.
 */

import * as fs from 'fs';
import * as path from 'path';
import { BaseHook } from '../../core/base-hook';
import { resolveFeaturesPath, resolveSpecRoot } from '../../core/path-resolver';
import { writeJSON, listFiles, ensureDirectory } from '../../utils/file-utils';
import { HookContext } from '../../types';

interface SessionData {
  timestamp: string;
  workingDirectory: string;
  lastActivity: string;
  workflow: {
    currentFeature: string | null;
    lastModifiedFiles: string[];
    pendingTasks: { total: number; completed: number; pending: number; progress: number } | null;
  };
  environment: {
    nodeVersion: string;
    platform: string;
    specVersion: string;
  };
}

/**
 * Save Session Hook
 */
export class SaveSessionHook extends BaseHook {
  constructor() {
    super('save-session');
  }

  async execute(context: HookContext): Promise<void> {
    const specRoot = resolveSpecRoot(this.config, this.cwd);
    const sessionPath = path.join(specRoot, '.session.json');

    // Ensure directory exists
    ensureDirectory(specRoot);

    // Gather session data
    const session: SessionData = {
      timestamp: new Date().toISOString(),
      workingDirectory: this.cwd,
      lastActivity: (context.command as string) || 'Unknown',
      workflow: {
        currentFeature: this.findCurrentFeature(),
        lastModifiedFiles: this.findRecentlyModified(),
        pendingTasks: this.findPendingTasks(),
      },
      environment: {
        nodeVersion: process.version,
        platform: process.platform,
        specVersion: this.config.version,
      },
    };

    // Save session
    writeJSON(sessionPath, session);

    this.logger.success('Session saved successfully');
  }

  private findCurrentFeature(): string | null {
    try {
      const featuresDir = resolveFeaturesPath(this.config, this.cwd);
      if (!fs.existsSync(featuresDir)) return null;

      const features = fs
        .readdirSync(featuresDir)
        .filter((f) => fs.statSync(path.join(featuresDir, f)).isDirectory())
        .sort((a, b) => {
          const aStat = fs.statSync(path.join(featuresDir, a));
          const bStat = fs.statSync(path.join(featuresDir, b));
          return bStat.mtime.getTime() - aStat.mtime.getTime();
        });

      return features[0] ?? null;
    } catch {
      return null;
    }
  }

  private findRecentlyModified(): string[] {
    try {
      const cutoff = Date.now() - 60 * 60 * 1000; // Last hour
      const files = listFiles(this.cwd, { recursive: true });

      return files
        .filter((file) => {
          try {
            const stat = fs.statSync(file);
            return stat.mtime.getTime() > cutoff;
          } catch {
            return false;
          }
        })
        .slice(0, 20); // Limit to 20 most recent
    } catch {
      return [];
    }
  }

  private findPendingTasks(): { total: number; completed: number; pending: number; progress: number } | null {
    try {
      const featuresDir = resolveFeaturesPath(this.config, this.cwd);
      const tasksFiles = listFiles(featuresDir, { pattern: /tasks\.md$/ });

      if (tasksFiles.length === 0) return null;

      let total = 0;
      let completed = 0;

      for (const file of tasksFiles) {
        const content = fs.readFileSync(file, 'utf8');
        const lines = content.split('\n');

        for (const line of lines) {
          if (line.includes('- [ ]')) total++;
          if (line.includes('- [x]')) {
            total++;
            completed++;
          }
        }
      }

      const pending = total - completed;
      const progress = total > 0 ? Math.round((completed / total) * 100) : 0;

      return { total, completed, pending, progress };
    } catch {
      return null;
    }
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new SaveSessionHook();
  await hook.run();
}

main();
