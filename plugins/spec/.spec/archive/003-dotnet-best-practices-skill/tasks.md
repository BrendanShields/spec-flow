# Tasks: .NET Best Practices Skill

## Parallel Group A - Setup

- [x] T001: Create skill directory `.claude/skills/reviewing-dotnet-code/` [P1]

## Parallel Group B - Core Files [depends:A]

- [x] T002: Create SKILL.md with frontmatter and core workflow [P1] [depends:T001]
- [x] T003: Create REFERENCE.md with detailed naming/style rules [P1] [depends:T001]
- [x] T004: Create EXAMPLES.md with before/after code samples [P1] [depends:T001]

## Sequential - Validation [depends:B]

- [x] T005: Verify SKILL.md is under 500 lines [P1] [depends:T002] (220 lines)
- [x] T006: Verify all reference links work [P2] [depends:T002,T003,T004]
- [x] T007: Update spec.md frontmatter to implementation status [P1] [depends:T002]

---

## Legend

- `[P1/P2/P3]` - Priority level
- `[depends:X,Y]` - Task dependencies
- `[critical:type]` - Requires extra review (schema, api, types, auth)
- `[estimate:S/M/L]` - Size estimate
