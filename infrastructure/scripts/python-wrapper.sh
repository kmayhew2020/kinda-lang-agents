#!/bin/bash
# Persistent Python Wrapper for Bots
# Automatically uses virtual environment without needing source commands

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KINDA_DIR="/home/kevin/kinda-lang"

# Check if virtual environment exists
if [ ! -d "$KINDA_DIR/venv" ]; then
    echo "Error: Virtual environment not found at $KINDA_DIR/venv"
    echo "Run setup-python-env.sh first"
    exit 1
fi

# Use the virtual environment Python directly
VENV_PYTHON="$KINDA_DIR/venv/bin/python"
VENV_PIP="$KINDA_DIR/venv/bin/pip"

# Export these for bots to use
export KINDA_PYTHON="$VENV_PYTHON"
export KINDA_PIP="$VENV_PIP"
export KINDA_PYTEST="$KINDA_DIR/venv/bin/pytest"

# Set PATH to include venv binaries first, then system python3
export PATH="$KINDA_DIR/venv/bin:$PATH"

# Ensure python command is available (many scripts expect 'python' not 'python3')
if [ ! -f "$KINDA_DIR/venv/bin/python" ]; then
    ln -sf "$KINDA_DIR/venv/bin/python3" "$KINDA_DIR/venv/bin/python"
fi

# Ensure we're in the right directory
cd "$KINDA_DIR" || exit 1

# Execute the command passed to this script
if [ $# -eq 0 ]; then
    echo "Kinda Python Environment Ready"
    echo "Available commands:"
    echo "  KINDA_PYTHON=$KINDA_PYTHON"
    echo "  KINDA_PIP=$KINDA_PIP"
    echo "  KINDA_PYTEST=$KINDA_PYTEST"
    echo ""
    echo "Current directory: $(pwd)"
    echo "Python version: $($KINDA_PYTHON --version)"
else
    # Execute the command in the proper environment
    exec "$@"
fi