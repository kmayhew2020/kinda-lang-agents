#!/bin/bash
# Standard Coder Bot Launcher
# Always calls coder with same consistent prompt

echo "🚀 Launching Coder Bot with standard prompt..."

# The Task tool call should always be exactly the same
# The bot reads agents/coder.md and follows it exactly
# Any specific work is communicated through state files

echo "Coder bot will:"
echo "  1. Read agents/coder.md prompt file" 
echo "  2. Follow startup sequence exactly"
echo "  3. Check state files for current work"
echo "  4. Execute according to prompt requirements"
echo ""

# This ensures consistent behavior every time