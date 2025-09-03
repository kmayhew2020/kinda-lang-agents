#!/bin/bash
# Complete Coder Bot Session Setup
# Everything needed for natural kinda-lang development

set -e

echo "🤖 Starting Coder Bot Session..."

# Use global environment setup function
source ~/.bashrc
setup_coder 2>/dev/null || {
    echo "🔄 Fallback: Manual setup..."
    # Move to project directory
    cd ~/kinda-lang
    
    # Load and apply authentication
    source ~/kinda-lang-agents/infrastructure/.env.local
    export GH_TOKEN="$KINDA_CODER_PAT"
    export GH_REPO="kinda-lang-dev/kinda-lang"
    
    # Set git identity
    git config user.name "kinda-lang-coder" 
    git config user.email "kinda-lang-coder@users.noreply.github.com"
    
    # Activate virtual environment
    source venv/bin/activate
}

echo "✅ Coder Bot Session Ready!"
echo "  GitHub: $(gh api user --jq .login)"
echo "  Python: $(python --version)" 
echo "  Branch: $(git branch --show-current)"
echo "  Location: $(pwd)"
echo ""
echo "🚀 Execute your development tasks..."

# Run any command passed as arguments
if [ $# -gt 0 ]; then
    echo "Running: $*"
    exec "$@"
fi