# flow-init Command

Invoke the `specter:init` skill to initialize a Specter workflow in your project.

## TLDR
```bash
/specter-init                    # Interactive initialization
/specter-init --type=greenfield  # New project
/specter-init --type=brownfield  # Existing codebase
```

## What It Does

Initializes the Specter specification-driven development system in your project:
1. Creates `.specter/` directory structure
2. Sets up templates for specs, plans, tasks
3. Initializes state management (`.specter-state/`, `.specter-memory/`)
4. Configures integration settings (optional)

## When to Use

- **Starting a new project** - Set up Flow from the beginning
- **Adding Flow to existing project** - Bring spec-driven workflow to brownfield code
- **First time using Flow** - Initialize before any other Specter commands

## Execution

When you run `/specter-init`, this command invokes the `specter:init` skill with the specified parameters.

### Options

**--type=greenfield**
- For new projects starting from scratch
- Creates full directory structure
- Sets up all templates
- Initializes git integration

**--type=brownfield**
- For existing codebases
- Analyzes current structure
- Adapts to existing patterns
- Minimal disruption setup

**--integrations=jira,confluence**
- Enable JIRA integration
- Enable Confluence integration
- Set up MCP server connections

## Example Usage

### New Project
```bash
# Interactive mode (asks questions)
/specter-init

# Direct greenfield setup
/specter-init --type=greenfield

# With integrations
/specter-init --type=greenfield --integrations=jira,confluence
```

### Existing Project
```bash
# Brownfield setup
/specter-init --type=brownfield

# Minimal setup, no integrations
/specter-init --type=brownfield --integrations=none
```

## What Gets Created

```
.specter/
├── product-requirements.md (template)
├── architecture-blueprint.md (template)
├── templates/
│   ├── spec-template.md
│   ├── plan-template.md
│   └── tasks-template.md
└── scripts/
    └── common.sh

.specter-state/
├── current-session.md
└── checkpoints/

.specter-memory/
├── WORKFLOW-PROGRESS.md
├── DECISIONS-LOG.md
├── CHANGES-PLANNED.md
└── CHANGES-COMPLETED.md

features/ (empty, ready for use)
```

## After Initialization

Next steps after running `/specter-init`:

1. **Define your architecture** (optional but recommended):
   ```bash
   /specter-blueprint
   ```

2. **Create your first feature**:
   ```bash
   /specter-specify "Your feature description"
   ```

3. **Check status anytime**:
   ```bash
   /status
   ```

## Configuration

After init, you can configure Flow in `CLAUDE.md`:

```markdown
# Flow Configuration
SPECTER_ATLASSIAN_SYNC=enabled
SPECTER_JIRA_PROJECT_KEY=PROJ
SPECTER_AUTO_CHECKPOINT=true
SPECTER_VALIDATE_ON_SAVE=true
```

## Troubleshooting

**Already initialized?**
```
Error: .specter/ directory already exists

Solution: Specter is already initialized. Use:
- /status to check current state
- /specter-specify to create features
```

**Permission errors?**
```
Error: Cannot create .specter/ directory

Solution: Check write permissions in current directory
```

## Related Commands

- `/status` - Check initialization status
- `/specter-blueprint` - Define architecture
- `/specter-specify` - Create first feature
- `/help` - Get general help

---

**Next**: After initialization, run `/specter-specify "Your feature"` to start developing.