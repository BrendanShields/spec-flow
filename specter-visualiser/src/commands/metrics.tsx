import React from 'react';
import { render } from 'ink';
import { MetricsView } from '../components/MetricsView.js';
import * as fs from 'fs';
import * as path from 'path';
import { SpecterParser } from '../services/specterParser.js';
import { MetricsCalculator } from '../services/metricsCalculator.js';

export async function renderMetrics(
  projectRoot: string,
  options: { feature?: string; export?: string }
): Promise<void> {
  if (options.export) {
    await exportMetrics(projectRoot, options.export, options.feature);
    return;
  }

  const { waitUntilExit } = render(
    <MetricsView projectRoot={projectRoot} featureId={options.feature} />
  );
  await waitUntilExit();
}

async function exportMetrics(
  projectRoot: string,
  format: string,
  featureId?: string
): Promise<void> {
  const parser = new SpecterParser(projectRoot);
  const calculator = new MetricsCalculator();

  if (featureId) {
    const feature = parser.getFeatureData(featureId);
    if (!feature) {
      console.error(`Feature ${featureId} not found`);
      return;
    }

    const metrics = calculator.calculateFeatureMetrics(
      feature.spec?.userStories || [],
      feature.tasks
    );

    const data = {
      featureId: feature.id,
      featureName: feature.name,
      metrics,
    };

    if (format === 'json') {
      console.log(JSON.stringify(data, null, 2));
    } else if (format === 'csv') {
      console.log('Feature,Total Stories,Total Tasks,Completed Tasks,In Progress,Blocked');
      console.log(
        `${feature.name},${metrics.stories.total},${metrics.tasks.total},${metrics.tasks.completed},${metrics.tasks.inProgress},${metrics.tasks.blocked}`
      );
    }
  } else {
    const progress = parser.parseWorkflowProgress();
    if (!progress) {
      console.error('No workflow progress data found');
      return;
    }

    if (format === 'json') {
      console.log(JSON.stringify(progress.totalMetrics, null, 2));
    } else if (format === 'csv') {
      console.log('Total Features,Completed Features,Total Tasks,Completed Tasks,Completion Rate');
      console.log(
        `${progress.totalMetrics.totalFeatures},${progress.totalMetrics.completedFeatures},${progress.totalMetrics.totalTasks},${progress.totalMetrics.completedTasks},${progress.totalMetrics.completionRate}`
      );
    }
  }
}
