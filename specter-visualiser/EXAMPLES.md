# Specter Visualiser Examples

Real-world usage examples and workflows.

## Quick Start

### First Time Setup

```bash
# Navigate to your Specter project
cd ~/projects/my-specter-project

# Run the visualiser
specter-viz

# You should see the dashboard with your current workflow state
```

## Common Workflows

### Morning Standup Routine

Start your day by checking project health:

```bash
# 1. Check overall status
specter-viz status

# 2. Open interactive dashboard
specter-viz dashboard

# 3. Review yesterday's progress
specter-viz metrics

# 4. Validate project consistency
specter-viz validate
```

### Feature Development Session

When actively working on a feature:

```bash
# Terminal 1: Work on your feature
cd features/001-user-authentication
# ... make changes ...

# Terminal 2: Watch mode
specter-viz watch --verbose

# See changes appear in real-time as you work!
```

### Sprint Planning

Review features and plan upcoming work:

```bash
# 1. List all features with status
specter-viz list

# 2. Browse feature specifications
specter-viz specs

# Navigate to specific features, review user stories and tasks

# 3. Export metrics for reporting
specter-viz metrics --export json > sprint-metrics.json
```

### Feature Review

Detailed review of a specific feature:

```bash
# View specific feature specs
specter-viz specs --feature 001

# View metrics for that feature
specter-viz metrics --feature 001

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
specter-viz validate

# Check dashboard health score
specter-viz

# Review blocked tasks and issues
# Dashboard will highlight problems in red
```

## Advanced Usage

### Continuous Monitoring

Set up a dedicated terminal for monitoring:

```bash
# Terminal setup (tmux example)
tmux new-session -d -s specter
tmux send-keys -t specter "cd ~/projects/my-project && specter-viz watch" Enter

# Attach when needed
tmux attach -t specter
```

### Metrics Tracking Over Time

Create a script to track metrics daily:

```bash
#!/bin/bash
# daily-metrics.sh

DATE=$(date +%Y-%m-%d)
specter-viz metrics --export json > "metrics/metrics-$DATE.json"

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
# Validate Specter state before commit

specter-viz validate --fix

if [ $? -ne 0 ]; then
  echo "Specter validation failed. Please fix issues before committing."
  exit 1
fi
```

### Custom Scripts

Create shortcuts in your `.bashrc` or `.zshrc`:

```bash
# Quick aliases
alias sv='specter-viz'
alias svd='specter-viz dashboard'
alias svm='specter-viz metrics'
alias svw='specter-viz watch'
alias svl='specter-viz list'

# Function to view feature quickly
svf() {
  specter-viz specs --feature "$1"
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
│ 📊 Specter Workflow Dashboard                        │
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
│ 👁️  Specter File Watcher                            │
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
- Terminal 2 (monitor): `specter-viz watch`

### 2. Quick Health Checks

Before committing:
```bash
specter-viz validate && git commit -m "..."
```

### 3. Daily Metrics

Track progress over time:
```bash
# Add to crontab
0 9 * * * cd ~/project && specter-viz metrics --export json > metrics/$(date +\%Y-\%m-\%d).json
```

### 4. Feature Focus

When working on a specific feature:
```bash
# Set an alias for current feature
alias svf='specter-viz specs --feature 001'
alias svm='specter-viz metrics --feature 001'
```

### 5. Terminal Multiplexing

Use with tmux/screen for always-on monitoring:
```bash
# tmux session
tmux new -s specter-watch
specter-viz watch

# Detach: Ctrl+B, D
# Reattach: tmux attach -t specter-watch
```

### 6. CI/CD Integration

Add to CI pipeline:
```yaml
# .github/workflows/specter-check.yml
- name: Validate Specter
  run: |
    npm install -g specter-visualiser
    specter-viz validate
```

## Troubleshooting Examples

### Problem: No features showing

```bash
# Check if Specter is initialized
specter-viz validate

# Look for features directory
ls -la features/

# If missing, initialize Specter
/specter-init
```

### Problem: Metrics seem wrong

```bash
# Validate project
specter-viz validate

# Check for parsing errors
specter-viz list

# Manually check a feature file
cat features/001-*/spec.md
```

### Problem: Watch mode not detecting changes

```bash
# Check permissions
ls -la .specter-state/

# Try verbose mode
specter-viz watch --verbose

# Check if files are being created
touch .specter-state/test.md
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
      "label": "Specter Dashboard",
      "type": "shell",
      "command": "specter-viz",
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    },
    {
      "label": "Specter Watch",
      "type": "shell",
      "command": "specter-viz watch",
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
# Open iTerm/Terminal with Specter visualiser

cd ~/projects/my-project
open -a iTerm
osascript -e 'tell application "iTerm" to activate'
osascript -e 'tell application "System Events" to keystroke "specter-viz"'
osascript -e 'tell application "System Events" to key code 36'
```

## More Examples

For more examples and use cases, visit the [GitHub repository](https://github.com/your-org/specter-visualiser).
