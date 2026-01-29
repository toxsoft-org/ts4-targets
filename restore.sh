#!/bin/bash

# Сохраняем текущий каталог
current_dir=$(pwd)

# Ищем все подкаталоги lib, main, rcp, rap в текущем каталоге и его подкаталогах
find "$current_dir" -type d \( -name "lib" -o -name "plugins" \) | while read -r target_dir; do

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
        cd "$current_dir" || exit 1
    fi
done

echo "done"


