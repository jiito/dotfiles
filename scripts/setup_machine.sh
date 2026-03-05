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
# Self-contained script - no external dependencies required.
#
# Usage (fresh machine):
#   curl -fsSL https://raw.githubusercontent.com/jiito/dotfiles/main/scripts/setup_machine.sh | bash
#
# Or download and run:
#   curl -fsSL -o setup.sh https://raw.githubusercontent.com/jiito/dotfiles/main/scripts/setup_machine.sh
#   chmod +x setup.sh && ./setup.sh
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository URLs
DOTFILES_REPO_SSH="git@github.com:jiito/dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/jiito/dotfiles.git"
CFG_DIR="$HOME/.cfg"

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

# Config alias function for bare repo
config() {
    git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"
}

# Detect OS
detect_os() {
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     MACHINE=Linux;;
        Darwin*)    MACHINE=Mac;;
        *)          MACHINE="UNKNOWN:${unameOut}"
    esac
    echo "$MACHINE"
}

MACHINE=$(detect_os)
log_info "Detected OS: $MACHINE"
echo ""

################################################################################
# Step 1: Install Zsh (Linux only)
################################################################################
log_info "Step 1: Installing Zsh..."

if command -v zsh &> /dev/null; then
    log_success "Zsh already installed ($(zsh --version))"
else
    if [[ $MACHINE == "Linux" ]]; then
        log_info "Installing zsh via apt..."
        sudo apt-get update && sudo apt-get install -y zsh
        log_success "Zsh installed"
    elif [[ $MACHINE == "Mac" ]]; then
        log_warning "Zsh not found. macOS should have zsh by default."
        log_warning "Please install via: brew install zsh"
        exit 1
    fi
fi

echo ""

################################################################################
# Step 2: Install Oh-My-Zsh
################################################################################
log_info "Step 2: Installing Oh-My-Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_success "Oh-My-Zsh already installed, skipping..."
else
    log_info "Installing Oh-My-Zsh (keeping existing .zshrc if present)..."
    KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh-My-Zsh installed"
fi

echo ""

################################################################################
# Step 3: Install Dotfiles
################################################################################
log_info "Step 3: Installing dotfiles from git repository..."

if [ -d "$CFG_DIR" ]; then
    log_success "Dotfiles repository already exists, skipping clone..."
else
    # Try SSH first (works with ForwardAgent), fall back to HTTPS
    log_info "Checking SSH access to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_info "SSH available, cloning via SSH..."
        git clone --bare "$DOTFILES_REPO_SSH" "$CFG_DIR"
    else
        log_warning "SSH not available, using HTTPS (read-only)..."
        git clone --bare "$DOTFILES_REPO_HTTPS" "$CFG_DIR"
    fi
    log_success "Cloned dotfiles repository"
fi

# Checkout dotfiles
log_info "Checking out dotfiles..."
mkdir -p "$HOME/.dotfiles-backup"

if config checkout 2>&1 | grep -q "error: The following untracked working tree files would be overwritten"; then
    log_warning "Moving conflicting files to ~/.dotfiles-backup"
    config checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | xargs -I{} sh -c 'mkdir -p $(dirname ~/.dotfiles-backup/{}) && mv {} ~/.dotfiles-backup/{}'
    config checkout
fi

# Configure bare repo to hide untracked files
config config status.showUntrackedFiles no

# Verify critical files exist
log_info "Verifying critical files..."
for file in .zshrc .zsh/aliases; do
    if [ -e "$HOME/$file" ]; then
        log_success "$file found"
    else
        log_error "$file MISSING"
    fi
done

if [ -d "$HOME/.zshfn" ]; then
    count=$(ls -1 "$HOME/.zshfn" 2>/dev/null | wc -l)
    log_success ".zshfn/ ($count functions)"
else
    log_warning ".zshfn/ directory not found (may be expected)"
fi

echo ""

################################################################################
# Step 4: Install Zsh Plugins
################################################################################
log_info "Step 4: Installing Zsh plugins..."

# Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    log_info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    log_success "Powerlevel10k installed"
else
    log_success "Powerlevel10k already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
else
    log_success "zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
else
    log_success "zsh-autosuggestions already installed"
fi

echo ""

################################################################################
# Step 5: Configure Git
################################################################################
log_info "Step 5: Configuring Git..."

git config --global user.email "me@benjamin.ar"
git config --global user.name "jiito"

# Use ssh keys for verifying commits (from ForwardAgent)
git config --global gpg.format ssh
git config --global gpg.ssh.defaultKeyCommand "ssh-add -L"

log_success "Git configured"

echo ""

################################################################################
# Step 6: Install Tmux + TPM
################################################################################
log_info "Step 6: Installing Tmux + TPM (Tmux Plugin Manager)..."

# Install tmux if not present (mainly for Linux)
if ! command -v tmux &> /dev/null; then
    if [[ $MACHINE == "Linux" ]]; then
        log_info "Installing tmux..."
        sudo apt-get update && sudo apt-get install -y tmux
        log_success "Tmux installed"
    elif [[ $MACHINE == "Mac" ]]; then
        log_warning "Tmux not found. Please install via: brew install tmux"
    fi
else
    log_success "Tmux already installed ($(tmux -V))"
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    log_success "TPM already installed, skipping..."
else
    log_info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    log_success "TPM installed"
fi

echo ""

################################################################################
# Step 7: Set Default Shell to Zsh
################################################################################
log_info "Step 7: Setting zsh as default shell..."

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
log_info "Your custom .zshrc from dotfiles has been installed"
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
