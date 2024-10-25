#!/bin/bash
#
# cloud-config.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# nextcloud address
NEXTCLOUD_PATH="https://tsapp.ru/remote.php/webdav/kovach/products/"
# nextcloud user login
NEXTCLOUD_LOGIN=kovach@toxsoft.ru
# nextcloud user password
NEXTCLOUD_PASSWORD=xYyeqTqn

REPO_PRODUCTS=\
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_install-linux.gtk.x86_64.zip \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_install-win32.win32.x86_64.zip \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_install-macosx.cocoa.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-win32.win32.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-macosx.cocoa.x86_64.tar.gz \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_skide_install-linux.gtk.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_skide_install-win32.win32.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск ru.toxsoft.mmk.ws.exe.product/target/products/mmk_skide_install-macosx.cocoa.x86_64.tar.gz


# curl https://tsapp.ru/remote.php/webdav/products/ --user kovach@toxsoft.ru:xYyeqTqn --upload-file test2.txt
DEST_PATH=mmk
REPO=cp-mmk
SOURCE_FILE=${GIT_REPOS_HOME}/${REPO}/ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip
curl ${NEXTCLOUD_PATH}/${DEST_PATH}/ --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD} --upload-file ${SOURCE_FILE}

