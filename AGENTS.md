# Dotfiles & Zsh Configuration

This document explains the dotfiles setup, zsh configuration, and how to set up new machines.

## Overview

This repository uses a **bare git repository** approach for managing dotfiles. Instead of symlinking files from a cloned repo, the dotfiles are tracked directly in your home directory using a special `config` alias.

## Architecture

### Bare Git Repository Structure

```
$HOME/.cfg/           # Bare git repository
$HOME/.zshrc          # Actual files tracked in repo (not symlinks)
$HOME/.zsh/           # Directory of aliases
$HOME/.zshfn/         # Directory of shell functions
$HOME/scripts/        # Setup and utility scripts
```

The `config` alias is used instead of `git` to manage dotfiles:
```bash
config status
config add .zshrc
config commit -m "Update zsh config"
config push
```

This approach avoids the need for symlinks and keeps your home directory clean.

## Zsh Configuration

### Dual-Prompt System

The `.zshrc` uses a **dual-prompt system** with intelligent fallback:

1. **Primary: Powerlevel10k** (p10k)
   - Rich, feature-complete prompt with icons and git integration
   - Used on local development machines
   - Configuration: `~/.p10k.zsh`

2. **Fallback: Custom Prompt**
   - Lightweight, portable prompt for SSH sessions and containers
   - Activated when `CURSOR_AGENT` environment variable is set
   - Shows:
     - `[hostname]` when SSH'd in (yellow)
     - Current directory (cyan)
     - Git branch and status (green)
     - Directory status indicator (clean/dirty)
     - Dotfiles repo status indicator

**Example prompts:**

Local machine with p10k:
```
  ~/projects/myrepo main  10:30:45
❯
```

SSH session with custom prompt:
```
[container-abc123] ~/projects/myrepo main *>
```

Local machine with custom prompt (no SSH):
```
~/projects/myrepo main *>
```

### Prompt Status Indicators

The custom prompt shows git and dotfiles status:

**Git repository status (`dir_status`):**
- `*` (green) - Clean working directory
- `*` (yellow) - Uncommitted changes
- `*` (red) - Staged changes

**Dotfiles repository status (`config_dir_status`):**
- ` ` (green) - Clean dotfiles
- `#` (yellow) - Uncommitted dotfiles changes
- `#` (red) - Staged dotfiles changes
- `#↑` (yellow) - Unpushed commits in dotfiles

### Oh-My-Zsh Plugins

Required plugins (installed by `setup_machine.sh`):
- `git` - Git aliases and completions (built-in)
- `zsh-syntax-highlighting` - Command syntax highlighting
- `zsh-autosuggestions` - Fish-like autosuggestions

### Functions and Aliases

**Functions** (`~/.zshfn/`):
- Loaded automatically from all files in `~/.zshfn/`
- Each file can contain one or more shell functions
- Example: `gclone` for cloning repos

**Aliases** (`~/.zsh/aliases`):
- Common command shortcuts
- `config` - Git alias for managing dotfiles

## Setup Scripts

### `scripts/setup_machine.sh`

Main setup script for new machines. Runs in order:

1. **Install Zsh + Oh-My-Zsh**
   - Installs zsh if not present
   - Installs Oh-My-Zsh framework
   - Backs up any existing `.zshrc` to `.zshrc.backup-pre-setup`

2. **Install Powerlevel10k theme**
   - Clones p10k into `~/.oh-my-zsh/custom/themes/powerlevel10k`
   - Skipped if already installed

3. **Install Oh-My-Zsh plugins**
   - `zsh-syntax-highlighting`
   - `zsh-autosuggestions`
   - Cloned into `~/.oh-my-zsh/custom/plugins/`

4. **Install Dotfiles**
   - Calls `scripts/install_dotfiles`
   - Clones bare repo to `~/.cfg/`
   - Checks out dotfiles to `$HOME`
   - Verifies critical files exist

5. **Verify Installation**
   - Checks that `.zshrc` was properly checked out
   - Restores backup if dotfiles checkout failed

### `scripts/install_dotfiles`

Handles dotfiles installation with robust error handling:

1. Clones bare repository from GitHub to `~/.cfg/`
2. Handles file conflicts by moving them to `~/.dotfiles-backup/`
3. Checks out all tracked files to `$HOME`
4. Verifies critical files exist:
   - `.zshrc`
   - `.zsh/aliases`
   - `.zshfn/` directory with functions
5. Configures git to not show untracked files

**Color-coded output:**
- 🟢 Green: Success
- 🟡 Yellow: Warning (skipped, already exists)
- 🔴 Red: Error

## Setting Up a New Machine

### Prerequisites

- Git installed
- SSH key configured for GitHub access
- Zsh installed (or script will install it)

### Quick Setup

```bash
# 1. Clone this repo temporarily to get the setup script
git clone git@github.com:jiito/dotfiles.git ~/dotfiles-temp
cd ~/dotfiles-temp

# 2. Copy scripts to home directory
mkdir -p ~/scripts
cp scripts/* ~/scripts/
chmod +x ~/scripts/*

# 3. Run setup script
bash ~/scripts/setup_machine.sh

# 4. Clean up temporary clone
cd ~
rm -rf ~/dotfiles-temp

# 5. Restart shell
exec zsh
```

### For Containers/SSH Environments

If you only need the dotfiles without the full setup:

```bash
# Clone bare repo
git clone --bare git@github.com:jiito/dotfiles.git $HOME/.cfg

# Define config alias temporarily
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Checkout dotfiles (backup conflicts if needed)
mkdir -p .dotfiles-backup
config checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | \
  xargs -I{} sh -c 'mkdir -p $(dirname .dotfiles-backup/{}) && mv {} .dotfiles-backup/{}'
config checkout

# Configure repo
config config status.showUntrackedFiles no

# Reload shell
exec zsh
```

## Environment Variables

### `CURSOR_AGENT`

When set, disables Powerlevel10k and uses the custom lightweight prompt.

Set this in CI/CD environments, containers, or SSH sessions where you want a simpler prompt:

```bash
export CURSOR_AGENT=1
```

### `SSH_CONNECTION`

Automatically set by SSH. Used to detect SSH sessions and show hostname in prompt.

No manual configuration needed.

## File Organization

### Tracked Files

Files tracked in the dotfiles repo:
- `.zshrc` - Main zsh configuration
- `.zsh/aliases` - Command aliases
- `.zshfn/*` - Shell functions
- `.p10k.zsh` - Powerlevel10k configuration
- `scripts/*` - Setup and utility scripts
- `.gitconfig` - Git configuration (if tracked)
- `.tmux.conf` - Tmux configuration (if tracked)

### Untracked Files

Files NOT tracked (stay local to each machine):
- `.local/bin/env` - Local environment variables and PATH setup
- `.ssh/` - SSH keys and config
- `.gnupg/` - GPG keys
- Any machine-specific configuration

## Managing Dotfiles

### Common Operations

**Check status:**
```bash
config status
```

**Add a new dotfile:**
```bash
config add ~/.zshrc
config commit -m "Update zsh config"
config push
```

**View changes:**
```bash
config diff
```

**Pull updates:**
```bash
config pull
```

**See what's tracked:**
```bash
config ls-files
```

### Best Practices

1. **Test changes locally first** - Changes affect your shell immediately
2. **Keep it portable** - Don't hardcode paths or assume files exist
3. **Use conditional sourcing** - Check if files exist before sourcing them
4. **Document changes** - Update this file when adding new features
5. **Commit .p10k.zsh** - Ensure p10k config is tracked for consistency

## Troubleshooting

### "zsh-syntax-highlighting not found"

The plugin isn't installed. Run:
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

### "zsh-autosuggestions not found"

The plugin isn't installed. Run:
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

### "no such file or directory: ~/.local/bin/env"

This file is optional and machine-specific. The error is harmless, but if you want to silence it, create an empty file:
```bash
mkdir -p ~/.local/bin
touch ~/.local/bin/env
```

Or ensure your `.zshrc` has the conditional check:
```bash
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
```

### Aliases/functions not loading

The dotfiles weren't properly checked out. Run:
```bash
config checkout --force
exec zsh
```

### Prompt doesn't show git info

Ensure you're in a git repository and `vcs_info` is loaded:
```bash
cd ~/projects/some-git-repo
echo $vcs_info_msg_0_  # Should show branch name
```

### Config alias doesn't work

Define it manually:
```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Then reload:
```bash
exec zsh
```

## Technical Details

### How the Custom Prompt Works

The `precmd()` function runs before each prompt display:

1. **Load git info** - `vcs_info` fetches current branch
2. **Check git status** - Determine if repo is clean/dirty/staged
3. **Check dotfiles status** - Query `.cfg` bare repo for uncommitted changes
4. **Set hostname** - Show hostname only if `SSH_CONNECTION` is set
5. **Build prompt** - Assemble all components with color codes

### Prompt String Expansion

Zsh prompt uses special sequences:
- `%F{color}` - Start color
- `%f` - End color
- `%~` - Current directory (with ~ for home)
- `${var}` - Variable expansion
- `${var:+text}` - Show text only if var is non-empty

Example:
```bash
PROMPT='${hostname_display:+[%F{yellow}${hostname_display}%f] }%F{cyan}%~%f> '
```

Expands to:
- With SSH: `[hostname] /path/to/dir> `
- Without SSH: `/path/to/dir> `

## Repository

- **GitHub**: [github.com/jiito/dotfiles](https://github.com/jiito/dotfiles)
- **Branch**: `master`
- **Clone URL**: `git@github.com:jiito/dotfiles.git`

## Version History

- **2025-02**: Complete rewrite of setup scripts with error handling
- **2025-02**: Added SSH hostname detection in prompt
- **2025-02**: Made ~/.local/bin/env conditional
- **2025-02**: Added Oh-My-Zsh plugin installation to setup script
- **2024**: Initial dotfiles setup with bare repo approach

## See Also

- [Oh-My-Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Atlassian Bare Repo Tutorial](https://www.atlassian.com/git/tutorials/dotfiles)
