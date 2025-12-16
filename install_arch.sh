#!/usr/bin/env bash
set -euo pipefail

# base-devel archlinux-keyring

pre_install(){
    echo 'MAKEFLAGS="-j$(nproc)"' | sudo tee -a /etc/makepkg.conf
}

aur_helper(){    
    if [ ! -d "$HOME/.src" ]; then
        mkdir -p "$HOME/.src" && cd "$HOME/.src" && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg --noconfirm -si        
    else
        cd "$HOME/.src" && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg --noconfirm -si
    fi  
    
}


# Arch
packages="
  visual-studio-code-bin
  polkit-gnome
  pavucontrol
  reflector
  rsync
  xorg-xrandr
  ttf-jetbrains-mono-nerd
  firefox
  python-psutil
  python-dbus-next
  wget
  neovim
  git
  kitty
  rofi
  scrot
  xclip
  dunst
  alsa-utils
  alacritty
  picom
  unzip
  fastfetch
  eza
  duf
  starship
  btop
  ripgrep
  gcc
  luarocks
  ripgrep
  lazygit
  pmenu
  dmenu
  maim
  loupe
  mousepad
  numlockx
  thunar
  thunar-volman
  thunar-archive-plugin
  file-roller
  gvfs
  zip
  unzip
  p7zip
  unrar
  bat
  nwg-look
  xdg-user-dirs
  sddm-sugar-dark
  xdotool
  jq
  xxhsum
  xwallpaper
  imagemagick
  findutils
  coreutils
  bc
  lua51
  python-pipenv
  python-nvim
  tree-sitter-cli
  npm
  nodejs
  fd
  feh
  qtile
"

vm(){
    yay -S --needed --noconfirm open-vm-tools fuse2 gtkmm3
    sudo systemctl enable --now vmtoolsd
}

install(){
    yay -S --needed --noconfirm $packages
}

fix(){
    xdg-user-dirs-update
}

# função
pre_install
aur_helper
install
vm
fix








