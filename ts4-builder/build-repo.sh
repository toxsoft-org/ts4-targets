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

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# include git configuration
source ${BUILDER_DIR}/git-config.sh

# include mail support configuration
source ${BUILDER_DIR}/mail-config.sh

# maven command
MVN_CMD="mvn"

# build mode constants
MODE_NONE="none"
MODE_FORCE="force"

# write to git
writeToGit () {
  ARG_BUILT_DATE=$1
  ARG_REPO=$2
  ARG_OUTPUT_TYPE=$3
  ARG_ARTEFACT_MODULES=$4
  ARG_MAIL_USERS=$5

  echo "git add -A ."
  # GIT ADD, COMMIT & PUSH 
  git add -A .
  GIT_ADD_INDEX_RETCODE=$?
  if [ $GIT_ADD_INDEX_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git add index ERROR for users = ${ARG_MAIL_USERS}, repo = ${ARG_REPO}[${ARG_OUTPUT_TYPE}]"
    # send mail
    eval "${MAIL_SEND_CMD} -t ${ARG_MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO}[${ARG_OUTPUT_TYPE}] -m ${MAIL_GIT_ADD_INDEX_MESSAGE_ERROR}${ARG_REPO}"
  fi

  echo "git commit -a -m "
  if [ ! -z "${ARG_ARTEFACT_MODULES}" ] ; then
    git commit -a -m"autobuild: ${ARG_REPO}, ${ARG_BUILT_DATE}."
  else
    git commit -a -m"autobuild dependence: ${ARG_REPO}."
  fi

  GIT_COMMIT_RETCODE=$?
  if [ $GIT_COMMIT_RETCODE -ne 0 ] ; then
    # git erro
    echo "mail: send git commit ERROR for users = ${ARG_MAIL_USERS}, repo = ${ARG_REPO}[${ARG_OUTPUT_TYPE}]"
    # send mail
    eval "${MAIL_SEND_CMD} -t ${ARG_MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO}[${ARG_OUTPUT_TYPE}] -m ${MAIL_GIT_COMMIT_MESSAGE_ERROR}${ARG_REPO}"
  fi

  echo "git push"
  git push
  GIT_PUSH_RETCODE=$?
  if [ $GIT_PUSH_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git push ERROR for users = ${ARG_MAIL_USERS}, repo = ${ARG_REPO}[${ARG_OUTPUT_TYPE}]"
    # send mail
    eval "${MAIL_SEND_CMD} -t ${ARG_MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO}[${ARG_OUTPUT_TYPE}] -m ${MAIL_GIT_PUSH_MESSAGE_ERROR}${TS4_REPO}"
  fi
}

# build one target 
buildTarget () {
  ARG_BUILT_DATE=$1
  ARG_REPO=$2
  ARG_PREV=$3
  ARG_BRANCH=$4
  ARG_MODE=$5
  ARG_OUTPUT_TYPE=$6

  pushd ../${ARG_REPO}

  ERROR_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_REPO}-${TARGETS_ERRORED_SUFFIX}"
  CANCEL_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_REPO}-${TARGETS_CANCELED_SUFFIX}"
  ERROR_PREV_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_PREV}-${TARGETS_ERRORED_SUFFIX}"
  CANCEL_PREV_TAG_FILE="${TARGETS_TMP_DIR}/${ARG_PREV}-${TARGETS_CANCELED_SUFFIX}"

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

  # check prev repo build flag
  if [ -f ${CANCEL_PREV_TAG_FILE} ] || [ -f ${ERROR_PREV_TAG_FILE} ]; then
    echo
    echo "cancel buildTarget(REPO=${ARG_REPO}, PREV=${ARG_PREV}, BRANCH=${ARG_BRANCH}, MODE=${ARG_MODE})"
    if [ ! -f ${CANCEL_TAG_FILE} ]; then
      # set canceled flag
      echo ${ARG_BUILT_DATE} > ${CANCEL_TAG_FILE}
    fi
    if [ ! -z "${ARTEFACT_MODULES}" ]; then
      return 2
    fi
    return 3
  fi

  echo
  echo "call buildTarget(REPO=${ARG_REPO}, PREV=${ARG_PREV}, BRANCH=${ARG_BRANCH}, MODE=${ARG_MODE})"

  BUILD_RCP_LOG="${TARGETS_TMP_DIR}/${ARG_REPO}-build-rcp.log"
  BUILD_RAP_LOG="${TARGETS_TMP_DIR}/${ARG_REPO}-build-rap.log"

  if [ ! -z "${ARTEFACT_MODULES}" ] || [ "${ARG_MODE}" = "${MODE_FORCE}" ]; then 
    echo "${ARG_BUILT_DATE}: [${ARG_REPO}] changed modules: ${ARTEFACT_MODULES}. build repository [${ARG_REPO}/${ARG_BRANCH}]"
    # TODO: build except common, rcp or rap
#    mvn --fail-at-end -o install -Drcp -pl ${ARTEFACT_MODULES},${TS4_RCP_MODULES}
#    mvn --fail-at-end -o install -Drap -pl ${ARTEFACT_MODULES},${TS4_RAP_MODULES}
    ${MVN_CMD} clean install -Drcp > ${BUILD_RCP_LOG}
    RCP_BUILD_RETCODE=$?
    RCP_RESULTS=$(cat ${BUILD_RCP_LOG})
    echo "${RCP_RESULTS}"
    if [ $RCP_BUILD_RETCODE -ne 0 ] ; then
       # build error
       echo "mail: send build ERROR for users = ${MAIL_USERS}, repo = ${ARG_REPO}"
       # set errored flag
       echo ${ARG_BUILT_DATE} > "${ERROR_TAG_FILE}"
       # send mail
       eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT_ERROR}${ARG_REPO} -m "${MAIL_MESSAGE_ERROR}" -a ${BUILD_RCP_LOG}"
       popd
       return 1
    fi
    printf "${BUILD_RCP_LOG} " >> ${TARGETS_ATTACHMENTS_RESULT_FILE}

    ## ${MVN_CMD} clean install -Drap > ${BUILD_RAP_LOG}
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
       # TODO: mvkd
       writeToGit "${ARG_BUILT_DATE}" ${ARG_REPO} ${TARGETS_OUTPUT_LOCAL} ${ARTEFACT_MODULES} ${MAIL_ADMINS}
       # echo "writeToGit call simulation. REPO = ${ARG_REPO}(local). ARTEFACT_MODULES = ${ARTEFACT_MODULES}"
    fi
    popd

    if [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_GLOBAL}" ] || [ "${ARG_OUTPUT_TYPE}" = "${TARGETS_OUTPUT_ALL}" ]; then
       # TODO: mvkd
       writeToGit "${ARG_BUILT_DATE}" ${ARG_REPO} ${TARGETS_OUTPUT_GLOBAL} ${ARTEFACT_MODULES} ${MAIL_ADMINS}
       # echo "writeToGit call simulation. REPO = ${ARG_REPO}(global). ARTEFACT_MODULES = ${ARTEFACT_MODULES}"
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


########################
# start build
########################
ARG_BUILT_DATE=$1
ARG_REPO=$2
ARG_PREV=$3
ARG_BRANCH=$4
ARG_OUTPUT_TYPE=$5

# define build mode
BUILD_MODE=${MODE_NONE}
if [ -f ${TARGETS_BUILDED_RESULT_FILE} ]; then
   BUILD_MODE=${MODE_FORCE}
fi

echo "build-repo.sh args:"
echo "ARG_BUILT_DATE=${ARG_BUILT_DATE}"
echo "ARG_REPO=${ARG_REPO}"
echo "ARG_PREV=${ARG_PREV}"
echo "ARG_BRANCH=${ARG_BRANCH}"
echo "ARG_OUTPUT_TYPE=${ARG_OUTPUT_TYPE}"
echo "BUILD_MODE=${BUILD_MODE}"

# launch build
buildTarget "${ARG_BUILT_DATE}" ${ARG_REPO} ${ARG_PREV} ${ARG_BRANCH} ${BUILD_MODE} ${ARG_OUTPUT_TYPE}
BUILD_TARGET_RESULT=$?
echo "BUILD_TARGET_RESULT=${BUILD_TARGET_RESULT}"
# handle results
case ${BUILD_TARGET_RESULT} in
   0 ) echo "${ARG_REPO} BUILDED!"; printf "${ARG_REPO} " >> ${TARGETS_BUILDED_RESULT_FILE};; 
   1 ) echo "${ARG_REPO} ERRORED!"; printf "${ARG_REPO} " >> ${TARGETS_ERRORED_RESULT_FILE};; 
   2 ) echo "${ARG_REPO} CANCELED!"; printf "${ARG_REPO} " >> ${TARGETS_CANCELED_RESULT_FILE};; 
   * ) echo "${ARG_REPO} PASSED(nothing to do)"
esac
