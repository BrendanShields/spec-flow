---
id: 003-dotnet-best-practices-skill
title: .NET Best Practices Skill
status: complete
priority: P1
created: 2025-11-27
updated: 2025-11-27
progress:
  tasks_total: 7
  tasks_done: 7
tags:
  - skill
  - dotnet
  - csharp
archived: true
archived_date: 2025-11-26
---

# Feature: .NET Best Practices Skill

## Overview

Create a Claude Code skill that provides .NET/C# best practices guidance when reviewing, writing, or refactoring .NET code. The skill follows Claude's skill best practices: concise main file (<500 lines), progressive disclosure via reference files, and concrete examples.

## User Stories

### US1: Code Review with Best Practices

As a .NET developer, I want Claude to automatically apply .NET best practices when reviewing my C# code so that I receive consistent, standards-compliant feedback.

**Acceptance Criteria:**
- [ ] AC1.1: Skill activates when user asks to review .NET/C# code
- [ ] AC1.2: Provides feedback on naming conventions (PascalCase, camelCase)
- [ ] AC1.3: Identifies async/await anti-patterns
- [ ] AC1.4: Flags exception handling issues
- [ ] AC1.5: Suggests modern C# features where applicable

### US2: Code Generation Guidance

As a .NET developer, I want Claude to follow .NET conventions when generating new C# code so that generated code matches project standards.

**Acceptance Criteria:**
- [ ] AC2.1: Generated code uses proper naming conventions
- [ ] AC2.2: Uses language keywords over system types (string vs String)
- [ ] AC2.3: Applies appropriate access modifiers
- [ ] AC2.4: Uses modern C# syntax (target-typed new, file-scoped namespaces)

### US3: Refactoring Suggestions

As a .NET developer, I want Claude to suggest refactoring opportunities based on .NET best practices so that I can improve code quality.

**Acceptance Criteria:**
- [ ] AC3.1: Identifies LINQ opportunities over manual loops
- [ ] AC3.2: Suggests using statements for disposables
- [ ] AC3.3: Recommends record types for immutable data
- [ ] AC3.4: Identifies nullable reference type improvements

## Technical Constraints

- Skill must be under 500 lines (main SKILL.md)
- Use progressive disclosure with REFERENCE.md and EXAMPLES.md
- Follow gerund naming convention (reviewing-dotnet-code)
- Compatible with .NET 6+ / C# 10+ patterns
- No external dependencies or scripts required

## Out of Scope

- ASP.NET-specific patterns (separate skill)
- Entity Framework patterns (separate skill)
- Blazor/MAUI-specific guidance
- Legacy .NET Framework (<.NET 6) patterns
