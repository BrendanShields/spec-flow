---
name: spec:init
description: Initialize spec workflow in project. Use when 1) Starting new project with spec workflow, 2) User says "initialize spec" or "setup spec workflow", 3) Adding spec to existing codebase, 4) Need to create {config.paths.spec_root}/ structure. Creates directory structure, state management, and configuration.
allowed-tools: Read, Write, Bash, Grep
---

# Spec Initialize

Initialize spec workflow structure in greenfield or brownfield projects.

## Core Capability

Sets up complete spec workflow infrastructure:
- Creates `{config.paths.spec_root}/` configuration directory
- Initializes `{config.paths.state}/` for session tracking (gitignored)
- Creates `{config.paths.memory}/` for persistent history (committed)
- Detects project type (greenfield vs brownfield)
- Generates starter templates and configuration

## Execution Flow

### Phase 1: Detect Project State

**Read existing structure**:
```bash
# Check for existing spec setup
test -d .spec && echo "exists" || echo "new"

# Detect project type
ls src/ package.json *.py 2>/dev/null | wc -l
```

**Project types**:
- **Greenfield**: Empty/new project → Create basic templates
- **Brownfield**: Existing code → Suggest `discover phase` for analysis

### Phase 2: Create Directory Structure

**Core directories** (always created):
```
{config.paths.spec_root}/                      # Configuration (committed)
├── product-requirements.md    # Product vision
├── templates/                 # Custom templates
└── scripts/                   # Utility scripts

{config.paths.state}/                # Session state (gitignored)
└── current-session.md         # Active work tracking

{config.paths.memory}/               # Persistent memory (committed)
├── WORKFLOW-PROGRESS.md       # Feature metrics
├── DECISIONS-LOG.md           # Architecture decisions
├── CHANGES-PLANNED.md         # Pending tasks
└── CHANGES-COMPLETED.md       # Completed work
```

**Use Write tool** to create each file from templates (see REFERENCE.md for full templates).

### Phase 3: Initialize State Files

**Template Location**: `.claude/skills/workflow/templates/state/`

**Process**:
1. Read each template file from plugin
2. Replace placeholder variables
3. Write to user project location

**Implementation**:
```
For each state file:
  1. Read template:
     - Read `.claude/skills/workflow/templates/state/{filename}`

  2. Replace placeholders:
     - {timestamp} → current ISO 8601 timestamp
     - {date} → current date (YYYY-MM-DD)
     - {uuid} → generated UUID
     - {conversation_id} → Claude conversation ID (if available)
     - {project_name} → from config or "Untitled Project"

  3. Write to destination:
     - Write to `{config.paths.state}/{filename}` or `{config.paths.memory}/{filename}`
```

**Files to create**:
1. `{config.paths.state}/current-session.md`
   - Template: `templates/state/current-session.md`
   - Destination: Session tracking (git-ignored)

2. `{config.paths.memory}/WORKFLOW-PROGRESS.md`
   - Template: `templates/state/WORKFLOW-PROGRESS.md`
   - Destination: Feature metrics (committed)

3. `{config.paths.memory}/DECISIONS-LOG.md`
   - Template: `templates/state/DECISIONS-LOG.md`
   - Destination: ADR log (committed)

4. `{config.paths.memory}/CHANGES-PLANNED.md`
   - Template: `templates/state/CHANGES-PLANNED.md`
   - Destination: Pending tasks (committed)

5. `{config.paths.memory}/CHANGES-COMPLETED.md`
   - Template: `templates/state/CHANGES-COMPLETED.md`
   - Destination: Completion audit trail (committed)

**Error Handling**:
- If template file not found: Report error and skip
- If destination file exists: Ask user to confirm overwrite
- If directory doesn't exist: Create it first

### Phase 4: Update .gitignore

**Add to .gitignore**:
```bash
# Read existing .gitignore
# Append if missing:
{config.paths.state}/
```

**Keep committed**:
- `{config.paths.spec_root}/` - Project configuration
- `{config.paths.memory}/` - Persistent history

### Phase 5: Create Configuration

**Generate `{config.paths.spec_root}/product-requirements.md`**:
```markdown
# Product Requirements

## Vision
[To be defined]

## Success Metrics
[To be defined]

## Constraints
[To be defined]
```

**Optional features** (ask user):
- Architecture blueprint (via `/workflow:spec` → "📐 Create Blueprint")
- Brownfield discovery (via `/workflow:spec` → "🔍 Discover Existing")
- Team collaboration settings

### Phase 6: Smart Hook Auto-Detection

If `workflow.auto_detect_hooks.enabled: true` in config, detect project tooling and offer to create hooks.

**Detection Algorithm**:
```bash
# Read config
config=$(cat .claude/.spec-config.yml)
if [[ ! "$config" =~ "auto_detect_hooks:\s*enabled:\s*true" ]]; then
  exit 0  # Skip if disabled
fi

# Detect tooling by checking for config files and dependencies
detected_tools=()

# Linters
test -f .eslintrc.json || test -f .eslintrc.js && detected_tools+=("eslint")
test -f .prettierrc || test -f .prettierrc.json && detected_tools+=("prettier")

# Type checkers
test -f tsconfig.json && detected_tools+=("typescript")
test -f .flowconfig && detected_tools+=("flow")
test -f setup.cfg | grep -q mypy && detected_tools+=("mypy")

# Build tools
test -f webpack.config.js && detected_tools+=("webpack")
test -f vite.config.ts && detected_tools+=("vite")
test -f turbo.json && detected_tools+=("turbo")

# Test runners
grep -q '"jest"' package.json 2>/dev/null && detected_tools+=("jest")
grep -q '"vitest"' package.json 2>/dev/null && detected_tools+=("vitest")
test -f pytest.ini && detected_tools+=("pytest")

# Package managers
test -f pnpm-lock.yaml && detected_tools+=("pnpm")
test -f yarn.lock && detected_tools+=("yarn")
test -f poetry.lock && detected_tools+=("poetry")

# Git hooks
test -f .husky/_/husky.sh && detected_tools+=("husky")
test -f .git/hooks/pre-commit && detected_tools+=("git-hooks")

echo "${detected_tools[@]}"
```

**User Prompt (if tools detected)**:

Use AskUserQuestion to present detected tools:
```markdown
🔍 Detected Project Tooling

I found these tools in your project:
- ESLint (linter)
- Prettier (formatter)
- TypeScript (type checker)
- Jest (test runner)
- pnpm (package manager)

Would you like me to create Claude Code hooks for these tools?

Options:
- ✅ Create All Hooks (recommended)
- 📝 Select Specific Hooks
- ❌ Skip Hook Creation

Hooks will run automatically during development:
- Linter/Formatter: Run on file edits
- Type Checker: Run before builds
- Tests: Run after test file changes
```

**If user selects "Create All Hooks"**:
```bash
# Generate hooks based on config template
for tool in "${detected_tools[@]}"; do
  case $tool in
    eslint)
      cat > .claude/hooks/eslint-check.js <<'EOF'
#!/usr/bin/env node
// Auto-generated by initialize phase
// Hook: Run ESLint on edited files

const { execSync } = require('child_process');
const path = require('path');

module.exports = function(context) {
  const { tool, parameters } = context;

  // Only run on Write/Edit of JS/TS files
  if ((tool === 'Write' || tool === 'Edit') &&
      parameters.file_path?.match(/\.(js|jsx|ts|tsx)$/)) {
    try {
      const file = parameters.file_path;
      console.log(`🔍 Running ESLint on ${file}...`);
      execSync(`npx eslint --fix "${file}"`, { stdio: 'inherit' });
      console.log(`✅ ESLint passed`);
    } catch (error) {
      console.error(`❌ ESLint failed: ${error.message}`);
      // Don't block - show warning but allow continuation
    }
  }
};
EOF
      chmod +x .claude/hooks/eslint-check.js
      # Register in hooks.json
      ;;

    prettier)
      cat > .claude/hooks/prettier-format.js <<'EOF'
#!/usr/bin/env node
// Auto-generated by initialize phase
// Hook: Run Prettier on edited files

const { execSync } = require('child_process');

module.exports = function(context) {
  const { tool, parameters } = context;

  if ((tool === 'Write' || tool === 'Edit') && parameters.file_path) {
    const file = parameters.file_path;
    // Skip node_modules and build artifacts
    if (file.includes('node_modules') || file.includes('dist')) return;

    try {
      console.log(`💅 Formatting ${file} with Prettier...`);
      execSync(`npx prettier --write "${file}"`, { stdio: 'inherit' });
      console.log(`✅ Formatted`);
    } catch (error) {
      console.error(`⚠️  Prettier warning: ${error.message}`);
    }
  }
};
EOF
      chmod +x .claude/hooks/prettier-format.js
      ;;

    typescript)
      cat > .claude/hooks/typescript-check.js <<'EOF'
#!/usr/bin/env node
// Auto-generated by initialize phase
// Hook: Run TypeScript type check before builds

const { execSync } = require('child_process');

module.exports = function(context) {
  const { tool, parameters } = context;

  // Run before build commands
  if (tool === 'Bash' && parameters.command?.includes('build')) {
    try {
      console.log(`🔍 Running TypeScript type check...`);
      execSync('npx tsc --noEmit', { stdio: 'inherit' });
      console.log(`✅ Type check passed`);
    } catch (error) {
      console.error(`❌ Type errors found. Build blocked.`);
      throw error; // Block build on type errors
    }
  }
};
EOF
      chmod +x .claude/hooks/typescript-check.js
      ;;

    jest|vitest)
      cat > .claude/hooks/test-runner.js <<'EOF'
#!/usr/bin/env node
// Auto-generated by initialize phase
// Hook: Run tests after test file changes

const { execSync } = require('child_process');

module.exports = function(context) {
  const { tool, parameters } = context;

  // Run tests after writing/editing test files
  if ((tool === 'Write' || tool === 'Edit') &&
      parameters.file_path?.match(/\.(test|spec)\.(js|ts|tsx)$/)) {
    const file = parameters.file_path;
    try {
      console.log(`🧪 Running tests for ${file}...`);
      execSync(`npm test -- "${file}"`, { stdio: 'inherit' });
      console.log(`✅ Tests passed`);
    } catch (error) {
      console.error(`❌ Tests failed: ${error.message}`);
      // Show warning but don't block
    }
  }
};
EOF
      chmod +x .claude/hooks/test-runner.js
      ;;
  esac
done

# Update hooks.json to register all hooks
cat > .claude/hooks/hooks.json <<'EOF'
{
  "PostToolUse": [
    {"file": "./eslint-check.js"},
    {"file": "./prettier-format.js"},
    {"file": "./test-runner.js"}
  ],
  "PreToolUse": [
    {"file": "./typescript-check.js"}
  ]
}
EOF
```

**If user selects "Select Specific Hooks"**:
Use AskUserQuestion with multiSelect: true:
```markdown
Select hooks to create:

Options:
- ESLint (auto-fix linting issues)
- Prettier (auto-format code)
- TypeScript (type-check before builds)
- Jest (run tests after changes)
- All of the above
```

**If user selects "Skip"**:
```markdown
⏭️  Skipped hook creation

You can create hooks later with:
  /claude-code (select "Create Hooks")

Or manually edit .claude/hooks/
```

**Hook Summary Output**:
```markdown
✅ Created hooks:
   📝 eslint-check.js - Run ESLint on file edits
   💅 prettier-format.js - Format code with Prettier
   🔍 typescript-check.js - Type-check before builds
   🧪 test-runner.js - Run tests after changes

🎯 Hooks active! Your development workflow is now automated.

Test hooks:
  1. Edit a .ts file → ESLint + Prettier run automatically
  2. Run build → TypeScript check runs first
  3. Create test file → Tests run after save
```

## Output

```
✅ Spec workflow initialized!

📁 Structure:
   {config.paths.spec_root}/                 (configuration)
   {config.paths.state}/          (session tracking, gitignored)
   {config.paths.memory}/         (persistent history, committed)

📝 Files created:
   product-requirements.md
   current-session.md
   WORKFLOW-PROGRESS.md
   DECISIONS-LOG.md

🎯 Next steps:
   1. Edit {config.paths.spec_root}/product-requirements.md
   2. Run /workflow:spec → "📝 Define Feature" to create first feature
   3. Or run /workflow:spec → "🔍 Discover Existing" for brownfield analysis

📖 Learn more: ../../../quick-start.md
```

## Brownfield Projects

If existing code detected (>5 source files), suggest:

```
🔍 Existing codebase detected!

Run /workflow:spec → "🔍 Discover Existing" to:
- Analyze current architecture
- Identify integration points
- Generate baseline blueprint
- Map existing features

Or continue with /workflow:spec → "📝 Define Feature" for new features.
```

## Templates Used

This function uses the following templates:

**Primary Templates**:
- `templates/product-requirements-template.md` → `{config.paths.spec_root}/product-requirements.md`
- `templates/architecture-blueprint-template.md` → `{config.paths.spec_root}/architecture-blueprint.md` (optional)

**Purpose**: Provides structure for project initialization, product vision, and architecture standards

**Customization**:
1. After init, edit `{config.paths.spec_root}/product-requirements.md` to define your product vision
2. Optionally run `/spec blueprint` to create comprehensive architecture documentation
3. Templates provide starter structure - customize for your project

**Product Requirements Template includes**:
- Product vision and goals
- Target users and personas
- Success criteria and KPIs
- Business constraints
- Stakeholder information

**Architecture Blueprint Template includes**:
- Tech stack decisions
- Design patterns and conventions
- API standards
- Security guidelines
- ADR (Architecture Decision Record) framework

**See also**:
- `templates/README.md` for complete template documentation
- `blueprint/guide.md` for architecture documentation details

## Error Handling

**Already initialized**:
```
⚠️  Spec already initialized!

Found: {config.paths.spec_root}/ directory

Options:
- Reinitialize: /workflow:spec → "🔄 Reinitialize"
- Validate: /workflow:track → "🔍 Analyze Consistency"
- Continue: /workflow:spec → "📝 Define Feature"
```

**Git not initialized**:
```
⚠️  Git repository not found

Initialize git first:
  git init
  git add .
  git commit -m "Initial commit"

Then run: /workflow:spec → "🚀 Initialize Project"
```

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for:
- Greenfield React app initialization
- Brownfield Python service setup
- Multi-team configuration
- Custom template configuration

## Reference

See [REFERENCE.md](./REFERENCE.md) for:
- Complete directory structure specification
- Full file templates
- Configuration options
- Integration with discover phase and blueprint phase
- Team collaboration setup

## Related Workflow Options

- **/workflow:spec** → "🔍 Discover Existing": Analyze existing codebase (brownfield)
- **/workflow:spec** → "📐 Create Blueprint": Define architecture guidelines
- **/workflow:spec** → "📝 Define Feature": Create first feature specification
- **/workflow:track** → "🔍 Analyze Consistency": Check workflow consistency
