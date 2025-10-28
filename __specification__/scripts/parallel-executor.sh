#!/bin/bash

# Parallel Executor - Worker Pool Pattern
# Enables concurrent execution of independent tasks

# Configuration
MAX_WORKERS=${NAVI_MAX_WORKERS:-4}
WORKER_DIR="__specification__/state/workers"
RESULTS_DIR="__specification__/state/results"

# Initialize worker pool
init_workers() {
    mkdir -p "$WORKER_DIR" "$RESULTS_DIR"

    # Clean up any stale workers
    rm -f "$WORKER_DIR"/*.pid 2>/dev/null

    echo "Initialized worker pool with max $MAX_WORKERS workers"
}

# Execute task in background
execute_task() {
    local task_id="$1"
    local command="$2"
    local output_file="$RESULTS_DIR/${task_id}.out"
    local error_file="$RESULTS_DIR/${task_id}.err"
    local pid_file="$WORKER_DIR/${task_id}.pid"

    # Execute in background
    (
        echo $$ > "$pid_file"
        eval "$command" > "$output_file" 2> "$error_file"
        local exit_code=$?
        echo "$exit_code" > "$RESULTS_DIR/${task_id}.exit"
        rm -f "$pid_file"
    ) &

    local pid=$!
    echo "$pid"
}

# Wait for available worker slot
wait_for_slot() {
    while true; do
        local active_workers=$(ls -1 "$WORKER_DIR"/*.pid 2>/dev/null | wc -l)
        if [ "$active_workers" -lt "$MAX_WORKERS" ]; then
            break
        fi
        sleep 0.1
    done
}

# Execute tasks in parallel
execute_parallel() {
    local tasks_file="$1"

    if [ ! -f "$tasks_file" ]; then
        echo "Error: Tasks file not found: $tasks_file"
        return 1
    fi

    init_workers

    local total_tasks=$(wc -l < "$tasks_file")
    local completed=0
    local failed=0

    echo "Executing $total_tasks tasks with up to $MAX_WORKERS parallel workers"
    echo ""

    # Process each task
    while IFS='|' read -r task_id command; do
        wait_for_slot

        echo "[$(date +%H:%M:%S)] Starting: $task_id"
        execute_task "$task_id" "$command"
    done < "$tasks_file"

    # Wait for all tasks to complete
    echo ""
    echo "Waiting for all tasks to complete..."

    while [ $(ls -1 "$WORKER_DIR"/*.pid 2>/dev/null | wc -l) -gt 0 ]; do
        sleep 0.5
    done

    # Collect results
    echo ""
    echo "## Results Summary"
    echo ""

    for result_file in "$RESULTS_DIR"/*.exit; do
        if [ -f "$result_file" ]; then
            task_id=$(basename "$result_file" .exit)
            exit_code=$(cat "$result_file")

            if [ "$exit_code" -eq 0 ]; then
                echo "✓ $task_id - Success"
                ((completed++))
            else
                echo "✗ $task_id - Failed (exit code: $exit_code)"
                ((failed++))

                # Show error if exists
                error_file="$RESULTS_DIR/${task_id}.err"
                if [ -s "$error_file" ]; then
                    echo "  Error: $(head -1 "$error_file")"
                fi
            fi
        fi
    done

    echo ""
    echo "Total: $total_tasks | Completed: $completed | Failed: $failed"

    return $failed
}

# Parse parallel markers from tasks.md
extract_parallel_tasks() {
    local tasks_file="$1"
    local output_file="$2"

    # Extract tasks marked with [P]
    grep -E "^\- \[ \] T[0-9]+ \[P\]" "$tasks_file" | while read -r line; do
        # Extract task ID and description
        task_id=$(echo "$line" | grep -oE "T[0-9]+")
        description=$(echo "$line" | sed 's/.*\] //')

        # Map to actual command (this would be customized per skill)
        echo "${task_id}|echo 'Executing: $description'"
    done > "$output_file"
}

# Monitor running tasks
monitor_tasks() {
    echo "## Active Workers"
    echo ""

    for pid_file in "$WORKER_DIR"/*.pid; do
        if [ -f "$pid_file" ]; then
            task_id=$(basename "$pid_file" .pid)
            pid=$(cat "$pid_file")

            if kill -0 "$pid" 2>/dev/null; then
                echo "- $task_id (PID: $pid) - Running"
            fi
        fi
    done

    echo ""
    echo "Workers: $(ls -1 "$WORKER_DIR"/*.pid 2>/dev/null | wc -l) / $MAX_WORKERS"
}

# Clean up resources
cleanup() {
    echo "Cleaning up worker pool..."

    # Kill any remaining workers
    for pid_file in "$WORKER_DIR"/*.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            kill "$pid" 2>/dev/null
        fi
    done

    rm -rf "$WORKER_DIR" "$RESULTS_DIR"
}

# Main execution
main() {
    local action="${1:-execute}"

    case "$action" in
        execute)
            tasks_file="${2:-}"
            if [ -z "$tasks_file" ]; then
                echo "Usage: $0 execute <tasks-file>"
                echo "Tasks file format: task_id|command"
                exit 1
            fi
            execute_parallel "$tasks_file"
            ;;
        extract)
            input_file="${2:-}"
            output_file="${3:-parallel-tasks.txt}"
            if [ -z "$input_file" ]; then
                echo "Usage: $0 extract <tasks.md> [output-file]"
                exit 1
            fi
            extract_parallel_tasks "$input_file" "$output_file"
            echo "Extracted parallel tasks to: $output_file"
            ;;
        monitor)
            monitor_tasks
            ;;
        cleanup)
            cleanup
            ;;
        test)
            # Create test tasks
            test_file="/tmp/test-tasks.txt"
            {
                echo "task1|sleep 1 && echo 'Task 1 complete'"
                echo "task2|sleep 2 && echo 'Task 2 complete'"
                echo "task3|sleep 1 && echo 'Task 3 complete'"
                echo "task4|sleep 3 && echo 'Task 4 complete'"
                echo "task5|sleep 1 && echo 'Task 5 complete'"
            } > "$test_file"

            echo "Running test with 5 tasks..."
            time execute_parallel "$test_file"
            rm -f "$test_file"
            ;;
        *)
            echo "Usage: $0 {execute|extract|monitor|cleanup|test} [args]"
            exit 1
            ;;
    esac
}

# Trap cleanup on exit
trap cleanup EXIT INT TERM

# Run if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi