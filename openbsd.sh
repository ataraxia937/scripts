#!/bin/ksh

set -ex

syspatch || true

pkg_add ffmpeg firefox

chmod 600 /usr/bin/bin/dbus-launch

rcctl enable unwind
rcctl start unwind

sed -i -e '73s/1536M/infinity/' /etc/login.conf

# 85 is too loud, 64 is too quiet
echo 'outputs.master=75' > /etc/mixerctl.conf

sed -i -e '/console$/s/#//' /etc/syslog.conf

echo 'lunaria' > /etc/myname
hostname lunaria

cat > /etc/hosts <<HOSTS
127.0.0.1       localhost lunaria
::1             localhost lunaria
HOSTS

cat > /etc/pf.conf <<PF
set skip on lo
block return log
pass out
pass proto {icmp icmp6}
PF

cat > /etc/daily.local <<DAILY
syspatch
fw_update
pkg_add -u
DAILY

cat >> /root/.profile <<ROOTPROFILE
umask 022
export HISTFILE="\$HOME/.ksh_history"
PS1='\u:\w:\!:\\$ '
alias ls='ls -F'
ROOTPROFILE

cat >> /home/ataraxia/.profile <<USERPROFILE
umask 077
export HISTFILE="\$HOME/.ksh_history"
export LC_CTYPE="en_US.UTF-8"
PS1='\u:\w:\!:\\$ '
alias ls='ls -F'
USERPROFILE

cat > /home/ataraxia/.tmux.conf << TMUX
set-option -g mode-keys vi
set-option -g mouse on
set-option -g prefix2 \`
set-option -g renumber-windows on
set-option -gw window-status-current-style bg=red
bind-key \` send-prefix -2
TMUX

cat >> /home/ataraxia/.Xdefaults <<XDEFAULTS
XTerm*faceName:mono
XTerm*faceSize:12
XTerm*saveLines:10000
XTerm*scrollKey:true
XTerm*scrollTtyOutput:false
Xft.autohint:0
Xft.lcdfilter:lcddefault
Xft.hintstyle:hintslight
Xft.hinting:1
Xft.antialias:1
Xft.rgba:rgb
XLock*dpmsoff:5
XDEFAULTS

mkdir -p /home/ataraxia/.config/gtk-3.0
cat > /home/ataraxia/.config/gtk-3.0/settings.ini <<GTK
[Settings]
gtk-cursor-theme-name = Adwaita
gtk-font-name = Sans 11
GTK

cat > /home/ataraxia/.xsession <<XSESSION
export LC_CTYPE="en_US.UTF-8"
setxkbmap -option compose:caps
xset s off
xset dpms 0 0 0
xterm &
firefox &
exec cwm
XSESSION

su ataraxia -c sndioctl

mkdir /home/ataraxia/Downloads

chown -R ataraxia:ataraxia /home/ataraxia
chmod 755 /home/ataraxia/.xsession

