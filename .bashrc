alias ft="fastfetch --logo small"
alias al='nvim ~/.bashrc'
alias .r='source ~/.bashrc'
alias nv='nvim'
alias v='nvim'
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
alias xprop='xprop WM_CLASS | grep WM_CLASS'
alias win='rofi -show window'
alias fix='~/.bin/fix_resolution'

# ─────────────────────────────────────────────────────────────────────────────
# DETECÇÃO DA DISTRO + CARREGAMENTO DE ALIASES
# ─────────────────────────────────────────────────────────────────────────────

# Detecta a distro
if [[ -f /etc/nixos/configuration.nix || -d /etc/nixos ]]; then
    DISTRO="nixos"
elif [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
    DISTRO="arch"
elif [[ -f /etc/debian_version ]] || grep -qiE '(ubuntu|debian)' /etc/os-release 2>/dev/null; then
    DISTRO="debian"
elif grep -qiE 'fedora' /etc/os-release 2>/dev/null || [[ -f /etc/fedora-release ]]; then
    DISTRO="fedora"
else
    DISTRO="unknown"
fi

# Carrega aliases comuns (sempre)
[[ -f ~/.aliases ]] && . ~/.aliases
[[ -f ~/.aliases.sh ]] && . ~/.aliases.sh

# Carrega aliases específicos da distro
case $DISTRO in
    arch)
        [ -f ~/.aliases-arch ] && . ~/.aliases-arch
        ;;
    debian)
        [ -f ~/.aliases-debian ] && . ~/.aliases-debian
        ;;
    nixos)
        [ -f ~/.aliases-nixos ] && . ~/.aliases-nixos
        ;;
    fedora)
        [ -f ~/.aliases-fedora ] && . ~/.aliases-fedora
        ;;
    *)
        echo "[AVISO] Distro não reconhecida: $DISTRO"
        ;;
esac

# Debug (opcional – pode remover depois de testar)
#echo "[INFO] Distro detectada: $DISTRO"

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

export PATH="$HOME/.bin:$PATH"
eval "$(starship init bash)"
