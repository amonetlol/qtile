alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias exe='chmod +x'
alias ft='fastfetch --logo small'
alias grep='grep -i'
alias jrnctl='journalctl -p 3 -xb'
alias off='poweroff'
alias weather="curl -s 'wttr.in/Ubatuba?0&lang=pt-br'"
alias tempo='curl -s https://wttr.in/Ubatuba\?format\="%t\n" | head -n 3'
alias cat='bat'
alias tping='ping -c4 google.com'
alias kill='kill -9'
alias killall='killall -9'
alias free-mem="sudo sh -c 'echo 1 >  /proc/sys/vm/drop_caches' && sudo sh -c 'echo 3 >  /proc/sys/vm/drop_caches'"
alias logs="systemctl --failed; echo; journalctl -p 3 -b"
alias gfont2='kitty +list-fonts | grep'
alias gfont='fc-list -f "%{family}\n" | grep -i '

alias al='nvim ~/.bashrc ~/.aliases.sh'
alias .r='source ~/.bashrc'
alias up2='yay -Syyu --noconfirm'
alias yay='yay --noconfirm'
alias yin='yay --noconfirm -S'
alias yse='yay -Ss'
alias ysel='yay -Qq | grep'
alias yre='yay --noconfirm -R'
alias yinfo='yay -Si'
alias rpac='sudo reflector --country Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist'
alias orf='sudo pacman -Qtdq | sudo pacman -Rns -'
alias cls='sudo pacman -Scc && yay -Sc'
alias man='tldr'
alias nv='nvim'
alias v='nvim'
alias df='duf -hide special'
alias duf='duf -hide special'
alias ff='sh ~/Scripts/fsearch'
alias hg='history | grep'
alias ag='alias | grep'
alias j-edit='nv ~/.local/share/autojump/autojump.txt'
alias inxi='inxi -Fxz'
alias fv='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs -r nvim'
alias nf='nerdfetch'

## Nvim
alias nup='nvim --headless -c "Lazy update" -c "qa"'

# --- ls --- #
alias lg="ls | grep"
alias ls='eza -lah --color=always --group-directories-first --icons'
alias ll='eza -lah --color=always --group-directories-first --icons'
alias lr='eza -R --color=always --icons --oneline'
alias lrv1='eza -R --color=always --icons --oneline --level=1'
alias lrv2='eza -R --color=always --icons --oneline --level=2'
alias ld='eza -lah --color=always --group-directories-first --icons --sort mod' # sort by date/time
alias tree='eza --tree --icons --group-directories-first'
#alias lt="command ls -l | awk 'NR>1 {print $9}'"
lt() {
  command ls -l | awk 'NR>1 {print $9}'
  #command eza -l --color=always --group-directories-first --icons | awk '{print $7, $8, $9}'
}

alias tx='gnome-text-editor'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Qtile
alias qre='qtile cmd-obj -o cmd -f restart'
alias qd='cd ~/.config/qtile && ll'
