#!/bin/bash
#
# target-config.sh
#

# target ID
export TARGETS_ID=ts4-targets

# git-repos dir
export GIT_REPOS_HOME=/home/ts4-targets/works/git-repos

# target home dir
export TARGETS_HOME=${GIT_REPOS_HOME}/${TARGETS_ID}

# target builder dir
export TARGETS_BUILDER_DIR="${TARGETS_HOME}/ts4-builder"

# target tepmorary dir
export TARGETS_TMP_DIR="/tmp/toxsoft-build-for-${TARGETS_ID}"

# build scope constants
export TARGETS_OUTPUT_NONE="none"
export TARGETS_OUTPUT_LOCAL="local"
export TARGETS_OUTPUT_GLOBAL="global"
export TARGETS_OUTPUT_ALL="all"

# BUILDED/ERRORED/CANCELED targets tag-file suffix
export TARGETS_BUILDED_SUFFIX="builded"
export TARGETS_ERRORED_SUFFIX="errored"
export TARGETS_CANCELED_SUFFIX="canceled"
export TARGETS_ATTACHMENTS_SUFFIX="attachments"

# build result files
export TARGETS_BUILDED_RESULT_FILE="${TARGETS_TMP_DIR}/${TARGETS_ID}-${TARGETS_BUILDED_SUFFIX}"
export TARGETS_ERRORED_RESULT_FILE="${TARGETS_TMP_DIR}/${TARGETS_ID}-${TARGETS_ERRORED_SUFFIX}"
export TARGETS_CANCELED_RESULT_FILE="${TARGETS_TMP_DIR}/${TARGETS_ID}-${TARGETS_CANCELED_SUFFIX}"
export TARGETS_ATTACHMENTS_RESULT_FILE="${TARGETS_TMP_DIR}/${TARGETS_ID}-${TARGETS_ATTACHMENTS_SUFFIX}"

# build repo command
export TARGETS_BUILD_REPO_CMD="${TARGETS_BUILDER_DIR}/build-repo.sh"

#############################################
# lookup array's intersection
#############################################
lookupIntersection () {
   local ARG_ARRAY1=$1
   local ARG_ARRAY2=$2
#   echo "#############################################"
#   echo "target-config.sh::lookupIntersection() args:"
#   echo "ARG_ARRAY1=${ARG_ARRAY1}"
#   echo "ARG_ARRAY2=${ARG_ARRAY2}"

   if [ -z "${ARG_ARRAY1}" ] && [ -z "${ARG_ARRAY2}" ]; then
      # one or both array is empty - no intersection
      return 0
   fi
   local ARRAY2
   read -a ARRAY2 <<< "${ARG_ARRAY2}"
   for item in "${ARRAY2[@]}"; do
      if [[ "${ARG_ARRAY1}" == *${item}* ]]; then
         # found intersection
         return 1
      fi
   done
   # no intersection
   return 0
}
