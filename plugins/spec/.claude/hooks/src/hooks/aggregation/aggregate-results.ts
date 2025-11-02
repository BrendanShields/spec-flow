#!/usr/bin/env node

/**
 * Aggregate Results Hook
 *
 * Aggregates results from multiple subagent executions,
 * combining outputs and providing summary statistics.
 */

import { BaseHook } from '../../core/base-hook';
import { resolveMemoryFile } from '../../core/path-resolver';
import { writeFile, readJSON, fileExists, ensureDirectory } from '../../utils/file-utils';
import { HookContext } from '../../types';
import * as path from 'path';

interface SubagentResult {
  agent: string;
  status: 'success' | 'failure';
  output: string;
  duration: number;
  timestamp: string;
}

interface AggregatedResults {
  totalAgents: number;
  successful: number;
  failed: number;
  totalDuration: number;
  results: SubagentResult[];
  summary: string;
}

/**
 * Aggregate Results Hook
 */
export class AggregateResultsHook extends BaseHook {
  constructor() {
    super('aggregate-results');
  }

  async execute(context: HookContext): Promise<void> {
    const agent = context.agent;
    const output = context.output;

    if (!agent) return;

    // Record this subagent's result
    const result: SubagentResult = {
      agent,
      status: this.detectStatus(output || ''),
      output: output || '',
      duration: 0, // Could be extracted from context if available
      timestamp: new Date().toISOString(),
    };

    // Load existing results
    const resultsFile = resolveMemoryFile(this.config, '.subagent-results.json', this.cwd);
    ensureDirectory(path.dirname(resultsFile));

    let results: SubagentResult[] = [];
    if (fileExists(resultsFile)) {
      try {
        results = readJSON<SubagentResult[]>(resultsFile);
      } catch {
        results = [];
      }
    }

    // Add new result
    results.push(result);

    // Aggregate
    const aggregated = this.aggregate(results);

    // Save results
    const fs = require('fs');
    fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));

    // Generate summary report
    const summaryFile = resolveMemoryFile(this.config, 'SUBAGENT-SUMMARY.md', this.cwd);
    this.generateSummaryReport(summaryFile, aggregated);

    this.logger.info('Subagent results aggregated', {
      total: aggregated.totalAgents,
      successful: aggregated.successful,
      failed: aggregated.failed,
    });
  }

  private detectStatus(output: string): 'success' | 'failure' {
    if (
      output.includes('error') ||
      output.includes('failed') ||
      output.includes('Error:')
    ) {
      return 'failure';
    }
    return 'success';
  }

  private aggregate(results: SubagentResult[]): AggregatedResults {
    const successful = results.filter((r) => r.status === 'success').length;
    const failed = results.filter((r) => r.status === 'failure').length;
    const totalDuration = results.reduce((sum, r) => sum + r.duration, 0);

    return {
      totalAgents: results.length,
      successful,
      failed,
      totalDuration,
      results,
      summary: this.generateSummary(results, successful, failed),
    };
  }

  private generateSummary(
    results: SubagentResult[],
    successful: number,
    failed: number
  ): string {
    const total = results.length;
    const successRate = total > 0 ? Math.round((successful / total) * 100) : 0;

    return `${successful}/${total} agents successful (${successRate}%), ${failed} failed`;
  }

  private generateSummaryReport(file: string, aggregated: AggregatedResults): void {
    const content = `# Subagent Execution Summary

**Total Agents:** ${aggregated.totalAgents}
**Successful:** ${aggregated.successful}
**Failed:** ${aggregated.failed}
**Total Duration:** ${aggregated.totalDuration}s

## Summary
${aggregated.summary}

## Individual Results

${aggregated.results
  .map(
    (r, i) => `### ${i + 1}. ${r.agent}
**Status:** ${r.status}
**Timestamp:** ${r.timestamp}
**Duration:** ${r.duration}s

<details>
<summary>Output</summary>

\`\`\`
${r.output.substring(0, 500)}${r.output.length > 500 ? '...' : ''}
\`\`\`

</details>
`
  )
  .join('\n')}

---
*Generated at ${new Date().toISOString()}*
`;

    writeFile(file, content);
  }
}

// Main execution
async function main(): Promise<void> {
  const hook = new AggregateResultsHook();
  await hook.run();
}

main();
