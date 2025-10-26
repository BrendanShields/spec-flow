---
name: flow:discover
description: Analyze JIRA backlog and codebase for brownfield onboarding. Use when 1) Starting work on existing project, 2) New team member needs project overview, 3) User says "analyze/understand project", 4) Need backlog/tech debt assessment, 5) Sprint planning assistance. Generates comprehensive discovery reports.
allowed-tools: Read, Bash, Write, WebSearch, Task
---

# Flow Discover

Comprehensive analysis of JIRA backlog, codebase, and work-in-progress for brownfield project intelligence.

## Core Workflow

### 1. JIRA Backlog Analysis

Connect to JIRA and extract:
- **Epics**: High-level features, progress, blocking issues
- **Stories**: By status (todo, in-progress, blocked, done)
- **Bugs**: By priority (P1, P2, P3)
- **Tech Debt**: Items labeled or matching patterns
- **Velocity**: Sprint history, average points, trends

### 2. Codebase Discovery

Analyze repository:
- **Technology Stack**: Languages, frameworks, databases
- **Architecture**: Pattern detection (microservices, monolith, etc.)
- **Structure**: Directory organization, module boundaries
- **Metrics**: Lines of code, test coverage, complexity

### 3. Git History Analysis

Extract patterns from commits:
- **Contributors**: Active/inactive developers, expertise areas
- **Activity**: Peak periods, current phase, commits/week
- **Hotspots**: Files with high change frequency + complexity
- **Ownership**: Code responsibility distribution

### 4. Work-in-Progress Assessment

Current development state:
- **Active PRs**: Open pull requests, review status
- **Active Branches**: Feature branches, age, staleness
- **Recent Commits**: Activity last 30 days
- **CI/CD Status**: Pipeline health, deployment frequency

### 5. Generate Reports

Create discovery documentation:

**discovery/project-overview.md**:
```markdown
# Project Discovery Report

## Executive Summary
- Project Age, Team Size, Tech Stack, Health Score

## Key Metrics
- Total Issues, Velocity, Tech Debt Ratio, Coverage

## Risk Areas
- Critical bugs, overdue epics, blocked items
```

**discovery/backlog-analysis.md**:
- Work distribution by type/priority
- Sprint readiness (ready vs needs refinement)
- Aging analysis (oldest unresolved items)

**discovery/technical-landscape.md**:
- Codebase structure and patterns
- Integration points (APIs, databases, services)
- Quality metrics and trends

**discovery/work-in-progress.md**:
- Active features being developed
- Open PRs and branches
- Team activity (last 30 days)

**discovery/onboarding-checklist.md**:
- Week 1: Critical understanding
- Week 2: First contributions
- Month 1: Independent work

## Command-Line Options

**`--focus [AREA]`**
Analyze specific area only:
- `backlog`: JIRA analysis only
- `sprint-planning`: Velocity and capacity
- `tech-debt`: Technical debt prioritization
- `architecture`: Codebase patterns only
- `team`: Contributor analysis

**`--mode [MODE]`**
- `full`: Complete analysis (default)
- `update`: Incremental since last run
- `quick`: Basic metrics only

**`--lookback [DAYS]`**
Historical period (default: 90 days)

**`--skip-codebase`**
JIRA only (skip code analysis)

**`--skip-jira`**
Codebase only (skip JIRA)

## Analysis Algorithms

### Velocity Calculation
```javascript
average = sum(completed_points) / num_sprints
stdDev = sqrt(variance)
trend = recent_avg vs older_avg
confidence = stdDev < average * 0.2 ? 'high' : 'medium'
```

### Hotspot Detection
```javascript
risk = (changeFrequency * 0.4) + (complexity * 0.6)
hotspots = files where risk >= 0.7
```

### Tech Debt Identification
- Code markers: TODO, FIXME, HACK
- High complexity: Cyclomatic > 15
- JIRA labels: tech-debt, refactor
- Title patterns: /refactor|optimize|clean up/i

## Integration with Flow

**Brownfield workflow**:
```bash
flow:discover                    # Analyze project
flow:init --type brownfield      # Initialize Flow
flow:blueprint --extract         # Extract architecture
flow:specify "First feature"     # Add features
```

**Continuous discovery**:
```bash
flow:discover --mode update      # Weekly updates
```

## Configuration

Set in CLAUDE.md:
```markdown
FLOW_DISCOVER_LOOKBACK_DAYS=90
FLOW_DISCOVER_INCLUDE_TESTS=true
FLOW_DISCOVER_ANALYZE_GIT=true
FLOW_DISCOVER_DETECT_HOTSPOTS=true
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- New team member onboarding
- Sprint planning assistance
- Technical debt prioritization
- Brownfield project takeover
- Weekly update mode
- Troubleshooting

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete option documentation
- Analysis algorithm details
- Output file formats
- Performance optimization
- Integration patterns
- Troubleshooting guide

## Related Skills

- **flow:init**: Initialize Flow after discover
- **flow:blueprint**: Extract architecture from discover data
- **flow:specify**: Create specs informed by findings

## Validation

Test this skill:
```bash
scripts/validate.sh
```
