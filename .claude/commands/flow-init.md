# flow-init Command

Invoke the `flow:init` skill to initialize a Flow workflow in your project.

## TLDR
```bash
/flow-init                    # Interactive initialization
/flow-init --type=greenfield  # New project
/flow-init --type=brownfield  # Existing codebase
```

## What It Does

Initializes the Flow specification-driven development system in your project:
1. Creates `__specification__/` directory structure
2. Sets up templates for specs, plans, tasks
3. Initializes state management (`__specification__-state/`, `__specification__-memory/`)
4. Configures integration settings (optional)

## When to Use

- **Starting a new project** - Set up Flow from the beginning
- **Adding Flow to existing project** - Bring spec-driven workflow to brownfield code
- **First time using Flow** - Initialize before any other Flow commands

## Execution

When you run `/flow-init`, this command invokes the `flow:init` skill with the specified parameters.

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
/flow-init

# Direct greenfield setup
/flow-init --type=greenfield

# With integrations
/flow-init --type=greenfield --integrations=jira,confluence
```

### Existing Project
```bash
# Brownfield setup
/flow-init --type=brownfield

# Minimal setup, no integrations
/flow-init --type=brownfield --integrations=none
```

## What Gets Created

```
__specification__/
├── product-requirements.md (template)
├── architecture-blueprint.md (template)
├── templates/
│   ├── spec-template.md
│   ├── plan-template.md
│   └── tasks-template.md
└── scripts/
    └── common.sh

__specification__-state/
├── current-session.md
└── checkpoints/

__specification__-memory/
├── WORKFLOW-PROGRESS.md
├── DECISIONS-LOG.md
├── CHANGES-PLANNED.md
└── CHANGES-COMPLETED.md

features/ (empty, ready for use)
```

## After Initialization

Next steps after running `/flow-init`:

1. **Define your architecture** (optional but recommended):
   ```bash
   /flow-blueprint
   ```

2. **Create your first feature**:
   ```bash
   /flow-specify "Your feature description"
   ```

3. **Check status anytime**:
   ```bash
   /status
   ```

## Configuration

After init, you can configure Flow in `CLAUDE.md`:

```markdown
# Flow Configuration
FLOW_ATLASSIAN_SYNC=enabled
FLOW_JIRA_PROJECT_KEY=PROJ
FLOW_AUTO_CHECKPOINT=true
FLOW_VALIDATE_ON_SAVE=true
```

## Troubleshooting

**Already initialized?**
```
Error: __specification__/ directory already exists

Solution: Flow is already initialized. Use:
- /status to check current state
- /flow-specify to create features
```

**Permission errors?**
```
Error: Cannot create __specification__/ directory

Solution: Check write permissions in current directory
```

## Related Commands

- `/status` - Check initialization status
- `/flow-blueprint` - Define architecture
- `/flow-specify` - Create first feature
- `/help` - Get general help

---

**Next**: After initialization, run `/flow-specify "Your feature"` to start developing.