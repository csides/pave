# Enable Powerlevel10k instant prompt. Keep near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git asdf)
source "$ZSH/oh-my-zsh.sh"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

alias gfp="git fetch && git pull"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

export GPG_TTY=$(tty)

autoload -U +X bashcompinit && bashcompinit

if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

if command -v gt >/dev/null 2>&1; then
  _gt_yargs_completions() {
    local reply si=$IFS
    IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT - 1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
    IFS=$si
    _describe 'values' reply
  }
  compdef _gt_yargs_completions gt
fi

[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
