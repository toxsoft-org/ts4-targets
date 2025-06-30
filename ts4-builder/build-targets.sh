#!/bin/bash
#
# build-platform.sh
#

ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include target configuration
source ${BUILDER_DIR}/targets-config.sh

# include git support
source ${BUILDER_DIR}/git-support.sh

# include mail support
source ${BUILDER_DIR}/mail-support.sh

# include nextcloud support
source ${BUILDER_DIR}/nextcloud-support.sh


# concurrent mode
# TS4_CONCURRENT=&

# non-concurrent mode
TS4_CONCURRENT=

# platform repos (core)
TS4_EXTLIBS_REPO=ts4-extlibs
TS4_CORE_REPO=ts4-core
TS4_USKAT_REPO=ts4-uskat
TS4_L2_REPO=ts4-l2
TS4_SKIDE_REPO=ts4-skide

# platform repos (extensions)
SKF_USERS_REPO=skf-users
SKF_BRIDGE_REPO=skf-bridge
SKF_ALARMS_REPO=skf-alarms
SKF_DQ_REPO=skf-dq
SKF_ONEWS_REPO=skf-onews
SKF_GGPREFS_REPO=skf-ggprefs
SKF_REFBOOKS_REPO=skf-refbooks
SKF_RRI_REPO=skf-rri
SKF_SAD_REPO=skf-sad
SKF_MNEMOS_REPO=skf-mnemos
SKF_JOURNALS_REPO=skf-journals
SKF_REPORTS_REPO=skf-reports
SKF_DEVS_REPO=skf-devs
SKF_LEGACY_REPO=skf-legacy
SKF_GENERAL_REPO=skf-general
SKT_VETROL_REPO=skt-vetrol
SKT_SITROL_REPO=skt-sitrol

# projects repos
CP_SITROL_NM_REPO=cp-sitrol-nm
CP_VETROL_BKN_REPO=cp-vetrol-bkn
CP_VAL_REPO=cp-val
CI_REPO=vetrol-ci
CP_MMK_REPO=cp-mmk
CP_GBH_REPO=cp-gbh
CP_GWP_REPO=cp-gwp
MCC_REPO=mcc

# build datetime
BUILT_DATE=$(date '+%Y-%m-%d_%H:%M:%S')

# helper constants for build command
BUILD_MAIN_GLOBAL="${TARGETS_BUILD_REPO_CMD} ${BUILT_DATE} ${GIT_MAIN_BRANCH}  ${TARGETS_OUTPUT_GLOBAL} "
BUILD_MAIN_LOCAL="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MAIN_BRANCH}  ${TARGETS_OUTPUT_LOCAL} "
BUILD_MAIN_ALL="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MAIN_BRANCH}  ${TARGETS_OUTPUT_ALL} "
BUILD_MAIN_NONE="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MAIN_BRANCH}  ${TARGETS_OUTPUT_NONE} "
BUILD_MASTER_GLOBAL="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MASTER_BRANCH}  ${TARGETS_OUTPUT_GLOBAL} "
BUILD_MASTER_LOCAL="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MASTER_BRANCH}  ${TARGETS_OUTPUT_LOCAL} "
BUILD_MASTER_ALL="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MASTER_BRANCH}  ${TARGETS_OUTPUT_ALL} "
BUILD_MASTER_NONE="${TARGETS_BUILD_REPO_CMD}  ${BUILT_DATE}  ${GIT_MASTER_BRANCH}  ${TARGETS_OUTPUT_NONE} "


# build all targets
buildAll () {
   # calc build time elapsed
   SECONDS=0

   ########################
   # clear prev results
   ########################
   if [ -f "${TARGETS_BUILDED_RESULT_FILE}" ]; then
      echo "clean prev results: remove ${TARGETS_BUILDED_RESULT_FILE}"
      rm ${TARGETS_BUILDED_RESULT_FILE}
   fi
   if [ -f "${TARGETS_ERRORED_RESULT_FILE}" ]; then
      echo "clean prev results: remove ${TARGETS_ERRORED_RESULT_FILE}"
      rm ${TARGETS_ERRORED_RESULT_FILE}
   fi
   if [ -f "${TARGETS_CANCELED_RESULT_FILE}" ]; then
      echo "clean prev results: remove ${TARGETS_CANCELED_RESULT_FILE}"
      rm ${TARGETS_CANCELED_RESULT_FILE}
   fi
   if [ -f "${TARGETS_ATTACHMENTS_RESULT_FILE}" ]; then
      echo "clean prev results: remove ${TARGETS_ATTACHMENTS_RESULT_FILE}"
      rm ${TARGETS_ATTACHMENTS_RESULT_FILE}
   fi
   ########################
   # build platform
   ########################
   echo ""
   echo "start ${TARGETS_ID} platform building..."

   ${BUILD_MAIN_GLOBAL}   ${TS4_EXTLIBS_REPO}  ""
   ${BUILD_MAIN_GLOBAL}   ${TS4_CORE_REPO}      ${TS4_EXTLIBS_REPO}
   ${BUILD_MAIN_GLOBAL}   ${TS4_USKAT_REPO}     ${TS4_CORE_REPO}

   ${BUILD_MAIN_GLOBAL}   ${TS4_SKIDE_REPO}    "${TS4_USKAT_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_GLOBAL}   ${SKF_DQ_REPO}       "${TS4_USKAT_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_GLOBAL}   ${SKF_SAD_REPO}      "${TS4_USKAT_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${SKF_LEGACY_REPO}   "${TS4_USKAT_REPO}" ${TS4_CONCURRENT}
   echo "waiting for ${TARGETS_ID} platform building (part 1) to be completed..."
   wait

   ${BUILD_MAIN_GLOBAL}   ${SKF_USERS_REPO}    "${TS4_USKAT_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_GLOBAL}   ${SKF_REFBOOKS_REPO} "${TS4_USKAT_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_GLOBAL}   ${SKF_REPORTS_REPO}  "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_NONE}     ${SKF_JOURNALS_REPO} "${TS4_USKAT_REPO} ${SKF_DQ_REPO}" ${TS4_CONCURRENT}
   echo "waiting for ${TARGETS_ID} platform building (part 2) to be completed..."
   wait

   ${BUILD_MAIN_GLOBAL}   ${SKF_ONEWS_REPO}    "${TS4_USKAT_REPO} ${SKF_USERS_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${SKF_ALARMS_REPO}   "${TS4_USKAT_REPO} ${SKF_REPORTS_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   echo "waiting for ${TARGETS_ID} platform building (part 3) to be completed..."
   wait

   ${BUILD_MAIN_GLOBAL}   ${SKF_RRI_REPO}      "${TS4_USKAT_REPO} ${SKF_ALARMS_REPO} ${TS4_SKIDE_REPO}"
   ${BUILD_MAIN_GLOBAL}   ${TS4_L2_REPO}       "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_RRI_REPO}"

   ${BUILD_MAIN_NONE}     ${SKF_BRIDGE_REPO}   "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${TS4_L2_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_NONE}     ${SKF_MNEMOS_REPO}    "${TS4_USKAT_REPO} ${SKF_REPORTS_REPO} ${SKF_RRI_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}

   echo "waiting for ${TARGETS_ID} platform building (part 4) to be completed..."
   wait

   ${BUILD_MAIN_LOCAL}    ${SKF_DEVS_REPO}     "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_RRI_REPO} ${SKF_REPORTS_REPO} ${SKF_BRIDGE_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${SKF_GENERAL_REPO}  "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_ALARMS_REPO} ${SKF_RRI_REPO} ${SKF_ONEWS_REPO} ${SKF_LEGACY_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${SKT_VETROL_REPO}   "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_ALARMS_REPO} ${SKF_RRI_REPO} ${SKF_ONEWS_REPO} ${SKF_BRIDGE_REPO} ${SKF_LEGACY_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${SKT_SITROL_REPO}   "${TS4_USKAT_REPO} ${SKF_DQ_REPO} ${SKF_ALARMS_REPO} ${SKF_RRI_REPO} ${SKF_ONEWS_REPO} ${SKF_BRIDGE_REPO} ${SKF_LEGACY_REPO} ${TS4_SKIDE_REPO} ${SKF_SAD_REPO}" ${TS4_CONCURRENT}

   echo "waiting for ${TARGETS_ID} platform building (part 5) to be completed..."
   wait

   if [ -f ${TARGETS_BUILDED_RESULT_FILE} ]; then
      BUILDED_REPOS=$(<${TARGETS_BUILDED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_ERRORED_RESULT_FILE} ]; then
      ERRORED_REPOS=$(<${TARGETS_ERRORED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_CANCELED_RESULT_FILE} ]; then
      CANCELED_REPOS=$(<${TARGETS_CANCELED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_ATTACHMENTS_RESULT_FILE} ]; then
      ATTACHMENTS=$(<${TARGETS_ATTACHMENTS_RESULT_FILE})
   fi

   if [ ! -z "${BUILDED_REPOS}" ] && [ -z "${ERRORED_REPOS}" ] && [ -z "${CANCELED_REPOS}" ]; then
       # write result (TARGETS_OUTPUT_GLOBAL) to git
       writeToGit "${BUILT_DATE}" "${BUILDED_REPOS}" ${TARGETS_OUTPUT_GLOBAL} "${BUILDED_REPOS}" "${MAIL_ADMINS}"
   fi

   # calc build time elapsed
   duration=$SECONDS
   PLATFORM_BUILD_TIME="platform = $((duration / 60)) minutes and $((duration % 60)) seconds."
   SECONDS=0

   echo "##############################"
   echo "# platform building results: #"
   echo "##############################"
   echo "BUILDED_REPOS = ${BUILDED_REPOS}"
   echo "ERRORED_REPOS = ${ERRORED_REPOS}"
   echo "CANCELED_REPOS = ${CANCELED_REPOS}"
   echo ${PLATFORM_BUILD_TIME}
   echo ""

   if [ ! -z "${ERRORED_REPOS}" ]; then 
     # error mail has already been sent in the build-repo.sh
     return 1;
   fi

   if [ ! -z "${CANCELED_REPOS}" ]; then
     echo "mail: send build CANCEL for users = ${MAIL_USERS}, repo = ${CANCELED_REPOS}"
     eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT_CANCEL}${CANCELED_REPOS} -m \"${MAIL_MESSAGE_CANCEL}\" -a ${ATTACHMENTS}"
     return 2;
   fi

   ########################
   # build projects
   ########################
   echo "start ${TARGETS_ID} projects building..."
   ${BUILD_MAIN_LOCAL}    ${CP_SITROL_NM_REPO}   "${SKT_SITROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_ALARMS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CP_VETROL_BKN_REPO}  "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_ALARMS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CP_VAL_REPO}         "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_ALARMS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CI_REPO}             "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO} ${SKF_LEGACY_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CP_MMK_REPO}         "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_ALARMS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CP_GBH_REPO}         "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO} ${SKF_LEGACY_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MAIN_LOCAL}    ${CP_GWP_REPO}         "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO} ${SKF_LEGACY_REPO}" ${TS4_CONCURRENT}
   ${BUILD_MASTER_LOCAL}  ${MCC_REPO}            "${SKT_VETROL_REPO} ${SKF_RRI_REPO} ${SKF_REFBOOKS_REPO} ${SKF_REPORTS_REPO} ${SKF_JOURNALS_REPO} ${SKF_MNEMOS_REPO} ${SKF_USERS_REPO} ${SKF_BRIDGE_REPO} ${SKF_DEVS_REPO} ${TS4_SKIDE_REPO} ${SKF_LEGACY_REPO}" ${TS4_CONCURRENT}

   echo "waiting for ${TARGETS_ID} projects building to be completed..."
   wait

   if [ -f ${TARGETS_BUILDED_RESULT_FILE} ]; then
      BUILDED_REPOS=$(<${TARGETS_BUILDED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_ERRORED_RESULT_FILE} ]; then
      ERRORED_REPOS=$(<${TARGETS_ERRORED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_CANCELED_RESULT_FILE} ]; then
      CANCELED_REPOS=$(<${TARGETS_CANCELED_RESULT_FILE})
   fi
   if [ -f ${TARGETS_ATTACHMENTS_RESULT_FILE} ]; then
      ATTACHMENTS=$(<${TARGETS_ATTACHMENTS_RESULT_FILE})
   fi

   # calc build time elapsed
   duration=$SECONDS
   PROJECTS_BUILD_TIME="projects = $((duration / 60)) minutes and $((duration % 60)) seconds."
   SECONDS=0

   echo "##############################"
   echo "# projects building results: #"
   echo "##############################"
   echo "BUILDED_REPOS = ${BUILDED_REPOS}"
   echo "ERRORED_REPOS = ${ERRORED_REPOS}"
   echo "CANCELED_REPOS = ${CANCELED_REPOS}"
   echo ${PROJECTS_BUILD_TIME}
   echo ""

   if [ ! -z "${ERRORED_REPOS}" ]; then 
     # error mail has already been sent in the build-repo.sh
     return 1;
   fi

   if [ ! -z "${CANCELED_REPOS}" ]; then 
     echo "mail: send build CANCEL for users = ${MAIL_USERS}, repo = ${CANCELED_REPOS}"
     eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT_CANCEL}${CANCELED_REPOS} -m \"${MAIL_MESSAGE_CANCEL}\" -a ${ATTACHMENTS}"
     return 2;
   fi

   if [ -z "${BUILDED_REPOS}" ]; then
     echo "mail: nothing to do"
   else
     echo "nextcloud: send query for sync"
     createSyncQuery "${BUILDED_REPOS}"

     echo "mail: send for users: ${MAIL_USERS}"
     MESSAGE="${MAIL_MESSAGE}\n\nBuild Time:\n${PLATFORM_BUILD_TIME}\n${PROJECTS_BUILD_TIME}"
     eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_SUBJECT}${BUILDED_REPOS} -m \"${MESSAGE}\" -a ${ATTACHMENTS}"
   fi
   return 0
}

# if need create tmp dir 
if ! [ -d ${TARGETS_TMP_DIR} ]; then
   mkdir --verbose ${TARGETS_TMP_DIR}
fi

########################
# start build script
########################
(
(
   flock -n 9 || exit 1

   echo "${BUILT_DATE}: ------------------------------------------------------------------------------ "
   echo "start build for: '${TARGETS_HOME}'"

   pushd ${TARGETS_HOME}

   GIT_PULL_RESULT=$(git pull)
   echo "git pull result: \"${GIT_PULL_RESULT}\""

   buildAll

   popd
   echo "${BUILT_DATE}: =================================================== $(date)"

) 9>${TARGETS_TMP_DIR}/${TARGETS_ID}-build.lock


if [ $? -eq 1 ]; then
   echo "${BUILT_DATE}: script $0 is already running: exiting"
   echo "${BUILT_DATE}: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ "
   exit 1
fi
exit 0
 ) >> ${TARGETS_TMP_DIR}/_build.log
# )

if [ $? -eq 1 ]; then
   echo "${BUILT_DATE}: script $0 is already running: exiting"
   exit
fi

if [ -f ${TARGETS_BUILDED_RESULT_FILE} ]; then
   BUILDED_REPOS=$(<${TARGETS_BUILDED_RESULT_FILE})
fi
if [ -f ${TARGETS_ERRORED_RESULT_FILE} ]; then
   ERRORED_REPOS=$(<${TARGETS_ERRORED_RESULT_FILE})
fi
if [ -f ${TARGETS_CANCELED_RESULT_FILE} ]; then
   CANCELED_REPOS=$(<${TARGETS_CANCELED_RESULT_FILE})
fi

if [ ! -z "${ERRORED_REPOS}" ] || [ ! -z "${CANCELED_REPOS}" ]; then
   echo "/////////////////////////////////////////////////////////////////////////////////////////////////////"
   echo "//                                                                                                 //"
   echo "//                                                                                                 //"
   echo "//                                                                                                 //"
   echo "//                                  B U I L D  F A I L E D  !                                      //"
   echo "//                                                                                                 //"
   echo "//                                                                                                 //"
   echo "//                                                                                                 //"
   echo "/////////////////////////////////////////////////////////////////////////////////////////////////////"
   exit
fi

if [ ! -z "${BUILDED_REPOS}" ]; then
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
   echo "***************************     B U I L D   C O M P L I T E D  !     ********************************"
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
   echo "*****************************************************************************************************"
fi
