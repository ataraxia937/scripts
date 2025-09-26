#!/bin/sh

# Update software
sudo apt -y update
sudo apt -y upgrade

# Configure DNS
conn="$(nmcli --terse --field NAME connection show --active | head -n1)"
sudo nmcli connection modify "$conn" ipv4.dns '9.9.9.9#dns.quad9.net,149.112.112.112#dns.quad9.net'
sudo nmcli connection modify "$conn" ipv4.ignore-auto-dns yes
sudo nmcli connection modify "$conn" ipv6.dns '2620:fe::fe#dns.quad9.net,2620:fe::9#dns.quad9.net'
sudo nmcli connection modify "$conn" ipv6.ignore-auto-dns yes
sudo nmcli connection modify "$conn" connection.dns-over-tls 2
sudo nmcli connection down "$conn"
sudo nmcli connection up "$conn"

# Configure sudo
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt update' | sudo tee /etc/sudoers.d/apt
echo '%sudo ALL=(ALL) NOPASSWD:/usr/bin/apt upgrade' | sudo tee -a /etc/sudoers.d/apt
sudo chmod 440 /etc/sudoers.d/apt
sudo visudo -c

# Harden ptrace
echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Install / remove debs
sudo apt -y install apt-file build-essential chrony curl flatpak fonts-noto gawk git jq needrestart-session podman ptyxis sqlite3 systemd-resolved ufw vim xclip xxd
sudo apt -y --purge autoremove cups-browsed fonts-dejavu\* gnome-terminal nano

# Reload D-Bus again because the systemd-resolve user is created too slowly to be picked up the first time
sudo systemctl reload dbus

# Configure Flatpak
sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Configure group memberships
sudo usermod -aG adm ataraxia

# Enable firewall
sudo ufw enable

# Move to /tmp before downloading things
cd /tmp || exit

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb
sudo /etc/cron.daily/google-chrome

# VS Code
wget -O vscode.deb 'https://go.microsoft.com/fwlink/?LinkID=760868'
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt -y install ./vscode.deb

