---
id: 009-creating-agents-skill
title: Agent Creation Best Practices Skill
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
  - agents
  - tooling
archived: true
archived_date: 2025-11-26
---

# Feature: Agent Creation Best Practices Skill

## Overview

A skill that guides users through creating Claude Code subagents following documented best practices. Covers agent file format, tool configuration, model selection, and effective system prompts.

## User Stories

### US1: Create New Agent

As a developer, I want guided help creating subagents so that I configure them correctly.

**Acceptance Criteria:**
- [ ] AC1.1: Guides through agent purpose definition
- [ ] AC1.2: Generates proper agent file with frontmatter
- [ ] AC1.3: Helps select appropriate tools
- [ ] AC1.4: Suggests optimal model for task type
- [ ] AC1.5: Creates effective system prompt

### US2: Understand Agent Types

As a developer, I want to know when to use different agent types so that I delegate tasks effectively.

**Acceptance Criteria:**
- [ ] AC2.1: Documents built-in agents (general-purpose, plan, explore)
- [ ] AC2.2: Provides comparison table for agent selection
- [ ] AC2.3: Examples of custom agents for common tasks

## Technical Constraints

- Agent names: lowercase with hyphens
- Files stored in `.claude/agents/` or `~/.claude/agents/`
- Frontmatter required: name, description
- Tools should be minimal (principle of least privilege)

## Out of Scope

- Multi-agent orchestration patterns (future feature)
- Agent performance optimization
- Custom model training
