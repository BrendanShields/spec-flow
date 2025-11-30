#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';

async function main() {
  try {
    const input = await new Promise((resolve) => {
      const stdin = process.stdin;
      let data = '';
      stdin.setEncoding('utf8');
      stdin.on('data', (chunk) => data += chunk);
      stdin.on('end', () => resolve(data));
      if (stdin.isTTY) resolve('');
    });

    if (!input) process.exit(0);

    const data = JSON.parse(input);
    const toolInput = data.tool_input;
    
    if (!toolInput || !toolInput.file_path) process.exit(0);

    const normalizedPath = path.normalize(toolInput.file_path);
    
    // Protection Rule 1: No editing archived features
    if (normalizedPath.includes('.spec/archive/')) {
      console.error("Error: Cannot modify archived features directly. Restore the feature first.");
      process.exit(1); // Block the tool use
    }

    // Protection Rule 2: Warn on manual status change in spec.md (Advanced, maybe skip for now)
    // Just blocking archive is good for "protected artifacts".

    process.exit(0); // Allow
  } catch (error) {
    process.exit(0); // Fail open if error parsing
  }
}

main();