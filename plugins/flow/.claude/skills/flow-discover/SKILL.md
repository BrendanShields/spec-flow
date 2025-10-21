---
name: flow:discover
description: Analyze JIRA backlog and existing codebase for brownfield onboarding. Use when: 1) Starting work on existing project with JIRA, 2) Need to understand work in progress, 3) Onboarding to established team, 4) Discovering technical debt and patterns. Creates comprehensive project overview and backlog analysis.
allowed-tools: Read, Bash, Write, WebSearch, Task
---

# Flow Discover: Brownfield Project Intelligence

Comprehensive analysis of JIRA backlog, existing codebase, and work in progress for seamless brownfield onboarding.

## When to Use

- **New team member onboarding**: Understand project state and ongoing work
- **Brownfield project takeover**: Analyze existing backlog and codebase
- **Technical debt assessment**: Identify accumulated debt and prioritize
- **Sprint planning**: Understand velocity and capacity from historical data
- **Architecture documentation**: Generate current state documentation

## What This Skill Does

### Phase 1: JIRA Backlog Analysis

1. **Connect to JIRA**
   - Authenticate with Atlassian MCP
   - Fetch project metadata
   - Identify project boards and workflows

2. **Analyze Backlog**
   ```javascript
   // Fetch and categorize all issues
   const backlog = {
     epics: [],           // High-level features
     inProgress: [],      // Currently being worked on
     todo: [],           // Ready for development
     blocked: [],        // Blocked issues
     bugs: [],           // Open bugs
     techDebt: []        // Technical debt items
   };
   ```

3. **Extract Patterns**
   - Story point distribution
   - Velocity trends
   - Common labels/components
   - Team capacity patterns

### Phase 2: Codebase Discovery

4. **Repository Analysis**
   - Git history analysis
   - Contributor patterns
   - Hotspot detection (frequently changed files)
   - Branch strategies

5. **Architecture Extraction**
   - Technology stack detection
   - Architecture patterns
   - Service boundaries
   - Database schemas

6. **Quality Metrics**
   - Test coverage
   - Code complexity
   - Technical debt markers
   - Documentation coverage

### Phase 3: Work-in-Progress Assessment

7. **Active Development**
   - Open pull requests
   - Active branches
   - Recent commits
   - CI/CD pipeline status

8. **Team Dynamics**
   - Active contributors
   - Code ownership patterns
   - Review patterns
   - Communication channels

### Phase 4: Intelligence Report

9. **Generate Comprehensive Report**
   - Executive summary
   - Technical overview
   - Backlog analysis
   - Risk assessment
   - Recommendations

## Output Structure

### 1. Project Overview (`discovery/project-overview.md`)
```markdown
# Project Discovery Report

## Executive Summary
- Project: [Name]
- Age: [Duration]
- Team Size: [Number]
- Tech Stack: [Technologies]
- Overall Health: [Score]

## Key Metrics
- Total Issues: [Number]
- In Progress: [Number]
- Velocity: [Points/Sprint]
- Tech Debt Ratio: [Percentage]
```

### 2. Backlog Analysis (`discovery/backlog-analysis.md`)
```markdown
# JIRA Backlog Analysis

## Work Distribution
- Epics: [Count] ([Points])
- User Stories: [Count] ([Points])
- Bugs: [Count] (P1: [X], P2: [Y])
- Tech Debt: [Count] ([Estimated Days])

## Sprint Readiness
- Ready for Development: [Count]
- Needs Refinement: [Count]
- Blocked: [Count]

## Risk Areas
- Oldest Unresolved: [Issue]
- Largest Epic: [Epic]
- Critical Bugs: [List]
```

### 3. Technical Landscape (`discovery/technical-landscape.md`)
```markdown
# Technical Architecture

## Codebase Structure
- Primary Language: [Language] ([%])
- Total Files: [Count]
- Lines of Code: [Count]
- Test Coverage: [%]

## Architecture Patterns
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

## Integration Points
- External APIs: [List]
- Databases: [List]
- Services: [List]
```

### 4. Work in Progress (`discovery/work-in-progress.md`)
```markdown
# Current Development Activity

## Active Work
- Features in Development: [List]
- Open PRs: [Count]
- Active Branches: [Count]

## Team Activity (Last 30 Days)
- Commits: [Count]
- PRs Merged: [Count]
- Issues Closed: [Count]
```

### 5. Onboarding Checklist (`discovery/onboarding-checklist.md`)
```markdown
# Onboarding Checklist

## Immediate Actions
- [ ] Review critical bugs: [JIRA Filter]
- [ ] Understand in-progress epics: [Links]
- [ ] Review architecture docs: [Location]
- [ ] Set up development environment

## First Week
- [ ] Complete starter task: [JIRA-XXX]
- [ ] Review recent PRs
- [ ] Attend team ceremonies
- [ ] Document learnings

## First Month
- [ ] Contribute to epic: [Suggestion]
- [ ] Address tech debt item: [Suggestion]
- [ ] Improve documentation: [Area]
```

## Integration with Flow Workflow

### Brownfield Project Flow
```bash
# 1. Discover existing project state
flow:discover

# 2. Initialize Flow for brownfield
flow:init --type brownfield

# 3. Import high-priority items from backlog
flow:import --from-jira --filter "priority=High AND sprint=current"

# 4. Generate specs for imported items
flow:specify --batch

# 5. Begin implementation
flow:implement
```

### Continuous Discovery
```bash
# Weekly discovery updates
flow:discover --mode update

# Sprint planning assistance
flow:discover --focus sprint-planning

# Technical debt prioritization
flow:discover --focus tech-debt
```

## Configuration Options

```javascript
{
  "discovery": {
    "jira": {
      "lookbackDays": 90,        // Historical data period
      "includeSubtasks": true,   // Include subtasks in analysis
      "analyzeVelocity": true,   // Calculate team velocity
      "detectPatterns": true     // Pattern recognition
    },
    "codebase": {
      "analyzeGitHistory": true, // Git analysis
      "detectHotspots": true,    // Frequently changed files
      "assessQuality": true,     // Code quality metrics
      "findTechDebt": true       // Technical debt markers
    },
    "report": {
      "format": "markdown",       // Output format
      "includeVisuals": true,    // Generate charts
      "actionable": true         // Include recommendations
    }
  }
}
```

## MCP Integration

If Atlassian MCP is configured:
```javascript
// Automatic JIRA connection
const jiraClient = await mcp.connect('atlassian');

// Fetch backlog
const backlog = await jiraClient.searchIssues({
  jql: `project = ${FLOW_JIRA_PROJECT_KEY} AND status != Done`,
  maxResults: 1000,
  fields: ['summary', 'status', 'priority', 'storyPoints', 'labels']
});

// Analyze patterns
const insights = analyzeBacklog(backlog);
```

## Intelligence Patterns

### Pattern 1: Velocity Analysis
```javascript
function analyzeVelocity(sprints) {
  return {
    average: calculateAverage(sprints.map(s => s.completed)),
    trend: calculateTrend(sprints),
    capacity: estimateCapacity(sprints),
    predictability: calculatePredictability(sprints)
  };
}
```

### Pattern 2: Tech Debt Detection
```javascript
function detectTechDebt(codebase, issues) {
  const markers = [
    'TODO', 'FIXME', 'HACK', 'REFACTOR',
    'technical debt', 'legacy', 'deprecated'
  ];

  return {
    codeMarkers: findInCode(codebase, markers),
    jiraItems: filterTechDebt(issues),
    hotspots: identifyHighChangeAreas(codebase),
    complexity: calculateComplexity(codebase)
  };
}
```

### Pattern 3: Team Dynamics
```javascript
function analyzeTeamDynamics(commits, reviews) {
  return {
    contributors: identifyActiveContributors(commits),
    expertise: mapExpertiseAreas(commits),
    collaboration: analyzeReviewPatterns(reviews),
    bottlenecks: identifyBottlenecks(reviews)
  };
}
```

## Success Metrics

Track discovery effectiveness:
- **Time to Productivity**: How quickly new team members contribute
- **Backlog Clarity**: Percentage of well-defined stories
- **Tech Debt Ratio**: Tech debt vs feature work
- **Knowledge Transfer**: Documentation completeness