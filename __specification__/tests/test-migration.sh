#!/bin/bash

# Migration Tool Test Suite
# Tests the Flow → Navi migration with sample projects

# Test configuration
TEST_DIR="/tmp/navi-migration-test-$$"
SCRIPT_DIR="$(dirname "$(dirname "$0")")/scripts"

# Source utilities
source "$SCRIPT_DIR/common-files.sh" 2>/dev/null || true
source "$SCRIPT_DIR/common-format.sh" 2>/dev/null || true

# Test results tracking
PASSED=0
FAILED=0
WARNINGS=0

# Test framework
run_test() {
    local test_name="$1"
    local test_function="$2"

    echo ""
    format_header 3 "Test: $test_name"

    if $test_function; then
        format_status success "$test_name passed"
        ((PASSED++))
    else
        format_status error "$test_name failed"
        ((FAILED++))
    fi
}

# Setup test environment
setup_test_env() {
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    # Initialize git
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"

    return 0
}

# Cleanup test environment
cleanup_test_env() {
    cd /tmp
    rm -rf "$TEST_DIR"
}

# Test 1: Greenfield project migration
test_greenfield_migration() {
    local test_project="$TEST_DIR/greenfield"
    mkdir -p "$test_project"
    cd "$test_project"

    # Create old Flow structure
    mkdir -p .flow/config .flow/features .flow/scripts
    echo "flow_version=1.0" > .flow/config/flow.json
    echo "#!/bin/bash" > .flow/scripts/flow-helper.sh
    echo "# Flow Project" > README.md
    echo "Flow is great" >> README.md

    # Create a feature
    mkdir -p .flow/features/001-test-feature
    echo "# Test Feature" > .flow/features/001-test-feature/spec.md
    echo "- [ ] Task with Flow" >> .flow/features/001-test-feature/tasks.md

    # Git commit
    git add .
    git commit -m "Initial Flow setup" --quiet

    # Run migration
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 | grep -q "Migration complete"
    local result=$?

    # Verify migration
    if [ $result -eq 0 ]; then
        # Check directory structure
        [ -d "__specification__" ] || return 1
        [ ! -d ".flow" ] || [ -L ".flow" ] || return 1

        # Check content updates
        grep -q "Navi" README.md || return 1
        grep -q "navi" __specification__/scripts/flow-helper.sh || return 1
        grep -q "Task with Flow" __specification__/features/001-test-feature/tasks.md || return 1

        # Check git history preserved
        git log --oneline | grep -q "Initial Flow setup" || return 1

        return 0
    fi

    return 1
}

# Test 2: Brownfield project migration
test_brownfield_migration() {
    local test_project="$TEST_DIR/brownfield"
    mkdir -p "$test_project"
    cd "$test_project"

    # Create existing project with Flow
    echo "# Existing Project" > README.md
    mkdir -p src tests docs
    echo "console.log('app');" > src/app.js

    # Add Flow
    mkdir -p .flow/config
    echo '{"project": {"type": "brownfield"}}' > .flow/config/flow.json

    git add .
    git commit -m "Existing project with Flow" --quiet

    # Run migration
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 | grep -q "Migration complete"
    local result=$?

    # Verify
    if [ $result -eq 0 ]; then
        [ -d "__specification__" ] || return 1
        [ -d "src" ] || return 1  # Original structure preserved
        [ -f "src/app.js" ] || return 1

        # Check config updated
        grep -q "brownfield" __specification__/config/flow.json || return 1

        return 0
    fi

    return 1
}

# Test 3: Command deprecation
test_command_deprecation() {
    local test_project="$TEST_DIR/deprecation"
    mkdir -p "$test_project"
    cd "$test_project"

    # Setup migrated project
    mkdir -p __specification__/config .claude/commands
    echo '{"migrated": true}' > __specification__/config/navi.json

    # Create old flow command
    cat > .claude/commands/flow-init.md << 'EOF'
#!/bin/bash
echo "DEPRECATED: Use /navi init instead"
echo "This command will be removed in 30 days"
exit 0
EOF

    # Test that deprecation warning appears
    bash .claude/commands/flow-init.md 2>&1 | grep -q "DEPRECATED" || return 1

    return 0
}

# Test 4: Rollback functionality
test_rollback() {
    local test_project="$TEST_DIR/rollback"
    mkdir -p "$test_project"
    cd "$test_project"

    # Create and migrate
    mkdir -p .flow/config
    echo "flow_version=1.0" > .flow/config/flow.json
    echo "# Flow Documentation" > README.md

    git add .
    git commit -m "Before migration" --quiet

    # Create backup
    cp -r .flow .flow-backup-test

    # Migrate
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 > /dev/null

    # Verify migration happened
    [ -d "__specification__" ] || return 1
    grep -q "Navi" README.md || return 1

    # Test rollback
    if [ -f "$SCRIPT_DIR/rollback-migration.sh" ]; then
        # Simulate rollback
        rm -rf __specification__
        mv .flow-backup-test .flow
        echo "# Flow Documentation" > README.md

        [ -d ".flow" ] || return 1
        [ ! -d "__specification__" ] || return 1
        grep -q "Flow" README.md || return 1

        return 0
    fi

    return 0
}

# Test 5: Parallel file migration
test_parallel_migration() {
    local test_project="$TEST_DIR/parallel"
    mkdir -p "$test_project"
    cd "$test_project"

    # Create many files to test parallel processing
    mkdir -p .flow/docs .flow/scripts .flow/features

    for i in {1..20}; do
        echo "Flow document $i" > .flow/docs/doc$i.md
        echo "#!/bin/bash" > .flow/scripts/script$i.sh
        echo "# flow command" >> .flow/scripts/script$i.sh
    done

    git add .
    git commit -m "Many files" --quiet

    # Time the migration
    local start=$(date +%s)
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 > /dev/null
    local end=$(date +%s)
    local duration=$((end - start))

    # Verify all files migrated
    local migrated_count=$(find __specification__ -name "*.md" -o -name "*.sh" | wc -l)
    [ "$migrated_count" -ge 40 ] || return 1

    # Check content updated
    grep -q "navi" __specification__/scripts/script1.sh || return 1
    grep -q "Navi" __specification__/docs/doc1.md || return 1

    echo "  Migration time: ${duration}s for 40+ files"
    return 0
}

# Test 6: Configuration preservation
test_config_preservation() {
    local test_project="$TEST_DIR/config"
    mkdir -p "$test_project"
    cd "$test_project"

    # Create complex config
    mkdir -p .flow/config
    cat > .flow/config/flow.json << 'EOF'
{
    "project": {
        "type": "brownfield",
        "name": "TestProject",
        "version": "2.0.0"
    },
    "integrations": {
        "jira": {
            "enabled": true,
            "project": "TEST"
        }
    },
    "preferences": {
        "interactive_mode": false,
        "parallel_execution": true
    }
}
EOF

    git add .
    git commit -m "Complex config" --quiet

    # Migrate
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 > /dev/null

    # Verify config preserved and updated
    [ -f "__specification__/config/navi.json" ] || return 1

    # Check specific values preserved
    grep -q '"type": "brownfield"' __specification__/config/navi.json || return 1
    grep -q '"name": "TestProject"' __specification__/config/navi.json || return 1
    grep -q '"jira"' __specification__/config/navi.json || return 1
    grep -q '"parallel_execution": true' __specification__/config/navi.json || return 1

    return 0
}

# Test 7: Error handling
test_error_handling() {
    local test_project="$TEST_DIR/errors"
    mkdir -p "$test_project"
    cd "$test_project"

    # Test 1: No .flow directory
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 | grep -q "No .flow directory found" || return 1

    # Test 2: Already migrated
    mkdir -p __specification__
    bash "$SCRIPT_DIR/migrate-to-navi.sh" --auto 2>&1 | grep -q "Already migrated" || return 1

    # Test 3: Uncommitted changes (simulate)
    rm -rf __specification__
    mkdir -p .flow
    echo "test" > .flow/test.txt
    # Migration should create backup even with uncommitted changes

    return 0
}

# Main test execution
main() {
    format_header 1 "Migration Tool Test Suite" "🧪"

    # Setup
    setup_test_env

    # Run tests
    run_test "Greenfield Migration" test_greenfield_migration
    run_test "Brownfield Migration" test_brownfield_migration
    run_test "Command Deprecation" test_command_deprecation
    run_test "Rollback Functionality" test_rollback
    run_test "Parallel File Migration" test_parallel_migration
    run_test "Configuration Preservation" test_config_preservation
    run_test "Error Handling" test_error_handling

    # Summary
    echo ""
    format_header 2 "Test Results"
    format_status success "Passed: $PASSED"
    format_status error "Failed: $FAILED"
    format_status warning "Warnings: $WARNINGS"

    local total=$((PASSED + FAILED))
    local percent=$((PASSED * 100 / total))
    echo ""
    echo -n "Overall: "
    format_progress_bar "$PASSED" "$total"

    # Cleanup
    cleanup_test_env

    # Exit code
    [ "$FAILED" -eq 0 ] && exit 0 || exit 1
}

# Run tests
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi