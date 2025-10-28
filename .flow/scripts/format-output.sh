#!/bin/bash
# Flow Output Formatting Utilities
# Provides consistent visual formatting for Flow command outputs

# Format TLDR section with box separators
format_tldr() {
  local content="$1"
  cat <<EOF
───────────────────────────────────────
📦 TLDR
───────────────────────────────────────
$content
───────────────────────────────────────
EOF
}

# Format Next Steps section with box separators
format_next_steps() {
  local steps="$1"
  cat <<EOF
───────────────────────────────────────
🚀 NEXT STEPS
───────────────────────────────────────
$steps
───────────────────────────────────────
EOF
}

# Create section separator line
format_section_separator() {
  echo "───────────────────────────────────────"
}

# Format status indicator based on status
# Usage: format_status_indicator "completed|next|pending|error|warning"
format_status_indicator() {
  local status="$1"

  case "$status" in
    completed|done|complete)
      echo "✅"
      ;;
    next|recommended|current)
      echo "➡️"
      ;;
    pending|waiting|notready)
      echo "⏳"
      ;;
    error|failed)
      echo "❌"
      ;;
    warning|caution)
      echo "⚠️"
      ;;
    info)
      echo "ℹ️"
      ;;
    success)
      echo "✅"
      ;;
    *)
      echo "•"
      ;;
  esac
}

# Format success header
format_success_header() {
  local title="$1"
  echo ""
  echo "## ✅ $title"
  echo ""
}

# Format error header
format_error_header() {
  local title="$1"
  echo ""
  echo "## ❌ $title"
  echo ""
}

# Format warning header
format_warning_header() {
  local title="$1"
  echo ""
  echo "## ⚠️ $title"
  echo ""
}

# Format info header
format_info_header() {
  local title="$1"
  echo ""
  echo "## ℹ️ $title"
  echo ""
}

# Format a list item with bullet
format_list_item() {
  local item="$1"
  echo "• $item"
}

# Format a numbered list item
format_numbered_item() {
  local number="$1"
  local item="$2"
  echo "$number. $item"
}

# Format a command block
format_command() {
  local command="$1"
  echo "   \`$command\`"
}

# Format a complete success message with TLDR and Next Steps
format_complete_success() {
  local title="$1"
  local tldr_content="$2"
  local details_content="$3"
  local next_steps_content="$4"

  format_success_header "$title"

  if [ -n "$tldr_content" ]; then
    format_tldr "$tldr_content"
    echo ""
  fi

  if [ -n "$details_content" ]; then
    echo "$details_content"
    echo ""
  fi

  if [ -n "$next_steps_content" ]; then
    format_next_steps "$next_steps_content"
  fi
}

# Format progress bar
# Usage: format_progress_bar 7 10 (7 out of 10 complete)
format_progress_bar() {
  local completed="$1"
  local total="$2"
  local width=20

  if [ "$total" -eq 0 ]; then
    echo "[          ] 0%"
    return
  fi

  local percentage=$((completed * 100 / total))
  local filled=$((completed * width / total))
  local empty=$((width - filled))

  printf "["
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "] %d%% (%d/%d)\n" "$percentage" "$completed" "$total"
}

# Format task status
format_task_status() {
  local status="$1"
  local task_id="$2"
  local description="$3"

  local indicator=$(format_status_indicator "$status")
  echo "$indicator $task_id: $description"
}

# Format section header
format_section_header() {
  local title="$1"
  echo ""
  echo "## 📂 $title"
  echo ""
}

# Export functions for use in other scripts
export -f format_tldr
export -f format_next_steps
export -f format_section_separator
export -f format_status_indicator
export -f format_success_header
export -f format_error_header
export -f format_warning_header
export -f format_info_header
export -f format_list_item
export -f format_numbered_item
export -f format_command
export -f format_complete_success
export -f format_progress_bar
export -f format_task_status
export -f format_section_header
