# Phase 5: Track Progress

Maintain specifications and monitor development progress throughout the lifecycle.

## Purpose

Ongoing workflow support for updating specifications, tracking metrics, and automating complete workflows.

## Supporting Tools (All Contextual)

### update/ 🔧 MODIFY SPECS
**Purpose**: Update existing specifications with changes
**Invocation**: `/spec update "Changes description"`
**When**: Requirements change, add/remove user stories, priority shifts
**Output**: Updated `spec.md`, propagated changes to `plan.md` and `tasks.md`

**Usage**: Run anytime requirements change - creates migration plan for breaking changes

### metrics/ 🔧 PROGRESS TRACKING
**Purpose**: View development analytics and progress
**Invocation**: `/spec metrics`
**When**: Need progress report, sprint planning, process optimization
**Output**: Analytics dashboard, CSV/JSON exports

**Usage**: Run anytime to check progress - no side effects, read-only analysis

### orchestrate/ 🔧 FULL AUTOMATION
**Purpose**: Automate complete workflow from spec to implementation
**Invocation**: `/spec orchestrate`
**When**: Want full automation, quick prototyping
**Output**: Complete feature (all artifacts + implementation)

**Usage**: Alternative to manual workflow - runs generate→clarify→plan→tasks→implement automatically

## Workflow Patterns

**Requirements Change**:
```
update/ 🔧 → analyze/ 🔧 → tasks/ --update ⭐ → implement/ --continue ⭐
```

**Progress Check**:
```
metrics/ 🔧 (view analytics anytime)
```

**Full Automation**:
```
orchestrate/ 🔧 (runs all phases: generate→plan→tasks→implement)
```

**Interrupted Automation**:
```
orchestrate/ 🔧 → [Interruption] → orchestrate/ --resume 🔧
```

## Continuous Use

Phase 5 is ongoing throughout project:
- ✅ Specs kept current with update/ 🔧
- ✅ Progress tracked with metrics/ 🔧
- ✅ New features automated with orchestrate/ 🔧
- ✅ Metrics inform process improvements

## Navigation

**Functions in this phase**:
- [update/](./update/) - Modify specifications 🔧
- [metrics/](./metrics/) - View progress 🔧
- [orchestrate/](./orchestrate/) - Automate workflow 🔧

**Previous phase**: [Phase 4: Build Feature](../4-build/)  
**Return to**: Phase 2 for new features

---

⭐ = Core workflow (required)  
🔧 = Supporting tool (contextual)

**Note**: Phase 5 has no CORE functions - all tools are contextual  
Use throughout development lifecycle as needed
