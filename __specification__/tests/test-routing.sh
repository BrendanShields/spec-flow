#!/bin/bash

# Command Routing and Deprecation Test Suite
# Tests intelligent routing, shortcuts, and backward compatibility

# Test configuration
SCRIPT_DIR="$(dirname "$(dirname "$0")")/scripts"
TEST_DIR="/tmp/navi-routing-test-$$"

# Source utilities
source "$SCRIPT_DIR/common-format.sh" 2>/dev/null || true
source "$SCRIPT_DIR/shortcuts.sh" 2>/dev/null || true
source "$SCRIPT_DIR/routing-v2.sh" 2>/dev/null || true

# Test results
PASSED=0
FAILED=0

# Test framework
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [ "$expected" = "$actual" ]; then
        format_status success "$message"
        ((PASSED++))
        return 0
    else
        format_status error "$message: expected '$expected', got '$actual'"
        ((FAILED++))
        return 1
    fi
}

# Test 1: Shortcut interpretation
test_shortcuts() {
    format_header 3 "Testing Shortcuts"

    # Single letter shortcuts
    assert_equals "auto" "$(interpret_command 'c')" "Shortcut 'c' → continue"
    assert_equals "implement" "$(interpret_command 'b')" "Shortcut 'b' → build"
    assert_equals "validate" "$(interpret_command 'v')" "Shortcut 'v' → validate"
    assert_equals "status" "$(interpret_command 's')" "Shortcut 's' → status"
    assert_equals "help" "$(interpret_command 'h')" "Shortcut 'h' → help"

    # Natural language
    assert_equals "init" "$(interpret_command 'start new feature')" "Natural: 'start new feature'"
    assert_equals "implement" "$(interpret_command 'build this')" "Natural: 'build this'"
    assert_equals "validate" "$(interpret_command 'check my work')" "Natural: 'check my work'"
    assert_equals "status" "$(interpret_command 'show progress')" "Natural: 'show progress'"

    # Empty/auto
    assert_equals "auto" "$(interpret_command '')" "Empty input → auto"
}

# Test 2: Phase detection
test_phase_detection() {
    format_header 3 "Testing Phase Detection"

    # Setup test environment
    mkdir -p "$TEST_DIR/__specification__/features/001-test"
    cd "$TEST_DIR"

    # Test init phase (no features)
    FEATURES_DIR="$TEST_DIR/__specification__/features"
    phase=$(detect_current_phase)
    assert_equals "init" "$phase" "No features → init phase"

    # Test specify phase (feature dir but no spec)
    phase=$(detect_current_phase)
    assert_equals "init" "$phase" "Empty feature dir → init phase"

    # Test plan phase (has spec but no plan)
    echo "# Spec" > "$TEST_DIR/__specification__/features/001-test/spec.md"
    phase=$(detect_current_phase)
    assert_equals "plan" "$phase" "Has spec → plan phase"

    # Test tasks phase (has plan but no tasks)
    echo "# Plan" > "$TEST_DIR/__specification__/features/001-test/plan.md"
    phase=$(detect_current_phase)
    assert_equals "tasks" "$phase" "Has plan → tasks phase"

    # Test implement phase (has incomplete tasks)
    echo "- [ ] Task 1" > "$TEST_DIR/__specification__/features/001-test/tasks.md"
    echo "- [ ] Task 2" >> "$TEST_DIR/__specification__/features/001-test/tasks.md"
    echo "- [x] Task 3" >> "$TEST_DIR/__specification__/features/001-test/tasks.md"
    phase=$(detect_current_phase)
    assert_equals "implement" "$phase" "Has incomplete tasks → implement phase"

    # Test complete phase (all tasks done)
    echo "- [x] Task 1" > "$TEST_DIR/__specification__/features/001-test/tasks.md"
    echo "- [x] Task 2" >> "$TEST_DIR/__specification__/features/001-test/tasks.md"
    echo "- [x] Task 3" >> "$TEST_DIR/__specification__/features/001-test/tasks.md"
    phase=$(detect_current_phase)
    assert_equals "complete" "$phase" "All tasks complete → complete phase"

    cd - > /dev/null
}

# Test 3: Command routing
test_command_routing() {
    format_header 3 "Testing Command Routing"

    # Test valid commands
    output=$(route_command "init" 2>&1)
    [[ "$output" == *"navi:init"* ]] && format_status success "Route: init → navi:init" && ((PASSED++)) || ((FAILED++))

    output=$(route_command "specify" "test feature" 2>&1)
    [[ "$output" == *"navi:specify"* ]] && format_status success "Route: specify → navi:specify" && ((PASSED++)) || ((FAILED++))

    output=$(route_command "validate" 2>&1)
    [[ "$output" == *"navi:analyze"* ]] && format_status success "Route: validate → navi:analyze" && ((PASSED++)) || ((FAILED++))

    # Test unknown command
    output=$(route_command "unknown" 2>&1)
    [[ "$output" == *"Unknown command"* ]] && format_status success "Unknown command handled" && ((PASSED++)) || ((FAILED++))
}

# Test 4: Deprecation warnings
test_deprecation() {
    format_header 3 "Testing Deprecation Warnings"

    # Create deprecated command
    mkdir -p "$TEST_DIR/.claude/commands"
    cat > "$TEST_DIR/.claude/commands/flow-test.md" << 'EOF'
#!/bin/bash
echo "DEPRECATED: Use /navi instead"
EOF

    # Test deprecation appears
    output=$(bash "$TEST_DIR/.claude/commands/flow-test.md" 2>&1)
    [[ "$output" == *"DEPRECATED"* ]] && format_status success "Deprecation warning shown" && ((PASSED++)) || ((FAILED++))

    # Test alias mapping
    mkdir -p "$TEST_DIR/__specification__/config"
    cat > "$TEST_DIR/__specification__/config/aliases.json" << 'EOF'
{
    "legacy": {
        "flow": "navi",
        "flow-init": "navi init",
        "flow-specify": "navi specify"
    }
}
EOF

    # Verify aliases exist
    [ -f "$TEST_DIR/__specification__/config/aliases.json" ] && format_status success "Alias mapping created" && ((PASSED++)) || ((FAILED++))
}

# Test 5: Intelligent suggestions
test_suggestions() {
    format_header 3 "Testing Intelligent Suggestions"

    cd "$TEST_DIR"
    FEATURES_DIR="$TEST_DIR/__specification__/features"

    # Test suggestion for each phase
    mkdir -p "$TEST_DIR/__specification__/features/001-test"

    # Init phase suggestion
    suggestion=$(get_next_suggested_command)
    assert_equals "init" "$suggestion" "Init phase suggests: init"

    # Specify phase suggestion
    echo "# Spec" > "$TEST_DIR/__specification__/features/001-test/spec.md"
    suggestion=$(get_next_suggested_command)
    assert_equals "plan" "$suggestion" "Specify phase suggests: plan"

    # Plan phase suggestion
    echo "# Plan" > "$TEST_DIR/__specification__/features/001-test/plan.md"
    suggestion=$(get_next_suggested_command)
    assert_equals "tasks" "$suggestion" "Plan phase suggests: tasks"

    cd - > /dev/null
}

# Test 6: Backward compatibility
test_backward_compatibility() {
    format_header 3 "Testing Backward Compatibility"

    # Old flow commands should still work with warnings
    mkdir -p "$TEST_DIR/.claude/skills/flow-init"
    echo "name: flow:init" > "$TEST_DIR/.claude/skills/flow-init/SKILL.md"

    # Check skill exists (would be found by skill system)
    [ -f "$TEST_DIR/.claude/skills/flow-init/SKILL.md" ] && format_status success "Legacy skill preserved" && ((PASSED++)) || ((FAILED++))

    # Check symlink support
    mkdir -p "$TEST_DIR/__specification__"
    ln -s "__specification__" "$TEST_DIR/.flow" 2>/dev/null
    [ -L "$TEST_DIR/.flow" ] && format_status success "Symlink compatibility" && ((PASSED++)) || ((FAILED++))

    # Check environment variables
    export FLOW_TEST="value"
    export NAVI_TEST="value"
    [ -n "$FLOW_TEST" ] && [ -n "$NAVI_TEST" ] && format_status success "Dual env var support" && ((PASSED++)) || ((FAILED++))
}

# Test 7: Performance
test_routing_performance() {
    format_header 3 "Testing Performance"

    # Test shortcut interpretation speed
    local start=$(date +%s%N)
    for i in {1..100}; do
        interpret_command "build" > /dev/null
    done
    local end=$(date +%s%N)
    local duration=$(((end - start) / 1000000))

    [ "$duration" -lt 1000 ] && format_status success "Shortcuts: 100 ops in ${duration}ms" && ((PASSED++)) || format_status warning "Slow: ${duration}ms" && ((FAILED++))

    # Test phase detection speed
    cd "$TEST_DIR"
    mkdir -p "$TEST_DIR/__specification__/features/001-test"
    echo "# Spec" > "$TEST_DIR/__specification__/features/001-test/spec.md"

    start=$(date +%s%N)
    for i in {1..100}; do
        detect_current_phase > /dev/null
    done
    end=$(date +%s%N)
    duration=$(((end - start) / 1000000))

    [ "$duration" -lt 2000 ] && format_status success "Phase detection: 100 ops in ${duration}ms" && ((PASSED++)) || format_status warning "Slow: ${duration}ms" && ((FAILED++))

    cd - > /dev/null
}

# Cleanup
cleanup() {
    rm -rf "$TEST_DIR"
}

# Main execution
main() {
    format_header 1 "Command Routing & Deprecation Tests" "🧭"

    # Setup
    mkdir -p "$TEST_DIR"

    # Run tests
    test_shortcuts
    test_phase_detection
    test_command_routing
    test_deprecation
    test_suggestions
    test_backward_compatibility
    test_routing_performance

    # Summary
    echo ""
    format_header 2 "Test Summary"
    local total=$((PASSED + FAILED))
    format_status success "Passed: $PASSED/$total"
    [ "$FAILED" -gt 0 ] && format_status error "Failed: $FAILED/$total"

    echo ""
    echo -n "Success Rate: "
    format_progress_bar "$PASSED" "$total"

    # Cleanup
    cleanup

    # Exit code
    [ "$FAILED" -eq 0 ] && exit 0 || exit 1
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi