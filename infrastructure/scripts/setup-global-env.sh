#!/bin/bash
# Setup Global Environment for Natural Kinda-Lang Development
# Makes environment variables available system-wide

echo "🌍 Setting up global kinda-lang environment..."

# Add to bashrc for persistent environment
ENV_SETUP="
# Kinda-Lang Bot Environment (Auto-generated)
source ~/kinda-lang-agents/infrastructure/.env.local 2>/dev/null || true
export GH_REPO=\"kinda-lang-dev/kinda-lang\"
export KINDA_PROJECT_DIR=\"~/kinda-lang\"

# Add kinda-lang venv to PATH so python/python3 work naturally everywhere
export PATH=\"/home/kevin/kinda-lang/venv/bin:\$PATH\"

# Set working directory to kinda-lang by default
if [ \"\$(pwd)\" = \"/home/kevin\" ] || [ \"\$(pwd)\" = \"/home/kevin/kinda-lang-agents\" ]; then
    cd ~/kinda-lang 2>/dev/null || true
fi

# Function to setup bot session naturally
setup_coder() {
    cd ~/kinda-lang
    export GH_TOKEN=\"\$KINDA_CODER_PAT\"
    git config user.name \"kinda-lang-coder\"
    git config user.email \"kinda-lang-coder@users.noreply.github.com\"
    echo \"🤖 Coder environment active: \$(gh api user --jq .login 2>/dev/null || echo 'Not authenticated')\"
}

setup_reviewer() {
    cd ~/kinda-lang  
    export GH_TOKEN=\"\$KINDA_REVIEWER_PAT\"
    git config user.name \"kinda-lang-reviewer\"
    git config user.email \"kinda-lang-reviewer@users.noreply.github.com\"
    echo \"🔍 Reviewer environment active: \$(gh api user --jq .login 2>/dev/null || echo 'Not authenticated')\"
}

# Aliases for natural commands
alias kinda-coder='setup_coder'
alias kinda-reviewer='setup_reviewer'
"

# Check if already added
if ! grep -q "Kinda-Lang Bot Environment" ~/.bashrc 2>/dev/null; then
    echo "$ENV_SETUP" >> ~/.bashrc
    echo "✅ Added to ~/.bashrc"
else
    echo "✅ Already configured in ~/.bashrc"
fi

echo "🎉 Global environment setup complete!"
echo ""
echo "Usage:"
echo "  kinda-coder     # Setup coder environment"
echo "  kinda-reviewer  # Setup reviewer environment"
echo ""
echo "Restart terminal or run: source ~/.bashrc"