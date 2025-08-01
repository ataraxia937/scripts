#!/bin/sh

echo '%wheel ALL=(ALL) NOPASSWD:/usr/bin/dnf update' | sudo tee /etc/sudoers.d/dnf
sudo chmod 440 /etc/sudoers.d/dnf

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo dnf -y update

sudo dnf -y install atuin cargo clippy dotnet-sdk-8.0 gh golang google-chrome-stable node pylint restic rust-src rustfmt shellcheck typescript vim-default-editor wine yarnpkg

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
