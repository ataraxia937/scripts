#!/bin/sh

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sed -i -e '/^#shopt -s globstar$/s/^#//' \
  -e '/^#force_color_prompt=yes$/s/^#//' \
  -e '/^#\[ -x \/usr\/bin\/lesspipe \] && eval "\$(SHELL=\/bin\/sh lesspipe)"$/s/^#//' ~/.bashrc

cat >> ~/.bashrc << 'EOF'

export npm_config_ignore_scripts=true

eval "$($HOME/.local/bin/mise activate bash)"

function format_output {
  printf "\n\033[96m==> Running %s:\033[0m\n" "$*"
  "$@"
  echo
}

function morning-ritual {
  (
    set -e
    sudo -v

    format_output sudo apt update
    format_output sudo apt upgrade --allow-downgrades -y
    format_output sudo apt dist-upgrade --allow-downgrades -y
    format_output sudo flatpak update -y
    format_output sudo flatpak uninstall --unused -y
    format_output sudo apt autoremove -y --purge

    format_output mise self-update -y
    format_output mise plugins upgrade -y
    format_output mise upgrade -y
    eval "$(mise hook-env)"
    if [[ -f $HOME/.local/state/mise/python_updated ]]; then
      format_output mise install -f -C "$HOME" 'pipx:*'
      rm -f "$HOME/.local/state/mise/python_updated"
    fi

    [[ -f $HOME/.emacs.d/bin/doom ]] && format_output doom upgrade && format_output doom env
    [[ -f $HOME/.local/bin/claude ]] && format_output claude update

    return 0
  )

  if [[ $? -ne 0 ]]; then
    echo -e "\033[91mmorning-ritual encountered errors.\033[0m"
    return 1
  fi
}
EOF

sudo apt -y install apt-file build-essential dc flatpak git jq man ncdu podman rsync unzip
sudo apt -y install libbz2-dev libffi-dev libgdbm-compat-dev libgdbm-dev liblzma-dev libncurses-dev libreadline-dev libsqlite3-dev libssl-dev libzstd-dev pkg-config tk-dev uuid-dev zlib1g-dev

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

curl https://mise.run | sh

. ~/.bashrc

mkdir -p ~/.config/containers
echo 'unqualified-search-registries = ["docker.io", "quay.io"]' > ~/.config/containers/registries.conf

cat > ~/.vimrc <<'EOF'
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set tabstop=2        " Sets the width of a tab character to 2 spaces
set softtabstop=2    " Sets the number of spaces a <Tab> keypress inserts
set shiftwidth=2     " Sets the width of an indent (used by autoindent, >>, <<)
set expandtab        " Converts tabs to spaces automatically
set autoindent       " Automatically indents new lines
set smartindent      " Smarter auto-indent for C-like languages
filetype plugin indent on " Enable filetype-specific indenting
set wrap

set background=light
EOF

mkdir ~/.config/mise
cat > ~/.config/mise/config.toml <<'EOF'
[tools]
node = "lts"
python = "latest"
usage = "latest"
uv = "latest"
fd = "latest"
ripgrep = "latest"

[settings]
experimental = true
EOF
mise install

curl -Lo /tmp/nerdfont.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip
mkdir -p ~/.local/share/fonts
unzip -d ~/.local/share/fonts -j /tmp/nerdfont.zip '.ttf'
fc-cache
rm -f /tmp/nerdfont.zip

sudo gpasswd -a ataraxia937 render
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf <<'EOF'
font_family Cousine
symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D7,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B8,U+E700-U+E7C5,U+EA60-U+EC1E,U+F000-U+F2FF,U+F300-U+F372,U+F400-U+F533,U+F0001-U+F1AF0 Symbols Nerd Font
font_size 12.0
text_composition_strategy 1.5
scrollback_lines 2000
scrollback_pager_history_size 4096
paste_actions replace-dangerous-control-codes
enable_audio_bell no
window_alert_on_bell no
remember_window_size yes
initial_window_width 80c
initial_window_height 24c
strip_trailing_spaces always
active_tab_background red
active_tab_font_style bold
inactive_tab_font_style italic

# Smaller bottom split - doesn't work in old versions of kitty
#map ctrl+shift+enter launch --cwd=current --bias=30

# Require Shift to click links
mouse_map left click ungrabbed mouse_handle_click selection prompt
mouse_map shift+left click ungrabbed mouse_handle_click link

# Atom One Light color scheme
background #F8F8F8
foreground #2A2B32
cursor #2A2B32
cursor_text_color background

# Normal colors
color0 #000000
color1 #DA3E39
color2 #41933E
color3 #855504
color4 #315EEE
color5 #930092
color6 #0E6FAD
color7 #8E8F96

# Bright colors
color8 #2A2B32
color9 #DA3E39
color10 #41933E
color11 #855504
color12 #315EEE
color13 #930092
color14 #0E6FAD
color15 #FFFEFE
EOF
