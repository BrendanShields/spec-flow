# Spec Visualiser Examples

Real-world usage examples and workflows.

## Quick Start

### First Time Setup

```bash
# Navigate to your Spec project
cd ~/projects/my-spec-project

# Run the visualiser
spec-viz

# You should see the dashboard with your current workflow state
```

## Common Workflows

### Morning Standup Routine

Start your day by checking project health:

```bash
# 1. Check overall status
spec-viz status

# 2. Open interactive dashboard
spec-viz dashboard

# 3. Review yesterday's progress
spec-viz metrics

# 4. Validate project consistency
spec-viz validate
```

### Feature Development Session

When actively working on a feature:

```bash
# Terminal 1: Work on your feature
cd features/001-user-authentication
# ... make changes ...

# Terminal 2: Watch mode
spec-viz watch --verbose

# See changes appear in real-time as you work!
```

### Sprint Planning

Review features and plan upcoming work:

```bash
# 1. List all features with status
spec-viz list

# 2. Browse feature specifications
spec-viz specs

# Navigate to specific features, review user stories and tasks

# 3. Export metrics for reporting
spec-viz metrics --export json > sprint-metrics.json
```

### Feature Review

Detailed review of a specific feature:

```bash
# View specific feature specs
spec-viz specs --feature 001

# View metrics for that feature
spec-viz metrics --feature 001

# Expected output:
# - User story breakdown
# - Task completion rates
# - Health score
# - Time estimates vs actuals
```

### Health Check

Regular project health monitoring:

```bash
# Run validation
spec-viz validate

# Check dashboard health score
spec-viz

# Review blocked tasks and issues
# Dashboard will highlight problems in red
```

## Advanced Usage

### Continuous Monitoring

Set up a dedicated terminal for monitoring:

```bash
# Terminal setup (tmux example)
tmux new-session -d -s spec
tmux send-keys -t spec "cd ~/projects/my-project && spec-viz watch" Enter

# Attach when needed
tmux attach -t spec
```

### Metrics Tracking Over Time

Create a script to track metrics daily:

```bash
#!/bin/bash
# daily-metrics.sh

DATE=$(date +%Y-%m-%d)
spec-viz metrics --export json > "metrics/metrics-$DATE.json"

echo "Metrics saved for $DATE"
```

Run daily:
```bash
chmod +x daily-metrics.sh
./daily-metrics.sh
```

### Integration with Git Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Validate Spec state before commit

spec-viz validate --fix

if [ $? -ne 0 ]; then
  echo "Spec validation failed. Please fix issues before committing."
  exit 1
fi
```

### Custom Scripts

Create shortcuts in your `.bashrc` or `.zshrc`:

```bash
# Quick aliases
alias sv='spec-viz'
alias svd='spec-viz dashboard'
alias svm='spec-viz metrics'
alias svw='spec-viz watch'
alias svl='spec-viz list'

# Function to view feature quickly
svf() {
  spec-viz specs --feature "$1"
}

# Usage: svf 001
```

## Keyboard Shortcuts Reference

### Dashboard
- `r` - Refresh data
- `q` - Quit

### Specs Browser
- `↑/↓` - Navigate items
- `Enter` - Select
- `s` - View stories
- `t` - View tasks
- `b` - Back
- `Esc` - Back to list
- `q` - Quit

### Watch Mode
- `r` - Refresh
- `c` - Clear activity log
- `q` - Quit

## Output Examples

### Dashboard View

```
┌──────────────────────────────────────────────────────┐
│ 📊 Spec Workflow Dashboard                        │
│  /Users/dev/projects/my-app                          │
└──────────────────────────────────────────────────────┘

┌─ 🎯 Current Session ──────────────────────────────────┐
│ Phase: implementation (75% complete)                  │
│ Feature: User Authentication System (001)             │
│ Tasks: 12/16 completed • 2 in progress               │
└───────────────────────────────────────────────────────┘

┌─ ✅ Health Score: 85/100 ────────────────────────────┐
│ Status: Healthy                                       │
└───────────────────────────────────────────────────────┘

┌─ 📈 Project Metrics ──────────────────────────────────┐
│ Features: 3/5 completed                               │
│ Tasks: 45/60 (75.0% complete)                        │
│ Decisions: 23                                         │
└───────────────────────────────────────────────────────┘

Press r to refresh • q to quit
```

### Metrics View

```
┌──────────────────────────────────────────────────────┐
│ 📊 Feature Metrics: User Authentication System       │
└──────────────────────────────────────────────────────┘

┌─ 📝 User Stories ─────────────────────────────────────┐
│ Total: 5                                              │
│ By Priority: P1:3 • P2:1 • P3:1                      │
└───────────────────────────────────────────────────────┘

┌─ ✓ Tasks ─────────────────────────────────────────────┐
│ Progress: ████████████████░░░░░░░░░░░ 75.0%          │
│ Status: ✓12 • ⟳2 • ○2                                │
│ By Priority: P1:8 • P2:6 • P3:2                      │
└───────────────────────────────────────────────────────┘

┌─ 🎯 Priority Distribution ────────────────────────────┐
│ P1: ██████████░░░░░░░░░░ 50.0%                       │
│ P2: ██████░░░░░░░░░░░░░░ 37.5%                       │
│ P3: ██░░░░░░░░░░░░░░░░░░ 12.5%                       │
└───────────────────────────────────────────────────────┘
```

### Watch Mode

```
┌──────────────────────────────────────────────────────┐
│ 👁️  Spec File Watcher                            │
│ Status: ● Watching • Last update: 5 seconds ago      │
└──────────────────────────────────────────────────────┘

┌─ 📊 Current State ────────────────────────────────────┐
│ Phase: implementation                                 │
│ Feature: User Authentication System (001)             │
│ Tasks: 12/16 • 2 in progress                         │
└───────────────────────────────────────────────────────┘

┌─ 📋 Activity Log (5) ─────────────────────────────────┐
│ 5 seconds ago 📝 Feature Modified                     │
│ 30 seconds ago 💾 Memory Updated                      │
│ 1 minute ago 🔵 Session Updated                       │
│ 2 minutes ago 📝 Tasks Updated                        │
│ 5 minutes ago 🔵 State Changed                        │
└───────────────────────────────────────────────────────┘

r - Refresh • c - Clear log • q - Quit
```

## Tips and Tricks

### 1. Dual Monitor Setup

Keep visualiser on second monitor:
- Terminal 1 (main): Code editor
- Terminal 2 (monitor): `spec-viz watch`

### 2. Quick Health Checks

Before committing:
```bash
spec-viz validate && git commit -m "..."
```

### 3. Daily Metrics

Track progress over time:
```bash
# Add to crontab
0 9 * * * cd ~/project && spec-viz metrics --export json > metrics/$(date +\%Y-\%m-\%d).json
```

### 4. Feature Focus

When working on a specific feature:
```bash
# Set an alias for current feature
alias svf='spec-viz specs --feature 001'
alias svm='spec-viz metrics --feature 001'
```

### 5. Terminal Multiplexing

Use with tmux/screen for always-on monitoring:
```bash
# tmux session
tmux new -s spec-watch
spec-viz watch

# Detach: Ctrl+B, D
# Reattach: tmux attach -t spec-watch
```

### 6. CI/CD Integration

Add to CI pipeline:
```yaml
# .github/workflows/spec-check.yml
- name: Validate Spec
  run: |
    npm install -g spec-visualiser
    spec-viz validate
```

## Troubleshooting Examples

### Problem: No features showing

```bash
# Check if Spec is initialized
spec-viz validate

# Look for features directory
ls -la features/

# If missing, initialize Spec
/spec-init
```

### Problem: Metrics seem wrong

```bash
# Validate project
spec-viz validate

# Check for parsing errors
spec-viz list

# Manually check a feature file
cat features/001-*/spec.md
```

### Problem: Watch mode not detecting changes

```bash
# Check permissions
ls -la .spec-state/

# Try verbose mode
spec-viz watch --verbose

# Check if files are being created
touch .spec-state/test.md
# Should show up in watch log
```

## Integration Examples

### VS Code Task

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Spec Dashboard",
      "type": "shell",
      "command": "spec-viz",
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    },
    {
      "label": "Spec Watch",
      "type": "shell",
      "command": "spec-viz watch",
      "isBackground": true,
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    }
  ]
}
```

### Alfred/Spotlight Workflow

Create a script wrapper:

```bash
#!/bin/bash
# Open iTerm/Terminal with Spec visualiser

cd ~/projects/my-project
open -a iTerm
osascript -e 'tell application "iTerm" to activate'
osascript -e 'tell application "System Events" to keystroke "spec-viz"'
osascript -e 'tell application "System Events" to key code 36'
```

## More Examples

For more examples and use cases, visit the [GitHub repository](https://github.com/your-org/spec-visualiser).
