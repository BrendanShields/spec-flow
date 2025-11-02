#!/usr/bin/env node

/**
 * Session Restore Hook
 *
 * Restores workflow state from previous session on startup.
 * Provides welcome message with context about last session,
 * pending tasks, and suggested next steps.
 */

import { resolveSpecRoot } from '../../core/path-resolver';
import { loadConfig } from '../../core/config-loader';
import { MemoryManager } from '../../core/memory-manager';
import { Logger } from '../../core/logger';
import { readJSON, fileExists } from '../../utils/file-utils';
import * as path from 'path';

interface SessionData {
  timestamp: string;
  workflow: {
    currentFeature?: string;
    pendingTasks?: {
      pending: number;
      completed: number;
      total: number;
      progress: number;
    };
  };
}

interface StateData {
  lastCompletedSkill?: string;
}

interface RestoreResults {
  session: SessionData | null;
  state: StateData | null;
  suggestions: string[];
  timeSinceLastSession?: string;
}

/**
 * Get next workflow step based on last completed skill
 */
function getNextStep(lastSkill: string): string | null {
  const workflow: Record<string, string> = {
    'spec:init': 'spec:blueprint',
    'spec:blueprint': 'spec:specify',
    'spec:specify': 'spec:plan',
    'spec:plan': 'spec:tasks',
    'spec:tasks': 'spec:implement',
  };

  return workflow[lastSkill] ?? null;
}

/**
 * Restore session from saved files
 */
async function restoreSession(): Promise<RestoreResults> {
  const cwd = process.cwd();
  const config = loadConfig(cwd);
  const specRoot = resolveSpecRoot(config, cwd);

  const sessionPath = path.join(specRoot, '.session.json');
  const statePath = path.join(specRoot, '.state.json');

  const results: RestoreResults = {
    session: null,
    state: null,
    suggestions: [],
  };

  // Try to restore from MemoryManager first
  const memoryManager = MemoryManager.getInstance(config, cwd);
  const restored = await memoryManager.restoreSession();

  if (restored) {
    Logger.info('Session restored from MemoryManager');

    // Map to legacy SessionData format for compatibility
    results.session = {
      timestamp: restored.last_updated,
      workflow: {
        currentFeature: restored.feature || undefined,
        pendingTasks: restored.tasksTotal
          ? {
              pending: (restored.tasksTotal || 0) - (restored.tasksComplete || 0),
              completed: restored.tasksComplete || 0,
              total: restored.tasksTotal || 0,
              progress: restored.progress || 0,
            }
          : undefined,
      },
    };

    // Calculate time since last session
    if (restored.last_updated) {
      const lastTime = new Date(restored.last_updated);
      const timeDiff = Date.now() - lastTime.getTime();
      const hours = Math.floor(timeDiff / (1000 * 60 * 60));
      const days = Math.floor(hours / 24);
      results.timeSinceLastSession = days > 0 ? `${days} days ago` : `${hours} hours ago`;
    }
  } else {
    // Fallback to legacy session files
    if (fileExists(sessionPath)) {
      try {
        results.session = readJSON<SessionData>(sessionPath);

        if (results.session) {
          // Calculate time since last session
          const lastTime = new Date(results.session.timestamp);
          const timeDiff = Date.now() - lastTime.getTime();
          const hours = Math.floor(timeDiff / (1000 * 60 * 60));
          const days = Math.floor(hours / 24);

          results.timeSinceLastSession = days > 0 ? `${days} days ago` : `${hours} hours ago`;
        }
      } catch {
        // Invalid session file - ignore
      }
    }
  }

  // Load workflow state if exists
  if (fileExists(statePath)) {
    try {
      results.state = readJSON<StateData>(statePath);
    } catch {
      // Invalid state file - ignore
    }
  }

  // Generate suggestions based on state
  if (results.session?.workflow) {
    const workflow = results.session.workflow;

    if (workflow.currentFeature) {
      results.suggestions.push(`Continue working on: ${workflow.currentFeature}`);
    }

    if (workflow.pendingTasks && workflow.pendingTasks.pending > 0) {
      results.suggestions.push(
        `Resume implementation: ${workflow.pendingTasks.pending} tasks pending ` +
          `(${workflow.pendingTasks.progress}% complete)`
      );
    }
  }

  if (results.state?.lastCompletedSkill) {
    const nextStep = getNextStep(results.state.lastCompletedSkill);
    if (nextStep) {
      results.suggestions.push(`Next workflow step: ${nextStep}`);
    }
  }

  return results;
}

/**
 * Format welcome message
 */
function formatWelcomeMessage(results: RestoreResults): string {
  let message = '🔄 Session Restored\n\n';

  if (results.session) {
    message += `Last session: ${results.timeSinceLastSession}\n`;

    if (results.session.workflow.currentFeature) {
      message += `Feature: ${results.session.workflow.currentFeature}\n`;
    }

    if (results.session.workflow.pendingTasks && results.session.workflow.pendingTasks.pending > 0) {
      const tasks = results.session.workflow.pendingTasks;
      message += `Tasks: ${tasks.completed}/${tasks.total} complete (${tasks.progress}%)\n`;
    }
  }

  if (results.suggestions.length > 0) {
    message += '\n📝 Suggestions:\n';
    results.suggestions.forEach((s) => {
      message += `  • ${s}\n`;
    });
  }

  return message;
}

/**
 * Main execution
 */
async function main(): Promise<void> {
  try {
    const results = await restoreSession();

    if (results.session || results.state) {
      const message = formatWelcomeMessage(results);

      Logger.custom('session-restored', message, {
        hasSession: !!results.session,
        hasState: !!results.state,
        feature: results.session?.workflow?.currentFeature,
        lastSkill: results.state?.lastCompletedSkill,
        suggestions: results.suggestions,
      });
    }

    process.exit(0);
  } catch (error) {
    // Silent fail - session restoration is non-critical
    process.exit(0);
  }
}

main();
