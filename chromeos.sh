#!/bin/sh

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file build-essential curl flatpak gawk git gnome-keyring podman sqlite3 vim xxd
sudo apt -y --purge autoremove cups-browsed nano

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ataraxia
podman system migrate

sudo usermod -aG adm ataraxia

cd /tmp || exit

# VS Code
wget -O vscode.deb 'https://go.microsoft.com/fwlink/?LinkID=760868'
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt -y install ./vscode.deb

