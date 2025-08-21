#!/bin/sh

echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt update' | sudo tee /etc/sudoers.d/apt
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt upgrade' | sudo tee -a /etc/sudoers.d/apt
sudo chmod 440 /etc/sudoers.d/apt
sudo visudo -c

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file build-essential curl fd-find flatpak fonts-noto fzf gawk git gnome-console gnome-shell-extension-dashtodock imagemagick luarocks needrestart-session podman python3-pip python3-pynvim python3-venv restic ruby ruby-dev sqlite3 vim wl-clipboard xxd
sudo apt -y --purge autoremove fonts-dejavu\* gnome-terminal nano xclip

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

cd /tmp || exit

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb
sudo /etc/cron.daily/google-chrome

# VS Code
wget -O vscode.deb 'https://go.microsoft.com/fwlink/?LinkID=760868'
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt -y install ./vscode.deb

# Spotify
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

restic restore latest -t /
