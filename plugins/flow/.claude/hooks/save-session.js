#!/usr/bin/env node

/**
 * Session Save Hook
 * Saves workflow state at end of session for continuity
 */

const fs = require('fs');
const path = require('path');

const SESSION_FILE = '.flow/.session.json';

async function saveSession(context) {
  const sessionPath = path.join(process.cwd(), SESSION_FILE);

  // Ensure .flow directory exists
  const flowDir = path.dirname(sessionPath);
  if (!fs.existsSync(flowDir)) {
    fs.mkdirSync(flowDir, { recursive: true });
  }

  // Gather session data
  const session = {
    timestamp: new Date().toISOString(),
    workingDirectory: process.cwd(),
    lastActivity: context.lastCommand || 'Unknown',
    duration: context.sessionDuration || 0,

    // Workflow state
    workflow: {
      currentFeature: findCurrentFeature(),
      lastModifiedFiles: findRecentlyModified(),
      pendingTasks: findPendingTasks()
    },

    // Environment
    environment: {
      nodeVersion: process.version,
      platform: process.platform,
      flowVersion: getFlowVersion()
    }
  };

  // Save session
  fs.writeFileSync(sessionPath, JSON.stringify(session, null, 2));

  return session;
}

function findCurrentFeature() {
  try {
    const featuresDir = path.join(process.cwd(), 'features');
    if (!fs.existsSync(featuresDir)) return null;

    const features = fs.readdirSync(featuresDir)
      .filter(f => fs.statSync(path.join(featuresDir, f)).isDirectory())
      .sort((a, b) => {
        // Sort by modification time
        const aStat = fs.statSync(path.join(featuresDir, a));
        const bStat = fs.statSync(path.join(featuresDir, b));
        return bStat.mtime - aStat.mtime;
      });

    return features[0] || null;
  } catch {
    return null;
  }
}

function findRecentlyModified() {
  const files = [];
  const cutoff = Date.now() - (60 * 60 * 1000); // Last hour

  function scanDir(dir, depth = 0) {
    if (depth > 3) return; // Limit recursion depth

    try {
      const entries = fs.readdirSync(dir);
      for (const entry of entries) {
        // Skip certain directories
        if (['.git', 'node_modules', '.flow'].includes(entry)) continue;

        const fullPath = path.join(dir, entry);
        const stat = fs.statSync(fullPath);

        if (stat.isFile() && stat.mtime.getTime() > cutoff) {
          files.push({
            path: fullPath.replace(process.cwd() + '/', ''),
            modified: stat.mtime.toISOString()
          });
        } else if (stat.isDirectory()) {
          scanDir(fullPath, depth + 1);
        }
      }
    } catch {
      // Ignore permission errors
    }
  }

  scanDir(process.cwd());
  return files.slice(0, 10); // Return top 10 most recent
}

function findPendingTasks() {
  try {
    // Look for tasks.md files
    const locations = [
      'tasks.md',
      'features/*/tasks.md'
    ];

    for (const pattern of locations) {
      if (pattern.includes('*')) {
        const featuresDir = path.join(process.cwd(), 'features');
        if (fs.existsSync(featuresDir)) {
          const features = fs.readdirSync(featuresDir);
          for (const feature of features) {
            const tasksPath = path.join(featuresDir, feature, 'tasks.md');
            if (fs.existsSync(tasksPath)) {
              return countPendingTasks(tasksPath);
            }
          }
        }
      } else {
        const tasksPath = path.join(process.cwd(), pattern);
        if (fs.existsSync(tasksPath)) {
          return countPendingTasks(tasksPath);
        }
      }
    }
  } catch {
    return { total: 0, pending: 0, completed: 0 };
  }

  return { total: 0, pending: 0, completed: 0 };
}

function countPendingTasks(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  let total = 0;
  let completed = 0;

  for (const line of lines) {
    if (line.match(/^-\s+\[\s*\]/)) {
      total++;
    } else if (line.match(/^-\s+\[x\]/i)) {
      total++;
      completed++;
    }
  }

  return {
    total,
    completed,
    pending: total - completed,
    progress: total > 0 ? Math.round((completed / total) * 100) : 0
  };
}

function getFlowVersion() {
  try {
    const pluginPath = path.join(__dirname, '../../..', '.claude-plugin', 'plugin.json');
    if (fs.existsSync(pluginPath)) {
      const plugin = JSON.parse(fs.readFileSync(pluginPath, 'utf8'));
      return plugin.version || 'Unknown';
    }
  } catch {
    // Ignore errors
  }
  return 'Unknown';
}

// Main execution
async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));
    const session = await saveSession(input.context || {});

    console.log(JSON.stringify({
      type: 'session-saved',
      message: '💾 Session saved successfully',
      summary: {
        feature: session.workflow.currentFeature,
        tasks: session.workflow.pendingTasks,
        filesModified: session.workflow.lastModifiedFiles.length
      }
    }, null, 2));

    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: error.message
    }));
    process.exit(0);
  }
}

main();