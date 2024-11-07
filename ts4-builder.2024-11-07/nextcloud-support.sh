#!/bin/bash
#
# nextcloud-support.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# nextcloud queries directory
NEXTCLOUD_QUERIES_DIR=${TARGETS_TMP_DIR}/nextcloud-sync-queries

# nexcloud query file name prefix
NEXTCLOUD_QUERY_FILE_PREFIX="query-"

# nextcloud sync cancels  file
NEXTCLOUD_CANCELS_FILE="${TARGETS_TMP_DIR}/nextcloud-sync-cancels"

#############################################
#  if necessary creates a queries directory
#############################################
createIfNeedQueriesDir () {
   # if need create tmp dir 
   if ! [ -d ${TARGETS_TMP_DIR} ]; then
      mkdir --verbose ${TARGETS_TMP_DIR}
   fi
   # if need create cloud queries dir 
   if ! [ -d ${NEXTCLOUD_QUERIES_DIR} ]; then
      mkdir --verbose ${NEXTCLOUD_QUERIES_DIR}
   fi
}

#############################################
#  create query update repo's products on the cloud.
#############################################
createSyncQuery () {
   local ARG_REPOS=$1
   read -a ARG_REPOS_ARRAY <<< "${ARG_REPOS}"
   # echo "nextcloud-support::createSyncQuery args:"
   # echo "ARG_REPOS=${ARG_REPOS}"

   #  if necessary creates a queries directory
   createIfNeedQueriesDir

   if [ -z "$( ls -A ${NEXTCLOUD_QUERIES_DIR} )" ]; then
      # no sync queries
      local QUERY_DATE=$(date '+%Y-%m-%d_%H:%M:%S')
      local QUERY_FILE=${NEXTCLOUD_QUERIES_DIR}/${NEXTCLOUD_QUERY_FILE_PREFIX}${QUERY_DATE}.txt
      printf "${ARG_REPOS}" >> ${QUERY_FILE}
      return 0
   fi
   for QUERY_FILE in ${NEXTCLOUD_QUERIES_DIR}/*;
   do
      local QUERY_REPOS=$(<${QUERY_FILE})
      local QUERY_REPOS_ARRAY
      for item in "${ARG_REPOS_ARRAY[@]}"; do
         if [[ "${QUERY_REPOS}" != *${item}* ]]; then
            printf " ${item}" >> ${QUERY_FILE}
         fi
      done
   done
   return 1
}

#############################################
# test sync query for update repo's products on the cloud.
#############################################
hasSyncQueryCancel () {
   local ARG_REPO=$1
   # echo "nextcloud-support::hasSyncQueryCancel args:"
   # echo "ARG_REPO=${ARG_REPO}"

   #  if necessary creates a queries directory
   createIfNeedQueriesDir

   if [ -f ${NEXTCLOUD_CANCELS_FILE} ]; then
      local CANCEL_REPOS=$(<${NEXTCLOUD_CANCELS_FILE})
      echo "nextcloud-support::hasSyncQueryCancel: CANCEL_REPOS=\'${CANCEL_REPOS}\'"
#         local PRODUCT_REPO=${REPO_PRODUCTS_ARRAY[index]}
#         if [[ ${UPLOADED_REPOS} != *${PRODUCT_REPO}* ]]; then

      if [[ ${CANCEL_REPOS} == *${ARG_REPO}* ]]; then
         # cancel is exist
         return 1
      fi
   fi
   # cancel is not exist
   return 0
}

#############################################
# cancel sync query for update repo's products on the cloud.
#############################################
cancelSyncQuery () {
   local ARG_REPO=$1
   # echo "nextcloud-support::cancelSyncQuery args:"
   # echo "ARG_REPO=${ARG_REPO}"

   # removing repo from all pending queries
   REPLACE=""
   for QUERY_FILE in ${NEXTCLOUD_QUERIES_DIR}/*;
   do
      if [ -f ${QUERY_FILE} ]; then
         sed -i "s/${ARG_REPO} /${REPLACE}/" ${QUERY_FILE}
      fi
   done
   # adding cancel to cancels file
   hasSyncQueryCancel ${ARG_REPO}
   local CANCEL_RESULT=$?
   if [ ${CANCEL_RESULT} -eq 0 ] ; then
      echo "add cancel ${ARG_REPO} to file ${NEXTCLOUD_CANCELS_FILE}"
      printf "${ARG_REPO} " >> ${NEXTCLOUD_CANCELS_FILE}
      return 1
   fi
   return 0
}
