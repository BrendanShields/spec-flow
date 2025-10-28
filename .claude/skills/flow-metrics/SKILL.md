---
name: flow:metrics
description: View and analyze code generation metrics. Use when 1) Want AI vs human code ratio, 2) User says "show/view metrics", 3) Track productivity metrics, 4) Analyze code generation patterns, 5) Generate AI effectiveness reports. Shows comprehensive metrics dashboard.
allowed-tools: Read, Write, Bash
---

# Flow Metrics

View comprehensive metrics about AI-generated vs human-modified code, productivity patterns, and generation velocity.

## Core Workflow

### 1. Load Metrics

Read from `.flow/.metrics.json`:
```javascript
{
  "totals": {
    "aiGeneratedLines": 9629,
    "humanWrittenLines": 2716,
    "aiGeneratedFiles": 45,
    "humanCreatedFiles": 22
  },
  "statistics": {
    "aiPercentage": 78,
    "generationVelocity": 234  // lines per hour
  }
}
```

### 2. Analyze Patterns

Calculate:
- AI vs Human code distribution
- Generation velocity (lines/hour)
- Most used Flow skills
- File type distribution
- Peak activity hours

### 3. Generate Dashboard

Visual output:
```
📊 Code Generation Metrics
==========================

Code Distribution:
AI Generated:    ████████████████░░░░ 78%
Human Written:   ████░░░░░░░░░░░░░░░░ 22%

Statistics:
- Total Lines: 12,345
- AI Generated: 9,629 lines (45 files)
- Human Written: 2,716 lines (22 files)

Generation Velocity: 234 lines/hour

Top Skills:
1. flow:implement - 23 operations
2. flow:specify - 12 operations
3. flow:plan - 8 operations

File Types:
- .js: 34 files
- .tsx: 18 files
- .md: 15 files

AI Effectiveness:
- Time Saved: ~48 hours
- Error Rate: 2%
```

## Usage Modes

### 1. Current Metrics (Default)

```bash
flow:metrics
```

Shows current dashboard with AI/Human ratios, activity, top skills.

### 2. Historical Analysis

```bash
flow:metrics --history 7d
```

Trends over time:
- Daily generation rates
- AI assistance trends
- Productivity patterns

### 3. Detailed Report

```bash
flow:metrics --report
```

Comprehensive report:
- Full statistics
- File-by-file breakdown
- Skill usage analysis
- Recommendations

### 4. Export

```bash
flow:metrics --export csv
flow:metrics --export json
flow:metrics --export markdown
```

Export for external analysis.

## Metrics Tracked

**Code Distribution**:
- AI-generated vs human-written lines
- Files created by AI vs humans
- Modification patterns

**Productivity**:
- Generation velocity (lines/hour)
- Peak activity hours
- Most used Flow skills
- File type distribution

**Quality**:
- AI assistance ratio
- Skill effectiveness
- Estimated time saved

## Automatic Tracking

The `track-metrics.js` hook automatically:
- Tracks every file operation
- Identifies AI vs human origin
- Maintains running statistics
- Generates hourly snapshots

Stored in:
```
.flow/
├── .metrics.json           # Current metrics
└── metrics-history/        # Historical snapshots
    ├── metrics-2024-10-21T10.json
    └── metrics-2024-10-21T11.json
```

## Configuration

Set in CLAUDE.md:
```markdown
FLOW_METRICS_TRACKING=enabled
FLOW_METRICS_GRANULARITY=file  # file|function|line
FLOW_METRICS_INCLUDE_TESTS=true
FLOW_METRICS_AUTO_REPORT=daily  # hourly|daily|weekly
```

## Use Cases

**Team Productivity**: Track AI adoption and gains
**ROI Analysis**: Calculate return on investment
**Code Review**: Identify AI-heavy files for review
**Skill Optimization**: See which skills provide most value

## Privacy

- All metrics stored locally in `.flow/`
- No external transmission
- File contents not stored, only statistics
- Can be disabled via configuration

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Viewing current metrics
- Historical analysis
- Export workflows
- ROI calculation
- Team dashboards

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete metrics data format
- Calculation formulas
- Hook integration details
- Export formats
- Privacy controls

## Related Skills

- **flow:implement**: Generates code (tracked by metrics)
- All Flow skills tracked for usage statistics

## Validation

Test this skill:
```bash
scripts/validate.sh
```
