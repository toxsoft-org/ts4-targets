#!/bin/bash

PLATFORM_REPOS='\
 ts4-targets\
 ts4-extlibs\
 ts4-core\
 ts4-core\
 ts4-uskat\
 ts4-l2\
 ts4-skide\
 skf-users\
 skf-bridge\
 skf-alarms\
 skf-dq\
 skf-onews\
 skf-ggprefs\
 skf-refbooks\
 skf-rri\
 skf-mnemos\
 skf-journals\
 skf-reports\
 skf-devs\
 skf-legacy\
 skf-general'

SUB_PLATFORM_REPOS='\
 skt-vetrol\
 skt-sitrol'

# projects repos
CP_REPOS='\
 cp-sitrol-nm\
 cp-vetrol-bkn\
 cp-val\
 vetrol-ci\
 cp-mmk\
 cp-gbh\
 cp-gwp\
 mcc'

##################################################################################################
# install
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`
BUILDER_LAST_DIR=`basename ${BUILDER_DIR}`

if [ "${BUILDER_LAST_DIR}" != "git-repos" ]; then
  echo "ОШИБКА: сценарий установки сборки ts4-targets должен быть запущен из каталога git-repos!"
  exit
fi

# mail is need for notification
sudo apt install sendemail

# curl is need for nextcloud
sudo apt-get install curl


read -a PLATFORM_REPOS_ITEMS <<< "${PLATFORM_REPOS}"
for item in "${PLATFORM_REPOS_ITEMS[@]}"; do
  git clone https://github.com/toxsoft-org/${item}
done

read -a SUB_PLATFORM_REPOS_ITEMS <<< "${SUB_PLATFORM_REPOS}"
for item in "${SUB_PLATFORM_REPOS_ITEMS[@]}"; do
  git clone https://github.com/toxsoft/${item}
done

read -a CP_REPOS_ITEMS <<< "${CP_REPOS}"
for item in "${CP_REPOS_ITEMS[@]}"; do
  git clone https://github.com/toxsoft/${item}
done

cd ts4-targets
mvn clean install -Drcp
