# Tasks: Hooks Context Injection

## Parallel Group A - Hook Fixes

- [x] T001: Rewrite orbit-init.sh to output minimal context JSON [P1]
- [x] T002: Fix orbit-protect.sh to use tool_input.file_path [P1]
- [x] T003: Fix orbit-log.sh to use tool_name [P1]

## Sequential - Validation [depends:A]

- [x] T004: Test SessionStart outputs valid JSON [P1] [depends:T001]
- [x] T005: Update spec.md status to complete [P1] [depends:T001,T002,T003]

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
