#chmod 644 /etc/profile.d/ranger.sh
if [ $(ps -p $PPID -o comm=) = "ranger" ]; then
		PS1='[\u@\h \W]\$> '
fi
# \$ - if the effective UID is 0, a #, otherwise a $
# only with single quotes
