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
        echo -e "${GREEN}OK${NC}   $dest → $(basename "$src")"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        echo -e "${YELLOW}Backup${NC} $dest → $dest.bak.$(date +%Y%m%d_%H%M%S)"
        mv "$dest" "$dest.bak.$(date +%Y%m%d_%H%M%S)"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo -e "${GREEN}Link${NC}  $dest → $src"
}

# 1. Tudo que está dentro de config/ (exceto bin e starship.toml)
for item in "$DOTFILES_DIR/config"/*/; do
    item=${item%/}
    nome=$(basename "$item")

    # Ignora essas pastas
    [[ "$nome" == "bin" || "$nome" == "dependencias" || "$nome" == "PERSONAL_FIX" ]] && continue

    link "$item" "$HOME/.config/$nome"
done

# 2. bin → ~/.bin
if [[ -d "$DOTFILES_DIR/config/bin" ]]; then
    link "$DOTFILES_DIR/config/bin" "$HOME/.bin"
    # Torna todos os scripts executáveis
    find "$HOME/.bin" -type f -exec chmod +x {} \; 2>/dev/null || true
fi

# 3. starship.toml (arquivo solto dentro de config/)
if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
    link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
fi

# 4. local/share/rofi → ~/.local/share/rofi
if [[ -d "$DOTFILES_DIR/local/share/rofi" ]]; then
    link "$DOTFILES_DIR/local/share/rofi" "$HOME/.local/share/rofi"
fi

echo -e "${GREEN}"
echo "Tudo pronto!"
echo "Reinicie o Qtile (Super + Ctrl + R) ou faça logout/login para aplicar as mudanças."
echo -e "${NC}"
