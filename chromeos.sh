#!/bin/sh

sudo sed -i -e 's/bookworm/trixie/' /etc/apt/sources.list

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sed -i -e '/^#shopt -s globstar$/s/^#//' \
  -e '/^#force_color_prompt=yes$/s/^#//' \
  -e '/^#\[ -x \/usr\/bin\/lesspipe \] && eval "\$(SHELL=\/bin\/sh lesspipe)"$/s/^#//' ~/.bashrc

sudo apt -y install apt-file build-essential dc fd-find flatpak git jq ncdu ripgrep rsync unzip

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "export npm_config_ignore_scripts=true" >> ~/.bashrc

curl https://mise.run | sh
echo "eval \"\$(/home/ataraxia937/.local/bin/mise activate bash)\"" >> ~/.bashrc
eval "$(/home/ataraxia937/.local/bin/mise activate bash)"

mkdir ~/.config/mise
curl -Lo ~/.config/mise/config.toml https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/mise_config.toml
mise install

curl -Lo /tmp/font.zip
mkdir -p ~/.local/share/fonts
unzip -d ~/.local/share/fonts /tmp/font.zip
fc-cache

sudo gpasswd -a ataraxia937 render
mkdir -p ~/.config/kitty
curl -Lo ~/.config/kitty/kitty.conf https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/kitty.conf
