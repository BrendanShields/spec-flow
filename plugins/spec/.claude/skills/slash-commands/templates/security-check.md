---
description: Run security audit on recent changes
allowed-tools: Bash(git diff:*), Read, Grep, Glob
model: sonnet
---

Recent changes (vs main branch):
!`git diff main...HEAD --name-only`

File changes:
!`git diff main...HEAD --stat`

Please perform a security audit on these changes, focusing on:

## 1. Input Validation
- Unvalidated user input
- Missing sanitization
- Type coercion issues

## 2. Authentication & Authorization
- Missing auth checks
- Weak authentication
- Authorization bypass potential

## 3. Sensitive Data
- Hardcoded credentials
- API keys in code
- Passwords in plain text
- Logging sensitive data

## 4. Injection Vulnerabilities
- SQL injection risks
- Command injection
- XSS vulnerabilities
- Path traversal

## 5. Dependencies
- Vulnerable packages
- Outdated dependencies
- Known CVEs

## Output Format

```
## Critical Vulnerabilities ⚠️
- [file:line] [Vulnerability Type]
  **Risk**: [Impact]
  **Fix**: [Specific mitigation]

## High Priority
[Same format]

## Medium Priority
[Same format]

## Recommendations
- General security improvements
```

Prioritize by exploitability and impact.
