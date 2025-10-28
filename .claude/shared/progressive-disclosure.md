# Progressive Disclosure Template

## Core Instructions (Always Loaded - ~100 tokens)

Execute the primary task with these minimal instructions:
1. Check prerequisites using @check-prereq
2. Execute main function
3. Update progress using @update-task
4. Return success/failure

## Extended Details (Load on Demand - ~200 tokens)

### If user needs specifics
@load-details [topic]

### If error occurs
@load-error-handling

### If validation needed
@load-validation-rules

## Reference Library (Lazy Load - ~300 tokens)

### Available References
- @ref:file-operations
- @ref:git-workflow
- @ref:validation-patterns
- @ref:error-recovery
- @ref:progress-tracking

Load only when specifically needed for the task at hand.