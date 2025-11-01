import { SpecterParser } from '../services/specterParser.js';
import chalk from 'chalk';
import * as fs from 'fs';
import * as path from 'path';

export async function validateProject(
  projectRoot: string,
  options: { fix?: boolean }
): Promise<void> {
  console.log(chalk.bold('\n🔍 Validating Specter Project...\n'));

  const parser = new SpecterParser(projectRoot);
  const config = parser.getConfig();
  let errors = 0;
  let warnings = 0;

  // Check directory structure
  console.log(chalk.cyan('Checking directory structure...'));

  const requiredDirs = [
    { path: config.specterDir, name: '.specter' },
    { path: config.stateDir, name: '.specter-state' },
    { path: config.memoryDir, name: '.specter-memory' },
  ];

  for (const dir of requiredDirs) {
    if (!fs.existsSync(dir.path)) {
      console.log(chalk.red(`  ✗ Missing directory: ${dir.name}`));
      errors++;

      if (options.fix) {
        fs.mkdirSync(dir.path, { recursive: true });
        console.log(chalk.green(`    ✓ Created ${dir.name}`));
      }
    } else {
      console.log(chalk.green(`  ✓ ${dir.name} exists`));
    }
  }

  // Check required files
  console.log(chalk.cyan('\nChecking required files...'));

  const requiredFiles = [
    { path: path.join(config.stateDir, 'current-session.md'), name: 'current-session.md' },
    { path: path.join(config.memoryDir, 'WORKFLOW-PROGRESS.md'), name: 'WORKFLOW-PROGRESS.md' },
  ];

  for (const file of requiredFiles) {
    if (!fs.existsSync(file.path)) {
      console.log(chalk.yellow(`  ⚠ Missing file: ${file.name}`));
      warnings++;
    } else {
      console.log(chalk.green(`  ✓ ${file.name} exists`));
    }
  }

  // Check features
  console.log(chalk.cyan('\nChecking features...'));

  const featureIds = parser.listFeatures();
  console.log(chalk.gray(`  Found ${featureIds.length} feature(s)`));

  for (const featureId of featureIds) {
    const id = featureId.match(/^\d{3}/)?.[0] || featureId;
    const feature = parser.getFeatureData(id);

    if (!feature) {
      console.log(chalk.red(`  ✗ Could not parse feature: ${featureId}`));
      errors++;
      continue;
    }

    // Check for spec.md
    const featureDir = path.join(config.featuresDir, featureId);
    const specPath = path.join(featureDir, 'spec.md');

    if (!fs.existsSync(specPath)) {
      console.log(chalk.yellow(`  ⚠ Missing spec.md for ${feature.name}`));
      warnings++;
    }

    // Check task consistency
    if (feature.tasks.length > 0) {
      const invalidTasks = feature.tasks.filter(t => !t.id || !t.title);
      if (invalidTasks.length > 0) {
        console.log(chalk.red(`  ✗ ${feature.name} has ${invalidTasks.length} invalid task(s)`));
        errors++;
      }
    }
  }

  // Check session state consistency
  console.log(chalk.cyan('\nChecking session state...'));

  const session = parser.parseSessionState();
  if (session) {
    if (session.currentFeature) {
      const featureExists = featureIds.some(f => f.startsWith(session.currentFeature!.id));
      if (!featureExists) {
        console.log(
          chalk.yellow(`  ⚠ Session references non-existent feature: ${session.currentFeature.id}`)
        );
        warnings++;
      } else {
        console.log(chalk.green(`  ✓ Session state is consistent`));
      }
    }
  } else {
    console.log(chalk.yellow('  ⚠ No session state found'));
    warnings++;
  }

  // Summary
  console.log(chalk.bold('\n📋 Validation Summary:\n'));

  if (errors === 0 && warnings === 0) {
    console.log(chalk.green('  ✓ Project is valid and healthy!\n'));
  } else {
    if (errors > 0) {
      console.log(chalk.red(`  ✗ ${errors} error(s) found`));
    }
    if (warnings > 0) {
      console.log(chalk.yellow(`  ⚠ ${warnings} warning(s) found`));
    }

    if (options.fix) {
      console.log(chalk.cyan('\n  Some issues were automatically fixed.'));
    } else {
      console.log(chalk.cyan('\n  Run with --fix to attempt automatic fixes.'));
    }
    console.log('');
  }
}
