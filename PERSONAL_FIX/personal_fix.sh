#!/usr/bin/env bash
set -euo pipefail

echo "fastfetch config"
# fastfetch
mkdir -p "${HOME}/.config/fastfetch/"
curl -sSLo "${HOME}/.config/fastfetch/config.jsonc" https://raw.githubusercontent.com/amonetlol/arch_vm/main/fastfetch_ChrisTitus-config.jsonc

echo "alias config"
# set alias
curl -sSLo "${HOME}/.aliases.sh" https://github.com/amonetlol/arch/raw/refs/heads/main/aliases.sh
echo 'source ~/.aliases.sh' >> ~/.bashrc

# starship
# echo "starship config"
# echo 'eval "$(starship init bash)"' >> ~/.bashrc
# wget -O ~/.config/starship.toml https://raw.githubusercontent.com/amonetlol/terminal-bash/refs/heads/main/starship.toml

echo "Fonts config"
wget -q --show-progress -O ~/.fonts \
  https://github.com/amonetlol/fonts

echo "Atualizando cache de fontes..."
fc-cache -fv

