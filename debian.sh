#!/bin/sh

echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt update' | sudo tee /etc/sudoers.d/apt
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt upgrade' | sudo tee -a /etc/sudoers.d/apt
sudo chmod 440 /etc/sudoers.d/apt
sudo visudo -c

sudo usermod -aG adm ataraxia

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file build-essential chrony curl flatpak fonts-noto gawk git needrestart-session podman ptyxis python3-pip python3-venv restic sqlite3 ufw vim xclip xxd
sudo apt -y --purge autoremove fonts-dejavu\* gnome-terminal nano

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo ufw enable

cd /tmp || exit

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb
sudo /etc/cron.daily/google-chrome

# VS Code
wget -O vscode.deb 'https://go.microsoft.com/fwlink/?LinkID=760868'
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt -y install ./vscode.deb

