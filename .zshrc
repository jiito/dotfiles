# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH/

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=( git
          zsh-syntax-highlighting
          zsh-autosuggestions
        )

source $ZSH/oh-my-zsh.sh

export LIBRARY_PATH=:/usr/local/opt/openssl/lib/

export VISUAL=vim
export EDITOR="$VISUAL"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# ~/.zshrc — disable Powerlevel10k when Cursor Agent runs
if [[ -n "$CURSOR_AGENT" ]]; then
  # Skip theme initialization for better compatibility
else
  [[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi


# PERSONAL FUNCTIONS
fpath=(~/.zshfn "${fpath[@]}")

autoload -Uz $fpath[1]/*(.:t)

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bjar/Documents/sketchpro_downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bjar/Documents/sketchpro_downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bjar/Documents/sketchpro_downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bjar/Documents/sketchpro_downloads/google-cloud-sdk/completion.zsh.inc'; fi

# pnpm
export PNPM_HOME="/Users/bjar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

. "$HOME/.local/bin/env"

# Added by Windsurf
export PATH="/Users/bjar/.codeium/windsurf/bin:$PATH"


if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

