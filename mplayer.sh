#!/bin/bash
#***************************************************************************
#*   Copyright (C) 2008, Konishchev Dmitry                                 *
#*   http://konishchevdmitry.blogspot.com/                                 *
#*                                                                         *
#*   Project homepage:                                                     *
#*   http://sourceforge.net/projects/mplayerext/                           *
#*                                                                         *
#*   This program is free software; you can redistribute it and/or modify  *
#*   it under the terms of the GNU General Public License as published by  *
#*   the Free Software Foundation; either version 3 of the License, or     *
#*   (at your option) any later version.                                   *
#*                                                                         *
#*   This program is distributed in the hope that it will be useful,       *
#*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#*   GNU General Public License for more details.                          *
#**************************************************************************/

# mplayer.ext - скрипт-оболочка для mplayer.
# 
# Предназначен для продолжения прослушивания/просмотра аудио и видео
# файлов с той позиции, на которой просмотр/прослушивание завершился в
# прошлый раз при закрытии mplayer'a.
# 
# Использование:
# Если вы хотите пользоваться возможностями скрипта, вам необходимо
# всегда, когда вы хотите проиграть аудио/видео файл, вызывать этот скрипт
# вместо mplayer'a.
# 
# Как работает скрипт:
# Если завершение работы mplayer'a происходит во время просмотра фильма,
# то в файл, путь к которому задан переменной $resume_info_file, заносится
# информация о времени, на котором произошло прерывание просмотра. Время
# привязывается к имени файла (имени, а не пути!), таким образом, если файл
# будет перемещен в другую дирректорию, то скрипт все равно его "узнает".
# В следующий раз, когда пользователь запросит проигрывание этого фильма,
# скрипт просмотрит файл, заданный переменной $resume_info_file и
# продолжит воспроизведение фильма с того момента, на котором завершилось
# воспроизведение в прошлый раз.
# 
# Максимальное количество файлов, информация о которых может храниться в
# $resume_info_file задается переменной $max_resume_info_length.
# 
# Ограничения скрипта:
# * Скрипт не обрабатывает файлы DVD вида VTS_*_*.VOB, т. к. mplayer не
#   позволяет начинать воспроизведение таких файлов с произвольного места.
# * Т. к. mplayer позволяет начинать воспроизведение фильма только с
#   ключевого кадра, то, если воспроизведение фильма в прошлый раз
#   прервалось не на ключевом кадре, при попытке воспроизвести фильм с
#   того же места произойдет перемотка вперед до следующего ключевого
#   кадра, т. е. часть фильма останется непросмотренной. В связи с этим
#   скрипт производит "отматывание" на $keyint секунд назад (по умолчанию
#   - 10), т. к., при кодировании большинства MPEG-4 файлов данная
#   величина используется в качестве максимального расстояния между
#   ключевыми кадрами. Если в ваших видеофайлах интервал между ключевыми
#   кадрами больше этого значения, то измените значение переменной $keyint.  


# Настройки -->
# Максимальный интервал между ключевыми кадрами
keyint=10

# Файл, в котором будет храниться информация о недосмотренных файлах
resume_info_file=~/.mplayer/resume_info

# Максимальное количесво файлов, информация о которых будет храниться в $resume_info_file
max_resume_info_length=100
# Настройки <--


mplayer_ext_echo()
{
echo "mplayer.ext: $@"
}


mplayer_ext_warning()
{
mplayer_ext_echo "$@" >&2
}


cleanup()
{
rm -f $tmp_file
}


die()
{
mplayer_ext_warning "$@"
cleanup
exit 1
}


# Возвращает идентификатор видео по имени файла
get_video_name_by_file_name()
{
local video_name=$(basename "$1")

if [[ "$video_name" == "" ]]
then
return 1
fi

# Не обрабатываем файлы DVD, т. к. в них невозможно осуществлять воспроизведение
# с произвольного места
if echo -n "$video_name" | egrep -i '^vts_[[:digit:]]+_[[:digit:]]+.vob$' > /dev/null
then
return 1
fi

echo -n "$video_name"
}


# Если $2 == 0, то файл помечается как просмотренный
set_resume_pos()
{
declare -a resume_info_array
local resume_info resume_info_time resume_info_time i

# Устанавливаем разделитель слов равным \n
local IFS=$'\n'

i=0
for resume_info in `cat "$resume_info_file" | tail --lines $((max_resume_info_length - 1))`
do
resume_info_time=`echo -n "$resume_info" | egrep '^.+:[[:digit:]]+$' | sed -r 's/^.+://' | egrep '^[[:digit:]]+$'`
resume_info_name=`echo -n "$resume_info" | sed "s/:${resume_info_time}\$//"`

# Пропускаем неверно сформированные записи
if [[ "$resume_info_time" == "" || "$resume_info_name" == "" ]]
then
mplayer_ext_warning "Bad resume info string: '$resume_info'."
continue
fi

# Если это тот файл, который мы ищем
if [[ "$resume_info_name" == "$1" ]]
then
# Пропускаем старую запись
continue
# Остальные файлы - оставляем без изменений
else
resume_info_array[$((i++))]="$resume_info"
fi
done

# Если видео не досмотрели до конца
if [[ "$2" != "0" ]]
then
mplayer_ext_echo "Writing resume time information: '$1': $2."
resume_info_array[$i]="$1:$2"
else
mplayer_ext_echo "Writing resume time information: '$1': viewed."
fi

# Заносим изменения в файл
echo "${resume_info_array[*]}" > "$resume_info_file" || die
}


# Получает строку времени, на котором было приостановлено воспроизведение файла.
# Преобразует строки вида:
# A: 308.4 V: 308.4 A-V:  -0.006 ct:  -0.041 7395/7395  4%  0%  5.5% 0 0
# A: 308.4 V: 308.4 A-V:  0.006 ct:  0.041 7395/7395  4%  0%  5.5% 0 0
# A:   2.0 V:   2.0 A-V: -0.006 ct:  0.007  50/ 50  6%  3%  3.9% 0
# A:  87.6 (01:27.5) of 228.0 (03:48.0)  4.4%
# V:   1.8  45/ 45 15%  3%  0.0% 0 0
# в строку вида:
# [AV]:308
# в зависимости от наличия в файле аудио/видео дорожек
get_cur_pos_info()
{
local pos_info=`cat $tmp_file | head --lines $end_line | tail --lines $((end_line - start_line + 1)) | tr '\33\15' '\n' \
| egrep '^[AV]:[[:space:]]*[[:digit:]]+\.[[:digit:]]+[[:space:]]+' \
| tail --lines 1 \
| sed -r 's/:\s+/:/g' | sed -r 's/\s+/ /g'`

if [[ $pos_info == "" ]]
then
return 1
fi

# Видео со звуком
if echo "$pos_info" | egrep -o '^A:[[:digit:]]+\.[[:digit:]]+ V:[[:digit:]]+\.[[:digit:]]' > /dev/null
then
pos_info=`echo -n "$pos_info" | awk '{ print $2 }' | awk -F '.' '{ print $1 }'`
# Видео без звука
elif echo "$pos_info" | egrep -o '^V:[[:digit:]]+\.[[:digit:]]' > /dev/null
then
pos_info=`echo -n "$pos_info" | awk -F '.' '{ print $1 }'`
# Аудио без видео
elif echo "$pos_info" | egrep -o '^A:[[:digit:]]+\.[[:digit:]]' > /dev/null
then
pos_info=`echo -n "$pos_info" | awk -F '.' '{ print $1 }'`
# Логическая ошибка
else
die "Logical error! :)"
fi

if [[ $pos_info == "" ]]
then
die "Logical error! :)"
fi

echo -n "$pos_info"
}


get_resume_pos()
{
local resume_info resume_info_time resume_info_time

# Устанавливаем разделитель слов равным \n
local IFS=$'\n'

for resume_info in $(< "$resume_info_file")
do
resume_info_time=`echo "$resume_info" | egrep '^.+:[[:digit:]]+$' | sed -r 's/^.+://' | egrep '^[[:digit:]]+$'`
resume_info_name=`echo "$resume_info" | sed "s/:${resume_info_time}\$//"`

# Пропускаем неверно сформированные записи
if [[ "$resume_info_time" == "" || "$resume_info_name" == "" ]]
then
# Предупреждение не выводим, т. к. оно будет выведено при записи в файл.
continue
fi

# Если это тот файл, который мы ищем
if [[ "$resume_info_name" == "$1" ]]
then
echo $resume_info_time
return 0
fi
done

return 1
}


if ! tmp_file=`mktemp`
then
die "Can't create temp file."
fi

if ! which mplayer > /dev/null
then
die "Error! Mplayer not installed."
fi

if [[ ! -e "$resume_info_file" ]]
then
touch "$resume_info_file" || die
fi

# Изменяем агрументы, переданные mplayer'у так, чтобы выбранные видеофайлы
# воспроизводились с того момента, где в прошлый раз было прервано
# воспроизведение.
i=0
for option
do
options[$((i++))]="$option"

if [[ ${option:0:1} != '-' ]]
then
# Если значение параметра похоже на имя файла, то считаем, что
# требуется проиграть этот файл.  Если это просто значение опции, то
# скрипт все равно сработает нормально, разве что добавится лишний
# ключ -ss в случае когда значение параметра будет совпадать с
# именем какого-либо файла в системе.
if [[ -e "$option" ]]
then
if video_name=`get_video_name_by_file_name "$option"`
then
# Если воспроизведение этого видео файла было прервано ранее
if video_resume_pos=`get_resume_pos "$video_name"`
then
options[$((i++))]='-ss'
options[$((i++))]="$video_resume_pos"
fi
fi
fi
fi
done

# Запускаем mplayer с измененными параметрами командной строки
mplayer_ext_echo "Starting mplayer: mplayer ${options[@]}"
mplayer "${options[@]}" | tee "$tmp_file"

# Получаем все файлы, которые проигрывал mplayer -->
files_in_output="`egrep --line-number 'Playing[[:space:]]+.+\.' $tmp_file`"

for line in `seq \`echo "$files_in_output" | wc --lines\``
do
file_in_output=`echo "$files_in_output" | head --lines $line | tail --lines 1`
files_lines[$((line-1))]=`echo "$file_in_output" | awk -F ':' '{ print $1 }'`
files_paths[$((line-1))]=`echo "$file_in_output" | sed -r 's/^[[:digit:]]+:Playing[[:space:]]+//' | sed 's/\.$//g'`
done
# Получаем все файлы, которые проигрывал mplayer <--

# Получаем всю необходимую информацию о каждом проигранном файле -->
for num in `seq 1 ${#files_lines[*]}`
do
i=$((num-1))

start_line=${files_lines[$i]}

# Генерируем имя видео по имени файла
if ! video_name=`get_video_name_by_file_name "${files_paths[$i]}"`
then
mplayer_ext_echo "Skiping file '${files_paths[$i]}'"
continue
fi

# Если файл последний
if [[ $num -eq ${#files_lines[*]} ]]
then
end_line=$((`cat $tmp_file | wc --lines` + 1))

# Получаем строку со временем, на котором остановилось воспроизведение
if ! video_resume_string=`get_cur_pos_info`
then
# Получить строку не удалось - это может произойти по разным причинам,
# например, если не удалось открыть файл.
# Т. к. файл не проигрывался, то не запоминаем его позицию.
mplayer_ext_echo "Skiping file '${files_paths[$i]}'"
continue
fi

# Файл проигрался до конца
if [[ `cat $tmp_file | tail --lines 1` == 'Exiting... (End of file)' ]]
then
set_resume_pos "$video_name" 0
# Проигрывание файла было прервано
else
video_resume_time=`echo -n "$video_resume_string" | awk -F ':' '{ print $2 }'`

# Видео (для аудио отматывать не надо)
if [[ `echo -n "$video_resume_string" | awk -F ':' '{ print $1 }'` == 'V' ]]
then
# "Отматываем" видео назад (приблизительно) до предыдущего ключевого кадра
if [[ $((video_resume_time - keyint)) -lt 0 ]]
then
video_resume_time=0
else
video_resume_time=$((video_resume_time - keyint))
fi
fi

set_resume_pos "$video_name" "$video_resume_time"
fi
# Файл не последний
else
end_line=${files_lines[$((i+1))]}

# Получаем строку со временем, на котором остановилось воспроизведение
if ! video_resume_string=`get_cur_pos_info`
then
# Получить строку не удалось - это может произойти по разным причинам,
# например, если не удалось открыть файл.
# Т. к. файл не проигрывался, то не запоминаем его позицию.
mplayer_ext_echo "Skiping file '${files_names[$i]}'"
continue
fi

set_resume_pos "$video_name" 0
fi
done
# Получаем всю необходимую информацию о каждом проигранном файле <--

cleanup
