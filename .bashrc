#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias tmux="tmux -2"
alias pipes="pipes.sh"
alias vim="nvim"
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_DEFAULT_OPTS='--height 50%'
export QT_QPA_PLATFORMTHEME=qt5ct
source "/usr/share/fzf/key-bindings.bash"
source "/usr/share/fzf/completion.bash"
eval "$(starship init bash)"

# execute on startup
fet.sh
