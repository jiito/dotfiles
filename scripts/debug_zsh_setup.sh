#!/usr/bin/env bash

################################################################################
# Debug Script: Check Zsh Functions & Aliases Setup
################################################################################
#
# This script helps diagnose why functions and aliases aren't loading
#
# Usage: bash ~/scripts/debug_zsh_setup.sh
#
################################################################################

echo "=================================="
echo "Zsh Setup Diagnostics"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}!${NC} $1"
}

echo "1. Checking .zshrc existence..."
if [ -f "$HOME/.zshrc" ]; then
    check_pass ".zshrc exists"
else
    check_fail ".zshrc NOT FOUND"
    echo "   → Run: config checkout ~/.zshrc"
    exit 1
fi
echo ""

echo "2. Checking aliases directory..."
if [ -d "$HOME/.zsh" ]; then
    check_pass ".zsh directory exists"
    if [ -f "$HOME/.zsh/aliases" ]; then
        check_pass ".zsh/aliases file exists"
        echo "   Aliases content:"
        cat "$HOME/.zsh/aliases" | head -10
    else
        check_fail ".zsh/aliases NOT FOUND"
        echo "   → Run: config checkout ~/.zsh/aliases"
    fi
else
    check_fail ".zsh directory NOT FOUND"
    echo "   → Run: mkdir -p ~/.zsh && config checkout ~/.zsh/aliases"
fi
echo ""

echo "3. Checking functions directory..."
if [ -d "$HOME/.zshfn" ]; then
    check_pass ".zshfn directory exists"
    function_count=$(ls -1 "$HOME/.zshfn" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$function_count" -gt 0 ]; then
        check_pass "Found $function_count function(s)"
        echo "   Functions:"
        ls -1 "$HOME/.zshfn" | sed 's/^/   - /'
    else
        check_warn ".zshfn directory is empty"
        echo "   → Run: config checkout ~/.zshfn/"
    fi
else
    check_fail ".zshfn directory NOT FOUND"
    echo "   → Run: mkdir -p ~/.zshfn && config checkout ~/.zshfn/"
fi
echo ""

echo "4. Checking .zshrc configuration..."
if grep -q "source.*\.zsh/aliases" "$HOME/.zshrc"; then
    check_pass ".zshrc sources aliases"
else
    check_fail ".zshrc does NOT source aliases"
    echo "   → Add to .zshrc: source \$HOME/.zsh/aliases"
fi

if grep -q "autoload.*zshfn" "$HOME/.zshrc"; then
    check_pass ".zshrc autoloads functions"
else
    check_fail ".zshrc does NOT autoload functions"
    echo "   → Add to .zshrc:"
    echo "     typeset -U fpath"
    echo "     my_functions=\$HOME/.zshfn"
    echo "     fpath=(\$my_functions \$fpath)"
    echo "     autoload -Uz \${my_functions}/*(:t)"
fi
echo ""

echo "5. Checking if files are tracked in dotfiles repo..."
if [ -d "$HOME/.cfg" ]; then
    check_pass "Dotfiles repo exists at ~/.cfg"

    echo "   Tracked files:"
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files | grep -E "(\.zshrc|\.zsh/|\.zshfn/)" | sed 's/^/   - /'

    echo ""
    echo "   Untracked files that should be added:"
    if [ -f "$HOME/.zshrc" ]; then
        if ! git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --error-unmatch .zshrc >/dev/null 2>&1; then
            echo "   - .zshrc (run: config add ~/.zshrc)"
        fi
    fi

    if [ -f "$HOME/.zsh/aliases" ]; then
        if ! git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files --error-unmatch .zsh/aliases >/dev/null 2>&1; then
            echo "   - .zsh/aliases (run: config add ~/.zsh/aliases)"
        fi
    fi

    if [ -d "$HOME/.zshfn" ]; then
        if ! git --git-dir=$HOME/.cfg/ --work-tree=$HOME ls-files .zshfn/ | grep -q .; then
            echo "   - .zshfn/* (run: config add ~/.zshfn/*)"
        fi
    fi
else
    check_fail "Dotfiles repo NOT FOUND at ~/.cfg"
    echo "   → Run setup_machine.sh first"
fi
echo ""

echo "=================================="
echo "Summary"
echo "=================================="
echo ""
echo "If all checks pass, try reloading your shell:"
echo "  source ~/.zshrc"
echo "  # or"
echo "  exec zsh"
echo ""
echo "If checks failed, follow the suggestions above, then:"
echo "  config commit -m 'Fix zsh setup'"
echo "  config push"
echo ""
