#!/bin/sh

echo '%wheel ALL=(ALL) NOPASSWD:/usr/bin/dnf update' | sudo tee /etc/sudoers.d/dnf
sudo chmod 440 /etc/sudoers.d/dnf
sudo visudo -c

echo 'kernel.yama.ptrace_scope = 3' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo dnf -y update

sudo dnf -y install google-chrome-stable restic vim-default-editor
