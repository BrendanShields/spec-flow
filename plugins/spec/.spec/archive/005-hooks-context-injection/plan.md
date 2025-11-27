# Technical Plan: Hooks Context Injection

## Architecture

SessionStart hook outputs minimal JSON that Claude receives as context:

```json
{
  "orbit": {
    "initialized": true,
    "features": [
      {"id": "001-feature", "status": "implementation", "progress": "3/10"}
    ],
    "suggestion": "Continue implementing 001-feature"
  }
}
```

## Minimal Context Schema

```typescript
interface OrbitContext {
  orbit: {
    initialized: boolean;           // .spec/ exists
    features: FeatureSummary[];     // Active features only
    suggestion: string;             // One-line next action
  }
}

interface FeatureSummary {
  id: string;                       // e.g., "001-auth"
  title: string;                    // e.g., "User Authentication"
  status: string;                   // specification|planning|implementation|etc
  progress?: string;                // e.g., "3/10" for implementation
}
```

## Hook Fixes

### orbit-init.sh (SessionStart)

```bash
#!/usr/bin/env bash
# SessionStart: Output minimal context for Claude

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SPEC_DIR="${PROJECT_DIR}/.spec"

# Check if initialized
if [[ ! -d "${SPEC_DIR}" ]]; then
  echo '{"orbit":{"initialized":false,"features":[],"suggestion":"Run /orbit to initialize"}}'
  exit 0
fi

# Scan features and output minimal context
python3 << 'PYTHON'
# ... minimal scanning logic
PYTHON
```

### orbit-protect.sh (PreToolUse)

Fix JSON path extraction:
```python
# Before (wrong)
json.load(sys.stdin).get('file_path', '')

# After (correct per docs)
data = json.load(sys.stdin)
file_path = data.get('tool_input', {}).get('file_path', '')
```

### orbit-log.sh (PostToolUse)

Fix field names:
```python
# Before (wrong)
tool = data.get('tool', '')

# After (correct per docs)
tool_name = data.get('tool_name', '')
```

## Components

| File | Change |
|------|--------|
| orbit-init.sh | Rewrite to output minimal context JSON |
| orbit-protect.sh | Fix `tool_input.file_path` extraction |
| orbit-log.sh | Fix `tool_name` extraction |

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Context too large | Wastes tokens | Keep to ~10 lines JSON max |
| Python not available | Hook fails | Fallback to bash-only output |
