#!/usr/bin/env node

/**
 * @fileoverview Aggregate Results Hook
 *
 * Aggregates results from parallel sub-agent executions when SubagentStop event fires.
 * Used primarily by spec:implement and spec:orchestrate when running parallel tasks.
 *
 * Features:
 * - Collects results from multiple parallel sub-agents
 * - Aggregates success/failure statistics
 * - Updates task completion in session state
 * - Provides summary of parallel execution
 * - Non-blocking (always exits 0)
 *
 * @requires fs
 * @requires path
 * @author Spec Plugin Team
 */

const fs = require('fs');
const path = require('path');

// Load common utilities
const hookUtils = path.join(__dirname, 'lib', 'hooks-common.js');
const {
  readHookInput,
  writeHookOutput,
  writeHookError,
  ensureDir,
  readJSON,
  writeJSON,
  loadState,
  saveState,
  findFeatureDir
} = fs.existsSync(hookUtils) ? require(hookUtils) : {
  // Fallback implementations if hooks-common.js not available
  readHookInput: () => {
    try {
      return JSON.parse(fs.readFileSync(0, 'utf8'));
    } catch {
      return null;
    }
  },
  writeHookOutput: (data) => {
    console.log(JSON.stringify(data, null, 2));
  },
  writeHookError: (message) => {
    console.error(JSON.stringify({
      type: 'error',
      message: message
    }, null, 2));
    process.exit(0);
  },
  ensureDir: (dir) => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  },
  readJSON: (filePath, defaultValue = null) => {
    try {
      if (!fs.existsSync(filePath)) return defaultValue;
      return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch {
      return defaultValue;
    }
  },
  writeJSON: (filePath, data) => {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
  }
};

/**
 * Load configuration from .spec-config.yml
 */
function loadConfig() {
  try {
    const configPath = path.join(process.cwd(), 'plugins/spec/.claude/.spec-config.yml');

    // Try to load YAML if js-yaml is available
    try {
      const yaml = require('js-yaml');
      const content = fs.readFileSync(configPath, 'utf8');
      return yaml.load(content);
    } catch {
      // Fallback to defaults if YAML parsing fails
      return getDefaultConfig();
    }
  } catch {
    return getDefaultConfig();
  }
}

function getDefaultConfig() {
  return {
    paths: {
      spec_root: '.spec',
      features: 'features',
      state: '.spec-state',
      memory: '.spec-memory'
    },
    naming: {
      feature_directory: '{id:000}-{slug}',
      files: {
        spec: 'spec.md',
        plan: 'plan.md',
        tasks: 'tasks.md'
      }
    }
  };
}

/**
 * Aggregate results from multiple sub-agents
 */
function aggregateResults(input) {
  const results = {
    total: 0,
    succeeded: 0,
    failed: 0,
    partial: 0,
    tasks: [],
    errors: [],
    duration: 0,
    summary: ''
  };

  // Parse subagent output if available
  if (input.output) {
    // Count task completions
    const completedMatches = input.output.match(/✅ Task .* completed?/gi) || [];
    const failedMatches = input.output.match(/❌ Task .* failed/gi) || [];
    const partialMatches = input.output.match(/⚠️ Task .* partially completed/gi) || [];

    results.succeeded = completedMatches.length;
    results.failed = failedMatches.length;
    results.partial = partialMatches.length;
    results.total = results.succeeded + results.failed + results.partial;

    // Extract task IDs if mentioned
    const taskIdMatches = input.output.match(/T\d{3}/g) || [];
    results.tasks = [...new Set(taskIdMatches)]; // Unique task IDs

    // Extract errors
    const errorMatches = input.output.match(/Error: .*/gi) || [];
    results.errors = errorMatches;

    // Extract duration if mentioned
    const durationMatch = input.output.match(/Duration: (\d+)s/i);
    if (durationMatch) {
      results.duration = parseInt(durationMatch[1]);
    }
  }

  // Generate summary
  if (results.total > 0) {
    results.summary = `Completed ${results.succeeded}/${results.total} tasks`;
    if (results.failed > 0) {
      results.summary += ` (${results.failed} failed)`;
    }
    if (results.partial > 0) {
      results.summary += ` (${results.partial} partial)`;
    }
  } else {
    results.summary = 'No tasks reported by sub-agent';
  }

  return results;
}

/**
 * Update session state with aggregated results
 */
function updateSessionState(config, results) {
  const statePath = path.join(process.cwd(), config.paths.state, 'current-session.md');

  if (!fs.existsSync(statePath)) {
    return; // No session to update
  }

  try {
    let content = fs.readFileSync(statePath, 'utf8');

    // Update task completion numbers if present
    if (results.succeeded > 0) {
      // Update pattern like "15/23 tasks complete"
      content = content.replace(
        /(\d+)\/(\d+) tasks complete/,
        (match, completed, total) => {
          const newCompleted = parseInt(completed) + results.succeeded;
          return `${newCompleted}/${total} tasks complete`;
        }
      );

      // Update percentage if present
      content = content.replace(
        /Progress: (\d+)%/,
        (match, percent) => {
          // Estimate new percentage (crude but functional)
          const increase = Math.floor((results.succeeded / results.total) * 20);
          const newPercent = Math.min(parseInt(percent) + increase, 100);
          return `Progress: ${newPercent}%`;
        }
      );
    }

    // Add execution summary
    const timestamp = new Date().toISOString();
    const summarySection = `
### Parallel Execution Summary (${timestamp})

- Tasks Completed: ${results.succeeded}/${results.total}
- Failed: ${results.failed}
- Partial: ${results.partial}
- Duration: ${results.duration}s
${results.errors.length > 0 ? '- Errors: ' + results.errors.length : ''}
`;

    // Append summary if not already present
    if (!content.includes('### Parallel Execution Summary')) {
      content += summarySection;
    }

    fs.writeFileSync(statePath, content);
  } catch (error) {
    // Silent fail - don't block on state update errors
  }
}

/**
 * Update metrics for parallel execution
 */
function updateMetrics(config, results) {
  const metricsPath = path.join(process.cwd(), config.paths.spec_root, '.metrics.json');

  try {
    const metrics = readJSON(metricsPath, {
      parallel_executions: 0,
      total_parallel_tasks: 0,
      successful_parallel_tasks: 0,
      failed_parallel_tasks: 0,
      last_parallel_execution: null
    });

    metrics.parallel_executions += 1;
    metrics.total_parallel_tasks += results.total;
    metrics.successful_parallel_tasks += results.succeeded;
    metrics.failed_parallel_tasks += results.failed;
    metrics.last_parallel_execution = new Date().toISOString();

    writeJSON(metricsPath, metrics);
  } catch {
    // Silent fail - metrics are optional
  }
}

/**
 * Main execution
 */
async function main() {
  try {
    const input = readHookInput();

    if (!input || input.event !== 'SubagentStop') {
      // Not our event - exit silently
      process.exit(0);
    }

    // Load configuration
    const config = loadConfig();

    // Aggregate results from sub-agent output
    const results = aggregateResults(input);

    // Update session state
    updateSessionState(config, results);

    // Update metrics
    updateMetrics(config, results);

    // Output aggregated results
    writeHookOutput({
      type: 'subagent-results-aggregated',
      summary: results.summary,
      details: {
        total_tasks: results.total,
        succeeded: results.succeeded,
        failed: results.failed,
        partial: results.partial,
        task_ids: results.tasks,
        duration: results.duration
      },
      message: `📊 ${results.summary}`
    });

    process.exit(0);
  } catch (error) {
    // Never block execution - fail silently
    writeHookError(`Failed to aggregate results: ${error.message}`);
  }
}

// Execute
main();