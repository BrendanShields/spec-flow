# Specter Visualiser

A powerful CLI tool to visualize and track your Specter workflow status, metrics, and real-time changes.

## Features

- 📊 **Interactive Dashboard** - Live view of your current workflow state
- 📚 **Specs Browser** - Navigate and explore feature specifications and user stories
- 📈 **Metrics & Analytics** - Comprehensive metrics for projects and individual features
- 👁️ **Real-time Watch Mode** - Monitor file changes as they happen
- ✅ **Project Validation** - Validate Specter project structure and consistency
- 🎯 **Health Scores** - Track project and feature health
- ⚡ **Velocity Tracking** - Monitor development velocity over time

## Installation

### Local Development

```bash
cd specter-visualiser
npm install
npm run build
npm link
```

### From npm (when published)

```bash
npm install -g specter-visualiser
```

## Usage

Run any command from within a Specter-initialized project:

### Dashboard (Default)

Display an interactive workflow dashboard with current session, health scores, and metrics:

```bash
specter-viz
# or
specter-viz dashboard
```

**Features:**
- Current session phase and feature
- Task progress with status breakdown
- Health score with factors
- Project-wide metrics
- Feature details and user stories

**Controls:**
- `r` - Refresh data
- `q` - Quit

### Specs Browser

Browse and view feature specifications interactively:

```bash
specter-viz specs

# Open specific feature
specter-viz specs --feature 001
```

**Features:**
- List all features
- View feature overview
- Browse user stories
- View task breakdown by priority
- Navigate with keyboard

**Controls:**
- Arrow keys - Navigate
- `Enter` - Select feature
- `s` - View user stories
- `t` - View tasks
- `b` - Back to previous view
- `Esc` - Back to feature list
- `q` - Quit

### Metrics View

Display detailed metrics and analytics:

```bash
# Project-wide metrics
specter-viz metrics

# Feature-specific metrics
specter-viz metrics --feature 001

# Export metrics
specter-viz metrics --export json > metrics.json
specter-viz metrics --export csv > metrics.csv
```

**Metrics Included:**
- User story counts by priority
- Task progress and completion rates
- Priority distribution charts
- Health scores
- Time tracking and estimate accuracy
- Velocity (tasks/day)

**Controls:**
- `q` - Quit

### Watch Mode

Monitor real-time changes to Specter files:

```bash
specter-viz watch

# Verbose mode (more details)
specter-viz watch --verbose
```

**Features:**
- Real-time file change notifications
- Activity log with timestamps
- Current state display
- Event categorization (state, memory, feature)
- Quick stats

**Controls:**
- `r` - Refresh
- `c` - Clear activity log
- `q` - Quit

### List Features

Quick list of all features with status:

```bash
specter-viz list

# Filter by status
specter-viz list --status implementation
```

### Validate Project

Validate Specter project structure and consistency:

```bash
specter-viz validate

# Attempt to fix issues automatically
specter-viz validate --fix
```

**Checks:**
- Directory structure
- Required files
- Feature consistency
- Task validity
- Session state consistency

### Quick Status

Get a quick status overview:

```bash
specter-viz status
```

## Project Structure

The tool expects a standard Specter project structure:

```
your-project/
├── .specter/                    # Specter configuration
├── .specter-state/              # Session state
│   └── current-session.md
├── .specter-memory/             # Persistent memory
│   ├── WORKFLOW-PROGRESS.md
│   ├── DECISIONS-LOG.md
│   ├── CHANGES-PLANNED.md
│   └── CHANGES-COMPLETED.md
└── features/                    # Feature artifacts
    └── ###-feature-name/
        ├── spec.md
        ├── plan.md
        └── tasks.md
```

## Metrics Explained

### Health Score (0-100)

Calculated based on:
- **Blocked tasks** - Each blocked task reduces score
- **Completion rate** - Low completion during implementation phase
- **Task progress** - No tasks in progress when implementation should be active
- **Priority alignment** - P1 tasks completion vs overall progress

Status levels:
- 🟢 **Healthy** (70-100) - Good progress, no major issues
- 🟡 **Warning** (40-69) - Some concerns, needs attention
- 🔴 **Critical** (0-39) - Serious issues, requires intervention

### Velocity

Tasks completed per day, averaged over the last 7 days. Helps predict feature completion times.

### Estimate Accuracy

Percentage accuracy of time estimates compared to actual time spent. Higher is better.

### Completion Rate

Percentage of tasks completed across the project or feature.

### Priority Distribution

Visual breakdown of task allocation across P1 (Must Have), P2 (Should Have), and P3 (Nice to Have).

## Development

### Build

```bash
npm run build
```

### Development Mode

```bash
npm run dev
```

### Watch Mode (TypeScript)

```bash
npm run watch
```

### Linting

```bash
npm run lint
```

### Formatting

```bash
npm run format
```

## Architecture

### Core Services

- **SpecterParser** - Parses Specter markdown files and extracts structured data
- **FileWatcher** - Monitors file system changes with debouncing
- **MetricsCalculator** - Computes metrics, health scores, and velocity
- **GitHelper** - Integrates with Git for status and history

### Components (React/Ink)

- **Dashboard** - Main interactive dashboard
- **SpecsBrowser** - Specification browser with navigation
- **MetricsView** - Detailed metrics visualization
- **WatchView** - Real-time file watching interface

### Commands

Each command is a thin wrapper that renders the appropriate React component:
- `dashboard.ts` - Renders Dashboard
- `specs.ts` - Renders SpecsBrowser
- `metrics.ts` - Renders MetricsView or exports data
- `watch.ts` - Renders WatchView
- `list.ts` - Simple table output
- `validate.ts` - Validation logic with reporting

## Tech Stack

- **TypeScript** - Type-safe development
- **Commander.js** - CLI framework
- **Ink** - React for CLIs (terminal UI)
- **Chokidar** - File watching
- **Chalk** - Terminal colors
- **Marked** - Markdown parsing
- **simple-git** - Git integration
- **date-fns** - Date formatting

## Troubleshooting

### "Not in a Specter project"

Make sure you're running the command in a directory with a `.specter` folder. The tool automatically searches up the directory tree.

### No data showing

Ensure Specter has been initialized (`/specter-init`) and has created the required files.

### File watching not working

- Check file permissions
- Ensure the paths exist
- Try verbose mode: `specter-viz watch --verbose`

### Metrics are incorrect

Run validation to check for consistency issues:
```bash
specter-viz validate
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT

## Author

Built with ❤️ for the Specter workflow community

---

**Pro Tips:**

- Use `specter-viz watch` in a split terminal while working to monitor progress in real-time
- Export metrics regularly to track project health trends
- Use the dashboard as your "mission control" at the start of each session
- Validate your project before and after major changes
- Use keyboard shortcuts to navigate efficiently

For more information about Specter workflow, see the main Specter documentation.
