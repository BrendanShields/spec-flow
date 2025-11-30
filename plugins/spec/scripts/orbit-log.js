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

    const filePath = toolInput.file_path;
    
    // Check if file is within a feature directory
    // Format: .spec/features/{feature-id}/{file}
    if (filePath.includes('.spec/features/')) {
      const match = filePath.match(/\.spec\/features\/([^/]+)\//);
      if (match) {
        const featureId = match[1];
        const featureDir = path.dirname(filePath).split(featureId)[0] + featureId;
        const metricsPath = path.join(featureDir, 'metrics.md');
        
        // Avoid infinite loop if we are writing to metrics.md
        if (filePath.endsWith('metrics.md')) process.exit(0);

        // Log activity
        try {
          const toolName = data.tool_name || 'Unknown Tool';
          const filename = path.basename(filePath);
          const timestamp = new Date().toISOString();
          const event = `${toolName} modified ${filename}`;
          const logLine = `| ${timestamp} | ${event} |`;

          // Read metrics.md
          let content = '';
          try {
            content = await fs.readFile(metricsPath, 'utf-8');
          } catch {
             // Feature might be new or metrics missing, skip
             process.exit(0);
          }

          const activityHeader = "## Activity";
          let newContent = content;

          if (content.includes(activityHeader)) {
             if (content.includes('| Timestamp | Event |')) {
                 if (content.includes('|-----------|-------|')) {
                     newContent = content.replace('|-----------|-------|', `|-----------|-------|\n${logLine}`);
                 } else {
                     newContent = content.replace('| Timestamp | Event |', `| Timestamp | Event |\n|-----------|-------|\n${logLine}`);
                 }
             } else {
                 newContent = content.replace(activityHeader, `${activityHeader}\n\n| Timestamp | Event |\n|-----------|-------|\n${logLine}`);
             }
          } else {
             newContent = content + `\n\n${activityHeader}\n\n| Timestamp | Event |\n|-----------|-------|\n${logLine}\n`;
          }

          await fs.writeFile(metricsPath, newContent);
        } catch (e) {
          // Ignore logging errors
        }
      }
    }
    
    process.exit(0);
  } catch (error) {
    process.exit(0);
  }
}

main();