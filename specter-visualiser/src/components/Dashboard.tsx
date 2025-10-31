import React, { useState, useEffect } from 'react';
import { Box, Text, useInput, useApp } from 'ink';
import Spinner from 'ink-spinner';
import { SpecterParser } from '../services/specterParser.js';
import { MetricsCalculator } from '../services/metricsCalculator.js';
import { SessionState, WorkflowProgress, FeatureData } from '../types/specter.js';

interface DashboardProps {
  projectRoot: string;
}

export const Dashboard: React.FC<DashboardProps> = ({ projectRoot }) => {
  const { exit } = useApp();
  const [loading, setLoading] = useState(true);
  const [session, setSession] = useState<SessionState | null>(null);
  const [progress, setProgress] = useState<WorkflowProgress | null>(null);
  const [currentFeature, setCurrentFeature] = useState<FeatureData | null>(null);
  const [refreshKey, setRefreshKey] = useState(0);

  const parser = new SpecterParser(projectRoot);
  const calculator = new MetricsCalculator();

  useEffect(() => {
    loadData();
  }, [refreshKey]);

  const loadData = () => {
    setLoading(true);
    try {
      const sessionData = parser.parseSessionState();
      const progressData = parser.parseWorkflowProgress();

      setSession(sessionData);
      setProgress(progressData);

      if (sessionData?.currentFeature) {
        const featureData = parser.getFeatureData(sessionData.currentFeature.id);
        setCurrentFeature(featureData);
      }
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  useInput((input, key) => {
    if (input === 'q' || key.escape) {
      exit();
    } else if (input === 'r') {
      setRefreshKey(prev => prev + 1);
    }
  });

  if (loading) {
    return (
      <Box flexDirection="column" padding={1}>
        <Text>
          <Text color="green">
            <Spinner type="dots" />
          </Text>
          {' Loading dashboard...'}
        </Text>
      </Box>
    );
  }

  const healthScore = currentFeature
    ? calculator.calculateHealthScore(currentFeature.tasks, session?.currentPhase || 'initialization')
    : null;

  const phaseProgress = session
    ? calculator.getPhaseProgress(session.currentPhase, currentFeature?.tasks || [])
    : 0;

  return (
    <Box flexDirection="column" padding={1}>
      {/* Header */}
      <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
        <Box flexDirection="column" width="100%">
          <Text bold color="cyan">
            📊 Specter Workflow Dashboard
          </Text>
          <Text dimColor> {projectRoot}</Text>
        </Box>
      </Box>

      {/* Current Session */}
      {session && (
        <Box
          borderStyle="single"
          borderColor="blue"
          padding={1}
          marginBottom={1}
          flexDirection="column"
        >
          <Text bold color="blue">
            🎯 Current Session
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Phase: </Text>
              <Text color="yellow">{session.currentPhase}</Text>
              <Text dimColor> ({phaseProgress}% complete)</Text>
            </Box>
            {session.currentFeature && (
              <>
                <Box marginTop={1}>
                  <Text bold>Feature: </Text>
                  <Text color="green">
                    {session.currentFeature.name}
                  </Text>
                  <Text dimColor> ({session.currentFeature.id})</Text>
                </Box>
                <Box marginTop={1}>
                  <Text bold>Tasks: </Text>
                  <Text color="cyan">{session.tasksProgress.completed}</Text>
                  <Text>/</Text>
                  <Text>{session.tasksProgress.total}</Text>
                  <Text dimColor> completed</Text>
                  {session.tasksProgress.inProgress > 0 && (
                    <Text color="yellow"> • {session.tasksProgress.inProgress} in progress</Text>
                  )}
                  {session.tasksProgress.blocked > 0 && (
                    <Text color="red"> • {session.tasksProgress.blocked} blocked</Text>
                  )}
                </Box>
              </>
            )}
            {!session.currentFeature && (
              <Box marginTop={1}>
                <Text dimColor>No active feature</Text>
              </Box>
            )}
          </Box>
        </Box>
      )}

      {/* Health Score */}
      {healthScore && (
        <Box
          borderStyle="single"
          borderColor={
            healthScore.status === 'healthy'
              ? 'green'
              : healthScore.status === 'warning'
              ? 'yellow'
              : 'red'
          }
          padding={1}
          marginBottom={1}
          flexDirection="column"
        >
          <Text bold>
            {healthScore.status === 'healthy' ? '✅' : healthScore.status === 'warning' ? '⚠️' : '🔴'}
            {' Health Score: '}
            <Text
              color={
                healthScore.status === 'healthy'
                  ? 'green'
                  : healthScore.status === 'warning'
                  ? 'yellow'
                  : 'red'
              }
            >
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
      )}

      {/* Project Metrics */}
      {progress && (
        <Box
          borderStyle="single"
          borderColor="magenta"
          padding={1}
          marginBottom={1}
          flexDirection="column"
        >
          <Text bold color="magenta">
            📈 Project Metrics
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Box>
              <Text bold>Features: </Text>
              <Text color="green">{progress.totalMetrics.completedFeatures}</Text>
              <Text>/</Text>
              <Text>{progress.totalMetrics.totalFeatures}</Text>
              <Text dimColor> completed</Text>
            </Box>
            <Box marginTop={1}>
              <Text bold>Tasks: </Text>
              <Text color="cyan">{progress.totalMetrics.completedTasks}</Text>
              <Text>/</Text>
              <Text>{progress.totalMetrics.totalTasks}</Text>
              <Text dimColor>
                {' '}({progress.totalMetrics.completionRate.toFixed(1)}% complete)
              </Text>
            </Box>
            <Box marginTop={1}>
              <Text bold>Decisions: </Text>
              <Text color="yellow">{progress.totalMetrics.totalDecisions}</Text>
            </Box>
            {progress.totalMetrics.averageFeatureTime && (
              <Box marginTop={1}>
                <Text bold>Avg Feature Time: </Text>
                <Text>{progress.totalMetrics.averageFeatureTime.toFixed(1)} hours</Text>
              </Box>
            )}
          </Box>
        </Box>
      )}

      {/* Current Feature Details */}
      {currentFeature && currentFeature.spec && (
        <Box
          borderStyle="single"
          borderColor="green"
          padding={1}
          marginBottom={1}
          flexDirection="column"
        >
          <Text bold color="green">
            📝 Feature Details
          </Text>
          <Box marginTop={1} flexDirection="column">
            <Text bold>{currentFeature.spec.featureName}</Text>
            <Box marginTop={1}>
              <Text bold>User Stories: </Text>
              <Text>{currentFeature.spec.userStories.length}</Text>
              <Text dimColor>
                {' (P1: '}
                {currentFeature.spec.userStories.filter(s => s.priority === 'P1').length}
                {', P2: '}
                {currentFeature.spec.userStories.filter(s => s.priority === 'P2').length}
                {', P3: '}
                {currentFeature.spec.userStories.filter(s => s.priority === 'P3').length}
                {')'}
              </Text>
            </Box>
            {currentFeature.tasks.length > 0 && (
              <Box marginTop={1} flexDirection="column">
                <Text bold>Task Breakdown:</Text>
                <Box marginLeft={2}>
                  <Text color="green">
                    ✓ {currentFeature.tasks.filter(t => t.status === 'completed').length} completed
                  </Text>
                  <Text> • </Text>
                  <Text color="yellow">
                    ⟳ {currentFeature.tasks.filter(t => t.status === 'in_progress').length} in progress
                  </Text>
                  <Text> • </Text>
                  <Text color="gray">
                    ○ {currentFeature.tasks.filter(t => t.status === 'pending').length} pending
                  </Text>
                  {currentFeature.tasks.filter(t => t.status === 'blocked').length > 0 && (
                    <>
                      <Text> • </Text>
                      <Text color="red">
                        ✗ {currentFeature.tasks.filter(t => t.status === 'blocked').length} blocked
                      </Text>
                    </>
                  )}
                </Box>
              </Box>
            )}
          </Box>
        </Box>
      )}

      {/* Controls */}
      <Box borderStyle="single" borderColor="gray" padding={1}>
        <Text dimColor>
          Press <Text bold>r</Text> to refresh • <Text bold>q</Text> to quit
        </Text>
      </Box>
    </Box>
  );
};
