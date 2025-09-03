#!/bin/bash
# Wrapper script to launch reviewer bot with guaranteed startup
# This script ALWAYS runs the startup sequence first, then executes the task

echo "🚀 Launching Kinda-Lang Reviewer Bot..."

# Force startup sequence first
bash ~/kinda-lang-agents/infrastructure/scripts/reviewer-startup.sh

# Check if startup was successful
if [ $? -ne 0 ]; then
    echo "❌ Reviewer bot startup failed!"
    exit 1
fi

echo "✅ Startup complete - ready for review operations"
echo ""

# Now the reviewer bot environment is guaranteed to be ready
# Execute any commands passed to this script
if [ $# -gt 0 ]; then
    echo "📋 Executing reviewer task: $*"
    exec "$@"
else
    echo "🎯 Reviewer bot ready - no specific task provided"
fi