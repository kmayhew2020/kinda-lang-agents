#!/bin/bash
# Bot Environment Setup - Natural Python Development
# This is exactly what a user would do to develop kinda-lang

# Navigate to project directory
cd ~/kinda-lang

# Load bot authentication
source ~/kinda-lang-agents/infrastructure/.env.local
export GH_TOKEN="$KINDA_CODER_PAT"
export GH_REPO="kinda-lang-dev/kinda-lang"

# Set git identity
git config user.name "kinda-lang-coder"
git config user.email "kinda-lang-coder@users.noreply.github.com"

# Activate virtual environment (standard Python development practice)
source venv/bin/activate

echo "🤖 Natural Kinda-Lang Development Environment Active"
echo "  GitHub: $(gh api user --jq .login 2>/dev/null || echo 'Not authenticated')" 
echo "  Python: $(python --version)"
echo "  Virtual env: $(which python)"
echo "  Branch: $(git branch --show-current)"
echo ""
echo "Ready for natural development - use 'python', 'pytest', etc. normally!"