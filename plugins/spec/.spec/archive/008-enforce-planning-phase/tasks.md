# Tasks: Enforce Planning Phase in Workflow

## Parallel Group A - Templates

- [x] T001: Create templates/quick-plan.md [P1]
- [x] T002: Create templates/quick-tasks.md [P2]

## Sequential - Skill Update [depends:A]

- [x] T003: Update SKILL.md Phase Validation section [P1] [critical:workflow]
- [x] T004: Update SKILL.md Implement section with validation gate [P1] [critical:workflow]
- [x] T005: Add quick-plan workflow option [P2] [depends:T001]

## Validation

- [x] T006: Test validation blocks implementation without artifacts [P1] [depends:T003,T004]
- [x] T007: Update feature status to complete [P1] [depends:T006]

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
- `[critical:workflow]` - Changes core workflow behavior
