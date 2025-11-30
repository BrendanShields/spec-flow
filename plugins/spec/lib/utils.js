import fs from 'fs/promises';
import path from 'path';

export async function findSpecFile(featureDir) {
  const candidates = ['spec.md', 'SPEC.md', 'Spec.md', 'specs.md', 'SPECS.md', 'Specs.md'];
  for (const name of candidates) {
    const filePath = path.join(featureDir, name);
    try {
      await fs.access(filePath);
      return filePath;
    } catch {
      continue;
    }
  }
  return null;
}

export async function getFrontmatter(specPath) {
  if (!specPath) return {};
  try {
    const content = await fs.readFile(specPath, 'utf-8');
    if (!content.startsWith('---')) return {};
    
    const end = content.indexOf('---', 3);
    if (end === -1) return {};
    
    const frontmatterBlock = content.slice(3, end);
    const result = {};
    
    const lines = frontmatterBlock.split('\n');
    let currentKey = null;
    let currentObj = null; // For nested objects
    let inArray = false;

    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) continue;

      // Check for array item "- value"
      if (trimmed.startsWith('- ')) {
        if (currentKey && inArray) {
          if (!Array.isArray(result[currentKey])) result[currentKey] = [];
          result[currentKey].push(trimmed.slice(2).trim());
        }
        continue;
      }

      // Check for "key: value" or "key:"
      const colonIndex = line.indexOf(':');
      if (colonIndex !== -1) {
        // Determine indentation to check for nesting
        const indent = line.search(/\S/);
        
        const key = line.slice(indent, colonIndex).trim();
        const value = line.slice(colonIndex + 1).trim();

        if (indent > 0 && currentKey) {
          // Nested object property (e.g. progress: -> tasks_total:)
          if (!result[currentKey]) result[currentKey] = {};
          // If it was previously an array (ambiguous yaml), reset or handle?
          // Assuming simple schema: progress is object, tags is array.
          if (typeof result[currentKey] !== 'object') result[currentKey] = {};
          
          // Parse value (number check)
          result[currentKey][key] = isNaN(Number(value)) || value === '' ? value : Number(value);
        } else {
          // Top level key
          currentKey = key;
          if (value === '') {
            // Start of object or array
            // We'll guess array if next line starts with dash, else object
            // But we can't see next line easily here. 
            // Let's assume object for now, and set inArray flag if we see dashes later?
            // Actually, standard yaml parser would look ahead.
            // Let's just set it as empty string or null, and refine if children appear.
            result[key] = {}; // Default to object/container
            inArray = true; // Allow array items to append
          } else {
            // Scalar
            result[key] = isNaN(Number(value)) ? value : Number(value);
            inArray = false;
          }
        }
      }
    }
    
    // Clean up empty objects if they were actually scalars? No, simpler to strict schema.
    return result;
  } catch {
    return {};
  }
}

export async function countTasks(featureDir) {
  const tasksPath = path.join(featureDir, 'tasks.md');
  try {
    const content = await fs.readFile(tasksPath, 'utf-8');
    const total = (content.match(/- [ ]/g) || []).length + (content.match(/- [x]/g) || []).length;
    const done = (content.match(/- [x]/g) || []).length;
    return { total, done };
  } catch {
    return null;
  }
}

export async function getArtifacts(featureDir) {
  const artifacts = [];
  if (await findSpecFile(featureDir)) artifacts.push('spec.md');
  
  for (const name of ['plan.md', 'tasks.md', 'metrics.md']) {
    try {
      await fs.access(path.join(featureDir, name));
      artifacts.push(name);
    } catch {
      continue;
    }
  }
  return artifacts;
}

export async function getFeatureContext(projectDir) {
  const specDir = path.join(projectDir, '.spec');
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
    // Ignore if features dir doesn't exist or error reading
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

  return { features, suggestion };
}