#!/bin/ksh

set -ex

pkg_add chromium noto-fonts noto-cjk sysclean

chmod 600 /usr/local/bin/dbus-launch

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
​​set-option -g history-limit 10000
set-option -g mode-keys vi
set-option -g mouse on
set-option -g prefix2 \`
set-option -g renumber-windows on
set-option -gw window-status-current-style bg=red
bind-key \` send-prefix -2
TMUX

cat >> /home/ataraxia/.Xdefaults <<XDEFAULTS
XTerm*allowMouseOps:true
XTerm*faceName:monospace
XTerm*faceSize:14
XTerm*saveLines:10000
XTerm*scrollKey:true
XTerm*scrollTtyOutput:false
XTerm*selectToClipboard:true
Xft.autohint:0
Xft.lcdfilter:lcddefault
Xft.hintstyle:hintslight
Xft.hinting:1
Xft.antialias:1
Xft.rgba:rgb
XLock*dpmsoff:5
*font: -misc-fixed-medium-r-normal--20-140-100-100-c-100-iso8859-1
XDEFAULTS

mkdir -p /home/ataraxia/.config/gtk-3.0
cat > /home/ataraxia/.config/gtk-3.0/settings.ini <<GTK
[Settings]
gtk-cursor-theme-name = Adwaita
gtk-font-name = sans 12
GTK

cat > /home/ataraxia/.cwmrc <<CWM
fontname "sans:size=14"
CWM

mkdir /home/ataraxia/bin

cat > /home/ataraxia/bin/chrome <<CHROME
#!/bin/sh

/usr/local/bin/chrome --force-device-scale-factor=1.25 "$@"
CHROME

cat > /home/ataraxia/.xsession <<XSESSION
PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin
export LC_CTYPE="en_US.UTF-8"
setxkbmap -option compose:caps
xset s off
xset dpms 0 0 0
xterm &
chrome &
exec cwm
XSESSION

mkdir -p /home/ataraxia/.config/alacritty
cat > /home/ataraxia/.config/alacritty/alacritty.toml <<ALACRITTY
[general]
ipc_socket = false

[window]
dimensions.columns = 80
dimensions.lines = 24
startup_mode = "Maximized"
resize_increments = true

[font]
size = 14

[terminal]
shell.program = "/bin/ksh"
shell.args = ["-l"]

[[hints.enabled]]
command = "xdg-open"
hyperlinks = true
post_processing = true
persist = false
mouse.mods = "Control"
mouse.enabled = true
binding = { key = "O", mods = "Control|Shift" }
regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^⟨⟩`\\\\]+"

[colors.primary]
background = '#f8f8f8'
foreground = '#2a2b33'

[colors.normal]
black   = '#000000'
red     = '#de3d35'
green   = '#3e953a'
yellow  = '#d2b67b'
blue    = '#2f5af3'
magenta = '#a00095'
cyan    = '#3e953a'
white   = '#bbbbbb'

[colors.bright]
black   = '#000000'
red     = '#de3d35'
green   = '#3e953a'
yellow  = '#d2b67b'
blue    = '#2f5af3'
magenta = '#a00095'
cyan    = '#3e953a'
white   = '#ffffff'
ALACRITTY

su ataraxia -c sndioctl

mkdir /home/ataraxia/Downloads

chown -R ataraxia:ataraxia /home/ataraxia
chmod 755 /home/ataraxia/.xsession
chmod 755 /home/ataraxia/bin/chrome
