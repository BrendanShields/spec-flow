# Spec Analyze - Technical Reference

Complete technical documentation for the spec:analyze skill.

## Table of Contents

1. [Validation Algorithms](#validation-algorithms)
2. [Coverage Calculation](#coverage-calculation)
3. [Priority Alignment](#priority-alignment)
4. [Blueprint Compliance](#blueprint-compliance)
5. [Terminology Detection](#terminology-detection)
6. [Report Generation](#report-generation)
7. [Subagent Integration](#subagent-integration)
8. [Configuration Options](#configuration-options)

---

## Validation Algorithms

### Algorithm 1: Forward Coverage

**Purpose**: Ensure all requirements have implementation tasks.

**Input**: spec.md, tasks.md

**Process**:
```
1. Parse spec.md:
   - Extract user stories (## User Story pattern)
   - Extract acceptance criteria (- **AC** pattern)
   - Record priorities (P1/P2/P3)

2. Parse tasks.md:
   - Extract tasks (### Task pattern)
   - Extract story references (→ US1.2 pattern)
   - Record task priorities

3. Build mapping:
   story_to_tasks = {}
   for each story in stories:
       story_to_tasks[story.id] = []
       for each task in tasks:
           if task references story.id:
               story_to_tasks[story.id].append(task)

4. Detect gaps:
   gaps = []
   for story, tasks in story_to_tasks:
       if len(tasks) == 0:
           severity = story.priority == "P1" ? "HIGH" : "MEDIUM"
           gaps.append({
               id: story.id,
               severity: severity,
               issue: f"{story.id} has 0 tasks"
           })

5. Return gaps
```

**Output**: List of stories without tasks, categorized by severity.

---

### Algorithm 2: Backward Coverage

**Purpose**: Find orphaned tasks not mapped to requirements.

**Process**:
```
1. Parse tasks.md:
   - Extract all tasks
   - Extract story references from each task

2. Identify orphans:
   orphans = []
   for task in tasks:
       if task.story_refs is empty:
           orphans.append({
               id: task.id,
               severity: "MEDIUM",
               issue: f"{task.id} not mapped to any story"
           })

3. Check validity:
   for orphan in orphans:
       # Some tasks may be infrastructure/setup
       if orphan.id matches ("setup", "config", "ci"):
           orphan.severity = "LOW"
           orphan.note = "Infrastructure task - OK if intentional"

4. Return orphans
```

**Output**: List of tasks without story references.

---

### Algorithm 3: Priority Alignment

**Purpose**: Ensure task priorities match story priorities.

**Process**:
```
1. Build story-task mapping (from Algorithm 1)

2. Check alignment:
   misalignments = []
   for story, tasks in story_to_tasks:
       if story.priority == "P1":
           # P1 stories MUST have P1 tasks
           p1_tasks = [t for t in tasks if t.priority == "P1"]
           if len(p1_tasks) == 0:
               misalignments.append({
                   id: story.id,
                   severity: "CRITICAL",
                   issue: "P1 story has no P1 tasks",
                   details: {
                       story_priority: "P1",
                       task_priorities: [t.priority for t in tasks]
                   }
               })

       elif story.priority == "P2":
           # P2 stories SHOULD NOT have only P3 tasks
           if all(t.priority == "P3" for t in tasks):
               misalignments.append({
                   id: story.id,
                   severity: "HIGH",
                   issue: "P2 story has only P3 tasks"
               })

3. Return misalignments
```

**Severity Rules**:
- P1 story + no P1 tasks = CRITICAL
- P1 story + some P1 tasks = OK
- P2 story + only P3 tasks = HIGH
- P3 story + any priority = OK

---

### Algorithm 4: Acceptance Criteria Coverage

**Purpose**: Verify all acceptance criteria have implementing tasks.

**Process**:
```
1. Parse spec.md:
   - Extract acceptance criteria per story
   - Format: "- **AC{story}.{num}**: {description}"

2. Parse tasks.md:
   - Extract tasks
   - Look for AC references: "Implements AC1.2", "→ AC3.1"

3. Build AC mapping:
   ac_to_tasks = {}
   for ac in acceptance_criteria:
       ac_to_tasks[ac.id] = []
       for task in tasks:
           if task references ac.id:
               ac_to_tasks[ac.id].append(task)

4. Detect unaddressed:
   unaddressed = []
   for ac, tasks in ac_to_tasks:
       if len(tasks) == 0:
           parent_story = ac.story_id
           severity = parent_story.priority == "P1" ? "HIGH" : "MEDIUM"
           unaddressed.append({
               id: ac.id,
               severity: severity,
               issue: f"{ac.id} not addressed by any task"
           })

5. Return unaddressed
```

**Output**: List of acceptance criteria without tasks.

---

### Algorithm 5: Terminology Consistency

**Purpose**: Detect inconsistent terminology across documents.

**Process**:
```
1. Define concept clusters:
   # Common synonyms in software projects
   clusters = {
       "person": ["user", "account", "member", "customer"],
       "item": ["product", "article", "sku", "item"],
       "purchase": ["order", "transaction", "purchase", "sale"]
   }

2. Scan documents:
   term_usage = {
       "spec.md": {},
       "plan.md": {},
       "tasks.md": {}
   }

   for doc in [spec, plan, tasks]:
       for cluster_name, terms in clusters:
           for term in terms:
               count = count_occurrences(doc, term, case_insensitive=true)
               if count > 0:
                   term_usage[doc][term] = count

3. Detect inconsistencies:
   inconsistencies = []
   for cluster_name, terms in clusters:
       used_terms = []
       for doc in [spec, plan, tasks]:
           for term in terms:
               if term_usage[doc][term] > 0:
                   used_terms.append(term)

       # If >1 term from same cluster used
       if len(set(used_terms)) > 1:
           # Find most common term
           total_usage = {}
           for term in set(used_terms):
               total_usage[term] = sum(
                   term_usage[doc][term]
                   for doc in [spec, plan, tasks]
               )

           primary_term = max(total_usage, key=total_usage.get)

           inconsistencies.append({
               severity: "MEDIUM",
               issue: f"Inconsistent terminology: {'/'.join(set(used_terms))}",
               recommendation: f"Standardize to '{primary_term}'",
               details: term_usage
           })

4. Return inconsistencies
```

**Output**: List of terminology inconsistencies with recommendations.

---

## Coverage Calculation

### Metrics Formulas

**Story Coverage**:
```
stories_with_tasks = count(stories where len(tasks) > 0)
total_stories = count(all stories)
coverage_percent = (stories_with_tasks / total_stories) * 100
```

**Task Coverage** (backward):
```
mapped_tasks = count(tasks where story_refs not empty)
total_tasks = count(all tasks)
coverage_percent = (mapped_tasks / total_tasks) * 100
```

**Acceptance Criteria Coverage**:
```
addressed_criteria = count(AC where len(tasks) > 0)
total_criteria = count(all AC)
coverage_percent = (addressed_criteria / total_criteria) * 100
```

**Priority Alignment**:
```
For each priority P1/P2/P3:
    stories_of_priority = count(stories where priority == P)
    aligned_stories = count(stories where:
        priority == P AND
        any(task.priority == P for task in story.tasks)
    )
    alignment_percent = (aligned_stories / stories_of_priority) * 100
```

---

## Priority Alignment

### Priority Rules

**P1 (Must Have)**:
```yaml
Definition: Core functionality, blocks release
Requirements:
  - MUST have at least one P1 task
  - SHOULD have majority P1 tasks
  - CAN have some P2 tasks for enhancements
  - SHOULD NOT have only P2/P3 tasks

Validation:
  CRITICAL if: No P1 tasks at all
  HIGH if: Less than 50% P1 tasks
  MEDIUM if: 50-70% P1 tasks
  OK if: 70%+ P1 tasks
```

**P2 (Should Have)**:
```yaml
Definition: Important but can defer if needed
Requirements:
  - SHOULD have P2 tasks
  - CAN have mix of P1/P2/P3 tasks
  - SHOULD NOT have only P3 tasks

Validation:
  HIGH if: Only P3 tasks
  MEDIUM if: Mix includes P1 (over-prioritized?)
  OK if: Mostly P2 tasks
```

**P3 (Nice to Have)**:
```yaml
Definition: Optional enhancements
Requirements:
  - CAN have any priority tasks
  - Usually P3 tasks
  - P1/P2 tasks OK if dependency

Validation:
  Always OK: No validation needed
```

---

## Blueprint Compliance

### Compliance Algorithm

**Input**: architecture-blueprint.md, tasks.md

**Process**:
```
1. Parse blueprint:
   principles = {
       "MUST": [],    # Required, blocks implementation
       "SHOULD": [],  # Recommended, warns if missing
       "MAY": []      # Optional, no validation
   }

   for section in blueprint.sections:
       for principle in section.principles:
           if principle.starts_with("MUST"):
               principles["MUST"].append(principle)
           elif principle.starts_with("SHOULD"):
               principles["SHOULD"].append(principle)
           elif principle.starts_with("MAY"):
               principles["MAY"].append(principle)

2. Define validation rules:
   rules = {
       "TDD": {
           "pattern": r"test|spec|tdd",
           "check": lambda tasks: any(
               re.search(pattern, t.description, re.I)
               for t in tasks
           )
       },
       "API Versioning": {
           "pattern": r"version|v\d|api.*version",
           "check": lambda tasks: any(
               re.search(pattern, t.description, re.I)
               for t in tasks
           )
       },
       "Security Review": {
           "pattern": r"security|audit|vulnerability",
           "check": lambda tasks: any(
               re.search(pattern, t.description, re.I)
               for t in tasks
           )
       }
       # Add more rules as needed
   }

3. Validate compliance:
   violations = []
   for principle in principles["MUST"]:
       rule = rules.get(principle.name)
       if rule and not rule.check(tasks):
           violations.append({
               severity: "CRITICAL",
               principle: principle.name,
               issue: f"{principle.name} required but no tasks found",
               fix: f"Add tasks matching: {rule.pattern}"
           })

   for principle in principles["SHOULD"]:
       rule = rules.get(principle.name)
       if rule and not rule.check(tasks):
           violations.append({
               severity: "MEDIUM",
               principle: principle.name,
               issue: f"{principle.name} recommended but missing"
           })

4. Return violations
```

**Output**: List of blueprint violations by severity.

---

## Terminology Detection

### Detection Patterns

**Common Clusters**:
```yaml
Authentication:
  - user
  - account
  - member
  - customer
  - profile

Products:
  - product
  - item
  - article
  - sku
  - listing

Transactions:
  - order
  - purchase
  - transaction
  - sale
  - payment

Storage:
  - database
  - datastore
  - repository
  - storage
  - persistence

API Concepts:
  - endpoint
  - route
  - handler
  - controller
  - resource
```

**Detection Logic**:
```python
def detect_terminology(documents, clusters):
    """
    Scan documents for terminology from clusters.
    Return inconsistencies.
    """
    usage = defaultdict(lambda: defaultdict(int))

    for doc_name, doc_content in documents.items():
        for cluster_name, terms in clusters.items():
            for term in terms:
                # Case-insensitive word boundary search
                pattern = rf'\b{term}\b'
                count = len(re.findall(pattern, doc_content, re.I))
                if count > 0:
                    usage[cluster_name][term] += count

    inconsistencies = []
    for cluster_name, term_counts in usage.items():
        # Multiple terms from same cluster used
        if len(term_counts) > 1:
            # Find primary term (most common)
            primary = max(term_counts, key=term_counts.get)

            inconsistencies.append({
                'cluster': cluster_name,
                'terms_found': list(term_counts.keys()),
                'primary': primary,
                'usage': dict(term_counts),
                'severity': 'MEDIUM',
                'recommendation': f'Standardize to "{primary}"'
            })

    return inconsistencies
```

---

## Report Generation

### Report Structure

**YAML Frontmatter**:
```yaml
---
report_type: spec_analysis
feature_id: 001-user-authentication
feature_name: User Authentication System
timestamp: 2025-10-31T16:00:00Z
status: issues_found | validation_passed
total_issues: 7
critical: 1
high: 2
medium: 3
low: 1
---
```

**Markdown Body**:
```markdown
# Analysis Report: {feature_name}

[Summary section]

[Issues by Severity section]

[Metrics section]

[Detailed Findings section]

[Recommendations section]

[Next Steps section]
```

### Report Templates

**Issue Table Template**:
```markdown
| ID | Category | Issue | Location | Fix |
|----|----------|-------|----------|-----|
| {severity}{num} | {category} | {brief_issue} | {file}:{line} | {fix_suggestion} |
```

**Metrics Template**:
```markdown
### Coverage
- User Stories: {total} ({with_tasks} with tasks = {percent}%)
- Tasks: {total} ({mapped} mapped = {percent}%)
- Acceptance Criteria: {total} ({addressed} addressed = {percent}%)

### Priority Distribution
- P1 Stories: {count} → P1 Tasks: {count} ({aligned}% aligned)
- P2 Stories: {count} → P2 Tasks: {count} ({aligned}% aligned)
- P3 Stories: {count} → P3 Tasks: {count} ({aligned}% aligned)

### Blueprint Compliance
- MUST Principles: {total} ({compliant} compliant = {percent}%)
- SHOULD Principles: {total} ({compliant} compliant = {percent}%)

### Consistency
- Terminology Variations: {count} detected
- Orphaned Tasks: {count}
- Unmapped Stories: {count}
```

---

## Subagent Integration

### spec:analyzer Protocol

**Invocation**:
```markdown
Task spec:analyzer with:
  Input Files:
    - spec.md: {file_path}
    - plan.md: {file_path}
    - tasks.md: {file_path}
    - blueprint.md: {file_path} (optional)

  Analysis Types:
    - coverage: forward and backward
    - priorities: alignment checking
    - acceptance: criteria mapping
    - blueprint: compliance validation
    - terminology: consistency checking

  Output Format:
    - Structured JSON or Markdown
    - Categorized by severity
    - Include recommendations
```

**Expected Output**:
```json
{
  "issues": [
    {
      "id": "C1",
      "severity": "CRITICAL",
      "category": "blueprint",
      "issue": "TDD required, no test tasks",
      "location": "tasks.md",
      "fix": "Add test tasks for each component"
    }
  ],
  "metrics": {
    "coverage": {
      "stories": {"total": 4, "with_tasks": 4, "percent": 100},
      "tasks": {"total": 23, "mapped": 23, "percent": 100}
    },
    "priorities": {
      "P1": {"stories": 2, "aligned": 2, "percent": 100}
    }
  },
  "recommendations": {
    "critical": ["Fix C1 before implementation"],
    "high": [],
    "next_steps": "Validation passed - proceed with spec:implement"
  }
}
```

**Fallback Behavior**:
```markdown
If spec:analyzer unavailable:
1. Perform basic checks:
   - Count stories vs tasks
   - Simple priority comparison
   - Regex-based terminology scan

2. Generate simplified report:
   - Coverage percentages only
   - No deep analysis
   - Note limitations

3. Recommend manual review:
   - "Full analysis unavailable"
   - "Review manually for complex issues"
```

---

## Configuration Options

### User Configuration

**In CLAUDE.md**:
```markdown
# Spec Analyze Configuration

SPEC_ANALYZE_STRICT_MODE=true           # Fail on any HIGH issues
SPEC_ANALYZE_AUTO_FIX=false             # Don't auto-fix issues
SPEC_ANALYZE_TERMINOLOGY_CLUSTERS=user  # Custom terminology
SPEC_ANALYZE_SAVE_REPORTS=true          # Save to .spec-state/
SPEC_ANALYZE_BLUEPRINT_REQUIRED=true    # Enforce blueprint
```

**Custom Terminology**:
```yaml
# .spec/terminology.yml
clusters:
  person:
    - user
    - account
  product:
    - item
    - sku
```

### Runtime Options

**Flags**:
```bash
spec:analyze --strict          # Fail on any issues
spec:analyze --skip-blueprint  # Skip blueprint checking
spec:analyze --coverage-only   # Only coverage analysis
spec:analyze --save-report     # Save detailed report
spec:analyze --verbose         # Show all details
```

---

## Performance Considerations

### Token Efficiency

**Optimization strategies**:
1. Load artifacts on-demand (don't load all upfront)
2. Use Grep for pattern matching (faster than Read + parse)
3. Cache parsed structures (don't re-parse)
4. Progressive disclosure (basic → detailed)

**Token estimates**:
- SKILL.md core: ~1,200 tokens
- EXAMPLES.md: ~2,500 tokens
- REFERENCE.md: ~2,000 tokens
- Total skill: ~5,700 tokens
- Typical artifacts: ~3,000 tokens (spec + plan + tasks)
- **Total activation cost**: ~8,700 tokens

### Caching Strategy

```markdown
1. Parse artifacts once:
   - Store in memory during analysis
   - Don't re-read files

2. Reuse patterns:
   - Compile regex once
   - Cache cluster lookups

3. Incremental analysis:
   - If only spec changed, skip plan validation
   - If only tasks changed, skip spec validation
```

---

## Error Handling

### Common Errors

**Missing Files**:
```python
if not exists("features/{id}/spec.md"):
    error("Specification not found")
    suggest("Run: spec:generate first")
    exit(1)

if not exists("features/{id}/plan.md"):
    error("Plan not found")
    suggest("Run: spec:plan first")
    exit(1)
```

**Parse Failures**:
```python
try:
    stories = parse_spec(spec_content)
except ParseError as e:
    error(f"Invalid spec format: {e}")
    suggest("Check YAML frontmatter")
    suggest("Verify user story format")
    exit(1)
```

**Analyzer Unavailable**:
```python
if not available("spec:analyzer"):
    warn("Deep analysis unavailable")
    warn("Using basic validation")
    # Continue with fallback
```

---

## Related Documentation

- **SKILL.md**: Core skill definition
- **EXAMPLES.md**: Concrete usage scenarios
- `shared/workflow-patterns.md`: Validation patterns
- `shared/state-management.md`: State file access
- `spec:analyzer/SKILL.md`: Subagent details

---

**Last Updated**: 2025-10-31
**Token Size**: ~2,000 tokens
**Version**: 1.0.0
