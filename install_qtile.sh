#!/usr/bin/env bash
# install_qtile.sh — Symlinks e setup otimizado para dotfiles do amonetlol/qtile
# Otimizado por Grok: mais rápido, mais limpo, menos redundâncias, melhor fluxo

# set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============ FUNÇÃO LINK OTIMIZADA ============
link() {
    local src="$1" dest="$2"
    [[ -L "$dest" && "$(readlink -f "$dest")" == "$(realpath "$src")" ]] && {
        echo -e "${GREEN}OK${NC} $dest → $(basename "$src")"
        return
    }
    [[ -e "$dest" || -L "$dest" ]] && {
        echo -e "${YELLOW}Backup${NC} $dest → $dest.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$dest" "$dest.bak.$(date +%Y%m%d_%H%M%S)"
    }
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo -e "${GREEN}Link${NC} $dest → $src"
}

echo_header() { echo -e "\n${GREEN}===== $1 =====${NC}"; }

# ============ INSTALAÇÕES ============
install_configs() {
    echo_header "Configurações gerais (~/.config)"
    for item in "$DOTFILES_DIR/config"/*/; do
        [[ ! -d "$item" ]] && continue
        local nome="${item%/}" nome="${nome##*/}"
        [[ "$nome" == "dependencias" || "$nome" == "PERSONAL_FIX" ]] && continue
        link "$item" "$HOME/.config/$nome"
    done

    # Torna autostart.sh executável (se existir)
    local autostart="$HOME/.config/qtile/src/autostart.sh"
    [[ -f "$autostart" ]] && chmod +x "$autostart" && echo -e "${GREEN}Executável${NC} $autostart"
}

install_bin() {
    echo_header "Binários (~/.bin)"
    [[ -d "$DOTFILES_DIR/bin" ]] || return
    link "$DOTFILES_DIR/bin" "$HOME/.bin"
    chmod +x "$HOME/.bin"/* 
}

install_starship() {
    echo_header "Starship prompt"
    [[ -f "$DOTFILES_DIR/config/starship.toml" ]] && link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
}

install_rofi_themes() {
    echo_header "Temas do Rofi"
    [[ -d "$DOTFILES_DIR/local/share/rofi" ]] && link "$DOTFILES_DIR/local/share/rofi" "$HOME/.local/share/rofi"
}

install_fonts() {
    echo_header "Fontes personalizadas"
    local font_dir="$HOME/.fonts"
    if [[ -d "$font_dir/.git" ]]; then
        echo -e "${YELLOW}Atualizando fontes...${NC}"
        git -C "$font_dir" pull --quiet
    else
        [[ -d "$font_dir" ]] && mv "$font_dir" "$font_dir.bak.$(date +%Y%m%d_%H%M%S)"
        git clone --depth 1 https://github.com/amonetlol/fonts "$font_dir"
    fi
    fc-cache -vf > /dev/null
    echo -e "${GREEN}Cache de fontes atualizado${NC}"
}

install_walls() {
    echo_header "Wallpapers"
    [[ -d "$HOME/.config/qtile/walls" ]] && link "$HOME/.config/qtile/walls" "$HOME/walls"
}

install_nvim() {
    echo_header "AstroNvim (template limpo)"
    local nvim_dir="$HOME/.config/nvim"
    [[ -d "$nvim_dir" ]] && { echo "AstroNvim já existe, pulando."; return; }
    git clone --depth 1 https://github.com/AstroNvim/template "$nvim_dir"
    rm -rf "$nvim_dir/.git"

    # Mappings personalizados
    mkdir -p ~/.config/nvim/lua/user
    cat > ~/.config/nvim/lua/user/mappings.lua << 'EOF'
    return {
      -- Modo Normal
      n = {
        ["<leader>w"] = { "<cmd>w<cr>", desc = "Salvar buffer" },
        ["<leader>W"] = { "<cmd>wqa<cr>", desc = "Salvar e sair todos" },
      },
      -- Modo Insert
      i = {
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Salvar buffer" },
      },
      -- Modo Visual
      v = {
        ["<leader>w"] = { ":w<cr>", desc = "Salvar buffer" },
      },
    }
    EOF
    echo -e "${YELLOW}AstroNvim clonado.${NC} Abra 'nvim' para finalizar a instalação inicial."
}

install_hidden_apps() {
    echo_header "Aplicações ocultas (.desktop)"
    [[ -d "$DOTFILES_DIR/local/share/applications" ]] && link "$DOTFILES_DIR/local/share/applications" "$HOME/.local/share/applications"
}

update_xdg_dirs() {
    echo_header "xdg-user-dirs (pt_BR)"
    echo "pt_BR" > "$HOME/.config/user-dirs.locale"
    xdg-user-dirs-update --force
}

# ============ EXECUÇÃO PRINCIPAL ============
echo -e "${GREEN}Instalando dotfiles do amonetlol/qtile — Versão otimizada${NC}"

install_configs
install_bin
install_starship
install_rofi_themes
install_fonts
install_walls
install_nvim
install_hidden_apps
update_xdg_dirs

# ============ FINALIZAÇÃO ============
echo -e "\n${GREEN}Tudo concluído com sucesso!${NC}"
echo "• Reinicie o Qtile: Super + Ctrl + R"
echo "• Ou faça logout/login para aplicar tudo"
echo -e "• Dica: ${YELLOW}source ~/.bashrc${NC} para atualizar o shell agora\n"
