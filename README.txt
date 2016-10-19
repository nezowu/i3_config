apt-get install --no-install-recommends xserver-xorg xserver-xorg-core \
xfonts-base xinit libgl1-mesa-dri x11-xserver-utils
apt-get install i3 suckless-tools

systemctl set-default rescue.target #однопользовательский режим
systemctl set-default multi-user.target
systemctl set-default graphical.target

cd /etc/X11
cp xorg.conf{,.bak)
Xorg -configure
Xorg -retro -config xorg.conf.new
startx

dnf groupinstall "X Window System" "Fonts"
dnf install i3 i3status dmenu

.xinitrc
exec i3
