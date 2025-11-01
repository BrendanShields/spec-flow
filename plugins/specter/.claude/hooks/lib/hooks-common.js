/**
 * Common utilities for Specter hooks
 * Consolidates duplicate code patterns across all hook files
 */

const fs = require('fs');
const path = require('path');

// ============= File System Utils =============

/**
 * Ensure directory exists, create if not
 */
exports.ensureDir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

/**
 * Read JSON file with default fallback
 */
exports.readJSON = (filePath, defaultValue = null) => {
  try {
    if (!fs.existsSync(filePath)) return defaultValue;
    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch {
    return defaultValue;
  }
};

/**
 * Write JSON file with pretty formatting
 */
exports.writeJSON = (filePath, data) => {
  this.ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
};

/**
 * Safely read file or return default
 */
exports.readFile = (filePath, defaultValue = '') => {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch {
    return defaultValue;
  }
};

// ============= Hook I/O Utils =============

/**
 * Read hook input from stdin
 */
exports.readHookInput = () => {
  try {
    return JSON.parse(fs.readFileSync(0, 'utf8'));
  } catch (error) {
    return null;
  }
};

/**
 * Write hook output to stdout
 */
exports.writeHookOutput = (data) => {
  console.log(JSON.stringify(data, null, 2));
};

/**
 * Write hook error and exit
 */
exports.writeHookError = (message, exitCode = 0) => {
  console.error(JSON.stringify({
    type: 'error',
    message: message
  }, null, 2));
  process.exit(exitCode);
};

// ============= State Management =============

/**
 * Load workflow state
 */
exports.loadState = (stateFile = '.specter-state/current-session.md') => {
  const content = this.readFile(stateFile, '');
  const state = {
    feature: null,
    phase: 'uninitialized',
    task: null,
    progress: 0
  };

  // Parse markdown state file
  const lines = content.split('\n');
  for (const line of lines) {
    if (line.includes('Current Feature:')) {
      state.feature = line.split(':')[1]?.trim();
    } else if (line.includes('Current Phase:')) {
      state.phase = line.split(':')[1]?.trim();
    } else if (line.includes('Current Task:')) {
      state.task = line.split(':')[1]?.trim();
    } else if (line.includes('Progress:')) {
      const match = line.match(/(\d+)%/);
      state.progress = match ? parseInt(match[1]) : 0;
    }
  }

  return state;
};

/**
 * Save workflow state
 */
exports.saveState = (stateFile, state) => {
  const content = `# Current Session State

## Overview
- Current Feature: ${state.feature || 'None'}
- Current Phase: ${state.phase || 'uninitialized'}
- Current Task: ${state.task || 'None'}
- Progress: ${state.progress || 0}%
- Last Updated: ${new Date().toISOString()}
`;

  this.ensureDir(path.dirname(stateFile));
  fs.writeFileSync(stateFile, content);
};

/**
 * Find current feature directory
 */
exports.findFeatureDir = () => {
  try {
    const featuresDir = path.join(process.cwd(), 'features');
    if (!fs.existsSync(featuresDir)) return null;

    const features = fs.readdirSync(featuresDir)
      .filter(f => fs.statSync(path.join(featuresDir, f)).isDirectory())
      .filter(f => /^\d{3}-/.test(f))
      .sort((a, b) => {
        const aStat = fs.statSync(path.join(featuresDir, a));
        const bStat = fs.statSync(path.join(featuresDir, b));
        return bStat.mtime - aStat.mtime;
      });

    return features[0] || null;
  } catch {
    return null;
  }
};

// ============= Workflow Utils =============

const WORKFLOW = {
  'specter:init': 'specter:blueprint',
  'specter:blueprint': 'specter:specify',
  'specter:specify': ['specter:clarify', 'specter:plan'],
  'specter:clarify': 'specter:plan',
  'specter:plan': 'specter:tasks',
  'specter:tasks': 'specter:implement'
};

/**
 * Get next step in workflow
 */
exports.getNextStep = (skill) => {
  const next = WORKFLOW[skill];
  return Array.isArray(next) ? next : (next || null);
};

/**
 * Calculate progress percentage
 */
exports.getProgress = (skill) => {
  const phases = {
    'specter:init': 10,
    'specter:blueprint': 20,
    'specter:specify': 30,
    'specter:clarify': 40,
    'specter:plan': 50,
    'specter:tasks': 70,
    'specter:implement': 90,
    'complete': 100
  };
  return phases[skill] || 0;
};

// ============= Validation Utils =============

/**
 * Validate file exists
 */
exports.validateFile = (filePath, required = true) => {
  const exists = fs.existsSync(filePath);
  if (!exists && required) {
    throw new Error(`Required file missing: ${filePath}`);
  }
  return exists;
};

/**
 * Validate branch name
 */
exports.validateBranch = (branchName) => {
  return /^\d{3}-/.test(branchName);
};

/**
 * Validate JIRA key
 */
exports.validateJiraKey = (key) => {
  return /^[A-Z]{2,10}(-\d+)?$/.test(key);
};

// ============= Git Utils =============

/**
 * Get current git branch
 */
exports.getCurrentBranch = () => {
  try {
    const { execSync } = require('child_process');
    return execSync('git branch --show-current', { encoding: 'utf8' }).trim();
  } catch {
    return null;
  }
};

/**
 * Check if working directory is clean
 */
exports.isWorkingDirectoryClean = () => {
  try {
    const { execSync } = require('child_process');
    const status = execSync('git status --porcelain', { encoding: 'utf8' });
    return status.trim() === '';
  } catch {
    return false;
  }
};

// ============= Common Hook Wrapper =============

/**
 * Standard hook execution wrapper
 */
exports.executeHook = async (hookName, handler) => {
  try {
    const input = this.readHookInput();
    const result = await handler(input);
    this.writeHookOutput(result);
    process.exit(0);
  } catch (error) {
    this.writeHookError(`${hookName}: ${error.message}`);
  }
};