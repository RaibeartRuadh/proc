#!/usr/bin/env bash

# Вывод заголовков
printf "%0s %7s %8s %7s %18s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

# 1. Формируем массив данных /proc  из ID
array=($(ls -1 -v /proc/ | grep -E "[0-9]+$"))

for i in ${array[@]}
do

# 2. Проверяем наличие каталога
if [ -r "/proc/$i/" ]
then

# 3. Получаем данные по PID процессов
VPID=$(cat /proc/$i/status | grep "^Pid:" | awk '{ print $2}')

# 4. получаем TTY, убеждаемся, что это не null
if [[ -L /proc/$VPID/fd/0 ]]; then
    VTTY=$(ls -l /proc/$VPID/fd/0 | awk '{print $11}')
     if ! [[ $VTTY =~ $re_socket ]]; then
         VTTY=$(echo $VTTY | cut -c 6-)
         if [[ $VTTY == "null" ]]; then
           VTTY="?"
       fi
   fi
else
        VTTY="?"
fi

# 5. Получасем статус процесса
VSTAT=$(cat /proc/$i/status | grep "^State:" | awk '{ print $2}')

# 6. Получаем время процессора

utime=$(cat /proc/$VPID/stat | awk '{ print $14 }')
stime=$(cat /proc/$VPID/stat | awk '{ print $15 }')
seconds="$(($utime + $stime))"
TTIME=$(printf '%d:%d' $(($seconds%3600/60)) $(($seconds%60)))

# 7. Получаем командну строку
COMMLINE=$(tr -d '\0' < /proc/$i/cmdline)
if [ ! -n "${COMMLINE}" ]
    then
	COMMLINE=$(grep "^Name:" /proc/$i/status | awk '{ print $2 }')
	COMMLINE=[$COMMLINE]
fi

# 8. Выводим значения:
echo -e "$VPID\t$VTTY\t$VSTAT\t$TTIME\t\t$COMMLINE"

fi
done
