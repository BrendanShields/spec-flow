import { SpecParser } from '../services/specParser.js';
import chalk from 'chalk';
import Table from 'cli-table3';
import { WorkflowPhase } from '../types/spec.js';

export async function listFeatures(
  projectRoot: string,
  options: { status?: string }
): Promise<void> {
  const parser = new SpecParser(projectRoot);
  const featureIds = parser.listFeatures();

  if (featureIds.length === 0) {
    console.log(chalk.yellow('No features found in this project.'));
    return;
  }

  const table = new Table({
    head: [
      chalk.cyan('ID'),
      chalk.cyan('Name'),
      chalk.cyan('Status'),
      chalk.cyan('Tasks'),
      chalk.cyan('Completed'),
    ],
    colWidths: [10, 40, 20, 10, 12],
  });

  for (const featureId of featureIds) {
    const id = featureId.match(/^\d{3}/)?.[0] || featureId;
    const feature = parser.getFeatureData(id);

    if (!feature) continue;

    if (options.status && feature.status !== options.status) {
      continue;
    }

    const statusColor = getStatusColor(feature.status);
    const completionRate =
      feature.tasks.length > 0
        ? ((feature.tasks.filter(t => t.status === 'completed').length / feature.tasks.length) * 100).toFixed(0)
        : '0';

    table.push([
      chalk.bold(feature.id),
      feature.name,
      statusColor(feature.status),
      feature.tasks.length.toString(),
      `${completionRate}%`,
    ]);
  }

  console.log('\n' + table.toString() + '\n');
}

function getStatusColor(status: WorkflowPhase): (text: string) => string {
  switch (status) {
    case 'completed':
      return chalk.green;
    case 'implementation':
      return chalk.blue;
    case 'planning':
    case 'task-breakdown':
      return chalk.yellow;
    default:
      return chalk.gray;
  }
}
