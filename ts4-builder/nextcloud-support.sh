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
   ARG_REPOS=$1

   echo "nextcloud-support::createSyncQuery args:"
   echo "ARG_REPOS=${ARG_REPOS}"

   #  if necessary creates a queries directory
   createIfNeedQueriesDir

   QUERY_DATE=$(date '+%Y-%m-%d_%H:%M:%S')
   QUERY_FILE=${NEXTCLOUD_QUERIES_DIR}/query-${QUERY_DATE}.txt
   printf "${ARG_REPOS}" >> ${QUERY_FILE}

   return 0
}
