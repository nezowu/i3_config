#chmod 644 /etc/profile.d/ranger.sh
if [ $(ps -p $PPID -o comm=) = "ranger" ]; then
	if [ $(id -u) -eq 0 ]; then
		PS1="[\u@\h \W]#> "
	else
		PS1="[\u@\h \W]\\$> "
	fi
fi
