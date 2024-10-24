#!/bin/bash
#
# cloud-config.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# nextcloudcmd --user kovach@toxsoft.ru --password xYyeqTqn  /home/ts4-targets/nextcloud https://tsapp.ru/index.php/apps/files/files/1827089?dir=/kovach/products
# nextcloudcmd --user kovach@toxsoft.ru --password xYyeqTqn  /home/ts4-targets/nextcloud https://tsapp.ru/index.php/s/aoFQX9kw5iWNcZa
# nextcloudcmd --user kovach@toxsoft.ru --password xYyeqTqn  /home/ts4-targets/nextcloud https://tsapp.ru/index.php/s/aoFQX9kw5iWNcZa

# source: https://serverfault.com/questions/957153/nextcloud-sync-without-gui
# nextcloudcmd --user kovach@toxsoft.ru --password xYyeqTqn  /home/ts4-targets/nextcloud https://tsapp.ru/remote.php/products
nextcloudcmd --user kovach@toxsoft.ru --password xYyeqTqn --unsyncedfolders nosync_dirs.txt  /home/ts4-targets/nextcloud   https://tsapp.ru
