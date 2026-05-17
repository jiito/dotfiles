# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH/

export PATH=$HOME/bin:$PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable theme - we use custom PROMPT below
ZSH_THEME=""

plugins=( git
          zsh-syntax-highlighting
          zsh-autosuggestions
        )

source $ZSH/oh-my-zsh.sh

export LIBRARY_PATH=:/usr/local/opt/openssl/lib/

export VISUAL=vim
export EDITOR="$VISUAL"

## Load Git for prompt 
autoload -Uz vcs_info
precmd() {
    vcs_info
    # taken from https://jnrowe.github.io/articles/tips/Zsh_and_the_vcs.html
    if [[ -z "${vcs_info_msg_0_}" ]]; then
        dir_status="%F{2} %f"
    elif [[ -n "$(git diff --cached --name-status 2>/dev/null)" ]]; then
        dir_status="%F{1}*%f"
    elif [[ -n "$(git diff --name-status 2>/dev/null)" ]]; then
        dir_status="%F{3}*%f"
    else
        dir_status="%F{2}*%f"
    fi

    # show status of dotfiles repo (only if bare repo exists)
    config_dir_status=""
    if [[ -d "$HOME/.cfg" ]]; then
        config_dir_status="%F{2} %f"
        if [[ -n "$(config diff --cached --name-status 2>/dev/null)" ]]; then
            config_dir_status="%F{1}#%f"
        elif [[ -n "$(config diff --name-status 2>/dev/null)" ]]; then
            config_dir_status="%F{3}#%f"
        elif [[ -n "$(config log @{u}.. 2>/dev/null)" ]]; then
            config_dir_status="%F{3}#↑%f"
        fi
    fi

    # Show hostname when SSH'd in
    if [[ -n "$SSH_CONNECTION" ]]; then
        hostname_display="[%F{yellow}$(hostname)%f] "
    else
        hostname_display=""
    fi

}

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='${hostname_display}%F{cyan}%~%F{green}${vcs_info_msg_0_}%f${dir_status}${config_dir_status}> '
# Ensure PROMPT_SUBST stays enabled
setopt PROMPT_SUBST

# PERSONAL FUNCTIONS
typeset -U fpath
my_functions=$HOME/.zshfn
fpath=($my_functions $fpath)
autoload -Uz ${my_functions}/*(:t)

export GPG_TTY=$(tty)

PATH=$HOME/.emacs.d/bin:$PATH
PATH+=:/usr/local/opt/coreutils/libexec/gnubin
export PATH

source $HOME/.zsh/aliases

autoload -U +X bashcompinit && bashcompinit

# bun completions
[ -s "/Users/bjar/.bun/_bun" ] && source "/Users/bjar/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/bjar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Source local env file if it exists
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Added by Windsurf
export PATH="/Users/bjar/.codeium/windsurf/bin:$PATH"


if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
#

alias reload='source ~/.zshrc'


# CRITICAL: Ensure prompt substitution is enabled (must be at end of file)
setopt PROMPT_SUBST


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bjar/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bjar/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bjar/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bjar/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="$HOME/.local/bin:$PATH"

# ── fzf shell integration (Ctrl-R history, Ctrl-T files, Alt-C dirs) ─────────
command -v fzf >/dev/null && source <(fzf --zsh)

# ── Claude Code multi-session helpers ────────────────────────────────────────
# Pick a worktree with fzf and cd into it.
wt() {
  command -v fzf >/dev/null || { echo "wt: fzf not installed (brew install fzf)" >&2; return 1; }
  git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "wt: not in a git repo" >&2; return 1; }
  local sel
  sel=$(git worktree list | fzf --prompt='worktree> ' --height=40% --reverse \
        --preview 'git -C $(echo {} | awk "{print \$1}") log --oneline -10' \
        | awk '{print $1}')
  [[ -z "$sel" ]] && return 130
  cd "$sel"
}

# Same, but exec nvim in the chosen worktree (closing nvim closes the pane).
nwt() {
  command -v fzf >/dev/null || { echo "nwt: fzf not installed (brew install fzf)" >&2; return 1; }
  git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "nwt: not in a git repo" >&2; return 1; }
  local sel
  sel=$(git worktree list | fzf --prompt='worktree> ' --height=40% --reverse \
        | awk '{print $1}')
  [[ -z "$sel" ]] && return 130
  cd "$sel" && exec nvim
}

# Create a new worktree branched from origin/main as a sibling dir, then cd in.
wtnew() {
  local branch="${1:?usage: wtnew <branch-name>}"
  local root parent path base
  root=$(git rev-parse --show-toplevel) || return 1
  parent=$(dirname "$root")
  path="$parent/$(basename "$root")-$branch"
  base=$(git rev-parse --verify --quiet origin/main || git rev-parse --verify --quiet origin/master || echo HEAD)
  git fetch origin --quiet
  git worktree add -b "$branch" "$path" "$base" || return 1
  cd "$path"
}

# Remove worktrees whose branch is fully merged into origin/main; prune the rest.
wt-prune() {
  git rev-parse --show-toplevel >/dev/null 2>&1 || { echo "wt-prune: not in a git repo" >&2; return 1; }
  git fetch origin --quiet
  git worktree list --porcelain | awk '/^worktree /{wt=$2} /^branch /{print wt, $2}' \
    | while read -r dir ref; do
        local branch=${ref#refs/heads/}
        [[ "$branch" == "main" || "$branch" == "master" ]] && continue
        if git merge-base --is-ancestor "$ref" origin/main 2>/dev/null \
        || git merge-base --is-ancestor "$ref" origin/master 2>/dev/null; then
          echo "removing $dir ($branch, merged)"
          git worktree remove "$dir" && git branch -D "$branch"
        fi
      done
  git worktree prune
}

# Claude Code short aliases.
alias cc='claude'
alias ccc='claude --continue'
alias ccr='claude --resume'
alias ccp='claude -p'
alias ccw='claude --worktree'        # creates a worktree, runs claude in current pane
