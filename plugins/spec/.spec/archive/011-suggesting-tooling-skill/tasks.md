# Tasks: Suggesting Tooling Skill

## Parallel Group A - Setup

- [x] T001: Create skill directory structure [P1]

## Parallel Group B - Core Files [depends:A]

- [x] T002: Create SKILL.md with workflow and pattern detection [P1] [depends:T001]
- [x] T003: Create reference.md with pattern catalog [P1] [depends:T001]

## Parallel Group C - Pattern Library [depends:B]

- [x] T004: Create patterns/skills.md with skill mappings [P2] [depends:T002,T003]
- [x] T005: Create patterns/agents.md with agent mappings [P2] [depends:T002,T003]

## Sequential - Finalization [depends:C]

- [x] T006: Validate skill against creating-skills checklist [P1] [depends:T002,T003,T004,T005]

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
- `[critical:type]` - Requires extra review (schema, api, types, auth)
- `[estimate:S/M/L]` - Size estimate
