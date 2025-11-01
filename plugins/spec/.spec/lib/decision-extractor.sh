#!/bin/bash
# Spec Decision Extractor
# Extract architectural decisions from plan.md

set -euo pipefail

SPEC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_ROOT="$(cd "$SPEC_LIB_DIR/../.." && pwd)"

source "$SPEC_ROOT/.spec/lib/state-sync.sh"

##
# Extract ADRs from plan.md and log to decisions.json
#
# Usage: spec_extract_decisions <plan_file> <feature_id>
#
spec_extract_decisions() {
  local plan_file=$1
  local feature_id=$2

  if [[ ! -f "$plan_file" ]]; then
    echo "⚠️  Plan file not found: $plan_file" >&2
    return 1
  fi

  local decisions_json="$SPEC_ROOT/.spec-memory/decisions.json"
  local decisions_count=0

  # Initialize decisions.json if it doesn't exist
  if [[ ! -f "$decisions_json" ]]; then
    echo "[]" > "$decisions_json"
  fi

  # Parse ADRs using awk
  local temp_decisions=$(mktemp)

  awk -v feature_id="$feature_id" -v date="$(date +%Y-%m-%d)" '
    BEGIN {
      in_adr=0
      adr_id=""
      title=""
      decision=""
      context=""
      mode=""
      first_output=1
    }

    /^### ADR-[0-9]+:/ {
      # Output previous ADR if exists
      if (in_adr && adr_id != "") {
        if (!first_output) printf ","
        first_output=0
        # Clean up strings (remove quotes, newlines)
        gsub(/"/, "\\\"", title)
        gsub(/"/, "\\\"", decision)
        gsub(/"/, "\\\"", context)
        gsub(/\n/, " ", decision)
        gsub(/\n/, " ", context)
        printf "{\"id\":\"%s\",\"title\":\"%s\",\"decision\":\"%s\",\"context\":\"%s\",\"feature\":\"%s\",\"date\":\"%s\"}\n",
          adr_id, title, decision, context, feature_id, date
      }

      # Start new ADR
      in_adr=1
      match($0, /ADR-[0-9]+/)
      adr_id=substr($0, RSTART, RLENGTH)
      title=$0
      sub(/^### ADR-[0-9]+: */, "", title)
      decision=""
      context=""
      mode=""
      next
    }

    /^\*\*Decision\*\*:/ {
      mode="decision"
      sub(/^\*\*Decision\*\*: */, "")
      decision=$0
      next
    }

    /^\*\*Context\*\*:/ {
      mode="context"
      sub(/^\*\*Context\*\*: */, "")
      context=$0
      next
    }

    /^\*\*Implementation\*\*:/ || /^\*\*Benefits\*\*:/ || /^\*\*Effort\*\*:/ {
      mode=""
      next
    }

    /^###/ && in_adr {
      # End of current ADR
      next
    }

    in_adr && mode=="decision" && NF > 0 {
      if (decision != "") decision = decision " "
      decision = decision $0
    }

    in_adr && mode=="context" && NF > 0 {
      if (context != "") context = context " "
      context = context $0
    }

    END {
      # Output last ADR
      if (in_adr && adr_id != "") {
        if (!first_output) printf ","
        gsub(/"/, "\\\"", title)
        gsub(/"/, "\\\"", decision)
        gsub(/"/, "\\\"", context)
        gsub(/\n/, " ", decision)
        gsub(/\n/, " ", context)
        printf "{\"id\":\"%s\",\"title\":\"%s\",\"decision\":\"%s\",\"context\":\"%s\",\"feature\":\"%s\",\"date\":\"%s\"}",
          adr_id, title, decision, context, feature_id, date
      }
    }
  ' "$plan_file" > "$temp_decisions"

  # Append to decisions.json
  if [[ -s "$temp_decisions" ]]; then
    local current_decisions=$(cat "$decisions_json")
    local new_decisions=$(cat "$temp_decisions")

    # Merge arrays
    echo "$current_decisions" | jq ". += [$new_decisions]" > "${decisions_json}.tmp"
    mv "${decisions_json}.tmp" "$decisions_json"

    # Count extracted decisions
    decisions_count=$(echo "$new_decisions" | grep -o '"id"' | wc -l | tr -d ' ')

    echo "✅ Extracted $decisions_count decision(s) from $feature_id"
  else
    echo "⚠️  No ADRs found in $plan_file"
  fi

  rm -f "$temp_decisions"

  # Regenerate DECISIONS-LOG.md
  spec_generate_md "$decisions_json" > "$SPEC_ROOT/.spec-memory/DECISIONS-LOG.md"

  return 0
}

# Export function
export -f spec_extract_decisions
