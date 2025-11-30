#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { HookOutputSchema } from '../lib/schema.js';
import { findSpecFile, getFrontmatter, countTasks, getArtifacts } from '../lib/utils.js';

async function main() {
  try {
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const specDir = path.join(projectDir, '.spec');
    
    // Ensure scaffolding exists
    // We check if specDir exists to decide if we are "initialized".
    // But if the prompt asks to "ensure scaffolding", we should probably just do it if it's a SessionStart that implies initialization?
    // No, `SessionStart` happens on every session. We shouldn't auto-create .spec if the user hasn't opted in via /orbit yet.
    // Wait, the prompt says "orbit-init should ensure .spec directory scaffolding and seed session state". 
    // AND "orbit-init.js ... currently exit immediately, so initialization safeguards ... never run."
    // This suggests it *should* run safeguards. 
    // IF the project is already using spec (has .spec), we ensure subdirs exist.
    // IF not, we report not initialized.
    
    let initialized = false;
    try {
      await fs.access(specDir);
      initialized = true;
    } catch {
      // Not initialized, check if we should initialize? 
      // The `orbit` command handles explicit initialization.
      // But maybe we should report "not initialized" context so the model knows.
    }

    if (initialized) {
      // Ensure subdirectories exist (safeguard)
      await fs.mkdir(path.join(specDir, 'features'), { recursive: true });
      await fs.mkdir(path.join(specDir, 'architecture'), { recursive: true });
      await fs.mkdir(path.join(specDir, 'archive'), { recursive: true });
      await fs.mkdir(path.join(specDir, 'state'), { recursive: true });

      // Seed session state if missing
      const sessionPath = path.join(specDir, 'state', 'session.json');
      try {
        await fs.access(sessionPath);
      } catch {
        await fs.writeFile(sessionPath, JSON.stringify({ feature: null }, null, 2));
      }
    }

    // Context gathering logic
    const featuresDir = path.join(specDir, 'features');
    const features = [];
    
    if (initialized) {
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
    }

    let suggestion = null;
    if (!initialized) {
      suggestion = "Run /orbit to initialize specification-driven development.";
    } else if (features.length === 0) {
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
      initialized,
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
    // Safe exit without context if error
    process.exit(0);
  }
}

main();
