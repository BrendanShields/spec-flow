# Skill Builder Demo: Generated Code Review Skill

## Generated Using skill:build

This example demonstrates the skill-builder in action, creating a code review skill.

### Input to Skill Builder
```
"I need a skill that reviews Python code for common issues and best practices"
```

### Generated Output

```yaml
---
name: python-review
description: Review Python code for issues, best practices, and improvement opportunities. Use when: 1) Code review requested for Python files, 2) Pre-commit quality check needed, 3) Finding code smells or anti-patterns, 4) User mentions "review Python", 5) Refactoring guidance needed. Generates detailed review report with actionable suggestions.
allowed-tools: Read, Grep, Glob
---
```

### Generated SKILL.md Structure

```markdown
# Python Code Reviewer

Analyzes Python code for quality, best practices, and improvement opportunities.

## What This Skill Does

- Checks PEP 8 compliance and style issues
- Identifies common anti-patterns and code smells
- Evaluates function/class complexity
- Suggests refactoring opportunities
- Reviews documentation completeness

## Execution Flow

### Phase 1: Discovery
- Find all Python files in scope
- Parse imports and dependencies
- Build module structure map

### Phase 2: Analysis
- Check each file for issues
- Calculate complexity metrics
- Identify duplicate code

### Phase 3: Reporting
- Prioritize issues by severity
- Generate actionable suggestions
- Create summary metrics
```

### Validation Results

```bash
./validate-skill.sh python-review/

🔍 Validating Claude Code Skill at: python-review/
================================================
✓ SKILL.md found
✓ Name: python-review
✓ Description found (length: 285)
✓ 'Use when:' phrase found
✓ Tool restrictions: Read, Grep, Glob
✓ Closing --- found at line 5
✓ SKILL.md size is optimal (<5KB)
✓ Found 5 trigger scenarios
✓ Good number of trigger scenarios

================================================
✅ SKILL VALID: No errors or warnings found!
```

### Usage Example

```
User: "Review my Python code for issues"