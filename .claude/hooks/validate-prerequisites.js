#!/usr/bin/env node

/**
 * @fileoverview Prerequisite Validation Hook
 *
 * Ensures workflow prerequisites are met before Flow skill execution.
 * Prevents users from running skills in the wrong order by checking for
 * required artifacts (spec.md, plan.md, tasks.md, etc.).
 *
 * Features:
 * - Required file validation (blocks execution if missing)
 * - Optional file warnings (suggests but doesn't block)
 * - anyOf validation (requires at least one from a set)
 * - Helpful suggestions for resolving missing prerequisites
 * - Supports glob patterns for flexible file locations
 *
 * @requires fs
 * @requires path
 * @author Flow Plugin Team
 */

const fs = require('fs');
const path = require('path');

// Skill prerequisites mapping
const PREREQUISITES = {
  'flow:clarify': {
    required: ['spec.md'],
    message: 'Specification must exist before clarification'
  },
  'flow:plan': {
    required: ['spec.md'],
    optional: ['architecture-blueprint.md'],
    message: 'Specification required for planning'
  },
  'flow:tasks': {
    required: ['spec.md'],
    optional: ['plan.md'],
    message: 'Specification (and ideally plan) required for task generation'
  },
  'flow:implement': {
    required: ['tasks.md'],
    message: 'Tasks must be generated before implementation'
  },
  'flow:analyze': {
    required: ['spec.md'],
    anyOf: ['plan.md', 'tasks.md'],
    message: 'Need artifacts to analyze'
  }
};

// File location patterns
const FILE_PATTERNS = {
  'spec.md': [
    'features/*/spec.md',
    'spec.md'
  ],
  'plan.md': [
    'features/*/plan.md',
    'plan.md'
  ],
  'tasks.md': [
    'features/*/tasks.md',
    'tasks.md'
  ],
  'architecture-blueprint.md': [
    '.flow/architecture-blueprint.md'
  ]
};

/**
 * Validates that all prerequisites for a skill are met
 *
 * Checks for required files, optional files, and anyOf requirements.
 * Returns validation results with helpful error messages and suggestions.
 *
 * @async
 * @param {string} skillName - Name of the Flow skill being executed (e.g., 'flow:plan')
 * @param {Object} context - Hook execution context
 * @param {string} [context.workingDir] - Working directory (defaults to process.cwd())
 * @returns {Promise<Object>} Validation results
 * @returns {boolean} return.valid - Whether all prerequisites are met
 * @returns {string[]} return.missing - Array of missing required files
 * @returns {string[]} return.warnings - Array of warning messages for optional files
 * @returns {string} return.message - Human-readable explanation
 * @returns {string} return.suggestion - Suggested command to resolve issues
 *
 * @example
 * const result = await validatePrerequisites('flow:plan', { workingDir: '/app' });
 * if (!result.valid) {
 *   console.error(result.message);
 *   console.log(`Suggestion: ${result.suggestion}`);
 * }
 */
async function validatePrerequisites(skillName, context) {
  const prereqs = PREREQUISITES[skillName];
  if (!prereqs) {
    return { valid: true }; // No prerequisites defined
  }

  const missing = [];
  const warnings = [];

  // Check required files
  if (prereqs.required) {
    for (const file of prereqs.required) {
      if (!findFile(file, context)) {
        missing.push(file);
      }
    }
  }

  // Check optional files
  if (prereqs.optional) {
    for (const file of prereqs.optional) {
      if (!findFile(file, context)) {
        warnings.push(`Optional: ${file} not found (recommended but not required)`);
      }
    }
  }

  // Check anyOf requirements
  if (prereqs.anyOf) {
    const found = prereqs.anyOf.some(file => findFile(file, context));
    if (!found) {
      missing.push(`One of: ${prereqs.anyOf.join(', ')}`);
    }
  }

  return {
    valid: missing.length === 0,
    missing,
    warnings,
    message: prereqs.message,
    suggestion: getSuggestion(skillName, missing)
  };
}

function findFile(fileName, context) {
  const patterns = FILE_PATTERNS[fileName] || [fileName];
  const baseDir = context.workingDir || process.cwd();

  for (const pattern of patterns) {
    // Handle glob patterns
    if (pattern.includes('*')) {
      const parts = pattern.split('*');
      const dir = path.join(baseDir, parts[0]);

      if (fs.existsSync(dir) && fs.statSync(dir).isDirectory()) {
        const files = fs.readdirSync(dir, { recursive: true });
        const targetFile = parts[1].replace('/', '');

        if (files.some(f => f.endsWith(targetFile))) {
          return true;
        }
      }
    } else {
      // Direct file path
      const filePath = path.join(baseDir, pattern);
      if (fs.existsSync(filePath)) {
        return true;
      }
    }
  }

  return false;
}

function getSuggestion(skillName, missing) {
  const suggestions = {
    'flow:plan': 'Run flow:specify first to create a specification',
    'flow:tasks': 'Run flow:plan first to create technical plan',
    'flow:implement': 'Run flow:tasks first to generate task list',
    'flow:analyze': 'Create specification and plan first',
    'flow:clarify': 'Run flow:specify to create initial specification'
  };

  return suggestions[skillName] || `Create missing files: ${missing.join(', ')}`;
}

// Main execution
async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));

    // Extract skill name from tool use
    const skillMatch = input.command?.match(/^flow:(\w+)/);
    if (!skillMatch) {
      process.exit(0); // Not a Flow skill
    }

    const skillName = `flow:${skillMatch[1]}`;
    const result = await validatePrerequisites(skillName, input.context || {});

    if (!result.valid) {
      console.error(JSON.stringify({
        type: 'validation-error',
        skill: skillName,
        missing: result.missing,
        message: result.message,
        suggestion: result.suggestion,
        warnings: result.warnings
      }, null, 2));

      process.exit(1); // Block execution
    }

    if (result.warnings?.length > 0) {
      console.log(JSON.stringify({
        type: 'validation-warning',
        warnings: result.warnings
      }, null, 2));
    }

    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: error.message
    }));
    process.exit(0); // Don't block on errors
  }
}

main();