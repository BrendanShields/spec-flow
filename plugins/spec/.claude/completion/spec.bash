#!/bin/bash
# Bash completion for /spec command

_spec_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Main subcommands
    local subcommands="init plan tasks implement specify clarify analyze validate metrics status team assign lock unlock master-spec help"

    # Options/flags
    local flags="--help --interactive --examples --reference --update --continue"

    case "${prev}" in
        /spec|spec)
            # Complete subcommands and flags
            COMPREPLY=( $(compgen -W "${subcommands} ${flags}" -- ${cur}) )
            return 0
            ;;
        assign)
            # Complete with @usernames from git
            local users=$(git log --format='%an' | sort -u | sed 's/^/@/')
            COMPREPLY=( $(compgen -W "${users}" -- ${cur}) )
            return 0
            ;;
        lock|unlock)
            # Complete with feature IDs from features/ directory
            if [[ -d "features" ]]; then
                local features=$(ls -1 features/ 2>/dev/null | grep -E '^[0-9]+-' | cut -d'-' -f1)
                COMPREPLY=( $(compgen -W "${features}" -- ${cur}) )
            fi
            return 0
            ;;
        *)
            # Default to files/directories
            COMPREPLY=( $(compgen -f -- ${cur}) )
            return 0
            ;;
    esac
}

# Register completion
complete -F _spec_completion spec
complete -F _spec_completion /spec

# Also complete for the emoji version if it exists
complete -F _spec_completion 👻
complete -F _spec_completion /👻
