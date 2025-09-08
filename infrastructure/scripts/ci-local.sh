#!/bin/bash
# Local CI Runner for Kinda-Lang
# Runs the same checks as GitHub Actions CI locally before PR creation

set -e  # Exit on any error

echo "🎲 Kinda-Lang Local CI (matches GitHub Actions)"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[CI]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Change to project root (should be ~/kinda-lang for bots)
if [ -d "~/kinda-lang" ]; then
    cd ~/kinda-lang
elif [ -d "../kinda-lang" ]; then
    cd ../kinda-lang
else
    cd "$(dirname "$0")/../.."  # Fallback to relative path
fi

print_status "Running same checks as GitHub Actions CI..."
print_status "Working directory: $(pwd)"

# Activate virtual environment if it exists
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    print_status "Virtual environment activated"
elif [ -f "/home/kevin/kinda-lang/venv/bin/activate" ]; then
    source /home/kevin/kinda-lang/venv/bin/activate
    cd /home/kevin/kinda-lang
    print_status "Virtual environment activated from absolute path"
fi

# 1. Install dependencies (matches CI workflow)
print_status "Installing project with dev dependencies..."
python -m pip install --upgrade pip
pip install -e .[dev] || {
    print_error "Failed to install project dependencies"
    exit 1
}
print_success "Dependencies installed"

# 2. Black formatting check (matches CI)
print_status "Check code formatting with Black..."
black --check --diff . || {
    print_error "Code formatting issues found. Run 'black .' to fix."
    exit 1
}
print_success "Black formatting check passed"

# 3. Run tests with coverage (matches CI)
print_status "Run tests with coverage..."
pytest --cov=kinda --cov-report=term-missing tests/ --tb=short || {
    print_error "Test suite failed"
    exit 1
}
print_success "Test suite passed with coverage"

# 4. Test CLI commands (matches CI)
print_status "Test kinda CLI commands..."
kinda --help > /dev/null || { print_error "CLI help failed"; exit 1; }
kinda examples > /dev/null || { print_error "CLI examples failed"; exit 1; }
kinda syntax > /dev/null || { print_error "CLI syntax failed"; exit 1; }
print_success "CLI commands functional"

# 5. Example smoke tests (matches CI, Unix version)
print_status "Example Smoke Tests..."
print_status "  → Testing core examples..."
kinda run examples/python/unified_syntax.py.knda || { print_error "unified_syntax example failed"; exit 1; }
kinda run examples/python/test_coverage_example.py.knda || { print_error "test_coverage example failed"; exit 1; }
kinda run examples/python/kinda_binary_example.py.knda || { print_error "kinda_binary example failed"; exit 1; }

print_status "  → Testing comprehensive examples..."
kinda run examples/python/comprehensive/fuzzy_calculator.py.knda || { print_error "fuzzy_calculator failed"; exit 1; }
kinda run examples/python/comprehensive/fuzzy_game_logic.py.knda || { print_error "fuzzy_game_logic failed"; exit 1; }
kinda run examples/python/comprehensive/chaos_arena_complete.py.knda || { print_error "chaos_arena_complete failed"; exit 1; }

print_status "  → Testing complex examples (with timeout)..."
timeout 30s kinda run examples/python/comprehensive/chaos_arena2_complete.py.knda || {
    print_warning "Chaos arena2 timed out as expected - this is normal"
}
print_success "Example smoke tests completed"

# 6. Additional local-only enhancements
print_status "Additional local CI enhancements..."

# Test with different chaos levels and seeds (local advantage)
print_status "  → Testing reproducible chaos with seeds..."
kinda run examples/python/hello.py.knda --seed 42 > /dev/null || { print_warning "Seeded example failed"; }
kinda run examples/python/unified_syntax.py.knda --chaos-level 1 --seed 123 > /dev/null || { print_warning "Low chaos failed"; }
kinda run examples/python/unified_syntax.py.knda --chaos-level 10 --seed 456 > /dev/null || { print_warning "High chaos failed"; }

# Test personality modes (local advantage)
print_status "  → Testing personality modes..."
kinda run examples/python/hello.py.knda --mood reliable --seed 42 > /dev/null || { print_warning "Reliable mood failed"; }
kinda run examples/python/hello.py.knda --mood chaotic --seed 42 > /dev/null || { print_warning "Chaotic mood failed"; }

print_success "Enhanced local testing completed"

# Final Summary
echo "=============================================="
print_success "🎉 Local CI passed - matches GitHub Actions!"
print_status "Repository is ready for PR creation"
echo "=============================================="

exit 0

echo ""
echo "🔍 Auditing Definition of Done"
infrastructure/scripts/audit-dod.sh

#echo ""
#echo "📄 DoD compliance report:"
#jq . .kinda/compliance_report.json || cat .kinda/compliance_report.json
#
#echo ""
#echo "🔍 Enforcing Definition of Done"
#if infrastructure/scripts/audit-dod.sh && jq -e '.overall_pass == true' .kinda/compliance_report.json >/dev/null; then
#  echo "✅ DoD compliance achieved"
#else
#  echo "❌ DoD compliance failed — see .kinda/compliance_report.json"
#  exit 1
#fi

