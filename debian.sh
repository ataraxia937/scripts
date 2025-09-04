#!/bin/sh

echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt update' | sudo tee /etc/sudoers.d/apt
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt upgrade' | sudo tee -a /etc/sudoers.d/apt
sudo chmod 440 /etc/sudoers.d/apt
sudo visudo -c

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file chrony curl flatpak fonts-noto git needrestart-session podman ptyxis restic sqlite3 ufw vim xclip xxd
sudo apt -y --purge autoremove fonts-dejavu\* gnome-terminal nano

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo ufw enable

cd /tmp || exit

