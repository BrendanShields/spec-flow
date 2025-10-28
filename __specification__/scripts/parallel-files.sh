#!/bin/bash

# Parallel File Operations Utility
# Enables concurrent file processing for improved performance

# Source parallel executor
source "$(dirname "$0")/parallel-executor.sh"

# Configuration
MAX_FILE_WORKERS=${NAVI_MAX_FILE_WORKERS:-6}
CHUNK_SIZE=10  # Files per batch

# Parallel file reading
parallel_read() {
    local files=("$@")
    local temp_dir="/tmp/navi-parallel-read-$$"
    mkdir -p "$temp_dir"

    # Create tasks file
    local tasks_file="$temp_dir/read-tasks.txt"
    > "$tasks_file"

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            task_id=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
            echo "${task_id}|cat '$file' > '$temp_dir/${task_id}.content'" >> "$tasks_file"
        fi
    done

    # Execute in parallel
    MAX_WORKERS=$MAX_FILE_WORKERS execute_parallel "$tasks_file"

    # Collect results
    for file in "${files[@]}"; do
        task_id=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
        if [ -f "$temp_dir/${task_id}.content" ]; then
            echo "=== $file ==="
            cat "$temp_dir/${task_id}.content"
            echo ""
        fi
    done

    # Cleanup
    rm -rf "$temp_dir"
}

# Parallel file searching
parallel_search() {
    local pattern="$1"
    shift
    local paths=("$@")
    local temp_dir="/tmp/navi-parallel-search-$$"
    mkdir -p "$temp_dir"

    # Create tasks file
    local tasks_file="$temp_dir/search-tasks.txt"
    > "$tasks_file"

    for path in "${paths[@]}"; do
        task_id=$(echo "$path" | sed 's/[^a-zA-Z0-9]/_/g')
        echo "${task_id}|grep -r '$pattern' '$path' 2>/dev/null > '$temp_dir/${task_id}.results'" >> "$tasks_file"
    done

    # Execute in parallel
    MAX_WORKERS=$MAX_FILE_WORKERS execute_parallel "$tasks_file"

    # Collect and display results
    for path in "${paths[@]}"; do
        task_id=$(echo "$path" | sed 's/[^a-zA-Z0-9]/_/g')
        if [ -s "$temp_dir/${task_id}.results" ]; then
            cat "$temp_dir/${task_id}.results"
        fi
    done

    # Cleanup
    rm -rf "$temp_dir"
}

# Parallel file transformation
parallel_transform() {
    local command="$1"
    shift
    local files=("$@")
    local temp_dir="/tmp/navi-parallel-transform-$$"
    mkdir -p "$temp_dir"

    # Create tasks file
    local tasks_file="$temp_dir/transform-tasks.txt"
    > "$tasks_file"

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            task_id=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
            # Apply transformation command to each file
            echo "${task_id}|$command '$file'" >> "$tasks_file"
        fi
    done

    # Execute in parallel
    MAX_WORKERS=$MAX_FILE_WORKERS execute_parallel "$tasks_file"

    # Cleanup
    rm -rf "$temp_dir"
}

# Parallel file validation
parallel_validate() {
    local validation_script="$1"
    shift
    local files=("$@")
    local temp_dir="/tmp/navi-parallel-validate-$$"
    mkdir -p "$temp_dir"

    # Create tasks file
    local tasks_file="$temp_dir/validate-tasks.txt"
    > "$tasks_file"

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            task_id=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
            echo "${task_id}|$validation_script '$file' > '$temp_dir/${task_id}.validation' 2>&1" >> "$tasks_file"
        fi
    done

    # Execute in parallel
    MAX_WORKERS=$MAX_FILE_WORKERS execute_parallel "$tasks_file"

    # Report results
    echo "## Validation Results"
    echo ""

    local passed=0
    local failed=0

    for file in "${files[@]}"; do
        task_id=$(basename "$file" | sed 's/[^a-zA-Z0-9]/_/g')
        if [ -f "$temp_dir/${task_id}.validation" ]; then
            if grep -q "PASS" "$temp_dir/${task_id}.validation" 2>/dev/null; then
                echo "✓ $file - Passed"
                ((passed++))
            else
                echo "✗ $file - Failed"
                cat "$temp_dir/${task_id}.validation"
                ((failed++))
            fi
        fi
    done

    echo ""
    echo "Total: $((passed + failed)) | Passed: $passed | Failed: $failed"

    # Cleanup
    rm -rf "$temp_dir"

    return $failed
}

# Batch file operations
batch_process() {
    local operation="$1"
    local file_list="$2"
    local batch_size="${3:-$CHUNK_SIZE}"

    if [ ! -f "$file_list" ]; then
        echo "Error: File list not found: $file_list"
        return 1
    fi

    local total_files=$(wc -l < "$file_list")
    local processed=0

    echo "Processing $total_files files in batches of $batch_size..."

    # Process files in chunks
    while IFS= read -r batch; do
        files=($batch)

        case "$operation" in
            read)
                parallel_read "${files[@]}"
                ;;
            validate)
                validation_script="${4:-/bin/true}"
                parallel_validate "$validation_script" "${files[@]}"
                ;;
            transform)
                command="${4:-echo}"
                parallel_transform "$command" "${files[@]}"
                ;;
            *)
                echo "Unknown operation: $operation"
                return 1
                ;;
        esac

        processed=$((processed + ${#files[@]}))
        echo "Progress: $processed / $total_files"
    done < <(xargs -n "$batch_size" < "$file_list")
}

# Find and process files in parallel
find_and_process() {
    local find_pattern="$1"
    local operation="$2"
    local base_dir="${3:-.}"

    local temp_file="/tmp/navi-files-$$.txt"

    # Find files matching pattern
    find "$base_dir" -name "$find_pattern" -type f > "$temp_file"

    local count=$(wc -l < "$temp_file")
    echo "Found $count files matching '$find_pattern'"

    if [ "$count" -gt 0 ]; then
        batch_process "$operation" "$temp_file"
    fi

    rm -f "$temp_file"
}

# Performance comparison
benchmark_operation() {
    local operation="$1"
    shift
    local files=("$@")

    echo "## Benchmarking: $operation"
    echo ""

    # Sequential execution
    echo "Sequential execution:"
    time {
        for file in "${files[@]}"; do
            case "$operation" in
                read)
                    cat "$file" > /dev/null 2>&1
                    ;;
                validate)
                    test -f "$file"
                    ;;
                *)
                    true
                    ;;
            esac
        done
    }

    echo ""
    echo "Parallel execution:"
    time {
        case "$operation" in
            read)
                parallel_read "${files[@]}" > /dev/null 2>&1
                ;;
            validate)
                parallel_validate "/bin/test -f" "${files[@]}" > /dev/null 2>&1
                ;;
            *)
                true
                ;;
        esac
    }
}

# Main execution
main() {
    local action="${1:-help}"
    shift

    case "$action" in
        read)
            parallel_read "$@"
            ;;
        search)
            pattern="$1"
            shift
            parallel_search "$pattern" "$@"
            ;;
        transform)
            command="$1"
            shift
            parallel_transform "$command" "$@"
            ;;
        validate)
            script="$1"
            shift
            parallel_validate "$script" "$@"
            ;;
        batch)
            batch_process "$@"
            ;;
        find)
            find_and_process "$@"
            ;;
        benchmark)
            benchmark_operation "$@"
            ;;
        test)
            # Create test files
            test_dir="/tmp/navi-parallel-test-$$"
            mkdir -p "$test_dir"

            for i in {1..10}; do
                echo "Content of file $i" > "$test_dir/file$i.txt"
            done

            echo "Testing parallel file operations..."
            echo ""

            # Test parallel read
            echo "### Parallel Read Test"
            parallel_read "$test_dir"/*.txt | head -20

            echo ""
            echo "### Parallel Search Test"
            parallel_search "Content" "$test_dir"

            echo ""
            echo "### Benchmark Test"
            benchmark_operation "read" "$test_dir"/*.txt

            # Cleanup
            rm -rf "$test_dir"
            ;;
        *)
            echo "Usage: $0 {read|search|transform|validate|batch|find|benchmark|test} [args]"
            echo ""
            echo "Operations:"
            echo "  read <files...>         - Read multiple files in parallel"
            echo "  search <pattern> <paths...> - Search for pattern in parallel"
            echo "  transform <cmd> <files...> - Apply command to files in parallel"
            echo "  validate <script> <files...> - Validate files in parallel"
            echo "  batch <op> <file-list> [size] - Process file list in batches"
            echo "  find <pattern> <op> [dir] - Find and process files"
            echo "  benchmark <op> <files...> - Compare sequential vs parallel"
            echo "  test - Run self-tests"
            exit 1
            ;;
    esac
}

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi