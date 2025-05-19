#!/bin/bash
#
# mail-config.sh
#
# 1. send mail configuration (postfix). source: https://linuxhint.com/bash_script_send_email/ 
#
# 2. sendemail -f software.builder@toxsoft.org -s smtp.gmail.com:587 -o tls=yes -xu "kovach.mike@gmail.com" -xp "dnhk zuiv ztli ylnm" -t kovach.mike@gmail.com -u "Тема сообщения4" -m "Текст сообщения4" -a attachments files


# disable(1)/enable(0) mail sending (for debug)
MAIL_DISABLE=0
# MAIL_DISABLE=1

if [ "${MAIL_DISABLE}" -eq 0 ] ; then
export MAIL_USERS=\
goga@toxsoft.ru,\
vs@toxsoft.ru,\
egorov.dmitry.alex@gmail.com,\
prokhorov_m@mail.ru,\
tdo@toxsoft.ru,\
kovach@toxsoft.ru,\
kovach.mike@gmail.com
else
export MAIL_USERS=kovach.mike@gmail.com
fi

export MAIL_ADMINS=\
kovach@toxsoft.ru,\
kovach.mike@gmail.com

export MAIL_PRODUCT_USERS=
# export MAIL_PRODUCT_USERS=\
# egorov.dmitry.alex@gmail.com,\
# kovach@toxsoft.ru,\
# kovach.mike@gmail.com

export MAIL_CHARSET=utf-8
export MAIL_SUBJECT="ToxsoftBuilder4. Updated targets: "
export MAIL_MESSAGE="The software builder rebuilt the toxsoft targets and committed the results to github."
export MAIL_MESSAGE_PRODUCT="Здравствуйте!\n\nВ облаке компании ТоксСофт https://tsapp.ru/ обновлены дистрибутивы следующих проектов."
export MAIL_BEST_REGARDS="С уважением, компания ТоксСофт."

export MAIL_SUBJECT_ERROR="SoftwareBuilder. Build ERROR: "
export MAIL_SUBJECT_PRODUCT="=?${MAIL_CHARSET}?Q?tsapp.ru: обновление продуктов компании ТоксСофт.?="
export MAIL_MESSAGE_ERROR="The software builder cannot execute rebuild toxsoft targets [ERROR]."


export MAIL_GIT_SUBJECT_ERROR="SoftwareBuilder. Git ERROR: "
export MAIL_GIT_FETCH_MESSAGE_ERROR="The software builder cannot execute command: git fetch. Repository: "
export MAIL_GIT_DIFF_MESSAGE_ERROR="The software builder cannot execute command: git diff. Repository: "
export MAIL_GIT_MERGE_MESSAGE_ERROR="The software builder cannot execute git merge. Repository: "
export MAIL_GIT_ADD_INDEX_MESSAGE_ERROR="The software builder cannot execute git add index. Repository: "
export MAIL_GIT_COMMIT_MESSAGE_ERROR="The software builder cannot execute git commit. Repository: "
export MAIL_GIT_PUSH_MESSAGE_ERROR="The software builder cannot execute git push. Repository: "
 
export MAIL_SUBJECT_CANCEL="SoftwareBuilder. Build CANCEL: "
export MAIL_MESSAGE_CANCEL="The software builder cannot execute build toxsoft targets [CANCEL].\\n\\nSee the attachments for details:"

SEND_FROM="software.builder@toxsoft.org"
SEND_GMAIL_SERVER="smtp.gmail.com:587"
SEND_GMAIL_USER="kovach.mike@gmail.com"
SEND_GMAIL_USER_PASSWD="'dnhk zuiv ztli ylnm'"

export MAIL_SEND_CMD="sendemail -f ${SEND_FROM} -s ${SEND_GMAIL_SERVER} -o message-charset=${MAIL_CHARSET} -o tls=yes -xu ${SEND_GMAIL_USER} -xp ${SEND_GMAIL_USER_PASSWD}"

# sendemail -f software.builder@toxsoft.org -s smtp.gmail.com:587 -o tls=yes -xu kovach.mike@gmail.com -xp 'dnhk zuiv ztli ylnm' -t kovach.mike@gmail.com -u 'Тема сообщения9' -m 'Текст сообщения9' -a attachments files
# eval "${SEND_CMD} -t ${MAIL_USERS} -u ${MAIL_GIT_SUBJECT_ERROR}${MAIL_USKAT_REPO} -m ${MAIL_GIT_DIFF_MESSAGE_ERROR}${MAIL_USKAT_REPO}"

