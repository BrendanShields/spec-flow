# Tasks: Workflow Phase Gates

## Parallel Group A - Scripts

- [x] T001: Create `scripts/validate-phase.sh` in orbit-workflow skill [P1]
- [x] T002: Create `scripts/update-status.sh` in orbit-workflow skill [P1]
- [x] T003: Create `scripts/log-activity.sh` in orbit-workflow skill [P1]

## Parallel Group B - Templates [depends:A]

- [x] T004: Update metrics.md template with ISO timestamp format [P1]

## Parallel Group C - Integration [depends:A]

- [x] T005: Add phase validation section to orbit-workflow SKILL.md [P1] [depends:T001]
- [x] T006: Add pre-flight gate to implementing-tasks.md agent [P1]

## Sequential - Cleanup [depends:B,C]

- [x] T007: Update spec.md frontmatter to implementation status [P1]
- [~] T008: Remove phase-change functions from hooks/lib.sh [P2] (deferred - still used by archive_feature)

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
- `[critical:type]` - Requires extra review
