---
description: Review a pull request with GitHub CLI
argument-hint: <pr-number>
allowed-tools: Bash(gh pr:*)
model: sonnet
---

Fetching PR #$1 details:
!`gh pr view $1`

PR diff:
!`gh pr diff $1 | head -500`

Please review this pull request focusing on:

1. **Code Quality**
   - Readability and maintainability
   - Adherence to best practices
   - Code organization

2. **Security**
   - Input validation
   - Authentication/authorization
   - Sensitive data handling

3. **Testing**
   - Test coverage for new code
   - Edge cases handled
   - Test quality

4. **Breaking Changes**
   - API compatibility
   - Migration requirements

Provide specific feedback with file:line references and code examples.
