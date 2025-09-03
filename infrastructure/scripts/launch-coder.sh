#!/bin/bash
# Wrapper script to launch coder bot with guaranteed startup
# This script ALWAYS runs the startup sequence first, then executes the task

echo "🚀 Launching Kinda-Lang Coder Bot..."

# Force startup sequence first
bash ~/kinda-lang-agents/infrastructure/scripts/coder-startup.sh

# Check if startup was successful
if [ $? -ne 0 ]; then
    echo "❌ Coder bot startup failed!"
    exit 1
fi

echo "✅ Startup complete - ready for coder operations"
echo ""

# Now the coder bot environment is guaranteed to be ready
# Execute any commands passed to this script
if [ $# -gt 0 ]; then
    echo "📋 Executing coder task: $*"
    exec "$@"
else
    echo "🎯 Coder bot ready - no specific task provided"
fi