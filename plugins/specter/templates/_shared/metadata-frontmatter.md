# Metadata Frontmatter

## Standard Document Header

```markdown
---
feature_id: ###-feature-name
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft|review|approved|implemented
priority: P1|P2|P3
---
```

## Extended Metadata

```markdown
---
feature_id: ###-feature-name
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft
priority: P1
author: Name
reviewers: [Name1, Name2]
jira_id: PROJ-123
confluence_id: 12345678
tags: [tag1, tag2]
---
```

## Status Values

- `draft`: Initial creation
- `review`: Under review
- `approved`: Approved for implementation
- `implemented`: Completed
- `deprecated`: No longer valid

## Auto-generated Fields

These fields are updated automatically:
- `updated`: Last modification timestamp
- `version`: Incremented on changes
- `checksum`: Content verification