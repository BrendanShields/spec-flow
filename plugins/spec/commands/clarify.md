---
description: Resolve clarification tags in the specification.
---

# Clarify

Explicitly enters the **Clarification** phase.

1. Scans `spec.md` for `[CLARIFY]` tags.
2. Invokes `managing-workflow` skill to resolve questions with the user.
3. Updates `spec.md` with answers.
