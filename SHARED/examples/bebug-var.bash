#!/bin/bash

# Вывод команд перед их исполнением.
#set -o verbose
#Подобна -v, но выполняет подстановку команд
#set -o xtrace

# Запретить вывод команд перед их исполнением.
#set +o verbose


trap 'echo "VARIABLE-TRACE> $LINENO: \$variable = \"$variable\""' DEBUG
# Выводить значение переменной после исполнения каждой команды.

variable=29

echo "Переменная \"\$variable\" инициализирована числом $variable."

let "variable *= 3"
echo "Значение переменной \"\$variable\" увеличено в 3 раза."

variable=77

echo "QWERTY"

# Конструкция "trap 'commands' DEBUG" может оказаться очень полезной
# при отладке больших и сложных скриптов,
# когда размещение множества инструкций "echo $variable"
# может потребовать достаточно большого времени.

# Спасибо Stephane Chazelas.

exit 0