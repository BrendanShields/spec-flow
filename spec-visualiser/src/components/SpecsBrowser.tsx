import React, { useState, useEffect } from 'react';
import { Box, Text, useInput, useApp } from 'ink';
import SelectInput from 'ink-select-input';
import { SpecParser } from '../services/specParser.js';
import { FeatureData, UserStory, Task } from '../types/spec.js';
import { stripMarkdown, wrapText } from '../utils/markdown.js';

interface SpecsBrowserProps {
  projectRoot: string;
  initialFeatureId?: string;
}

type View = 'list' | 'feature' | 'story' | 'tasks';

export const SpecsBrowser: React.FC<SpecsBrowserProps> = ({
  projectRoot,
  initialFeatureId,
}) => {
  const { exit } = useApp();
  const [view, setView] = useState<View>('list');
  const [features, setFeatures] = useState<FeatureData[]>([]);
  const [selectedFeature, setSelectedFeature] = useState<FeatureData | null>(null);
  const [selectedStoryIndex, setSelectedStoryIndex] = useState(0);

  const parser = new SpecParser(projectRoot);

  useEffect(() => {
    loadFeatures();
  }, []);

  const loadFeatures = () => {
    const featureIds = parser.listFeatures();
    const featureData: FeatureData[] = [];

    for (const featureId of featureIds) {
      const id = featureId.match(/^\d{3}/)?.[0] || featureId;
      const feature = parser.getFeatureData(id);
      if (feature) {
        featureData.push(feature);
      }
    }

    setFeatures(featureData);

    if (initialFeatureId) {
      const feature = featureData.find(f => f.id === initialFeatureId);
      if (feature) {
        setSelectedFeature(feature);
        setView('feature');
      }
    }
  };

  useInput((input, key) => {
    if (input === 'q' || key.escape) {
      if (view === 'list') {
        exit();
      } else {
        setView('list');
        setSelectedFeature(null);
      }
    } else if (input === 's' && view === 'feature' && selectedFeature?.spec) {
      setView('story');
      setSelectedStoryIndex(0);
    } else if (input === 't' && view === 'feature' && selectedFeature?.tasks.length) {
      setView('tasks');
    } else if (input === 'b' && view !== 'list') {
      setView('feature');
    } else if (key.upArrow && view === 'story') {
      setSelectedStoryIndex(prev => Math.max(0, prev - 1));
    } else if (key.downArrow && view === 'story' && selectedFeature?.spec) {
      setSelectedStoryIndex(prev =>
        Math.min((selectedFeature.spec?.userStories.length || 1) - 1, prev + 1)
      );
    }
  });

  const handleFeatureSelect = (item: { value: string }) => {
    const feature = features.find(f => f.id === item.value);
    if (feature) {
      setSelectedFeature(feature);
      setView('feature');
    }
  };

  if (view === 'list') {
    const items = features.map(f => ({
      label: `${f.id} - ${f.name} (${f.status})`,
      value: f.id,
    }));

    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            📚 Feature Specifications
          </Text>
        </Box>

        {features.length === 0 ? (
          <Box borderStyle="single" padding={1}>
            <Text dimColor>No features found</Text>
          </Box>
        ) : (
          <Box borderStyle="single" padding={1}>
            <SelectInput items={items} onSelect={handleFeatureSelect} />
          </Box>
        )}

        <Box borderStyle="single" borderColor="gray" padding={1} marginTop={1}>
          <Text dimColor>
            Use arrow keys to navigate • <Text bold>Enter</Text> to select • <Text bold>q</Text> to quit
          </Text>
        </Box>
      </Box>
    );
  }

  if (view === 'feature' && selectedFeature) {
    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            {selectedFeature.name}
          </Text>
          <Text dimColor> ({selectedFeature.id})</Text>
        </Box>

        {/* Overview */}
        {selectedFeature.spec && (
          <Box
            borderStyle="single"
            borderColor="blue"
            padding={1}
            marginBottom={1}
            flexDirection="column"
          >
            <Text bold color="blue">
              📋 Overview
            </Text>
            <Box marginTop={1}>
              <Text>
                {stripMarkdown(selectedFeature.spec.overview).substring(0, 300) ||
                  'No overview available'}
              </Text>
            </Box>
          </Box>
        )}

        {/* User Stories Summary */}
        {selectedFeature.spec && selectedFeature.spec.userStories.length > 0 && (
          <Box
            borderStyle="single"
            borderColor="green"
            padding={1}
            marginBottom={1}
            flexDirection="column"
          >
            <Text bold color="green">
              📝 User Stories ({selectedFeature.spec.userStories.length})
            </Text>
            <Box marginTop={1} flexDirection="column">
              {selectedFeature.spec.userStories.slice(0, 5).map((story, i) => (
                <Box key={i} marginBottom={1}>
                  <Text bold color={story.priority === 'P1' ? 'red' : story.priority === 'P2' ? 'yellow' : 'gray'}>
                    {story.priority}
                  </Text>
                  <Text>: {story.title}</Text>
                </Box>
              ))}
              {selectedFeature.spec.userStories.length > 5 && (
                <Text dimColor>
                  ... and {selectedFeature.spec.userStories.length - 5} more
                </Text>
              )}
            </Box>
          </Box>
        )}

        {/* Tasks Summary */}
        {selectedFeature.tasks.length > 0 && (
          <Box
            borderStyle="single"
            borderColor="yellow"
            padding={1}
            marginBottom={1}
            flexDirection="column"
          >
            <Text bold color="yellow">
              ✓ Tasks ({selectedFeature.tasks.length})
            </Text>
            <Box marginTop={1} flexDirection="column">
              <Box>
                <Text color="green">
                  ✓ {selectedFeature.tasks.filter(t => t.status === 'completed').length} completed
                </Text>
                <Text> • </Text>
                <Text color="yellow">
                  ⟳ {selectedFeature.tasks.filter(t => t.status === 'in_progress').length} in progress
                </Text>
                <Text> • </Text>
                <Text color="gray">
                  ○ {selectedFeature.tasks.filter(t => t.status === 'pending').length} pending
                </Text>
              </Box>
            </Box>
          </Box>
        )}

        {/* Navigation */}
        <Box borderStyle="single" borderColor="gray" padding={1}>
          <Text dimColor>
            {selectedFeature.spec && <Text><Text bold>s</Text> - View stories • </Text>}
            {selectedFeature.tasks.length > 0 && <Text><Text bold>t</Text> - View tasks • </Text>}
            <Text bold>Esc</Text> - Back • <Text bold>q</Text> - Quit
          </Text>
        </Box>
      </Box>
    );
  }

  if (view === 'story' && selectedFeature?.spec) {
    const story = selectedFeature.spec.userStories[selectedStoryIndex];

    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            User Story {selectedStoryIndex + 1}/{selectedFeature.spec.userStories.length}
          </Text>
        </Box>

        {story && (
          <>
            <Box borderStyle="single" borderColor="green" padding={1} marginBottom={1} flexDirection="column">
              <Text bold color="green">
                {story.priority}: {story.title}
              </Text>
            </Box>

            <Box borderStyle="single" padding={1} marginBottom={1} flexDirection="column">
              <Text bold>As a </Text>
              <Text color="cyan">{story.asA}</Text>
              <Box marginTop={1}>
                <Text bold>I want </Text>
                <Text color="yellow">{story.iWant}</Text>
              </Box>
              <Box marginTop={1}>
                <Text bold>So that </Text>
                <Text color="green">{story.soThat}</Text>
              </Box>
            </Box>

            {story.acceptanceCriteria && story.acceptanceCriteria.length > 0 && (
              <Box borderStyle="single" padding={1} marginBottom={1} flexDirection="column">
                <Text bold>Acceptance Criteria:</Text>
                {story.acceptanceCriteria.map((criteria, i) => (
                  <Box key={i} marginTop={1}>
                    <Text>• {criteria}</Text>
                  </Box>
                ))}
              </Box>
            )}
          </>
        )}

        <Box borderStyle="single" borderColor="gray" padding={1}>
          <Text dimColor>
            <Text bold>↑/↓</Text> Navigate • <Text bold>b</Text> Back • <Text bold>Esc</Text> Feature • <Text bold>q</Text> Quit
          </Text>
        </Box>
      </Box>
    );
  }

  if (view === 'tasks' && selectedFeature) {
    const tasksByPriority = {
      P1: selectedFeature.tasks.filter(t => t.priority === 'P1'),
      P2: selectedFeature.tasks.filter(t => t.priority === 'P2'),
      P3: selectedFeature.tasks.filter(t => t.priority === 'P3'),
    };

    return (
      <Box flexDirection="column" padding={1}>
        <Box borderStyle="round" borderColor="cyan" padding={1} marginBottom={1}>
          <Text bold color="cyan">
            ✓ Tasks - {selectedFeature.name}
          </Text>
        </Box>

        {(['P1', 'P2', 'P3'] as const).map(priority => {
          const tasks = tasksByPriority[priority];
          if (tasks.length === 0) return null;

          return (
            <Box
              key={priority}
              borderStyle="single"
              borderColor={priority === 'P1' ? 'red' : priority === 'P2' ? 'yellow' : 'gray'}
              padding={1}
              marginBottom={1}
              flexDirection="column"
            >
              <Text bold color={priority === 'P1' ? 'red' : priority === 'P2' ? 'yellow' : 'gray'}>
                {priority} Tasks ({tasks.length})
              </Text>
              <Box marginTop={1} flexDirection="column">
                {tasks.map((task, i) => (
                  <Box key={i} marginBottom={1}>
                    <Text
                      color={
                        task.status === 'completed'
                          ? 'green'
                          : task.status === 'in_progress'
                          ? 'yellow'
                          : task.status === 'blocked'
                          ? 'red'
                          : 'gray'
                      }
                    >
                      {task.status === 'completed'
                        ? '✓'
                        : task.status === 'in_progress'
                        ? '⟳'
                        : task.status === 'blocked'
                        ? '✗'
                        : '○'}
                    </Text>
                    <Text> {task.id}: {task.title}</Text>
                    {task.parallel && <Text color="cyan"> [P]</Text>}
                  </Box>
                ))}
              </Box>
            </Box>
          );
        })}

        <Box borderStyle="single" borderColor="gray" padding={1}>
          <Text dimColor>
            <Text bold>b</Text> Back • <Text bold>Esc</Text> Feature • <Text bold>q</Text> Quit
          </Text>
        </Box>
      </Box>
    );
  }

  return null;
};
