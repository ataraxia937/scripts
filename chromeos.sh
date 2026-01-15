#!/bin/sh

sudo sed -i -e 's/bookworm/trixie/' /etc/apt/sources.list

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sudo apt -y install alacritty apt-file build-essential flatpak jq rsync

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

curl https://mise.run | sh
echo "eval \"\$(/home/ataraxia/.local/bin/mise activate bash)\"" >> ~/.bashrc
eval "$(/home/ataraxia/.local/bin/mise activate bash)"

curl -Lo /tmp/font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip
mkdir $HOME/.local/share/fonts
unzip -d $HOME/.local/share/fonts/ /tmp/font.zip SymbolsNerdFontMono-Regular.ttf
fc-cache

mkdir $HOME/.config/alacritty
curl -Lo $HOME/.config/alacritty/alacritty.toml https://codeberg.org/ataraxia937/scripts/raw/branch/main/configs/alacritty.toml
