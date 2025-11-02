# Workflow Track

Monitor progress, view metrics, maintain specifications, and perform quality checks.

## What This Does

Access tracking and maintenance functions throughout the development lifecycle:

- 📊 **Metrics** - Development stats, velocity, completion rates
- 📝 **Update** - Modify specifications and documentation
- 🔍 **Analyze** - Consistency checks and validation
- ✅ **Quality** - Generate checklists and quality reports

This command is orthogonal to the main workflow - use it anytime during development to monitor progress and maintain quality.

## When to Use

- **Check progress** - See how far along you are
- **View metrics** - Understand development velocity and patterns
- **Update specs** - Requirements changed or learned something new
- **Quality checks** - Validate consistency across artifacts
- **Maintain docs** - Keep documentation current
- **Sync external** - Update JIRA, Confluence, etc.

## Implementation

I'll present an interactive menu to access tracking and maintenance functions.

### Step 1: Read Current State

I'll read workflow state to provide context:
- Current feature and phase
- Progress metrics
- Recent activity
- Quality indicators

### Step 2: Present Tracking Menu

Using AskUserQuestion, I'll show available tracking options:

```
📊 Tracking & Maintenance

What would you like to do?

Options:
- 📈 View Metrics → Development stats and progress
- 📝 Update Specification → Modify spec based on learnings
- 🔍 Analyze Consistency → Validate spec-plan-code alignment
- ✅ Quality Checklist → Generate quality review checklist
- 🔄 Sync External → Update JIRA/Confluence
- 📚 View Documentation → Read project artifacts
```

### Step 3: Execute Selection

Based on user's choice:

**📈 View Metrics**

I'll invoke the workflow skill to load `phases/5-track/metrics/guide.md` which will:
- Show development velocity (tasks per day/week)
- Display completion rates by priority (P1/P2/P3)
- Show phase durations (how long each phase took)
- Present feature progress (completed vs in-progress)
- Calculate quality metrics (test coverage, consistency score)

**Output Example:**
```
Development Metrics

Active Feature: 002-user-authentication
Progress: 12/15 tasks (80%)
Time in Phase: 3 hours 42 minutes

Velocity:
- Last 7 days: 8 tasks completed
- Average: 1.14 tasks/day

Completion by Priority:
- P1: 8/10 (80%) ████████░░
- P2: 4/5 (80%)  ████████░░
- P3: 0/0 (N/A)  ──────────

Phase Durations:
- Specification: 45 minutes
- Planning: 1 hour 20 minutes
- Implementation: 3 hours 42 minutes (in progress)

Quality Metrics:
- Spec-Plan Consistency: 95%
- Test Coverage: 87%
- [CLARIFY] Tags Resolved: 100%
```

After displaying, I'll ask if they want to:
- Return to tracking menu
- View specific metrics in detail
- Export metrics report

---

**📝 Update Specification**

I'll invoke the workflow skill to load `phases/5-track/update/guide.md` which will:

Ask what needs updating:
```
What would you like to update?

Options:
- Requirements changed → Add/modify user stories
- Found edge case → Add acceptance criteria
- Learned during implementation → Document decisions
- Scope adjustment → Move items between priorities
- Architecture change → Update technical approach
```

Then use Edit tool to update the appropriate files:
- `spec.md` - For requirement changes
- `plan.md` - For technical changes
- `tasks.md` - For task adjustments
- `{config.paths.memory}/DECISIONS-LOG.md` - For new decisions

After update, I'll:
- Show what was changed (diff view)
- Ask if consistency check is needed
- Update workflow state

---

**🔍 Analyze Consistency**

I'll invoke the workflow skill to load `phases/3-design/analyze/guide.md` which will:

Check multiple consistency dimensions:
1. **Spec ↔ Plan Alignment**
   - All user stories have tasks in plan
   - Plan addresses all requirements
   - No orphaned architecture decisions

2. **Plan ↔ Tasks Alignment**
   - All plan items have corresponding tasks
   - Tasks cover all technical components
   - No missing implementation areas

3. **Tasks ↔ Code Alignment**
   - All completed tasks have code
   - No untracked code changes
   - Test coverage for all user stories

4. **Documentation Consistency**
   - ADRs match implementation
   - Comments align with spec
   - README reflects actual state

**Output Example:**
```
Consistency Analysis

✅ Spec → Plan: 95% aligned
   ⚠️  US2.3 missing in plan.md
   ✅ All other stories covered

✅ Plan → Tasks: 100% aligned
   ✅ All components have tasks
   ✅ All tasks link to plan sections

⚠️  Tasks → Code: 88% aligned
   ✅ Completed tasks have code
   ⚠️  3 tasks missing tests
   ✅ No orphaned code found

✅ Documentation: 92% current
   ✅ ADRs match implementation
   ⚠️  README needs update for auth changes
   ✅ Comments are current

Overall Consistency: 94% ████████████████████░

Recommended Actions:
1. Add tasks for US2.3 in plan.md
2. Write tests for T007, T011, T014
3. Update README.md authentication section
```

After analysis, I'll ask if they want to:
- Fix issues automatically (for simple fixes)
- Get guidance on fixing manually
- Generate quality checklist
- Return to tracking menu

---

**✅ Quality Checklist**

I'll invoke the workflow skill to load `phases/2-define/checklist/guide.md` which will:

Generate a comprehensive quality checklist:

**Specification Quality:**
- [ ] All user stories follow format "As a... I can... so that..."
- [ ] Acceptance criteria are clear and testable
- [ ] P1/P2/P3 priorities are appropriate
- [ ] No [CLARIFY] tags remaining
- [ ] Edge cases documented
- [ ] Non-functional requirements defined

**Planning Quality:**
- [ ] Architecture decisions documented (ADRs)
- [ ] All components have clear responsibility
- [ ] Dependencies identified
- [ ] Integration points defined
- [ ] Security considerations addressed
- [ ] Performance requirements specified

**Implementation Quality:**
- [ ] All tasks linked to user stories
- [ ] Tests written for P1 user stories
- [ ] Error handling implemented
- [ ] Code follows project conventions
- [ ] Documentation updated
- [ ] No TODO/FIXME comments

**Process Quality:**
- [ ] Regular commits with clear messages
- [ ] State files kept current
- [ ] External systems synced (if applicable)
- [ ] Metrics tracked
- [ ] Team informed (if applicable)

After showing checklist, I'll offer to:
- Help complete remaining items
- Export checklist for review
- Return to tracking menu

---

**🔄 Sync External Systems**

If JIRA/Confluence integration is configured (check CLAUDE.md), I'll:

1. **Check configuration:**
   ```
   Read CLAUDE.md for:
   - SPEC_ATLASSIAN_SYNC
   - SPEC_JIRA_PROJECT_KEY
   - SPEC_CONFLUENCE_ROOT_PAGE_ID
   ```

2. **Show sync options:**
   ```
   External System Sync

   Available Integrations:
   - JIRA (PROJ) → Sync user stories as tickets
   - Confluence (root: 123456) → Publish specifications

   What would you like to sync?

   Options:
   - 📋 JIRA → Create/update tickets from user stories
   - 📚 Confluence → Publish spec.md as documentation
   - 🔄 Both → Sync all external systems
   - ⚙️ Configure → Set up integration settings
   ```

3. **Execute sync** using MCP tools (if available)

4. **Report results:**
   ```
   Sync Complete

   JIRA:
   - Created: 3 new tickets
   - Updated: 2 existing tickets
   - Epic: PROJ-123 (user-authentication)

   Confluence:
   - Page created: Authentication System Spec
   - URL: https://company.atlassian.net/wiki/...
   - Last updated: 2025-11-02 17:30

   Next sync recommended: After implementation complete
   ```

If not configured, I'll offer to help set it up.

---

**📚 View Documentation**

I'll show available documentation and let user choose what to view:

```
Project Documentation

What would you like to view?

Options:
- 📋 Current Specification → features/{id}-{name}/spec.md
- 🎨 Technical Plan → features/{id}-{name}/plan.md
- 📝 Task List → features/{id}-{name}/tasks.md
- 📊 Workflow Progress → {config.paths.memory}/WORKFLOW-PROGRESS.md
- 🗂️ Decision Log → {config.paths.memory}/DECISIONS-LOG.md
- ✅ Completed Changes → {config.paths.memory}/CHANGES-COMPLETED.md
- 🏗️ Architecture Blueprint → .spec/architecture-blueprint.md
- 📖 Product Requirements → .spec/product-requirements.md
```

Then I'll use Read tool to display the selected file with syntax highlighting and formatting.

## Menu Flow

```
/workflow:track
  ↓
┌─────────────────────────────┐
│ Tracking & Maintenance Menu │
└─────────────────────────────┘
  ↓
AskUserQuestion:
  📈 View Metrics
  📝 Update Specification
  🔍 Analyze Consistency
  ✅ Quality Checklist
  🔄 Sync External
  📚 View Documentation
  ↓
Execute selected option
  ↓
Show results
  ↓
AskUserQuestion:
  🔙 Return to tracking menu
  ↗️ Return to main workflow (/workflow:spec)
  🛑 Done
```

## Integration

This command integrates with:
- **Workflow skill** - Routes to phase 5 tracking guides
- **State files** - Reads progress and metrics
- **Memory files** - Accesses decision logs and change history
- **MCP tools** - Syncs with external systems (optional)
- **Analysis tools** - Validates consistency

## Benefits

**Continuous Monitoring:**
- ✅ Track progress throughout development
- ✅ Catch inconsistencies early
- ✅ Maintain quality standards

**Adaptability:**
- ✅ Update specs as you learn
- ✅ Document decisions in real-time
- ✅ Adjust priorities based on insights

**External Integration:**
- ✅ Keep team tools synchronized
- ✅ Publish documentation automatically
- ✅ Track work in JIRA/Confluence

**Quality Assurance:**
- ✅ Automated consistency checks
- ✅ Quality checklists
- ✅ Metrics-driven improvement

## Examples

**Example 1: Checking Progress**

```bash
User: /workflow:track

Claude presents menu:
  - 📈 View Metrics
  - 📝 Update Specification
  - ...

User selects: View Metrics

Claude: [Shows comprehensive metrics]
- Velocity: 1.2 tasks/day
- Progress: 75% complete
- Quality: 92% consistency

Claude: What would you like to do?
  - 🔙 Return to tracking
  - ↗️ Return to workflow
```

**Example 2: Updating Spec After Learning**

```bash
User: /workflow:track

User selects: Update Specification

Claude: What needs updating?
  - Requirements changed
  - Found edge case
  - Learned during implementation

User selects: Found edge case

Claude: What edge case did you discover?
User: When user is already logged in, need to handle session refresh

Claude: I'll add this to the acceptance criteria...
[Updates spec.md]

Claude: Updated! Added to US2.1 acceptance criteria:
- [ ] Handle session refresh for already-logged-in users

Run consistency check?
  - ✅ Yes
  - 🔙 Return to tracking
```

---

Use `/workflow:track` anytime to monitor progress, maintain quality, and keep documentation current!
