# Skill Builder: Examples

## Example 1: Create Data Processing Skill

### User Request
"I need a skill that processes CSV files and generates summary reports"

### Execution

1. **Gather requirements**:
   - Capability: CSV processing and analysis
   - Triggers: ["CSV", "spreadsheet", "data analysis", "pivot table", "summary"]
   - Tools: Read, Write, Bash
   - Complexity: standard

2. **Generate description**:
   ```yaml
   description: Process CSV files, analyze data, and generate summary reports. Use when: 1) User mentions CSV or spreadsheet files, 2) Data analysis or transformation needed, 3) Creating pivot tables or summaries, 4) Converting between data formats, 5) Statistical analysis requested. Outputs formatted reports with visualizations.
   ```

3. **Create structure**:
   ```
   csv-processor/
   ├── SKILL.md (1.2k tokens)
   ├── EXAMPLES.md
   ├── REFERENCE.md
   └── scripts/
       └── analyze.py
   ```

### Output
✅ Skill created: csv-processor
- Token efficiency: 1.2k tokens (core)
- Discovery strength: 9/10
- Activation tested on 10 phrases

---

## Example 2: Uplift Existing Verbose Skill

### User Request
"Improve my documentation-generator skill - it's using too many tokens"

### Analysis
Current skill: 4.8k tokens, everything inline, weak description

### Execution

1. **Analyze current implementation**:
   ```bash
   wc -w SKILL.md  # 4832 words
   grep "Use when:" SKILL.md  # Not found - weak discovery
   ```

2. **Extract and modularize**:
   - Moved 15 examples → EXAMPLES.md
   - Moved API docs → REFERENCE.md
   - Converted templates → files
   - Replaced inline scripts → executable

3. **Optimize description**:
   ```yaml
   # Before (82 chars, vague):
   description: Generates documentation for projects

   # After (512 chars, specific):
   description: Generate comprehensive documentation from code analysis. Use when: 1) User requests documentation generation, 2) README or docs update needed, 3) API documentation requested, 4) Code comments need extraction, 5) Documentation audit required. Creates markdown docs with examples.
   ```

### Result
✅ Skill uplifted: documentation-generator
- Token reduction: 4.8k → 1.3k (73% reduction)
- Discovery improvement: 3/10 → 9/10
- Modular structure: 4 separate files

---

## Example 3: Create Minimal POC Skill

### User Request
"Quick skill to format JSON files"

### Execution

1. **Minimal template selection**:
   ```yaml
   name: json-formatter
   description: Format and validate JSON files. Use when: 1) User mentions JSON formatting, 2) Pretty-print JSON needed, 3) JSON validation requested, 4) Minify JSON files, 5) JSON syntax errors need fixing. Outputs formatted JSON.
   ```

2. **Simple SKILL.md** (500 tokens):
   ```markdown
   # JSON Formatter

   Formats and validates JSON files.

   ## Workflow
   1. Read JSON file
   2. Validate syntax
   3. Apply formatting (indent/minify)
   4. Write result

   ## Usage
   `cat file.json | python -m json.tool`
   ```

### Output
✅ Minimal skill created: json-formatter
- Ultra-light: 500 tokens
- Single-purpose focus
- No unnecessary resources

---

## Example 4: Complex Enterprise Skill

### User Request
"Create a skill for automated code review with security scanning"

### Execution

1. **Comprehensive template**:
   - Multiple phases (analyze, scan, report)
   - External tool integration
   - Configurable rules
   - Team collaboration features

2. **Modular architecture**:
   ```
   code-reviewer/
   ├── SKILL.md (1.8k tokens - workflow only)
   ├── EXAMPLES.md (8 scenarios)
   ├── REFERENCE.md (security rules)
   ├── templates/
   │   ├── review-template.md
   │   └── security-report.md
   ├── scripts/
   │   ├── scan.sh
   │   └── analyze.py
   └── configs/
       └── rules.yaml
   ```

3. **Rich discovery description**:
   ```yaml
   description: Automated code review with security and quality analysis. Use when: 1) Code review requested or PR created, 2) Security audit needed, 3) Code quality assessment required, 4) Technical debt analysis, 5) Compliance check needed. Generates detailed review reports with actionable recommendations.
   ```

### Output
✅ Enterprise skill created: code-reviewer
- Core: 1.8k tokens (workflow focused)
- Resources: 15+ files (loaded as needed)
- Discovery: 10/10 (comprehensive triggers)

---

## Example 5: Pattern-Based Skill Creation

### User Request
"I want to create multiple similar skills for different file types"

### Execution

Using pattern templates to generate consistent skills:

1. **Base pattern** (file-processor):
   ```yaml
   name: {format}-processor
   description: Process {FORMAT} files with validation and transformation. Use when: 1) User mentions {FORMAT} files, 2) {FORMAT} validation needed, 3) Converting from/to {FORMAT}, 4) {FORMAT} analysis requested, 5) Batch {FORMAT} processing. Outputs processed {FORMAT} with reports.
   ```

2. **Generated skills**:
   - xml-processor
   - yaml-processor
   - markdown-processor
   - toml-processor

3. **Shared resources**:
   ```
   shared/
   ├── base-processor.md
   ├── validation-rules/
   └── scripts/
       └── process.sh
   ```

### Output
✅ Pattern-based skills created: 4 processors
- Consistent structure
- Shared resources (no duplication)
- Each under 1k tokens