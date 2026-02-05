#!/usr/bin/env bash

################################################################################
# Comprehensive Development Environment Setup Script
################################################################################
#
# This script sets up a complete development environment including:
#   - Zsh + Oh-My-Zsh
#   - Personal dotfiles from git repository (bare repo method)
#   - Git configuration (user info and GPG signing)
#   - Tmux + TPM (Tmux Plugin Manager)
#
# Originally created for RunPod environments, but works on any Linux/Mac system.
#
# Usage:
#   bash ~/scripts/setup_machine.sh
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect scripts directory
SCRIPTS_DIR="$HOME/scripts"
if [ ! -d "$SCRIPTS_DIR" ]; then
    log_error "Scripts directory not found at $SCRIPTS_DIR"
    log_info "Please ensure your scripts are located in ~/scripts/"
    exit 1
fi

log_info "Step 1: Installing Zsh + Oh-My-Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warning "Oh-My-Zsh already installed, skipping..."
else
    if [ -f "$SCRIPTS_DIR/install-zsh.sh" ]; then
        # Backup any existing .zshrc before oh-my-zsh install
        if [ -f "$HOME/.zshrc" ]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.backup-pre-setup"
            log_info "Backed up existing .zshrc"
        fi

        bash "$SCRIPTS_DIR/install-zsh.sh"
        log_success "Zsh + Oh-My-Zsh installed"

        # Remove the oh-my-zsh template .zshrc if it was created
        # (dotfiles will provide the real one)
        if [ -f "$HOME/.zshrc" ]; then
            rm "$HOME/.zshrc"
            log_info "Removed oh-my-zsh template .zshrc (dotfiles will provide custom config)"
        fi
    else
        log_error "install-zsh.sh not found in $SCRIPTS_DIR"
        exit 1
    fi
fi

echo ""

log_info "Step 2: Installing dotfiles from git repository..."

if [ -d "$HOME/.cfg" ]; then
    log_warning "Dotfiles repository already exists, skipping..."
else
    if [ -f "$SCRIPTS_DIR/install_dotfiles" ]; then
        bash "$SCRIPTS_DIR/install_dotfiles"
        log_success "Dotfiles installed (including custom .zshrc)"
    else
        log_error "install_dotfiles not found in $SCRIPTS_DIR"
        exit 1
    fi
fi

echo ""

log_info "Step 3: Configuring Git..."

git config --global user.email "me@benjamin.ar"
git config --global user.name "jiito"

# Use ssh keys for verifying commits (from ForwardAgent)
git config --global gpg.format ssh
git config --global gpg.ssh.defaultKeyCommand "ssh-add -L"

log_success "Git configured"

echo ""

log_info "Step 4: Installing Tmux + TPM (Tmux Plugin Manager)..."

# Detect OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

# Install tmux if not present (mainly for Linux)
if ! command -v tmux &> /dev/null; then
    if [[ $MACHINE == "Linux" ]]; then
        log_info "Installing tmux..."
        sudo apt-get update && sudo apt-get install -y tmux
        log_success "Tmux installed"
    elif [[ $MACHINE == "Mac" ]]; then
        log_warning "Tmux not found. Please install via: brew install tmux"
	# TODO: add confirm and install automatically
	
    fi
else
    log_success "Tmux already installed ($(tmux -V))"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    log_warning "TPM already installed, skipping..."
else
    log_info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_success "TPM installed"
fi

echo ""

################################################################################
# 5. Change Default Shell to Zsh
################################################################################
log_info "Step 5: Setting zsh as default shell..."

ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    # Check if zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        log_warning "Adding $ZSH_PATH to /etc/shells (requires sudo)"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    log_info "Changing default shell to zsh (requires password)"
    chsh -s "$ZSH_PATH"
    log_success "Default shell changed to zsh"
else
    log_success "Default shell is already zsh"
fi

echo ""

################################################################################
# Final Instructions
################################################################################
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
log_success "All components installed successfully"
echo ""
log_info "Your custom .zshrc from dotfiles has been installed (not the oh-my-zsh template)"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: exec zsh"
echo "  2. Start tmux: tmux"
echo "  3. Inside tmux, install TPM plugins: Press Ctrl+p then Shift+I"
echo "  4. Verify zsh in tmux: echo \$SHELL (should show /bin/zsh)"
echo ""
echo "Verification commands:"
echo "  - zsh --version"
echo "  - ls ~/.oh-my-zsh"
echo "  - ls ~/.cfg"
echo "  - git config --global --list"
echo "  - tmux -V"
echo "  - ls ~/.tmux/plugins/tpm"
echo ""
