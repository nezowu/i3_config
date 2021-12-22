#/etc/profile.d/serial_console.sh 
if [ "$TERM" = vt220 ]; then
    #stty rows 35 cols 127
    stty -F /dev/ttyS0 cols 127 
    stty -F /dev/ttyS0 rows 35
fi
