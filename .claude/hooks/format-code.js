#!/usr/bin/env node

/**
 * @fileoverview Code Formatting Hook
 *
 * Auto-formats code files after Write/Edit tool operations using appropriate
 * formatters (Prettier, Black, gofmt, rustfmt, etc.).
 *
 * Features:
 * - Multi-language support (JS/TS, Python, Go, Rust, Ruby, Java, C/C++, YAML, MD)
 * - Automatic formatter detection
 * - Graceful degradation if formatter not installed
 * - Selective formatting (skips .flow/, node_modules, .git, minified files)
 * - **Security**: Properly quotes all shell command variables
 *
 * @requires child_process
 * @requires fs
 * @requires path
 * @requires util
 * @author Flow Plugin Team
 */

const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const util = require('util');

const execAsync = util.promisify(exec);

// File extension to formatter mapping
const FORMATTERS = {
  // JavaScript/TypeScript
  '.js': 'prettier --write',
  '.jsx': 'prettier --write',
  '.ts': 'prettier --write',
  '.tsx': 'prettier --write',
  '.json': 'prettier --write',

  // Python
  '.py': 'black --quiet',

  // Go
  '.go': 'gofmt -w',

  // Rust
  '.rs': 'rustfmt --quiet',

  // Ruby
  '.rb': 'rubocop -a --quiet',

  // Java
  '.java': 'google-java-format -i',

  // C/C++
  '.c': 'clang-format -i',
  '.cpp': 'clang-format -i',
  '.h': 'clang-format -i',

  // YAML/Markdown
  '.yaml': 'prettier --write',
  '.yml': 'prettier --write',
  '.md': 'prettier --write --prose-wrap always'
};

// Check if formatter is available
async function hasFormatter(command) {
  try {
    const baseCommand = command.split(' ')[0];
    await execAsync(`which "${baseCommand}"`);
    return true;
  } catch {
    return false;
  }
}

// Format a single file
async function formatFile(filePath) {
  const ext = path.extname(filePath);
  const formatter = FORMATTERS[ext];

  if (!formatter) {
    return { skipped: true, reason: 'No formatter configured' };
  }

  if (!(await hasFormatter(formatter))) {
    return { skipped: true, reason: `Formatter not installed: ${formatter.split(' ')[0]}` };
  }

  try {
    // Split formatter into command and args for safe execution
    const parts = formatter.split(' ');
    const command = parts[0];
    const args = parts.slice(1).join(' ');
    await execAsync(`"${command}" ${args} "${filePath}"`);
    return { formatted: true };
  } catch (error) {
    return { error: error.message };
  }
}

// Extract file path from tool output
function extractFilePath(toolOutput) {
  // Match various file operation patterns
  const patterns = [
    /File created successfully at: (.+)$/m,
    /File (.+) has been updated/m,
    /Writing to (.+)$/m,
    /Editing (.+)$/m
  ];

  for (const pattern of patterns) {
    const match = toolOutput.match(pattern);
    if (match) {
      return match[1].trim();
    }
  }

  return null;
}

// Main execution
async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));

    // Only process Write and Edit tool outputs
    if (!['Write', 'Edit'].includes(input.tool)) {
      process.exit(0);
    }

    const filePath = extractFilePath(input.output || '');
    if (!filePath) {
      process.exit(0); // Could not determine file path
    }

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      process.exit(0);
    }

    // Skip formatting for certain files
    const skipPatterns = [
      /\.flow\//,      // Skip .flow directory files
      /node_modules/,  // Skip dependencies
      /\.git/,         // Skip git files
      /\.min\./        // Skip minified files
    ];

    if (skipPatterns.some(pattern => pattern.test(filePath))) {
      process.exit(0);
    }

    // Format the file
    const result = await formatFile(filePath);

    if (result.formatted) {
      console.log(JSON.stringify({
        type: 'format-success',
        file: filePath,
        message: `✨ Auto-formatted ${path.basename(filePath)}`
      }));
    } else if (result.skipped) {
      // Silent skip - don't clutter output
    } else if (result.error) {
      console.error(JSON.stringify({
        type: 'format-error',
        file: filePath,
        error: result.error
      }));
    }

    process.exit(0);
  } catch (error) {
    // Silent fail - formatting is non-critical
    process.exit(0);
  }
}

main();