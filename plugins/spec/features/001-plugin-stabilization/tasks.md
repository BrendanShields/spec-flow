# Task Breakdown: Plugin Stabilization

**Feature**: 001-plugin-stabilization
**Created**: 2024-10-30
**Total Tasks**: 24
**Estimated Time**: 4 hours

## Tracking Guidelines

- **GitHub Issues**: Track work in the story issues listed below. Keep the sub-task checklist in sync before closing an issue.
- **External Tracker**: None configured for this feature. If JIRA becomes available, mirror the issues and cross-link IDs.
- **Documentation Updates**: Update `.spec-memory/WORKFLOW-PROGRESS.md`, `docs/`, and any blueprint references as soon as a story's sub tasks are completed.

---

## Epic 0: Foundations (Supports all epics)

### Story 0.0 – Initialise Stabilisation Work (GitHub #[ops-placeholder])

#### Sub Tasks
- [ ] **ST-0.0.1** Create safety backup of the existing workspace.
  ```bash
  cp -r . ../spec-backup-$(date +%Y%m%d-%H%M%S)
  ls -la ../spec-backup-*
  ```
- [ ] **ST-0.0.2** Create feature branch `feat/spec-refactor-stabilization` and confirm checkout.
  ```bash
  git checkout -b feat/spec-refactor-stabilization
  git branch --show-current
  ```
- [ ] **ST-0.0.3** Audit working tree to confirm Navi artefacts are marked for removal and Spec files exist.
  ```bash
  git status --short | cut -c1-2 | sort | uniq -c
  ```
- [ ] **ST-0.0.4** Record baseline findings in `.spec-memory/WORKFLOW-PROGRESS.md`.

---

## Epic 1: Documentation & Traceability (PRD §2.1 / Blueprint DOC-01)

### Story 1.1 – Document Changes (GitHub #TBD-001)

#### Sub Tasks
- [ ] **ST-1.1.1** Export deleted file list with reasons and capture in `features/001-plugin-stabilization/spec.md` appendices.
- [ ] **ST-1.1.2** Export added/modified files with summaries into `docs/CHANGE-LOG.md` (new) and link from spec.
- [ ] **ST-1.1.3** Draft Navi→Spec migration overview highlighting structural differences.
- [ ] **ST-1.1.4** Update `.spec-memory/CHANGES-PLANNED.md` with documented deltas.

### Story 1.2 – Update Documentation (GitHub #TBD-002)

#### Sub Tasks
- [ ] **ST-1.2.1** Refresh `plugins/spec/README.md` and marketplace docs to remove Navi references.
- [ ] **ST-1.2.2** Validate documented command examples against a local run and capture output snippets.
  ```bash
  /spec init
  /spec plan --dry-run
  /spec tasks --summary
  ```
- [ ] **ST-1.2.3** Update quick-start and workflow docs under `docs/` and `.spec/`.
- [ ] **ST-1.2.4** Commit documentation updates with message `docs: refresh Spec plugin guidance` and attach results to GitHub issue checklist.

---

## Epic 2: Release Hygiene & Validation (PRD §2.2 / Blueprint REL-02)

### Story 2.1 – Organise Commits (GitHub #TBD-003)

#### Sub Tasks
- [ ] **ST-2.1.1** Stage and commit Flow/Navi deletions (`git ls-files --deleted | xargs git add`).
- [ ] **ST-2.1.2** Stage Spec core structure (`.spec/`, `.spec-state/`, `.spec-memory/`) and commit with rationale.
- [ ] **ST-2.1.3** Stage skills, commands, and hooks; commit as cohesive unit.
- [ ] **ST-2.1.4** Stage templates/agents aligning with new naming conventions.
- [ ] **ST-2.1.5** Review commit history (`git log --oneline -n 7`) ensuring narrative alignment, adjust as needed.
- [ ] **ST-2.1.6** Push branch and open PR using `gh pr create`, linking the GitHub story issue.

### Story 2.2 – Validate Functionality (GitHub #TBD-004)

#### Sub Tasks
- [ ] **ST-2.2.1** Execute validation script if available to confirm no regressions.
  ```bash
  if [ -f ./plugins/spec/scripts/validate.sh ]; then
    ./plugins/spec/scripts/validate.sh
  fi
  ```
- [ ] **ST-2.2.2** Install plugin locally (`/plugin install ./`) and run `/spec init`, `/spec plan`, `/spec tasks`.
- [ ] **ST-2.2.3** Verify state management by exercising `.spec-state/` checkpoint and `.spec-memory/` updates.
- [ ] **ST-2.2.4** Capture validation evidence and attach to GitHub issue and project docs.
- [ ] **ST-2.2.5** Update `.spec-memory/CHANGES-COMPLETED.md` after successful validation.

### Story 2.3 – Clean Configuration (GitHub #TBD-005)

#### Sub Tasks
- [ ] **ST-2.3.1** Reconcile `.gitignore` files and marketplace metadata; commit with `fix:` message.
- [ ] **ST-2.3.2** Run linting/schema checks for config files.
  ```bash
  npm run lint --workspaces --if-present
  jq . ../../.claude-plugin/marketplace.json >/dev/null
  ```
- [ ] **ST-2.3.3** Confirm `git status` is clean except for pending story work; document findings in issue checklist.
- [ ] **ST-2.3.4** Update relevant blueprint configuration notes after cleanup.

---

## Epic 3: Migration Support (PRD §2.3 / Blueprint MIG-03)

### Story 3.1 – Publish Migration Guide (GitHub #TBD-006)

#### Sub Tasks
- [ ] **ST-3.1.1** Draft migration steps and breaking changes in `docs/MIGRATION-GUIDE.md`.
- [ ] **ST-3.1.2** Review guide with maintainers, capture feedback in GitHub issue comments.
- [ ] **ST-3.1.3** Publish final guide, link from README and `.spec-memory/WORKFLOW-PROGRESS.md`.
- [ ] **ST-3.1.4** Close GitHub issue once documentation links and checklists are complete.

---

## Completion Checklist

- [ ] All sub tasks checked off in GitHub issues
- [ ] External tracker statuses updated (if later configured)
- [ ] Project-level documentation refreshed
- [ ] Release PR merged with agreed strategy
- [ ] Post-release summary appended to `.spec-memory/WORKFLOW-PROGRESS.md`
