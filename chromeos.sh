#!/bin/sh

sudo sed -i -e 's/bookworm/trixie/' /etc/apt/sources.list

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sudo apt -y install apt-file build-essential dc fd-find flatpak jq ncdu ripgrep rsync

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

curl https://mise.run | sh
echo "eval \"\$(/home/ataraxia/.local/bin/mise activate bash)\"" >> ~/.bashrc
eval "$(/home/ataraxia/.local/bin/mise activate bash)"

mkdir $HOME/.config/mise
curl -Lo $HOME/.config/mise/config.toml https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/mise_config.toml
mise -C $HOME install
