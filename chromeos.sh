#!/bin/sh

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sed -i -e '/^#shopt -s globstar$/s/^#//' \
  -e '/^#force_color_prompt=yes$/s/^#//' \
  -e '/^#\[ -x \/usr\/bin\/lesspipe \] && eval "\$(SHELL=\/bin\/sh lesspipe)"$/s/^#//' ~/.bashrc

sudo apt -y install apt-file build-essential dc fd-find flatpak git jq man ncdu podman ripgrep rsync unzip

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "export npm_config_ignore_scripts=true" >> ~/.bashrc

curl https://mise.run | sh
echo "eval \"\$($HOME/.local/bin/mise activate bash)\"" >> ~/.bashrc

. ~/.bashrc

mkdir -p ~/.config/containers
echo 'unqualified-search-registries = ["docker.io", "quay.io"]' > ~/.config/containers/registries.conf

curl -Lo ~/.vimrc https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/vimrc

mkdir ~/.config/mise
curl -Lo ~/.config/mise/config.toml https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/mise_config.toml
mise install

curl -Lo /tmp/font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip
mkdir -p ~/.local/share/fonts
unzip -d ~/.local/share/fonts /tmp/font.zip
find ~/.local/share/fonts ! -name '*.ttf' -type f -delete
fc-cache

sudo gpasswd -a ataraxia937 render
mkdir -p ~/.config/kitty
curl -Lo ~/.config/kitty/kitty.conf https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/kitty.conf
