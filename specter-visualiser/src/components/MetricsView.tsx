import React, { useState, useEffect } from 'react';
import { Box, Text, useInput, useApp } from 'ink';
import { SpecterParser } from '../services/specterParser.js';
import { MetricsCalculator } from '../services/metricsCalculator.js';
import { WorkflowMetrics, FeatureData } from '../types/specter.js';

interface MetricsViewProps {
  projectRoot: string;
  featureId?: string;
}

export const MetricsView: React.FC<MetricsViewProps> = ({ projectRoot, featureId }) => {
  const { exit } = useApp();
  const [metrics, setMetrics] = useState<WorkflowMetrics | null>(null);
  const [feature, setFeature] = useState<FeatureData | null>(null);
  const [velocity, setVelocity] = useState<number>(0);

  const parser = new SpecterParser(projectRoot);
  const calculator = new MetricsCalculator();

  useEffect(() => {
    loadMetrics();
  }, []);

  const loadMetrics = () => {
    if (featureId) {
      const featureData = parser.getFeatureData(featureId);
      setFeature(featureData);
    } else {
      const progress = parser.parseWorkflowProgress();
      if (progress) {
        setMetrics(progress.totalMetrics);
        const vel = calculator.calculateVelocity(progress.features, 7);
        setVelocity(vel);
      }
    }
  };

  useInput((input, key) => {
    if (input === 'q' || key.escape) {
      exit();
    }
  });

  const renderProgressBar = (completed: number, total: number, width: number = 30) => {
    const percentage = total > 0 ? completed / total : 0;
    const filled = Math.round(percentage * width);
    const empty = width - filled;

    return (
      <Text>
        <Text color="green">{'█'.repeat(filled)}</Text>
        <Text color="gray">{'░'.repeat(empty)}</Text>
        <Text> {(percentage * 100).toFixed(1)}%</Text>
      </Text>
    );
  };

  if (feature) {
    const featureMetrics = calculator.calculateFeatureMetrics(
      feature.spec?.userStories || [],
      feature.tasks
    );

    const healthScore = calculator.calculateHealthScore(feature.tasks, feature.status);
    const estimateAccuracy = calculator.calculateEstimateAccuracy(feature.tasks);
    const priorityDist = calculator.getPriorityDistribution(feature.tasks);

    return (
      <Box flexDirection="column" padding={1}>
        {/* Header */}
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            📊 Feature Metrics: {feature.name}
          </Text>
        </Box>

        {/* Stories */}
        <Box borderStyle="single" borderColor="green" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="green">
            📝 User Stories
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Total: </Text>
              <Text>{featureMetrics.stories.total}</Text>
            </Box>
            <Box marginTop={1}>
              <Text bold>By Priority: </Text>
              <Text color="red">P1:{featureMetrics.stories.byPriority.P1}</Text>
              <Text> • </Text>
              <Text color="yellow">P2:{featureMetrics.stories.byPriority.P2}</Text>
              <Text> • </Text>
              <Text color="gray">P3:{featureMetrics.stories.byPriority.P3}</Text>
            </Box>
          </Box>
        </Box>

        {/* Tasks */}
        <Box borderStyle="single" borderColor="blue" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="blue">
            ✓ Tasks
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Progress: </Text>
              {renderProgressBar(featureMetrics.tasks.completed, featureMetrics.tasks.total)}
            </Box>
            <Box marginTop={1}>
              <Text bold>Status: </Text>
              <Text color="green">✓{featureMetrics.tasks.completed}</Text>
              <Text> • </Text>
              <Text color="yellow">⟳{featureMetrics.tasks.inProgress}</Text>
              <Text> • </Text>
              <Text color="gray">○{featureMetrics.tasks.total - featureMetrics.tasks.completed - featureMetrics.tasks.inProgress - featureMetrics.tasks.blocked}</Text>
              {featureMetrics.tasks.blocked > 0 && (
                <>
                  <Text> • </Text>
                  <Text color="red">✗{featureMetrics.tasks.blocked}</Text>
                </>
              )}
            </Box>
            <Box marginTop={1}>
              <Text bold>By Priority: </Text>
              <Text color="red">P1:{featureMetrics.tasks.byPriority.P1}</Text>
              <Text> • </Text>
              <Text color="yellow">P2:{featureMetrics.tasks.byPriority.P2}</Text>
              <Text> • </Text>
              <Text color="gray">P3:{featureMetrics.tasks.byPriority.P3}</Text>
            </Box>
          </Box>
        </Box>

        {/* Priority Distribution */}
        <Box borderStyle="single" borderColor="yellow" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="yellow">
            🎯 Priority Distribution
          </Text>
          <Box marginTop={1} flexDirection="column">
            {priorityDist.map(p => (
              <Box key={p.priority} marginTop={1}>
                <Text bold color={p.priority === 'P1' ? 'red' : p.priority === 'P2' ? 'yellow' : 'gray'}>
                  {p.priority}:{' '}
                </Text>
                {renderProgressBar(p.count, feature.tasks.length, 20)}
              </Box>
            ))}
          </Box>
        </Box>

        {/* Health Score */}
        <Box
          borderStyle="single"
          borderColor={healthScore.status === 'healthy' ? 'green' : healthScore.status === 'warning' ? 'yellow' : 'red'}
          padding={1}
          marginBottom={1}
          flexDirection="column"
        >
          <Text bold>
            {healthScore.status === 'healthy' ? '✅' : healthScore.status === 'warning' ? '⚠️' : '🔴'}
            {' Health Score: '}
            <Text color={healthScore.status === 'healthy' ? 'green' : healthScore.status === 'warning' ? 'yellow' : 'red'}>
              {healthScore.score}/100
            </Text>
          </Text>
          {healthScore.factors.length > 0 && (
            <Box marginTop={1} flexDirection="column">
              {healthScore.factors.map((factor, i) => (
                <Text key={i} dimColor>
                  • {factor}
                </Text>
              ))}
            </Box>
          )}
        </Box>

        {/* Time Estimates */}
        {(featureMetrics.estimatedHours || featureMetrics.actualHours) && (
          <Box borderStyle="single" borderColor="magenta" padding={1} marginBottom={1} flexDirection="column">
            <Text bold color="magenta">
              ⏱️  Time Tracking
            </Text>
            <Box marginTop={1} flexDirection="column">
              {featureMetrics.estimatedHours && (
                <Box>
                  <Text bold>Estimated: </Text>
                  <Text>{featureMetrics.estimatedHours.toFixed(1)} hours</Text>
                </Box>
              )}
              {featureMetrics.actualHours && (
                <Box marginTop={1}>
                  <Text bold>Actual: </Text>
                  <Text>{featureMetrics.actualHours.toFixed(1)} hours</Text>
                </Box>
              )}
              {estimateAccuracy !== null && (
                <Box marginTop={1}>
                  <Text bold>Estimate Accuracy: </Text>
                  <Text color={estimateAccuracy >= 80 ? 'green' : estimateAccuracy >= 60 ? 'yellow' : 'red'}>
                    {estimateAccuracy.toFixed(1)}%
                  </Text>
                </Box>
              )}
            </Box>
          </Box>
        )}

        {/* Controls */}
        <Box borderStyle="single" borderColor="gray" padding={1}>
          <Text dimColor>
            Press <Text bold>q</Text> to quit
          </Text>
        </Box>
      </Box>
    );
  }

  if (metrics) {
    return (
      <Box flexDirection="column" padding={1}>
        {/* Header */}
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            📊 Project Metrics
          </Text>
        </Box>

        {/* Features Overview */}
        <Box borderStyle="single" borderColor="green" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="green">
            📁 Features
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Total: </Text>
              <Text>{metrics.totalFeatures}</Text>
            </Box>
            <Box marginTop={1}>
              <Text bold>Completed: </Text>
              {renderProgressBar(metrics.completedFeatures, metrics.totalFeatures)}
            </Box>
            <Box marginTop={1}>
              <Text bold>In Progress: </Text>
              <Text color="yellow">{metrics.inProgressFeatures}</Text>
            </Box>
          </Box>
        </Box>

        {/* Tasks Overview */}
        <Box borderStyle="single" borderColor="blue" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="blue">
            ✓ Tasks
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Total: </Text>
              <Text>{metrics.totalTasks}</Text>
            </Box>
            <Box marginTop={1}>
              <Text bold>Completed: </Text>
              {renderProgressBar(metrics.completedTasks, metrics.totalTasks)}
            </Box>
            <Box marginTop={1}>
              <Text bold>Completion Rate: </Text>
              <Text color={metrics.completionRate >= 70 ? 'green' : metrics.completionRate >= 40 ? 'yellow' : 'red'}>
                {metrics.completionRate.toFixed(1)}%
              </Text>
            </Box>
          </Box>
        </Box>

        {/* Velocity */}
        <Box borderStyle="single" borderColor="yellow" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="yellow">
            ⚡ Velocity
          </Text>
          <Box marginTop={1}>
            <Text bold>7-day avg: </Text>
            <Text color="cyan">{velocity.toFixed(1)}</Text>
            <Text> tasks/day</Text>
          </Box>
        </Box>

        {/* Decisions */}
        <Box borderStyle="single" borderColor="magenta" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="magenta">
            💡 Decisions
          </Text>
          <Box marginTop={1}>
            <Text bold>Total Logged: </Text>
            <Text>{metrics.totalDecisions}</Text>
          </Box>
        </Box>

        {/* Average Feature Time */}
        {metrics.averageFeatureTime && (
          <Box borderStyle="single" borderColor="cyan" padding={1} marginBottom={1} flexDirection="column">
            <Text bold color="cyan">
              ⏱️  Average Feature Time
            </Text>
            <Box marginTop={1}>
              <Text>{metrics.averageFeatureTime.toFixed(1)} hours</Text>
            </Box>
          </Box>
        )}

        {/* Controls */}
        <Box borderStyle="single" borderColor="gray" padding={1}>
          <Text dimColor>
            Press <Text bold>q</Text> to quit
          </Text>
        </Box>
      </Box>
    );
  }

  return (
    <Box padding={1}>
      <Text>No metrics available</Text>
    </Box>
  );
};
