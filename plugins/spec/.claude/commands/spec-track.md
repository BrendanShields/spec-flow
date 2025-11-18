# Workflow Track

Secondary slash command for maintenance flows. `/spec-track` never runs phases itself—it just reads current progress and routes requests to the tracking skills under `phases/5-track/` (or simple Read operations) using a single AskUserAgent prompt.

## Capabilities
- 📈 Metrics dashboard (phase 5 metrics guide)
- 📝 Spec/plan/task updates (phase 5 update guide)
- 🔍 Consistency analysis (phase 3 analyze guide)
- ✅ Quality checklist (phase 5 checklist templates)
- 🔄 External sync (MCP-enabled integrations)
- 📚 Quick document viewer (Read tool)

## Option Catalog
| ID | Label | Description | Action |
|----|-------|-------------|--------|
| `metrics` | 📈 View Metrics | Show progress, velocity, completion percentages | `phases/5-track/metrics/guide.md` |
| `update` | 📝 Update Specification | Edit spec/plan/tasks + decision log | `phases/5-track/update/guide.md` |
| `analyze` | 🔍 Analyze Consistency | Run validate/analyze guide | `phases/3-design/analyze/guide.md` |
| `quality` | ✅ Quality Checklist | Generate QA checklist, export as needed | `phases/5-track/metrics/guide.md` (quality section) |
| `sync` | 🔄 Sync External | Trigger MCP flows (JIRA, Confluence, Linear, GitHub) | `phases/5-track/update/guide.md` with MCP enabled |
| `docs` | 📚 View Documentation | Read any tracked artifact (spec, plan, tasks, logs) | Read tool |
| `return` | ↗️ Back to Workflow | Jump back into `/spec` | command dispatch |

## Execution Flow
1. **Read context** – load `{config.paths.state}/current-session.md` and `workflow-progress.md` to populate stats shown in the AskUserAgent prompt.
2. **AskUserAgent** – pass the table above along with current stats so Claude highlights the most relevant action (e.g., show `metrics` when in implementation, `update` after requirement changes).
3. **Dispatch** – route to the mapped skill or perform the inline Read:
   - Skills automatically update session/memory files.
   - Document view just streams the requested file.
4. **Loop** – after each action, AskUserAgent again (unless the user chooses `return`).

## Integration Notes
- Tracking options rely on the same hooks as `/spec` (NEXT-STEP cache, workflow context append). Nothing special to configure.
- External sync honors the MCP settings from `claude.md` (e.g., `SPEC_ATLASSIAN_SYNC=enabled`).
- Quality checklist content lives inside `phases/5-track/metrics/guide.md`; no duplicate instructions live here.

## Example
```bash
/spec-track
# AskUserAgent suggests 📈 View Metrics (because implementation is 67% done)
# User selects metrics → phases/5-track/metrics/guide.md runs and shows velocity/histograms
# AskUserAgent re-opens with options like 🔍 Analyze, 📝 Update, ↗️ Back to workflow
```
