---
description: Run tests and analyze failures
allowed-tools: Bash(npm test:*), Bash(npm run:*), Read, Grep
model: sonnet
---

Running test suite:
!`npm test 2>&1`

Please analyze any test failures and provide:

1. **Root Cause Analysis**
   - Why each test is failing
   - Specific file:line references

2. **Proposed Fixes**
   - Concrete code changes
   - Whether to fix test or implementation

3. **Additional Tests Needed**
   - Coverage gaps identified
   - Edge cases to add

Format each failure as:

```
### ❌ Test: [name]
**Error**: [error message]
**Cause**: [root cause]
**Fix**: [code example]
```

Focus on getting tests to pass while maintaining correctness.
