# Spec Discover - Technical Reference

Complete technical documentation for codebase discovery and analysis.

## Analysis Algorithms

### Technology Stack Detection

```javascript
// Language detection by file extensions
const languageDetection = {
  '.js': 'JavaScript',
  '.ts': 'TypeScript',
  '.py': 'Python',
  '.java': 'Java',
  '.go': 'Go',
  '.rb': 'Ruby',
  '.php': 'PHP',
  '.rs': 'Rust',
  '.swift': 'Swift',
  '.kt': 'Kotlin'
};

// Framework detection by manifest files
const frameworkIndicators = {
  'package.json': detectNodeFramework,
  'requirements.txt': detectPythonFramework,
  'pom.xml': detectJavaFramework,
  'go.mod': detectGoFramework,
  'Gemfile': detectRubyFramework,
  'composer.json': detectPHPFramework
};

function detectNodeFramework(packageJson) {
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies };

  if (deps.react) return { name: 'React', version: deps.react };
  if (deps.vue) return { name: 'Vue.js', version: deps.vue };
  if (deps.angular) return { name: 'Angular', version: deps.angular };
  if (deps.express) return { name: 'Express', version: deps.express };
  if (deps.next) return { name: 'Next.js', version: deps.next };
  // ... more frameworks
}
```

### Architecture Pattern Detection

```javascript
// Pattern detection with confidence scoring
const architecturePatterns = {
  microservices: {
    indicators: [
      { path: 'services/', weight: 0.3 },
      { file: 'docker-compose.yml', weight: 0.2 },
      { path: 'k8s/', weight: 0.2 },
      { path: 'api-gateway/', weight: 0.15 },
      { pattern: /service-[a-z]+/, weight: 0.15 }
    ],
    threshold: 0.6
  },
  monolith: {
    indicators: [
      { file: 'src/main', weight: 0.4 },
      { singlePackageJson: true, weight: 0.3 },
      { noServiceDirs: true, weight: 0.3 }
    ],
    threshold: 0.7
  },
  monorepo: {
    indicators: [
      { path: 'packages/', weight: 0.4 },
      { file: 'lerna.json', weight: 0.3 },
      { file: 'nx.json', weight: 0.3 }
    ],
    threshold: 0.6
  },
  layered: {
    indicators: [
      { path: 'controllers/', weight: 0.25 },
      { path: 'services/', weight: 0.25 },
      { path: 'models/', weight: 0.25 },
      { path: 'views/', weight: 0.25 }
    ],
    threshold: 0.65
  }
};

function detectArchitecture(fileStructure) {
  const scores = {};

  for (const [pattern, config] of Object.entries(architecturePatterns)) {
    let score = 0;

    for (const indicator of config.indicators) {
      if (indicator.path && hasPath(fileStructure, indicator.path)) {
        score += indicator.weight;
      }
      if (indicator.file && hasFile(fileStructure, indicator.file)) {
        score += indicator.weight;
      }
      if (indicator.pattern && matchesPattern(fileStructure, indicator.pattern)) {
        score += indicator.weight;
      }
      // ... other indicator types
    }

    scores[pattern] = score;
  }

  // Find pattern with highest score above threshold
  const detected = Object.entries(scores)
    .filter(([_, score]) => score >= architecturePatterns[_].threshold)
    .sort((a, b) => b[1] - a[1])
    .map(([pattern, score]) => ({ pattern, confidence: score }));

  return detected[0] || { pattern: 'unknown', confidence: 0 };
}
```

### API Endpoint Discovery

```javascript
// REST endpoint extraction patterns
const endpointPatterns = {
  express: [
    /app\.(get|post|put|patch|delete)\(['"]([^'"]+)['"]/g,
    /router\.(get|post|put|patch|delete)\(['"]([^'"]+)['"]/g
  ],
  fastapi: [
    /@app\.(get|post|put|patch|delete)\(['"]([^'"]+)['"]/g,
    /@router\.(get|post|put|patch|delete)\(['"]([^'"]+)['"]/g
  ],
  spring: [
    /@(Get|Post|Put|Patch|Delete)Mapping\(['"]([^'"]+)['"]/g,
    /@RequestMapping\(.*path\s*=\s*['"]([^'"]+)['"]/g
  ],
  django: [
    /path\(['"]([^'"]+)['"],/g,
    /url\(r['"]\^?([^'"$]+)/g
  ]
};

async function discoverAPIEndpoints(projectPath, framework) {
  const patterns = endpointPatterns[framework] || [];
  const endpoints = [];

  // Find route files
  const routeFiles = await findFiles(projectPath, [
    '**/routes/**/*.{js,ts,py,java}',
    '**/controllers/**/*.{js,ts,py,java}',
    '**/api/**/*.{js,ts,py,java}'
  ]);

  for (const file of routeFiles) {
    const content = await readFile(file);

    for (const pattern of patterns) {
      let match;
      while ((match = pattern.exec(content)) !== null) {
        endpoints.push({
          method: match[1].toUpperCase(),
          path: match[2],
          file: file,
          line: getLineNumber(content, match.index)
        });
      }
    }
  }

  return deduplicateEndpoints(endpoints);
}

// GraphQL schema discovery
async function discoverGraphQLSchema(projectPath) {
  const schemaFiles = await findFiles(projectPath, [
    '**/*.graphql',
    '**/*.gql',
    '**/schema.{js,ts}'
  ]);

  const types = [];
  const queries = [];
  const mutations = [];

  for (const file of schemaFiles) {
    const content = await readFile(file);

    // Parse GraphQL schema
    const schema = parseGraphQLSchema(content);
    types.push(...schema.types);
    queries.push(...schema.queries);
    mutations.push(...schema.mutations);
  }

  return { types, queries, mutations };
}
```

### Code Quality Metrics

```javascript
// Complexity calculation (cyclomatic complexity approximation)
function calculateComplexity(sourceCode) {
  const keywords = [
    'if', 'else', 'for', 'while', 'do', 'switch', 'case',
    'catch', '&&', '||', '?', 'break', 'continue'
  ];

  let complexity = 1; // Base complexity

  for (const keyword of keywords) {
    const regex = new RegExp(`\\b${keyword}\\b`, 'g');
    const matches = sourceCode.match(regex);
    complexity += matches ? matches.length : 0;
  }

  return complexity;
}

// Technical debt detection
const debtIndicators = {
  comments: [
    /TODO/gi,
    /FIXME/gi,
    /HACK/gi,
    /XXX/gi,
    /BUG/gi,
    /@deprecated/gi
  ],
  antipatterns: [
    /eval\(/g,                    // eval usage
    /var\s+/g,                    // var instead of let/const
    /==(?!=)/g,                   // == instead of ===
    /process\.exit/g,             // Abrupt exit
    /console\.(log|debug|info)/g  // Debug logging in prod
  ],
  complexity: {
    highThreshold: 15,
    criticalThreshold: 25
  }
};

async function assessTechnicalDebt(projectPath) {
  const sourceFiles = await findSourceFiles(projectPath);
  const debt = {
    todoComments: [],
    highComplexity: [],
    antipatterns: [],
    duplicateCode: []
  };

  for (const file of sourceFiles) {
    const content = await readFile(file);
    const lines = content.split('\n');

    // Find TODO/FIXME comments
    lines.forEach((line, idx) => {
      for (const pattern of debtIndicators.comments) {
        if (pattern.test(line)) {
          debt.todoComments.push({
            file,
            line: idx + 1,
            text: line.trim(),
            type: pattern.source
          });
        }
      }
    });

    // Calculate complexity
    const functions = extractFunctions(content);
    for (const func of functions) {
      const complexity = calculateComplexity(func.body);
      if (complexity >= debtIndicators.complexity.highThreshold) {
        debt.highComplexity.push({
          file,
          function: func.name,
          complexity,
          severity: complexity >= debtIndicators.complexity.criticalThreshold
            ? 'critical'
            : 'high'
        });
      }
    }

    // Detect antipatterns
    for (const [name, pattern] of Object.entries(debtIndicators.antipatterns)) {
      const matches = content.match(pattern);
      if (matches) {
        debt.antipatterns.push({
          file,
          type: name,
          occurrences: matches.length
        });
      }
    }
  }

  return debt;
}

// Hotspot detection (high change frequency + high complexity)
async function detectHotspots(projectPath) {
  // Get git history for change frequency
  const gitLog = await execCommand('git log --numstat --format="%H" --since="6 months ago"');
  const changeFrequency = parseGitLog(gitLog);

  // Get complexity for each file
  const sourceFiles = await findSourceFiles(projectPath);
  const fileMetrics = [];

  for (const file of sourceFiles) {
    const content = await readFile(file);
    const complexity = calculateComplexity(content);
    const changes = changeFrequency[file] || 0;

    // Risk score: weighted combination
    const riskScore = (changes * 0.4) + (complexity * 0.6);

    if (riskScore >= 0.7) {
      fileMetrics.push({
        file,
        complexity,
        changes,
        riskScore,
        recommendation: riskScore >= 0.85 ? 'Refactor urgently' : 'Review and refactor'
      });
    }
  }

  return fileMetrics.sort((a, b) => b.riskScore - a.riskScore);
}
```

### JIRA Integration (via MCP)

```javascript
// JIRA backlog analysis
async function analyzeJIRABacklog(projectKey, options = {}) {
  const { lookbackDays = 90, sprintCount = 6 } = options;

  // Fetch epics
  const epics = await mcp.jira.searchIssues({
    jql: `project = ${projectKey} AND type = Epic ORDER BY created DESC`
  });

  // Fetch stories
  const stories = await mcp.jira.searchIssues({
    jql: `project = ${projectKey} AND type = Story ORDER BY priority DESC, created DESC`
  });

  // Fetch bugs
  const bugs = await mcp.jira.searchIssues({
    jql: `project = ${projectKey} AND type = Bug AND resolution = Unresolved ORDER BY priority DESC`
  });

  // Get sprint history
  const sprints = await mcp.jira.getBoard(projectKey).then(board =>
    mcp.jira.getSprintsForBoard(board.id, { limit: sprintCount })
  );

  // Calculate velocity
  const velocity = calculateVelocity(sprints);

  // Analyze work distribution
  const workDistribution = {
    byType: groupBy(stories, 'type'),
    byPriority: groupBy([...stories, ...bugs], 'priority'),
    byStatus: groupBy(stories, 'status'),
    aging: calculateAging(stories)
  };

  return {
    epics: analyzeEpics(epics),
    stories: analyzeStories(stories),
    bugs: analyzeBugs(bugs),
    velocity,
    workDistribution,
    recommendations: generateRecommendations(velocity, workDistribution)
  };
}

// Velocity calculation
function calculateVelocity(sprints) {
  const completedPoints = sprints.map(sprint => ({
    name: sprint.name,
    planned: sprint.plannedPoints || 0,
    completed: sprint.completedPoints || 0,
    sprintGoalMet: sprint.completedPoints >= sprint.plannedPoints * 0.9
  }));

  const average = completedPoints.reduce((sum, s) => sum + s.completed, 0) / sprints.length;
  const variance = completedPoints.reduce((sum, s) =>
    sum + Math.pow(s.completed - average, 2), 0
  ) / sprints.length;
  const stdDev = Math.sqrt(variance);

  // Trend analysis (recent vs older sprints)
  const recentAvg = completedPoints.slice(-3).reduce((sum, s) => sum + s.completed, 0) / 3;
  const olderAvg = completedPoints.slice(0, 3).reduce((sum, s) => sum + s.completed, 0) / 3;
  const trend = recentAvg > olderAvg ? 'increasing' : recentAvg < olderAvg ? 'decreasing' : 'stable';

  return {
    average: Math.round(average),
    stdDev: Math.round(stdDev),
    trend,
    confidence: stdDev < average * 0.2 ? 'high' : stdDev < average * 0.4 ? 'medium' : 'low',
    sprints: completedPoints
  };
}
```

## Report Formats

### Project Overview Report

```markdown
# Project Discovery Report

## Executive Summary
- **Project Name**: [Detected from package.json or repo name]
- **Project Age**: [From first git commit]
- **Primary Language**: [Most common language by LOC]
- **Architecture**: [Detected pattern] (Confidence: [0-1])
- **Health Score**: [0-100]

## Technology Stack
### Languages
- [Language 1]: [LOC count] ([percentage]%)
- [Language 2]: [LOC count] ([percentage]%)

### Frameworks & Libraries
- **Frontend**: [Framework] [version]
- **Backend**: [Framework] [version]
- **Database**: [Type] [version]
- **Testing**: [Framework] [version]

### Build & Deploy
- **Build Tool**: [Tool name]
- **CI/CD**: [Platform]
- **Container**: [Docker/K8s/None]

## Key Metrics
- **Total LOC**: [number] across [number] files
- **Directories**: [number]
- **Test Coverage**: [percentage]%
- **Dependencies**: [number] direct, [number] total
- **Complexity**: [Simple/Moderate/Complex]

## Health Assessment

### Code Quality: [Score]/100
- Test Coverage: [percentage]%
- Documentation: [Good/Fair/Poor]
- Code Smells: [count] detected
- Technical Debt: [Low/Medium/High]

### Maintenance Risk: [Low/Medium/High]
- Outdated Dependencies: [count]
- Security Vulnerabilities: [count]
- Code Hotspots: [count]
- Failing Tests: [count]

## Quick Start
[Generated onboarding steps based on project type]
```

### Technical Landscape Report

```markdown
# Technical Landscape

## Architecture Diagram
[ASCII or Mermaid diagram of detected architecture]

## Component Map
### Frontend
[Directory structure with descriptions]

### Backend
[Directory structure with descriptions]

### Database
[Schema overview]

### External Services
- [Service 1]: [Purpose]
- [Service 2]: [Purpose]

## API Catalog
### REST Endpoints ([count] total)
| Method | Path | Description | File |
|--------|------|-------------|------|
| GET | /api/users | List users | src/routes/users.js:12 |
| POST | /api/users | Create user | src/routes/users.js:45 |

### GraphQL Schema (if applicable)
[Types, Queries, Mutations]

## Data Models
[Entity relationship descriptions]

## Code Conventions
- **Naming**: [Convention]
- **Style**: [Formatter used]
- **Testing**: [Testing approach]
- **Git Workflow**: [Branch strategy]
```

### Backlog Analysis Report (JIRA)

```markdown
# JIRA Backlog Analysis

## Sprint Velocity (Last [N] Sprints)
[Table of sprint performance]

**Statistics**:
- Average: [number] points/sprint
- Trend: [Increasing/Decreasing/Stable]
- Confidence: [High/Medium/Low]

## Work Distribution
### By Type
- Stories: [count] ([percentage]%)
- Bugs: [count] ([percentage]%)
- Tasks: [count] ([percentage]%)

### By Priority
- P1 (Must Have): [count] stories
- P2 (Should Have): [count] stories
- P3 (Nice to Have): [count] stories

### By Status
- To Do: [count]
- In Progress: [count]
- Blocked: [count]
- Done: [count]

## Sprint Readiness
### Ready for Sprint ([count] stories, [points] points)
[List of ready stories]

### Needs Refinement ([count] stories)
[List with reasons]

### Blocked ([count] stories)
[List with blockers]

## Technical Debt
- Total Items: [count]
- Estimated Effort: [weeks]
- Priority Distribution: P1 ([count]), P2 ([count]), P3 ([count])

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]
```

## Configuration Reference

### claude.md Settings

```markdown
# Spec Discover Configuration

## Analysis Mode
SPEC_DISCOVER_MODE=standard           # quick|standard|deep

## Scope Control
SPEC_DISCOVER_INCLUDE_TESTS=true      # Include test directories
SPEC_DISCOVER_ANALYZE_GIT=true        # Analyze git history
SPEC_DISCOVER_DETECT_HOTSPOTS=true    # Calculate hotspot risk

## Path Exclusions
SPEC_DISCOVER_EXCLUDE_PATHS=node_modules,dist,build,.git,vendor

## Performance
SPEC_DISCOVER_MAX_FILE_SIZE=1048576   # Skip files >1MB
SPEC_DISCOVER_PARALLEL_WORKERS=4      # Parallel processing
SPEC_DISCOVER_TIMEOUT_SECONDS=600     # 10 minute timeout

## JIRA Integration
SPEC_ATLASSIAN_SYNC=enabled           # Enable JIRA analysis
SPEC_JIRA_PROJECT_KEY=PROJ            # Default project key
SPEC_DISCOVER_SPRINT_LOOKBACK=6       # Number of sprints

## Report Format
SPEC_DISCOVER_OUTPUT_FORMAT=markdown  # markdown|json|both
SPEC_DISCOVER_REPORT_DIR=discovery    # Output directory
```

## Performance Optimization

### Large Codebase Strategies

**Progressive Scanning**:
```javascript
// Scan in phases for large repos
async function progressiveScan(rootPath) {
  // Phase 1: Quick structure scan (1-2 min)
  const structure = await scanFileStructure(rootPath, { maxDepth: 3 });

  // Phase 2: Manifest analysis (2-3 min)
  const manifests = await analyzeManifests(structure);

  // Phase 3: Sample detailed analysis (5-10 min)
  const samples = selectRepresentativeSamples(structure, 100);
  const detailed = await analyzeInDetail(samples);

  // Phase 4: Focused deep dive (10-20 min)
  const hotspots = identifyAreasOfInterest(detailed);
  const deepAnalysis = await analyzeInDepth(hotspots);

  return combineResults(structure, manifests, detailed, deepAnalysis);
}
```

**Sampling Strategy**:
```javascript
// For repos >100k LOC, sample intelligently
function selectRepresentativeSamples(files, maxSamples) {
  // Always include: entry points, config files, main routes
  const critical = files.filter(f =>
    f.path.includes('main') ||
    f.path.includes('index') ||
    f.path.includes('config') ||
    f.path.includes('routes')
  );

  // Sample by directory
  const byDir = groupBy(files, f => path.dirname(f.path));
  const samples = critical;

  for (const [dir, dirFiles] of Object.entries(byDir)) {
    const sampleSize = Math.ceil(dirFiles.length * 0.1); // 10% sample
    samples.push(...dirFiles.slice(0, sampleSize));
  }

  return samples.slice(0, maxSamples);
}
```

### Caching Strategy

```javascript
// Cache results for incremental updates
const CACHE_DIR = '.spec-cache/discover';

async function discoverWithCache(projectPath, mode) {
  const cacheKey = generateCacheKey(projectPath, mode);
  const cached = await loadCache(cacheKey);

  if (cached && !isStale(cached, maxAgeHours = 24)) {
    // Incremental update: analyze only changed files
    const changedFiles = await getChangedFilesSince(cached.timestamp);

    if (changedFiles.length < 50) {
      const updates = await analyzeFiles(changedFiles);
      return mergeCacheWithUpdates(cached, updates);
    }
  }

  // Full analysis needed
  const results = await performFullDiscovery(projectPath, mode);
  await saveCache(cacheKey, results);
  return results;
}
```

## Error Recovery

### Handling Missing Permissions

```javascript
async function safeReadFile(filePath) {
  try {
    return await fs.readFile(filePath, 'utf-8');
  } catch (error) {
    if (error.code === 'EACCES') {
      console.warn(`Permission denied: ${filePath}`);
      return null;
    }
    throw error;
  }
}
```

### Partial Results on Failure

```javascript
async function discoverWithRecovery(projectPath) {
  const results = {
    techStack: null,
    architecture: null,
    apis: null,
    quality: null,
    errors: []
  };

  // Each phase is independent
  try {
    results.techStack = await discoverTechStack(projectPath);
  } catch (error) {
    results.errors.push({ phase: 'techStack', error: error.message });
  }

  try {
    results.architecture = await discoverArchitecture(projectPath);
  } catch (error) {
    results.errors.push({ phase: 'architecture', error: error.message });
  }

  // ... continue with other phases

  // Generate report with available data
  return generatePartialReport(results);
}
```

## Integration Patterns

### Workflow Integration

**Before generate phase** (recommended):
```bash
# Discover existing patterns
discover phase

# Initialize with brownfield mode
initialize phase --type brownfield

# Create blueprint from discovery
blueprint phase --from-discovery

# Now generate specs informed by discovery
generate phase "New Feature"
```

**Continuous Discovery** (weekly):
```bash
# Quick incremental update
discover phase --mode quick

# Review changes in discovery/updates/
cat discovery/updates/$(date +%Y-%m-%d).md
```

### State File Updates

Discovery updates `{config.paths.memory}/workflow-progress.md`:

```markdown
## Discovery History

### 2024-10-31: Initial Discovery
- **Mode**: Standard
- **Duration**: 18 minutes
- **Health Score**: 73/100
- **Key Findings**: Microservices architecture, 6 services, 81% test coverage
- **Report**: `discovery/2024-10-31/`

### 2024-11-07: Weekly Update
- **Mode**: Quick
- **Duration**: 5 minutes
- **Changes**: 2 new dependencies, coverage increased to 83%
- **Report**: `discovery/updates/2024-11-07.md`
```

---

## Advanced Usage

### Custom Analysis Scripts

Create `{config.paths.spec_root}/scripts/custom-discovery.sh`:

```bash
#!/bin/bash
# Custom discovery for specific patterns

echo "## Custom Metrics" >> discovery/custom-metrics.md

# Find all database queries
echo "### Database Queries" >> discovery/custom-metrics.md
grep -r "SELECT\|INSERT\|UPDATE\|DELETE" src/ >> discovery/custom-metrics.md

# API endpoint count by service
echo "### Endpoints by Service" >> discovery/custom-metrics.md
for dir in services/*/; do
  service=$(basename "$dir")
  count=$(grep -r "@app\.(get|post)" "$dir" | wc -l)
  echo "- $service: $count endpoints" >> discovery/custom-metrics.md
done
```

### Extending Detection Patterns

Add custom patterns to `{config.paths.spec_root}/config/discovery-patterns.json`:

```json
{
  "customFrameworks": {
    "astro": {
      "indicators": ["astro.config.mjs"],
      "packageName": "astro"
    }
  },
  "customArchitectures": {
    "jamstack": {
      "indicators": [
        { "path": "src/pages/", "weight": 0.4 },
        { "file": "netlify.toml", "weight": 0.3 },
        { "staticSite": true, "weight": 0.3 }
      ],
      "threshold": 0.7
    }
  }
}
```

---

For usage examples, see [EXAMPLES.md](./EXAMPLES.md).
