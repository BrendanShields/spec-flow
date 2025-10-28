# Common Patterns Library

## File Operations

### Read and Validate
Instead of repeating file reading instructions, use:
```
@read-validate [filename]
```
This handles: existence check, reading, format validation, error handling.

### Safe Write
Instead of repeating write instructions, use:
```
@safe-write [filename] [content]
```
This handles: backup creation, writing, verification, rollback on error.

## Path Management

### Get Feature Directory
```
@get-feature-dir
```
Returns current feature directory from session state.

### Update Paths
```
@update-paths [old] [new]
```
Updates all path references in a consistent way.

## Validation Patterns

### Check Prerequisites
```
@check-prereq [phase]
```
Validates that previous phases are complete.

### Validate Output
```
@validate-output [artifact]
```
Checks that generated artifact meets quality standards.

## Progress Tracking

### Update Task Status
```
@update-task [task-id] [status]
```
Updates task checkbox and logs progress.

### Get Progress
```
@get-progress
```
Returns current feature progress percentage.

## Error Handling

### Safe Execute
```
@safe-exec [command]
```
Executes with error handling and rollback.

### Log Error
```
@log-error [context] [error]
```
Logs error with context for debugging.

## Git Operations

### Incremental Commit
```
@commit-task [task-id] [message]
```
Creates properly formatted commit for task.

### Check Git Status
```
@git-check
```
Ensures clean working directory.