import * as fs from 'fs';
import * as path from 'path';
import {
  SpecterConfig,
  SessionState,
  WorkflowProgress,
  Specification,
  TechnicalPlan,
  Task,
  FeatureData,
  UserStory,
  Priority,
  TaskStatus,
  WorkflowPhase,
  Change,
} from '../types/specter.js';

export class SpecterParser {
  private config: SpecterConfig;

  constructor(projectRoot: string) {
    this.config = this.loadConfig(projectRoot);
  }

  private loadConfig(projectRoot: string): SpecterConfig {
    const specterDir = path.join(projectRoot, '.specter');
    const stateDir = path.join(projectRoot, '.specter-state');
    const memoryDir = path.join(projectRoot, '.specter-memory');
    const featuresDir = path.join(projectRoot, 'features');

    const initialized =
      fs.existsSync(specterDir) &&
      fs.existsSync(stateDir) &&
      fs.existsSync(memoryDir);

    return {
      projectRoot,
      specterDir,
      stateDir,
      memoryDir,
      featuresDir,
      initialized,
    };
  }

  getConfig(): SpecterConfig {
    return this.config;
  }

  isInitialized(): boolean {
    return this.config.initialized;
  }

  parseSessionState(): SessionState | null {
    const sessionFile = path.join(
      this.config.stateDir,
      'current-session.md'
    );

    if (!fs.existsSync(sessionFile)) {
      return null;
    }

    try {
      const content = fs.readFileSync(sessionFile, 'utf-8');
      return this.extractSessionFromMarkdown(content);
    } catch (error) {
      console.error('Error parsing session state:', error);
      return null;
    }
  }

  private extractSessionFromMarkdown(content: string): SessionState {
    const lines = content.split('\n');
    const sessionId = this.extractValue(lines, 'Session ID');
    const startTime = this.extractValue(lines, 'Started');
    const lastUpdated = this.extractValue(lines, 'Last Updated');
    const phase = this.extractValue(lines, 'Current Phase') as WorkflowPhase;

    // Extract current feature
    let currentFeature;
    const featureSection = this.extractSection(content, '## Current Feature');
    if (featureSection) {
      const featureId = this.extractValue(featureSection.split('\n'), 'Feature ID');
      const name = this.extractValue(featureSection.split('\n'), 'Name');
      const directory = this.extractValue(featureSection.split('\n'), 'Directory');
      if (featureId) {
        currentFeature = { id: featureId, name: name || '', directory: directory || '' };
      }
    }

    // Extract tasks progress
    const tasksSection = this.extractSection(content, '## Tasks Progress');
    const tasksProgress = {
      total: parseInt(this.extractValue(tasksSection?.split('\n') || [], 'Total') || '0'),
      completed: parseInt(this.extractValue(tasksSection?.split('\n') || [], 'Completed') || '0'),
      inProgress: parseInt(this.extractValue(tasksSection?.split('\n') || [], 'In Progress') || '0'),
      blocked: parseInt(this.extractValue(tasksSection?.split('\n') || [], 'Blocked') || '0'),
    };

    return {
      sessionId: sessionId || 'unknown',
      startTime: startTime || new Date().toISOString(),
      lastUpdated: lastUpdated || new Date().toISOString(),
      currentFeature,
      currentPhase: phase || 'initialization',
      tasksProgress,
      recentActivity: [],
      checkpoints: [],
    };
  }

  parseWorkflowProgress(): WorkflowProgress | null {
    const progressFile = path.join(
      this.config.memoryDir,
      'WORKFLOW-PROGRESS.md'
    );

    if (!fs.existsSync(progressFile)) {
      return null;
    }

    try {
      const content = fs.readFileSync(progressFile, 'utf-8');
      return this.extractWorkflowProgress(content);
    } catch (error) {
      console.error('Error parsing workflow progress:', error);
      return null;
    }
  }

  private extractWorkflowProgress(content: string): WorkflowProgress {
    const features = this.extractFeaturesList(content);

    const totalMetrics = {
      totalFeatures: features.length,
      completedFeatures: features.filter(f => f.phase === 'completed').length,
      inProgressFeatures: features.filter(f => f.phase !== 'completed').length,
      totalTasks: features.reduce((sum, f) => sum + (f.metrics.tasks.total || 0), 0),
      completedTasks: features.reduce((sum, f) => sum + (f.metrics.tasks.completed || 0), 0),
      totalDecisions: features.reduce((sum, f) => sum + (f.metrics.decisions || 0), 0),
      completionRate: 0,
    };

    if (totalMetrics.totalTasks > 0) {
      totalMetrics.completionRate = (totalMetrics.completedTasks / totalMetrics.totalTasks) * 100;
    }

    return { features, totalMetrics };
  }

  private extractFeaturesList(content: string): any[] {
    // Parse features from markdown table or list
    const features: any[] = [];
    const lines = content.split('\n');

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (line.startsWith('### ') || line.match(/^\d{3}-/)) {
        // Extract feature info
        const feature = {
          id: line.match(/\d{3}/)?.[0] || '',
          name: line.replace(/^###\s*/, '').replace(/^\d{3}-/, ''),
          phase: 'specification' as WorkflowPhase,
          startDate: new Date().toISOString(),
          metrics: {
            stories: { total: 0, byPriority: { P1: 0, P2: 0, P3: 0 } },
            tasks: { total: 0, completed: 0, inProgress: 0, blocked: 0, byPriority: { P1: 0, P2: 0, P3: 0 } },
            decisions: 0,
            clarifications: 0,
          },
        };
        features.push(feature);
      }
    }

    return features;
  }

  parseSpecification(featureDir: string): Specification | null {
    const specFile = path.join(featureDir, 'spec.md');

    if (!fs.existsSync(specFile)) {
      return null;
    }

    try {
      const content = fs.readFileSync(specFile, 'utf-8');
      return this.extractSpecification(content, path.basename(featureDir));
    } catch (error) {
      console.error('Error parsing specification:', error);
      return null;
    }
  }

  private extractSpecification(content: string, featureId: string): Specification {
    const lines = content.split('\n');
    const featureName = lines.find(l => l.startsWith('# '))?.replace('# ', '') || featureId;
    const overview = this.extractSection(content, '## Overview') || '';
    const userStories = this.extractUserStories(content);

    return {
      featureId,
      featureName,
      overview,
      userStories,
      outOfScope: [],
      technicalConstraints: [],
      dependencies: [],
    };
  }

  private extractUserStories(content: string): UserStory[] {
    const stories: UserStory[] = [];
    const storyPattern = /### (P[123]): (.+?)\n[\s\S]*?As a (.+?)\nI want (.+?)\nSo that (.+?)\n/g;

    let match;
    while ((match = storyPattern.exec(content)) !== null) {
      stories.push({
        id: `US${stories.length + 1}`,
        priority: match[1] as Priority,
        title: match[2].trim(),
        asA: match[3].trim(),
        iWant: match[4].trim(),
        soThat: match[5].trim(),
        acceptanceCriteria: [],
      });
    }

    return stories;
  }

  parseTasks(featureDir: string): Task[] {
    const tasksFile = path.join(featureDir, 'tasks.md');

    if (!fs.existsSync(tasksFile)) {
      return [];
    }

    try {
      const content = fs.readFileSync(tasksFile, 'utf-8');
      return this.extractTasks(content);
    } catch (error) {
      console.error('Error parsing tasks:', error);
      return [];
    }
  }

  private extractTasks(content: string): Task[] {
    const tasks: Task[] = [];
    const lines = content.split('\n');

    for (const line of lines) {
      const taskMatch = line.match(/^[-*]\s*\[(.)\]\s*\*\*(T\d+)\*\*.*?\*\*(P[123])\*\*:\s*(.+)/);
      if (taskMatch) {
        const [, statusChar, id, priority, title] = taskMatch;
        const status: TaskStatus =
          statusChar === 'x' ? 'completed' :
          statusChar === '>' ? 'in_progress' :
          statusChar === 'B' ? 'blocked' : 'pending';

        tasks.push({
          id,
          title: title.trim(),
          description: '',
          priority: priority as Priority,
          status,
          parallel: line.includes('[P]'),
        });
      }
    }

    return tasks;
  }

  parseChanges(type: 'planned' | 'completed'): Change[] {
    const filename = type === 'planned' ? 'CHANGES-PLANNED.md' : 'CHANGES-COMPLETED.md';
    const changesFile = path.join(this.config.memoryDir, filename);

    if (!fs.existsSync(changesFile)) {
      return [];
    }

    try {
      const content = fs.readFileSync(changesFile, 'utf-8');
      return this.extractChanges(content);
    } catch (error) {
      console.error(`Error parsing ${type} changes:`, error);
      return [];
    }
  }

  private extractChanges(content: string): Change[] {
    const changes: Change[] = [];
    const changePattern = /^[-*]\s*\[(.+?)\]\s*(.+?):\s*(.+)/gm;

    let match;
    let changeId = 1;
    while ((match = changePattern.exec(content)) !== null) {
      const [, category, changeType, description] = match;

      changes.push({
        id: `C${changeId++}`,
        type: changeType.toLowerCase().includes('add') ? 'addition' :
              changeType.toLowerCase().includes('modify') ? 'modification' : 'deletion',
        category: category.toLowerCase() as any,
        description: description.trim(),
        files: [],
      });
    }

    return changes;
  }

  listFeatures(): string[] {
    if (!fs.existsSync(this.config.featuresDir)) {
      return [];
    }

    try {
      return fs
        .readdirSync(this.config.featuresDir)
        .filter(file => {
          const fullPath = path.join(this.config.featuresDir, file);
          return fs.statSync(fullPath).isDirectory() && file.match(/^\d{3}-/);
        })
        .sort();
    } catch (error) {
      console.error('Error listing features:', error);
      return [];
    }
  }

  getFeatureData(featureId: string): FeatureData | null {
    const featureDirs = this.listFeatures();
    const featureDir = featureDirs.find(dir => dir.startsWith(featureId));

    if (!featureDir) {
      return null;
    }

    const fullPath = path.join(this.config.featuresDir, featureDir);
    const spec = this.parseSpecification(fullPath);
    const tasks = this.parseTasks(fullPath);

    // Determine status based on tasks
    let status: WorkflowPhase = 'specification';
    if (tasks.length > 0) {
      const allCompleted = tasks.every(t => t.status === 'completed');
      const anyInProgress = tasks.some(t => t.status === 'in_progress');

      if (allCompleted) status = 'completed';
      else if (anyInProgress) status = 'implementation';
      else status = 'task-breakdown';
    }

    return {
      id: featureId,
      name: spec?.featureName || featureDir,
      spec,
      plan: null, // Could parse plan.md if needed
      tasks,
      status,
    };
  }

  private extractValue(lines: string[], key: string): string | null {
    for (const line of lines) {
      if (line.includes(key + ':')) {
        return line.split(':').slice(1).join(':').trim();
      }
      if (line.includes('**' + key + '**:')) {
        return line.split('**:').slice(1).join('**:').trim();
      }
    }
    return null;
  }

  private extractSection(content: string, heading: string): string | null {
    const lines = content.split('\n');
    const startIndex = lines.findIndex(l => l.trim() === heading);

    if (startIndex === -1) return null;

    const endIndex = lines.findIndex((l, i) => i > startIndex && l.startsWith('##'));
    const sectionLines = endIndex === -1
      ? lines.slice(startIndex + 1)
      : lines.slice(startIndex + 1, endIndex);

    return sectionLines.join('\n').trim();
  }
}
