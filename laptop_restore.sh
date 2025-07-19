#!/bin/bash

# Disable Secure Boot
# Install Ubuntu with FDE, name it rkohler
# NVIDIA driver - latest non-server, non-open
# Set root password
# Update software, firmware, snaps and maybe reboot

# Install AWS CLI:
mkdir -p ~/bin ~/.local/share/aws-cli
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install --install-dir ~/.local/share/aws-cli --bin-dir ~/bin

# Load s3backup from chef-repo
# Download restic and install it to ~/bin
cd /tmp
curl -LO "https://github.com/restic/restic/releases/latest/download/restic_$(uname -s)_$(uname -m).bz2"
bunzip2 restic_$(uname -s)_$(uname -m).bz2
mv restic ~/bin/
chmod +x ~/bin/restic

# Create .aws/config and s3backup config files
mkdir -p ~/.aws ~/.config/s3backup
cat <<EOL > ~/.aws/config
[profile laptop-backup]
sso_session = renovo
sso_account_id = 536912249256
sso_role_name = LinuxLaptopBackup
region = us-east-2

[sso-session renovo]
sso_start_url = https://renovo.awsapps.com/start#/
sso_region = us-east-1
sso_registration_scopes = sso:account:access
EOL

cat <<EOL > ~/.config/s3backup/excludes.txt
.cache
local-mode-cache
EOL

cat <<EOL > ~/.config/s3backup/profile.txt
laptop-backup
EOL

# Restore backup from S3
s3backup restore -t / latest

# Install software and copy files back into place
sudo apt install aptitude curl dos2unix git vim
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation -v 25.5.1084
sudo install -D -m 600 -o 0 -g 0 /home/rkohler/Documents/vpn/*.conf /etc/openvpn
sudo install -D -m 644 -o 0 -g 0 /home/rkohler/Documents/Yubico/u2f_keys /etc/Yubico/u2f_keys
sudo add-apt-repository ppa:fish-shell/release-4
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo chmod 644 /etc/apt/sources.list.d/*
sudo chmod 644 /usr/share/keyrings/*
sudo apt update
sudo apt install fish nodejs
sudo chsh -s /usr/bin/fish rkohler

# Log out and back in with fish

# Install Renovo Chef cookbooks
cd /home/rkohler/repos/chef-repo/cookbooks
sudo -E cinc-client -z -o 'recipe[renovo-workstation]'
sudo -E cinc-client -z -o 'recipe[renovo-github-cli]'
sudo -E cinc-client -z -o 'recipe[renovo-yubikey::linux_ppa],recipe[renovo-yubikey::pam_u2f]'
sudo -E cinc-client -z -o 'recipe[renovo-yubikey::linux_sudo],recipe[renovo-yubikey::linux_login],recipe[renovo-yubikey::linux_lock],recipe[renovo-yubikey::linux_tty],recipe[renovo-yubikey::linux_polkit]'

# Test Yubikey PAM
pkexec ls

# Clean up
sudo chown -R rkohler:rkohler /home/rkohler
sudo apt --purge autoremove gitkraken microsoft-edge-stable
sudo rm -f /etc/apt/sources.list.d/microsoft-edge.list

# TODO: Fix after USG hardening
