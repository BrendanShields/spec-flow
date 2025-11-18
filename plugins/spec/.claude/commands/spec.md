# Spec

Primary slash command that opens the Spec Workflow Navigator skill (`skills/workflow/skill.md`). The command itself stays intentionally thin—its only job is to collect a hint about the user’s current state, show the menu shell, and hand off control to the workflow skill.

## What This Command Does

- Detects whether `.spec/` and `{config.paths.state}/current-session.md` exist.
- Reads `.spec/state/NEXT-STEP.json` (cached by hooks) to pre-select the recommended action.
- Builds an option catalog (Initialize, Auto Mode, etc.) and lets AskUserAgent highlight the best subset for the current phase.
- Invokes the `workflow` skill with the user’s selection and any cached hints.
- Loops until the user exits, letting the skill perform all real work (phase guides, auto mode orchestration, help, etc.).

All menu definitions, phase transitions, and auto-mode details live in `skills/workflow/skill.md`. Keep that file authoritative—do not duplicate the logic here.

## Request Flow

1. **Load cached hints**
   - If `{config.paths.state}/NEXT-STEP.json` exists, parse it for `action`, `phase`, and `feature`.
   - Fallback: read frontmatter from `{config.paths.state}/current-session.md` if the cache is missing or stale.

2. **Surface the adaptive menu**
   - Assemble the canonical option catalog from `skills/workflow/skill.md` (single table lists every action, target skill, and valid states).
   - Call **AskUserAgent** with the current context (`phase`, `feature`, cached `action`) plus the full option list. AskUserAgent decides how many actions to show and in what priority, so we only describe each option once.
   - The tool returns the user’s choice; no manual branching per state is needed.

3. **Invoke the workflow skill**
   - Forward the user’s choice plus any cached hints to the `workflow` skill.
   - The skill decides which guide to run (`phases/*/guide.md`), whether to enter Auto Mode, and when to request additional confirmation.

4. **Loop**
   - After the skill returns, offer to run another option or exit.

## Hook Interaction

- **SessionStart / PostToolUse hooks** compute `.spec/state/NEXT-STEP.json`, so `/spec` can instantly suggest the right action.
- **UserPromptSubmit hook** appends `[Spec Workflow Context]` to manual prompts, ensuring Claude retains feature/phase context outside `/spec`.
- **Notification hook** surfaces the cached next step whenever Claude is waiting for user input.

Hook implementations live in `.claude/hooks/*.sh`; keep this command logic in sync with those scripts.

## Examples

```bash
/spec
# → Detects missing .spec/, highlights “Initialize Project”, invokes workflow skill → phases/1-initialize/init/guide.md
```

```bash
/spec
# → Existing feature (phase=implementation), cached action “validate” → menu focuses “Validate”.
#    workflow skill runs phases/3-design/analyze/guide.md and reports results.
```

```bash
/spec
# → User selects Auto Mode → workflow skill orchestrates phases/2-define → 3-design → 4-build with checkpoints.
```

For the complete menu tree, auto-mode timeline, and help topics, read `skills/workflow/skill.md`.
