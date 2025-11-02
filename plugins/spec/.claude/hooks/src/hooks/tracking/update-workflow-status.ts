#!/usr/bin/env node

/**
 * Update Workflow Status Hook
 *
 * Updates workflow state after tool executions to maintain
 * current session state and progress tracking.
 */

import * as fs from 'fs';
import * as path from 'path';
import { BaseHook } from '../../core/base-hook';
import { resolveStateFile, resolveMemoryFile } from '../../core/path-resolver';
import { ensureDirectory, fileExists } from '../../utils/file-utils';
import { HookContext, WorkflowPhase } from '../../types';

interface WorkflowState {
  feature: string | null;
  phase: WorkflowPhase | null;
  progress: number;
  tasksComplete: number;
  tasksTotal: number;
  lastUpdated: string;
}

/**
 * Update Workflow Status Hook
 */
export class UpdateWorkflowStatusHook extends BaseHook {
  constructor() {
    super('update-workflow-status');
  }

  async execute(context: HookContext): Promise<void> {
    const command = context.command;

    if (!command) return;

    // Update state based on command
    const stateFile = resolveStateFile(this.config, 'current-session.md', this.cwd);
    const progressFile = resolveMemoryFile(this.config, 'WORKFLOW-PROGRESS.md', this.cwd);

    ensureDirectory(path.dirname(stateFile));
    ensureDirectory(path.dirname(progressFile));

    // Extract phase from command
    const phase = this.extractPhase(command as string);

    if (phase) {
      await this.updateState(stateFile, phase);
      await this.updateProgress(progressFile, phase, command as string);

      this.logger.info(`Workflow status updated: ${phase}`);
    }
  }

  private extractPhase(command: string): WorkflowPhase | null {
    if (command.includes('init')) return 'initialize';
    if (command.includes('generate') || command.includes('specify')) return 'generate';
    if (command.includes('clarify')) return 'clarify';
    if (command.includes('plan')) return 'plan';
    if (command.includes('tasks')) return 'tasks';
    if (command.includes('implement')) return 'implement';
    if (command.includes('validate')) return 'validate';
    if (command.includes('complete')) return 'complete';

    return null;
  }

  private async updateState(stateFile: string, phase: WorkflowPhase): Promise<void> {
    const state: WorkflowState = fileExists(stateFile)
      ? this.parseStateFile(stateFile)
      : {
          feature: null,
          phase: null,
          progress: 0,
          tasksComplete: 0,
          tasksTotal: 0,
          lastUpdated: new Date().toISOString(),
        };

    state.phase = phase;
    state.lastUpdated = new Date().toISOString();

    // Update progress based on phase
    const phaseProgress: Record<WorkflowPhase, number> = {
      initialize: 10,
      generate: 25,
      clarify: 35,
      plan: 50,
      tasks: 60,
      implement: 80,
      validate: 90,
      complete: 100,
    };

    state.progress = phaseProgress[phase] || 0;

    // Write state file
    const content = `# Current Session

**Current Feature:** ${state.feature || 'None'}
**Current Phase:** ${state.phase}
**Progress:** ${state.progress}%
**Tasks:** ${state.tasksComplete}/${state.tasksTotal}
**Last Updated:** ${state.lastUpdated}
`;

    fs.writeFileSync(stateFile, content, 'utf8');
  }

  private parseStateFile(stateFile: string): WorkflowState {
    const content = fs.readFileSync(stateFile, 'utf8');

    const state: WorkflowState = {
      feature: null,
      phase: null,
      progress: 0,
      tasksComplete: 0,
      tasksTotal: 0,
      lastUpdated: new Date().toISOString(),
    };

    content.split('\n').forEach((line) => {
      if (line.includes('Current Feature:')) {
        state.feature = line.split(':')[1]?.trim() ?? null;
      } else if (line.includes('Current Phase:')) {
        const phase = line.split(':')[1]?.trim() as WorkflowPhase;
        state.phase = phase;
      } else if (line.includes('Progress:')) {
        const match = line.match(/(\d+)%/);
        state.progress = match ? parseInt(match[1] ?? '0') : 0;
      } else if (line.includes('Tasks:')) {
        const match = line.match(/(\d+)\/(\d+)/);
        if (match) {
          state.tasksComplete = parseInt(match[1] ?? '0');
          state.tasksTotal = parseInt(match[2] ?? '0');
        }
      }
    });

    return state;
  }

  private async updateProgress(
    progressFile: string,
    phase: WorkflowPhase,
    command: string
  ): Promise<void> {
    const timestamp = new Date().toISOString();
    const entry = `\n- [${timestamp}] **${phase}**: ${command}`;

    if (fileExists(progressFile)) {
      fs.appendFileSync(progressFile, entry);
    } else {
      const content = `# Workflow Progress\n${entry}`;
      fs.writeFileSync(progressFile, content, 'utf8');
    }
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new UpdateWorkflowStatusHook();
  await hook.run();
}

main();
