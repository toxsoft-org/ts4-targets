#!/bin/bash

ARG_CMD=$1

GIT_REPOS_HOME="../"

PLATFORM_REPOS='\
 ts4-targets\
 ts4-extlibs\
 ts4-core\
 ts4-uskat\
 skf-ext\

 ts4-skide\
 skf-dq\
 skf-sad\
 skf-ha\
 skf-legacy\

 skf-users\
 skf-refbooks\
 skf-reports\
 skf-journals\
 skf-onews\
 skf-alarms\
 skf-rri\
 ts4-l2\
 skf-bridge\
 skf-mnemos\
 skf-devs\
 skf-general\
 skt-vetrol\
 skt-sitrol'

# skf-ggprefs\

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
#
# 0. clean
#
if [ "${ARG_CMD}" = "clean" ]; then
   echo "removing local git repository (clean)..."
   rm -rf /.m2
fi


##################################################################################################
#
# 1. install
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`
BUILDER_LAST_DIR=`basename ${BUILDER_DIR}`

pushd ${GIT_REPOS_HOME}

if [ "${ARG_CMD}" = "install" ]; then
  # git is need for sources
  sudo apt install git

  # maven is need for build
  sudo apt install maven

  # ant is need for build
  sudo apt install ant

  # mail is need for notification
  sudo apt install sendemail
  
  # curl is need for nextcloud
  sudo apt-get install curl
fi


##################################################################################################
#
# 2. load ts4 sources
#

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

popd

##################################################################################################
#
# 3. build all
#

mvn clean install -Drcp
