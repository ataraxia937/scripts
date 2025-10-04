#!/bin/sh

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install apt-file build-essential curl flatpak gawk git podman sqlite3 vim-tiny
sudo apt -y --purge autoremove cups-browsed nano

sudo flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ataraxia
podman system migrate

sudo usermod -aG adm ataraxia
