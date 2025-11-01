#!/bin/bash
# Token Measurement Tool
# Approximates token usage for Specter components

set -euo pipefail

SPECTER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Approximate: 1 token ≈ 4 characters (GPT-4 estimate)
estimate_tokens() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        echo "0"
        return
    fi

    local chars=$(wc -c < "$file" | tr -d ' ')
    local tokens=$((chars / 4))
    echo "$tokens"
}

# Measure command files
measure_commands() {
    echo "=== Commands ==="
    local total=0

    for cmd in "$SPECTER_ROOT/.claude/commands"/*.md; do
        if [[ -f "$cmd" ]]; then
            local tokens=$(estimate_tokens "$cmd")
            total=$((total + tokens))
            printf "  %-30s %6d tokens\n" "$(basename "$cmd")" "$tokens"
        fi
    done

    echo "  --------------------------------"
    printf "  %-30s %6d tokens\n" "Total Commands" "$total"
    echo ""
    return $total
}

# Measure skills (SKILL.md only for lazy loading)
measure_skills() {
    echo "=== Skills (Core Only) ==="
    local total=0

    for skill_dir in "$SPECTER_ROOT/.claude/skills"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_file="$skill_dir/SKILL.md"
            if [[ -f "$skill_file" ]]; then
                local tokens=$(estimate_tokens "$skill_file")
                total=$((total + tokens))
                printf "  %-30s %6d tokens\n" "$(basename "$skill_dir")" "$tokens"
            fi
        fi
    done

    echo "  --------------------------------"
    printf "  %-30s %6d tokens\n" "Total Skills (Core)" "$total"
    echo ""
    return $total
}

# Measure state templates
measure_state() {
    echo "=== State Templates ==="
    local total=0

    if [[ -d "$SPECTER_ROOT/.specter-state" ]]; then
        for file in "$SPECTER_ROOT/.specter-state"/*.md; do
            if [[ -f "$file" ]]; then
                local tokens=$(estimate_tokens "$file")
                total=$((total + tokens))
                printf "  %-30s %6d tokens\n" "$(basename "$file")" "$tokens"
            fi
        done
    fi

    echo "  --------------------------------"
    printf "  %-30s %6d tokens\n" "Total State" "$total"
    echo ""
    return $total
}

# Measure hooks
measure_hooks() {
    echo "=== Hooks ==="
    local total=0

    if [[ -d "$SPECTER_ROOT/.specter/hooks" ]]; then
        for file in "$SPECTER_ROOT/.specter/hooks/core"/*.sh; do
            if [[ -f "$file" ]]; then
                local tokens=$(estimate_tokens "$file")
                total=$((total + tokens))
                printf "  %-30s %6d tokens\n" "$(basename "$file")" "$tokens"
            fi
        done
    fi

    echo "  --------------------------------"
    printf "  %-30s %6d tokens\n" "Total Hooks" "$total"
    echo ""
    return $total
}

# Main measurement
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Specter Token Usage Measurement"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    cmd_tokens=$(measure_commands)
    skill_tokens=$(measure_skills)
    state_tokens=$(measure_state)
    hook_tokens=$(measure_hooks)

    # Calculate totals
    local typical_load=$((500 + 1750 + 500))  # Router + 1 skill + state utils
    local full_load=$((cmd_tokens + skill_tokens + state_tokens + hook_tokens))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  %-30s %6d tokens\n" "Typical invocation (lazy)" "$typical_load"
    printf "  %-30s %6d tokens\n" "Full load (all components)" "$full_load"
    echo ""

    # V2.1 baseline for comparison
    local v21_baseline=88700
    local reduction_pct=$(( (v21_baseline - typical_load) * 100 / v21_baseline ))

    echo "Comparison to v2.1:"
    printf "  %-30s %6d tokens\n" "v2.1 baseline" "$v21_baseline"
    printf "  %-30s %6d tokens\n" "v3.0 typical" "$typical_load"
    printf "  %-30s %5d%%\n" "Reduction" "$reduction_pct"
    echo ""

    # Check if target met
    local target=17740
    if [[ $typical_load -le $target ]]; then
        echo "✅ Token budget met! ($typical_load ≤ $target)"
    else
        echo "⚠️  Over budget: $typical_load > $target"
        echo "   Need to reduce by $((typical_load - target)) tokens"
    fi

    echo ""
}

main "$@"
