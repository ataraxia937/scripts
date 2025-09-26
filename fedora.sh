#!/bin/sh

# Set hostname
sudo hostnamectl hostname lunaria

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
echo '%wheel ALL=(ALL) NOPASSWD:/usr/bin/dnf update' | sudo tee /etc/sudoers.d/dnf
sudo chmod 440 /etc/sudoers.d/dnf
sudo visudo -c

# Configure auto-login
sudo sed -i -e '/daemon/aAutomaticLoginEnable=True\nAutomaticLogin=ataraxia' /etc/gdm/custom.conf

# Harden ptrace
echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure firewall
sudo firewall-cmd --remove-service=ssh
sudo firewall-cmd --remove-service=samba-client
sudo firewall-cmd --remove-port=1025-65535/udp
sudo firewall-cmd --remove-port=1025-65535/tcp
sudo firewall-cmd --add-service=mdns
sudo firewall-cmd --set-log-denied=all
sudo firewall-cmd --runtime-to-permanent

# Update software
sudo dnf -y update

# Install packages
sudo dnf -y install --allowerasing google-chrome-stable vim-default-editor

# Clean up unneeded packages
sudo dnf -y autoremove

# Configure Flatpak
flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install VS Code
sudo tee /etc/yum.repos.d/vscode.repo << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sudo dnf -y install code