#!/bin/sh

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sudo apt -y install apt-file build-essential dc flatpak git man ncdu podman rsync unzip
sudo apt -y install libbz2-dev libffi-dev libgdbm-compat-dev libgdbm-dev liblzma-dev libncurses-dev libreadline-dev libsqlite3-dev libssl-dev libzstd-dev pkg-config tk-dev uuid-dev zlib1g-dev # Python build deps

sed -i -e '/^#shopt -s globstar$/s/^#//' \
  -e '/^#force_color_prompt=yes$/s/^#//' \
  -e '/^#\[ -x \/usr\/bin\/lesspipe \] && eval "\$(SHELL=\/bin\/sh lesspipe)"$/s/^#//' ~/.bashrc

cat > ~/.bashrc << 'EOF'
#!/bin/bash
# shellcheck disable=SC1090,SC1091

umask 0077

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth
export HISTIGNORE="*AWS_ACCESS_KEY*:*AWS_SECRET*:*ASSWORD*:*assword*:*OKEN*:*oken*"

# append to the history file, don't overwrite it
shopt -s histappend
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTTIMEFORMAT="[%F %T] "
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export EDITOR=vim
command -v nvim >/dev/null 2>&1 && export EDITOR=nvim
export VISUAL="$EDITOR"
export GOPATH=$HOME/.local/share/go
export GOBIN=$HOME/.local/bin
export NODE_NO_WARNINGS=1
export npm_config_ignore_scripts=true
export npm_config_loglevel=error

# shellcheck disable=SC2076
if [ -d "$HOME/.npm/bin" ] && [[ ! ":$PATH:" =~ ":$HOME/.npm/bin:" ]]; then
  export PATH="$HOME/.npm/bin:$PATH"
fi

# shellcheck disable=SC2076
if [ -d "$HOME/.emacs.d/bin" ] && [[ ! ":$PATH:" =~ ":$HOME/.emacs.d/bin:" ]]; then
  export PATH="$HOME/.emacs.d/bin:$PATH"
fi

eval "$(~/.local/bin/mise activate bash)"

# enable programmable completion features
source /usr/share/bash-completion/bash_completion
# shellcheck source=/dev/null
source "$(mise where fd)"/*/autocomplete/fd.bash
#complete -C gocomplete go
#eval "$(rustup completions bash rustup)"
#eval "$(rustup completions bash cargo)"
eval "$(mise completion bash --include-bash-completion-lib)"
#eval "$(restic generate --bash-completion -)"
eval "$(rg --generate complete-bash)"
eval "$(starship completions bash)"
#eval "$(gh completion -s bash)"
#eval "$(tailscale completion bash)"
eval "$(npm completion)"

eval "$(dircolors -b)"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias uv-recreate='rm -rf .venv && uv venv && find . -name "requirements.txt" -not -path "./node_modules/*" -not -path "./.venv/*" -exec uv pip install -r {} \;'
alias venv-activate='source .venv/bin/activate'
alias fd='fd -H'
[[ $TERM = 'xterm-kitty' ]] && alias rg='rg --hyperlink-format=kitty'

function format_output {
  printf "\n\033[96m==> Running %s:\033[0m\n" "$*"
  "$@"
  echo
}

function morning-ritual {
  if ! (
    set -e

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
    mise prune -y

    [[ -f $HOME/.emacs.d/bin/doom ]] && format_output doom upgrade && format_output doom env
    [[ -f $HOME/.local/bin/claude ]] && format_output claude update

    return 0
  ); then
    echo -e "\033[91mmorning-ritual encountered errors.\033[0m"
    return 1
  fi
}

function get_my_ip {
  curl -w "\n" -4 https://ifconfig.me
}

eval "$(fzf --bash)"

eval "$(starship init bash)"

EOF

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
jq = "latest"
fzf = "latest"
starship = "latest"

[settings]
experimental = true

[settings.python]
compile = true
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
