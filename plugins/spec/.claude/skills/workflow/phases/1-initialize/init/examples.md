# spec:init Examples

Complete scenarios demonstrating initialization in different project contexts.

---

## Example 1: Greenfield React Application

**Context**: Starting a new React web application from scratch.

**User**: "Initialize spec workflow for my new React app"

**Execution**:

```bash
# Phase 1: Detect state
$ ls -la
total 8
drwxr-xr-x   2 user  staff    64 Oct 31 10:00 .
drwxr-xr-x  15 user  staff   480 Oct 31 09:59 ..
-rw-r--r--   1 user  staff   123 Oct 31 10:00 README.md

# Result: Greenfield (no source files)

# Phase 2-3: Create structure
$ tree .spec*
.spec
├── product-requirements.md
├── templates/
└── scripts/
    └── config.sh

{config.paths.state}
└── current-session.md

{config.paths.memory}
├── WORKFLOW-PROGRESS.md
├── DECISIONS-LOG.md
├── CHANGES-PLANNED.md
└── CHANGES-COMPLETED.md

# Phase 4: Update .gitignore
$ cat .gitignore
{config.paths.state}/
node_modules/
dist/
```

**Output**:
```
✅ Spec workflow initialized in greenfield project!

📁 Structure created
📝 6 files written
🎯 Ready for: spec:specify "User Authentication"

💡 Tip: Edit {config.paths.spec_root}/product-requirements.md first
```

---

## Example 2: Brownfield Python Service

**Context**: Adding spec workflow to existing Flask microservice with 50+ files.

**User**: "Setup spec for this existing Flask app"

**Execution**:

```bash
# Phase 1: Detect state
$ find . -name "*.py" | wc -l
52

$ tree -L 2 src/
src/
├── api/
│   ├── routes.py
│   ├── models.py
│   └── utils.py
├── services/
├── tests/
└── main.py

# Result: Brownfield (existing codebase)

# Phase 2-3: Create structure (same as greenfield)
# Phase 4: Detect brownfield context
```

**Output**:
```
✅ Spec workflow initialized!

🔍 Existing codebase detected: 52 Python files

📁 Structure created
📝 6 files written

🎯 Recommended next steps:
   1. Run spec:discover to analyze existing architecture
   2. Run spec:blueprint to document current patterns
   3. Then spec:specify for new features

💡 Or skip analysis: spec:specify "New Feature"
```

**Follow-up**:
```
User: "Analyze the existing code first"

→ Automatically invoke spec:discover skill
```

---

## Example 3: Multi-Team Monorepo

**Context**: Large monorepo with multiple teams, need spec workflow at package level.

**User**: "Initialize spec for the checkout service"

**Execution**:

```bash
# Working directory: /monorepo/services/checkout/
$ pwd
/Users/dev/monorepo/services/checkout

# Phase 1: Detect monorepo
$ ls ../../
services/
  - checkout/     ← Current location
  - payment/
  - inventory/
  - user/
packages/
docs/

# Phase 2-3: Create local structure
$ tree .spec
{config.paths.spec_root}/
├── product-requirements.md
├── templates/
│   └── feature-template.md    # Team-specific template
└── scripts/
    └── config.sh

# Phase 5: Team configuration
$ cat {config.paths.spec_root}/scripts/config.sh
```
```bash
#!/bin/bash
# Team: Checkout
# Slack: #team-checkout
# Jira: CHKT

SPEC_TEAM="checkout"
SPEC_JIRA_PROJECT_KEY="CHKT"
SPEC_REQUIRE_BLUEPRINT="true"
SPEC_REQUIRE_ADR="true"
```

**Output**:
```
✅ Spec workflow initialized for checkout service!

👥 Multi-team setup detected

📁 Local structure: ./services/checkout/{config.paths.spec_root}/
📝 Team config: CHKT project, ADRs required
🎯 Next: spec:blueprint for service architecture

💡 Root blueprint: ../../docs/architecture.md
   Service blueprint: ./{config.paths.spec_root}/architecture-blueprint.md
```

---

## Example 4: Reinitialize with Force

**Context**: Spec already initialized but corrupted, need fresh start.

**User**: "Reinitialize spec workflow"

**Execution**:

```bash
# Phase 1: Detect existing
$ ls .spec
product-requirements.md
templates/
scripts/

# Error case
```

**Output**:
```
⚠️  Spec already initialized!

Found: {config.paths.spec_root}/ directory (3 files)

Options:
1. Validate structure: spec:validate
2. Force reinitialize: spec:init --force (⚠️  overwrites files)
3. Resume work: spec:specify "Feature Name"

Choose an option or provide custom input:
```

**User selects**: "Force reinitialize"

**Result**:
```
⚠️  Forcing reinitialization...

📦 Backed up existing: .spec.backup.2024-10-31/
🗑️  Removed: {config.paths.spec_root}/, {config.paths.state}/
✅ Created fresh structure

⚠️  Memory preserved: {config.paths.memory}/ (contains history)

🎯 Next: spec:specify to continue
```

---

## Example 5: No Git Repository

**Context**: User hasn't initialized git yet.

**User**: "Initialize spec"

**Execution**:

```bash
# Phase 1: Check git
$ git status
fatal: not a git repository
```

**Output**:
```
⚠️  Git repository not found

Spec workflow requires git for:
- Change tracking
- Feature branches
- Commit integration

Initialize git first:
  git init
  git add .
  git commit -m "Initial commit"

Then run: spec:init

Continue anyway? (not recommended)
[Yes] [No]
```

**User selects**: "Yes"

**Result**:
```
⚠️  Proceeding without git (limited functionality)

✅ Spec structure created
⚠️  Git integration disabled
⚠️  Branch workflows unavailable
⚠️  Session checkpoints limited

Recommendation: Initialize git, then spec:validate
```

---

## Example 6: Custom Templates Configuration

**Context**: Team wants custom feature templates.

**User**: "Initialize spec with our team's templates"

**Interactive setup**:

```
🎯 Initialize spec workflow

Configuration options:

1. Use default templates? [Yes] [Custom]
2. Enable blueprint requirement? [Yes] [No]
3. Enable ADR requirement? [Yes] [No]
4. Jira integration? [Disabled] [Configure]
5. Confluence sync? [Disabled] [Configure]
```

**User selects**:
- Custom templates
- Blueprint required
- ADR required
- Jira: PROJ
- Confluence: Enabled

**Execution**:

```bash
# Creates custom template structure
$ tree {config.paths.spec_root}/templates/
{config.paths.spec_root}/templates/
├── feature-spec.md        # Custom spec template
├── feature-plan.md        # Custom plan template
├── adr-template.md        # ADR format
└── user-story.md          # Story template
```

**Output**:
```
✅ Spec workflow initialized with custom configuration!

📁 Structure created
📝 Custom templates: 4 files
🔧 Configuration:
   - Blueprints: Required
   - ADRs: Required
   - Jira: PROJ
   - Confluence: Enabled

🎯 Next steps:
   1. Edit templates in {config.paths.spec_root}/templates/
   2. Create architecture blueprint: spec:blueprint
   3. Create first feature: spec:specify "Feature"

📖 Template docs: {config.paths.spec_root}/templates/README.md
```

---

## Common Patterns

### Pattern 1: Quick Start (Greenfield)
```bash
spec:init
# Edit product requirements
spec:specify "First Feature"
```

### Pattern 2: Brownfield Analysis
```bash
spec:init
spec:discover              # Analyze existing code
spec:blueprint            # Document architecture
spec:specify "New Feature"
```

### Pattern 3: Team Onboarding
```bash
spec:init
# Configure team settings
spec:blueprint            # Define guidelines
# Share with team
```

### Pattern 4: Recovery
```bash
spec:validate             # Check for issues
spec:init --force         # Reinitialize if needed
spec:resume               # Continue work
```

---

## Validation

After initialization, verify with:

```bash
# Check structure
tree .spec* -L 2

# Validate configuration
spec:validate

# View status
spec:status

# Start first feature
spec:specify "Feature Name"
```

---

## Troubleshooting

**Issue**: "Permission denied creating {config.paths.spec_root}/"
- **Solution**: Check directory write permissions
- **Command**: `ls -la | grep -E '(spec|\.git)'`

**Issue**: "Already initialized but files missing"
- **Solution**: Run `spec:validate` to check structure
- **Recovery**: `spec:init --force` if validation fails

**Issue**: "Git hooks not working"
- **Solution**: Ensure `{config.paths.spec_root}/scripts/` has execute permissions
- **Command**: `chmod +x {config.paths.spec_root}/scripts/*.sh`

---

*For complete initialization reference, see [REFERENCE.md](./REFERENCE.md)*
