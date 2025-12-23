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

    local bashrc_src="$DOTFILES_DIR/.bashrc"
    local bashrc_dest="$HOME/.bashrc"

    # Se o .bashrc fonte não existe, não faz nada
    if [[ ! -f "$bashrc_src" ]]; then
        echo -e "${YELLOW}Aviso:${NC} $bashrc_src não encontrado. Pulando configuração do bashrc."
        return
    fi

    # Backup simples do .bashrc existente (se houver)
    if [[ -e "$bashrc_dest" || -L "$bashrc_dest" ]]; then
        echo -e "${YELLOW}Backup${NC} ~/.bashrc → ~/.bashrc.old"
        mv "$bashrc_dest" "$bashrc_dest.old" || true
    fi

    # Cria symlink do .bashrc
    ln -sf "$bashrc_src" "$bashrc_dest"
    echo -e "${GREEN}Link${NC} ~/.bashrc → $bashrc_src"

    # Detecção da distro
    echo -e "${YELLOW}Detectando distro...${NC}"
    local distro="unknown"

    if [[ -f /etc/nixos/configuration.nix || -d /etc/nixos ]]; then
        distro="nixos"
    elif [[ -f /etc/arch-release || -f /etc/artix-release ]]; then
        distro="arch"
    elif [[ -f /etc/debian_version ]] || grep -qiE '(ubuntu|debian)' /etc/os-release 2>/dev/null; then
        distro="debian"
    elif grep -qiE 'fedora' /etc/os-release 2>/dev/null || [[ -f /etc/fedora-release ]]; then
        distro="fedora"
    fi

    echo -e "${GREEN}Distro detectada:${NC} $distro"

    # Arquivo de aliases específico
    local aliases_file="$DOTFILES_DIR/.aliases-$distro"

    if [[ -f "$aliases_file" ]]; then
        # Backup simples do .aliases existente (se houver)
        if [[ -e "$HOME/.aliases" || -L "$HOME/.aliases" ]]; then
            echo -e "${YELLOW}Backup${NC} ~/.aliases → ~/.aliases.old"
            mv "$HOME/.aliases" "$HOME/.aliases.old" 2>/dev/null || true
        fi

        # Cria symlink do .aliases
        ln -sf "$aliases_file" "$HOME/.aliases"
        echo -e "${GREEN}Link${NC} ~/.aliases → $aliases_file"
    else
        echo -e "${RED}Aviso:${NC} Arquivo $aliases_file não encontrado."
    fi

    echo -e "${YELLOW}Dica:${NC} Rode 'source ~/.bashrc' para aplicar as mudanças agora."
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
