# Flow Discover Reference

## Command-Line Options

### `--focus [AREA]`

Focus analysis on specific area.

**Options**:
- `backlog`: JIRA backlog analysis only
- `sprint-planning`: Velocity and capacity analysis
- `tech-debt`: Technical debt prioritization
- `architecture`: Codebase architecture only
- `team`: Team dynamics and contributions

**Usage**:
```bash
flow:discover --focus sprint-planning
flow:discover --focus tech-debt
```

---

### `--mode [MODE]`

Set discovery mode.

**Options**:
- `full`: Complete analysis (default)
- `update`: Incremental since last run
- `quick`: Basic metrics only

**Usage**:
```bash
flow:discover --mode update
flow:discover --mode quick
```

---

### `--lookback [DAYS]`

Set historical analysis period.

**Default**: 90 days

**Usage**:
```bash
flow:discover --lookback 30   # Last 30 days
flow:discover --lookback 180  # Last 6 months
```

---

### `--skip-codebase`

Skip codebase analysis (JIRA only).

**Use when**: Only need backlog analysis, codebase too large.

---

### `--skip-jira`

Skip JIRA analysis (codebase only).

**Use when**: No JIRA access, git-only discovery.

---

## Output Files

### Generated Reports

**Location**: `discovery/` directory

**Files**:
1. **project-overview.md**: Executive summary, key metrics
2. **backlog-analysis.md**: Work distribution, sprint readiness
3. **technical-landscape.md**: Architecture, tech stack, codebase structure
4. **work-in-progress.md**: Active development, PRs, branches
5. **onboarding-checklist.md**: Actionable onboarding tasks

---

## Analysis Components

### JIRA Backlog Analysis

**Extracted Data**:
```javascript
{
  epics: [
    {
      key: 'MYAPP-100',
      summary: 'Payment Processing',
      status: 'In Progress',
      progress: 65,
      stories: 12,
      points: 89,
      blocked: 2
    }
  ],
  stories: {
    todo: [],
    inProgress: [],
    blocked: [],
    done: []
  },
  bugs: {
    p1: [],
    p2: [],
    p3: []
  },
  techDebt: [],
  velocity: {
    sprints: [],
    average: 46,
    trend: 'stable'
  }
}
```

---

### Codebase Analysis

**Technology Detection**:
```javascript
// Detect from package.json, Gemfile, requirements.txt, etc.
{
  languages: {
    'JavaScript': 45.2,
    'TypeScript': 38.7,
    'CSS': 10.1,
    'HTML': 6.0
  },
  frameworks: [
    'React 18.2',
    'Express 4.18',
    'TypeScript 5.0'
  ],
  databases: [
    'PostgreSQL',
    'Redis'
  ]
}
```

**Architecture Pattern Detection**:
```javascript
{
  pattern: 'microservices',
  confidence: 0.85,
  indicators: [
    'services/ directory with 5 services',
    'docker-compose.yml with 5 services',
    'kubernetes/ directory',
    'Independent package.json per service'
  ]
}
```

---

### Git History Analysis

**Contributor Analysis**:
```javascript
{
  contributors: [
    {
      email: 'alice@company.com',
      commits: 423,
      percentage: 50,
      lastActive: '2024-04-15',
      expertise: ['payment', 'auth', 'api']
    }
  ],
  activityPattern: {
    peakPeriod: '2024-01-01 to 2024-06-30',
    currentPhase: 'maintenance',
    commitsPerWeek: 12
  }
}
```

**Hotspot Detection**:
```javascript
// Files with high change frequency AND high complexity
{
  hotspots: [
    {
      file: 'src/payment/processor.js',
      changes: 23,
      complexity: 18,
      risk: 'high',
      recommendation: 'Refactor to reduce complexity'
    }
  ]
}
```

---

## Integration with Flow Workflow

### After Discovery

**Brownfield flow**:
```bash
# 1. Discover project
flow:discover

# 2. Initialize Flow
flow:init --type brownfield

# 3. Extract architecture blueprint
flow:blueprint --extract

# 4. Start adding features
flow:specify "First new feature"
```

**Continuous discovery**:
```bash
# Weekly
flow:discover --mode update

# Review changes
cat discovery/project-overview.md

# Act on findings
flow:specify "Fix critical bugs"
```

---

## Configuration

**Default settings** (can override in CLAUDE.md):

```markdown
## Flow Discover Configuration
FLOW_DISCOVER_LOOKBACK_DAYS=90
FLOW_DISCOVER_INCLUDE_TESTS=true
FLOW_DISCOVER_ANALYZE_GIT=true
FLOW_DISCOVER_DETECT_HOTSPOTS=true
FLOW_DISCOVER_AUTO_ONBOARDING=true
```

---

## Velocity Calculation

### Formula

```javascript
function calculateVelocity(sprints) {
  // Get completed points per sprint
  const completedPoints = sprints.map(s => s.completed);

  // Calculate average
  const average = completedPoints.reduce((a, b) => a + b) / sprints.length;

  // Calculate standard deviation
  const variance = completedPoints
    .map(x => Math.pow(x - average, 2))
    .reduce((a, b) => a + b) / sprints.length;
  const stdDev = Math.sqrt(variance);

  // Detect trend
  const recent = completedPoints.slice(-3);
  const older = completedPoints.slice(0, -3);
  const recentAvg = recent.reduce((a, b) => a + b) / recent.length;
  const olderAvg = older.reduce((a, b) => a + b) / older.length;

  const trend = recentAvg > olderAvg * 1.1 ? 'increasing' :
                recentAvg < olderAvg * 0.9 ? 'decreasing' : 'stable';

  return {
    average: Math.round(average),
    stdDev: Math.round(stdDev),
    range: [average - stdDev, average + stdDev],
    trend,
    confidence: stdDev < average * 0.2 ? 'high' : 'medium'
  };
}
```

---

## Tech Debt Detection

### Code Markers

**Scanned patterns**:
```javascript
const techDebtMarkers = [
  /TODO:/gi,
  /FIXME:/gi,
  /HACK:/gi,
  /XXX:/gi,
  /REFACTOR:/gi,
  /DEPRECATED:/gi,
  /technical debt/gi,
  /legacy/gi
];
```

**Complexity Thresholds**:
- **Low**: Cyclomatic complexity ≤ 10
- **Medium**: 11-15
- **High**: 16-20
- **Critical**: > 20

---

### JIRA Tech Debt Identification

**Heuristics**:
```javascript
function isTechDebt(issue) {
  // Label-based
  if (issue.labels.some(l =>
    ['tech-debt', 'refactor', 'technical-debt'].includes(l)
  )) return true;

  // Issue type
  if (issue.type === 'Technical Debt') return true;

  // Title patterns
  const titlePatterns = [
    /refactor/i,
    /tech debt/i,
    /clean up/i,
    /improve performance/i,
    /optimize/i
  ];

  return titlePatterns.some(p => p.test(issue.summary));
}
```

---

## Hotspot Detection

### Algorithm

```javascript
function detectHotspots(gitHistory, codeMetrics) {
  const files = {};

  // Count changes per file
  gitHistory.commits.forEach(commit => {
    commit.files.forEach(file => {
      files[file] = (files[file] || 0) + 1;
    });
  });

  // Combine with complexity
  const hotspots = Object.entries(files)
    .map(([file, changes]) => ({
      file,
      changes,
      complexity: codeMetrics[file]?.complexity || 0,
      risk: calculateRisk(changes, complexity)
    }))
    .filter(h => h.risk >= 0.7)  // High risk threshold
    .sort((a, b) => b.risk - a.risk);

  return hotspots;
}

function calculateRisk(changes, complexity) {
  // Normalize to 0-1 scale
  const changeScore = Math.min(changes / 50, 1);
  const complexityScore = Math.min(complexity / 20, 1);

  // Weighted average (complexity weighted higher)
  return (changeScore * 0.4) + (complexityScore * 0.6);
}
```

---

## Performance Optimization

### Large Codebases

**Strategies**:
1. **Sampling**: Analyze 10% of files, extrapolate
2. **Incremental**: Cache results, update incrementally
3. **Parallel**: Analyze multiple directories concurrently
4. **Filtering**: Skip test files, generated code

**Configuration**:
```markdown
FLOW_DISCOVER_MAX_FILES=10000
FLOW_DISCOVER_SAMPLE_RATE=0.1
FLOW_DISCOVER_PARALLEL_WORKERS=4
FLOW_DISCOVER_SKIP_PATTERNS=*.test.js,*.spec.ts,dist/,build/
```

---

## Related Skills

- **flow:init**: Initialize Flow (run after discover for brownfield)
- **flow:blueprint**: Extract architecture (uses discover data)
- **flow:specify**: Create specs (informed by discover findings)

---

## Troubleshooting

### Analysis Incomplete

**Cause**: Timeout, large codebase
**Solution**: Use `--focus` to limit scope, increase timeout

---

### Inaccurate Metrics

**Cause**: Incomplete git history, wrong branch
**Solution**: Fetch all history, specify branch

---

### JIRA Rate Limiting

**Cause**: Too many API calls
**Solution**: Reduce lookback period, use caching

---

## Version History

- **v1.0**: Initial JIRA + git analysis
- **v1.1**: Added hotspot detection
- **v1.2**: Velocity calculation improvements
- **v1.3**: Tech debt prioritization
