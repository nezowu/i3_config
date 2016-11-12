#!/usr/bin/env bash
/usr/bin/sed -ri \
-e 's/Рабочий стол/Desktop/' \
-e 's/Загрузки/Downloads/' \
-e 's/Шаблоны/Templates/' \
-e 's/Общедоступные/Public/' \
-e 's/Документы/Documents/' \
-e 's/Музыка/Music/' \
-e 's/Изображения/Pictures/' \
-e 's/Видео/Video/' \
~/.config/user-dirs.dirs

mv ~/Рабочий\ стол ~/Desktop &> /dev/null
mv ~/Загрузки ~/Downloads &> /dev/null
mv ~/Шаблоны ~/Templates &> /dev/null
mv ~/Общедоступные ~/Public &> /dev/null
mv ~/Документы ~/Documents &> /dev/null
mv ~/Музыка ~/Music &> /dev/null
mv ~/Изображения ~/Pictures &> /dev/null
mv ~/Видео ~/Video &>/dev/null
mkdir -p ~/Pictures/screenshots/windows &> /dev/null
mkdir Projects &> /dev/null
mkdir ~/.config/i3status/
if [ ! -f ~/.config/i3status/config ]; then
	cat /etc/i3status.conf > ~/.config/i3status/config
fi

ssh-agent /bin/bash
cp ~/Dropbox/git/keys/* ~/.ssh/
ssh-add ~/.ssh/id_rsa
