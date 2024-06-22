#!/bin/bash
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
# 5. send mail configuration (postfix). source: https://linuxhint.com/bash_script_send_email/ 
#
# 6. start build4.sh by /etc/crotntab

# mail:
# sendemail -f software.builder@toxsoft.org -s smtp.gmail.com:587 -o tls=yes -xu "kovach.mike@gmail.com" -xp "dnhk zuiv ztli ylnm" -t kovach.mike@gmail.com -u "Тема сообщения4" -m "Текст сообщения4" -a attachments files

TS4_EXTLIBS_REPO=ts4-extlibs
TS4_CORE_REPO=ts4-core
TS4_USKAT_REPO=ts4-uskat
TS4_L2_REPO=ts4-l2
TS4_SKIDE_REPO=ts4-skide

SKF_USERS_REPO=skf-users
SKF_BRIDGE_REPO=skf-bridge
SKF_ALARMS_REPO=skf-alarms
SKF_DQ_REPO=skf-dq
SKF_ONEWS_REPO=skf-onews
SKF_GGPREFS_REPO=skf-ggprefs
SKF_REFBOOKS_REPO=skf-refbooks
SKF_RRI_REPO=skf-rri
SKF_MNEMO_REPO=skf-mnemo
SKF_JOURNALS_REPO=skf-journals
SKF_REPORTS_REPO=skf-reports
SKF_DEVS_REPO=skf-devs
SKF_LEGACY_REPO=skf-legacy

SKT_VETROL_REPO=skt-vetrol


MCC_REPO=mcc
CI_REPO=vetrol-ci
CP_GWP_REPO=cp-gwp
CP_GBH_REPO=cp-gbh


TS4_TARGET=ts4-targets
TS4_TARGET_HOME=/home/ts4-targets/works/git-repos/${TS4_TARGET}

# TS4_MAIL_USERS=\

# TS4_MAIL_USERS=\
# goga@toxsoft.ru,\
# vs@toxsoft.ru,\
# egorov.dmitry.alex@gmail.com,\
# prokhorov_m@mail.ru,\
# tdo@toxsoft.ru,\
# kovach@toxsoft.ru,\
# kovach.mike@gmail.com

# TS4_MAIL_USERS=
TS4_MAIL_USERS=kovach.mike@gmail.com

TS4_MAIL_ADMINS=\
kovach@toxsoft.ru,\
kovach.mike@gmail.com

TS4_MAIL_SUBJECT="SoftwareBuilder. Updated targets: "
TS4_MAIL_MESSAGE="The software builder rebuilds toxsoft targets and commit results to github."
TS4_MAIL_ATTACHMENTS=

TS4_MAIL_SUBJECT_ERROR="SoftwareBuilder. Build ERROR: "
TS4_MAIL_MESSAGE_ERROR="The software builder cannot execute rebuild toxsoft targets [ERROR]."


TS4_GIT_SUBJECT_ERROR="SoftwareBuilder. Git ERROR: "
TS4_GIT_FETCH_MESSAGE_ERROR="The software builder cannot execute command: git fetch. Repository: "
TS4_GIT_DIFF_MESSAGE_ERROR="The software builder cannot execute command: git diff. Repository: "
TS4_GIT_MERGE_MESSAGE_ERROR="The software builder cannot execute git merge. Repository: "
TS4_GIT_ADD_INDEX_MESSAGE_ERROR="The software builder cannot execute git add index. Repository: "
TS4_GIT_COMMIT_MESSAGE_ERROR="The software builder cannot execute git commit. Repository: "
TS4_GIT_PUSH_MESSAGE_ERROR="The software builder cannot execute git push. Repository: "

TS4_MAIL_SUBJECT_CANCEL="SoftwareBuilder. Build CANCEL: "
TS4_MAIL_MESSAGE_CANCEL="The software builder cannot execute build toxsoft targets [CANCEL]."

SEND_MAIL_FROM="software.builder@toxsoft.org"
SEND_MAIL_GMAIL_SERVER="smtp.gmail.com:587"
SEND_MAIL_GMAIL_USER="kovach.mike@gmail.com"
SEND_MAIL_GMAIL_USER_PASSWD="'dnhk zuiv ztli ylnm'"
SEND_MAIL_CMD="sendemail -f ${SEND_MAIL_FROM} -s ${SEND_MAIL_GMAIL_SERVER} -o tls=yes -xu ${SEND_MAIL_GMAIL_USER} -xp ${SEND_MAIL_GMAIL_USER_PASSWD}"

# sendemail -f software.builder@toxsoft.org -s smtp.gmail.com:587 -o tls=yes -xu kovach.mike@gmail.com -xp 'dnhk zuiv ztli ylnm' -t kovach.mike@gmail.com -u 'Тема сообщения9' -m 'Текст сообщения9' -a attachments files
# eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_USKAT_REPO} -m ${TS4_GIT_DIFF_MESSAGE_ERROR}${TS4_USKAT_REPO}"

NONE="none"
FORCE="force"
OUTPUT_LOCAL="local"
OUTPUT_GLOBAL="global"
OUTPUT_ALL="all"

# main branch
GIT_MAIN_BRANCH=main
GIT_MASTER_BRANCH=master

# maven command
MVN_CMD="mvn"

# git results parser
DIFF_PARSER_CMD="java -jar /home/ts4-targets/works/git-repos/ts4-targets/ts4-target-core/lib/org.toxsoft.core.git.parser-lib.jar"

# tepmorary dir
TMP_DIR="/tmp/toxsoft-build-for-${TS4_TARGET}"
# build datetime
BUILT_DATE=$(date)

# ERROR tag-file suffix
ERROR_SUFFIX="error"

# CANCEL tag-file suffix
CANCEL_SUFFIX="cancel"


# write to git
writeToGit () {
  TS4_REPO=$1
  TS4_OUTPUT_TYPE=$2
  echo "git add -A ."
  # GIT ADD, COMMIT & PUSH 
  git add -A .
  GIT_ADD_INDEX_RETCODE=$?
  if [ $GIT_ADD_INDEX_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git add index ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}[${TS4_OUTPUT_TYPE}]"
    # send mail
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO}[${TS4_OUTPUT_TYPE}] -m ${TS4_GIT_ADD_INDEX_MESSAGE_ERROR}${TS4_REPO}"
  fi

  echo "git commit -a -m "
  if [ ! -z "${ARTEFACT_MODULES}" ] ; then
    git commit -a -m"autobuild: ${TS4_REPO}, ${BUILT_DATE}."
  else
    git commit -a -m"autobuild dependence: ${TS4_REPO}."
  fi

  GIT_COMMIT_RETCODE=$?
  if [ $GIT_COMMIT_RETCODE -ne 0 ] ; then
    # git erro
    echo "mail: send git commit ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}[${TS4_OUTPUT_TYPE}]"
    # send mail
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO}[${TS4_OUTPUT_TYPE}] -m ${TS4_GIT_COMMIT_MESSAGE_ERROR}${TS4_REPO}"
  fi

  echo "git push"
  git push
  GIT_PUSH_RETCODE=$?
  if [ $GIT_PUSH_RETCODE -ne 0 ] ; then
    # git error
    echo "mail: send git push ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}[${TS4_OUTPUT_TYPE}]"
    # send mail
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO}[${TS4_OUTPUT_TYPE}] -m ${TS4_GIT_PUSH_MESSAGE_ERROR}${TS4_REPO}"
  fi
}

# build one target 
buildTarget () {
  TS4_REPO=$1
  TS4_PREV=$2
  TS4_BRANCH=$3
  TS4_MODE=$4
  TS4_OUTPUT_TYPE=$5

  pushd ../${TS4_REPO}

  ERROR_TAG_FILE="${TMP_DIR}/${TS4_REPO}-${ERROR_SUFFIX}"
  CANCEL_TAG_FILE="${TMP_DIR}/${TS4_REPO}-${CANCEL_SUFFIX}"

  git fetch
  GIT_FETCH_RETCODE=$?
  if [ $GIT_FETCH_RETCODE -ne 0 ] ; then
     # build error
     echo "mail: send git fetch ERROR for users = ${TS4_MAIL_ADMINS}, repo = ${TS4_REPO}"
     # set errored flag
     # echo ${BUILT_DATE} > ${ERROR_TAG_FILE}
     # set mail
     ### eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_ADMINS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO} -m ${TS4_GIT_FETCH_MESSAGE_ERROR}${TS4_REPO}"


     popd
     return 4
  fi  

  ARTEFACT_MODULES=$(git diff FETCH_HEAD HEAD | ${DIFF_PARSER_CMD})
  GIT_DIFF_RETCODE=$?
  if [ $GIT_DIFF_RETCODE -ne 0 ] ; then
     # build error
     echo "mail: send git diff ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
     # set errored flag
     echo ${BUILT_DATE} > ${ERROR_TAG_FILE}
     # send mail
     eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO} -m ${TS4_GIT_DIFF_MESSAGE_ERROR}${TS4_REPO}"
     popd
     return 1
  fi

  git merge origin/${TS4_BRANCH}
  GIT_MERGE_RETCODE=$?
  if [ $GIT_MERGE_RETCODE -ne 0 ] ; then
     # build error
     echo "mail: send git merge ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
     # set errored flag
     echo ${BUILT_DATE} > ${ERROR_TAG_FILE}
     # send mail
     eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_GIT_SUBJECT_ERROR}${TS4_REPO} -m ${TS4_GIT_MERGE_MESSAGE_ERROR}${TS4_REPO}"
     popd
     return 1
  fi

  # check prev repo build flag
  if [ -f ${CANCEL_TAG_FILE} ] || [ -f ${ERROR_TAG_FILE} ]; then
    echo
    echo "cancel buildTarget(TS4_REPO=${TS4_REPO}, TS4_PREV=${TS4_PREV}, TS4_BRANCH=${TS4_BRANCH}, TS4_MODE=${TS4_MODE})"
    if [ ! -f ${CANCEL_TAG_FILE} ]; then
      # set canceled flag
      echo ${BUILT_DATE} > ${CANCEL_TAG_FILE}
    fi
    if [ ! -z "${ARTEFACT_MODULES}" ]; then
      return 2
    fi
    return 3
  fi

  echo
  echo "call buildTarget(TS4_REPO=${TS4_REPO}, TS4_PREV=${TS4_PREV}, TS4_BRANCH=${TS4_BRANCH}, TS4_MODE=${TS4_MODE})"

  BUILD_RCP_LOG="${TMP_DIR}/${TS4_REPO}-build-rcp.log"
  BUILD_RAP_LOG="${TMP_DIR}/${TS4_REPO}-build-rap.log"

  if [ ! -z "${ARTEFACT_MODULES}" ] || [ "${TS4_MODE}" = "${FORCE}" ]; then 
    echo "${BUILT_DATE}: [${TS4_REPO}] changed modules: ${ARTEFACT_MODULES}. build repository [${TS4_REPO}/${TS4_BRANCH}]"
    # TODO: build except common, rcp or rap
#    mvn --fail-at-end -o install -Drcp -pl ${ARTEFACT_MODULES},${TS4_RCP_MODULES}
#    mvn --fail-at-end -o install -Drap -pl ${ARTEFACT_MODULES},${TS4_RAP_MODULES}
    ${MVN_CMD} clean install -Drcp > ${BUILD_RCP_LOG}
    RCP_BUILD_RETCODE=$?
    RCP_RESULTS=$(cat ${BUILD_RCP_LOG})
    echo "${RCP_RESULTS}"
    if [ $RCP_BUILD_RETCODE -ne 0 ] ; then
       # build error
       echo "mail: send build ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
       # set errored flag
       echo ${BUILT_DATE} > "${TMP_DIR}/${TS4_REPO}-${ERRORED_SUFFIX}"
       # send mail
       eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_MAIL_SUBJECT_ERROR}${TS4_REPO} -m "${TS4_MAIL_MESSAGE_ERROR}" -a ${BUILD_RCP_LOG}"
       popd
       return 1
    fi
    TS4_MAIL_ATTACHMENTS="${TS4_MAIL_ATTACHMENTS} ${BUILD_RCP_LOG}"

    ## ${MVN_CMD} clean install -Drap > ${BUILD_RAP_LOG}
    ## RAP_BUILD_RETCODE=$?
    ## RAP_RESULTS=$(cat ${BUILD_RAP_LOG})
    ## echo "${RAP_RESULTS}"
    ## if [ $RAP_BUILD_RETCODE -ne 0 ] ; then
       # build error
       ## echo "OFF: mail: send build ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
       # set errored flag
       ## echo ${BUILT_DATE} > "${TMP_DIR}/${TS4_REPO}-${ERRORED_SUFFIX}"
       # send mail
       ## eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_MAIL_SUBJECT_ERROR}${TS4_REPO} -m "${TS4_MAIL_MESSAGE_ERROR}" -a ${BUILD_RAP_LOG}"
       ## popd
       ## return 1
    ## fi
    ## TS4_MAIL_ATTACHMENTS="${TS4_MAIL_ATTACHMENTS} ${BUILD_RAP_LOG}"

    # write to git
    if [ "${TS4_OUTPUT_TYPE}" = "${OUTPUT_LOCAL}" ] || [ "${TS4_OUTPUT_TYPE}" = "${OUTPUT_ALL}" ]; then
       writeToGit ${TS4_REPO} ${OUTPUT_LOCAL} 
    fi
    popd

    if [ "${TS4_OUTPUT_TYPE}" = "${OUTPUT_GLOBAL}" ] || [ "${TS4_OUTPUT_TYPE}" = "${OUTPUT_ALL}" ]; then
       writeToGit ${TS4_REPO} ${OUTPUT_GLOBAL} 
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

  echo "${BUILT_DATE}: [${TS4_REPO}/${TS4_BRANCH}] nothing to do"
  popd
  return 3
}

# build all targets
buildAll () {
  BUILD_MODE=${NONE}
  BUILDED_REPOS=
  ERRORED_REPOS=
  CANCELED_REPOS=

  buildTarget ${TS4_EXTLIBS_REPO} "" ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_EXTLIBS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_EXTLIBS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_EXTLIBS_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_CORE_REPO} ${TS4_EXTLIBS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_CORE_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_CORE_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_CORE_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_USKAT_REPO} ${TS4_CORE_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_USKAT_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_USKAT_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_USKAT_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_SKIDE_REPO} ${TS4_USKAT_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_SKIDE_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_SKIDE_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_SKIDE_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_USERS_REPO} ${TS4_SKIDE_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_USERS_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_USERS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_USERS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_BRIDGE_REPO} ${SKF_USERS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_BRIDGE_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_BRIDGE_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_BRIDGE_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_RRI_REPO} ${SKF_BRIDGE_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_RRI_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_RRI_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_RRI_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_DQ_REPO} ${SKF_RRI_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_DQ_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_DQ_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_DQ_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_ONEWS_REPO} ${SKF_DQ_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_ONEWS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_ONEWS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_ONEWS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_GGPREFS_REPO} ${SKF_ONEWS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_GGPREFS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_GGPREFS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_GGPREFS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_ALARMS_REPO} ${SKF_GGPREFS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_ALL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_ALARMS_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_ALARMS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_ALARMS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_REFBOOKS_REPO} ${SKF_ALARMS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_REFBOOKS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_REFBOOKS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_REFBOOKS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_JOURNALS_REPO} ${SKF_REFBOOKS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_JOURNALS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_JOURNALS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_JOURNALS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_REPORTS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_REPORTS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_REPORTS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_MNEMO_REPO} ${SKF_REPORTS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_MNEMO_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_MNEMO_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_MNEMO_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_L2_REPO} ${SKF_MNEMO_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_L2_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_L2_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_L2_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_DEVS_REPO} ${TS4_L2_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_DEVS_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_DEVS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_DEVS_REPO}";;
     * ) 
  esac

  buildTarget ${SKF_LEGACY_REPO} ${SKF_DEVS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKF_LEGACY_REPO}";BUILD_MODE="${FORCE}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKF_LEGACY_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKF_LEGACY_REPO}";;
     * ) 
  esac


  buildTarget ${SKT_VETROL_REPO} ${SKF_LEGACY_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SKT_VETROL_REPO}";BUILD_MODE="${FORCE}";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SKT_VETROL_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SKT_VETROL_REPO}";;
     * ) 
  esac

#  buildTarget ${TS4_SKIDE_REPO} ${TS4_USKAT_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_SKIDE_REPO}";BUILD_MODE="${FORCE}";; 
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_SKIDE_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_SKIDE_REPO}";;
#     * ) 
#  esac

#  buildTarget ${TS4_SITROL_REPO} ${TS4_LEGACY_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_GLOBAL}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_SITROL_REPO}";BUILD_MODE="${FORCE}";; 
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_SITROL_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_SITROL_REPO}";;
#     * ) 
#  esac

  echo "BUILDED_REPOS = ${BUILDED_REPOS}"
  echo "ERRORED_REPOS = ${ERRORED_REPOS}"
  echo "CANCELED_REPOS = ${CANCELED_REPOS}"

  if [ ! -z "${ERRORED_REPOS}" ]; then 
    return 1;
  fi

  if [ ! -z "${CANCELED_REPOS}" ]; then
    echo "mail: send build CANCEL for users = ${TS4_MAIL_USERS}, repo = ${CANCELED_REPOS}"
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_MAIL_SUBJECT_CANCEL}${CANCELED_REPOS} -m ${TS4_MAIL_MESSAGE_CANCEL}${CANCELED_REPOS}"
    return 2;
  fi

  # build project products
  buildTarget ${MCC_REPO} ${TS4_L2_REPO} ${GIT_MASTER_BRANCH} ${BUILD_MODE} ${OUTPUT_LOCAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${MCC_REPO}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${MCC_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${MCC_REPO}";;
     * ) 
  esac

  buildTarget ${CI_REPO} ${TS4_L2_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_LOCAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${CI_REPO}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${CI_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${CI_REPO}";;
     * ) 
  esac

  buildTarget ${CP_GWP_REPO} ${TS4_L2_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_LOCAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${CP_GWP_REPO}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${CP_GWP_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${CP_GWP_REPO}";;
     * ) 
  esac

  buildTarget ${CP_GBH_REPO} ${TS4_L2_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} ${OUTPUT_LOCAL}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${CP_GBH_REPO}";;
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${CP_GBH_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${CP_GBH_REPO}";;
     * ) 
  esac

  echo "BUILDED_REPOS = ${BUILDED_REPOS}"
  echo "ERRORED_REPOS = ${ERRORED_REPOS}"
  echo "CANCELED_REPOS = ${CANCELED_REPOS}"

  if [ ! -z "${ERRORED_REPOS}" ]; then 
    return 1;
  fi

  if [ ! -z "${CANCELED_REPOS}" ]; then 
    echo "mail: send build CANCEL for users = ${TS4_MAIL_USERS}, repo = ${CANCELED_REPOS}"
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_MAIL_SUBJECT_CANCEL}${CANCELED_REPOS} -m ${TS4_MAIL_MESSAGE_CANCEL}${CANCELED_REPOS}"
    return 2;
  fi

  if [ -z "${BUILDED_REPOS}" ]; then
    echo "mail: nothing to do"
  else
    echo "mail: send for users: ${TS4_MAIL_USERS}"
    eval "${SEND_MAIL_CMD} -t ${TS4_MAIL_USERS} -u ${TS4_MAIL_SUBJECT}${BUILDED_REPOS} -m ${TS4_MAIL_MESSAGE} -a ${TS4_MAIL_ATTACHMENTS}"
  fi
}

# if need create tmp dir 
if ! [ -d ${TMP_DIR} ]; then
   mkdir --verbose ${TMP_DIR}
fi

# start build script
(

  flock -n 9 || exit 1
  
  echo "${BUILT_DATE}: ------------------------------------------------------------------------------ "
  echo "start build from: '${TS4_TARGET_HOME}'"

  pushd ${TS4_TARGET_HOME}

  git pull

  buildAll

  popd
  echo "${BUILT_DATE}: ============================================================================== $(date)"
  
) 9>${TMP_DIR}/ts4-targets-build.lock


if [ $? -eq 1 ]; then
   echo "${BUILT_DATE}: script $0 is already running: exiting"
   echo "${BUILT_DATE}: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
fi
