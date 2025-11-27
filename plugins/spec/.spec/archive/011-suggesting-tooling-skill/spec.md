---
id: 011-suggesting-tooling-skill
title: Suggesting Tooling Skill
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 6
  tasks_done: 6
owner: spec-flow
tags:
  - skills
  - agents
  - analysis
  - tooling
archived: true
archived_date: 2025-11-26
---

# Feature: Suggesting Tooling Skill

## Overview

A skill that analyzes a codebase and suggests custom Claude Code skills and subagents that would improve the development workflow. It examines project structure, common patterns, pain points, and repetitive tasks to recommend automation opportunities. Uses `creating-skills` and `creating-agents` skills to generate the suggested tooling.

## User Stories

### US1: Analyze Codebase for Tooling Opportunities

As a developer, I want my codebase analyzed for automation opportunities so that I can identify where custom skills/agents would help.

**Acceptance Criteria:**
- [ ] AC1.1: Scans project structure (languages, frameworks, build tools)
- [ ] AC1.2: Identifies repetitive patterns in code
- [ ] AC1.3: Detects common workflows (testing, deployment, review)
- [ ] AC1.4: Analyzes existing .claude/ configuration
- [ ] AC1.5: Reports findings with actionable suggestions

### US2: Suggest Custom Skills

As a developer, I want skill suggestions based on my codebase so that I automate repetitive tasks.

**Acceptance Criteria:**
- [ ] AC2.1: Matches project patterns to skill templates
- [ ] AC2.2: Prioritizes suggestions by impact (P1/P2/P3)
- [ ] AC2.3: Provides rationale for each suggestion
- [ ] AC2.4: Integrates with creating-skills skill to generate

### US3: Suggest Custom Agents

As a developer, I want agent suggestions for complex tasks so that I delegate multi-step workflows.

**Acceptance Criteria:**
- [ ] AC3.1: Identifies tasks suited for autonomous agents
- [ ] AC3.2: Suggests tool configurations for each agent
- [ ] AC3.3: Provides rationale for agent vs skill decision
- [ ] AC3.4: Integrates with creating-agents skill to generate

### US4: Generate Suggested Tooling

As a developer, I want to generate suggested skills/agents with one command so that setup is easy.

**Acceptance Criteria:**
- [ ] AC4.1: Presents suggestions for user approval
- [ ] AC4.2: Generates approved skills using creating-skills
- [ ] AC4.3: Generates approved agents using creating-agents
- [ ] AC4.4: Reports what was created

## Technical Constraints

- Must work with any codebase (language-agnostic analysis)
- Uses existing creating-skills and creating-agents skills
- Suggestions based on detected patterns, not guesswork
- Does not modify code, only creates .claude/ artifacts

## Out of Scope

- Automatic skill/agent creation without approval
- Performance optimization suggestions
- Security vulnerability scanning
- Dependency analysis
