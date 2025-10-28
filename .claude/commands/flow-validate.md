# /flow-validate

Validate workflow consistency and artifact alignment.

## Purpose
Ensures all workflow artifacts (spec, plan, tasks) are consistent and aligned, detecting issues like orphaned tasks, missing requirements, or conflicting priorities before they cause problems during implementation.

## Usage
```
/flow-validate                        # Check current feature
/flow-validate --fix                  # Auto-fix issues
/flow-validate --strict               # Strict validation
/flow-validate --phase=planning       # Validate specific phase
/flow-validate --all                  # Validate entire project
```

## Validation Checks

### 1. Artifact Consistency
```
✓ Spec → Plan alignment
  • All user stories in plan
  • Priorities match
  • No missing requirements

✓ Plan → Tasks alignment
  • All plan items have tasks
  • Task estimates present
  • Dependencies valid

✓ Tasks → Implementation
  • File paths exist or are valid
  • No duplicate task IDs
  • Proper task formatting
```

### 2. Workflow Prerequisites
```
✓ Required files present
  • spec.md exists and valid
  • plan.md matches spec
  • tasks.md properly formatted

✓ Dependencies satisfied
  • Parent tasks before children
  • [P] parallel markers valid
  • No circular dependencies

✓ Configuration valid
  • CLAUDE.md settings correct
  • Integration configs work
  • No conflicting options
```

### 3. State Consistency
```
✓ No orphaned elements
  • All tasks map to stories
  • All stories have tasks
  • All files referenced exist

✓ Priority alignment
  • P1 before P2 before P3
  • Critical path identified
  • No priority conflicts

✓ Completeness
  • All {CLARIFY} resolved
  • No TODO markers left
  • All requirements covered
```

## Example Output

### Standard Validation
```
🔍 Validating Workflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature: 001-user-authentication
Files Checked: 3 (spec.md, plan.md, tasks.md)

✅ Artifact Consistency           [PASS]
   • Spec has 3 user stories
   • Plan covers all 3 stories
   • Tasks map to all plan items

✅ Workflow Prerequisites         [PASS]
   • All required files present
   • Dependencies properly ordered
   • Configuration valid

⚠️ State Consistency            [WARN]
   • 2 orphaned tasks found
   • 1 {CLARIFY} marker unresolved
   • Task T007 missing priority

Issues Found: 3
Severity: Warning
Can Continue: Yes

Recommended Actions:
1. Resolve clarification in spec.md line 34
2. Add priority to task T007
3. Remove or map orphaned tasks T011, T012

Run with --fix to auto-correct formatting issues
```

### With Auto-Fix
```
/flow-validate --fix

🔧 Auto-Fixing Issues
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Fixed:
✅ Added missing task IDs (T013, T014)
✅ Corrected task formatting (5 tasks)
✅ Fixed priority markers (3 tasks)
✅ Aligned user story references
✅ Removed duplicate entries

Could Not Fix (Manual Required):
⚠️ Unresolved {CLARIFY} at line 34
⚠️ Missing implementation for US3
⚠️ Circular dependency T005 ↔ T008

Summary:
• Fixed: 8 issues
• Manual Required: 3 issues
• Files Updated: tasks.md, plan.md
```

### Strict Mode
```
/flow-validate --strict

🚨 Strict Validation Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ FAILED: Does not meet strict criteria

Critical Issues:
1. Blueprint not defined (__specification__/architecture-blueprint.md missing)
2. No test coverage requirements in spec
3. Missing error handling scenarios
4. No performance criteria defined
5. Accessibility requirements absent

Blocking Issues:
• Cannot proceed without blueprint
• Test requirements must be specified

To proceed in strict mode:
1. Run flow:blueprint to define architecture
2. Add test requirements to spec.md
3. Define error scenarios
4. Add performance criteria
5. Include accessibility requirements
```

## Validation Rules

### Task Format Validation
```
Valid:   - [ ] T001 [P] [US1] Create user model at src/models/user.ts
Invalid: - [ ] Create user model (missing task ID)
Invalid: - [ ] T001 Create user (missing story reference)
Invalid: - [] T001 [US1] Create (missing checkbox space)
```

### Priority Rules
```
P1 tasks must:
- Be completed first
- Have no P2/P3 dependencies
- Map to P1 user stories

P2 tasks must:
- Wait for P1 completion
- Not block P1 tasks

P3 tasks:
- Optional/nice-to-have
- Can be deferred
```

### Dependency Validation
```
Valid Dependency Chain:
T001 → T002 → T003 (sequential)
T004 [P], T005 [P] (parallel)

Invalid:
T001 → T002 → T001 (circular)
T003 [P] → T003 (self-reference)
```

## Fix Capabilities

### Automatic Fixes
- Missing task IDs
- Task format issues
- Checkbox formatting
- Priority marker format
- Whitespace/indentation
- User story references
- Duplicate removal

### Manual Required
- Unresolved {CLARIFY}
- Missing implementations
- Circular dependencies
- Logic conflicts
- Requirement gaps
- Integration issues

## Options

- `--fix`: Attempt auto-fix of issues
- `--strict`: Enable strict validation
- `--phase=PHASE`: Validate specific phase only
- `--all`: Validate entire project
- `--quiet`: Only show errors
- `--json`: Output as JSON
- `--dry-run`: Show what would be fixed

## Phase-Specific Validation

### Specification Phase
```
/flow-validate --phase=specification

Checks:
• User stories present
• Success criteria defined
• Priorities assigned
• No missing sections
```

### Planning Phase
```
/flow-validate --phase=planning

Checks:
• Technical approach defined
• All stories addressed
• Architecture decisions documented
• Dependencies identified
```

### Implementation Phase
```
/flow-validate --phase=implementation

Checks:
• All tasks have IDs
• File paths valid
• Dependencies resolved
• Progress tracking working
```

## Integration Validation

### JIRA Integration
```
Validates:
• JIRA ticket exists
• Status synchronized
• Fields mapped correctly
• Permissions valid
```

### Git Integration
```
Validates:
• Branch naming correct
• No merge conflicts
• Commit messages follow format
• Remote synchronized
```

## Common Issues & Solutions

### Issue: Orphaned Tasks
```
Problem: Tasks exist without user story
Solution:
1. Map to existing story
2. Create new story
3. Remove if not needed
```

### Issue: Missing Priorities
```
Problem: Tasks lack P1/P2/P3
Solution:
1. Review spec priorities
2. Assign based on story
3. Use --fix to update
```

### Issue: Circular Dependencies
```
Problem: T001 depends on T003 depends on T001
Solution:
1. Review task relationships
2. Break circular reference
3. Reorder tasks
```

## Best Practices

### When to Validate
- After `flow:specify`
- After `flow:plan`
- After `flow:tasks`
- Before `flow:implement`
- After any manual edits

### Validation Workflow
```bash
flow:specify "Feature"
/flow-validate               # Check spec
flow:plan
/flow-validate               # Check plan alignment
flow:tasks
/flow-validate --fix         # Fix task formatting
flow:implement
```

### Continuous Validation
Enable in CLAUDE.md:
```
FLOW_AUTO_VALIDATE=true
FLOW_VALIDATE_ON_SAVE=true
FLOW_STRICT_MODE=false
```

## Error Messages

### No Artifacts Found
```
❌ No workflow artifacts found

Start with:
• flow:init - Initialize project
• flow:specify "Feature" - Create first feature
```

### Validation Blocked
```
🚫 Validation blocked by critical error

Issue: spec.md is empty or corrupted
Action: Restore from backup or recreate

Try:
• /flow-session restore
• flow:specify --update
```

## Performance

- Full validation: < 500ms
- Auto-fix: < 1s
- Strict mode: < 2s
- Large project (50+ features): < 5s

## Related Commands

- `/flow-status` - Check workflow state
- `/flow-debug` - Debug specific issues
- `flow:analyze` - Deep consistency analysis
- `/flow-resume` - Resume after fixing issues