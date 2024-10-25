#!/bin/bash
#
# cloud-config.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# nextcloud address
NEXTCLOUD_PATH="https://tsapp.ru/remote.php/webdav/kovach/products/"
# nextcloud user login
NEXTCLOUD_LOGIN=kovach@toxsoft.ru
# nextcloud user password
NEXTCLOUD_PASSWORD=xYyeqTqn


# curl https://tsapp.ru/remote.php/webdav/products/ --user kovach@toxsoft.ru:xYyeqTqn --upload-file test2.txt
DEST_PATH=mmk
SOURCE_FILE=/home/ts4-targets/works/git-repos/cp-mmk/ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip
curl ${NEXTCLOUD_PATH}/${DEST_PATH}/ --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD} --upload-file ${SOURCE_FILE}

