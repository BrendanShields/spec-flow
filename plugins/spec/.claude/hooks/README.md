# Spec Hooks Documentation

Claude Code hooks that enhance the Spec plugin with automated workflows, quality checks, and integrations.

## Overview

Spec uses **11 specialized hooks** that execute at different lifecycle points to provide:
- **Workflow automation** (intent detection, prerequisite validation, workflow tracking)
- **Quality enhancement** (code formatting, metrics tracking)
- **Session management** (save/restore state)
- **Integration support** (JIRA/Confluence sync via pre/post-specify hooks)

## Hook Inventory

| Hook | Type | Triggers | Purpose | Blocking? |
|------|------|----------|---------|-----------|
| **session-init.js** | Session start | SessionStart | Initialize config, validate setup, load state | No |
| **restore-session.js** | Session start | SessionStart | Restores previous workflow state | No |
| **detect-intent.js** | Pre-execution | User input | Suggests Spec skills based on prompt | No |
| **validate-prerequisites.js** | Pre-execution | Before Spec skills | Checks required artifacts exist | **Yes** (exits 1) |
| **pre-specify.js** | Pre-skill | Before spec:generate | Prepares environment, loads templates | No |
| **post-specify.js** | Post-skill | After spec:generate | Triggers clarify, syncs JIRA/Confluence | No |
| **format-code.js** | Post-tool | After Write/Edit | Auto-formats code files | No |
| **track-metrics.js** | Post-tool | After file operations | Tracks AI vs human code metrics | No |
| **update-workflow-status.js** | Post-skill | After any Spec skill | Updates .spec/.state.json | No |
| **aggregate-results.js** | Subagent stop | SubagentStop | Aggregates results from parallel execution | No |
| **save-session.js** | Session end | On session end | Saves workflow state | No |

## Execution Flow

```
Session Start
  ├─> session-init.js (initialize config, validate setup)
  └─> restore-session.js (loads previous state)

User Input
  └─> detect-intent.js (suggests skills)

Before Spec Skill (e.g., spec:plan)
  └─> validate-prerequisites.js (checks spec.md exists) [BLOCKS if missing]
  └─> pre-specify.js (if spec:generate)

Spec Skill Executes
  └─> [Skill runs...]
      └─> SubagentStop → aggregate-results.js (if parallel execution)

After Spec Skill
  └─> post-specify.js (if spec:generate - triggers clarify, JIRA sync)
  └─> update-workflow-status.js (updates progress)

After Write/Edit Tools
  └─> format-code.js (auto-formats)
  └─> track-metrics.js (tracks code generation)

Session End
  └─> save-session.js (saves state for next time)
```

## Hook Details

### 1. detect-intent.js

**Purpose**: Analyzes user prompts to suggest appropriate Spec skills

**Features**:
- Pattern matching against 60+ intent patterns
- Context-aware (detects JIRA URLs, user story format)
- Workflow continuation hints (suggests next step)
- Confidence scoring (high/medium/low/none)

**Example**:
```
User: "I need to implement a new login feature"
Hook: 🎯 Detected intent: spec:generate
      Consider using: spec:generate
```

**Configuration**: None

---

### 2. validate-prerequisites.js

**Purpose**: Ensures workflow prerequisites are met before skill execution

**Features**:
- Required file validation (blocks execution if missing)
- Optional file warnings (suggests but doesn't block)
- anyOf validation (requires at least one from a set)
- Glob pattern support (features/*/spec.md)

**Example**:
```bash
# User runs: spec:plan
# Hook checks: spec.md exists? ✓
# Result: Proceeds

# User runs: spec:plan (but no spec.md)
# Hook checks: spec.md exists? ✗
# Result: BLOCKS with error + suggestion to run spec:generate first
```

**Configuration**:
Edit `PREREQUISITES` object in validate-prerequisites.js to add/modify rules.

---

### 3. pre-specify.js

**Purpose**: Prepares environment before specification generation

**Features**:
- Project type detection (greenfield vs brownfield)
- Domain detection (e-commerce, SaaS, API, social, analytics, CMS, fintech)
- Template loading (domain-specific requirements, user stories)
- Research task queuing
- AI inference level adjustment

**Example**:
```
User: spec:generate "Build an e-commerce checkout flow"
Hook: ✓ Auto-detected project type: greenfield
      ✓ Detected domain: e-commerce. Loading specialized templates.
      ✓ Queued 3 research tasks for AI analysis
```

**Configuration**: None (auto-detects)

---

### 4. post-specify.js

**Purpose**: Executes follow-up actions after specification creation

**Features**:
- Clarification detection ([NEEDS CLARIFICATION] markers)
- Auto-triggers spec:clarify if needed
- JIRA sync (creates/updates stories)
- Confluence publishing (auto-publishes specs)
- Quality assessment (completeness, clarity, testability scores)
- Telemetry tracking

**Example**:
```
After spec:generate completes:
Hook: ✓ Specification created with 3 clarifications needed. Auto-triggering spec:clarify...
      ✓ Synced with JIRA: PROJ-123
      ✓ Published to Confluence: https://company.atlassian.net/wiki/...
      ⚠ Specification quality score: 72%. Consider improving completeness and clarity.
```

**Configuration**: See CLAUDE.md for JIRA/Confluence settings

---

### 5. format-code.js

**Purpose**: Auto-formats code files after Write/Edit operations

**Features**:
- Multi-language support (JS/TS, Python, Go, Rust, Ruby, Java, C/C++, YAML, MD)
- Automatic formatter detection
- Graceful degradation if formatter not installed
- **Security**: Properly quotes shell variables

**Supported Formatters**:
- **JavaScript/TypeScript**: Prettier
- **Python**: Black
- **Go**: gofmt
- **Rust**: rustfmt
- **Ruby**: RuboCop
- **Java**: google-java-format
- **C/C++**: clang-format
- **YAML/Markdown**: Prettier

**Example**:
```
After writing src/components/Button.tsx:
Hook: ✨ Auto-formatted Button.tsx
```

**Configuration**:
Edit `FORMATTERS` object to add/modify formatters.

**Security Note**: Fixed command injection vulnerability (properly quotes variables).

---

### 6. track-metrics.js

**Purpose**: Tracks AI-generated vs human-modified code metrics

**Features**:
- AI vs human code tracking
- Skill usage patterns
- Development velocity (lines/hour)
- File type distribution
- Historical snapshots (hourly)
- Metrics dashboard generation

**Output**:
- `.spec/.metrics.json` - Current metrics
- `.spec/metrics-history/` - Hourly snapshots
- `.spec/metrics-dashboard.md` - Visual dashboard

**Example Dashboard**:
```markdown
## Code Distribution
AI Generated:    ████████████░░░░░░░░ 65%
Human Written:   ███████░░░░░░░░░░░░░ 35%

## Statistics
| Metric | Value |
|--------|-------|
| Total Lines | 12,543 |
| Generation Velocity | 42 lines/hour |
| Most Used Skill | spec:implement |
```

**Configuration**: None

---

### 7. update-workflow-status.js

**Purpose**: Tracks workflow progress across skill executions

**Features**:
- Phase tracking (setup → specification → planning → validation → implementation)
- Progress percentage (0-100%)
- Execution history (last 50 operations)
- Time estimation (average time per skill × remaining steps)
- Next step suggestions

**Output**: `.spec/.state.json`

**Example**:
```
After spec:tasks completes:
Hook: 📊 Workflow Progress: ███████░░░ 70%
      Phase: planning
      Steps: 5/10
      Next step: spec:analyze or spec:implement
      Estimated time: ~15 minutes
```

**Configuration**: None

---

### 8. save-session.js

**Purpose**: Saves workflow state at session end

**Features**:
- Feature context preservation
- Task progress tracking
- Recent file tracking (last hour)
- Environment capture

**Output**: `.spec/.session.json`

**Example**:
```
On session end:
Hook: 💾 Session saved successfully
      Feature: features/001-login-flow
      Tasks: 12/25 complete (48%)
      Files modified: 8
```

**Configuration**: None

---

### 9. restore-session.js

**Purpose**: Restores workflow state on session start

**Features**:
- Session continuity
- Time since last session calculation
- Pending task summary
- Workflow continuation suggestions

**Example**:
```
On session start:
Hook: 🔄 Session Restored
      Last session: 2 hours ago
      Feature: features/001-login-flow
      Tasks: 12/25 complete (48%)
      
      📝 Suggestions:
        • Continue working on: features/001-login-flow
        • Resume implementation: 13 tasks pending (48% complete)
        • Next workflow step: spec:implement
```

**Configuration**: None

---

## Security Considerations

### Vulnerability Audit Results

✅ **8/9 hooks are secure** (no shell execution or safe operations only)

❌ **1 vulnerability found and FIXED**:
- **format-code.js** (lines 54, 75) - Command injection risk with unquoted shell variables
  - **Fix applied**: Properly quote all shell command variables
  - **Status**: ✅ RESOLVED

### Security Best Practices

All hooks follow these security guidelines:

1. **Shell Command Safety**:
   - Always quote variables: `"${variable}"`
   - Validate inputs before execution
   - Use `fs` APIs instead of shell commands when possible

2. **Path Traversal Prevention**:
   - Limit recursion depth (save-session.js: max depth 3)
   - Skip dangerous directories (.git, node_modules)
   - Validate file paths

3. **Error Handling**:
   - Silent failures for non-critical operations
   - Exit code 1 for blocking errors (validate-prerequisites.js)
   - Try-catch wrapping for all file operations

4. **Input Validation**:
   - Regex pattern validation
   - File existence checks before operations
   - JSON parsing with error handling

---

## Development Guide

### Adding a New Hook

1. **Create hook file**:
```javascript
#!/usr/bin/env node

/**
 * @fileoverview My New Hook
 * 
 * Description of what the hook does.
 * 
 * @requires fs
 * @author Spec Plugin Team
 */

const fs = require('fs');

async function main() {
  try {
    const input = JSON.parse(fs.readFileSync(0, 'utf8'));
    
    // Hook logic here
    
    console.log(JSON.stringify({
      type: 'my-hook-result',
      message: 'Success'
    }, null, 2));
    
    process.exit(0);
  } catch (error) {
    console.error(JSON.stringify({
      type: 'error',
      message: error.message
    }));
    process.exit(0); // Don't block on errors unless critical
  }
}

main();
```

2. **Make executable**:
```bash
chmod +x .claude/hooks/my-new-hook.js
```

3. **Register in Claude Code**:
Add to `.claude/hooks.json` (if exists) or hook configuration.

4. **Test**:
```bash
echo '{"test": "input"}' | node .claude/hooks/my-new-hook.js
```

### Hook Input Format

Hooks receive JSON via stdin:

```json
{
  "tool": "Write",
  "command": "spec:implement",
  "output": "File created successfully at: src/Button.tsx",
  "file_path": "src/Button.tsx",
  "context": {
    "feature": "001-login-flow",
    "workingDir": "/app"
  }
}
```

### Hook Output Format

Hooks output JSON to stdout:

```json
{
  "type": "hook-type",
  "message": "Human-readable message",
  "data": {
    "key": "value"
  }
}
```

### Blocking vs Non-Blocking

**Blocking hooks** (exit code 1 stops execution):
- Use for critical validation (validate-prerequisites.js)
- Provide clear error messages
- Suggest remediation steps

**Non-blocking hooks** (always exit 0):
- Use for enhancements (formatting, metrics)
- Silent failures acceptable
- Log errors but don't block

---

## Troubleshooting

### Hook Not Executing

1. **Check executable permissions**:
```bash
chmod +x .claude/hooks/*.js
```

2. **Check Node.js version**:
```bash
node --version  # Should be 14+
```

3. **Test hook directly**:
```bash
echo '{}' | node .claude/hooks/your-hook.js
```

### Hook Execution Blocked

If `validate-prerequisites.js` blocks execution:

```
❌ validation-error
   Skill: spec:plan
   Missing: spec.md
   Suggestion: Run spec:generate first to create a specification
```

**Resolution**: Follow the suggestion (run the prerequisite skill first)

### Formatter Not Found

If `format-code.js` skips formatting:

```
Hook: (silent skip - prettier not installed)
```

**Resolution**: Install the formatter:
```bash
npm install -g prettier  # For JS/TS/YAML/MD
pip install black        # For Python
# etc.
```

---

## Metrics and Analytics

### Viewing Metrics Dashboard

```bash
cat .spec/metrics-dashboard.md
```

### Viewing Workflow State

```bash
cat .spec/.state.json | jq .
```

### Viewing Session History

```bash
cat .spec/.session.json | jq .
```

### Historical Metrics

```bash
ls .spec/metrics-history/
# Hourly snapshots kept for 30 days
```

---

## Configuration

Most hooks are **zero-configuration** and work automatically.

**Configurable hooks**:

1. **post-specify.js** / **pre-specify.js**:
   - JIRA/Confluence integration
   - See `CLAUDE.md` for configuration

2. **validate-prerequisites.js**:
   - Edit `PREREQUISITES` object to modify validation rules

3. **format-code.js**:
   - Edit `FORMATTERS` object to add/modify formatters

---

## Related Documentation

- **Skills**: See `.claude/skills/*/SKILL.md` for Spec skill documentation
- **Agents**: See `.claude/agents/*/PROMPT.md` for agent documentation
- **Configuration**: See `CLAUDE.md` for project-level configuration
- **Architecture**: See `plan.md` for plugin architecture overview

---

## Contributing

When modifying hooks:

1. **Maintain JSDoc**: All functions should have comprehensive JSDoc
2. **Security review**: Check for shell command injection, path traversal
3. **Error handling**: Always wrap in try-catch, fail gracefully
4. **Testing**: Test both success and error paths
5. **Documentation**: Update this README.md

---

## License

MIT License - Spec Plugin Team
