#!/bin/bash
#
# git-config.sh
#

# disable(1)/enable(0) git writing (for debug)
GIT_WRITE_DISABLE=0
# GIT_WRITE_DISABLE=1


ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# include mail support
source ${BUILDER_DIR}/mail-support.sh

# 2024-10-12 +++mvk: -XX:-UsePerfData (source: https://stackoverflow.com/questions/76327/how-can-i-prevent-java-from-creating-hsperfdata-files)
export GIT_DIFF_PARSER_CMD="java -XX:-UsePerfData -jar /home/ts4-targets/works/git-repos/ts4-targets/ts4-target-core/lib/org.toxsoft.core.git.parser-lib.jar"

# git main branch variants
export GIT_MAIN_BRANCH=main
export GIT_MASTER_BRANCH=master

# write to git
writeToGit () {
  ARG_BUILT_DATE=$1
  ARG_REPO=$2
  ARG_OUTPUT_TYPE=$3
  ARG_ARTEFACT_MODULES=$4
  ARG_MAIL_USERS=$5

  echo "build-repo::writeToGit args:"
  echo "ARG_BUILT_DATE=${ARG_BUILT_DATE}"
  echo "ARG_REPO=${ARG_REPO}"
  echo "ARG_OUTPUT_TYPE=${ARG_OUTPUT_TYPE}"
  echo "ARG_ARTEFACT_MODULES=${ARG_ARTEFACT_MODULES}"
  echo "ARG_MAIL_USERS=${ARG_MAIL_USERS}"

  if [ "${GIT_WRITE_DISABLE}" -ne 0 ] ; then
     echo "git-config.sh::writeToGit(...): reject git write request. GIT_WRITE_DISABLE = ${GIT_WRITE_DISABLE}"
     return 1
  fi

  echo "git add -A ."
  # GIT ADD, COMMIT & PUSH 
  git add -A .
  GIT_ADD_INDEX_RETCODE=$?
  if [ $GIT_ADD_INDEX_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git add index ERROR for users = ${ARG_MAIL_USERS}, repo = ${ARG_REPO}[${ARG_OUTPUT_TYPE}]"
    # send mail
    eval "${MAIL_SEND_CMD} -t ${ARG_MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO}[${ARG_OUTPUT_TYPE}] -m ${MAIL_GIT_ADD_INDEX_MESSAGE_ERROR}${ARG_REPO}"
    return 2
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
    return 3
  fi

  echo "git push"
  git push
  GIT_PUSH_RETCODE=$?
  if [ $GIT_PUSH_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git push ERROR for users = ${ARG_MAIL_USERS}, repo = ${ARG_REPO}[${ARG_OUTPUT_TYPE}]"
    # send mail
    eval "${MAIL_SEND_CMD} -t ${ARG_MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${ARG_REPO}[${ARG_OUTPUT_TYPE}] -m ${MAIL_GIT_PUSH_MESSAGE_ERROR}${TS4_REPO}"
    return 4
  fi
  return 0
}
