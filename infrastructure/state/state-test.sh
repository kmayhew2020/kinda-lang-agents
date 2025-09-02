#!/bin/bash
# Test State Management System
# Validates that all state operations work correctly

set -e

echo "🧪 Testing Kinda-Lang Bot State Management System"
echo "================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_MANAGER="$SCRIPT_DIR/../scripts/state-manager.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() { echo -e "${BLUE}[TEST]${NC} $1"; }
print_pass() { echo -e "${GREEN}[✓]${NC} $1"; }
print_fail() { echo -e "${RED}[✗]${NC} $1"; }

# Test 1: State file validation
print_test "Validating state file formats..."
for bot_type in coder reviewer pm; do
    state_file="$SCRIPT_DIR/${bot_type}-bot-state.json"
    if jq empty "$state_file" 2>/dev/null; then
        print_pass "$bot_type state file is valid JSON"
    else
        print_fail "$bot_type state file is invalid JSON"
        exit 1
    fi
done

# Test 2: State manager commands
print_test "Testing state manager commands..."
if "$STATE_MANAGER" load coder >/dev/null 2>&1; then
    print_pass "State manager load command works"
else
    print_fail "State manager load command failed"
    exit 1
fi

# Test 3: State persistence
print_test "Testing state persistence..."
if "$STATE_MANAGER" save coder >/dev/null 2>&1; then
    print_pass "State manager save command works"
else
    print_fail "State manager save command failed"
    exit 1
fi

# Test 4: Shared state operations
print_test "Testing shared state operations..."
if "$STATE_MANAGER" update-shared "test.key" "test_value" >/dev/null 2>&1; then
    print_pass "Shared state update works"
else
    print_fail "Shared state update failed"
    exit 1
fi

# Test 5: State retrieval
print_test "Testing state value retrieval..."
value=$("$STATE_MANAGER" get coder '.meta.bot_type')
if [ "$value" = "coder" ]; then
    print_pass "State value retrieval works"
else
    print_fail "State value retrieval failed (got: $value)"
    exit 1
fi

print_pass "All state management tests passed!"
echo "================================================"
echo "State management system is ready for bot operations"

exit 0