#!/bin/bash
# Bot Python Environment Setup
# Ensures bots have access to python, python3, and all necessary tools

set -e

KINDA_DIR="/home/kevin/kinda-lang"

# Navigate to kinda-lang directory
cd "$KINDA_DIR" || {
    echo "Error: Cannot access $KINDA_DIR"
    exit 1
}

# Activate virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
else
    echo "Error: Virtual environment not found at $KINDA_DIR/venv"
    exit 1
fi

# Ensure python symlink exists (many scripts expect 'python' command)
if [ ! -f "venv/bin/python" ]; then
    ln -sf python3 venv/bin/python
fi

# Set environment variables for consistency
export PYTHON="$(pwd)/venv/bin/python"
export PYTHON3="$(pwd)/venv/bin/python3"
export PIP="$(pwd)/venv/bin/pip"
export PYTEST="$(pwd)/venv/bin/pytest"

# Update PATH to prioritize venv
export PATH="$(pwd)/venv/bin:$PATH"

# Verify setup
echo "🐍 Bot Python Environment Ready"
echo "  Python: $(which python) ($(python --version))"
echo "  Python3: $(which python3) ($(python3 --version))"
echo "  Pip: $(which pip) ($(pip --version | head -1))"
echo "  Working directory: $(pwd)"

# If arguments provided, execute them in this environment
if [ $# -gt 0 ]; then
    exec "$@"
fi