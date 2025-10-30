#!/usr/bin/env node

/**
 * @fileoverview Workflow Status Tracking Hook
 *
 * Tracks workflow progress across Flow skill executions.
 * Maintains state in .specter/.state.json showing current phase, progress percentage,
 * skill execution history, and estimated time remaining.
 *
 * Features:
 * - Phase tracking (setup → specification → planning → validation → implementation)
 * - Progress percentage (0-100% based on completed steps)
 * - Execution history (last 50 operations)
 * - Time estimation (average time per skill × remaining steps)
 * - Next step suggestions
 *
 * @requires fs
 * @requires path
 * @author Specter Plugin Team
 */

const fs = require('fs');
const path = require('path');

const STATE_FILE = '.specter/.state.json';

// Skill completion tracking
const SKILL_WORKFLOW = {
  'specter:init': { phase: 'setup', progress: 10 },
  'specter:blueprint': { phase: 'setup', progress: 20 },
  'specter:specify': { phase: 'specification', progress: 30 },
  'specter:clarify': { phase: 'specification', progress: 40 },
  'specter:plan': { phase: 'planning', progress: 50 },
  'specter:analyze': { phase: 'planning', progress: 60 },
  'specter:tasks': { phase: 'planning', progress: 70 },
  'specter:checklist': { phase: 'validation', progress: 80 },
  'specter:implement': { phase: 'implementation', progress: 90 },
  'specter:update': { phase: 'maintenance', progress: 100 }
};

async function updateWorkflowStatus(skillName, status, context) {
  const stateFilePath = path.join(process.cwd(), STATE_FILE);

  // Ensure .flow directory exists
  const flowDir = path.dirname(stateFilePath);
  if (!fs.existsSync(flowDir)) {
    fs.mkdirSync(flowDir, { recursive: true });
  }

  // Load existing state
  let state = {};
  if (fs.existsSync(stateFilePath)) {
    try {
      state = JSON.parse(fs.readFileSync(stateFilePath, 'utf8'));
    } catch {
      state = {};
    }
  }

  // Update state
  const skillInfo = SKILL_WORKFLOW[skillName] || { phase: 'unknown', progress: 0 };

  state.lastCompletedSkill = skillName;
  state.lastExecutionTime = new Date().toISOString();
  state.currentPhase = skillInfo.phase;
  state.overallProgress = skillInfo.progress;
  state.status = status;

  // Track skill history
  if (!state.history) {
    state.history = [];
  }

  state.history.push({
    skill: skillName,
    timestamp: new Date().toISOString(),
    status,
    phase: skillInfo.phase
  });

  // Keep only last 50 entries
  if (state.history.length > 50) {
    state.history = state.history.slice(-50);
  }

  // Track feature/project context if available
  if (context.featureName) {
    state.currentFeature = context.featureName;
  }

  // Calculate completion stats
  const completedSkills = new Set(state.history
    .filter(h => h.status === 'success')
    .map(h => h.skill));

  state.completedSteps = completedSkills.size;
  state.totalSteps = Object.keys(SKILL_WORKFLOW).length;

  // Estimate time remaining (basic heuristic)
  if (state.history.length > 1) {
    const avgTime = calculateAverageSkillTime(state.history);
    const remainingSteps = state.totalSteps - state.completedSteps;
    state.estimatedTimeRemaining = avgTime * remainingSteps;
  }

  // Save updated state
  fs.writeFileSync(stateFilePath, JSON.stringify(state, null, 2));

  return state;
}

function calculateAverageSkillTime(history) {
  if (history.length < 2) return 300000; // Default 5 minutes

  const times = [];
  for (let i = 1; i < history.length; i++) {
    const prev = new Date(history[i - 1].timestamp);
    const curr = new Date(history[i].timestamp);
    times.push(curr - prev);
  }

  return times.reduce((a, b) => a + b, 0) / times.length;
}

function formatStatus(state) {
  const progress = '█'.repeat(Math.floor(state.overallProgress / 10)) +
                   '░'.repeat(10 - Math.floor(state.overallProgress / 10));

  return {
    message: `📊 Workflow Progress: ${progress} ${state.overallProgress}%`,
    phase: `Phase: ${state.currentPhase}`,
    completed: `Steps: ${state.completedSteps}/${state.totalSteps}`,
    feature: state.currentFeature || 'No feature context'
  };
}

// Main execution
async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));

    // Extract skill name
    const skillMatch = input.command?.match(/^(flow:\w+)/);
    if (!skillMatch) {
      process.exit(0); // Not a Flow skill
    }

    const skillName = skillMatch[1];
    const status = input.success ? 'success' : 'failed';

    const state = await updateWorkflowStatus(skillName, status, input.context || {});
    const formatted = formatStatus(state);

    // Output status update
    console.log(JSON.stringify({
      type: 'workflow-status',
      ...formatted,
      state: {
        lastSkill: state.lastCompletedSkill,
        nextStep: getNextStep(state.lastCompletedSkill),
        estimatedTime: state.estimatedTimeRemaining
          ? `~${Math.ceil(state.estimatedTimeRemaining / 60000)} minutes`
          : 'Unknown'
      }
    }, null, 2));

    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: error.message
    }));
    process.exit(0);
  }
}

function getNextStep(lastSkill) {
  const workflow = {
    'specter:init': 'specter:blueprint',
    'specter:blueprint': 'specter:specify',
    'specter:specify': 'specter:clarify or specter:plan',
    'specter:clarify': 'specter:plan',
    'specter:plan': 'specter:tasks',
    'specter:tasks': 'specter:analyze or specter:implement',
    'specter:analyze': 'specter:implement',
    'specter:checklist': 'specter:implement'
  };

  return workflow[lastSkill] || 'Workflow complete or custom path';
}

main();