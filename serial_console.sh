#/etc/profile.d/serial_console.sh 
#if [ "$TERM" = vt220 ]; then
    #stty rows 35 cols 127
    stty -F /dev/ttyS0 cols 127 rows 35
#fi
#stty назначает размер именно vt220!
#/etc/default/grub
#GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200"
#GRUB_TERMINAL=serial
#update-grub
