#!/bin/bash

# Функция для обработки каталога
process_directory() {
    local target_dir="$1"
    echo "target_dir = ${target_dir}"
    # Ищем все подкаталоги lib, main, rcp, rap в текущем каталоге и его подкаталогах
    find "$target_dir" -type d \( -name "lib" -o -name "plugins" -o -name "deploy" \) | while read -r target_dir; do

        # Проверяем, есть ли jar-файлы в каталоге
        if find "$target_dir" -maxdepth 1 -name "*.jar" | grep -q .; then
            echo "Удаление jar-файлов из: $target_dir"

            # Удаляем все jar-файлы в текущем целевом каталоге
            find "$target_dir" -maxdepth 1 -name "*.jar" -delete

            # Возвращаемся в родительский каталог целевого
            parent_dir=$(dirname "$target_dir")
            cd "$parent_dir" || exit 1

            # Восстанавливаем каталог из git
            echo "Восстановление каталога: $target_dir"
            git restore --source=HEAD "$(basename "$target_dir")"

            # Возвращаемся в исходный каталог
            cd "$target_dir" || exit 1
        fi
    done
}

process_directory "$(pwd)/../ts4-targets"
process_directory "$(pwd)/../skt-sitrol/zz-releng/targets"


echo "done"


