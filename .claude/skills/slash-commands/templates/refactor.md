---
description: Refactor a file for better structure and maintainability
argument-hint: <file-path>
allowed-tools: Read, Edit, Grep
model: sonnet
---

Current implementation:
@$1

Please refactor this code to improve:

## 1. Readability
- Clear variable and function names
- Logical code organization
- Reduced complexity

## 2. Maintainability
- DRY principle (remove duplication)
- Single responsibility
- Clear separation of concerns

## 3. Code Quality
- Proper error handling
- Type safety (if TypeScript)
- Consistent patterns

## 4. Performance
- Algorithm efficiency
- Unnecessary operations removed
- Resource usage optimized

## Guidelines

- **Preserve behavior**: Don't change functionality
- **Incremental changes**: Show before/after for each refactoring
- **Test compatibility**: Maintain existing test compatibility
- **Document changes**: Explain why each refactoring improves the code

## Output Format

```
### Refactoring: [Name]

**Before**:
[Original code]

**After**:
[Refactored code]

**Benefits**:
- [Improvement 1]
- [Improvement 2]
```

Focus on high-impact improvements that enhance long-term maintainability.
