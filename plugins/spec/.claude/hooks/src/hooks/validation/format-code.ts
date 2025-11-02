#!/usr/bin/env node

/**
 * Format Code Hook
 *
 * Automatically formats code before Write/Edit operations using
 * detected formatters (Prettier, Black, gofmt, rustfmt).
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import * as path from 'path';
import { BaseHook } from '../../core/base-hook';
import { fileExists } from '../../utils/file-utils';
import { HookContext } from '../../types';

const execAsync = promisify(exec);

/**
 * Format Code Hook
 */
export class FormatCodeHook extends BaseHook {
  constructor() {
    super('format-code');
  }

  async execute(context: HookContext): Promise<void> {
    const filePath = context.file_path;
    const tool = context.tool;

    // Only format on Write/Edit operations
    if (!filePath || (tool !== 'Write' && tool !== 'Edit')) {
      return;
    }

    // Detect and run formatter
    const formatter = this.detectFormatter(filePath);

    if (formatter) {
      try {
        await this.runFormatter(formatter, filePath);
        this.logger.info(`Formatted ${path.basename(filePath)} with ${formatter}`);
      } catch (error) {
        this.logger.warn(`Formatting failed for ${path.basename(filePath)}`, {
          formatter,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }
  }

  private detectFormatter(filePath: string): string | null {
    const ext = path.extname(filePath);

    // Check for Prettier (JS/TS/JSON/CSS/etc)
    if (['.js', '.ts', '.jsx', '.tsx', '.json', '.css', '.md'].includes(ext)) {
      if (
        fileExists(path.join(this.cwd, '.prettierrc')) ||
        fileExists(path.join(this.cwd, '.prettierrc.json')) ||
        fileExists(path.join(this.cwd, 'prettier.config.js'))
      ) {
        return 'prettier';
      }
    }

    // Python - Black
    if (ext === '.py') {
      return 'black';
    }

    // Go - gofmt
    if (ext === '.go') {
      return 'gofmt';
    }

    // Rust - rustfmt
    if (ext === '.rs') {
      return 'rustfmt';
    }

    return null;
  }

  private async runFormatter(formatter: string, filePath: string): Promise<void> {
    const commands: Record<string, string> = {
      prettier: `npx prettier --write "${filePath}"`,
      black: `black "${filePath}"`,
      gofmt: `gofmt -w "${filePath}"`,
      rustfmt: `rustfmt "${filePath}"`,
    };

    const command = commands[formatter];
    if (command) {
      await execAsync(command, { cwd: this.cwd });
    }
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new FormatCodeHook();
  await hook.run();
}

main();
