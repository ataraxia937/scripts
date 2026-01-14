#!/bin/sh

sudo sed -i -e 's/bookworm/trixie/' /etc/apt/sources.list

sudo apt -y update
sudo apt -y full-upgrade
sudo apt -y --purge autoremove

sudo apt -y install apt-file build-essential flatpak jq rsync

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

curl https://mise.run | sh
echo "eval \"\$(/home/ataraxia/.local/bin/mise activate bash)\"" >> ~/.bashrc
eval "$(/home/ataraxia/.local/bin/mise activate bash)"
