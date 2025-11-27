# Technical Plan: Hook Creation Best Practices Skill

## Architecture

The skill follows the same progressive disclosure pattern as `creating-skills`:
- SKILL.md: Overview, workflow, quick reference (~150 lines)
- reference.md: Complete event details, all input/output schemas
- templates/: Ready-to-use hook script templates

## Components

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| SKILL.md | Main entry, workflow, event summary | None |
| reference.md | Full event reference, JSON schemas | SKILL.md references |
| templates/basic.sh | Simple hook template | None |
| templates/context-injector.sh | SessionStart template | None |
| templates/file-protector.sh | PreToolUse blocking template | None |

## Design Decisions

### Why Templates Over Scripts

Unlike creating-skills which has a validation script, hooks are more varied. Providing templates users customize is more practical than trying to generate hooks programmatically.

### Event Organization

Group events by common use case:
1. **Tool control**: PreToolUse, PostToolUse, PermissionRequest
2. **Session lifecycle**: SessionStart, SessionEnd
3. **Agent control**: Stop, SubagentStop
4. **User interaction**: UserPromptSubmit, Notification

### Security Emphasis

Hooks execute arbitrary commands - security guidance is critical:
- Input validation patterns
- Path traversal prevention
- Variable quoting
- Timeout configuration

## Implementation Phases

1. **Phase 1**: Core SKILL.md with workflow and event table
2. **Phase 2**: Reference documentation with JSON schemas
3. **Phase 3**: Hook script templates

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Security holes in templates | User systems at risk | Review templates for injection issues |
| Overwhelming detail | Skill too large | Keep SKILL.md lean, details in reference |
| Outdated hook API | Wrong guidance | Link to official docs for latest |
