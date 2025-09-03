#!/bin/sh

sudo hostnamectl hostname lunaria

echo '%wheel ALL=(ALL) NOPASSWD:/usr/bin/dnf update' | sudo tee /etc/sudoers.d/dnf
sudo chmod 440 /etc/sudoers.d/dnf
sudo visudo -c

sudo sed -i -e '/daemon/aAutomaticLoginEnable=True\nAutomaticLogin=ataraxia' /etc/gdm/custom.conf

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo firewall-cmd --remove-service=ssh
sudo firewall-cmd --remove-service=samba-client
sudo firewall-cmd --remove-port=1025-65535/udp
sudo firewall-cmd --remove-port=1025-65535/tcp
sudo firewall-cmd --set-log-denied=all
sudo firewall-cmd --runtime-to-permanent

sudo dnf -y update

sudo dnf -y install --allowerasing atuin awscli2 cargo clippy fish gh golang nodejs restic rustfmt rust-src typescript vim-default-editor yarnpkg

sudo dnf -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

sudo dnf -y swap --allowerasing ffmpeg-free ffmpeg
sudo dnf -y install intel-media-driver

sudo tee /etc/yum.repos.d/vscode.repo <<EOF
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

flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

chsh -s /usr/bin/fish
