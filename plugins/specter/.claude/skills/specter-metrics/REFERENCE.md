# Flow Metrics Reference

## Metrics Data Format

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
      "modifications": [
        {
          "timestamp": "2024-10-21T10:30:00Z",
          "type": "ai",
          "lines": 150
        }
      ]
    }
  },
  "statistics": {
    "aiPercentage": 78,
    "humanPercentage": 22,
    "generationVelocity": 234,
    "skillUsage": {
      "specter:implement": 23,
      "specter:specify": 12
    }
  }
}
```

## Calculation Formulas

**AI Percentage**:
```
aiPercentage = (aiGeneratedLines / totalLines) * 100
```

**Generation Velocity**:
```
velocity = aiGeneratedLines / hoursWorked
```

**Time Saved Estimate**:
```
timeSaved = aiGeneratedLines / averageTypingSpeed
averageTypingSpeed = 50 lines/hour (conservative)
```

## Command-Line Options

### `--history [PERIOD]`

View historical trends.

**Periods**: `1d`, `7d`, `30d`, `90d`

### `--export [FORMAT]`

Export metrics.

**Formats**: `csv`, `json`, `markdown`, `pdf`

### `--report`

Generate comprehensive report with recommendations.

### `--roi`

Calculate ROI: time saved, estimated value, productivity gain.

## Hook Integration

Metrics tracked automatically by `track-metrics.js` hook:

**PostToolUse** on Write/Edit:
- Capture file path
- Count lines added/modified
- Tag as AI-generated
- Update metrics JSON

## Privacy Controls

Disable tracking:
```markdown
SPECTER_METRICS_TRACKING=disabled
```

Anonymize data:
```markdown
SPECTER_METRICS_ANONYMIZE=true
```

## Related Files

- `.specter/.metrics.json`: Current metrics
- `.specter/metrics-history/`: Historical snapshots
- `.specter/metrics-dashboard.md`: Visual dashboard

## Troubleshooting

**Metrics not updating**: Check hook is enabled
**Inaccurate numbers**: Regenerate from git history
**Export fails**: Check write permissions
