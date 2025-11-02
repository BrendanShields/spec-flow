# metrics phase Technical Reference

Complete technical specifications for metric calculations, data formats, and export schemas.

## Metric Calculation Formulas

### Velocity Metrics

**Features Completed**:
```
Count of features with status = "completed"
```

**Average Feature Duration**:
```
Sum(completed_date - started_date for all completed features) / Count(completed features)
Result in: days (decimal)
```

**Task Velocity**:
```
Total tasks completed / Total days elapsed
Result in: tasks per day (decimal)
```

**Sprint Velocity**:
```
Count(features completed in sprint) / Count(sprints)
Result in: features per sprint (decimal)
```

**Story Points Velocity**:
```
Sum(story points completed in sprint) / Count(sprints)
Result in: story points per sprint (decimal)
Note: Only if story points tracked in WORKFLOW-PROGRESS.md
```

### Quality Metrics

**Test Coverage**:
```
Source: WORKFLOW-PROGRESS.md metrics section
Format: Percentage (0.0 to 1.0)
Display: Percentage with progress bar
```

**Bug Resolution Rate**:
```
bugs_fixed / bugs_found
Result in: Percentage (0.0 to 1.0)
```

**Bug Density**:
```
Total bugs found / Total features completed
Result in: Bugs per feature (decimal)
Target: < 4.0 bugs per feature
```

**Tech Debt Growth Rate**:
```
(Current tech debt items - Initial tech debt items) / Days elapsed
Result in: Items per day (can be negative if decreasing)
```

### Efficiency Metrics

**Phase Time Distribution**:
```
spec_time = Sum(spec phase duration across features) / Sum(total feature duration)
plan_time = Sum(plan phase duration across features) / Sum(total feature duration)
impl_time = Sum(implement phase duration across features) / Sum(total feature duration)

Result in: Percentage of total time
Targets: spec=15%, plan=20%, implement=60%, tasks=5%
```

**Bottleneck Identification**:
```
bottleneck = Phase with largest deviation from target percentage
deviation = (actual_percentage - target_percentage) / target_percentage
```

**Context Switch Frequency**:
```
Count of phase changes or feature switches / Count of features
Result in: Switches per feature
Target: < 5 switches per feature
```

**Rework Percentage**:
```
Count(tasks marked as rework) / Total tasks completed
Result in: Percentage
Source: CHANGES-COMPLETED.md with rework tag
```

### AI Impact Metrics

**AI Contribution Percentage**:
```
ai_generated_lines / total_lines
Result in: Percentage (0.0 to 1.0)
Source: Git commit metadata or manual tracking
```

**AI Time Savings**:
```
Estimated based on:
- Code generation: (ai_lines / 50 lines_per_hour) * efficiency_factor
- Test writing: (ai_test_lines / 30 lines_per_hour) * efficiency_factor
- Documentation: (ai_doc_lines / 100 lines_per_hour) * efficiency_factor

efficiency_factor = 0.7 (conservative estimate)
Result in: Hours saved
```

**AI Suggestion Acceptance**:
```
Count(AI suggestions accepted) / Count(AI suggestions made)
Result in: Percentage
Source: Session logs or manual tracking
```

## Data Source Specifications

### Primary Data Source: WORKFLOW-PROGRESS.md

**Location**: `{config.paths.memory}/WORKFLOW-PROGRESS.md`

**Required Sections**:
```markdown
## Summary
- Total Features: N
- Completed: N (%)
- In Progress: N (%)

## Features
### ✅ Completed Features
#### Feature NNN: Name
- Status: completed
- Completed: YYYY-MM-DD
- Duration: N days/hours
- Tasks: N/N (100%)

### 🚧 In Progress Features
#### Feature NNN: Name
- Status: in_progress
- Started: YYYY-MM-DD
- Progress: N%
- Tasks: N/N (N%)

## Metrics
### Velocity
- Average Feature Duration: N days
- Average Tasks per Feature: N
- Sprint Velocity: N {config.paths.features}/sprint

### Quality
- Test Coverage: N%
- Bugs Found: N
- Bugs Fixed: N
- Tech Debt Items: N

### Efficiency
- Spec Time: N% of feature time
- Planning Time: N% of feature time
- Implementation Time: N% of feature time
```

**Parsing Logic**:
1. Split on `##` headers
2. Extract key-value pairs from list items
3. Parse dates with format YYYY-MM-DD
4. Parse percentages and convert to decimal
5. Parse durations and normalize to days

### Secondary Data Source: current-session.md

**Location**: `{config.paths.state}/current-session.md`

**Used For**:
- Current feature context
- Active task progress
- Real-time metrics (tasks completed today)

**Extract**:
```markdown
**Active Feature**: NNN-feature-name
**Progress**: N/N tasks complete (N%)
```

### Tertiary Data Source: CHANGES-COMPLETED.md

**Location**: `{config.paths.memory}/CHANGES-COMPLETED.md`

**Used For**:
- Task-level timing data
- Detailed completion history
- Rework identification

**Extract**:
```markdown
**TNNN**: Task description ✅
- Completed: YYYY-MM-DD HH:MM
- Duration: N hours
- Files Modified: list
```

## Export Format Specifications

### CSV Export Schema

**Filename**: `metrics-export.csv` (default) or user-specified

**Structure**: Flat table with columns:
```
metric_type      : string  [velocity|quality|efficiency|ai_impact]
metric_name      : string  [specific metric identifier]
value            : float   [numeric value]
unit             : string  [count|percentage|days|hours|tasks_per_day|etc]
timestamp        : string  [ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ]
target           : float   [target value if applicable, null otherwise]
status           : string  [above|below|on_target|na]
```

**Example Rows**:
```csv
metric_type,metric_name,value,unit,timestamp,target,status
velocity,features_completed,2,count,2025-10-31T15:45:00Z,5,below
velocity,sprint_velocity,2.0,features_per_sprint,2025-10-31T15:45:00Z,2.0,on_target
quality,test_coverage,0.87,percentage,2025-10-31T15:45:00Z,0.85,above
```

**Alternative Structure**: Feature-based table
```
feature_id,name,status,started,completed,duration_days,tasks_total,tasks_completed,test_coverage,bugs_found,bugs_fixed,ai_percentage
001,User Auth,completed,2025-10-20,2025-10-25,5,23,23,0.92,7,7,0.68
```

### JSON Export Schema

**Filename**: `metrics-export.json` (default) or user-specified

**Root Structure**:
```json
{
  "meta": {
    "generated_at": "ISO 8601 timestamp",
    "generator": "metrics phase v3.0",
    "project_name": "string",
    "project_started": "YYYY-MM-DD",
    "report_period": {
      "start": "YYYY-MM-DD",
      "end": "YYYY-MM-DD"
    }
  },
  "summary": {
    "total_features": integer,
    "features_completed": integer,
    "features_in_progress": integer,
    "features_planned": integer,
    "completion_rate": float
  },
  "metrics": {
    "velocity": {...},
    "quality": {...},
    "efficiency": {...},
    "ai_impact": {...}
  },
  "features": [
    {
      "id": "string",
      "name": "string",
      "status": "completed|in_progress|not_started",
      "priority": "P1|P2|P3",
      "started": "YYYY-MM-DD",
      "completed": "YYYY-MM-DD|null",
      "duration_days": float,
      "user_stories": {
        "total": integer,
        "completed": integer
      },
      "tasks": {
        "total": integer,
        "completed": integer
      },
      "progress": float,
      "metrics": {
        "test_coverage": float,
        "bugs_found": integer,
        "bugs_fixed": integer,
        "ai_generated_lines": integer,
        "total_lines": integer
      },
      "artifacts": {
        "spec": "path",
        "plan": "path",
        "tasks": "path"
      },
      "integrations": {
        "jira_key": "string|null",
        "confluence_url": "string|null",
        "pull_request": "string|null"
      }
    }
  ],
  "sprints": [
    {
      "number": integer,
      "start_date": "YYYY-MM-DD",
      "end_date": "YYYY-MM-DD",
      "features_planned": integer,
      "features_completed": integer,
      "story_points_planned": integer,
      "story_points_completed": integer,
      "success_rate": float,
      "progress": float,
      "days_remaining": integer,
      "on_track": boolean
    }
  ],
  "insights": {
    "highlights": ["string"],
    "concerns": ["string"],
    "recommendations": ["string"]
  }
}
```

**Data Types**:
- `integer`: Whole numbers
- `float`: Decimal numbers (0.0 to 1.0 for percentages)
- `string`: Text values
- `boolean`: true/false
- `null`: Missing or not applicable

**Required vs Optional**:
- Required: meta, summary, metrics, features
- Optional: sprints (if sprint tracking not used), integrations (if not configured)

## Visualization Specifications

### Progress Bar Format

**Pattern**: `█▓▒░` (4 levels of shading)

**Calculation**:
```
filled_blocks = round(percentage * 10)
bar = repeat("█", filled_blocks) + repeat("░", 10 - filled_blocks)
```

**Examples**:
- 0%:   `░░░░░░░░░░`
- 50%:  `█████░░░░░`
- 87%:  `███████▓░░`
- 100%: `██████████`

**With Percentage**:
```
Test Coverage: 87% ███████▓░░
```

### Text-Based Charts

**Trend Line** (last 5 sprints):
```
Sprint Velocity Trend:
Sprint 1: ▓▓▓▓▓▓▓▓░░ 2.1 features
Sprint 2: ▓▓▓▓▓▓▓▓▓░ 2.3 features ↗
Sprint 3: ▓▓▓▓▓▓▓░░░ 1.9 features ↘
Sprint 4: ▓▓▓▓▓▓▓▓░░ 2.0 features ↗
Sprint 5: ▓▓▓▓▓▓▓▓▓▓ 2.5 features ↗
```

**Horizontal Bar Chart**:
```
Phase Time Distribution:
Spec:    ███░░░░░░░ 15%
Plan:    ████░░░░░░ 20%
Tasks:   █░░░░░░░░░ 5%
Impl:    ██████░░░░ 65% ⚠️ (target: 60%)
```

**Status Indicators**:
- ✅ On target or better
- ⚠️ Warning (slightly off target)
- ❌ Critical (significantly off target)
- ↗ Trending up
- ↘ Trending down
- → Stable

## Command-Line Options

### Flags

**`--export=FORMAT`**:
- Values: `csv`, `json`
- Default: None (display only)
- Example: `metrics phase --export=csv`

**`--output=PATH`**:
- Values: File path (absolute or relative)
- Default: `./metrics-export.{csv|json}`
- Example: `metrics phase --export=json --output=/tmp/metrics.json`

**`--verbose`**:
- Values: None (flag)
- Default: False
- Effect: Show detailed historical analysis
- Example: `metrics phase --verbose`

**`--category=TYPE`**:
- Values: `velocity`, `quality`, `efficiency`, `ai`, `all`
- Default: `all`
- Effect: Filter to specific metric category
- Example: `metrics phase --category=velocity`

**`--format=STYLE`**:
- Values: `dashboard`, `table`, `minimal`
- Default: `dashboard`
- Effect: Change display format
- Example: `metrics phase --format=table`

### Usage Examples

```bash
# Default dashboard
metrics phase

# Verbose analysis
metrics phase --verbose

# Export to CSV
metrics phase --export=csv

# Export to custom path
metrics phase --export=json --output=/reports/metrics-2025-10-31.json

# Show only velocity
metrics phase --category=velocity

# Minimal table format
metrics phase --format=table

# Combined
metrics phase --verbose --category=quality --format=dashboard
```

## Implementation Notes

### Performance Considerations

**File Reading**:
- WORKFLOW-PROGRESS.md typically < 10 KB
- Read once at skill start
- Cache parsed data for multiple calculations

**Calculation Complexity**:
- All metrics O(n) where n = number of features
- Typical n < 100 features
- Total calculation time < 100ms

**Export File Size**:
- CSV: ~1-2 KB per 10 features
- JSON: ~3-5 KB per 10 features
- Typical project: < 50 KB exports

### Error Handling

**Missing WORKFLOW-PROGRESS.md**:
```
Error: Metrics data not found
File: {config.paths.memory}/WORKFLOW-PROGRESS.md

Solution: Initialize Spec tracking
Command: /spec init

Description: WORKFLOW-PROGRESS.md contains metric data.
Run /spec init to set up tracking infrastructure.
```

**Incomplete Data**:
```
Warning: Some metrics unavailable

Missing data:
- Sprint velocity (need 2+ completed sprints)
- AI impact metrics (no tracking data)

Displaying available metrics:
- Feature completion: 2/5 (40%)
- Average duration: 4.2 days
- Test coverage: 87%

To enable missing metrics:
- Complete more features for sprint trends
- Enable AI tracking in session logs
```

**Parse Errors**:
```
Error: Cannot parse WORKFLOW-PROGRESS.md

Issue: Invalid date format at line 42
Expected: YYYY-MM-DD
Found: 10/31/2025

Solution: Fix date format in WORKFLOW-PROGRESS.md
Run: /validate to check file format
```

**Export Errors**:
```
Error: Cannot write export file

Path: /readonly/metrics.csv
Issue: Permission denied

Solution: Choose writable location
Try: ./metrics.csv or ~/metrics.csv
```

### Data Validation

**Before Calculation**:
1. Verify WORKFLOW-PROGRESS.md exists
2. Check file is readable
3. Validate required sections present
4. Verify date formats (YYYY-MM-DD)
5. Check numeric values parseable

**During Calculation**:
1. Handle division by zero (no completed features)
2. Skip features with missing data
3. Log warnings for anomalies
4. Default to N/A for unavailable metrics

**After Calculation**:
1. Verify all percentages between 0.0 and 1.0
2. Check for logical inconsistencies
3. Validate export data structure
4. Confirm file write success

## Integration with Other Skills

**spec:status**:
- Calls metrics phase internally for quick metrics
- Uses subset of calculations
- Displays minimal output

**analyze phase**:
- Calls metrics phase for feature-specific data
- Filters to single feature
- Adds deeper analysis

**plan phase**:
- Uses velocity metrics for estimation
- References historical durations
- Suggests realistic timelines

**tasks phase**:
- Uses task velocity for breakdown
- References avg tasks per feature
- Optimizes parallel task opportunities

## Related Files

**State Management**: `shared/state-management.md`
**Workflow Patterns**: `shared/workflow-patterns.md`
**Integration**: `shared/integration-patterns.md`

---

**Last Updated**: 2025-10-31
**Token Size**: ~2,100 tokens
**Skill Version**: 3.0.0
