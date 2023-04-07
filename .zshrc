[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(/opt/homebrew/bin/brew shellenv)"

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
alias gcc="gcc-12"
alias g++="g++-12"

export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--height 50%'

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Jekyll ruby stuff
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.2 # run chruby to see actual version
