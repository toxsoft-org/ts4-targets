#!/bin/bash
#
# nextcloud-sync.sh
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
# NEXTCLOUD_PRODUCT_PATH="kovach/products"
NEXTCLOUD_PRODUCT_PATH="Архив/products"
# nextcloud project path
NEXTCLOUD_HTTPS_PATH="https://${NEXTCLOUD_HOST}/index.php/apps/files/files?dir=/${NEXTCLOUD_PRODUCT_PATH}"
# nextcloud sync path
NEXTCLOUD_SYNC_PATH="${NEXTCLOUD_PATH}/${NEXTCLOUD_PRODUCT_PATH}"
# nextcloud uploading path
NEXTCLOUD_UPLOADING_PATH="${NEXTCLOUD_PATH}/${NEXTCLOUD_PRODUCT_PATH}/_uploading"
# nextcloud trashbin path
NEXTCLOUD_TRASHBIN_PATH=https://${NEXTCLOUD_HOST}/remote.php/dav/trashbin/kovach/trash

# nextcloud user login
NEXTCLOUD_LOGIN=kovach@toxsoft.ru
# nextcloud user password
NEXTCLOUD_PASSWORD=xYyeqTqn
# nextcloud sync date
NEXTCLOUD_SYNC_DATE=$(date '+%Y-%m-%d_%H:%M:%S')

# REPO_PRODUCTS="\
# mcc        17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-linux.gtk.x86_64.zip \
# mcc        17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-win32.win32.x86_64.zip \
# mcc        17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-macosx.cocoa.x86_64.tar.gz \
# mcc        17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/repository \
# vetrol-ci  21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-linux.gtk.x86_64.zip \
# vetrol-ci  21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-win32.win32.x86_64.zip \
# vetrol-ci  21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-macosx.cocoa.x86_64.tar.gz \
# vetrol-ci  21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/repository \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-win32.win32.x86_64.zip \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-macosx.cocoa.x86_64.tar.gz \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/repository \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-linux.gtk.x86_64.zip \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-win32.win32.x86_64.zip \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-macosx.cocoa.x86_64.tar.gz \
# cp-mmk     23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/repository \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-linux.gtk.x86_64.zip \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-win32.win32.x86_64.zip \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-macosx.cocoa.x86_64.tar.gz \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/repository \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-linux.gtk.x86_64.zip \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-win32.win32.x86_64.zip \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-macosx.cocoa.x86_64.tar.gz \
# cp-val     24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/repository "

REPO_PRODUCTS="\
cp-vetrol-bkn  24068_BKN_ЦЭНКИ_Байтерек_Байконур       АРМ    ru.toxsoft.bkn.ws.exe/product/target/products/bkn-ws-linux.gtk.x86_64.zip \
cp-vetrol-bkn  24068_BKN_ЦЭНКИ_Байтерек_Байконур       АРМ    ru.toxsoft.bkn.ws.exe/product/target/products/bkn-ws-win32.win32.x86_64.zip \
cp-vetrol-bkn  24068_BKN_ЦЭНКИ_Байтерек_Байконур       SkIDE  ru.toxsoft.bkn.skide.exe/product/target/products/bkn-skide-linux.gtk.x86_64.zip \
cp-vetrol-bkn  24068_BKN_ЦЭНКИ_Байтерек_Байконур       SkIDE  ru.toxsoft.bkn.skide.exe/product/target/products/bkn-skide-win32.win32.x86_64.zip \
cp-val         24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-linux.gtk.x86_64.zip \
cp-val         24015_VAL_АСУТП_АКО_ВАЛКОМ              АРМ    ru.toxsoft.val.ws.exe.product/target/products/val_ws_install-win32.win32.x86_64.zip \
cp-val         24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-linux.gtk.x86_64.zip \
cp-val         24015_VAL_АСУТП_АКО_ВАЛКОМ              SkIDE  ru.toxsoft.val.skide.exe.product/target/products/val_skide_install-win32.win32.x86_64.zip \
vetrol-ci      21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-linux.gtk.x86_64.zip \
vetrol-ci      21016_CI_Ветрол_АСУ_компр_РУСАЛ_Братск  АРМ    ru.toxsoft.ci.ws.exe.product/target/products/ci_ws_exe_product-win32.win32.x86_64.zip \
cp-mmk         23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-linux.gtk.x86_64.zip \
cp-mmk         23014_MMK_Ветрол_Магнитогорск           АРМ    ru.toxsoft.mmk.ws.exe.product/target/products/mmk_ws_install-win32.win32.x86_64.zip \
cp-mmk         23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-linux.gtk.x86_64.zip \
cp-mmk         23014_MMK_Ветрол_Магнитогорск           SkIDE  ru.toxsoft.mmk.skide.exe.product/target/products/mmk_skide_install-win32.win32.x86_64.zip \
mcc            17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-linux.gtk.x86_64.zip \
mcc            17023_MCC_Москокс                       АРМ    ru.toxsoft.mcc.ws.exe.product/target/products/mcc_ws_exe_product-win32.win32.x86_64.zip \
"

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
   local ARG_REPO=$1
   local ARG_FROM=$2
   local ARG_TO=$3

   echo "nextcloud-sync::syncPath args:"
   echo "ARG_REPO=${ARG_REPO}"
   echo "ARG_FROM=${ARG_FROM}"
   echo "ARG_TO=${ARG_TO}"

   hasSyncQueryCancel ${ARG_REPO}
   local CANCEL_RESULT=$?
   if [ ${CANCEL_RESULT} -eq 1 ] ; then
      echo "nextcloud-sync::syncPath: ${ARG_REPO} sync query was cancelled"
      return 1
   fi

   if [[ -f ${ARG_FROM} ]]; then
      echo "curl PUT ARG_TO=${ARG_TO}, upload-file=${ARG_FROM}"
      ${CURL_CMD} --request PUT ${ARG_TO}/ --upload-file ${ARG_FROM}
      return 0
   fi

   local DIR_BASENAME=$(basename ${ARG_FROM})
   local TO_DIR="${ARG_TO}/${DIR_BASENAME}"
   echo "curl MKCOL TO_DIR=${TO_DIR}"
   ${CURL_CMD} --request MKCOL ${TO_DIR}
   # for FILE in ${ARG_FROM}/*;
   # do
   #    echo "PARENT=${ARG_FROM}, CHILD=${FILE}, TO_DIR=${TO_DIR}"
   # done
   for FILE in ${ARG_FROM}/*;
   do
      DIR_BASENAME=$(basename ${ARG_FROM})
      TO_DIR="${ARG_TO}/${DIR_BASENAME}"
      syncPath ${ARG_REPO} ${FILE} ${TO_DIR}
      local SYNC_RESULT=$?
      if [ ${SYNC_RESULT} -eq 1 ] ; then
         echo "nextcloud-sync::syncPath: ${ARG_REPO} sync query was cancelled"
         return 1
      fi
   done
   return 0
}

#############################################
# handle sync query
#############################################
handleSyncQuery () {
   ARG_REPOS=$1

   echo "nextcloud-sync::handleSyncQuery args:"
   echo "ARG_REPOS=${ARG_REPOS}"

   for (( index = 0; index < ${#REPO_PRODUCTS_ARRAY[@]}; index = index + 4 ))
   do
      local PRODUCT_REPO=${REPO_PRODUCTS_ARRAY[index]}
      local PRODUCT_PROJECT=${REPO_PRODUCTS_ARRAY[index + 1]}
      local PRODUCT_APP=${REPO_PRODUCTS_ARRAY[index + 2]}
      local PRODUCT_FILE=${GIT_REPOS_HOME}/${PRODUCT_REPO}/${REPO_PRODUCTS_ARRAY[index + 3]}
      local NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_UPLOADING_PATH}/${PRODUCT_PROJECT}
      local NEXTCLOUD_APP_PATH=${NEXTCLOUD_PROJ_PATH}/${PRODUCT_APP}

      if [[ ${ARG_REPOS} == *${PRODUCT_REPO}* ]]; then
         if [[ ${HANDLING_REPOS} != *${PRODUCT_REPO}* ]]; then
            # a new repo was found. backup project dir, creating new project dir
            HANDLING_REPOS="${HANDLING_REPOS}${PRODUCT_REPO} "

            # echo "backup ${PRODUCT_PROJECT} directory"
            # eval "${CURL_CMD} --request MOVE -H 'Destination: ${NEXTCLOUD_UPLOADING_PATH}/${PRODUCT_PROJECT}' '${NEXTCLOUD_PROJ_PATH}'"

            echo "curl MKCOL NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_PROJ_PATH}"
            ${CURL_CMD} --request MKCOL ${NEXTCLOUD_PROJ_PATH}
         fi
         if [[ ${HANDLING_APPS} != *${PRODUCT_REPO}/${PRODUCT_APP}* ]]; then
            # a new project app was found. creating a new app dir
            HANDLING_APPS="${HANDLING_APPS} ${PRODUCT_REPO}/${PRODUCT_APP}"

            echo "curl MKCOL NEXTCLOUD_APP_PATH=${NEXTCLOUD_APP_PATH}"
            ${CURL_CMD} --request MKCOL ${NEXTCLOUD_APP_PATH}
         fi
         echo "**************************************************************"
         echo "HANDLING_APPS=${HANDLING_APPS}"
         echo "**************************************************************"

         syncPath ${PRODUCT_REPO} ${PRODUCT_FILE} ${NEXTCLOUD_APP_PATH}

      fi
   done
   return 0
}

#############################################
# handle sync queries
#############################################
handleSyncQueries () {
   # calc sync time elapsed
   SECONDS=0

   if [ -z "$( ls -A ${NEXTCLOUD_QUERIES_DIR} )" ]; then
      echo "nextcloud-sync.sh::handleSyncQueries: no sync queries."
      return 1
   fi

   ########################
   # prepare sync operations
   ########################
   if [ -f "${NEXTCLOUD_CANCELS_FILE}" ]; then
      echo "nextcloud-sync.sh::handleSyncQueries: clear prev cancels: remove ${NEXTCLOUD_CANCELS_FILE}"
      rm ${NEXTCLOUD_CANCELS_FILE}
   fi
   echo "nextcloud-sync::handleSyncQueries: creating upload directory: ${NEXTCLOUD_UPLOADING_PATH}."
   ${CURL_CMD} --request MKCOL ${NEXTCLOUD_UPLOADING_PATH}

   ########################
   # handle new queries
   ########################
   for QUERY_FILE in ${NEXTCLOUD_QUERIES_DIR}/*;
   do
      QUERY_SYNC_REPOS=$(<${QUERY_FILE})
      rm ${QUERY_FILE}
      echo "nextcloud-sync.sh::handleSyncQueries: query sync repo: ${QUERY_SYNC_REPOS}"
      handleSyncQuery "${QUERY_SYNC_REPOS}"
      # one query at a time
      break
   done

   ########################
   # handle sync results
   ########################
   if [ ! -z "${HANDLING_REPOS}" ]; then
      local UPLOADED_REPOS=${HANDLING_REPOS}
      echo "############################# clear trashbin. HANDLING_REPOS=${HANDLING_REPOS}, CLEARING_REPOS=${CLEARING_REPOS} ###############################"
      for (( index = 0; index < ${#REPO_PRODUCTS_ARRAY[@]}; index = index + 4 ))
      do
         local PRODUCT_REPO=${REPO_PRODUCTS_ARRAY[index]}
         local PRODUCT_PROJECT=${REPO_PRODUCTS_ARRAY[index + 1]}
         if [[ ${UPLOADED_REPOS} != *${PRODUCT_REPO}* ]]; then
            continue
         fi
         UPLOADED_REPOS=${UPLOADED_REPOS#${PRODUCT_REPO} }

         NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_SYNC_PATH}/${PRODUCT_PROJECT}
         hasSyncQueryCancel ${PRODUCT_REPO}
         local CANCEL_RESULT=$?
         if [ ${CANCEL_RESULT} -eq 1 ] ; then
            echo "nextcloud-sync::handleSyncQueries: ${PRODUCT_PROJECT} uploading was cancelled."
            continue
         fi
         echo "nextcloud-sync::handleSyncQueries: ${PRODUCT_REPO} is uploaded. try remove old version. NEXTCLOUD_PROJ_PATH=${NEXTCLOUD_PROJ_PATH}"
         ${CURL_CMD} --request DELETE ${NEXTCLOUD_PROJ_PATH}

         echo "move new version of ${PRODUCT_PROJECT} to the target directory."
         eval "${CURL_CMD} --request MOVE -H 'Destination: ${NEXTCLOUD_PROJ_PATH}' '${NEXTCLOUD_UPLOADING_PATH}/${PRODUCT_PROJECT}'"

         local LOGGED_REPO_APPS=
         HANDLING_LOG="${HANDLING_LOG}\n\n${PRODUCT_PROJECT}: "
         for (( index2 = 0; index2 < ${#REPO_PRODUCTS_ARRAY[@]}; index2 = index2 + 4 ))
         do
            local PRODUCT_REPO2=${REPO_PRODUCTS_ARRAY[index2]}
            local PRODUCT_PROJECT2=${REPO_PRODUCTS_ARRAY[index2 + 1]}
            local PRODUCT_APP2=${REPO_PRODUCTS_ARRAY[index2 + 2]}
            local PRODUCT_REPO_APP="${PRODUCT_REPO2}/${PRODUCT_APP2}"
            if [[ ${PRODUCT_REPO} == ${PRODUCT_REPO2} ]] && [[ ${LOGGED_REPO_APPS} != *${PRODUCT_REPO_APP}* ]]; then
               LOGGED_REPO_APPS="${LOGGED_REPO_APPS}${PRODUCT_REPO_APP} "
               HANDLING_LOG="${HANDLING_LOG}\n   ${PRODUCT_APP2} - ${NEXTCLOUD_HTTPS_PATH}/${PRODUCT_PROJECT2}/${PRODUCT_APP2}"
            fi
         done
      done
   fi
   echo "nextcloud-sync::handleSyncQueries: deleting upload directory: ${NEXTCLOUD_UPLOADING_PATH}."
   ${CURL_CMD} --request DELETE ${NEXTCLOUD_UPLOADING_PATH}

   echo "nextcloud-sync::handleSyncQueries: clear trash."
   eval "${CURL_CMD} --request DELETE ${NEXTCLOUD_TRASHBIN_PATH}"

   # calc build time elapsed
   duration=$SECONDS
   SYNC_TIME="sync time = $((duration / 60)) minutes and $((duration % 60)) seconds."
   CHARSET_INFO="charset = ${MAIL_CHARSET}."

   if [ ! -z "${HANDLING_LOG}" ]; then
        # send mail
        MESSAGE="${MAIL_MESSAGE_PRODUCT}${HANDLING_LOG}\n\n${SYNC_TIME}\n${CHARSET_INFO}\n\n${MAIL_BEST_REGARDS}"
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
   echo "nextcloud-sync.sh: start nextcloud sync for: '${TARGETS_HOME}'"

   pushd ${TARGETS_HOME} > /dev/null 2>&1

   ###
   # createSyncQuery  "ts4-core ts4-uskat cp-mmk cp-val mcc vetrol-ci"
   # createSyncQuery  "ts4-core ts4-uskat mcc"
   # createSyncQuery  "vetrol-ci"
   # createSyncQuery  "ts4-uskat cp-mmk cp-val mcc cp-mmk vetrol-ci"

   handleSyncQueries

   popd > /dev/null 2>&1

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
