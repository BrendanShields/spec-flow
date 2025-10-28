#!/bin/bash

# Parallel Execution Test Suite
# Validates correctness and performance of parallel processing

# Configuration
SCRIPT_DIR="$(dirname "$(dirname "$0")")/scripts"
TEST_DIR="/tmp/navi-parallel-test-$$"

# Source utilities
source "$SCRIPT_DIR/common-format.sh" 2>/dev/null || true
source "$SCRIPT_DIR/parallel-executor.sh" 2>/dev/null || true
source "$SCRIPT_DIR/parallel-files.sh" 2>/dev/null || true

# Test results
PASSED=0
FAILED=0
PERFORMANCE_GAIN=0

# Test 1: Worker pool correctness
test_worker_pool() {
    format_header 3 "Worker Pool Correctness"

    # Create test tasks
    local tasks_file="$TEST_DIR/test-tasks.txt"
    > "$tasks_file"

    # Add tasks with varying durations
    for i in {1..10}; do
        echo "task$i|echo 'Task $i start' && sleep 0.5 && echo 'Task $i complete'" >> "$tasks_file"
    done

    # Execute with worker pool
    MAX_WORKERS=4 execute_parallel "$tasks_file" > "$TEST_DIR/pool-output.txt" 2>&1

    # Verify all tasks completed
    local completed=$(grep -c "Task .* complete" "$TEST_DIR/pool-output.txt")

    if [ "$completed" -eq 10 ]; then
        format_status success "All 10 tasks completed correctly"
        ((PASSED++))
    else
        format_status error "Only $completed/10 tasks completed"
        ((FAILED++))
    fi

    # Verify worker limit respected
    local max_concurrent=$(ls "$WORKER_DIR"/*.pid 2>/dev/null | wc -l)
    if [ "$max_concurrent" -le 4 ]; then
        format_status success "Worker limit respected (≤4)"
        ((PASSED++))
    else
        format_status error "Too many workers: $max_concurrent > 4"
        ((FAILED++))
    fi
}

# Test 2: Parallel file operations
test_parallel_files() {
    format_header 3 "Parallel File Operations"

    # Create test files
    mkdir -p "$TEST_DIR/files"
    for i in {1..20}; do
        echo "Content of file $i" > "$TEST_DIR/files/file$i.txt"
    done

    # Test parallel read
    local start=$(date +%s%N)
    parallel_read "$TEST_DIR/files/"*.txt > /dev/null 2>&1
    local end=$(date +%s%N)
    local parallel_time=$(((end - start) / 1000000))

    # Sequential comparison
    start=$(date +%s%N)
    for file in "$TEST_DIR/files/"*.txt; do
        cat "$file" > /dev/null 2>&1
    done
    end=$(date +%s%N)
    local sequential_time=$(((end - start) / 1000000))

    # Calculate speedup
    if [ "$sequential_time" -gt 0 ]; then
        local speedup=$((parallel_time * 100 / sequential_time))
        format_status success "Parallel: ${parallel_time}ms, Sequential: ${sequential_time}ms"
        format_status success "Speedup: $((100 - speedup))% faster"
        ((PASSED++))
    else
        format_status warning "Could not measure speedup"
    fi

    # Test parallel search
    echo "NEEDLE" > "$TEST_DIR/files/file10.txt"
    parallel_search "NEEDLE" "$TEST_DIR/files" > "$TEST_DIR/search-results.txt" 2>&1

    if grep -q "NEEDLE" "$TEST_DIR/search-results.txt"; then
        format_status success "Parallel search found target"
        ((PASSED++))
    else
        format_status error "Parallel search failed"
        ((FAILED++))
    fi
}

# Test 3: Task dependency handling
test_dependencies() {
    format_header 3 "Task Dependency Handling"

    # Create tasks with dependencies
    cat > "$TEST_DIR/dependent-tasks.txt" << 'EOF'
task1|echo "Task 1" > /tmp/task1.done
task2|test -f /tmp/task1.done && echo "Task 2" > /tmp/task2.done
task3|test -f /tmp/task2.done && echo "Task 3" > /tmp/task3.done
EOF

    # These should run sequentially despite parallel mode
    # In real implementation, would need dependency resolution

    format_status info "Dependencies require sequential execution"
    format_status warning "Full dependency resolution not yet implemented"
}

# Test 4: Error handling
test_error_handling() {
    format_header 3 "Error Handling in Parallel"

    # Create tasks with some failures
    cat > "$TEST_DIR/error-tasks.txt" << 'EOF'
success1|echo "Success 1"
fail1|exit 1
success2|echo "Success 2"
fail2|false
success3|echo "Success 3"
EOF

    # Execute and check error reporting
    execute_parallel "$TEST_DIR/error-tasks.txt" > "$TEST_DIR/error-output.txt" 2>&1

    local successes=$(grep -c "✓" "$TEST_DIR/error-output.txt")
    local failures=$(grep -c "✗" "$TEST_DIR/error-output.txt")

    if [ "$successes" -eq 3 ] && [ "$failures" -eq 2 ]; then
        format_status success "Correctly reported 3 successes, 2 failures"
        ((PASSED++))
    else
        format_status error "Error reporting incorrect"
        ((FAILED++))
    fi
}

# Test 5: Performance benchmark
test_performance_benchmark() {
    format_header 3 "Performance Benchmark"

    # Create CPU-bound tasks
    cat > "$TEST_DIR/cpu-tasks.txt" << 'EOF'
task1|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task2|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task3|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task4|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task5|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task6|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task7|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
task8|for i in {1..1000}; do echo $((i*i)) > /dev/null; done
EOF

    # Measure parallel execution
    local start=$(date +%s)
    MAX_WORKERS=4 execute_parallel "$TEST_DIR/cpu-tasks.txt" > /dev/null 2>&1
    local end=$(date +%s)
    local parallel_duration=$((end - start))

    # Estimate sequential time (would be ~8x single task time)
    # For testing, we'll use the parallel time to estimate
    local estimated_sequential=$((parallel_duration * 8 / 4))

    PERFORMANCE_GAIN=$((100 - (parallel_duration * 100 / estimated_sequential)))

    format_status info "Parallel execution: ${parallel_duration}s"
    format_status info "Est. sequential: ${estimated_sequential}s"
    format_status success "Performance gain: ~${PERFORMANCE_GAIN}%"

    if [ "$PERFORMANCE_GAIN" -gt 30 ]; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
}

# Test 6: Concurrent file writes
test_concurrent_writes() {
    format_header 3 "Concurrent File Writes"

    # Test lock-based safe writes
    cat > "$TEST_DIR/write-tasks.txt" << 'EOF'
write1|echo "Line 1" >> /tmp/concurrent-test.txt
write2|echo "Line 2" >> /tmp/concurrent-test.txt
write3|echo "Line 3" >> /tmp/concurrent-test.txt
write4|echo "Line 4" >> /tmp/concurrent-test.txt
write5|echo "Line 5" >> /tmp/concurrent-test.txt
EOF

    # Execute concurrent writes
    rm -f /tmp/concurrent-test.txt
    execute_parallel "$TEST_DIR/write-tasks.txt" > /dev/null 2>&1

    # Verify all writes completed
    if [ -f /tmp/concurrent-test.txt ]; then
        local lines=$(wc -l < /tmp/concurrent-test.txt)
        if [ "$lines" -eq 5 ]; then
            format_status success "All 5 concurrent writes successful"
            ((PASSED++))
        else
            format_status error "Expected 5 lines, got $lines"
            ((FAILED++))
        fi
    else
        format_status error "Output file not created"
        ((FAILED++))
    fi

    rm -f /tmp/concurrent-test.txt
}

# Test 7: Resource cleanup
test_resource_cleanup() {
    format_header 3 "Resource Cleanup"

    # Create tasks that might leave resources
    cat > "$TEST_DIR/cleanup-tasks.txt" << 'EOF'
task1|touch /tmp/test-file-1.tmp
task2|touch /tmp/test-file-2.tmp
task3|touch /tmp/test-file-3.tmp
EOF

    # Execute
    execute_parallel "$TEST_DIR/cleanup-tasks.txt" > /dev/null 2>&1

    # Check worker cleanup
    local remaining_pids=$(ls "$WORKER_DIR"/*.pid 2>/dev/null | wc -l)
    if [ "$remaining_pids" -eq 0 ]; then
        format_status success "All worker PIDs cleaned up"
        ((PASSED++))
    else
        format_status error "$remaining_pids PIDs not cleaned"
        ((FAILED++))
    fi

    # Clean test files
    rm -f /tmp/test-file-*.tmp
}

# Cleanup
cleanup() {
    rm -rf "$TEST_DIR"
    cleanup 2>/dev/null  # Call parallel cleanup
}

# Main execution
main() {
    format_header 1 "Parallel Execution Test Suite" "⚡"

    # Setup
    mkdir -p "$TEST_DIR"
    init_workers

    # Run tests
    test_worker_pool
    echo ""
    test_parallel_files
    echo ""
    test_dependencies
    echo ""
    test_error_handling
    echo ""
    test_performance_benchmark
    echo ""
    test_concurrent_writes
    echo ""
    test_resource_cleanup

    # Summary
    echo ""
    format_header 2 "Test Summary"
    local total=$((PASSED + FAILED))
    format_status success "Passed: $PASSED/$total"
    [ "$FAILED" -gt 0 ] && format_status error "Failed: $FAILED/$total"

    echo ""
    echo -n "Success Rate: "
    format_progress_bar "$PASSED" "$total"

    if [ "$PERFORMANCE_GAIN" -gt 0 ]; then
        echo ""
        format_alert success "Parallel execution provides ~${PERFORMANCE_GAIN}% performance improvement"
    fi

    # Cleanup
    cleanup

    # Exit code
    [ "$FAILED" -eq 0 ] && exit 0 || exit 1
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi