#!/bin/bash
#
# build-repo.sh
#
# 1. at home directory should be two files (https://stackoverflow.com/questions/35942754/how-to-save-username-and-password-in-git):
# .gitconfig
#  ---------------------
#  [credential]
#     helper = store
#  ---------------------
# .git-credentials
#  ---------------------
# https://d520b50b3b9db4dc508b84b9ee39601444575c7c:x-oauth-basic@github.com
#  ---------------------
#
# 2 ,call commands for commit:
# git config --global user.email "kovach@toxsoft.ru"
# git config --global user.name "toxsoft build server"
#
# 3. call commands for push:
# git config --global push.default simple
#
# 4. blocking: # The file which represent the lock.
#
# 5. start build4.sh by /etc/crotntab

# disable(1)/enable(0) git writing (for debug)
BUILD_FORCE=0
# BUILD_FORCE=1


ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# include mail support
source ${BUILDER_DIR}/mail-support.sh

# include git support
source ${BUILDER_DIR}/git-support.sh

# include nextcloud support
source ${BUILDER_DIR}/nextcloud-support.sh

# maven command
# MVN_CMD="mvn clean install"
#MVN_CMD="mvn -X -e clean install"
MVN_CMD="mvn -e clean install"
# maven command using takari API (source: http://takari.io/book/30-team-maven.html)
# MVN_CMD="mvn clean -e install -Drcp --builder smart -T8"

# MVN_CMD="mvn -T 4 clean install"
# maven memory limit at a process
# export MAVEN_OPTS="-Xms2048m -Xmx2048m"
# export MAVEN_OPTS="-Xms512m -Xmx4096m" # success 23
# export MAVEN_OPTS="-Xms512m -Xmx32768m"  # success > 20
export MAVEN_OPTS="-Xms512m -Xmx4096m"  # success > 20

# build mode constants
MODE_NONE="none"
MODE_FORCE="force"


#############################################
# check need cancel by depends states
#############################################
needCancelByDepends () {
   ARG_DEPENDS=$1
#   echo "#############################################"
#   echo "build-repo.sh::needCancelByDepends() args:"
#   echo "ARG_DEPENDS=${ARG_DEPENDS}"
   if [ -z "${ARG_DEPENDS}" ]; then
      # depends array is empty - no intersection
      return 0
   fi
   read -a DEPENDS <<< "${ARG_DEPENDS}"
   for item in "${DEPENDS[@]}"; do
      ERROR_DEPEND_TAG_FILE="${TARGETS_TMP_DIR}/${item}-${TARGETS_ERRORED_SUFFIX}"
      CANCEL_DEPEND_TAG_FILE="${TARGETS_TMP_DIR}/${item}-${TARGETS_CANCELED_SUFFIX}"
      if [ -f ${CANCEL_DEPEND_TAG_FILE} ] || [ -f ${ERROR_DEPEND_TAG_FILE} ]; then
         return 1
      fi
   done
   return 0
}

#############################################
# log depends states
#############################################
logDepends () {
   local ARG_LOG_FILE=$1
   local ARG_DEPENDS=$2
#   echo "#############################################"
#   echo "build-repo.sh::log depends states() args:"
#   echo "ARG_LOG_FILE=${ARG_LOG_FILE}"
#   echo "ARG_DEPENDS=${ARG_DEPENDS}"
   if [ -z "${ARG_DEPENDS}" ]; then
      # depends array is empty
      return 0
   fi
   local DEPENDS
   local item
   read -a DEPENDS <<< "${ARG_DEPENDS}"
   for item in "${DEPENDS[@]}"; do
      ERROR_DEPEND_TAG_FILE="${TARGETS_TMP_DIR}/${item}-${TARGETS_ERRORED_SUFFIX}"
      CANCEL_DEPEND_TAG_FILE="${TARGETS_TMP_DIR}/${item}-${TARGETS_CANCELED_SUFFIX}"
      if [ -f ${CANCEL_DEPEND_TAG_FILE} ]; then
         echo "   ${item}: canceled." >> ${BUILD_LOG_FILE}
      fi
      if [  -f ${ERROR_DEPEND_TAG_FILE} ]; then
         echo "   ${item}: errored." >> ${BUILD_LOG_FILE}
      fi
   done
   return 0
}

#############################################
# lookup array's intersection
#############################################
lookupIntersection () {
   local ARG_ARRAY1=$1
   local ARG_ARRAY2=$2
#   echo "#############################################"
#   echo "build-repo.sh::lookupIntersection() args:"
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

#############################################
# build one target 
#############################################
buildTarget () {
   ARG_BUILT_DATE=$1
   ARG_REPO=$2
   ARG_DEPENDS=$3
   ARG_BRANCH=$4
   ARG_MODE=$5
   ARG_OUTPUT_TYPE=$6
   echo "#############################################"
   echo "build-repo.sh::buildTarget() args:"
   echo "ARG_BUILT_DATE=${ARG_BUILT_DATE}"
   echo "ARG_REPO=${ARG_REPO}"
   echo "ARG_DEPENDS=${ARG_DEPENDS}"
   echo "ARG_BRANCH=${ARG_BRANCH}"
   echo "ARG_MODE=${ARG_MODE}"
   echo "ARG_OUTPUT_TYPE=${ARG_OUTPUT_TYPE}"

   pushd ../${ARG_REPO}

   # tag files target repo
   ERROR_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_REPO}-${TARGETS_ERRORED_SUFFIX}"
   CANCEL_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_REPO}-${TARGETS_CANCELED_SUFFIX}"
   # log file
   BUILD_LOG_FILE="${TARGETS_TMP_DIR}/${ARG_REPO}-build.log"

   GIT_FETCH_RESULT=$(git fetch)
   GIT_FETCH_RETCODE=$?
   echo "git fetch result: \"${GIT_FETCH_RESULT}\""
   if [ $GIT_FETCH_RETCODE -ne 0 ] ; then
      # build error
      echo "mail: send git fetch ERROR for users = ${MAIL_ADMINS}, repo = ${ARG_REPO}"
      # set errored flag
      # echo ${ARG_BUILT_DATE} > ${ERROR_TAG_FILE}
      # set mail
      ### eval "${MAIL_SEND_CMD} -t ${MAIL_ADMINS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG__REPO} -m ${MAIL_GIT_FETCH_MESSAGE_ERROR}${ARG__REPO}"
      popd
      return 4
   fi

   ARTEFACT_MODULES=$(git diff FETCH_HEAD HEAD | ${GIT_DIFF_PARSER_CMD})
   GIT_DIFF_RETCODE=$?
   if [ $GIT_DIFF_RETCODE -ne 0 ] ; then
      # build error
      echo "mail: send git diff ERROR for users = ${MAIL_ADMINS}, repo = ${ARG_REPO}"
      # set errored flag
      echo ${ARG_BUILT_DATE} > ${ERROR_TAG_FILE}
      # send mail
      eval "${MAIL_SEND_CMD} -t ${MAIL_ADMINS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO} -m ${MAIL_GIT_DIFF_MESSAGE_ERROR}${ARG_REPO}"
      popd
      return 1
   fi

   GIT_RESET_RESULT=$(git reset --hard origin/${ARG_BRANCH})
   GIT_RESET_RETCODE=$?
   echo "git reset --hard --hard origin/${ARG_BRANCH}) result: \"${GIT_RESET_RESULT}\""

   if [ $GIT_RESET_RETCODE -ne 0 ] ; then
      # build error
      echo "mail: send git merge ERROR for users = ${MAIL_ADMINS}, repo = ${ARG_REPO}"
      # set errored flag
      echo ${ARG_BUILT_DATE} > ${ERROR_TAG_FILE}
      # send mail
      eval "${MAIL_SEND_CMD} -t ${MAIL_ADMINS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO} -m ${MAIL_GIT_MERGE_MESSAGE_ERROR}${ARG_REPO}"
      popd
      return 1
   fi

   # check depends states
   needCancelByDepends "${ARG_DEPENDS}"
   NEED_CANCEL_RETCODE=$?
   # cancel by depends states 
   if [ ${NEED_CANCEL_RETCODE} -ne 0 ]; then
      echo
      echo "cancel buildTarget(REPO=${ARG_REPO}, DEPENDS=\"${ARG_DEPENDS}\", BRANCH=${ARG_BRANCH}, MODE=${ARG_MODE})"
      # if [ ! -f ${CANCEL_TAG_FILE} ] || [ ! -z "${ARTEFACT_MODULES}" ]; then
      if [ ! -f ${CANCEL_TAG_FILE} ] || [ ! -z "${ARTEFACT_MODULES}" ] || [ "${ARG_MODE}" = "${MODE_FORCE}" ] || [ "${BUILD_FORCE}" -eq 1  ]; then
         # set/update canceled flag
         echo "${ARG_BUILT_DATE}" > ${CANCEL_TAG_FILE}
         echo "${ARG_BUILT_DATE}: cancel build ${ARG_REPO} by the states of dependencies: " > ${BUILD_LOG_FILE}
         logDepends ${BUILD_LOG_FILE} "${ARG_DEPENDS}"
         printf "${BUILD_LOG_FILE} " >> ${TARGETS_ATTACHMENTS_RESULT_FILE}
      fi
      if [ ! -z "${ARTEFACT_MODULES}" ] || [ "${ARG_MODE}" = "${MODE_FORCE}" ] || [ "${BUILD_FORCE}" -eq 1  ] || [ -f ${TARGETS_BUILDED_RESULT_FILE} ]; then
         return 2
      fi
      return 3
   fi

   echo
   echo "call buildTarget(REPO=${ARG_REPO}, DEPENDS=\"${ARG_DEPENDS}\", BRANCH=${ARG_BRANCH}, MODE=${ARG_MODE})"

   if [ ! -z "${ARTEFACT_MODULES}" ] || [ "${ARG_MODE}" = "${MODE_FORCE}" ] || [ "${BUILD_FORCE}" -eq 1  ]; then 
     echo "${ARG_BUILT_DATE}: [${ARG_REPO}] changed modules: \"${ARTEFACT_MODULES}\". build repository [${ARG_REPO}/${ARG_BRANCH}]"

     echo "nextcloud cancelSyncQuery ${ARG_REPO}"
     cancelSyncQuery ${ARG_REPO}

     # TODO: build except common, rcp or rap
#    mvn --fail-at-end -o install -Drcp -pl "${ARTEFACT_MODULES}",${TS4_RCP_MODULES}
#    mvn --fail-at-end -o install -Drap -pl "${ARTEFACT_MODULES}",${TS4_RAP_MODULES}
     ${MVN_CMD} -Drcp > ${BUILD_LOG_FILE}
     RCP_BUILD_RETCODE=$?
     RCP_RESULTS=$(cat ${BUILD_LOG_FILE})
     echo "${RCP_RESULTS}"
     if [ $RCP_BUILD_RETCODE -ne 0 ] ; then
        # build error
        echo "mail: send build ERROR for users = ${MAIL_USERS}, repo = ${ARG_REPO}"
        # set errored flag
        echo ${ARG_BUILT_DATE} > "${ERROR_TAG_FILE}"
        # send mail
        eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT_ERROR}${ARG_REPO} -m "${MAIL_MESSAGE_ERROR}" -a ${BUILD_LOG_FILE}"
        popd
        return 1
     fi
     printf "${BUILD_LOG_FILE} " >> ${TARGETS_ATTACHMENTS_RESULT_FILE}

     ## ${MVN_CMD} -Drap > ${BUILD_RAP_LOG}
     ## RAP_BUILD_RETCODE=$?
     ## RAP_RESULTS=$(cat ${BUILD_RAP_LOG})
     ## echo "${RAP_RESULTS}"
     ## if [ $RAP_BUILD_RETCODE -ne 0 ] ; then
        # build error
        ## echo "OFF: mail: send build ERROR for users = ${MAIL_USERS}, repo = ${ARG_REPO}"
        # set errored flag
        ## echo ${ARG_BUILT_DATE} > "${ERROR_TAG_FILE}"
        # send mail
        ## eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT_ERROR}${ARG_REPO} -m "${MAIL_MESSAGE_ERROR}" -a ${BUILD_RAP_LOG}"
        ## popd
        ## return 1
     ## fi
     ## printf "${BUILD_RAP_LOG} " >> ${TARGETS_ATTACHMENTS_RESULT_FILE}

     # write to git
     if [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_LOCAL}" ] || [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_ALL}" ]; then
        writeToGit "${ARG_BUILT_DATE}" ${ARG_REPO} ${TARGETS_OUTPUT_LOCAL} "${ARTEFACT_MODULES}" "${MAIL_ADMINS}"
     fi
     popd

     if [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_GLOBAL}" ] || [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_ALL}" ]; then
        writeToGit "${ARG_BUILT_DATE}" ${ARG_REPO} ${TARGETS_OUTPUT_GLOBAL} "${ARTEFACT_MODULES}" "${MAIL_ADMINS}"
     fi
     # clear errored flag
     if [ -f ${ERROR_TAG_FILE} ]; then
        rm ${ERROR_TAG_FILE}
     fi
     # clear canceled flag
     if [ -f ${CANCEL_TAG_FILE} ]; then
        rm ${CANCEL_TAG_FILE}
     fi

     return 0
   fi

   echo "${ARG_BUILT_DATE}: [${ARG_REPO}/${ARG_BRANCH}] nothing to do"
   popd
   return 3
}



#############################################
# start build
#############################################
ARG_BUILT_DATE=$1
ARG_BRANCH=$2
ARG_OUTPUT_TYPE=$3
ARG_REPO=$4
ARG_DEPENDS=$5

# define build mode by depends
BUILD_MODE=${MODE_NONE}
if [ -f ${TARGETS_BUILDED_RESULT_FILE} ] && [ ! -z "${ARG_DEPENDS}" ]; then
   BUILDED_REPOS=$(<${TARGETS_BUILDED_RESULT_FILE})
   lookupIntersection "${BUILDED_REPOS}" "${ARG_DEPENDS}"
   LOOKUP_RETCODE=$?
   if [ ${LOOKUP_RETCODE} -ne 0 ] ; then
      BUILD_MODE=${MODE_FORCE}
   fi
fi

# echo "#############################################"
# echo "build-repo.sh args:"
# echo "ARG_BUILT_DATE=${ARG_BUILT_DATE}"
# echo "ARG_REPO=${ARG_REPO}"
# echo "ARG_DEPENDS=${ARG_DEPENDS}"
# echo "ARG_BRANCH=${ARG_BRANCH}"
# echo "ARG_OUTPUT_TYPE=${ARG_OUTPUT_TYPE}"
# echo "BUILD_MODE=${BUILD_MODE}"

# launch build
buildTarget ${ARG_BUILT_DATE} ${ARG_REPO} "${ARG_DEPENDS}" ${ARG_BRANCH} ${BUILD_MODE} ${ARG_OUTPUT_TYPE}
BUILD_TARGET_RESULT=$?
echo "BUILD_TARGET_RESULT=${BUILD_TARGET_RESULT}"
# handle results
case ${BUILD_TARGET_RESULT} in
   0 ) echo "${ARG_REPO} BUILDED!"; printf "${ARG_REPO} " >> ${TARGETS_BUILDED_RESULT_FILE};; 
   1 ) echo "${ARG_REPO} ERRORED!"; printf "${ARG_REPO} " >> ${TARGETS_ERRORED_RESULT_FILE};; 
   2 ) echo "${ARG_REPO} CANCELED!"; printf "${ARG_REPO} " >> ${TARGETS_CANCELED_RESULT_FILE};; 
   * ) echo "${ARG_REPO} PASSED(nothing to do)"
esac
