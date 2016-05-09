#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

TFTPROOT=${TARGET}/tftp
if [ ! -r ${TFTPROOT}/pxelinux.cfg/default ] ; then
    echo "${TFTPROOT}/pxelinux.cfg/default is not readable."
    exit 1
fi

MAIN_INCLUDE_FILE=${TFTPROOT}/pxelinux.cfg/includes
echo > ${MAIN_INCLUDE_FILE}

for f in ${TFTPROOT}/* ; do
    DIRNAME=$(basename ${f})
    if [ -r ${TFTPROOT}/${DIRNAME}/${DIRNAME}.inc ] ; then
        INCLUDEFILE=$(mktemp)
        for g in ${TFTPROOT}/${DIRNAME}/*.menu ; do
            FILENAME=$(basename ${g})
            if [[ ! ${FILENAME} = "${DIRNAME}.menu" ]] ; then
                echo "include ${DIRNAME}/${FILENAME}" >> ${INCLUDEFILE}
            fi
        done
        render_template ${TFTPROOT}/${DIRNAME}/${DIRNAME}.inc | sed "/## include ##/ {
            r ${INCLUDEFILE}
            d
        }" > ${TFTPROOT}/${DIRNAME}/${DIRNAME}.menu
    fi
    if [ -r ${TFTPROOT}/${DIRNAME}/${DIRNAME}.menu ] ; then
        echo "include ${DIRNAME}/${DIRNAME}.menu" >> ${MAIN_INCLUDE_FILE}
        echo "added ${DIRNAME}/${DIRNAME}.menu"
    fi
done
