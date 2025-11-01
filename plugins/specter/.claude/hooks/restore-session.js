#!/usr/bin/env node

/**
 * @fileoverview Session Restore Hook
 *
 * Restores workflow state from previous session on startup.
 * Provides welcome message with context about last session,
 * pending tasks, and suggested next steps.
 *
 * Features:
 * - Session continuity (restores feature context)
 * - Time since last session calculation
 * - Pending task summary
 * - Workflow continuation suggestions
 * - Graceful handling of missing/corrupt session files
 *
 * @requires fs
 * @requires path
 * @author Specter Plugin Team
 */

const fs = require('fs');
const path = require('path');

const SESSION_FILE = '.specter/.session.json';
const STATE_FILE = '.specter/.state.json';

async function restoreSession() {
  const sessionPath = path.join(process.cwd(), SESSION_FILE);
  const statePath = path.join(process.cwd(), STATE_FILE);

  const results = {
    session: null,
    state: null,
    suggestions: []
  };

  // Load session if exists
  if (fs.existsSync(sessionPath)) {
    try {
      results.session = JSON.parse(fs.readFileSync(sessionPath, 'utf8'));

      // Calculate time since last session
      const lastTime = new Date(results.session.timestamp);
      const timeDiff = Date.now() - lastTime.getTime();
      const hours = Math.floor(timeDiff / (1000 * 60 * 60));
      const days = Math.floor(hours / 24);

      results.timeSinceLastSession = days > 0 ? `${days} days ago` : `${hours} hours ago`;
    } catch {
      // Invalid session file
    }
  }

  // Load workflow state if exists
  if (fs.existsSync(statePath)) {
    try {
      results.state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
    } catch {
      // Invalid state file
    }
  }

  // Generate suggestions based on state
  if (results.session?.workflow) {
    const workflow = results.session.workflow;

    if (workflow.currentFeature) {
      results.suggestions.push(`Continue working on: ${workflow.currentFeature}`);
    }

    if (workflow.pendingTasks?.pending > 0) {
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

function getNextStep(lastSkill) {
  const workflow = {
    'specter:init': 'specter:blueprint',
    'specter:blueprint': 'specter:specify',
    'specter:specify': 'specter:plan',
    'specter:plan': 'specter:tasks',
    'specter:tasks': 'specter:implement'
  };

  return workflow[lastSkill];
}

function formatWelcomeMessage(results) {
  let message = '🔄 Session Restored\n\n';

  if (results.session) {
    message += `Last session: ${results.timeSinceLastSession}\n`;

    if (results.session.workflow.currentFeature) {
      message += `Feature: ${results.session.workflow.currentFeature}\n`;
    }

    if (results.session.workflow.pendingTasks?.pending > 0) {
      const tasks = results.session.workflow.pendingTasks;
      message += `Tasks: ${tasks.completed}/${tasks.total} complete (${tasks.progress}%)\n`;
    }
  }

  if (results.suggestions.length > 0) {
    message += '\n📝 Suggestions:\n';
    results.suggestions.forEach(s => {
      message += `  • ${s}\n`;
    });
  }

  return message;
}

// Main execution
async function main() {
  try {
    const results = await restoreSession();

    if (results.session || results.state) {
      const message = formatWelcomeMessage(results);

      console.log(JSON.stringify({
        type: 'session-restored',
        message,
        context: {
          hasSession: !!results.session,
          hasState: !!results.state,
          feature: results.session?.workflow?.currentFeature,
          lastSkill: results.state?.lastCompletedSkill,
          suggestions: results.suggestions
        }
      }, null, 2));
    }

    process.exit(0);
  } catch (error) {
    // Silent fail - session restoration is non-critical
    process.exit(0);
  }
}

main();