# Custom Specter Hooks

Add your own hooks here to extend Specter's automation.

## Example

Create a file `my-hook.sh`:

```bash
#!/bin/bash
# Custom hook example

set -euo pipefail

# Read context from stdin
context=$(cat)

# Your custom logic here
echo "Custom hook executed!"
```

## Register

Add to `../config.json`:

```json
{
  "hooks": {
    "post-command": {
      "scripts": [
        "core/post-command.sh",
        "custom/my-hook.sh"
      ]
    }
  }
}
```

See `docs/CUSTOM-HOOKS-API.md` for full API documentation.
