#!/usr/bin/env bash
# install.sh — symlinks para o dotfiles do amonetilol/qtile
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echo -e "${GREEN}Instalando configs do amonetilol/qtile${NC}"
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
# 1. Tudo que está dentro de config/ (exceto bin e starship.toml)
for item in "$DOTFILES_DIR/config"/*/; do
    item=${item%/}
    nome=$(basename "$item")
    # Ignora essas pastas
    [[ "$nome" == "dependencias" || "$nome" == "PERSONAL_FIX" ]] && continue
    link "$item" "$HOME/.config/$nome"
done

# === Adicionado: tornar executável o autostart.sh do qtile ===
if [[ -f "$HOME/.config/qtile/src/autostart.sh" ]]; then
    chmod +x "$HOME/.config/qtile/src/autostart.sh"
    echo -e "${GREEN}Executável${NC} $HOME/.config/qtile/src/autostart.sh"
fi

# 2. bin → ~/.bin
if [[ -d "$DOTFILES_DIR/bin" ]]; then
    link "$DOTFILES_DIR/bin" "$HOME/.bin"
    # Torna todos os scripts executáveis (duas formas: find + glob)
    find "$HOME/.bin" -type f -exec chmod +x {} \; 2>/dev/null || true
    chmod +x "$HOME/.bin"/* 2>/dev/null || true
    echo -e "${GREEN}Executáveis${NC} todos os arquivos em ~/.bin"
fi
# 3. starship.toml (arquivo solto dentro de config/)
if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
    link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
fi
# 4. local/share/rofi → ~/.local/share/rofi
if [[ -d "$DOTFILES_DIR/local/share/rofi" ]]; then
    link "$DOTFILES_DIR/local/share/rofi" "$HOME/.local/share/rofi"
fi
# 5. .bashrc na raiz do repositório → ~/.bashrc (sempre com backup)
if [[ -f "$DOTFILES_DIR/.bashrc" ]]; then
    BASHRC_DEST="$HOME/.bashrc"
    # Se já existir (arquivo ou symlink), faz backup com data/hora
    if [[ -e "$BASHRC_DEST" || -L "$BASHRC_DEST" ]]; then
        echo -e "${YELLOW}Backup${NC} ~/.bashrc → ~/.bashrc.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$BASHRC_DEST" "$BASHRC_DEST.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    # Cria o symlink novo
    ln -sf "$DOTFILES_DIR/.bashrc" "$BASHRC_DEST"
    ln -sf "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
    echo -e "${GREEN}Link${NC} ~/.bashrc → $DOTFILES_DIR/.bashrc"
    echo -e "${YELLOW}Dica:${NC} Para aplicar agora → source ~/.bashrc"
fi
# 6. sddm.conf → /etc/sddm.conf
if [[ -f "$DOTFILES_DIR/sddm.conf" ]]; then
    SDDM_DEST="/etc/sddm.conf"
    echo -e "${GREEN}Copiando${NC} sddm.conf para o sistema..."
    sudo cp "$DOTFILES_DIR/sddm.conf" "$SDDM_DEST"
    echo -e "${GREEN}feito${NC} $SDDM_DEST atualizado"
    sudo systemctl enable sddm
    echo -e "${YELLOW}Dica:${NC} Para aplicar agora → sudo systemctl restart sddm"
fi
# 7. Instalando fonts
echo -e "${GREEN}Instalando fonts do amonetlol/fonts...${NC}"
wget -q --show-progress -O ~/.fonts \
  https://github.com/amonetlol/fonts
echo -e "${GREEN}Atualizando cache de fontes...${NC}"
fc-cache -vf
# 8.Fixes
echo -e "${GREEN}FIXES...${NC}"
ln -s "$HOME/.config/qtile/walls" "$HOME/walls"
chmod +x "$DOTFILES_DIR/PERSONAL_FIX/hide_shortcuts"
sh "$DOTFILES_DIR/PERSONAL_FIX/hide_shortcuts"
firefox "$DOTFILES_DIR/PERSONAL_FIX/qtile.html"
# 9 Nvim
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim


echo -e "${GREEN}"
echo "Tudo pronto!"
echo "Reinicie o Qtile (Super + Ctrl + R) ou faça logout/login para aplicar as mudanças."
echo -e "${NC}"
