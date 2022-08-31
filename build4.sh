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

TS4_EXTLIBS_REPO=ts4-extlibs
TS4_CORE_REPO=ts4-core
TS4_USKAT_REPO=ts4-uskat
TS4_L2_REPO=ts4-l2
TS4_SKIDE_REPO=ts4-skide
TS4_SITROL_REPO=ts4-sitrol
SITROL_TM_REPO=sitrol-tm
SITROL_MM_REPO=sitrol-mm

TS4_TARGET_EXTLIBS=ts4-target-extlibs
TS4_TARGET_CORE=ts4-target-core
TS4_TARGET_USKAT=ts4-target-uskat
TS4_TARGET_L2=ts4-target-l2
TS4_TARGET_SKIDE=ts4-target-skide
TS4_TARGET_SITROL=ts4-target-sitrol

TS4_TARGET_HOME=/home/tsdev4/works/git-repos/ts4-targets

TS4_MAIL_USERS=\
goga@toxsoft.ru,\
vs@toxsoft.ru,\
egorov.dmitry.alex@gmail.com,\
prokhorov_m@mail.ru,\
tdo@toxsoft.ru,\
kovach@toxsoft.ru,\
kovach.mike@gmail.com

# TS4_MAIL_USERS=\
# kovach@toxsoft.ru,\
# kovach.mike@gmail.com

TS4_MAIL_SUBJECT="updated targets: "
TS4_MAIL_MESSAGE="server rebuilds toxsoft targets and commit results to github"
TS4_MAIL_ATTACHMENTS=

TS4_MAIL_SUBJECT_ERROR="build ERROR: "
TS4_MAIL_MESSAGE_ERROR="server can't rebuilds toxsoft targets (ERROR)"

TS4_MAIL_SUBJECT_CANCEL="build CANCEL: "
TS4_MAIL_MESSAGE_CANCEL="server can't rebuilds toxsoft targets (CANCEL)"

# main branch
GIT_MAIN_BRANCH=main
GIT_MASTER_BRANCH=master

# meven command
MVN_CMD="mvn17"

# git results parser
DIFF_PARSER="java -jar /home/tsdev4/works/git-repos/ts4-targets/ts4-target-core/lib/org.toxsoft.core.git.parser-lib.jar"

# build datetime
BUILT_DATE=$(date)

# ERRORED tag-file suffix
ERRORED_SUFFIX="errored"

# CANCELED tag-file suffix
CANCELED_SUFFIX="canceled"

# build one target 
buildTarget () {
  TS4_REPO=$1
  TS4_PREV=$2
  TS4_BRANCH=$3
  TS4_MODE=$4
  
  pushd ../${TS4_REPO}
  
  git fetch
  ARTEFACT_MODULES=$(git diff FETCH_HEAD HEAD | ${DIFF_PARSER})
  git merge origin/${TS4_BRANCH}

  # check prev repo build flag
  if [ -f "/tmp/${TS4_PREV}-${CANCELED_SUFFIX}" ] || [ -f "/tmp/${TS4_PREV}-${ERRORED_SUFFIX}" ]; then
    echo
    echo "cancel buildTarget(TS4_REPO=${TS4_REPO}, TS4_PREV=${TS4_PREV}, TS4_BRANCH=${TS4_BRANCH}, TS4_MODE=${TS4_MODE})"
    if [ ! -f "/tmp/${TS4_REPO}-${CANCELED_SUFFIX}" ]; then
      # set canceled flag
      echo ${BUILT_DATE} > "/tmp/${TS4_REPO}-${CANCELED_SUFFIX}"
    fi
    if [ ! -z "${ARTEFACT_MODULES}" ]; then
      return 2
    fi
    return 3
  fi

  echo
  echo "call buildTarget(TS4_REPO=${TS4_REPO}, TS4_PREV=${TS4_PREV}, TS4_BRANCH=${TS4_BRANCH}, TS4_MODE=${TS4_MODE})"

  if [ ! -z "${ARTEFACT_MODULES}" ] || [ "${TS4_MODE}" = "force" ]; then 
    echo "${BUILT_DATE}: [${TS4_REPO}] changed modules: ${ARTEFACT_MODULES}. build repository [${TS4_REPO}/${TS4_BRANCH}]"
    # TODO: build except common, rcp or rap
#    mvn --fail-at-end -o install -Drcp -pl ${ARTEFACT_MODULES},${TS4_RCP_MODULES}
#    mvn --fail-at-end -o install -Drap -pl ${ARTEFACT_MODULES},${TS4_RAP_MODULES}
    ${MVN_CMD} clean install -Drcp > /tmp/${TS4_REPO}-build-rcp.log
    RCP_BUILD_RETCODE=$?
    RCP_RESULTS=$(cat /tmp/${TS4_REPO}-build-rcp.log)
    echo "${RCP_RESULTS}"
    if [ $RCP_BUILD_RETCODE -ne 0 ] ; then
       # build error
       echo "mail: send build ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
       # set errored flag
       echo ${BUILT_DATE} > "/tmp/${TS4_REPO}-${ERRORED_SUFFIX}"
       # set mail
       mail -s "${TS4_MAIL_SUBJECT_ERROR}${TS4_REPO}" ${TS4_MAIL_USERS} <<< "${TS4_MAIL_MESSAGE_ERROR}${RCP_RESULTS}"
       popd
       return 1
    fi

    ${MVN_CMD} clean install -Drap > /tmp/${TS4_REPO}-build-rap.log
    RAP_BUILD_RETCODE=$?
    RAP_RESULTS=$(cat /tmp/${TS4_REPO}-build-rcp.log)
    echo "${RAP_RESULTS}"
    if [ $RCP_BUILD_RETCODE -ne 0 ] ; then
       # build error
       echo "mail: send build ERROR for users = ${TS4_MAIL_USERS}, repo = ${TS4_REPO}"
       # set errored flag
       echo ${BUILT_DATE} > "/tmp/${TS4_REPO}-${ERRORED_SUFFIX}"
       # set mail
       mail -s "${TS4_MAIL_SUBJECT_ERROR}${TS4_REPO}" ${TS4_MAIL_USERS} <<< "${TS4_MAIL_MESSAGE_ERROR}${RAP_RESULTS}"
       popd
       return 1
    fi  

    # clear errored flag
    rm "/tmp/${TS4_REPO}-${ERRORED_SUFFIX}"
    # clear canceled flag
    rm "/tmp/${TS4_REPO}-${CANCELED_SUFFIX}"

    TS4_MAIL_ATTACHMENTS=$(echo "";echo "";echo "${TS4_REPO}:";echo "";echo "${RCP_RESULTS}";echo "";echo "${RAP_RESULTS}")
    popd
    return 0
  fi

  echo "${BUILT_DATE}: [${TS4_REPO}/${TS4_BRANCH}] nothing to do"
  popd
  return 3
}

# build all targets
buildAll () {
  BUILD_MODE="none"
  BUILDED_REPOS=
  ERRORED_REPOS=
  CANCELED_REPOS=
  
  buildTarget ${TS4_EXTLIBS_REPO} "" ${GIT_MAIN_BRANCH} ${BUILD_MODE}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_EXTLIBS_REPO}";BUILD_MODE="force";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_EXTLIBS_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_EXTLIBS_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_CORE_REPO} ${TS4_EXTLIBS_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE} }
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_CORE_REPO}";BUILD_MODE="force";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_CORE_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_CORE_REPO}";;
     * ) 
  esac

  buildTarget ${TS4_USKAT_REPO} ${TS4_CORE_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE}
  case $? in
     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_USKAT_REPO}";BUILD_MODE="force";; 
     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_USKAT_REPO}";;
     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_USKAT_REPO}";;
     * ) 
  esac

#  buildTarget ${TS4_L2_REPO} ${TS4_USKAT_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_L2_REPO}";BUILD_MODE="force";; 
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_L2_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_L2_REPO}";;
#     * ) 
#  esac

#  buildTarget ${TS4_SKIDE_REPO} ${TS4_USKAT_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_SKIDE_REPO}";BUILD_MODE="force";; 
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${TS4_SKIDE_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${TS4_SKIDE_REPO}";;
#     * ) 
#  esac

#  buildTarget ${TS4_SITROL_REPO} ${TS4_LEGACY_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${TS4_SITROL_REPO}";BUILD_MODE="force";; 
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
    mail -s "${TS4_MAIL_SUBJECT_CANCEL}${CANCELED_REPOS}" ${TS4_MAIL_USERS} <<< "${TS4_MAIL_MESSAGE_CANCEL}${CANCELED_REPOS}"
    return 2;
  fi

  git add -A .

  if [ -z "${BUILDED_REPOS}" ]; then
    git commit -a -m"autobuild ${BUILT_DATE}: build changes"
    git push
  else
    git commit -a -m"autobuild ${BUILT_DATE}: ${BUILDED_REPOS}"
    git push
  fi

  # build project products
#  buildTarget ${SITROL_TM_REPO} ${TS4_SITROL_REPO} ${GIT_MASTER_BRANCH} ${BUILD_MODE}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SITROL_TM_REPO}";;
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SITROL_TM_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SITROL_TM_REPO}";;
#     * ) 
#  esac

#  buildTarget ${SITROL_MM_REPO} ${TS4_SITROL_REPO} ${GIT_MAIN_BRANCH} ${BUILD_MODE}
#  case $? in
#     0 ) BUILDED_REPOS="${BUILDED_REPOS} ${SITROL_MM_REPO}";;
#     1 ) ERRORED_REPOS="${ERRORED_REPOS} ${SITROL_MM_REPO}";;
#     2 ) CANCELED_REPOS="${CANCELED_REPOS} ${SITROL_MM_REPO}";;
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
    mail -s "${TS4_MAIL_SUBJECT_CANCEL}${CANCELED_REPOS}" ${TS4_MAIL_USERS} <<< "${TS4_MAIL_MESSAGE_CANCEL}${CANCELED_REPOS}"
    return 2;
  fi

  if [ -z "${BUILDED_REPOS}" ]; then
    echo "mail: nothing to do"
  else
    echo "mail: send for users: ${TS4_MAIL_USERS}"
    mail -s "${TS4_MAIL_SUBJECT}${BUILDED_REPOS}" ${TS4_MAIL_USERS} <<< "${TS4_MAIL_MESSAGE}${TS4_MAIL_ATTACHMENTS}"
  fi
}

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
  
) 9>/tmp/ts4-targets-build.lock

if [ $? -eq 1 ]; then
   echo "${BUILT_DATE}: script $0 is already running: exiting"
   echo "${BUILT_DATE}: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
fi

