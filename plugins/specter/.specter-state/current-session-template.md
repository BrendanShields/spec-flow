# Current Session State

**Session ID**: sess_{uuid}
**Created**: {timestamp}
**Updated**: {timestamp}
**Claude Conversation**: {conversation_id}

## Active Work

### Current Feature
- **Feature ID**: {feature_id}
- **Feature Name**: {feature_name}
- **Phase**: {phase} (specification|planning|implementation|complete)
- **Started**: {timestamp}
- **JIRA**: {jira_id} (if applicable)

### Current Task
- **Task ID**: {task_id}
- **Description**: {task_description}
- **User Story**: {story_id}
- **Status**: {in_progress|blocked|complete}
- **Progress**: {current}/{total} tasks

## Workflow Progress

### Completed Phases
- [x] spec:init - Project initialization ({timestamp})
- [x] spec:blueprint - Architecture defined ({timestamp})
- [x] spec:generate - Feature specification ({timestamp})
- [x] spec:clarify - {N} questions resolved ({timestamp})
- [x] spec:plan - Technical design ({timestamp})
- [x] spec:tasks - {N} tasks generated ({timestamp})
- [ ] spec:implement - {current}/{total} tasks ({status})
- [ ] spec:checklist - Quality validation
- [ ] spec:metrics - Performance baseline

### Task Completion
```
Phase 1: Foundation [3/3] ✅
- [x] T001 [US1] Database schema
- [x] T002 [US1] Core models
- [x] T003 [US1] Migrations

Phase 2: Core Features [1/5] 🔄
- [x] T004 [US2] User service
- [ ] T005 [US2] Auth middleware ← CURRENT
- [ ] T006 [US2] JWT handling
- [ ] T007 [P] [US2] Rate limiting
- [ ] T008 [P] [US2] Session management

Phase 3: API Layer [0/4] ⏳
- [ ] T009 [US3] REST endpoints
- [ ] T010 [US3] OpenAPI spec
- [ ] T011 [US3] Validation
- [ ] T012 [US3] Error handling
```

## Configuration State

### Spec Settings
```
SPECTER_ATLASSIAN_SYNC={enabled|disabled}
SPECTER_JIRA_PROJECT_KEY={key}
SPECTER_CONFLUENCE_ROOT_PAGE_ID={id}
SPECTER_BRANCH_PREPEND_JIRA={true|false}
SPECTER_REQUIRE_BLUEPRINT={true|false}
SPECTER_REQUIRE_ANALYSIS={true|false}
SPECTER_AUTO_VALIDATE={true|false}
```

### Active Integrations
- **JIRA**: {status} (Last sync: {timestamp})
- **Confluence**: {status} (Page: {url})
- **GitHub**: {status} (Branch: {branch})
- **MCP Servers**: {list}

## Context Information

### Git State
- **Branch**: {branch_name}
- **Base Branch**: {main|master|develop}
- **Last Commit**: {hash} "{message}"
- **Uncommitted Changes**: {count} files
- **Behind Remote**: {count} commits

### Recent Commands
1. {timestamp} - {command} ({status})
2. {timestamp} - {command} ({status})
3. {timestamp} - {command} ({status})
4. {timestamp} - {command} ({status})
5. {timestamp} - {command} ({status})

### Working Context
- **Working Directory**: {path}
- **Feature Directory**: {path}
- **Last Modified Files**:
  - {file1} ({timestamp})
  - {file2} ({timestamp})
  - {file3} ({timestamp})

## Pending Items

### Decisions Required
1. **{Decision 1}**
   - Context: {context}
   - Options: {options}
   - Deadline: {date}

2. **{Decision 2}**
   - Context: {context}
   - Options: {options}
   - Deadline: {date}

### Blockers
1. **{Blocker 1}**
   - Type: {technical|requirement|dependency}
   - Description: {description}
   - Action Required: {action}

### Clarifications Pending
1. {CLARIFY: question from spec.md}
2. {CLARIFY: question from plan.md}

## Error State

### Recent Errors
```
{timestamp} - {error_type}
Message: {error_message}
Context: {context}
Recovery: {suggested_action}
```

### Failed Validations
- [ ] {validation_1}
- [ ] {validation_2}

## Session Metadata

### Performance Metrics
- **Session Duration**: {duration}
- **Tasks Completed**: {count}
- **Velocity**: {tasks_per_hour}
- **Error Rate**: {percentage}

### Checkpoints
- **Last Checkpoint**: {timestamp} ({name})
- **Auto-save**: {enabled|disabled}
- **Checkpoint Count**: {count}

### Notes
```
{free-form notes about session}
{important reminders}
{context for next session}
```

---

## Quick Resume Commands

Based on current state, resume with:
```bash
# Primary action
{primary_command}

# Alternative actions
{alt_command_1}
{alt_command_2}

# Check status
/spec status
```

## Session History Reference

Previous sessions for this feature:
- {date} - {duration} - {tasks_completed}
- {date} - {duration} - {tasks_completed}
- {date} - {duration} - {tasks_completed}

Total time on feature: {total_duration}
Total tasks completed: {total_tasks}/{total_planned}