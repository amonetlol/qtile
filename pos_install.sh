#!/usr/bin/env bash
# pos_install.sh — symlinks para o dotfiles do amonetlol/qtile
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Global 
# --------- INICIO -----------
link() {
    local src="$1"
    local dest="$2"
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$src" ]]; then
        echo -e "${GREEN}OK${NC} $dest → $(basename "$src")"
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo -e "${YELLOW}Backup${NC} $dest → $dest.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$dest" "$dest.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo -e "${GREEN}Link${NC} $dest → $src"
}

# --------- FIM -----------

# =============================================
#                FUNÇÕES
# =============================================

echo_header() {
    echo -e "\n${GREEN}===== $1 =====${NC}"
}

install_configs() {
    echo_header "Configurações gerais (.config)"
    for item in "$DOTFILES_DIR/config"/*/; do
        item=${item%/}
        nome=$(basename "$item")
        [[ "$nome" == "dependencias" || "$nome" == "PERSONAL_FIX" ]] && continue
        link "$item" "$HOME/.config/$nome"
    done

    # autostart.sh do qtile
    if [[ -f "$HOME/.config/qtile/src/autostart.sh" ]]; then
        chmod +x "$HOME/.config/qtile/src/autostart.sh"
        echo -e "${GREEN}Executável${NC} $HOME/.config/qtile/src/autostart.sh"
    fi
}

install_bin() {
    echo_header "Binários (~/.bin)"
    if [[ -d "$DOTFILES_DIR/bin" ]]; then
        link "$DOTFILES_DIR/bin" "$HOME/.bin"
        find "$HOME/.bin" -type f -exec chmod +x {} \; 2>/dev/null || true
        chmod +x "$HOME/.bin"/* 2>/dev/null || true
        echo -e "${GREEN}Executáveis${NC} todos os arquivos em ~/.bin"
    fi
}

install_starship() {
    echo_header "Starship prompt"
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    fi
}

install_rofi_themes() {
    echo_header "Temas do Rofi"
    if [[ -d "$DOTFILES_DIR/local/share/rofi" ]]; then
        link "$DOTFILES_DIR/local/share/rofi" "$HOME/.local/share/rofi"
    fi
}

install_shell_configs() {
    echo_header "Configurações do shell (.bashrc + .aliases)"
    if [[ -f "$DOTFILES_DIR/.bashrc" ]]; then
    BASHRC_DEST="$HOME/.bashrc"
 
    # Faz backup do .bashrc existente (se houver)
    if [[ -e "$BASHRC_DEST" || -L "$BASHRC_DEST" ]]; then
        echo -e "${YELLOW}Backup${NC} ~/.bashrc → ~/.bashrc.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$BASHRC_DEST" "$BASHRC_DEST.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    # Cria o symlink para .bashrc
    ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC_DEST"
    echo -e "${GREEN}Link${NC} ~/.bashrc → $DOTFILES_DIR/.bashrc"
    # ─── DETECÇÃO DA DISTRO PARA ESCOLHER O .aliases correto ───────────────
    echo -e "${YELLOW}Detectando distro para carregar aliases corretos...${NC}"
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
    echo -e "${GREEN}Distro detectada:${NC} $DISTRO"
    # Nome do arquivo de aliases específico
    ALIASES_FILE="$DOTFILES_DIR/.aliases-$DISTRO"
    # Verifica se o arquivo específico existe
    if [[ -f "$ALIASES_FILE" ]]; then
        # Faz backup do .aliases atual (se existir)
        if [[ -e "$HOME/.aliases" || -L "$HOME/.aliases" ]]; then
            echo -e "${YELLOW}Backup${NC} ~/.aliases → ~/.aliases.bak.$(date +%Y%m%d_%H%M%S)"
            mv "$HOME/.aliases" "$HOME/.aliases.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        fi
        # Cria o symlink para o .aliases correto
        ln -sf "$ALIASES_FILE" "$HOME/.aliases"
        echo -e "${GREEN}Link${NC} ~/.aliases → $ALIASES_FILE"
    else
        echo -e "${RED}Aviso:${NC} Arquivo $ALIASES_FILE não encontrado no repositório."
        echo -e " Usando apenas aliases comuns (se houver ~/.aliases)."
    fi
    echo -e "${YELLOW}Dica:${NC} Após instalar, rode 'source ~/.bashrc' para aplicar agora."
fi
}

install_sddm() {
    echo_header "Configuração do SDDM"
    if [[ -f "$DOTFILES_DIR/sddm.conf" ]]; then
        SDDM_DEST="/etc/sddm.conf"
        echo -e "${GREEN}Copiando${NC} sddm.conf para o sistema..."
        sudo cp "$DOTFILES_DIR/sddm.conf" "$SDDM_DEST"
        echo -e "${GREEN}feito${NC} $SDDM_DEST atualizado"
        sudo systemctl enable sddm
    fi
}

install_fonts() {
    echo_header "Instalação de fontes"
    if [[ -d "$HOME/.fonts" && -d "$HOME/.fonts/.git" ]]; then
        echo -e "${YELLOW}Atualizando fontes existentes...${NC}"
        git -C "$HOME/.fonts" pull
    else
        if [[ -d "$HOME/.fonts" ]]; then
            mv "$HOME/.fonts" "$HOME/.fonts.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        git clone https://github.com/amonetlol/fonts "$HOME/.fonts"
    fi
    fc-cache -vf
    echo -e "${GREEN}Cache de fontes atualizado${NC}"
}

install_walls() {
    echo_header "Fixes e ajustes pessoais"
    link "$HOME/.config/qtile/walls" "$HOME/walls"
}

install_nvim() {
    echo_header "AstroNvim (template limpo)"
    git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    # nvim   ← comentado, pois abre editor e trava o script
    echo "AstroNvim clonado. Abra o nvim para finalizar a instalação inicial."
}

install_hidden_applications() {
    echo_header "Aplicações ocultas"
    link "$DOTFILES_DIR/local/share/applications" "$HOME/.local/share/applications"
}

update_xdg_users() {
    echo_header "xdg-user-dirs Update)"
    # Define o idioma desejado (ex: português do Brasil)
    echo "pt_BR" > ~/.config/user-dirs.locale
    # Atualiza tudo
    xdg-user-dirs-update --force
}

# =============================================
#               EXECUÇÃO
# =============================================

echo -e "${GREEN}Instalando configs do amonetlol/qtile${NC}"

install_configs
install_bin
install_starship
install_rofi_themes
install_shell_configs
install_sddm
install_fonts
install_walls
install_nvim
install_hidden_applications
update_xdg_users

# =============================================
#                FINALIZAÇÃO
# =============================================

echo -e "\n${GREEN}Tudo pronto!${NC}"
echo "Reinicie o Qtile (Super + Ctrl + R) ou faça logout/login."
echo -e "Dica: para aplicar bashrc agora → ${YELLOW}source ~/.bashrc${NC}\n"

# Para desativar alguma parte, é só comentar a linha abaixo:
# install_sddm
# install_nvim
# install_fixes
# etc...
