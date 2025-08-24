#!/bin/sh

echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt update' | sudo tee /etc/sudoers.d/apt
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt upgrade' | sudo tee -a /etc/sudoers.d/apt
sudo chmod 440 /etc/sudoers.d/apt
sudo visudo -c

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file build-essential curl fd-find fish flatpak fonts-noto fzf gawk git imagemagick libsqlite3-dev luarocks needrestart-session podman ptyxis python3-pip python3-pynvim python3-venv restic ruby ruby-dev sqlite3 vim xclip xxd
sudo apt -y --purge autoremove fonts-dejavu\* gnome-terminal nano

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

chsh -s /usr/bin/fish
