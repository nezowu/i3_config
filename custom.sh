#chmod 644 /etc/profile.d/custom.sh
if [[ $(tty) =~ "/dev/tty" ]]; then
        if [ "$PS1" ]; then
                PS1="[\A@\l \W]\\$ "
		setterm --blank 0 #отмена выключения экрана
        fi
fi
