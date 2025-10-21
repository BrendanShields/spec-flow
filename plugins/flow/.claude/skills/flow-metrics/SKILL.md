---
name: flow:metrics
description: View and analyze code generation metrics. Use when: 1) Want to see AI vs human code ratio, 2) Track productivity metrics, 3) Analyze code generation patterns, 4) Generate reports on AI assistance effectiveness. Shows comprehensive metrics dashboard.
allowed-tools: Read, Write, Bash
---

# Flow Metrics: Code Generation Analytics

View comprehensive metrics about AI-generated vs human-modified code, productivity patterns, and generation velocity.

## What This Skill Does

1. **Loads** metrics from `.flow/.metrics.json`
2. **Analyzes** code generation patterns
3. **Generates** visual dashboard
4. **Tracks** productivity trends
5. **Reports** AI assistance effectiveness

## Metrics Tracked

### Code Distribution
- AI-generated lines vs human-written lines
- Files created by AI vs humans
- Modification patterns (AI edits vs human edits)

### Productivity Metrics
- Generation velocity (lines per hour)
- Peak activity hours
- Most used Flow skills
- File type distribution

### Quality Indicators
- AI assistance ratio
- Skill effectiveness
- Time saved estimates

## Usage Modes

### 1. View Current Metrics
```bash
flow:metrics
```

Shows current metrics dashboard with:
- AI vs Human code percentage
- Total lines and files
- Recent activity
- Top skills used

### 2. Historical Analysis
```bash
flow:metrics --history 7d
```

Shows trends over time:
- Daily generation rates
- AI assistance trends
- Productivity patterns

### 3. Detailed Report
```bash
flow:metrics --report
```

Generates comprehensive report:
- Full statistics
- File-by-file breakdown
- Skill usage analysis
- Recommendations

### 4. Export Metrics
```bash
flow:metrics --export csv
```

Exports metrics for external analysis:
- CSV format for spreadsheets
- JSON for programmatic access
- Markdown for documentation

## Dashboard Output

```
📊 Code Generation Metrics
==========================

Code Distribution:
AI Generated:    ████████████████░░░░ 78%
Human Written:   ████░░░░░░░░░░░░░░░░ 22%

Statistics:
- Total Lines: 12,345
- Total Files: 67
- AI Generated: 9,629 lines (45 files)
- Human Written: 2,716 lines (22 files)

Generation Velocity: 234 lines/hour

Top Skills:
1. flow:implement - 23 operations
2. flow:specify - 12 operations
3. flow:plan - 8 operations

Activity Pattern:
Most productive hour: 10:00 AM

File Types:
- .js: 34 files
- .tsx: 18 files
- .md: 15 files

AI Effectiveness:
- Time Saved: ~48 hours
- Error Rate: 2%
- Rework Required: 5%
```

## Integration with Workflow

### Automatic Tracking
The `track-metrics.js` hook automatically:
- Tracks every file operation
- Identifies AI vs human origin
- Maintains running statistics
- Generates hourly snapshots

### Manual Metrics Check
```bash
# Check metrics after implementation
flow:implement
flow:metrics

# View weekly progress
flow:metrics --history 7d

# Generate report for stakeholders
flow:metrics --report --format pdf
```

## Metrics Storage

### File Structure
```
.flow/
├── .metrics.json                 # Current metrics
├── metrics-dashboard.md         # Visual dashboard
└── metrics-history/             # Historical snapshots
    ├── metrics-2024-10-21T10.json
    ├── metrics-2024-10-21T11.json
    └── ...
```

### Data Format
```json
{
  "totals": {
    "aiGeneratedLines": 9629,
    "humanWrittenLines": 2716,
    "aiGeneratedFiles": 45,
    "humanCreatedFiles": 22
  },
  "files": {
    "src/app.js": {
      "aiLines": 234,
      "humanLines": 45,
      "modifications": [...]
    }
  },
  "statistics": {
    "aiPercentage": 78,
    "humanPercentage": 22,
    "generationVelocity": 234
  }
}
```

## Use Cases

### 1. Team Productivity Tracking
```bash
flow:metrics --team --period month
```

Track team's AI adoption and productivity gains.

### 2. ROI Analysis
```bash
flow:metrics --roi
```

Calculate return on investment from AI assistance.

### 3. Code Review Insights
```bash
flow:metrics --by-file
```

See which files are AI-heavy for focused review.

### 4. Skill Optimization
```bash
flow:metrics --skill-analysis
```

Identify which skills provide most value.

## Configuration

```javascript
{
  "metrics": {
    "tracking": {
      "enabled": true,
      "granularity": "file",  // file|function|line
      "includeTests": true,
      "trackDependencies": false
    },
    "reporting": {
      "autoGenerate": "daily",  // hourly|daily|weekly
      "format": "markdown",
      "includeCharts": true
    },
    "privacy": {
      "anonymize": false,
      "shareMetrics": false
    }
  }
}
```

## Privacy & Security

- All metrics stored locally in `.flow/` directory
- No external transmission unless explicitly configured
- File contents not stored, only statistics
- Can be disabled via configuration

## Tips

### Improve AI Effectiveness
1. Use clear specifications for better AI generation
2. Review AI-generated code regularly
3. Provide feedback through edits

### Track Progress
1. Run metrics weekly to track trends
2. Compare before/after Flow adoption
3. Share reports with stakeholders

### Optimize Workflow
1. Identify most effective skills
2. Focus on high-velocity periods
3. Balance AI assistance with human review