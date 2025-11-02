#!/usr/bin/env node

/**
 * Validate Prerequisites Hook
 *
 * Validates that required tools and environment setup exists before
 * executing certain skills/commands.
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import { BaseHook } from '../../core/base-hook';
import { HookContext } from '../../types';

const execAsync = promisify(exec);

/**
 * Validate Prerequisites Hook
 */
export class ValidatePrerequisitesHook extends BaseHook {
  constructor() {
    super('validate-prerequisites');
  }

  async execute(context: HookContext): Promise<void> {
    const command = context.command;

    // Check if command requires validation
    if (!command || !this.requiresValidation(command as string)) {
      return;
    }

    // Validate based on command type
    const validationErrors: string[] = [];

    if (command.includes('spec:implement')) {
      // Check for common development tools
      await this.checkGit(validationErrors);
    }

    if (command.includes('build') || command.includes('test')) {
      await this.checkNodeModules(validationErrors);
    }

    // Report validation errors
    if (validationErrors.length > 0) {
      this.logger.warn('Prerequisites validation failed', {
        errors: validationErrors,
        suggestion: 'Install missing dependencies before continuing',
      });
    } else {
      this.logger.info('Prerequisites validated successfully');
    }
  }

  private requiresValidation(command: string): boolean {
    return (
      command.includes('spec:') || command.includes('build') || command.includes('test')
    );
  }

  private async checkGit(errors: string[]): Promise<void> {
    try {
      await execAsync('git --version');
    } catch {
      errors.push('Git is not installed or not in PATH');
    }
  }

  private async checkNodeModules(errors: string[]): Promise<void> {
    const fs = require('fs');
    const path = require('path');

    const nodeModulesPath = path.join(this.cwd, 'node_modules');
    if (!fs.existsSync(nodeModulesPath)) {
      errors.push('node_modules not found - run npm install');
    }
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new ValidatePrerequisitesHook();
  await hook.run();
}

main();
