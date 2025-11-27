---
id: 007-creating-hooks-skill
title: Hook Creation Best Practices Skill
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 7
  tasks_done: 7
owner: spec-flow
tags:
  - skills
  - hooks
  - tooling
archived: true
archived_date: 2025-11-26
---

# Feature: Hook Creation Best Practices Skill

## Overview

A skill that guides users through creating Claude Code hooks following documented best practices. Covers all hook events, configuration, input/output formats, and security considerations.

## User Stories

### US1: Create New Hook

As a developer, I want guided help creating hooks so that I configure them correctly the first time.

**Acceptance Criteria:**
- [ ] AC1.1: Guides through hook event selection
- [ ] AC1.2: Generates proper settings.json configuration
- [ ] AC1.3: Creates hook script with proper input handling
- [ ] AC1.4: Includes security best practices

### US2: Understand Hook Events

As a developer, I want to know which hook event to use so that my automation triggers at the right time.

**Acceptance Criteria:**
- [ ] AC2.1: Clear event reference table
- [ ] AC2.2: Examples for each event type
- [ ] AC2.3: Input/output format for each event

## Technical Constraints

- Hooks execute arbitrary shell commands - security critical
- Must handle JSON input from stdin
- Exit codes determine behavior (0=success, 2=blocking)
- Timeout default is 60 seconds
