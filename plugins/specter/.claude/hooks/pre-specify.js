/**
 * @fileoverview Pre-Specify Hook
 *
 * Executes before specter:specify to prepare environment and gather context.
 * Auto-detects project type, domain, and loads relevant templates.
 *
 * Features:
 * - Project type detection (greenfield vs brownfield)
 * - Blueprint validation (warns if missing)
 * - Domain detection (e-commerce, SaaS, API, social, analytics, CMS, fintech)
 * - Template loading (domain-specific requirements, user stories, entities)
 * - Research task queuing (identifies tech/domain topics for AI analysis)
 * - Branch naming validation
 * - AI inference level adjustment (based on project type and domain)
 *
 * @param {Object} context - Hook execution context
 * @returns {Promise<Object>} Enhanced context with templates and research tasks
 * @author Specter Plugin Team
 */

module.exports = async function preSpecify(context) {
  const { config, options, description, projectPath } = context;

  // 1. Validate project initialization
  if (!config.workflow.projectType) {
    // Auto-detect project type
    const isNewProject = await detectProjectType(projectPath);
    config.workflow.projectType = isNewProject ? 'greenfield' : 'brownfield';

    context.messages.push({
      type: 'info',
      text: `Auto-detected project type: ${config.workflow.projectType}`
    });
  }

  // 2. Check blueprint requirements (optional in flat model)
  if (config.workflow.requireBlueprint && !options.skipValidation) {
    const hasBlueprint = await checkBlueprint(projectPath);

    if (!hasBlueprint) {
      context.warnings.push({
        type: 'warning',
        text: 'Architecture blueprint not found. Consider running specter:blueprint to define architecture standards.'
      });
    }
  }

  // 3. Load domain templates
  const detectedDomain = await detectDomain(description);
  if (detectedDomain) {
    context.domain = detectedDomain;
    context.templates = await loadDomainTemplates(detectedDomain);

    context.messages.push({
      type: 'info',
      text: `Detected domain: ${detectedDomain}. Loading specialized templates.`
    });
  }

  // 4. Prepare research context
  if (config.ai.autoResearch && !options.skipResearch) {
    // Queue research tasks for the researcher agent
    context.researchTasks = await identifyResearchNeeds(description, detectedDomain);

    if (context.researchTasks.length > 0) {
      context.messages.push({
        type: 'info',
        text: `Queued ${context.researchTasks.length} research tasks for AI analysis`
      });
    }
  }

  // 5. Check for existing specifications
  const existingSpecs = await findExistingSpecs(projectPath);
  if (existingSpecs.length > 0 && !options.update) {
    context.existingSpecs = existingSpecs;
    context.warnings.push({
      type: 'warning',
      text: `Found ${existingSpecs.length} existing specifications. Use --update flag to modify existing spec.`
    });
  }

  // 6. Validate branch naming
  if (config.integrations.github.enabled && config.integrations.github.branchProtection) {
    const branchName = await generateBranchName(description, config);
    const isValid = await validateBranchName(branchName);

    if (!isValid) {
      context.warnings.push({
        type: 'warning',
        text: `Generated branch name "${branchName}" may not meet repository standards`
      });
    }
  }

  // 7. Set AI inference level based on context
  if (!options.inferenceLevel) {
    // Adjust based on project type and domain
    if (config.workflow.projectType === 'brownfield') {
      context.inferenceLevel = 'minimal'; // Be conservative in existing projects
    } else if (detectedDomain && domainTemplates[detectedDomain]) {
      context.inferenceLevel = 'aggressive'; // We have good templates
    } else {
      context.inferenceLevel = config.ai.inferenceLevel || 'moderate';
    }
  }

  return context;
};

// Helper Functions

async function detectProjectType(projectPath) {
  const indicators = {
    brownfield: [
      'package.json',
      'requirements.txt',
      'Gemfile',
      'pom.xml',
      'build.gradle',
      '.git'
    ]
  };

  for (const file of indicators.brownfield) {
    if (await fileExists(`${projectPath}/${file}`)) {
      return false; // It's a brownfield project
    }
  }

  return true; // It's a greenfield project
}

async function checkBlueprint(projectPath) {
  const blueprintPaths = [
    '.specter/architecture-blueprint.md',
    '.specify/memory/constitution.md', // Legacy support
    'ARCHITECTURE.md'
  ];

  for (const path of blueprintPaths) {
    if (await fileExists(`${projectPath}/${path}`)) {
      return true;
    }
  }

  return false;
}

async function detectDomain(description) {
  const domains = {
    'e-commerce': ['shop', 'cart', 'checkout', 'payment', 'product', 'inventory'],
    'saas': ['subscription', 'tenant', 'billing', 'usage', 'tier'],
    'api': ['endpoint', 'rest', 'graphql', 'openapi', 'swagger'],
    'social': ['user', 'post', 'comment', 'like', 'follow', 'feed'],
    'analytics': ['dashboard', 'metrics', 'charts', 'reports', 'kpi'],
    'cms': ['content', 'page', 'blog', 'article', 'editor'],
    'fintech': ['transaction', 'account', 'balance', 'transfer', 'kyc']
  };

  const lowercaseDesc = description.toLowerCase();

  for (const [domain, keywords] of Object.entries(domains)) {
    const matches = keywords.filter(keyword => lowercaseDesc.includes(keyword));
    if (matches.length >= 2) {
      return domain;
    }
  }

  return null;
}

async function loadDomainTemplates(domain) {
  // Load domain-specific templates
  const templatePath = `plugins/specter/templates/domains/${domain}`;

  try {
    return {
      requirements: await loadTemplate(`${templatePath}/requirements.md`),
      userStories: await loadTemplate(`${templatePath}/user-stories.md`),
      edgeCases: await loadTemplate(`${templatePath}/edge-cases.md`),
      entities: await loadTemplate(`${templatePath}/entities.md`)
    };
  } catch (error) {
    console.log(`No specialized templates for domain: ${domain}`);
    return {};
  }
}

async function identifyResearchNeeds(description, domain) {
  const researchTasks = [];

  // Technology research
  const techKeywords = ['database', 'framework', 'library', 'api', 'cloud', 'hosting'];
  techKeywords.forEach(keyword => {
    if (description.toLowerCase().includes(keyword)) {
      researchTasks.push({
        type: 'technology',
        topic: keyword,
        context: description
      });
    }
  });

  // Domain best practices
  if (domain) {
    researchTasks.push({
      type: 'best-practices',
      topic: domain,
      context: 'domain-specific patterns'
    });
  }

  // Architecture patterns
  if (description.length > 100) { // Substantial description
    researchTasks.push({
      type: 'architecture',
      topic: 'patterns',
      context: description
    });
  }

  return researchTasks;
}

async function findExistingSpecs(projectPath) {
  const specPattern = 'features/*/spec.md';
  // Implementation would use glob or similar
  return [];
}

async function generateBranchName(description, config) {
  // Extract key terms and create branch name
  const words = description.toLowerCase()
    .split(/\s+/)
    .filter(word => word.length > 3)
    .slice(0, 3);

  return words.join('-');
}

async function validateBranchName(branchName) {
  // Check branch naming conventions
  const validPattern = /^[a-z0-9-]+$/;
  return validPattern.test(branchName);
}

async function fileExists(path) {
  // Check if file exists
  const fs = require('fs').promises;
  try {
    await fs.access(path);
    return true;
  } catch {
    return false;
  }
}

async function loadTemplate(path) {
  const fs = require('fs').promises;
  return await fs.readFile(path, 'utf8');
}

// Domain template configurations
const domainTemplates = {
  'e-commerce': true,
  'saas': true,
  'api': true,
  'social': true,
  'analytics': true,
  'cms': true,
  'fintech': true
};