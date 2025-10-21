/**
 * Post-Specify Hook
 * Triggers clarification if needed and updates project tracking after specification
 */

module.exports = async function postSpecify(context) {
  const { result, config, options } = context;

  // 1. Check for clarification needs
  const clarificationNeeded = await analyzeClarificationNeeds(result);

  if (clarificationNeeded.count > 0 && config.workflow.requireClarification) {
    context.nextAction = {
      skill: 'flow:clarify',
      automatic: true,
      reason: `Found ${clarificationNeeded.count} clarification markers`,
      items: clarificationNeeded.items
    };

    context.messages.push({
      type: 'info',
      text: `Specification created with ${clarificationNeeded.count} clarifications needed. Auto-triggering flow:clarify...`
    });
  } else if (clarificationNeeded.count > 0) {
    context.messages.push({
      type: 'suggestion',
      text: `Specification has ${clarificationNeeded.count} clarification markers. Consider running flow:clarify to resolve ambiguities.`
    });
  }

  // 2. Update project index
  await updateProjectIndex(result.specPath, result.metadata);

  // 3. Sync with external systems
  if (config.integrations.jira.enabled && config.integrations.jira.autoSync) {
    try {
      const jiraId = await syncWithJira(result);
      context.messages.push({
        type: 'success',
        text: `Synced with JIRA: ${jiraId}`
      });
    } catch (error) {
      context.warnings.push({
        type: 'warning',
        text: `JIRA sync failed: ${error.message}`
      });
    }
  }

  if (config.integrations.confluence.enabled && config.integrations.confluence.autoPublish) {
    try {
      const pageUrl = await publishToConfluence(result);
      context.messages.push({
        type: 'success',
        text: `Published to Confluence: ${pageUrl}`
      });
    } catch (error) {
      context.warnings.push({
        type: 'warning',
        text: `Confluence publish failed: ${error.message}`
      });
    }
  }

  // 4. Generate quality report
  const qualityReport = await assessSpecificationQuality(result);

  context.metrics = {
    completeness: qualityReport.completeness,
    clarity: qualityReport.clarity,
    testability: qualityReport.testability,
    aiGenerated: qualityReport.aiGeneratedPercentage
  };

  if (qualityReport.score < 0.7 && !options.skipValidation) {
    context.warnings.push({
      type: 'warning',
      text: `Specification quality score: ${(qualityReport.score * 100).toFixed(0)}%. Consider improving completeness and clarity.`
    });
  }

  // 5. Queue next workflow steps
  if (config.workflow.autoAnalyze && !clarificationNeeded.critical) {
    context.queuedActions.push({
      skill: 'flow:analyze',
      delay: 0,
      reason: 'Auto-analysis enabled'
    });
  }

  // 6. Update telemetry
  await recordTelemetry({
    event: 'specification-created',
    data: {
      projectType: config.workflow.projectType,
      domain: result.domain,
      userStoryCount: result.userStories.length,
      clarificationCount: clarificationNeeded.count,
      qualityScore: qualityReport.score,
      aiPercentage: qualityReport.aiGeneratedPercentage,
      duration: context.duration
    }
  });

  // 7. Create checklist if configured
  if (config.quality.requireChecklists || options.generateChecklist) {
    context.queuedActions.push({
      skill: 'flow:checklist',
      params: {
        type: 'requirements',
        focus: qualityReport.weakAreas
      },
      reason: 'Checklist generation configured'
    });
  }

  return context;
};

// Helper Functions

async function analyzeClarificationNeeds(result) {
  const clarificationMarkers = [];
  const content = result.content;

  // Find all [NEEDS CLARIFICATION] markers
  const regex = /\[NEEDS CLARIFICATION:([^\]]+)\]/g;
  let match;

  while ((match = regex.exec(content)) !== null) {
    clarificationMarkers.push({
      text: match[1].trim(),
      position: match.index,
      critical: isCriticalClarification(match[1])
    });
  }

  return {
    count: clarificationMarkers.length,
    items: clarificationMarkers,
    critical: clarificationMarkers.some(m => m.critical)
  };
}

function isCriticalClarification(text) {
  const criticalKeywords = [
    'security',
    'authentication',
    'payment',
    'compliance',
    'data protection',
    'privacy',
    'core functionality'
  ];

  const lowerText = text.toLowerCase();
  return criticalKeywords.some(keyword => lowerText.includes(keyword));
}

async function updateProjectIndex(specPath, metadata) {
  const indexPath = '.flow/project-index.json';

  let index = {};
  try {
    const fs = require('fs').promises;
    const content = await fs.readFile(indexPath, 'utf8');
    index = JSON.parse(content);
  } catch {
    // Index doesn't exist yet
    index = {
      specifications: [],
      features: [],
      lastUpdated: null
    };
  }

  // Add new specification
  index.specifications.push({
    path: specPath,
    created: new Date().toISOString(),
    feature: metadata.featureName,
    branch: metadata.branchName,
    priority: metadata.priority,
    status: 'draft'
  });

  index.lastUpdated = new Date().toISOString();

  // Save updated index
  const fs = require('fs').promises;
  await fs.mkdir('.flow', { recursive: true });
  await fs.writeFile(indexPath, JSON.stringify(index, null, 2));
}

async function syncWithJira(result) {
  // Mock JIRA sync
  // In real implementation, would use JIRA API

  const jiraData = {
    projectKey: result.config.integrations.jira.projectKey,
    summary: result.metadata.featureName,
    description: result.content.substring(0, 1000),
    issueType: 'Story',
    priority: mapPriorityToJira(result.metadata.priority),
    labels: ['flow-generated', result.domain].filter(Boolean)
  };

  // Simulate API call
  console.log('Syncing with JIRA:', jiraData.projectKey);

  // Return mock JIRA ID
  return `${jiraData.projectKey}-${Math.floor(Math.random() * 1000)}`;
}

async function publishToConfluence(result) {
  // Mock Confluence publish
  // In real implementation, would use Confluence API

  const confluenceData = {
    spaceKey: result.config.integrations.confluence.spaceKey,
    parentId: result.config.integrations.confluence.rootPageId,
    title: `Spec: ${result.metadata.featureName}`,
    content: convertMarkdownToConfluence(result.content)
  };

  // Simulate API call
  console.log('Publishing to Confluence:', confluenceData.spaceKey);

  // Return mock page URL
  return `https://company.atlassian.net/wiki/spaces/${confluenceData.spaceKey}/pages/${Math.random()}`;
}

async function assessSpecificationQuality(result) {
  const quality = {
    completeness: 0,
    clarity: 0,
    testability: 0,
    aiGeneratedPercentage: 0,
    weakAreas: [],
    score: 0
  };

  // Assess completeness
  const requiredSections = [
    'User Scenarios',
    'Functional Requirements',
    'Success Criteria',
    'Edge Cases'
  ];

  const foundSections = requiredSections.filter(section =>
    result.content.includes(section)
  );

  quality.completeness = foundSections.length / requiredSections.length;

  if (quality.completeness < 1) {
    quality.weakAreas.push('completeness');
  }

  // Assess clarity (no vague terms)
  const vagueTerms = ['fast', 'easy', 'intuitive', 'robust', 'scalable'];
  const vagueCount = vagueTerms.filter(term =>
    result.content.toLowerCase().includes(term)
  ).length;

  quality.clarity = Math.max(0, 1 - (vagueCount * 0.1));

  if (quality.clarity < 0.8) {
    quality.weakAreas.push('clarity');
  }

  // Assess testability (presence of acceptance criteria)
  const acceptanceRegex = /Given.*When.*Then/g;
  const acceptanceCount = (result.content.match(acceptanceRegex) || []).length;

  quality.testability = Math.min(1, acceptanceCount / result.userStories.length);

  if (quality.testability < 0.7) {
    quality.weakAreas.push('testability');
  }

  // Calculate AI-generated percentage
  const aiMarkers = (result.content.match(/\[AI-GENERATED\]|\[INFERRED\]/g) || []).length;
  const totalLines = result.content.split('\n').length;

  quality.aiGeneratedPercentage = Math.min(100, (aiMarkers / totalLines) * 100);

  // Overall score
  quality.score = (
    quality.completeness * 0.4 +
    quality.clarity * 0.3 +
    quality.testability * 0.3
  );

  return quality;
}

async function recordTelemetry(telemetryData) {
  // In production, would send to telemetry service
  console.log('Telemetry:', telemetryData);

  // Local telemetry file for now
  const fs = require('fs').promises;
  const telemetryPath = '.flow/telemetry.jsonl';

  try {
    await fs.mkdir('.flow', { recursive: true });
    await fs.appendFile(
      telemetryPath,
      JSON.stringify({ ...telemetryData, timestamp: new Date().toISOString() }) + '\n'
    );
  } catch (error) {
    console.error('Telemetry error:', error);
  }
}

function mapPriorityToJira(priority) {
  const mapping = {
    'P1': 'Critical',
    'P2': 'Major',
    'P3': 'Minor',
    'P4': 'Trivial'
  };

  return mapping[priority] || 'Major';
}

function convertMarkdownToConfluence(markdown) {
  // Simple conversion - in production would use proper converter
  return markdown
    .replace(/^# (.*)/gm, '<h1>$1</h1>')
    .replace(/^## (.*)/gm, '<h2>$1</h2>')
    .replace(/^### (.*)/gm, '<h3>$1</h3>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/```(.*?)```/gs, '<code>$1</code>');
}