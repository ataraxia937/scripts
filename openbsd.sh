#!/bin/ksh

set -ex

syspatch || true

pkg_add ffmpeg firefox
#pkg_add avahi cups

rcctl enable unwind #messagebus avahi_daemon cupsd
rcctl start unwind #messagebus avahi_daemon cupsd

sed -i -e 's/datasize-cur=1536M/datasize-cur=infinity/' /etc/login.conf

# 85 is too loud, 64 is too quiet
echo 'outputs.master=75' > /etc/mixerctl.conf

sed -i -e '/console$/s/#//' /etc/syslog.conf

echo 'lunaria' > /etc/myname
hostname lunaria

cat > /etc/hosts <<HOSTS
127.0.0.1       localhost lunaria
::1             localhost lunaria
#192.168.0.35    printer.local printer
HOSTS

cat > /etc/daily.local <<DAILY
syspatch
fw_update
pkg_add -u
DAILY

#lpadmin -p lp -E -v ipp://printer.local:631/ipp/print -m everywhere
#lpadmin -d lp

cat >> /root/.profile <<ROOTPROFILE
umask 022
export HISTFILE="\$HOME/.ksh_history"
PS1='\u:\w:\!:\\$ '
alias ls='ls -F'
ROOTPROFILE

echo 'gap 36 0 0 0' > /home/ataraxia/.cwmrc

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
XClock*analog:false
XClock*face:mono
XClock*render:true
XClock*strftime:%a %b %e %l:%M
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
xclock -geometry -0+0 &
xterm -geometry +0+0 &
xterm -geometry +0-0 &
firefox &
exec cwm
XSESSION

su ataraxia -c sndioctl

mkdir /home/ataraxia/Downloads

chown -R ataraxia:ataraxia /home/ataraxia
chmod 755 /home/ataraxia/.xsession

