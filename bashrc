set -o vi
mkcd() {
	(($#)) || return
	mkdir -p ${@: -1}
	cd $_
}
export -f mkcd

#sudo mkdir /usr/pl
#sudo sedfacl "u:$USER:rwx" /usr/pl
#updatedb -l 0 -o /usr/pl/plocate.db -U $HOME
include() {
	if ! (( $# )); then
		updatedb -l 0 -o /usr/pl/plocate.db -U $HOME
	fi
        while (( $# )); do
                file=($(locate -d /usr/pl/plocate.db -er /$1$))
                if [ "${file[1]}" ]; then
                        echo Need a unique file, received: ${file[@]}
                        exit 1
		fi
                if [ "$file" ]; then
                        source "$file"
                else
                        if [ "$flag" ]; then
                                echo No such library $1
                                exit 1
                        fi
                        updatedb -l 0 -o /usr/pl/plocate.db -U $HOME
                        flag=1
                        continue
                fi
                shift
                flag=
        done
}
export -f include

alias trans='trans -s en -t ru -b -speak'
vi() {
	[ $# -eq 0 -a -f Session.vim ] && vim -S || vim -p $@'
}
