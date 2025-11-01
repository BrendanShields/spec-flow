# spec:metrics Examples

Concrete scenarios demonstrating different metric views and use cases.

## Example 1: Default Dashboard View

**User Request**: "Show me the metrics"

**Skill Action**:
1. Reads `.spec-memory/WORKFLOW-PROGRESS.md`
2. Calculates all metric categories
3. Generates dashboard with visualizations
4. Displays on console

**Output**:
```
📊 Spec Metrics Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 VELOCITY METRICS
  Features Completed: 2/5 (40%)
  Average Duration:   4.2 days per feature
  Task Velocity:      23 tasks/day
  Sprint Velocity:    2.0 features/sprint
  Progress:           ████░░░░░░ 40%

📈 QUALITY METRICS
  Test Coverage:      87% ███████▓░░
  Bugs Found/Fixed:   12/10 (83% resolved)
  Bug Density:        6.0 bugs per feature
  Tech Debt Items:    5 open

⚡ EFFICIENCY METRICS
  Spec Phase:         15% of total time
  Plan Phase:         20% of total time
  Implement Phase:    65% of total time
  Bottleneck:         Implementation

🤖 AI IMPACT METRICS
  AI-Generated Lines: 2,145 / 3,500 (61%)
  Features w/ AI:     5/5 (100%)
  Time Saved:         ~18 hours estimated

📊 CURRENT SPRINT (Sprint 2)
  Features Complete:  2/3 (67%)
  Days Elapsed:       7/14 days
  On Track:           Yes ✅

🔍 INSIGHTS
  ✅ Sprint velocity stable
  ⚠️  Bug density above target (6.0 vs 4.0)
  ✅ Test coverage above 85% threshold
  💡 Implementation bottleneck - consider parallel tasks

Last Updated: 2025-10-31 15:45:00
```

**Use Case**: Quick health check of project progress

---

## Example 2: Verbose Historical Analysis

**User Request**: "Show me detailed metrics with historical trends"

**Skill Action**:
1. Reads WORKFLOW-PROGRESS.md with full history
2. Calculates trends across sprints
3. Generates detailed breakdown with comparisons
4. Identifies patterns and anomalies

**Output**:
```
📊 Spec Metrics Dashboard (Verbose Mode)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 VELOCITY METRICS

Features Completed: 2/5 (40%)
├─ Sprint 1: 2 features (100% of sprint capacity)
├─ Sprint 2: 0 features (ongoing - 50% complete)
└─ Trend: On track for 2 features/sprint target

Average Feature Duration: 4.2 days
├─ Feature 001: 5 days (20% above average)
├─ Feature 002: 3.5 days (17% below average)
└─ Trend: Duration stabilizing

Task Completion Velocity: 23 tasks/day
├─ Week 1: 28 tasks/day (+22% above avg)
├─ Week 2: 18 tasks/day (-22% below avg)
└─ Trend: High variance - investigate blockers

Story Points Velocity: 13 points/sprint
├─ Sprint 1: 13 points (baseline)
└─ Sprint 2: 13 points estimated (on track)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 QUALITY METRICS

Test Coverage: 87% (Target: 85%)
├─ Feature 001: 92% coverage (excellent)
├─ Feature 002: 85% coverage (at target)
└─ Trend: Stable, minor 3% decrease

Bugs Found/Fixed: 12 found, 10 fixed (83% resolution)
├─ Critical: 2 found, 2 fixed (100%)
├─ Major: 5 found, 4 fixed (80%)
├─ Minor: 5 found, 4 fixed (80%)
└─ Trend: Resolution rate improving

Bug Density: 6.0 bugs per feature (Target: 4.0)
├─ Feature 001: 7 bugs (above target)
├─ Feature 002: 5 bugs (above target)
└─ Trend: Consistent - review testing approach

Tech Debt Items: 5 open
├─ High Priority: 2 items
├─ Medium Priority: 2 items
├─ Low Priority: 1 item
└─ Trend: Stable - no growth

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ EFFICIENCY METRICS

Phase Time Distribution:
├─ Specification: 15% (30 min avg) [Target: 15%] ✅
├─ Planning:      20% (45 min avg) [Target: 20%] ✅
├─ Task Breakdown: 5% (10 min avg) [Target: 5%] ✅
└─ Implementation: 65% (4h avg)     [Target: 60%] ⚠️

Bottleneck Analysis:
└─ Implementation phase 5% above target
   └─ Root causes:
      - Complex integrations (Elasticsearch)
      - Learning curve for new technologies
      - Insufficient parallel task opportunities
   └─ Recommendations:
      - Create more granular tasks
      - Pair program on complex integrations
      - Front-load research in planning phase

Context Switches: 8 per feature (Target: <5)
└─ Trend: High - interruptions impacting flow

Rework Percentage: 12% of tasks required changes
└─ Trend: Acceptable - mostly from requirement clarifications

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🤖 AI IMPACT METRICS

AI-Generated Code: 2,145 / 3,500 lines (61%)
├─ Feature 001: 1,247 lines (68% AI)
├─ Feature 002: 898 lines (55% AI)
└─ Trend: Consistent AI contribution

AI Time Savings: ~18 hours estimated
├─ Code generation: 12 hours
├─ Test writing: 4 hours
├─ Documentation: 2 hours
└─ Impact: 15% faster feature delivery

Features with AI Assistance: 5/5 (100%)
└─ All features leverage Claude Code

AI Suggestion Acceptance: 78% (high confidence)
└─ Developers modify 22% of AI suggestions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SPRINT ANALYSIS

Sprint 1 (2025-10-15 to 2025-10-29):
├─ Features Planned: 2
├─ Features Completed: 2 (100%)
├─ Story Points: 13/13 (100%)
├─ Quality: 92% avg test coverage
└─ Outcome: Success ✅

Sprint 2 (2025-10-30 to 2025-11-12):
├─ Features Planned: 2
├─ Features Completed: 0 (in progress)
├─ Story Points: 6/13 (46% complete)
├─ Days Remaining: 8 days
└─ Projection: On track for 2 features ✅

Sprint 3 (Planned):
├─ Projected Capacity: 2 features
├─ Features Queued: 3 (need prioritization)
└─ Risk: Dependency on external API (Feature 003)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 INSIGHTS & RECOMMENDATIONS

Performance Highlights:
✅ Sprint velocity consistent at 2 features/sprint
✅ Test coverage maintained above 85% threshold
✅ No critical blockers currently
✅ AI productivity gains measurable

Areas for Improvement:
⚠️  Bug density 50% above target (6.0 vs 4.0)
    → Recommendation: Add code review checklist
⚠️  Implementation time 5% over budget
    → Recommendation: Create smaller parallel tasks
⚠️  Context switches high (8 per feature)
    → Recommendation: Implement focus time blocks

Predictions:
📈 Sprint 2 will complete on time (95% confidence)
📈 Sprint 3 capacity achievable with current velocity
⚠️  Feature 003 payment integration may slip (API dependency)

Action Items:
1. Address bug density - add validation phase
2. Optimize task granularity for parallelization
3. Secure API access for Feature 003 by 2025-11-08
4. Continue current testing practices (working well)

Last Updated: 2025-10-31 15:45:00
Generated by: spec:metrics (verbose mode)
```

**Use Case**: Sprint retrospective, deep performance analysis

---

## Example 3: CSV Export for Dashboard Integration

**User Request**: "Export metrics to CSV for our dashboard"

**Skill Action**:
1. Reads WORKFLOW-PROGRESS.md
2. Formats as CSV with headers
3. Writes to specified file (default: `metrics-export.csv`)
4. Confirms export location

**Command**:
```bash
# Triggers skill with export flag
User: "Export metrics to CSV"
# Or explicit: spec:metrics --export=csv --output=metrics.csv
```

**Output File** (`metrics-export.csv`):
```csv
metric_type,metric_name,value,unit,timestamp,target,status
velocity,features_completed,2,count,2025-10-31T15:45:00Z,5,below
velocity,avg_feature_duration,4.2,days,2025-10-31T15:45:00Z,4.0,above
velocity,task_velocity,23,tasks_per_day,2025-10-31T15:45:00Z,20,above
velocity,sprint_velocity,2.0,features_per_sprint,2025-10-31T15:45:00Z,2.0,on_target
quality,test_coverage,0.87,percentage,2025-10-31T15:45:00Z,0.85,above
quality,bugs_found,12,count,2025-10-31T15:45:00Z,,na
quality,bugs_fixed,10,count,2025-10-31T15:45:00Z,,na
quality,bug_density,6.0,bugs_per_feature,2025-10-31T15:45:00Z,4.0,above
quality,tech_debt_items,5,count,2025-10-31T15:45:00Z,,na
efficiency,spec_phase_pct,0.15,percentage,2025-10-31T15:45:00Z,0.15,on_target
efficiency,plan_phase_pct,0.20,percentage,2025-10-31T15:45:00Z,0.20,on_target
efficiency,implement_phase_pct,0.65,percentage,2025-10-31T15:45:00Z,0.60,above
ai_impact,ai_generated_lines,2145,lines,2025-10-31T15:45:00Z,,na
ai_impact,total_lines,3500,lines,2025-10-31T15:45:00Z,,na
ai_impact,ai_percentage,0.61,percentage,2025-10-31T15:45:00Z,,na
ai_impact,time_saved_hours,18,hours,2025-10-31T15:45:00Z,,na
```

**Console Output**:
```
✅ Metrics exported to CSV
   File: /Users/dev/project/metrics-export.csv
   Rows: 16 metrics
   Format: Compatible with Excel, Tableau, Google Sheets

Import to dashboard tools:
- Excel: File → Import → CSV
- Tableau: Connect to Data → Text File
- Google Sheets: File → Import
- PowerBI: Get Data → Text/CSV
```

**Use Case**: Integration with business intelligence tools, executive reporting

---

## Example 4: JSON Export for API Integration

**User Request**: "Export metrics as JSON for our monitoring API"

**Skill Action**:
1. Reads WORKFLOW-PROGRESS.md and related files
2. Structures as nested JSON with full hierarchy
3. Writes to file
4. Displays sample for verification

**Output File** (`metrics-export.json`):
```json
{
  "meta": {
    "generated_at": "2025-10-31T15:45:00Z",
    "generator": "spec:metrics v3.0",
    "project_name": "My SaaS Application",
    "project_started": "2025-10-15",
    "report_period": {
      "start": "2025-10-15",
      "end": "2025-10-31"
    }
  },
  "summary": {
    "total_features": 5,
    "features_completed": 2,
    "features_in_progress": 1,
    "features_planned": 2,
    "completion_rate": 0.40
  },
  "metrics": {
    "velocity": {
      "features_completed": 2,
      "avg_duration_days": 4.2,
      "task_velocity": 23,
      "sprint_velocity": 2.0,
      "story_points_velocity": 13
    },
    "quality": {
      "test_coverage": 0.87,
      "test_coverage_target": 0.85,
      "bugs": {
        "found": 12,
        "fixed": 10,
        "resolution_rate": 0.83,
        "by_severity": {
          "critical": {"found": 2, "fixed": 2},
          "major": {"found": 5, "fixed": 4},
          "minor": {"found": 5, "fixed": 4}
        }
      },
      "bug_density": 6.0,
      "bug_density_target": 4.0,
      "tech_debt_items": 5
    },
    "efficiency": {
      "phase_distribution": {
        "specification": {"percentage": 0.15, "avg_minutes": 30, "target": 0.15},
        "planning": {"percentage": 0.20, "avg_minutes": 45, "target": 0.20},
        "tasks": {"percentage": 0.05, "avg_minutes": 10, "target": 0.05},
        "implementation": {"percentage": 0.65, "avg_hours": 4.0, "target": 0.60}
      },
      "bottleneck": "implementation",
      "context_switches_per_feature": 8,
      "rework_percentage": 0.12
    },
    "ai_impact": {
      "lines_generated_by_ai": 2145,
      "total_lines": 3500,
      "ai_percentage": 0.61,
      "time_saved_hours": 18,
      "features_with_ai": 5,
      "suggestion_acceptance_rate": 0.78
    }
  },
  "features": [
    {
      "id": "001",
      "name": "User Authentication System",
      "status": "completed",
      "priority": "P1",
      "started": "2025-10-20",
      "completed": "2025-10-25",
      "duration_days": 5,
      "user_stories": {"total": 4, "completed": 4},
      "tasks": {"total": 23, "completed": 23},
      "metrics": {
        "test_coverage": 0.92,
        "bugs_found": 7,
        "bugs_fixed": 7,
        "ai_generated_lines": 1247,
        "total_lines": 1835
      },
      "artifacts": {
        "spec": "features/001-user-auth/spec.md",
        "plan": "features/001-user-auth/plan.md",
        "tasks": "features/001-user-auth/tasks.md"
      },
      "integrations": {
        "jira_key": "PROJ-101",
        "confluence_url": "https://company.atlassian.net/wiki/pages/123456",
        "pull_request": "#42"
      }
    },
    {
      "id": "002",
      "name": "Product Search",
      "status": "in_progress",
      "priority": "P1",
      "started": "2025-10-30",
      "completed": null,
      "duration_days": 1,
      "user_stories": {"total": 4, "completed": 2},
      "tasks": {"total": 23, "completed": 15},
      "progress": 0.65,
      "metrics": {
        "test_coverage": 0.85,
        "bugs_found": 5,
        "bugs_fixed": 3,
        "ai_generated_lines": 898,
        "total_lines": 1665
      }
    }
  ],
  "sprints": [
    {
      "number": 1,
      "start_date": "2025-10-15",
      "end_date": "2025-10-29",
      "features_planned": 2,
      "features_completed": 2,
      "story_points_planned": 13,
      "story_points_completed": 13,
      "success_rate": 1.0
    },
    {
      "number": 2,
      "start_date": "2025-10-30",
      "end_date": "2025-11-12",
      "features_planned": 2,
      "features_completed": 0,
      "story_points_planned": 13,
      "story_points_completed": 6,
      "progress": 0.46,
      "days_remaining": 8,
      "on_track": true
    }
  ],
  "insights": {
    "highlights": [
      "Sprint velocity consistent at 2 features/sprint",
      "Test coverage maintained above 85% threshold",
      "No critical blockers currently",
      "AI productivity gains measurable (18h saved)"
    ],
    "concerns": [
      "Bug density 50% above target (6.0 vs 4.0)",
      "Implementation time 5% over budget",
      "Context switches high (8 per feature)"
    ],
    "recommendations": [
      "Add code review checklist to address bug density",
      "Create smaller parallel tasks to optimize implementation",
      "Implement focus time blocks to reduce context switches"
    ]
  }
}
```

**Console Output**:
```
✅ Metrics exported to JSON
   File: /Users/dev/project/metrics-export.json
   Size: 3.2 KB
   Format: Machine-readable, API-ready

Structure:
├─ meta: Report metadata
├─ summary: High-level overview
├─ metrics: Detailed metrics by category
├─ features: Per-feature breakdown
├─ sprints: Sprint-level data
└─ insights: Analysis and recommendations

Use cases:
- POST to monitoring API
- Import to analytics platform
- Archive for historical analysis
- Generate custom visualizations
```

**Use Case**: Automated reporting, API integration, data warehousing

---

## Usage Patterns

### Pattern 1: Quick Check
```
User: "show metrics"
→ Default dashboard displays
```

### Pattern 2: Deep Dive
```
User: "show me detailed metrics with trends"
→ Verbose mode activates
→ Historical analysis included
```

### Pattern 3: Export for Reporting
```
User: "export metrics to CSV"
→ CSV file generated
→ Path displayed for import
```

### Pattern 4: API Integration
```
User: "export metrics as JSON for monitoring"
→ JSON file with full structure
→ API-ready format
```

### Pattern 5: Specific Category
```
User: "show me velocity metrics"
→ Filters to velocity category only
→ Detailed velocity breakdown
```

---

**Related Skills**: spec:analyze (feature-specific), spec:status (quick overview)
**State Dependencies**: Requires `.spec-memory/WORKFLOW-PROGRESS.md`
