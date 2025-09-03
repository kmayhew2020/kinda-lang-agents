#!/bin/bash
# Mandatory Coder Bot Startup Sequence
# This script MUST run before any coder bot operations
# Usage: source this script to preserve environment variables

echo "🤖 Initializing Coder Bot Environment..."

# 1. Navigate to project directory
cd ~/kinda-lang || {
    echo "❌ ERROR: Cannot access ~/kinda-lang"
    return 1 2>/dev/null || exit 1
}

# 2. Load environment variables
if [ -f ~/kinda-lang-agents/infrastructure/.env.local ]; then
    source ~/kinda-lang-agents/infrastructure/.env.local
    echo "✅ Loaded .env.local"
    echo "✅ KINDA_CODER_PAT: ${KINDA_CODER_PAT:0:10}..."
else
    echo "❌ ERROR: .env.local not found"
    return 1 2>/dev/null || exit 1
fi

# 3. Set GitHub authentication
if [ -n "$KINDA_CODER_PAT" ]; then
    export GH_TOKEN="$KINDA_CODER_PAT"
    export GH_REPO="kinda-lang-dev/kinda-lang"
    echo "✅ GitHub token configured: ${GH_TOKEN:0:10}..."
    echo "✅ Repository set to: $GH_REPO"
else
    echo "❌ ERROR: KINDA_CODER_PAT not set in .env.local"
    return 1 2>/dev/null || exit 1
fi

# 4. Configure git identity
git config user.name "kinda-lang-coder"
git config user.email "kinda-lang-coder@users.noreply.github.com"
echo "✅ Git identity configured"

# 5. Verify authentication
if gh auth status >/dev/null 2>&1; then
    GITHUB_USER=$(gh api user --jq .login 2>/dev/null || echo "unknown")
    echo "✅ GitHub authenticated as: $GITHUB_USER"
else
    echo "❌ ERROR: GitHub authentication failed"
    exit 1
fi

# 6. Load persistent state
STATE_FILE="~/kinda-lang-agents/infrastructure/state/coder-bot-state.json"
if [ -f "$STATE_FILE" ]; then
    echo "✅ Persistent state available"
    # Could add state summary here if needed
else
    echo "⚠️  No persistent state found (first run?)"
fi

echo "🎯 Coder Bot Environment Ready!"
echo "   Working Directory: $(pwd)"
echo "   GitHub User: $(gh api user --jq .login 2>/dev/null || echo 'Not authenticated')"
echo "   Git Branch: $(git branch --show-current)"
echo "   Python: $(python --version)"
echo ""

# Execute any additional commands passed to this script
if [ $# -gt 0 ]; then
    echo "📋 Executing: $*"
    exec "$@"
fi