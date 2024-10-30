#!/bin/bash
#
# nextcloud-support.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include nextcloud common support
source ${BUILDER_DIR}/nextcloud-support.sh

# include mail support
source ${BUILDER_DIR}/mail-support.sh


# nextcloud host
NEXTCLOUD_HOST="tsapp.ru"
# nextcloud address
NEXTCLOUD_PATH="https://${NEXTCLOUD_HOST}/remote.php/webdav"
# nextcloud product path
NEXTCLOUD_PRODUCT_PATH="kovach/products"
# nextcloud project path
NEXTCLOUD_HTTPS_PATH="https://${NEXTCLOUD_HOST}/index.php/apps/files/files?dir=/${NEXTCLOUD_PRODUCT_PATH}"
# nextcloud sync path
NEXTCLOUD_SYNC_PATH="${NEXTCLOUD_PATH}/${NEXTCLOUD_PRODUCT_PATH}"
# nextcloud trashbin path
NEXTCLOUD_TRASHBIN_PATH=https://${NEXTCLOUD_HOST}/remote.php/dav/trashbin/kovach/trash

# nextcloud user login
NEXTCLOUD_LOGIN=kovach@toxsoft.ru
# nextcloud user password
NEXTCLOUD_PASSWORD=xYyeqTqn
# nextcloud sync date
NEXTCLOUD_SYNC_DATE=$(date '+%Y-%m-%d_%H:%M:%S')


REPO_PRODUCTS="\
mcc 17023_Москокс АРМ ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-linux.gtk.x86_64.zip \
mcc 17023_Москокс АРМ ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-win32.win32.x86_64.zip \
mcc 17023_Москокс АРМ ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-macosx.cocoa.x86_64.tar.gz \
mcc 17023_Москокс АРМ ru.toxsoft.mcc.ws.exe.product/target/repository \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск АРМ ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-linux.gtk.x86_64.zip \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск АРМ ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-win32.win32.x86_64.zip \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск АРМ ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-macosx.cocoa.x86_64.tar.gz \
vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск АРМ ru.toxsoft.ci.ws.exe.product/target/repository \
cp-val 24015_АСУТП_АКО_ВАЛКОМ АРМ ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-linux.gtk.x86_64.zip \
cp-val 24015_АСУТП_АКО_ВАЛКОМ АРМ ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-win32.win32.x86_64.zip \
cp-val 24015_АСУТП_АКО_ВАЛКОМ АРМ ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-macosx.cocoa.x86_64.tar.gz \
cp-val 24015_АСУТП_АКО_ВАЛКОМ АРМ ru.toxsoft.val.ws.exe.product/target/repository \
cp-val 24015_АСУТП_АКО_ВАЛКОМ SkIDE ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-linux.gtk.x86_64.zip \
cp-val 24015_АСУТП_АКО_ВАЛКОМ SkIDE ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-win32.win32.x86_64.zip \
cp-val 24015_АСУТП_АКО_ВАЛКОМ SkIDE ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-macosx.cocoa.x86_64.tar.gz \
cp-val 24015_АСУТП_АКО_ВАЛКОМ SkIDE ru.toxsoft.val.skide.exe.product/target/repository \
cp-mmk 23014_MMK_Ветрол_Магнитогорск АРМ ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск АРМ ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-win32.win32.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск АРМ ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-macosx.cocoa.x86_64.tar.gz \
cp-mmk 23014_MMK_Ветрол_Магнитогорск АРМ ru.toxsoft.mmk.ws.exe.product/target/repository \
cp-mmk 23014_MMK_Ветрол_Магнитогорск SkIDE ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-linux.gtk.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск SkIDE ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-win32.win32.x86_64.zip \
cp-mmk 23014_MMK_Ветрол_Магнитогорск SkIDE ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-macosx.cocoa.x86_64.tar.gz \
cp-mmk 23014_MMK_Ветрол_Магнитогорск SkIDE ru.toxsoft.mmk.skide.exe.product/target/repository"

# REPO_PRODUCTS="\
# vetrol-ci 21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск АРМ ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-win32.win32.x86_64.zip \
# cp-mmk 23014_MMK_Ветрол_Магнитогорск АРМ ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip"
read -a REPO_PRODUCTS_ARRAY <<< "${REPO_PRODUCTS}"

CURL_CMD="curl --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD}"

HANDLING_REPOS=
HANDLING_APPS=
HANDLING_LOG=

#############################################
# sync path
#############################################
syncPath () {
   # ATTENTION! Recursive function call is used. local vars are not allowed
   # ARG_FROM=$1
   # ARG_TO=$2

   echo "nextcloud-support::syncPath args:"
   echo "ARG_FROM=$1"
   echo "ARG_TO=$2"

   if [[ -f $1 ]]; then
      echo "curl PUT ARG_TO=$2, upload-file=$1"
      ${CURL_CMD} --request PUT $2/ --upload-file $1
      return 0
   fi

   DIR_BASENAME=$(basename $1)
   TO_DIR="$2/${DIR_BASENAME}"
   echo "curl MKCOL TO_DIR=${TO_DIR}"
   ${CURL_CMD} --request MKCOL ${TO_DIR}
   for FILE in $1/*;
   do
      echo "PARENT=$1, CHILD=${FILE}, TO_DIR=${TO_DIR}"
   done
   for FILE in $1/*;
   do
      DIR_BASENAME=$(basename $1)
      TO_DIR="$2/${DIR_BASENAME}"
      syncPath ${FILE} ${TO_DIR}
   done
}

#############################################
# handle sync query
#############################################
handleSyncQuery () {
   ARG_REPOS=$1

   echo "nextcloud-support::handleSyncQuery args:"
   echo "ARG_REPOS=${ARG_REPOS}"

   for (( index = 0; index < ${#REPO_PRODUCTS_ARRAY[@]}; index = index + 4 ))
   do
      PRODUCT_REPO=${REPO_PRODUCTS_ARRAY[index]}
      PRODUCT_PROJECT=${REPO_PRODUCTS_ARRAY[index + 1]}
      PRODUCT_APP=${REPO_PRODUCTS_ARRAY[index + 2]}
      PRODUCT_FILE=${GIT_REPOS_HOME}/${PRODUCT_REPO}/${REPO_PRODUCTS_ARRAY[index + 3]}
      NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}
      NEXTCLOUD_APP_PATH=${NEXTCLOUD_PROJ_PATH}/${PRODUCT_APP}

      if [[ ${ARG_REPOS} == *${PRODUCT_REPO}* ]]; then
         if [[ ${HANDLING_REPOS} != *${PRODUCT_REPO}* ]]; then
            HANDLING_REPOS="${HANDLING_REPOS} ${PRODUCT_REPO}"

            echo "recreate ${NEXTCLOUD_PROJ_PATH} project directory"
            echo "curl DELETE OLD_PROJECT=${NEXTCLOUD_PROJ_PATH}"
            ${CURL_CMD} --request DELETE ${NEXTCLOUD_PROJ_PATH}

            echo "curl MKCOL NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_PROJ_PATH}"
            ${CURL_CMD} --request MKCOL ${NEXTCLOUD_PROJ_PATH}

            HANDLING_LOG="${HANDLING_LOG}\n\nПроект ${PRODUCT_PROJECT}: "
         fi
         if [[ ${HANDLING_APPS} != *${PRODUCT_REPO}/${PRODUCT_APP}* ]]; then
            HANDLING_APPS="${HANDLING_APPS} ${PRODUCT_REPO}/${PRODUCT_APP}"

            echo "curl MKCOL NEXTCLOUD_APP_PATH=${NEXTCLOUD_APP_PATH}"
            ${CURL_CMD} --request MKCOL ${NEXTCLOUD_APP_PATH}
            HANDLING_LOG="${HANDLING_LOG}\n   ${PRODUCT_APP} - ${NEXTCLOUD_HTTPS_PATH}/${PRODUCT_PROJECT}/${PRODUCT_APP}"
            # HANDLING_LOG="${HANDLING_LOG}\n   ${PRODUCT_APP} - [url=${NEXTCLOUD_HTTPS_PATH}/${PRODUCT_PROJECT}/${PRODUCT_APP}]ссылка на продукт в облаке[/url]."
         fi
         echo "**************************************************************"
         echo "HANDLING_APPS=${HANDLING_APPS}"
         echo "**************************************************************"

         syncPath ${PRODUCT_FILE} ${NEXTCLOUD_APP_PATH}

      fi
   done
   return 0
}

#############################################
# handle sync queries
#############################################
handleSyncQueries () {
   echo "handleSyncQueries"
   # calc sync time elapsed
   SECONDS=0

   if [ -z "$( ls -A ${NEXTCLOUD_QUERIES_DIR} )" ]; then
      echo "No sync queries."
      return 1
   fi
   for QUERY_FILE in ${NEXTCLOUD_QUERIES_DIR}/*;
   do
      QUERY_SYNC_REPOS=$(<${QUERY_FILE})
      rm ${QUERY_FILE}
      echo "query sync repo: ${QUERY_SYNC_REPOS}"
      handleSyncQuery "${QUERY_SYNC_REPOS}"
      # one query at a time
      break
   done

   if [ ! -z "${HANDLING_REPOS}" ]; then
      echo "############################# clear trashbin ###############################"
      curl --request DELETE ${NEXTCLOUD_TRASHBIN_PATH} --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD}
   fi

   # calc build time elapsed
   duration=$SECONDS
   SYNC_TIME="sync time = $((duration / 60)) minutes and $((duration % 60)) seconds."

   if [ ! -z "${HANDLING_LOG}" ]; then
        # send mail
        MESSAGE="${MAIL_MESSAGE_PRODUCT}${HANDLING_LOG}\n\n${SYNC_TIME}\n\n${MAIL_BEST_REGARDS}"
        eval "${MAIL_SEND_CMD} -t ${MAIL_PRODUCT_USERS} -u ${MAIL_SUBJECT_PRODUCT} -m \"${MESSAGE}\""
   fi


   return 0
}


#  if necessary creates a queries directory
createIfNeedQueriesDir

#############################################
# start nextcloud sync script
#############################################
(
(
   flock -n 9 || exit 1

   echo "${NEXTCLOUD_SYNC_DATE}: ------------------------------------------------------------------------------ "
   echo "start nextcloud sync for: '${TARGETS_HOME}'"

   pushd ${TARGETS_HOME}

   ###
   # createSyncQuery  "ts4-core ts4-uskat cp-mmk cp-val mcc vetrol-ci"
   # createSyncQuery  "ts4-core ts4-uskat mcc"
   # createSyncQuery  "vetrol-ci"
   # createSyncQuery  "ts4-uskat cp-mmk cp-val mcc cp-mmk vetrol-ci"

   handleSyncQueries

   popd

   echo "${NEXTCLOUD_SYNC_DATE}: ============================================================================== $(date)"

) 9>${TARGETS_TMP_DIR}/${TARGETS_ID}-nextcloud-sync.lock


if [ $? -eq 1 ]; then
   echo "${NEXTCLOUD_SYNC_DATE}: script $0 is already running: exiting"
   echo "${NEXTCLOUD_SYNC_DATE}: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
fi
) >> ${TARGETS_TMP_DIR}/_nextcloud_sync.log



         # echo "sync product: remove  ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}"
         # curl --request "DELETE" ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}/
         # curl -X "DELETE" ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}/
         # echo "sync product: ${PRODUCT_REPO}: ${PRODUCT_PROJECT} => ${PRODUCT_FILE}"
         # curl --request PUT ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}/ --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD} --upload-file ${PRODUCT_FILE}
         # echo "list dir"
         # curl -s ${NEXTCLOUD_SYNC_PATH}/ # | grep -o 'href=".*">' | sed -e "s/href=\"//g" | sed -e 's/">//g' 

         # curl --request DELETE ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}/ --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD} --upload-file ${PRODUCT_FILE}
         # curl --request DELETE ${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}/ --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD} --upload-file ${PRODUCT_FILE}
         # curl --request DELETE ${NEXTCLOUD_TRASHBIN_PATH} --user ${NEXTCLOUD_LOGIN}:${NEXTCLOUD_PASSWORD}
