# Spec Track

Secondary slash command for workflow tracking and maintenance. Provides guidance on which tracking and maintenance skills to invoke.

## What This Command Does

- Reads current workflow progress and metrics
- Presents interactive `AskUserQuestion` interface for tracking and maintenance
- Invokes appropriate skill based on user selection
- Guides spec updates, consistency checks, and progress monitoring

**User Experience**: Interactive multi-tab questions for easy access to metrics, updates, validation, and documentation viewing.

## Capabilities

### 📊 Progress Monitoring
- **orbit-lifecycle** (Track branch) - View metrics, velocity, completion rates, forecasts

### 📝 Specification Maintenance
- **orbit-lifecycle** (Update branch) - Modify specs, add/remove user stories, update requirements
- **orbit-lifecycle** (Clarify branch) - Resolve new [CLARIFY] tags that emerge during development

### 🔍 Quality Validation
- **orbit-lifecycle** (Quality branch) - Validate spec quality and completeness
- **orbit-planning** (Consistency branch) - Check spec-plan-tasks alignment

### 📚 Documentation & Sync
- View spec/plan/tasks documents directly (Read tool)
- Sync to external systems (JIRA, Confluence) if MCP enabled

## Interactive Interface

Use `AskUserQuestion` to present tracking and maintenance options:

**Main Question**: "What would you like to track or update?"

**Options**:
1. **View Metrics** → Invoke `orbit-lifecycle` (Track branch)
   - Description: "See velocity, completion rates, forecasts, and bottleneck analysis"

2. **Update Specification** → Invoke `orbit-lifecycle` (Update branch)
   - Description: "Modify requirements, add/remove user stories, update acceptance criteria"

3. **Check Consistency** → Invoke `orbit-planning` (Consistency branch)
   - Description: "Validate alignment between spec, plan, and tasks"

4. **Validate Spec Quality** → Invoke `orbit-lifecycle` (Quality branch)
   - Description: "Quality check specification completeness and clarity"

**Multi-Tab Approach** (when showing documents):

**Question 1**: "Which document would you like to view?" (multiSelect: false)
- Specification (spec.md)
- Technical Plan (plan.md)
- Tasks Breakdown (tasks.md)
- All Documents (show all three)

**Question 2**: "Would you like to perform any actions?" (multiSelect: false)
- Just view (Read only)
- View + Validate (Read + `orbit-planning` Consistency branch)
- View + Update (Read + `orbit-lifecycle` Update branch)

## Autonomous Skills for Tracking

### Monitoring & Metrics
- **orbit-lifecycle** (Track branch) - Dashboards, velocity trends, forecasts, bottleneck analysis

### Specification Updates
- **orbit-lifecycle** (Update branch) - Add/modify/remove user stories, update acceptance criteria
- **orbit-lifecycle** (Clarify branch) - Resolve [CLARIFY] tags that arise during implementation

### Quality & Validation
- **orbit-lifecycle** (Quality branch) - Spec quality gates, completeness checks
- **orbit-planning** (Consistency branch) - Cross-document validation (spec ↔ plan ↔ tasks)

## State Awareness

The command reads:
- `{config.paths.state}/current-session.md` - Current feature and phase
- `{config.paths.memory}/workflow-progress.md` - Historical progress and metrics
- `{config.paths.spec_root}/architecture/architecture-decision-record.md` - Architecture decisions
- Active feature files (spec.md, plan.md, tasks.md)

This allows Claude to provide context-aware recommendations.

## Examples

```bash
/spec-track
# Shows context: "You're 67% through implementation (8/12 tasks)"
# → Shows AskUserQuestion:
#    "What would you like to track or update?"
#    [View Metrics] [Update Specification] [Check Consistency] [Validate Spec Quality]
# User selects "View Metrics" → Invokes: orbit-lifecycle (Track)
```

```bash
/spec-track
# → Shows AskUserQuestion:
#    "What would you like to track or update?"
#    [View Metrics] [Update Specification] [Check Consistency] [Validate Spec Quality]
# User selects "Update Specification" → Invokes: orbit-lifecycle (Update)
```

```bash
/spec-track
# User wants to view documents
# → Shows multi-tab AskUserQuestion:
#    Q1: "Which document would you like to view?"
#        [Specification] [Technical Plan] [Tasks Breakdown] [All Documents]
#    Q2: "Would you like to perform any actions?"
#        [Just view] [View + Validate] [View + Update]
# User selects options → Performs selected actions
```

## Integration with External Systems

- If MCP is configured (via `.claude/mcp.json` and `SPEC_ATLASSIAN_SYNC=enabled`):
  - **orbit-lifecycle** (Track branch) can sync metrics to JIRA
  - **orbit-lifecycle** (Update branch) can sync changes to Confluence
- Hooks handle automatic syncing on PostToolUse

## Command Flow

1. `/spec-track` invoked
2. Read current state and progress
3. Present context summary (current phase, completion %, active feature)
4. **Show `AskUserQuestion` with tracking/maintenance options**
5. User selects option(s) from interactive UI
6. Claude invokes the corresponding autonomous skill(s)
7. Skill executes and reports results
8. Suggest running `/orbit` or `/spec-track` again for next action

**Key Principle**: Use `AskUserQuestion` with clear, actionable options. Multi-tab questions when viewing documents to combine view + action in one interaction.

## Relationship to /orbit

- `/orbit` - Main workflow navigation (define → design → build)
- `/spec-track` - Tracking and maintenance (monitor → update → validate)

Both commands guide Claude to invoke the appropriate autonomous skills based on context.
