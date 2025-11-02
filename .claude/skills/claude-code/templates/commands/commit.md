---
description: Generate conventional commit message from current changes
allowed-tools: Bash(git status:*), Bash(git diff:*)
model: sonnet
---

Current git status:
!`git status -s`

Staged changes:
!`git diff --cached --stat`

Detailed diff:
!`git diff --cached`

Please analyze these changes and generate a concise commit message following conventional commits format:

**Format**: `type(scope): description`

**Types**: feat, fix, docs, style, refactor, test, chore

**Guidelines**:
- Focus on WHAT changed and WHY, not HOW
- Use imperative mood ("add" not "added")
- Keep first line under 72 characters
- Include body if changes are complex
- Reference issues if applicable

Provide the commit message ready to use with `git commit -m`.
