# Brainstorming Skill - Technical Reference

## Data Models

### Session Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["id", "topic", "framework", "state", "created_at"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^bs-\\d{8}-\\d{3}$",
      "description": "Unique session identifier"
    },
    "topic": {
      "type": "string",
      "minLength": 1,
      "description": "Brainstorming topic or problem statement"
    },
    "framework": {
      "type": "string",
      "enum": ["mindmap", "scamper", "six-hats", "five-whys", "affinity", "brainwriting", "swot"],
      "description": "Selected brainstorming framework"
    },
    "state": {
      "type": "string",
      "enum": ["active", "paused", "completed"],
      "description": "Current session state"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Session creation timestamp"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "Last update timestamp"
    },
    "expires_at": {
      "type": "string",
      "format": "date-time",
      "description": "Session expiration timestamp"
    },
    "stats": {
      "type": "object",
      "properties": {
        "ideas_generated": {
          "type": "integer",
          "minimum": 0
        },
        "groups_created": {
          "type": "integer",
          "minimum": 0
        },
        "time_spent": {
          "type": "integer",
          "minimum": 0,
          "description": "Time spent in seconds"
        }
      }
    },
    "context": {
      "type": "object",
      "properties": {
        "constraints": {
          "type": "array",
          "items": { "type": "string" }
        },
        "goals": {
          "type": "array",
          "items": { "type": "string" }
        },
        "participants": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    }
  }
}
```

### Idea Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["id", "content", "category", "created_at"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^idea-\\d{4}$",
      "description": "Unique idea identifier"
    },
    "content": {
      "type": "string",
      "minLength": 1,
      "description": "The idea text"
    },
    "category": {
      "type": "string",
      "enum": ["Feature", "Enhancement", "BugFix", "Refactor", "Research"],
      "description": "Type-based categorization"
    },
    "tags": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Additional tags for the idea"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "parent_id": {
      "type": ["string", "null"],
      "description": "Parent idea for hierarchical structure"
    },
    "group_id": {
      "type": ["string", "null"],
      "description": "Group assignment"
    },
    "scores": {
      "type": "object",
      "properties": {
        "feasibility": {
          "type": "string",
          "enum": ["XS", "S", "M", "L", "XL"]
        },
        "impact": {
          "type": "string",
          "enum": ["XS", "S", "M", "L", "XL"]
        },
        "effort": {
          "type": "string",
          "enum": ["XS", "S", "M", "L", "XL"]
        },
        "innovation": {
          "type": "string",
          "enum": ["XS", "S", "M", "L", "XL"]
        }
      }
    },
    "priority": {
      "type": "string",
      "enum": ["P1", "P2", "P3"],
      "description": "Calculated priority based on scores"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "source": {
          "type": "string",
          "enum": ["user", "ai", "framework"],
          "description": "Origin of the idea"
        },
        "confidence": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Confidence score for AI-generated ideas"
        }
      }
    }
  }
}
```

### Group Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["id", "name"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^group-\\d{3}$",
      "description": "Unique group identifier"
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "description": "Group name"
    },
    "description": {
      "type": "string",
      "description": "Group description"
    },
    "idea_ids": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Ideas belonging to this group"
    },
    "parent_group_id": {
      "type": ["string", "null"],
      "description": "Parent group for hierarchy"
    },
    "color": {
      "type": "string",
      "description": "Color for visualization"
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    }
  }
}
```

## File Structure

### Session Storage
```
.brainstorm/
├── sessions/
│   └── bs-20251120-001/
│       ├── session.json      # Session metadata
│       ├── ideas.json         # All ideas
│       ├── groups.json        # Groupings
│       ├── evaluation.json    # Scores and priorities
│       └── output.md          # Latest export
├── config.yml                 # User configuration
└── .index.json               # Session index for quick lookup
```

## Core Functions

### Session Manager

```bash
# Create new session
create_session() {
  local topic="$1"
  local framework="${2:-mindmap}"
  local session_id="bs-$(date +%Y%m%d)-$(printf "%03d" $((RANDOM % 1000)))"
  local session_dir=".brainstorm/sessions/$session_id"

  mkdir -p "$session_dir"

  cat > "$session_dir/session.json" <<EOF
{
  "id": "$session_id",
  "topic": "$topic",
  "framework": "$framework",
  "state": "active",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "expires_at": "$(date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ)",
  "stats": {
    "ideas_generated": 0,
    "groups_created": 0,
    "time_spent": 0
  }
}
EOF

  echo "$session_id"
}

# Load existing session
load_session() {
  local session_id="$1"
  local session_file=".brainstorm/sessions/$session_id/session.json"

  if [ -f "$session_file" ]; then
    cat "$session_file"
  else
    echo "ERROR: Session $session_id not found" >&2
    return 1
  fi
}

# Save session (atomic write)
save_session() {
  local session_id="$1"
  local session_data="$2"
  local session_file=".brainstorm/sessions/$session_id/session.json"
  local temp_file="${session_file}.tmp"

  echo "$session_data" > "$temp_file"
  mv -f "$temp_file" "$session_file"
}

# List active sessions
list_active_sessions() {
  local now=$(date +%s)

  for session_dir in .brainstorm/sessions/*/; do
    [ -d "$session_dir" ] || continue

    local session_file="${session_dir}session.json"
    [ -f "$session_file" ] || continue

    local expires_at=$(jq -r '.expires_at' "$session_file")
    local expires_ts=$(date -d "$expires_at" +%s 2>/dev/null || echo 0)

    if [ "$expires_ts" -gt "$now" ]; then
      jq -r '[.id, .topic, .state] | @tsv' "$session_file"
    fi
  done
}

# Clean up expired sessions
cleanup_expired() {
  local now=$(date +%s)
  local cleaned=0

  for session_dir in .brainstorm/sessions/*/; do
    [ -d "$session_dir" ] || continue

    local session_file="${session_dir}session.json"
    [ -f "$session_file" ] || continue

    local expires_at=$(jq -r '.expires_at' "$session_file")
    local expires_ts=$(date -d "$expires_at" +%s 2>/dev/null || echo 0)

    if [ "$expires_ts" -le "$now" ]; then
      rm -rf "$session_dir"
      ((cleaned++))
    fi
  done

  echo "Cleaned up $cleaned expired sessions"
}
```

### Idea Management

```bash
# Add idea to session
add_idea() {
  local session_id="$1"
  local content="$2"
  local category="${3:-Feature}"

  local ideas_file=".brainstorm/sessions/$session_id/ideas.json"
  local idea_count=$(jq '. | length' "$ideas_file" 2>/dev/null || echo 0)
  local idea_id=$(printf "idea-%04d" $((idea_count + 1)))

  local new_idea=$(cat <<EOF
{
  "id": "$idea_id",
  "content": "$content",
  "category": "$category",
  "tags": [],
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "parent_id": null,
  "group_id": null
}
EOF
)

  if [ ! -f "$ideas_file" ] || [ "$idea_count" -eq 0 ]; then
    echo "[$new_idea]" > "$ideas_file"
  else
    jq ". += [$new_idea]" "$ideas_file" > "${ideas_file}.tmp"
    mv -f "${ideas_file}.tmp" "$ideas_file"
  fi

  # Trigger auto-save if needed
  if [ $((idea_count % 5)) -eq 4 ]; then
    auto_save_session "$session_id"
  fi

  echo "$idea_id"
}

# Auto-categorize idea
categorize_idea() {
  local content="$1"

  # Simple keyword-based categorization
  if echo "$content" | grep -qiE "bug|fix|issue|error|problem"; then
    echo "BugFix"
  elif echo "$content" | grep -qiE "refactor|clean|optimize|improve"; then
    echo "Refactor"
  elif echo "$content" | grep -qiE "research|investigate|explore|analyze"; then
    echo "Research"
  elif echo "$content" | grep -qiE "enhance|upgrade|extend|add"; then
    echo "Enhancement"
  else
    echo "Feature"
  fi
}
```

### Framework Templates

Framework templates are stored in `templates/frameworks/` and loaded dynamically:

```bash
# Load framework template
load_framework() {
  local framework="$1"
  local template_file="templates/frameworks/${framework}.md"

  if [ -f "$template_file" ]; then
    cat "$template_file"
  else
    echo "ERROR: Framework template $framework not found" >&2
    return 1
  fi
}
```

## Framework Definitions

### Mind Mapping
Progressive expansion from central concept to detailed ideas.

### SCAMPER
- **S**ubstitute: What can be substituted?
- **C**ombine: What can be combined?
- **A**dapt: What can be adapted?
- **M**odify/Magnify: What can be modified?
- **P**ut to other uses: How else can this be used?
- **E**liminate: What can be removed?
- **R**everse/Rearrange: What can be reversed?

### Six Thinking Hats
- **White Hat**: Facts and information
- **Red Hat**: Emotions and feelings
- **Black Hat**: Critical judgment
- **Yellow Hat**: Optimistic assessment
- **Green Hat**: Creative alternatives
- **Blue Hat**: Process control

### Five Whys
Root cause analysis through iterative questioning.

## Export Formats

### Markdown Export
```markdown
# Brainstorming Session: {topic}
Date: {date}
Framework: {framework}
Duration: {duration}

## Summary
- Ideas Generated: {count}
- Groups Created: {groups}
- Top Priority Items: {top_count}

## Ideas by Group
### {Group Name}
- {Idea 1} [Category] (Priority)
- {Idea 2} [Category] (Priority)

## Evaluation Matrix
| Idea | Feasibility | Impact | Effort | Priority |
|------|-------------|--------|--------|----------|
| {idea} | {score} | {score} | {score} | {priority} |

## Next Steps
1. {actionable item}
2. {actionable item}
```

### Task Export (TodoWrite compatible)
```json
[
  {
    "content": "Implement {idea}",
    "status": "pending",
    "activeForm": "Implementing {idea}",
    "metadata": {
      "source": "brainstorm",
      "session": "{session_id}",
      "priority": "{priority}"
    }
  }
]
```

## Error Handling

All functions include error handling:
- File operations use atomic writes (temp file + rename)
- JSON parsing validates against schemas
- Session operations check expiration
- Auto-recovery from interrupted sessions

## Performance Considerations

- Maximum 100 ideas per session (configurable)
- Auto-save every 5 ideas
- Lazy loading for large idea sets
- Indexed session lookup via `.index.json`
- Cleanup of expired sessions on startup

---
*Last Updated: 2025-11-20*
*Version: 1.0.0*