#!/bin/bash

# Context Compression Utility
# Reduces token usage by compressing context information

# Configuration
MAX_CONTEXT_TOKENS=3000
SUMMARY_RATIO=0.3  # Keep 30% when summarizing

# Functions
compress_context() {
    local context="$1"
    local max_tokens="${2:-$MAX_CONTEXT_TOKENS}"

    # Count approximate tokens (rough estimate: 1 token per 4 chars)
    local char_count=${#context}
    local token_estimate=$((char_count / 4))

    if [ $token_estimate -le $max_tokens ]; then
        echo "$context"
        return
    fi

    # Compression needed
    echo "## Compressed Context"
    echo ""

    # Keep recent operations in detail
    echo "### Recent Operations (Detailed)"
    echo "$context" | tail -n 20
    echo ""

    # Summarize older operations
    echo "### Historical Summary"
    echo "$context" | head -n -20 | compress_operations
}

compress_operations() {
    # Group similar operations
    local compressed=""
    local last_op=""
    local count=0

    while IFS= read -r line; do
        # Extract operation type
        op_type=$(echo "$line" | grep -oE "^[A-Z]+:" | head -1)

        if [ "$op_type" = "$last_op" ]; then
            ((count++))
        else
            if [ $count -gt 1 ]; then
                compressed+="  ($count similar operations)\\n"
            fi
            compressed+="$line\\n"
            last_op="$op_type"
            count=1
        fi
    done

    echo -e "$compressed"
}

# Prune old context
prune_context() {
    local context_file="$1"
    local max_size="${2:-10000}"  # Max file size in bytes

    if [ ! -f "$context_file" ]; then
        return
    fi

    local file_size=$(stat -f%z "$context_file" 2>/dev/null || stat -c%s "$context_file" 2>/dev/null)

    if [ "$file_size" -gt "$max_size" ]; then
        # Keep only recent content
        tail -n 100 "$context_file" > "$context_file.tmp"
        mv "$context_file.tmp" "$context_file"
        echo "Pruned context file: $context_file"
    fi
}

# Extract relevant context
extract_relevant() {
    local full_context="$1"
    local query="$2"

    # Find lines relevant to query
    echo "$full_context" | grep -i "$query" | head -20
}

# Main execution
main() {
    local action="${1:-compress}"
    local input="${2:-}"

    case "$action" in
        compress)
            if [ -z "$input" ]; then
                # Read from stdin
                compress_context "$(cat)"
            else
                compress_context "$input"
            fi
            ;;
        prune)
            prune_context "$input"
            ;;
        extract)
            local query="${3:-}"
            extract_relevant "$input" "$query"
            ;;
        *)
            echo "Usage: $0 {compress|prune|extract} [input] [query]"
            exit 1
            ;;
    esac
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi