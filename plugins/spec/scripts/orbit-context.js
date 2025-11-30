#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { HookOutputSchema, ContextSchema } from '../lib/schema.js';
import { getFeatureContext } from '../lib/utils.js';

async function main() {
  try {
    // Read input from stdin
    const input = await new Promise((resolve) => {
      const stdin = process.stdin;
      let data = '';
      stdin.setEncoding('utf8');
      stdin.on('data', (chunk) => data += chunk);
      stdin.on('end', () => resolve(data));
      if (stdin.isTTY) resolve('');
    });

    if (!input) process.exit(0);

    let prompt = '';
    try {
      const data = JSON.parse(input);
      prompt = data.prompt || '';
    } catch {
      // Ignore parse errors
    }

    if (!prompt.startsWith('/orbit')) process.exit(0);

    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    
    // Get robust context
    const { features, suggestion } = await getFeatureContext(projectDir);

    // Check architecture presence
    const specDir = path.join(projectDir, '.spec');
    const archDir = path.join(specDir, 'architecture');
    let hasPrd = false;
    let hasTdd = false;
    
    try {
        await fs.access(path.join(archDir, 'product-requirements.md'));
        hasPrd = true;
    } catch {}
    
    try {
        await fs.access(path.join(archDir, 'technical-design.md'));
        hasTdd = true;
    } catch {}

    const context = {
      features,
      architecture: { has_prd: hasPrd, has_tdd: hasTdd },
      suggestion: suggestion || "Review workflow status"
    };

    // Validate context against schema (throws if invalid)
    ContextSchema.parse(context);

    const output = {
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext: JSON.stringify(context)
      }
    };

    // Validate output against schema
    HookOutputSchema.parse(output);

    console.log(JSON.stringify(output));

  } catch (error) {
    // Fallback: output safe minimal valid JSON if something explodes, or just exit.
    // Hook failure is usually ignored by Claude, but let's be safe.
    process.exit(0);
  }
}

main();