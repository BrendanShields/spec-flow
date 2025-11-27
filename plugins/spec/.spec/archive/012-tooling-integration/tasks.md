# Tasks: Integrate Suggesting-Tooling into Orbit Workflow

## Parallel Group A - Core Updates

- [x] T001: Update analyzing-codebase agent with tooling step [P1]
- [x] T002: Update orbit-workflow skill with archive tooling check [P1]

## Sequential - Validation [depends:A]

- [x] T003: Verify integration points work correctly [P1] [depends:T001,T002]

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
- `[critical:type]` - Requires extra review (schema, api, types, auth)
- `[estimate:S/M/L]` - Size estimate
