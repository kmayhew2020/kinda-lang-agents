#!/bin/bash
# Python Environment Setup for Kinda-Lang Bots
# Ensures bots can run Python commands and tests properly

set -e

echo "🐍 Setting up Python Environment for Bots"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_status() { echo -e "${BLUE}[PYTHON]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Navigate to kinda-lang repository
cd ~/kinda-lang || {
    print_error "Cannot access ~/kinda-lang directory"
    exit 1
}

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_error "Virtual environment not found at ~/kinda-lang/venv"
    print_status "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Verify Python setup
print_status "Verifying Python installation..."
python_version=$(python --version 2>&1)
pip_version=$(pip --version 2>&1 | head -1)

print_success "Python: $python_version"
print_success "Pip: $pip_version"

# Check if pytest is available
if ! python -c "import pytest" 2>/dev/null; then
    print_status "Installing pytest and dev dependencies..."
    pip install pytest pytest-cov black mypy
    print_success "Development dependencies installed"
else
    print_success "pytest already available"
fi

# Verify kinda module is importable
if python -c "import kinda" 2>/dev/null; then
    print_success "Kinda module import successful"
else
    print_status "Installing kinda in development mode..."
    pip install -e .
    print_success "Kinda installed in development mode"
fi

# Test basic functionality
print_status "Testing kinda CLI..."
if python -m kinda --help >/dev/null 2>&1; then
    print_success "Kinda CLI working"
else
    print_error "Kinda CLI test failed"
    exit 1
fi

# Test record/replay functionality if it exists
if [ -f "tests/python/test_record_replay_basic.py" ]; then
    print_status "Testing record/replay functionality..."
    if python -m pytest tests/python/test_record_replay_basic.py -v --tb=short -q; then
        print_success "Record/replay tests passing"
    else
        print_error "Record/replay tests failing"
        exit 1
    fi
fi

print_status "Python environment ready!"
print_success "To use in scripts: source ~/kinda-lang/venv/bin/activate"

echo "=========================================="
print_success "🎉 Python environment setup complete!"
echo "=========================================="