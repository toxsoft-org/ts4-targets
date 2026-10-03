#
#!/bin/bash
#


ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include mail support
source ${BUILDER_DIR}/mail-support.sh

echo "${MAIL_SEND_CMD} to ${MAIL_USERS}"
eval "${MAIL_SEND_CMD} -t ${MAIL_USERS} -u test_topic5 -m test_message5"