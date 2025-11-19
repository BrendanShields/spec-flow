# Orbit

Primary slash command for the Orbit workflow. Provides context-aware guidance on which autonomous skill to invoke based on current project state.

## What This Command Does

- Detects project state (initialized, current phase, active feature)
- Reads cached workflow hints from `{config.paths.state}/NEXT-STEP.json`
- Presents interactive `AskUserQuestion` interface for easy navigation
- Invokes appropriate autonomous skill based on user selection
- Guides the user through the workflow phases

**User Experience**: Interactive multi-tab questions where appropriate, allowing users to easily choose their next action without typing commands.

## Initial Status Message

Always begin your response with a formatted Orbit status block so the user immediately sees the current phase and recommendation:

```
**🚀🌑 Orbit Status**
- Phase: {phase or "not initialized"}
- Feature: {feature id or "none"}
- Next Step: {cached recommendation}
```

After printing the block, continue with the context summary and AskUserQuestion flow described below.

## Workflow State Detection

1. **Check for interrupted auto-mode session** (PRIORITY)
   - If `.spec/state/auto-mode-session.json` exists with status `"interrupted"` or `"paused"`
   - Check session not expired (< 24 hours)
   - → Offer resume with progress summary (see Auto-Mode Resume section)

2. **Check initialization**
   - If `.spec/` doesn't exist → recommend the **Orbit Lifecycle** skill (Initialize branch)

3. **Read current state**
   - Parse `{config.paths.state}/current-session.md` for current phase and feature
   - Read `{config.paths.state}/NEXT-STEP.json` (cached by hooks) for recommended action

4. **Determine current phase**
   - `NOT_INITIALIZED` → Initialize project
   - `NO_FEATURE` → Define new feature (offer auto-mode)
   - `IN_SPECIFICATION` → Clarify or validate spec
   - `IN_PLANNING` → Design solution
   - `IN_IMPLEMENTATION` → Build or track progress
   - `COMPLETE` → Validate or start new feature

## Autonomous Skills by Phase

- **orbit-lifecycle** – Single skill covering initialization, specification, clarifications, updates, implementation, and tracking branches.
- **orbit-planning** – Handles architecture blueprints, technical plans, task breakdown, and consistency checks.
- **analyzing-codebase** – Optional brownfield reconnaissance before entering Orbit.
- **orbit-orchestrator** – Auto mode wrapper chaining Orbit Lifecycle + Orbit Planning.

## Interactive Interface by State

Use `AskUserQuestion` to present context-aware options based on workflow state.

**State: AUTO_MODE_RESUMABLE (interrupted/paused session detected)**
→ Show progress summary:
```
⚠️  Auto-mode interrupted during {Phase} phase

Progress saved:
  ✓ {Completed phases summary}
  ⚠️ {Current phase} (interrupted at ~{X}%)

Time remaining: {hours}h until expiry
```

→ Single question: "Resume from {Phase} phase?"
  - Option 1: "Resume" (default) → Invoke `orbit-orchestrator` skill with resume=true
  - Option 2: "Restart" → Discard session, invoke `orbit-orchestrator` with fresh start
  - Option 3: "Interactive" → Remove session, return to manual workflow

**State: AUTO_MODE_EXPIRED (session > 24 hours old)**
→ Show expiry message:
```
⚠️  Auto-mode session expired

Session from: {started_at}
Expired: {expires_at} ({X} hours ago)

Progress was saved at:
  {List of completed phases and artifacts}

Session too old to resume automatically.
Review saved files at: {feature_dir}/
```

→ Single question: "Start new feature?"
  - Option 1: "Auto Mode" → Invoke `orbit-orchestrator`
  - Option 2: "Interactive" → Invoke `orbit-lifecycle` (Define branch)
  - Option 3: "View Saved Work" → Show file paths

**State: NOT_INITIALIZED**
→ Single question: "Your project isn't initialized. Ready to set up?"
  - Option 1: "Initialize Project" → Invoke `orbit-lifecycle` (Initialize branch)
  - Option 2: "Learn More" → Explain what initialization does

**State: NO_FEATURE (initialized but no active feature)**
→ Single question with 4-5 options: "What would you like to do?"
  - Option 1: "🚀 Auto Mode (Recommended)" → Invoke `orbit-orchestrator` skill
    - Description: "Runs Orbit Lifecycle → Orbit Planning automatically with checkpoints"
  - Option 2: "Start New Feature (Interactive)" → Invoke `orbit-lifecycle` (Define branch)
    - Description: "Step-by-step control through Orbit"
  - Option 3: "Analyze Codebase" → Invoke `analyzing-codebase` (brownfield)
  - Option 4: "Create Architecture" → Invoke `orbit-planning` (Architecture branch)
  - Option 5: "View Help" → Show workflow overview

**State: IN_SPECIFICATION (spec exists, has [CLARIFY] tags)**
→ Multi-question AskUserQuestion block:
  1. Single-select question that lists each clarification headline (auto-generated options such as “Cache invalidation”, “Preloading scope”, etc.) so the user can choose which ones to answer now.
  2. For each selected clarification, immediately present the follow-up options (per the guidelines: max 4 options + automatic “Other”).
  - Include an option like “Answer All Now” to encourage resolving everything in one pass.
  - After collection, invoke `orbit-lifecycle` (Clarify branch) with the chosen answers.
  - Offer "Skip to Planning" (invokes `orbit-planning` with warning) and "Validate Spec Quality" (invokes `orbit-lifecycle` Quality branch) for users who intentionally defer.

**State: IN_SPECIFICATION (spec validated, no [CLARIFY] tags)**
→ Single question: "Spec looks good! Ready to plan implementation?"
  - Option 1: "Create Technical Plan" → Invoke `orbit-planning` (Plan branch)
  - Option 2: "Validate Spec First" → Invoke `orbit-lifecycle` (Quality branch)
  - Option 3: "Update Spec" → Invoke `orbit-lifecycle` (Update branch)

**State: IN_PLANNING (plan exists)**
→ Single question: "Plan created. What's next?"
  - Option 1: "Break Into Tasks" → Invoke `orbit-planning` (Tasks branch)
  - Option 2: "Check Consistency" → Invoke `orbit-planning` (Consistency branch)
  - Option 3: "Revise Plan" → Invoke `orbit-planning` (Plan branch)

**State: IN_IMPLEMENTATION (tasks exist, {X}% complete)**
→ Single question: "Implementation {X}% complete. Continue?"
  - Option 1: "Continue Building" → Invoke `orbit-lifecycle` (Implement branch)
  - Option 2: "Check Progress" → Invoke `orbit-lifecycle` (Track branch)
  - Option 3: "Update Tasks" → Invoke `orbit-planning` (Tasks branch)

**State: COMPLETE**
→ Single question: "Feature complete! What's next?"
  - Option 1: "Start New Feature" → Invoke `orbit-lifecycle`
  - Option 2: "Validate Consistency" → Invoke `orbit-planning` (Consistency branch)
  - Option 3: "View Metrics" → Invoke `orbit-lifecycle` (Track branch)

## Multi-Tab Questions (When Applicable)

Use multi-tab questions when user might want multiple actions:

**Example: NO_FEATURE state with architecture needs**
→ Question 1: "What would you like to create?" (multiSelect: false)
  - New feature spec
  - Architecture blueprint
  - Codebase analysis

**Example: IN_PLANNING state**
→ Question 1: "Ready to proceed?" (multiSelect: false)
  - Create tasks
  - Validate consistency
  - Both (tasks + validation)

Keep questions focused and actionable - avoid overwhelming users with too many options.

## Hook Interaction

- **SessionStart hook** - Computes `NEXT-STEP.json` with recommended skill
- **UserPromptSubmit hook** - Appends workflow context to prompts
- **PostToolUse hook** - Updates workflow state after skill execution
- **Notification hook** - Surfaces next recommended skill

## Auto Mode

For fully autonomous execution across multiple phases:
- User says "auto mode" or "build this feature end-to-end"
- Claude chains skills automatically: `orbit-orchestrator` runs `orbit-lifecycle` (Define/Clarify) → `orbit-planning` (Plan/Tasks/Consistency) → `orbit-lifecycle` (Implement/Track)
- Checkpoints at phase transitions for user review

## Examples

```bash
/orbit
# State: NOT_INITIALIZED
# → Shows AskUserQuestion:
#    "Your project isn't initialized. Ready to set up?"
#    [Initialize Project] [Learn More]
# User selects → Invokes: orbit-lifecycle (Initialize)
```

```bash
/orbit
# State: NO_FEATURE
# → Shows AskUserQuestion:
#    "What would you like to do?"
#    [Start New Feature] [Analyze Codebase] [Create Architecture] [View Help]
# User selects "Start New Feature" → Invokes: orbit-lifecycle (Define)
```

```bash
/orbit
# State: IN_SPECIFICATION (with 3 [CLARIFY] tags)
# → Shows AskUserQuestion:
#    "Your spec has 3 clarifications needed. Next step?"
#    [Resolve Clarifications] [Skip to Planning] [Validate Spec Quality]
# User selects "Resolve Clarifications" → Invokes: orbit-lifecycle (Clarify)
```

```bash
/orbit
# State: IN_IMPLEMENTATION (67% complete)
# → Shows AskUserQuestion:
#    "Implementation 67% complete. Continue?"
#    [Continue Building] [Check Progress] [Update Tasks]
# User selects → Invokes appropriate skill
```

## Command Flow

1. `/orbit` invoked

2. **Check for auto-mode resume** (PRIORITY)
   ```bash
   if [ -f ".spec/state/auto-mode-session.json" ]; then
     status=$(jq -r '.status' .spec/state/auto-mode-session.json)
     expires_at=$(jq -r '.expires_at' .spec/state/auto-mode-session.json)

     if [ "$status" = "interrupted" ] || [ "$status" = "paused" ]; then
       if ! is_expired "$expires_at"; then
         # Show AUTO_MODE_RESUMABLE interface
         # Offer: Resume / Restart / Interactive
         return
       else
         # Show AUTO_MODE_EXPIRED interface
         # Clean up expired session, offer new auto-mode
         rm .spec/state/auto-mode-session.json
       fi
     fi
   fi
   ```

3. Read state from `{config.paths.state}/current-session.md` and `NEXT-STEP.json`

4. Present context summary (current phase, progress, recommendations)

5. **Show `AskUserQuestion` with context-appropriate options**
   - Include "Auto Mode" option for NO_FEATURE state
   - Standard phase-specific options for other states

6. User selects option from interactive UI

7. Claude invokes the corresponding autonomous skill
   - If "Auto Mode" selected → Invoke `orbit-orchestrator` skill
   - If "Resume" selected → Invoke `orbit-orchestrator` with resume context
   - Otherwise → Invoke phase-specific skill

8. Skill executes and updates state

9. Report completion and suggest running `/orbit` again for next step

**Key Principle**: Use `AskUserQuestion` to make the interface easy and intuitive. No need for users to remember skill names or type commands - just select from contextual options.

---

## Auto-Mode Integration

### Auto-Mode Detection

The `/orbit` command detects auto-mode sessions in this priority order:

1. **Interrupted/Paused Session** (highest priority)
   - File exists: `.spec/state/auto-mode-session.json`
   - Status: `"interrupted"` or `"paused"`
   - Not expired: `expires_at` < 24 hours ago
   - → Show resume interface immediately

2. **Expired Session**
   - File exists but expired (> 24 hours)
   - → Clean up session file, offer new auto-mode

3. **No Session**
   - Normal workflow state detection
   - → Offer auto-mode as option in NO_FEATURE state

### Invoking Auto-Mode

When user selects auto-mode option, invoke the `orbit-orchestrator` skill:

```javascript
// Pseudo-code for skill invocation
if (userSelection === "Auto Mode") {
  skill("orbit-orchestrator");
  // Skill handles:
  // - Feature input prompt
  // - Phase sequencing
  // - Checkpoints
  // - State management
}
```

### Resume Flow

When resuming interrupted session:

```javascript
// Pseudo-code for resume
if (userSelection === "Resume") {
  // Read session state
  const session = readJSON(".spec/state/auto-mode-session.json");
  const currentPhase = session.current_phase;

  // Invoke orbit-orchestrator with resume context
  skill("orbit-orchestrator", {
    mode: "resume",
    phase: currentPhase,
    sessionId: session.session_id
  });
}
```

### Restart Flow

When user chooses to restart instead of resume:

```javascript
// Pseudo-code for restart
if (userSelection === "Restart") {
  // Remove old session
  remove(".spec/state/auto-mode-session.json");

  // Start fresh auto-mode
  skill("orbit-orchestrator");
}
```

### Exit to Interactive

When user chooses interactive mode over auto-mode:

```javascript
// Pseudo-code for exit to interactive
if (userSelection === "Interactive") {
  // Remove auto-mode session
  remove(".spec/state/auto-mode-session.json");

  // Return to standard workflow detection
  // Show phase-appropriate options
}
```

### Integration with Hooks

**SessionStart Hook**:
- Checks for auto-mode session on every new session
- Updates `NEXT-STEP.json` to recommend resume if found
- Cleans up expired sessions automatically

**Notification Hook**:
- Detects "continue", "next", "proceed" keywords
- If auto-mode session active, auto-advances to next phase
- Skips showing `/orbit` menu if keyword detected

**PostToolUse Hook**:
- Updates auto-mode state after each skill execution
- Marks phases complete in session JSON
- Creates backups before phase transitions

### Auto-Mode vs Interactive Mode

| Aspect | Auto Mode | Interactive Mode |
|--------|-----------|------------------|
| **Control** | Checkpoints only | Every step |
| **Speed** | Fast (5-7 min) | Slower (15+ min) |
| **Interactions** | ~10 | ~50 |
| **Best for** | Well-defined features | Exploration, learning |
| **Resume** | Automatic | Manual |
| **State** | Session JSON | current-session.md |

### Configuration

Auto-mode behavior in `.spec/.spec-config.yml`:

```yaml
auto_mode:
  enabled: true                    # Enable auto-mode offering
  default_mode: interactive        # or "auto" to default to auto-mode
  checkpoints:
    after_spec: true
    after_clarify: true
    after_plan: true
    after_tasks: true
    before_implement: true
    timeout: 10
    default_action: continue
  session:
    expiry_hours: 24
    max_interruptions: 10
    auto_resume: true              # Auto-offer resume on /orbit
    cleanup_expired: true
```
