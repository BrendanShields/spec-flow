#!/usr/bin/env node

import { Command } from 'commander';
import * as path from 'path';
import * as fs from 'fs';
import { SpecterParser } from './services/specterParser.js';
import { renderDashboard } from './commands/dashboard.js';
import { renderSpecs } from './commands/specs.js';
import { renderMetrics } from './commands/metrics.js';
import { renderWatch } from './commands/watch.js';
import { listFeatures } from './commands/list.js';
import { validateProject } from './commands/validate.js';

const program = new Command();

program
  .name('specter-viz')
  .description('CLI tool to visualize and track Specter workflow')
  .version('1.0.0');

// Find project root (look for .specter directory)
function findProjectRoot(startPath: string = process.cwd()): string | null {
  let currentPath = path.resolve(startPath);

  while (currentPath !== path.parse(currentPath).root) {
    if (fs.existsSync(path.join(currentPath, '.specter'))) {
      return currentPath;
    }
    currentPath = path.dirname(currentPath);
  }

  return null;
}

// Dashboard command (default)
program
  .command('dashboard', { isDefault: true })
  .description('Display interactive workflow dashboard')
  .option('-p, --project <path>', 'Project root directory')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project. Run this command in a project with .specter directory.');
      process.exit(1);
    }

    const parser = new SpecterParser(projectRoot);
    if (!parser.isInitialized()) {
      console.error('Error: Specter not initialized in this project. Run /specter-init first.');
      process.exit(1);
    }

    await renderDashboard(projectRoot);
  });

// Specs command
program
  .command('specs')
  .description('Browse and view feature specifications')
  .option('-p, --project <path>', 'Project root directory')
  .option('-f, --feature <id>', 'Feature ID to view')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    await renderSpecs(projectRoot, options.feature);
  });

// Metrics command
program
  .command('metrics')
  .description('Display workflow metrics and analytics')
  .option('-p, --project <path>', 'Project root directory')
  .option('-f, --feature <id>', 'Feature ID for specific metrics')
  .option('--export <format>', 'Export metrics (json, csv)')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    await renderMetrics(projectRoot, options);
  });

// Watch command
program
  .command('watch')
  .description('Watch for real-time changes in Specter files')
  .option('-p, --project <path>', 'Project root directory')
  .option('-v, --verbose', 'Show verbose output')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    await renderWatch(projectRoot, options);
  });

// List command
program
  .command('list')
  .description('List all features in the project')
  .option('-p, --project <path>', 'Project root directory')
  .option('--status <status>', 'Filter by status')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    await listFeatures(projectRoot, options);
  });

// Validate command
program
  .command('validate')
  .description('Validate Specter project structure and consistency')
  .option('-p, --project <path>', 'Project root directory')
  .option('--fix', 'Attempt to fix common issues')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    await validateProject(projectRoot, options);
  });

// Status command (quick overview)
program
  .command('status')
  .description('Quick status overview')
  .option('-p, --project <path>', 'Project root directory')
  .action(async (options) => {
    const projectRoot = options.project || findProjectRoot();

    if (!projectRoot) {
      console.error('Error: Not in a Specter project.');
      process.exit(1);
    }

    const parser = new SpecterParser(projectRoot);
    const session = parser.parseSessionState();
    const progress = parser.parseWorkflowProgress();

    console.log('\n📊 Specter Status\n');

    if (session) {
      console.log(`Phase: ${session.currentPhase}`);
      if (session.currentFeature) {
        console.log(`Feature: ${session.currentFeature.name} (${session.currentFeature.id})`);
      }
      console.log(`Tasks: ${session.tasksProgress.completed}/${session.tasksProgress.total} completed`);
    }

    if (progress) {
      console.log(`\nTotal Features: ${progress.totalMetrics.totalFeatures}`);
      console.log(`Completion Rate: ${progress.totalMetrics.completionRate.toFixed(1)}%`);
    }

    console.log('');
  });

program.parse();
