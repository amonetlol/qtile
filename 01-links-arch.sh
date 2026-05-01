#!/usr/bin/env bash
#bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/scripts/main/01-links-arch.sh)

DIR="$HOME/.src/qtile"

ln -sf $DIR/bin ~/.bin
chmod +x $DIR/bin/*
ln -sf $DIR/.aliases ~/.aliases
ln -sf $DIR/.aliases-arch ~/.aliases-arch
ln -sf $DIR/.bashrc ~/.bashrc
ln -sf $DIR/config/starship.toml ~/.config/starship.toml
ln -sf $DIR/config/fastfetch ~/.config/fastfetch
ln -sf $DIR/config/neofetch ~/.config/neofetch
ln -sf $DIR/local/share/applications ~/.local/share/applications

echo "Done!!!!"
