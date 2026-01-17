ft() {
    local config_dir="/home/pio/.config/fastfetch"
    local configs=(
        "$config_dir/Chris.jsonc"
        "$config_dir/config.jsonc"
        "$config_dir/small_config.jsonc"
        "$config_dir/cybrland.jsonc"
    )

    # Verifica se pelo menos uma config existe (opcional, mas evita erro)
    local valid_configs=()
    for cfg in "${configs[@]}"; do
        [[ -f "$cfg" ]] && valid_configs+=("$cfg")
    done

    if [[ ${#valid_configs[@]} -eq 0 ]]; then
        echo "Erro: Nenhuma das configs encontradas em $config_dir" >&2
        return 1
    fi

    # Escolhe uma config aleatória entre as válidas
    local chosen="${valid_configs[$RANDOM % ${#valid_configs[@]}]}"

    fastfetch --config "$chosen"
}

# USO:
# gc https://github.com/amonetlol/polybar
# → Clona e entra automaticamente na pasta polybar
#
# gc https://github.com/dylanaraps/neofetch.git meu-neofetch
# → Clona para a pasta "meu-neofetch" e entra nela


gc() {
    if [ -z "$1" ]; then
        echo "Uso: gc <url-do-repositório> [pasta-opcional]"
        return 1
    fi

    # Clona o repositório
    git clone "$@"

    # Verifica se o clone foi bem sucedido
    if [ $? -ne 0 ]; then
        echo "Erro ao clonar o repositório."
        return 1
    fi

    # Extrai o nome da pasta (último argumento ou deduz do URL)
    local repo_dir
    if [ -n "$2" ]; then
        repo_dir="$2"  # Se especificaste uma pasta personalizada
    else
        repo_dir=$(basename "$1" .git)  # Remove .git do final do URL
    fi

    # Entra na pasta
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir" || return 1
        echo "Entraste na pasta: $repo_dir"
    else
        echo "Aviso: Pasta $repo_dir não encontrada após clone."
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# DETECÇÃO DA DISTRO + CARREGAMENTO DE ALIASES
# ─────────────────────────────────────────────────────────────────────────────

# Detecta a distro
if [[ -f /etc/nixos/configuration.nix || -d /etc/nixos ]]; then
    DISTRO="nixos"
elif [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
    DISTRO="arch"
elif [[ -f /etc/debian_version ]] || grep -qiE '(ubuntu|debian|pop|mint)' /etc/os-release 2>/dev/null; then
    DISTRO="debian"
elif grep -qiE 'fedora' /etc/os-release 2>/dev/null || [[ -f /etc/fedora-release ]]; then
    DISTRO="fedora"
elif grep -qiE 'openSUSE' /etc/os-release 2>/dev/null || [[ -f /etc/fedora-release ]]; then
    DISTRO="openSUSE"
elif grep -qiE 'Solus' /etc/os-release 2>/dev/null || [[ -f /etc/fedora-release ]]; then
    DISTRO="Solus"
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
    openSUSE)
        [ -f ~/.aliases-opensuse ] && . ~/.aliases-opensuse
        ;;
    Solus)
        [ -f ~/.aliases-solus ] && . ~/.aliases-solus
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
eval "$(zoxide init bash)"
