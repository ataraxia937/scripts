#!/bin/sh

echo '%wheel ALL=(ALL) NOPASSWD:/usr/bin/dnf update' | sudo tee /etc/sudoers.d/dnf
sudo chmod 440 /etc/sudoers.d/dnf

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo dnf -y update

sudo dnf -y install google-chrome-stable restic vim-default-editor

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

restic restore latest -t /

