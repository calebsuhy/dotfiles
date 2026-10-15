[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

bindkey -e

zstyle :compinstall filename '/home/casu/.zprofile'
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure
zstyle ':prompt:pure:prompt:success' color green

alias ls="ls --color=auto"
alias tmux="tmux -2"
alias vim="nvim"
alias python="python3"

export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--height 50%'

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# latex stuff
export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH
export MANPATH=/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH
export INFOPATH=/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH

# aliases
alias clear="clear && fet.sh"

# execute on startup
fet.sh
