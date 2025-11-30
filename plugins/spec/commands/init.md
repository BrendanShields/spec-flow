---
description: Initialize the Orbit specification workflow for this project.
---

# Init

Explicitly initializes the `.spec/` directory structure and starts the first feature.

1. Create directory structure:
   ```bash
   mkdir -p .spec/features .spec/architecture .spec/state .spec/archive
   echo '{"feature": null}' > .spec/state/session.json
   ```
2. Invoke `managing-workflow` skill to start first feature.
