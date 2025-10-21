# Test Example: Using Skill Builder

## Example Request

```
User: "I need a skill that can analyze Python code complexity and suggest refactoring"
```

## Skill Builder Response

### Step 1: Requirements Gathering

```
I'll help you create a Python code complexity analyzer skill. Let me ask a few questions:

1. What complexity metrics should it check?
   → Cyclomatic complexity, cognitive complexity, lines of code

2. Should it auto-fix issues or just report?
   → Report with suggestions

3. What's the threshold for "complex" code?
   → Cyclomatic > 10, Cognitive > 15, LOC > 50
```

### Step 2: Generated Skill

#### SKILL.md
```yaml
---
name: python-complexity
description: Analyze Python code complexity metrics and suggest refactoring opportunities. Use when: 1) Code review for complexity, 2) Refactoring needed, 3) Python file analysis requested, 4) User mentions "complexity" or "refactor", 5) Code quality assessment. Generates complexity report with actionable refactoring suggestions.
allowed-tools: Read, Grep, Glob
---

# Python Complexity Analyzer

Analyzes Python code for complexity metrics and provides refactoring suggestions.

## What This Skill Does

- Calculates cyclomatic complexity per function
- Measures cognitive complexity
- Counts lines of code and nesting depth
- Identifies code smells
- Suggests specific refactoring strategies

## Execution Flow

### Phase 1: Discovery
1. Find all Python files
2. Parse AST for each file
3. Build complexity map

### Phase 2: Analysis
1. Calculate complexity metrics
2. Identify hotspots
3. Detect patterns

### Phase 3: Reporting
1. Rank by complexity
2. Generate suggestions
3. Create report
```

#### Generated Test Phrases

✅ **Should Activate**:
- "Analyze this Python code for complexity"
- "Which functions need refactoring?"
- "Check code complexity"
- "Find complex Python functions"

❌ **Should NOT Activate**:
- "Run Python code" (different intent)
- "Write Python function" (generation, not analysis)
- "Debug Python error" (debugging, not complexity)

### Step 3: Validation Results

```bash
./validate-skill.sh python-complexity/

🔍 Validating Claude Code Skill at: python-complexity/
================================================
✓ SKILL.md found

Checking YAML frontmatter...
----------------------------
✓ Opening --- found
✓ Name: python-complexity
✓ Description found (length: 342)
✓ 'Use when:' phrase found
✓ Tool restrictions: Read, Grep, Glob
✓ Closing --- found at line 5

Checking file structure...
-------------------------
✓ examples.md found
✓ reference.md found
✓ README.md found

Context usage analysis...
------------------------
SKILL.md size: 1847 bytes
✓ SKILL.md size is optimal (<5KB)

Discovery test phrases...
------------------------
Found 5 trigger scenarios
✓ Good number of trigger scenarios

================================================
Validation Summary
================================================
✅ SKILL VALID: No errors or warnings found!
```

## Result

The Skill Builder successfully created a well-structured, discoverable skill that:
- ✅ Has clear activation triggers
- ✅ Uses minimal required tools
- ✅ Implements progressive disclosure
- ✅ Includes comprehensive documentation
- ✅ Passes all validation checks

## Usage

```bash
# Install the generated skill
cp -r python-complexity ~/.claude/skills/

# Test it
"Analyze the complexity of my Python project"

# The skill activates and provides:
📊 Python Complexity Analysis
============================
High Complexity Functions:
1. process_data() - Cyclomatic: 15, Cognitive: 22
   Suggestion: Extract nested conditions into separate functions

2. validate_input() - Cyclomatic: 12, Cognitive: 18
   Suggestion: Use early returns to reduce nesting
...
```