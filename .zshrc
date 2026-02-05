# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH/

export PATH=$HOME/bin:$PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme - custom PROMPT below will override this
# This is just a safety fallback in case custom prompt fails
ZSH_THEME="robbyrussell"

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

}

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%F{green}${vcs_info_msg_0_}%f${dir_status}${config_dir_status}> '


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

. "$HOME/.local/bin/env"

# Added by Windsurf
export PATH="/Users/bjar/.codeium/windsurf/bin:$PATH"


if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
#

alias reload='source ~/.zshrc'


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/bjar/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/bjar/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/bjar/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/bjar/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
