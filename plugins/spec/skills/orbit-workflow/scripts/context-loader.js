#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { ContextSchema } from '../../../lib/schema.js';
import { findSpecFile, getFrontmatter, countTasks, getArtifacts } from '../../../lib/utils.js';

async function main() {
  try {
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const specDir = path.join(projectDir, '.spec');

    try {
      await fs.access(specDir);
    } catch {
      console.log(JSON.stringify({
        suggestion: "Initialize Orbit",
        features: [],
        architecture: { has_prd: false, has_tdd: false }
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

    const archDir = path.join(specDir, 'architecture');
    const hasPrd = await fs.access(path.join(archDir, 'product-requirements.md')).then(() => true).catch(() => false);
    const hasTdd = await fs.access(path.join(archDir, 'technical-design.md')).then(() => true).catch(() => false);

    let suggestion = null;
    // ... (Suggestion logic same as orbit-context.js, can be extracted to shared lib if needed)
    // For now duplicating for simplicity as they are separate entry points
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
      features,
      architecture: { has_prd: hasPrd, has_tdd: hasTdd },
      suggestion
    };

    ContextSchema.parse(context);
    console.log(JSON.stringify(context));

  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

main();
