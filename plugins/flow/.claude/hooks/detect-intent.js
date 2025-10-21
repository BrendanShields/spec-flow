#!/usr/bin/env node

/**
 * Intent Detection Hook
 * Analyzes user prompts to suggest appropriate Flow skills
 */

const fs = require('fs');
const path = require('path');

// Intent patterns mapped to Flow skills
const INTENT_PATTERNS = {
  // Specification intents
  'flow:specify': [
    /\b(create|add|build|develop|make)\s+(a\s+)?(new\s+)?feature/i,
    /\b(need|want)\s+(to\s+)?(implement|build|create)/i,
    /\bspecify\s+(requirements?|features?)/i,
    /\bwrite\s+(a\s+)?spec(ification)?/i,
    /\bstart(ing)?\s+(new\s+)?(project|feature|development)/i
  ],

  // Planning intents
  'flow:plan': [
    /\b(create|design|plan)\s+(the\s+)?(technical|implementation|architecture)/i,
    /\bhow\s+(should|would|to)\s+(we\s+)?(implement|build|architect)/i,
    /\btechnical\s+design/i,
    /\barchitecture\s+(for|of)/i
  ],

  // Implementation intents
  'flow:implement': [
    /\b(implement|build|code|develop)\s+(this|it|the\s+feature)/i,
    /\bexecute\s+(the\s+)?tasks?/i,
    /\bstart\s+(coding|implementing|building)/i,
    /\blet'?s\s+(build|code|implement)/i
  ],

  // Blueprint/Architecture intents
  'flow:blueprint': [
    /\b(define|set|establish)\s+(project\s+)?architecture/i,
    /\b(technical|architecture)\s+standards?/i,
    /\btech(nology)?\s+stack/i,
    /\bdevelopment\s+(principles?|guidelines?|standards?)/i
  ],

  // Analysis intents
  'flow:analyze': [
    /\bcheck\s+(for\s+)?(consistency|conflicts|issues)/i,
    /\bvalidate\s+(the\s+)?(spec|plan|tasks)/i,
    /\banalyze\s+(artifacts?|documents?)/i,
    /\bare\s+(there\s+)?any\s+(conflicts?|issues?|problems?)/i
  ],

  // Initialization intents
  'flow:init': [
    /\b(initialize|setup|configure)\s+flow/i,
    /\bset\s?up\s+(the\s+)?(project|flow|workflow)/i,
    /\b(enable|configure)\s+(jira|atlassian|integrations?)/i,
    /\bstart\s+(a\s+)?new\s+project/i
  ]
};

// Additional context clues
const CONTEXT_HINTS = {
  hasJiraUrl: /https?:\/\/[^\/]*\.atlassian\.net\/browse\/[A-Z]+-\d+/,
  hasRequirements: /\b(requirements?|needs?|should|must|wants?)\b/i,
  hasUserStory: /\b(as\s+a|i\s+want|so\s+that)\b/i,
  hasTechnicalTerms: /\b(api|database|frontend|backend|microservice|component)\b/i
};

async function detectIntent(prompt) {
  const detectedIntents = [];
  const suggestions = [];

  // Check each intent pattern
  for (const [skill, patterns] of Object.entries(INTENT_PATTERNS)) {
    for (const pattern of patterns) {
      if (pattern.test(prompt)) {
        detectedIntents.push(skill);
        break; // Only match once per skill
      }
    }
  }

  // Add context-based suggestions
  if (CONTEXT_HINTS.hasJiraUrl.test(prompt)) {
    suggestions.push({
      skill: 'flow:specify',
      reason: 'JIRA URL detected - can import story'
    });
  }

  if (CONTEXT_HINTS.hasUserStory.test(prompt) && !detectedIntents.includes('flow:specify')) {
    suggestions.push({
      skill: 'flow:specify',
      reason: 'User story format detected'
    });
  }

  // Check for workflow state and suggest next step
  const workflowState = await checkWorkflowState();
  if (workflowState.nextStep) {
    suggestions.push({
      skill: workflowState.nextStep,
      reason: `Next step in workflow after ${workflowState.lastCompleted}`
    });
  }

  return {
    detectedIntents,
    suggestions,
    confidence: calculateConfidence(detectedIntents, suggestions),
    prompt: prompt.substring(0, 100) // Truncate for logging
  };
}

async function checkWorkflowState() {
  try {
    const stateFile = path.join(process.cwd(), '.flow', '.state.json');
    if (fs.existsSync(stateFile)) {
      const state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));
      return {
        lastCompleted: state.lastCompletedSkill,
        nextStep: getNextStep(state.lastCompletedSkill)
      };
    }
  } catch (error) {
    // State file doesn't exist or is invalid
  }

  return { lastCompleted: null, nextStep: null };
}

function getNextStep(lastCompleted) {
  const workflow = {
    'flow:init': 'flow:blueprint',
    'flow:blueprint': 'flow:specify',
    'flow:specify': 'flow:clarify',
    'flow:clarify': 'flow:plan',
    'flow:plan': 'flow:tasks',
    'flow:tasks': 'flow:implement'
  };

  return workflow[lastCompleted] || null;
}

function calculateConfidence(intents, suggestions) {
  if (intents.length === 1) return 'high';
  if (intents.length > 1) return 'medium';
  if (suggestions.length > 0) return 'low';
  return 'none';
}

// Main execution
async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));
    const result = await detectIntent(input.prompt || '');

    // Output formatted message if intents detected
    if (result.detectedIntents.length > 0 || result.suggestions.length > 0) {
      const output = {
        type: 'intent-detection',
        intents: result.detectedIntents,
        suggestions: result.suggestions,
        confidence: result.confidence,
        message: formatMessage(result)
      };

      console.log(JSON.stringify(output, null, 2));
    }

    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: error.message
    }));
    process.exit(0); // Don't block on errors
  }
}

function formatMessage(result) {
  let message = '';

  if (result.detectedIntents.length > 0) {
    message += `🎯 Detected intent: ${result.detectedIntents.join(', ')}\n`;
    message += `Consider using: ${result.detectedIntents[0]}`;
  }

  if (result.suggestions.length > 0 && result.detectedIntents.length === 0) {
    message += `💡 Suggestion: ${result.suggestions[0].skill}\n`;
    message += `Reason: ${result.suggestions[0].reason}`;
  }

  return message;
}

main();