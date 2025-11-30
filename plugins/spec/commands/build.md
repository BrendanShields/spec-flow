---
description: Execute implementation tasks.
---

# Build

Explicitly enters the **Implementation** phase.

1. **Validate Phase** (Mandatory):
   - Check if `tasks.md` exists and is valid.
   - Ensure `spec.md` and `plan.md` are consistent.
2. **Delegate to Agent**:
   - Invoke `task-implementer` to execute tasks.
3. **Update Progress**:
   - Update frontmatter with task completion status.
