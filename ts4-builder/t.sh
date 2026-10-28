#
#!/bin/bash
#


ABSOLUTE_FILENAME=`readlink -e "$0"`
BUILDER_DIR=`dirname ${ABSOLUTE_FILENAME}`

# include mail support
source ${BUILDER_DIR}/mail-support.sh

# ADDR=${MAIL_USERS}
ADDR=kovach@toxsoft.ru

echo "${MAIL_SEND_CMD} to ${ADDR}"
eval "${MAIL_SEND_CMD} -t ${ADDR} -u test_topic8 -m test_message8"