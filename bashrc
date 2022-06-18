set -o vi
mkcd() {
	mkdir -p $1
	cd $_
}
declare -xf mkcd

#sudo mkdir /usr/ml
#sudo sedfacl "u:nez:rwx" /usr/ml
include() {
        if [ $1 ]; then
                if file=$(locate -d /usr/mlocate/mlocate.db -qer /$1$ -n 1) ; then
                        source $file
                else
                        updatedb -l 0 -o /usr/mlocate/mlocate.db -U /usr/lbash
                        if file=$(locate -d /usr/mlocate/mlocate.db -qer /$1$ -n 1) ; then
				source $file
			fi
                fi
        else
                updatedb -l 0 -o /usr/mlocate/mlocate.db -U /usr/lbash
        fi
}
declare -xf include

alias trans='trans -s en -t ru -b -speak'
vi() {
	[ $# -eq 0 -a -f Session.vim ] && vim -S || vim -p $@'
}
