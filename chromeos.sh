#!/bin/sh

sudo sed -i -e 's/bookworm/trixie/' /etc/apt/sources.list

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sed -i -e '/^#shopt -s globstar$/s/^#//' \
  -e '/^#force_color_prompt=yes$/s/^#//' \
  -e '/^#\[ -x \/usr\/bin\/lesspipe \] && eval "\$(SHELL=\/bin\/sh lesspipe)"$/s/^#//' $HOME/.bashrc

sudo apt -y install apt-file build-essential dc fd-find flatpak git jq ncdu ripgrep rsync unzip

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

curl https://mise.run | sh
echo "eval \"\$(/home/ataraxia/.local/bin/mise activate bash)\"" >> ~/.bashrc
eval "$(/home/ataraxia/.local/bin/mise activate bash)"

mkdir $HOME/.config/mise
curl -Lo $HOME/.config/mise/config.toml https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/mise_config.toml
mise -C $HOME install

curl -Lo /tmp/font.zip
mkdir -p $HOME/.local/share/fonts
unzip -d $HOME/.local/share/fonts /tmp/font.zip
fc-cache

sudo gpasswd -a ataraxia937 render
mkdir -p $HOME/.config/kitty
curl -Lo $HOME/.config/kitty/kitty.conf https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/kitty.conf
