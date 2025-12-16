alias ft="fastfetch --logo small"
alias al='nvim ~/.bashrc'
alias .r='source ~/.bashrc'
alias nv='nvim'
alias v='nvim'
alias ed='sudo nvim /etc/nixos/configuration.nix'
alias up2='sudo nixos-rebuild switch'
alias qd='cd ~/.config/qtile && ll'
alias lg="ls | grep"
alias ls='eza -lah --color=always --group-directories-first --icons'
alias ll='eza -lah --color=always --group-directories-first --icons'
alias df='duf -hide special'
alias duf='duf -hide special'
alias hg='history | grep'
alias ag='alias | grep'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep -i'
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias exe='chmod +x'
alias fix='sh ~/.src/fix.sh'
alias clean='sudo nix-collect-garbage -d'
alias cls='sudo nix-collect-garbage -d && sudo nixos-rebuild switch --upgrade'
alias xprop='xprop WM_CLASS | grep WM_CLASS'
alias win='rofi -show window'
alias fix='~/.bin/fix_resolution'

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

source ~/.aliases
export PATH="$HOME/.bin:$PATH"
eval "$(starship init bash)"
