---
id: 005-hooks-context-injection
title: Hooks Context Injection
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 5
  tasks_done: 5
tags:
  - hooks
  - context
  - sessionstart
archived: true
archived_date: 2025-11-26
---

# Feature: Hooks Context Injection

## Overview

Fix the SessionStart hook to automatically inject minimal Orbit context into Claude's conversation. Currently the hook outputs a simple message that wastes the context injection opportunity. Also fix JSON field parsing in PreToolUse/PostToolUse hooks.

## User Stories

### US1: Automatic Context on Session Start

As a developer using Orbit, I want Claude to automatically know the Orbit state when a session starts so that I don't need to run commands to load context.

**Acceptance Criteria:**
- [ ] AC1.1: SessionStart outputs minimal context JSON
- [ ] AC1.2: Context includes: initialized status, active features, suggested action
- [ ] AC1.3: Context is automatically available to Claude (no manual call needed)

### US2: Correct Hook JSON Parsing

As a developer, I want hooks to correctly parse the JSON input so that file protection and logging work properly.

**Acceptance Criteria:**
- [ ] AC2.1: PreToolUse extracts `tool_input.file_path` correctly
- [ ] AC2.2: PostToolUse extracts `tool_name` correctly
- [ ] AC2.3: Hooks handle missing fields gracefully

## Technical Constraints

- SessionStart stdout is added to context (per Claude Code docs)
- Keep context minimal - just enough for next step decisions
- No breaking changes to existing workflow

## Out of Scope

- Full artifact content loading (too large for context)
- UserPromptSubmit hooks (future consideration)
- Moving archive_feature to skill (separate feature)
