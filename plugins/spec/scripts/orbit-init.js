#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { HookOutputSchema } from '../lib/schema.js';
import { findSpecFile, getFrontmatter, countTasks, getArtifacts } from '../lib/utils.js';

async function main() {
  try {
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const specDir = path.join(projectDir, '.spec');
    let initialized = false;

    try {
      await fs.access(specDir);
      initialized = true;
    } catch {
      const context = {
        initialized: false,
        features: [],
        suggestion: "Run /orbit to initialize specification-driven development."
      };
      console.log(JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "SessionStart",
          additionalContext: JSON.stringify(context)
        }
      }));
      process.exit(0);
    }

    const featuresDir = path.join(specDir, 'features');
    const features = [];
    
    try {
      const entries = await fs.readdir(featuresDir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        
        const featureDir = path.join(featuresDir, entry.name);
        const specPath = await findSpecFile(featureDir);
        const frontmatter = await getFrontmatter(specPath);
        const status = frontmatter.status || 'initialize';

        if (["initialize", "specification", "clarification", "planning", "implementation", "complete"].includes(status)) {
          const feature = {
            id: entry.name,
            title: frontmatter.title || entry.name,
            status,
            priority: frontmatter.priority || 'P2',
            artifacts: await getArtifacts(featureDir)
          };

          if (status === 'implementation' || status === 'complete') {
            const progress = await countTasks(featureDir);
            if (progress) feature.progress = progress;
          }

          features.push(feature);
        }
      }
    } catch {
      // Ignore
    }

    let suggestion = null;
    if (features.length === 0) {
      suggestion = "No active features. Start a new feature or analyze codebase for brownfield project.";
    } else {
      const priorityOrder = ["complete", "implementation", "planning", "clarification", "specification", "initialize"];
      
      for (const status of priorityOrder) {
        for (const f of features) {
          if (f.status === status) {
            if (status === "complete") {
              const done = f.progress?.done ?? '?';
              const total = f.progress?.total ?? '?';
              suggestion = `Archive completed feature '${f.title}' (${done}/${total} tasks)`;
            } else if (status === "implementation") {
              const done = f.progress?.done ?? 0;
              const total = f.progress?.total ?? '?';
              suggestion = `Continue implementing '${f.title}' (${done}/${total} tasks done)`;
            } else if (status === "planning") {
              suggestion = `Create tasks.md for '${f.title}'`;
            } else if (status === "clarification") {
              suggestion = `Resolve [CLARIFY] tags in '${f.title}' plan.md`;
            } else if (status === "specification") {
              suggestion = `Create plan.md for '${f.title}'`;
            } else {
              suggestion = `Create spec.md for '${f.title}'`;
            }
            break;
          }
        }
        if (suggestion) break;
      }
      if (!suggestion) suggestion = "Review features and continue work";
    }

    const context = {
      initialized: true,
      features,
      suggestion
    };

    const output = {
      hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: JSON.stringify(context)
      }
    };

    HookOutputSchema.parse(output);
    console.log(JSON.stringify(output));

  } catch (error) {
    process.exit(0);
  }
}

main();