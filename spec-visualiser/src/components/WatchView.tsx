import React, { useState, useEffect, useRef } from 'react';
import { Box, Text, useInput, useApp } from 'ink';
import { SpecFileWatcher } from '../services/fileWatcher.js';
import { SpecParser } from '../services/specParser.js';
import { FileChange, SessionState, WorkflowProgress } from '../types/spec.js';
import { formatDistance } from 'date-fns';

interface WatchViewProps {
  projectRoot: string;
  verbose: boolean;
}

interface LogEntry {
  timestamp: Date;
  type: 'state' | 'memory' | 'feature' | 'error';
  event: string;
  file: string;
  change: FileChange;
}

export const WatchView: React.FC<WatchViewProps> = ({ projectRoot, verbose }) => {
  const { exit } = useApp();
  const [watching, setWatching] = useState(false);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [session, setSession] = useState<SessionState | null>(null);
  const [progress, setProgress] = useState<WorkflowProgress | null>(null);
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
  const watcherRef = useRef<SpecFileWatcher | null>(null);
  const parserRef = useRef<SpecParser>(new SpecParser(projectRoot));

  const MAX_LOGS = 50;

  useEffect(() => {
    startWatching();

    return () => {
      stopWatching();
    };
  }, []);

  const startWatching = () => {
    const watcher = new SpecFileWatcher(projectRoot);
    watcherRef.current = watcher;

    // Load initial data
    loadData();

    // Set up event listeners
    watcher.on('ready', () => {
      setWatching(true);
      addLog({
        timestamp: new Date(),
        type: 'state',
        event: 'Watcher Ready',
        file: 'system',
        change: { path: 'system', type: 'modified', timestamp: new Date() },
      });
    });

    watcher.on('state-change', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'state',
        event: 'State Changed',
        file: change.path,
        change,
      });
      if (verbose) {
        loadData();
      }
    });

    watcher.on('memory-change', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'memory',
        event: 'Memory Updated',
        file: change.path,
        change,
      });
      if (verbose) {
        loadData();
      }
    });

    watcher.on('feature-change', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'feature',
        event: 'Feature Modified',
        file: change.path,
        change,
      });
      if (verbose) {
        loadData();
      }
    });

    watcher.on('session-update', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'state',
        event: 'Session Updated',
        file: change.path,
        change,
      });
      loadData();
    });

    watcher.on('progress-update', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'memory',
        event: 'Progress Updated',
        file: change.path,
        change,
      });
      loadData();
    });

    watcher.on('spec-update', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'feature',
        event: 'Spec Updated',
        file: change.path,
        change,
      });
    });

    watcher.on('tasks-update', (change: FileChange) => {
      addLog({
        timestamp: new Date(),
        type: 'feature',
        event: 'Tasks Updated',
        file: change.path,
        change,
      });
      loadData();
    });

    watcher.on('error', (error: Error) => {
      addLog({
        timestamp: new Date(),
        type: 'error',
        event: 'Error',
        file: 'system',
        change: { path: 'system', type: 'modified', timestamp: new Date() },
      });
    });

    watcher.start();
  };

  const stopWatching = () => {
    if (watcherRef.current) {
      watcherRef.current.stop();
      watcherRef.current = null;
      setWatching(false);
    }
  };

  const loadData = () => {
    const parser = parserRef.current;
    const sessionData = parser.parseSessionState();
    const progressData = parser.parseWorkflowProgress();

    setSession(sessionData);
    setProgress(progressData);
    setLastUpdate(new Date());
  };

  const addLog = (entry: LogEntry) => {
    setLogs(prev => {
      const newLogs = [entry, ...prev];
      return newLogs.slice(0, MAX_LOGS);
    });
  };

  useInput((input, key) => {
    if (input === 'q' || key.escape) {
      exit();
    } else if (input === 'c') {
      setLogs([]);
    } else if (input === 'r') {
      loadData();
    }
  });

  const getEventColor = (type: LogEntry['type']) => {
    switch (type) {
      case 'state':
        return 'blue';
      case 'memory':
        return 'magenta';
      case 'feature':
        return 'green';
      case 'error':
        return 'red';
      default:
        return 'white';
    }
  };

  const getEventIcon = (type: LogEntry['type']) => {
    switch (type) {
      case 'state':
        return '🔵';
      case 'memory':
        return '💾';
      case 'feature':
        return '📝';
      case 'error':
        return '❌';
      default:
        return '•';
    }
  };

  const getChangeTypeIcon = (type: FileChange['type']) => {
    switch (type) {
      case 'created':
        return '+';
      case 'modified':
        return '~';
      case 'deleted':
        return '-';
      default:
        return '•';
    }
  };

  return (
    <Box flexDirection="column" padding={1}>
      {/* Header */}
      <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
        <Box flexDirection="column" width="100%">
          <Text bold color="cyan">
            👁️  Spec File Watcher
          </Text>
          <Box marginTop={1}>
            <Text dimColor>
              Status:{' '}
              <Text color={watching ? 'green' : 'red'}>
                {watching ? '● Watching' : '○ Stopped'}
              </Text>
              {' • '}
              Last update: {formatDistance(lastUpdate, new Date(), { addSuffix: true })}
            </Text>
          </Box>
        </Box>
      </Box>

      {/* Current State */}
      <Box borderStyle="single" borderColor="blue" padding={1} marginBottom={1} flexDirection="column">
        <Text bold color="blue">
          📊 Current State
        </Text>
        <Box marginTop={1} flexDirection="column">
          {session ? (
            <>
              <Box>
                <Text bold>Phase: </Text>
                <Text color="yellow">{session.currentPhase}</Text>
              </Box>
              {session.currentFeature && (
                <Box marginTop={1}>
                  <Text bold>Feature: </Text>
                  <Text color="green">{session.currentFeature.name}</Text>
                  <Text dimColor> ({session.currentFeature.id})</Text>
                </Box>
              )}
              <Box marginTop={1}>
                <Text bold>Tasks: </Text>
                <Text color="cyan">{session.tasksProgress.completed}</Text>
                <Text>/</Text>
                <Text>{session.tasksProgress.total}</Text>
                {session.tasksProgress.inProgress > 0 && (
                  <Text color="yellow"> • {session.tasksProgress.inProgress} in progress</Text>
                )}
              </Box>
            </>
          ) : (
            <Text dimColor>No session data</Text>
          )}
        </Box>
      </Box>

      {/* Activity Log */}
      <Box
        borderStyle="single"
        borderColor="green"
        padding={1}
        marginBottom={1}
        flexDirection="column"
        height={20}
      >
        <Text bold color="green">
          📋 Activity Log ({logs.length})
        </Text>
        <Box marginTop={1} flexDirection="column">
          {logs.length === 0 ? (
            <Text dimColor>Waiting for changes...</Text>
          ) : (
            logs.slice(0, 15).map((log, i) => (
              <Box key={i}>
                <Text dimColor>{formatDistance(log.timestamp, new Date(), { addSuffix: true })}</Text>
                <Text> </Text>
                <Text color={getEventColor(log.type)}>
                  {getEventIcon(log.type)} {log.event}
                </Text>
                {verbose && (
                  <>
                    <Text dimColor> • </Text>
                    <Text color="gray">
                      [{getChangeTypeIcon(log.change.type)}] {log.file}
                    </Text>
                  </>
                )}
              </Box>
            ))
          )}
        </Box>
      </Box>

      {/* Project Stats */}
      {progress && (
        <Box borderStyle="single" borderColor="magenta" padding={1} marginBottom={1} flexDirection="column">
          <Text bold color="magenta">
            📈 Quick Stats
          </Text>
          <Box marginTop={1}>
            <Text bold>Features: </Text>
            <Text color="green">{progress.totalMetrics.completedFeatures}</Text>
            <Text>/</Text>
            <Text>{progress.totalMetrics.totalFeatures}</Text>
            <Text> • </Text>
            <Text bold>Tasks: </Text>
            <Text color="cyan">{progress.totalMetrics.completedTasks}</Text>
            <Text>/</Text>
            <Text>{progress.totalMetrics.totalTasks}</Text>
            <Text dimColor> ({progress.totalMetrics.completionRate.toFixed(1)}%)</Text>
          </Box>
        </Box>
      )}

      {/* Controls */}
      <Box borderStyle="single" borderColor="gray" padding={1}>
        <Text dimColor>
          <Text bold>r</Text> - Refresh • <Text bold>c</Text> - Clear log • <Text bold>q</Text> - Quit
        </Text>
      </Box>
    </Box>
  );
};
