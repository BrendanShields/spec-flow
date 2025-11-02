# Spec Workflow Configuration Management Analysis

**Date**: November 2, 2025  
**Version**: 1.0.0  
**Author**: Configuration Analysis Team  
**Status**: Complete

## Executive Summary

This document provides a comprehensive analysis of the Spec workflow plugin's configuration management system, identifying current limitations and proposing a robust, extensible configuration architecture. The analysis reveals that while Spec v3.0 has sophisticated workflow capabilities, its configuration system is fragmented, hardcoded, and lacks centralized management.

### Key Findings

1. **Configuration is scattered** across CLAUDE.md files, hardcoded paths, and implicit defaults
2. **No centralized configuration schema** or validation mechanism exists
3. **Limited extensibility** for custom workflows, paths, or integrations
4. **Hardcoded assumptions** about directory structure (`.spec/`, `features/`, etc.)
5. **No auto-detection** capabilities for project type or existing tools
6. **Configuration discovery** is ad-hoc and inconsistent across skills

### Primary Recommendations

1. Implement a **hierarchical configuration system** with clear precedence
2. Create a **JSON Schema-based configuration** with validation
3. Build **auto-detection capabilities** for project initialization
4. Develop **configuration management commands** for users
5. Enable **template-driven extensibility** for custom workflows

## Current State Assessment

### 1. Configuration Storage Locations

The current system stores configuration in multiple, disconnected locations:

#### A. CLAUDE.md Variables
```markdown
# Found in user's project CLAUDE.md
SPEC_AUTO_CHECKPOINT=true
SPEC_VALIDATE_ON_SAVE=true
SPEC_ATLASSIAN_SYNC=enabled
SPEC_JIRA_PROJECT_KEY=PROJ
SPEC_CONFLUENCE_ROOT_PAGE_ID=123456
SPEC_ORCHESTRATE_MODE=interactive|auto
SPEC_ORCHESTRATE_SKIP_ANALYZE=false
SPEC_IMPLEMENT_MAX_PARALLEL=3
SPEC_CLARIFY_MAX_QUESTIONS=4
```

**Issues**:
- No validation or type checking
- Mixed with other project documentation
- No clear schema or required fields
- Discovery requires grep/regex parsing

#### B. Hardcoded Paths

Numerous paths are hardcoded throughout the codebase:

```bash
# In scripts and skills
.spec/                      # Configuration directory
.spec-state/               # Session state
.spec-memory/              # Persistent memory
features/                  # Feature artifacts
features/###-feature-name/ # Naming convention enforced
```

**Issues**:
- Cannot customize directory structure
- Forced naming conventions (###-feature-name)
- No support for monorepo structures
- Conflicts with existing project layouts

#### C. Hook Configuration

Hooks have absolute paths hardcoded in hooks.json:

```json
{
  "event": "UserPromptSubmit",
  "command": "node /Users/dev/dev/tools/spec-flow/plugins/spec/.claude/hooks/detect-intent.js"
}
```

**Issues**:
- Breaks on different installations
- No environment variable support
- Cannot relocate plugin directory
- Platform-specific paths

#### D. Implicit Defaults

Many configurations have implicit defaults with no documentation:

- Session checkpoint frequency (30 minutes)
- Maximum parallel tasks (3)
- Token limits for state files
- Archive thresholds for memory files
- Retry counts and backoff strategies

### 2. Configuration Discovery Mechanisms

Current discovery is inconsistent and fragile:

#### Pattern 1: Grep-based Discovery
```bash
if grep -q "SPEC_ATLASSIAN_SYNC=enabled" CLAUDE.md 2>/dev/null; then
    PROJECT_KEY=$(grep "SPEC_JIRA_PROJECT_KEY" CLAUDE.md | cut -d= -f2)
fi
```

#### Pattern 2: File Existence Checks
```bash
test -d .spec && echo "exists" || echo "new"
ls src/ package.json *.py 2>/dev/null | wc -l
```

#### Pattern 3: State File Parsing
```bash
CURRENT_FEATURE=$(cat .spec-state/current-session.md | grep "Active Feature:" | cut -d: -f2)
```

**Issues**:
- Error-prone string manipulation
- No consistent parsing library
- Silent failures on malformed data
- Race conditions on concurrent access

### 3. Configuration Inconsistencies

#### Naming Conventions
- Features: `###-feature-name` (enforced)
- Tasks: `T###` (enforced)
- User Stories: `US#` (suggested)
- Branches: Various patterns accepted

#### Path Specifications
- Some require absolute paths
- Others use relative paths
- No consistent resolution strategy
- Working directory assumptions vary

#### Integration Points
- MCP servers: Sometimes auto-detected, sometimes configured
- Git: Assumed present, no fallback
- External tools: No consistent detection pattern

### 4. Missing Configuration Capabilities

The current system lacks:

1. **Project Templates**: No way to define project-specific workflows
2. **Team Standards**: Cannot enforce team conventions
3. **Custom Phases**: No ability to add/remove workflow phases
4. **Integration Mapping**: Cannot configure custom MCP mappings
5. **Performance Tuning**: No control over parallel execution, timeouts
6. **Localization**: All templates/messages in English only
7. **Access Control**: No way to restrict certain operations
8. **Audit Logging**: No configuration for compliance needs

## Gap Analysis

### Critical Gaps

| Gap | Current State | Desired State | Impact |
|-----|--------------|---------------|---------|
| **Schema Validation** | No validation | JSON Schema with types | High - Prevents runtime errors |
| **Configuration Hierarchy** | Single flat namespace | Multi-level with precedence | High - Enables customization |
| **Auto-detection** | Manual configuration | Smart defaults from context | High - Better UX |
| **Path Configuration** | Hardcoded | Fully configurable | Medium - Flexibility |
| **Template System** | Static templates | User-customizable | Medium - Extensibility |
| **Migration Support** | None | Automated migration tools | Medium - Upgrades |

### Feature Gaps

| Feature | Priority | Complexity | User Impact |
|---------|----------|------------|-------------|
| Custom workflow phases | P1 | High | Enables domain-specific workflows |
| Project type detection | P1 | Medium | Better initialization |
| Configuration validation | P1 | Low | Prevents errors |
| Multi-language support | P2 | Medium | International teams |
| Plugin composition | P2 | High | Workflow combinations |
| Configuration inheritance | P2 | Medium | Team standards |
| Hot reload | P3 | Medium | Developer experience |
| Configuration UI | P3 | High | Non-technical users |

## Proposed Configuration Schema

### Complete Configuration Example

```json
{
  "$schema": "https://spec-flow.dev/schemas/config/v1.0.0.json",
  "version": "1.0.0",
  "extends": ["@company/team-standards", "./base-config.json"],
  
  "project": {
    "type": "auto|monorepo|microservice|library|application",
    "name": "${PROJECT_NAME:-MyProject}",
    "description": "Project description",
    "language": ["typescript", "python"],
    "framework": ["nextjs", "fastapi"],
    "repository": {
      "type": "git",
      "url": "${GIT_REMOTE_URL}",
      "mainBranch": "${GIT_MAIN_BRANCH:-main}",
      "conventions": {
        "branches": {
          "feature": "feat/{feature-id}-{name}",
          "bugfix": "fix/{issue-id}-{description}",
          "release": "release/{version}"
        },
        "commits": {
          "format": "conventional|gitmoji|custom",
          "template": "{type}({scope}): {subject}"
        }
      }
    }
  },

  "paths": {
    "base": "${SPEC_BASE_PATH:-.}",
    "config": "${SPEC_CONFIG_PATH:-.spec}",
    "state": "${SPEC_STATE_PATH:-.spec-state}",
    "memory": "${SPEC_MEMORY_PATH:-.spec-memory}",
    "features": "${SPEC_FEATURES_PATH:-features}",
    "templates": "${SPEC_TEMPLATES_PATH:-.spec/templates}",
    "scripts": "${SPEC_SCRIPTS_PATH:-.spec/scripts}",
    "artifacts": {
      "specs": "${paths.features}/{feature-id}/spec.md",
      "plans": "${paths.features}/{feature-id}/plan.md",
      "tasks": "${paths.features}/{feature-id}/tasks.md",
      "tests": "${paths.features}/{feature-id}/tests/"
    }
  },

  "naming": {
    "features": {
      "pattern": "{number:3}-{name:kebab}",
      "examples": ["001-user-auth", "002-payment-gateway"],
      "validation": "^\\d{3}-[a-z][a-z0-9-]*$",
      "sequence": {
        "start": 1,
        "increment": 1,
        "padding": 3
      }
    },
    "tasks": {
      "pattern": "T{number:3}",
      "validation": "^T\\d{3}$"
    },
    "userStories": {
      "pattern": "US{number}",
      "validation": "^US\\d+$"
    }
  },

  "workflow": {
    "phases": {
      "initialize": {
        "enabled": true,
        "skills": ["init", "discover", "blueprint"],
        "auto": {
          "detectProjectType": true,
          "scanDependencies": true,
          "analyzeStructure": true,
          "suggestBlueprint": true
        }
      },
      "define": {
        "enabled": true,
        "skills": ["generate", "clarify", "update"],
        "templates": {
          "spec": "${paths.templates}/spec-template.md",
          "userStory": "${paths.templates}/user-story-template.md"
        },
        "validation": {
          "requireUserStories": true,
          "minStories": 1,
          "requireAcceptanceCriteria": true
        }
      },
      "design": {
        "enabled": true,
        "skills": ["plan", "analyze", "blueprint"],
        "templates": {
          "plan": "${paths.templates}/plan-template.md",
          "adr": "${paths.templates}/adr-template.md"
        },
        "review": {
          "required": false,
          "reviewers": ["@team-lead", "@architect"]
        }
      },
      "build": {
        "enabled": true,
        "skills": ["tasks", "implement"],
        "templates": {
          "tasks": "${paths.templates}/tasks-template.md"
        },
        "execution": {
          "maxParallel": "${SPEC_MAX_PARALLEL:-3}",
          "testFirst": false,
          "autoCommit": false,
          "requireTests": true
        }
      },
      "track": {
        "enabled": true,
        "skills": ["update", "metrics", "orchestrate"],
        "reporting": {
          "frequency": "daily|weekly|sprint",
          "format": "markdown|json|html"
        }
      },
      "custom": {
        "qa": {
          "enabled": false,
          "skills": ["test-generate", "test-run", "coverage-report"],
          "afterPhase": "build"
        },
        "deploy": {
          "enabled": false,
          "skills": ["package", "deploy", "smoke-test"],
          "afterPhase": "qa"
        }
      }
    },
    
    "orchestration": {
      "mode": "${SPEC_ORCHESTRATE_MODE:-interactive}",
      "skipAnalyze": false,
      "autoApprove": [],
      "requireApproval": ["plan", "implement"],
      "parallelPhases": false
    },

    "subagents": {
      "implementer": {
        "enabled": true,
        "model": "sonnet",
        "maxParallel": 3,
        "retryStrategy": {
          "maxAttempts": 3,
          "backoff": "exponential",
          "retryableErrors": ["ETIMEDOUT", "ECONNRESET", "429"]
        }
      },
      "researcher": {
        "enabled": true,
        "model": "sonnet",
        "sources": ["web", "documentation", "codebase"],
        "maxSearchResults": 10
      },
      "analyzer": {
        "enabled": true,
        "model": "sonnet",
        "depth": "standard|shallow|deep",
        "focus": ["consistency", "completeness", "quality"]
      }
    }
  },

  "integrations": {
    "mcp": {
      "atlassian": {
        "enabled": "${SPEC_ATLASSIAN_SYNC:-false}",
        "jira": {
          "projectKey": "${SPEC_JIRA_PROJECT_KEY}",
          "baseUrl": "${JIRA_BASE_URL}",
          "authentication": {
            "type": "bearer|basic|oauth",
            "token": "${JIRA_API_TOKEN}"
          },
          "sync": {
            "createIssues": true,
            "updateIssues": true,
            "linkFeatures": true,
            "syncStatus": true
          },
          "mapping": {
            "P1": "Highest",
            "P2": "High",
            "P3": "Medium",
            "spec": "Story",
            "task": "Sub-task"
          }
        },
        "confluence": {
          "spaceKey": "${SPEC_CONFLUENCE_SPACE_KEY}",
          "rootPageId": "${SPEC_CONFLUENCE_ROOT_PAGE_ID}",
          "authentication": {
            "token": "${CONFLUENCE_API_TOKEN}"
          },
          "sync": {
            "createPages": true,
            "updatePages": true,
            "publishPlans": true,
            "publishMetrics": false
          }
        }
      },
      "github": {
        "enabled": "${SPEC_GITHUB_SYNC:-false}",
        "owner": "${GITHUB_OWNER}",
        "repo": "${GITHUB_REPO}",
        "authentication": {
          "token": "${GITHUB_TOKEN}"
        },
        "sync": {
          "createIssues": false,
          "createPRs": true,
          "updateStatus": true,
          "labels": {
            "feature": "enhancement",
            "bug": "bug",
            "P1": "priority:high",
            "P2": "priority:medium",
            "P3": "priority:low"
          }
        }
      },
      "linear": {
        "enabled": "${SPEC_LINEAR_SYNC:-false}",
        "teamId": "${SPEC_LINEAR_TEAM_ID}",
        "authentication": {
          "apiKey": "${LINEAR_API_KEY}"
        },
        "sync": {
          "createIssues": true,
          "updateIssues": true,
          "mapping": {
            "spec": "feature",
            "task": "task",
            "bug": "bug"
          }
        }
      },
      "custom": {
        "myTool": {
          "enabled": false,
          "endpoint": "https://api.example.com",
          "authentication": {
            "type": "custom",
            "headers": {
              "X-API-Key": "${MY_TOOL_API_KEY}"
            }
          },
          "hooks": {
            "beforeGenerate": "./hooks/mytool-prepare.js",
            "afterPlan": "./hooks/mytool-sync.js",
            "onImplement": "./hooks/mytool-track.js"
          }
        }
      }
    },
    
    "git": {
      "autoCommit": false,
      "commitTemplate": "${paths.templates}/commit-template.txt",
      "hooks": {
        "preCommit": ["lint", "format", "test"],
        "prePush": ["test", "build"]
      }
    },

    "ci": {
      "provider": "github-actions|gitlab-ci|jenkins|circle-ci",
      "configPath": ".github/workflows",
      "onFeatureComplete": {
        "createPR": true,
        "runTests": true,
        "requestReview": true
      }
    }
  },

  "state": {
    "persistence": {
      "session": {
        "location": "${paths.state}",
        "format": "markdown|json",
        "checkpoint": {
          "enabled": true,
          "frequency": "30m",
          "maxCheckpoints": 10,
          "compression": false
        }
      },
      "memory": {
        "location": "${paths.memory}",
        "format": "markdown",
        "archive": {
          "enabled": true,
          "afterDays": 90,
          "location": "${paths.memory}/archive",
          "compression": true
        }
      }
    },
    "limits": {
      "maxSessionSize": "2000",
      "maxMemorySize": "5000",
      "maxFeatures": 100,
      "tokenLimits": {
        "stateFile": 2000,
        "memoryFile": 3000,
        "totalContext": 10000
      }
    }
  },

  "validation": {
    "onSave": true,
    "beforeCommit": true,
    "rules": {
      "spec": {
        "required": ["title", "userStories", "acceptanceCriteria"],
        "minUserStories": 1,
        "maxUserStories": 10
      },
      "plan": {
        "required": ["technicalContext", "designDecisions"],
        "requireADR": true
      },
      "tasks": {
        "required": ["phases", "tasks"],
        "minTasks": 1,
        "maxTasks": 50,
        "requireEstimates": false
      }
    }
  },

  "templates": {
    "sources": [
      "${paths.templates}",
      "@spec-flow/standard-templates",
      "https://templates.spec-flow.dev/v1"
    ],
    "custom": {
      "spec": {
        "path": "${paths.templates}/custom-spec.md",
        "variables": {
          "company": "ACME Corp",
          "team": "Platform Team"
        }
      }
    },
    "variables": {
      "PROJECT_NAME": "${project.name}",
      "CURRENT_DATE": "${date:YYYY-MM-DD}",
      "USER": "${env:USER}",
      "FEATURE_ID": "${workflow.currentFeature}"
    }
  },

  "performance": {
    "caching": {
      "enabled": true,
      "ttl": 300,
      "maxSize": "100MB"
    },
    "parallelization": {
      "enabled": true,
      "maxWorkers": "${SPEC_MAX_WORKERS:-4}",
      "taskQueue": "fifo|lifo|priority"
    },
    "optimization": {
      "lazyLoading": true,
      "progressiveDisclosure": true,
      "tokenReduction": true
    }
  },

  "security": {
    "secrets": {
      "provider": "env|vault|keychain|aws-secrets",
      "prefix": "SPEC_SECRET_"
    },
    "permissions": {
      "readOnly": false,
      "allowedPaths": ["${paths.base}"],
      "deniedPaths": ["node_modules", ".git", "dist"]
    },
    "audit": {
      "enabled": false,
      "logPath": "${paths.config}/audit.log",
      "events": ["generate", "plan", "implement"]
    }
  },

  "notifications": {
    "enabled": false,
    "channels": {
      "slack": {
        "enabled": false,
        "webhook": "${SLACK_WEBHOOK_URL}",
        "events": ["featureComplete", "buildFailed"]
      },
      "email": {
        "enabled": false,
        "smtp": {
          "host": "${SMTP_HOST}",
          "port": 587,
          "secure": true
        },
        "recipients": ["team@example.com"],
        "events": ["weeklyReport"]
      }
    }
  },

  "telemetry": {
    "enabled": false,
    "anonymous": true,
    "events": ["commandUsage", "errorRate", "performance"],
    "endpoint": "https://telemetry.spec-flow.dev"
  },

  "experimental": {
    "features": {
      "aiReview": false,
      "autoRefactor": false,
      "predictiveCompletion": false,
      "voiceCommands": false
    }
  }
}
```

## Configuration Levels and Priority

### Configuration Hierarchy

The system should support multiple configuration levels with clear precedence:

```
1. Command-line arguments (highest priority)
   └─ 2. Environment variables
      └─ 3. Project configuration (.spec/config.json)
         └─ 4. User configuration (~/.spec-flow/config.json)
            └─ 5. Team configuration (from extends)
               └─ 6. Default configuration (built-in)
```

### Resolution Strategy

```javascript
// Pseudo-code for configuration resolution
function resolveConfig() {
  let config = loadDefaults();
  
  // Layer configurations
  config = merge(config, loadGlobalConfig());
  config = merge(config, loadTeamConfig());
  config = merge(config, loadUserConfig());
  config = merge(config, loadProjectConfig());
  config = merge(config, loadEnvironmentVars());
  config = merge(config, parseCommandLineArgs());
  
  // Resolve variables
  config = interpolateVariables(config);
  
  // Validate final config
  validateAgainstSchema(config);
  
  return config;
}
```

### Variable Interpolation

Support multiple variable sources:

```json
{
  "project": {
    "name": "${env:PROJECT_NAME}",          // Environment variable
    "version": "${package:version}",        // From package.json
    "date": "${date:YYYY-MM-DD}",          // Current date
    "user": "${git:user.name}",            // Git config
    "branch": "${git:branch}",             // Current branch
    "custom": "${custom:myValue}"          // User-defined
  }
}
```

## Auto-Detection Strategy

### Project Type Detection

```javascript
class ProjectDetector {
  async detect() {
    const indicators = await this.gatherIndicators();
    return this.inferProjectType(indicators);
  }

  async gatherIndicators() {
    return {
      // Package managers
      hasPackageJson: await exists('package.json'),
      hasRequirementsTxt: await exists('requirements.txt'),
      hasPomXml: await exists('pom.xml'),
      hasGemfile: await exists('Gemfile'),
      hasCargoToml: await exists('Cargo.toml'),
      
      // Build tools
      hasWebpackConfig: await exists('webpack.config.js'),
      hasViteConfig: await exists('vite.config.js'),
      hasDockerfile: await exists('Dockerfile'),
      hasGradleBuild: await exists('build.gradle'),
      
      // Frameworks
      hasNextConfig: await exists('next.config.js'),
      hasDjangoSettings: await exists('manage.py'),
      hasRailsConfig: await exists('config/application.rb'),
      hasSpringBoot: await exists('src/main/resources/application.properties'),
      
      // Project structure
      hasSrcDir: await exists('src/'),
      hasLibDir: await exists('lib/'),
      hasAppDir: await exists('app/'),
      hasPublicDir: await exists('public/'),
      hasTestDir: await exists('test/') || await exists('tests/'),
      
      // Monorepo indicators
      hasLernaJson: await exists('lerna.json'),
      hasNxJson: await exists('nx.json'),
      hasPackagesDir: await exists('packages/'),
      hasAppsDir: await exists('apps/'),
      hasPnpmWorkspace: await exists('pnpm-workspace.yaml'),
      
      // Version control
      hasGitDir: await exists('.git/'),
      hasGitignore: await exists('.gitignore'),
      
      // Documentation
      hasReadme: await exists('README.md'),
      hasDocsDir: await exists('docs/'),
      
      // CI/CD
      hasGithubActions: await exists('.github/workflows/'),
      hasGitlabCI: await exists('.gitlab-ci.yml'),
      hasJenkinsfile: await exists('Jenkinsfile'),
      
      // File counts
      jsFileCount: await countFiles('**/*.{js,jsx,ts,tsx}'),
      pyFileCount: await countFiles('**/*.py'),
      javaFileCount: await countFiles('**/*.java'),
      goFileCount: await countFiles('**/*.go'),
      rustFileCount: await countFiles('**/*.rs'),
      
      // Size metrics
      totalFiles: await countFiles('**/*'),
      totalLinesOfCode: await countLinesOfCode(),
      
      // Dependencies
      dependencies: await extractDependencies(),
      devDependencies: await extractDevDependencies()
    };
  }

  inferProjectType(indicators) {
    const scores = {
      monorepo: 0,
      microservice: 0,
      library: 0,
      application: 0,
      api: 0,
      cli: 0
    };

    // Monorepo detection
    if (indicators.hasLernaJson || indicators.hasNxJson || 
        indicators.hasPackagesDir || indicators.hasPnpmWorkspace) {
      scores.monorepo += 10;
    }

    // Microservice detection
    if (indicators.hasDockerfile && indicators.totalFiles < 1000) {
      scores.microservice += 5;
    }

    // Library detection
    if (indicators.hasLibDir && !indicators.hasAppDir && 
        !indicators.hasPublicDir) {
      scores.library += 5;
    }

    // Application detection
    if (indicators.hasPublicDir || indicators.hasNextConfig || 
        indicators.hasDjangoSettings) {
      scores.application += 5;
    }

    // API detection
    if (indicators.dependencies.includes('express') || 
        indicators.dependencies.includes('fastapi') ||
        indicators.hasSpringBoot) {
      scores.api += 5;
    }

    // CLI detection
    if (indicators.dependencies.includes('commander') ||
        indicators.dependencies.includes('yargs') ||
        indicators.dependencies.includes('click')) {
      scores.cli += 5;
    }

    // Return highest scoring type
    return Object.entries(scores)
      .sort(([,a], [,b]) => b - a)[0][0];
  }
}
```

### Framework Detection

```javascript
class FrameworkDetector {
  async detect() {
    const frameworks = [];
    
    // Frontend frameworks
    if (await this.hasReact()) frameworks.push('react');
    if (await this.hasVue()) frameworks.push('vue');
    if (await this.hasAngular()) frameworks.push('angular');
    if (await this.hasNext()) frameworks.push('nextjs');
    if (await this.hasNuxt()) frameworks.push('nuxtjs');
    
    // Backend frameworks
    if (await this.hasExpress()) frameworks.push('express');
    if (await this.hasFastAPI()) frameworks.push('fastapi');
    if (await this.hasDjango()) frameworks.push('django');
    if (await this.hasRails()) frameworks.push('rails');
    if (await this.hasSpring()) frameworks.push('spring');
    
    // Test frameworks
    if (await this.hasJest()) frameworks.push('jest');
    if (await this.hasMocha()) frameworks.push('mocha');
    if (await this.hasPytest()) frameworks.push('pytest');
    if (await this.hasRSpec()) frameworks.push('rspec');
    
    return frameworks;
  }

  async hasReact() {
    const pkg = await readPackageJson();
    return pkg?.dependencies?.react || pkg?.devDependencies?.react;
  }

  async hasNext() {
    return await exists('next.config.js') || 
           await exists('next.config.mjs');
  }

  // ... more framework detection methods
}
```

### Optimal Defaults Generation

```javascript
class DefaultsGenerator {
  generate(projectType, frameworks, indicators) {
    const defaults = {
      project: {
        type: projectType,
        language: this.inferLanguages(indicators),
        framework: frameworks
      },
      
      paths: this.inferPaths(projectType, indicators),
      
      naming: this.inferNaming(projectType),
      
      workflow: this.inferWorkflow(projectType, frameworks),
      
      integrations: this.inferIntegrations(indicators),
      
      validation: this.inferValidation(frameworks)
    };

    return defaults;
  }

  inferPaths(projectType, indicators) {
    if (projectType === 'monorepo') {
      return {
        config: '.spec',
        features: 'packages/shared/features',
        templates: 'packages/shared/templates'
      };
    }
    
    if (indicators.hasSrcDir) {
      return {
        config: '.spec',
        features: 'src/features',
        templates: 'src/templates'
      };
    }
    
    return {
      config: '.spec',
      features: 'features',
      templates: 'templates'
    };
  }

  inferWorkflow(projectType, frameworks) {
    const workflow = {
      phases: {
        initialize: { enabled: true },
        define: { enabled: true },
        design: { enabled: true },
        build: { enabled: true },
        track: { enabled: true }
      }
    };

    // Add test phase for projects with test frameworks
    if (frameworks.some(f => ['jest', 'mocha', 'pytest'].includes(f))) {
      workflow.phases.test = {
        enabled: true,
        skills: ['test-generate', 'test-run'],
        afterPhase: 'build'
      };
    }

    // Add deploy phase for applications
    if (['application', 'api', 'microservice'].includes(projectType)) {
      workflow.phases.deploy = {
        enabled: true,
        skills: ['package', 'deploy'],
        afterPhase: 'test'
      };
    }

    return workflow;
  }

  inferIntegrations(indicators) {
    const integrations = {};

    // Git integration
    if (indicators.hasGitDir) {
      integrations.git = {
        enabled: true,
        autoCommit: false
      };
    }

    // CI/CD integration
    if (indicators.hasGithubActions) {
      integrations.ci = {
        provider: 'github-actions',
        configPath: '.github/workflows'
      };
    } else if (indicators.hasGitlabCI) {
      integrations.ci = {
        provider: 'gitlab-ci',
        configPath: '.gitlab-ci.yml'
      };
    }

    return integrations;
  }
}
```

## User Experience Design

### Configuration Management Commands

```bash
# Initialize configuration
spec config init [--auto-detect] [--interactive]

# View current configuration
spec config show [--effective] [--source]

# Get specific value
spec config get paths.features

# Set configuration value
spec config set paths.features "src/features"

# Validate configuration
spec config validate

# Export configuration
spec config export [--format=json|yaml|env]

# Import configuration
spec config import <file>

# Reset to defaults
spec config reset [--keep-credentials]

# Migrate from v2 to v3
spec config migrate

# Create team template
spec config template create <name>

# Use team template
spec config template use <name>
```

### Interactive Configuration

```typescript
class InteractiveConfigurator {
  async configure() {
    console.log('🚀 Welcome to Spec Configuration');
    
    // Project detection
    const detected = await this.detectProject();
    console.log(`📁 Detected project type: ${detected.type}`);
    
    const useDetected = await this.confirm(
      'Use detected settings?',
      true
    );
    
    let config = useDetected ? detected : {};
    
    // Core configuration
    config.project = await this.configureProject(config.project);
    config.paths = await this.configurePaths(config.paths);
    config.naming = await this.configureNaming(config.naming);
    
    // Optional features
    const features = await this.selectFeatures();
    
    if (features.includes('jira')) {
      config.integrations.mcp.atlassian = 
        await this.configureJira();
    }
    
    if (features.includes('github')) {
      config.integrations.github = 
        await this.configureGitHub();
    }
    
    // Advanced options
    if (await this.confirm('Configure advanced options?')) {
      config.workflow = await this.configureWorkflow();
      config.performance = await this.configurePerformance();
      config.validation = await this.configureValidation();
    }
    
    // Save configuration
    await this.saveConfig(config);
    
    console.log('✅ Configuration complete!');
    console.log('📝 Saved to .spec/config.json');
    
    // Offer to initialize project
    if (await this.confirm('Initialize project now?')) {
      await this.runCommand('spec init');
    }
  }

  async selectFeatures() {
    return await this.multiSelect('Select integrations:', [
      { value: 'jira', label: 'JIRA (Atlassian)' },
      { value: 'confluence', label: 'Confluence' },
      { value: 'github', label: 'GitHub Issues' },
      { value: 'linear', label: 'Linear' },
      { value: 'slack', label: 'Slack Notifications' }
    ]);
  }
}
```

### Configuration Validation

```typescript
class ConfigValidator {
  private schema: JSONSchema;
  
  async validate(config: Config): Promise<ValidationResult> {
    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];
    
    // Schema validation
    const schemaResult = await this.validateSchema(config);
    errors.push(...schemaResult.errors);
    
    // Path validation
    const pathResult = await this.validatePaths(config.paths);
    errors.push(...pathResult.errors);
    warnings.push(...pathResult.warnings);
    
    // Integration validation
    const integrationResult = 
      await this.validateIntegrations(config.integrations);
    errors.push(...integrationResult.errors);
    
    // Cross-field validation
    const crossFieldResult = 
      await this.validateCrossFields(config);
    errors.push(...crossFieldResult.errors);
    
    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }

  async validatePaths(paths: PathConfig): Promise<ValidationResult> {
    const errors = [];
    const warnings = [];
    
    // Check required paths exist or can be created
    for (const [key, path] of Object.entries(paths)) {
      if (typeof path !== 'string') continue;
      
      const resolvedPath = this.resolvePath(path);
      
      if (key === 'base' && !await exists(resolvedPath)) {
        errors.push({
          field: `paths.${key}`,
          message: `Base path does not exist: ${resolvedPath}`
        });
      }
      
      if (key.endsWith('templates') && 
          !await exists(resolvedPath)) {
        warnings.push({
          field: `paths.${key}`,
          message: `Template path will be created: ${resolvedPath}`
        });
      }
    }
    
    return { errors, warnings };
  }

  async validateIntegrations(integrations: IntegrationConfig) {
    const errors = [];
    
    // Validate JIRA configuration
    if (integrations.mcp?.atlassian?.enabled) {
      if (!integrations.mcp.atlassian.jira?.projectKey) {
        errors.push({
          field: 'integrations.mcp.atlassian.jira.projectKey',
          message: 'JIRA project key required when Atlassian sync enabled'
        });
      }
    }
    
    // Validate GitHub configuration
    if (integrations.github?.enabled) {
      if (!integrations.github.owner || !integrations.github.repo) {
        errors.push({
          field: 'integrations.github',
          message: 'GitHub owner and repo required when GitHub sync enabled'
        });
      }
    }
    
    return { errors, warnings: [] };
  }
}
```

### Migration Support

```typescript
class ConfigMigrator {
  async migrate(fromVersion: string, toVersion: string) {
    console.log(`🔄 Migrating configuration from v${fromVersion} to v${toVersion}`);
    
    // Load old configuration
    const oldConfig = await this.loadOldConfig(fromVersion);
    
    // Apply migrations
    let newConfig = oldConfig;
    const migrations = this.getMigrationPath(fromVersion, toVersion);
    
    for (const migration of migrations) {
      console.log(`  Applying migration: ${migration.name}`);
      newConfig = await migration.apply(newConfig);
    }
    
    // Validate new configuration
    const validation = await this.validator.validate(newConfig);
    if (!validation.valid) {
      console.error('❌ Migration failed validation:');
      validation.errors.forEach(e => 
        console.error(`  - ${e.field}: ${e.message}`)
      );
      return false;
    }
    
    // Backup old configuration
    await this.backupConfig(oldConfig, fromVersion);
    
    // Save new configuration
    await this.saveConfig(newConfig, toVersion);
    
    console.log('✅ Migration complete!');
    return true;
  }

  getMigrationPath(from: string, to: string): Migration[] {
    const migrations = [];
    
    if (from < '2.0.0' && to >= '2.0.0') {
      migrations.push(new V1ToV2Migration());
    }
    
    if (from < '3.0.0' && to >= '3.0.0') {
      migrations.push(new V2ToV3Migration());
    }
    
    return migrations;
  }
}

class V2ToV3Migration {
  name = 'v2.x to v3.0';
  
  async apply(config: any) {
    const newConfig: Config = {
      version: '3.0.0',
      project: {},
      paths: {},
      workflow: {},
      integrations: {}
    };
    
    // Migrate CLAUDE.md variables
    if (config.SPEC_AUTO_CHECKPOINT) {
      newConfig.state = {
        persistence: {
          session: {
            checkpoint: {
              enabled: config.SPEC_AUTO_CHECKPOINT === 'true'
            }
          }
        }
      };
    }
    
    // Migrate MCP configuration
    if (config.SPEC_ATLASSIAN_SYNC === 'enabled') {
      newConfig.integrations.mcp = {
        atlassian: {
          enabled: true,
          jira: {
            projectKey: config.SPEC_JIRA_PROJECT_KEY
          },
          confluence: {
            rootPageId: config.SPEC_CONFLUENCE_ROOT_PAGE_ID
          }
        }
      };
    }
    
    // Migrate paths from hardcoded to configurable
    newConfig.paths = {
      config: '.spec',
      state: '.spec-state',
      memory: '.spec-memory',
      features: 'features'
    };
    
    return newConfig;
  }
}
```

### Help Integration

```typescript
class ConfigHelp {
  async showHelp(topic?: string) {
    if (!topic) {
      this.showOverview();
      return;
    }
    
    const helpTopics = {
      'paths': this.showPathsHelp,
      'naming': this.showNamingHelp,
      'workflow': this.showWorkflowHelp,
      'integrations': this.showIntegrationsHelp,
      'variables': this.showVariablesHelp,
      'precedence': this.showPrecedenceHelp
    };
    
    const helpFunction = helpTopics[topic];
    if (helpFunction) {
      helpFunction.call(this);
    } else {
      console.log(`Unknown help topic: ${topic}`);
      console.log(`Available topics: ${Object.keys(helpTopics).join(', ')}`);
    }
  }

  showPathsHelp() {
    console.log(`
📁 PATH CONFIGURATION

Spec uses configurable paths for all artifacts:

{
  "paths": {
    "config": ".spec",           // Configuration directory
    "state": ".spec-state",      // Session state (gitignored)
    "memory": ".spec-memory",    // Persistent memory
    "features": "features",      // Feature artifacts
    "templates": "templates"     // Custom templates
  }
}

Variables supported:
- \${env:VARIABLE} - Environment variable
- \${paths.base} - Reference other paths
- Relative paths resolved from project root

Examples:
- Monorepo: "features": "packages/shared/features"
- Src-based: "features": "src/features"
- Custom: "features": "documentation/specs"
    `);
  }

  showWorkflowHelp() {
    console.log(`
⚡ WORKFLOW CONFIGURATION

Customize the spec workflow phases:

{
  "workflow": {
    "phases": {
      "initialize": { "enabled": true },
      "define": { "enabled": true },
      "design": { "enabled": true },
      "build": { "enabled": true },
      "track": { "enabled": true },
      "custom": {
        "qa": {
          "enabled": true,
          "skills": ["test-generate"],
          "afterPhase": "build"
        }
      }
    }
  }
}

Add custom phases for your team's workflow!
    `);
  }
}
```

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)

1. **Configuration Schema**
   - [ ] Define JSON Schema for configuration
   - [ ] Implement schema validation
   - [ ] Create default configuration

2. **Configuration Loader**
   - [ ] Implement hierarchical loading
   - [ ] Add variable interpolation
   - [ ] Support environment variables

3. **Migration Tools**
   - [ ] Create v2 to v3 migrator
   - [ ] Backup and restore utilities
   - [ ] Migration validation

### Phase 2: Core Features (Week 3-4)

1. **Auto-Detection**
   - [ ] Project type detector
   - [ ] Framework detector
   - [ ] Dependency analyzer
   - [ ] Defaults generator

2. **Management Commands**
   - [ ] `spec config` command suite
   - [ ] Interactive configurator
   - [ ] Validation command

3. **Path Configuration**
   - [ ] Replace hardcoded paths
   - [ ] Support path variables
   - [ ] Path resolution system

### Phase 3: Integration (Week 5-6)

1. **Skill Updates**
   - [ ] Update all skills to use configuration
   - [ ] Remove hardcoded values
   - [ ] Add configuration checks

2. **Template System**
   - [ ] Template variable system
   - [ ] Custom template loading
   - [ ] Template inheritance

3. **Integration Configuration**
   - [ ] MCP configuration system
   - [ ] Git integration config
   - [ ] CI/CD configuration

### Phase 4: Advanced Features (Week 7-8)

1. **Team Features**
   - [ ] Configuration inheritance
   - [ ] Team templates
   - [ ] Shared configurations

2. **Extensibility**
   - [ ] Custom workflow phases
   - [ ] Plugin configuration
   - [ ] Hook configuration

3. **Performance**
   - [ ] Configuration caching
   - [ ] Lazy loading
   - [ ] Hot reload support

### Phase 5: Polish (Week 9-10)

1. **Documentation**
   - [ ] Configuration guide
   - [ ] Migration guide
   - [ ] API documentation

2. **Testing**
   - [ ] Unit tests
   - [ ] Integration tests
   - [ ] Migration tests

3. **User Experience**
   - [ ] Error messages
   - [ ] Help system
   - [ ] Examples

## Migration Plan

### For Existing Users

1. **Automatic Detection**
   ```bash
   # Detect v2 configuration
   spec config detect
   > Found v2.x configuration in CLAUDE.md
   > Run 'spec config migrate' to upgrade
   ```

2. **Guided Migration**
   ```bash
   spec config migrate
   > Migrating from v2.1 to v3.0...
   > ✓ Backed up old configuration
   > ✓ Converted CLAUDE.md variables
   > ✓ Generated config.json
   > ✓ Validated new configuration
   > Migration complete!
   ```

3. **Gradual Adoption**
   - v3.0: Support both old and new format
   - v3.1: Deprecation warnings for old format
   - v4.0: Remove old format support

### For New Users

1. **Auto-Detection First**
   ```bash
   spec init
   > 🔍 Analyzing project...
   > ✓ Detected: Next.js application
   > ✓ Found: TypeScript, Jest, ESLint
   > ✓ Generated optimal configuration
   > Continue with these settings? (Y/n)
   ```

2. **Interactive Setup**
   ```bash
   spec init --interactive
   > Welcome to Spec Configuration!
   > Let's set up your project...
   ```

### Backward Compatibility

- Keep reading CLAUDE.md variables (deprecated)
- Support old directory structure
- Provide migration warnings
- Maintain command aliases

## Success Metrics

### Adoption Metrics
- Configuration file adoption rate
- Migration success rate
- Auto-detection accuracy
- User satisfaction scores

### Technical Metrics
- Configuration validation errors
- Migration failures
- Performance impact
- Token usage reduction

### User Experience Metrics
- Time to first successful configuration
- Configuration command usage
- Help documentation views
- Support ticket reduction

## Appendix A: Configuration Examples

### Monorepo Configuration

```json
{
  "project": {
    "type": "monorepo",
    "name": "my-monorepo"
  },
  "paths": {
    "config": ".spec",
    "features": "packages/shared/specs",
    "templates": "packages/shared/templates",
    "artifacts": {
      "specs": "packages/{package}/specs/{feature-id}/spec.md",
      "plans": "packages/{package}/specs/{feature-id}/plan.md"
    }
  },
  "naming": {
    "features": {
      "pattern": "{package}-{number:3}-{name}",
      "examples": ["api-001-auth", "web-002-dashboard"]
    }
  }
}
```

### Microservices Configuration

```json
{
  "project": {
    "type": "microservice",
    "name": "user-service"
  },
  "paths": {
    "features": "docs/specs",
    "state": "/tmp/spec-state",
    "memory": "docs/decisions"
  },
  "integrations": {
    "mcp": {
      "atlassian": {
        "enabled": true,
        "jira": {
          "projectKey": "USER",
          "createIssues": true
        }
      }
    }
  }
}
```

### Library Configuration

```json
{
  "project": {
    "type": "library",
    "name": "my-ui-library"
  },
  "workflow": {
    "phases": {
      "initialize": { "enabled": true },
      "define": { "enabled": true },
      "design": { "enabled": true },
      "build": { "enabled": true },
      "test": {
        "enabled": true,
        "skills": ["test-generate", "test-visual"],
        "afterPhase": "build"
      },
      "document": {
        "enabled": true,
        "skills": ["docs-generate", "storybook-update"],
        "afterPhase": "test"
      },
      "publish": {
        "enabled": true,
        "skills": ["version-bump", "npm-publish"],
        "afterPhase": "document"
      }
    }
  }
}
```

## Appendix B: Variable Reference

### Built-in Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `${env:NAME}` | Environment variable | `${env:HOME}` |
| `${paths.KEY}` | Path reference | `${paths.base}` |
| `${project.KEY}` | Project config | `${project.name}` |
| `${git:KEY}` | Git information | `${git:branch}` |
| `${date:FORMAT}` | Current date | `${date:YYYY-MM-DD}` |
| `${package:KEY}` | package.json field | `${package:version}` |
| `${workflow.KEY}` | Workflow state | `${workflow.currentFeature}` |

### Custom Variables

Define in configuration:

```json
{
  "variables": {
    "company": "ACME Corp",
    "team": "Platform Team",
    "region": "${env:AWS_REGION:-us-east-1}"
  },
  "templates": {
    "header": "© ${variables.company} - ${variables.team}"
  }
}
```

## Appendix C: JSON Schema

The complete JSON Schema for configuration validation will be published at:
`https://spec-flow.dev/schemas/config/v1.0.0.json`

Key features:
- Type validation for all fields
- Pattern matching for strings
- Enum validation for known values
- Dependency validation
- Custom validation rules
- Clear error messages

## Conclusion

The proposed configuration management system addresses all identified gaps while maintaining backward compatibility and providing a smooth migration path. The hierarchical configuration with auto-detection capabilities will significantly improve the user experience while the extensible schema enables teams to customize Spec for their specific needs.

Key benefits:
- **Flexibility**: Fully configurable paths, naming, and workflows
- **Extensibility**: Support for custom phases and integrations
- **Usability**: Auto-detection and interactive setup
- **Maintainability**: Schema validation and migration tools
- **Scalability**: Team configurations and inheritance

The implementation roadmap provides a clear path to delivery with minimal disruption to existing users while opening up powerful new capabilities for customization and extension.
