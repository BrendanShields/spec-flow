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
    
    const frontmatter = {};
    const lines = content.slice(3, end).split('\n');
    for (const line of lines) {
      const colonIndex = line.indexOf(':');
      if (colonIndex !== -1) {
        const key = line.slice(0, colonIndex).trim();
        const value = line.slice(colonIndex + 1).trim();
        frontmatter[key] = value;
      }
    }
    return frontmatter;
  } catch {
    return {};
  }
}

export async function countTasks(featureDir) {
  const tasksPath = path.join(featureDir, 'tasks.md');
  try {
    const content = await fs.readFile(tasksPath, 'utf-8');
    const total = (content.match(/- \[ \]/g) || []).length + (content.match(/- \[x\]/g) || []).length;
    const done = (content.match(/- \[x\]/g) || []).length;
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
