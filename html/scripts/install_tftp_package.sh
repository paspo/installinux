#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

if [ ! $# -eq 2 ] ; then
    echo "Usage:"
    echo "   $0 [repo] [package.tar.gz]"
    exit 1
fi

REPODIR=/var/lib/installinux/tftp_repos/$1
REPOFILE=${REPODIR}/packages.list
if [ ! -r ${REPOFILE} ] ; then
    echo "Unkown repo: $1. Maybe you should update repos info."
    exit 1
fi

PACKAGE=$2.tar.gz
PACKAGE_MD5=$(grep -e "^[a-zA-Z0-9]\{32\}\ \ ${PACKAGE}" ${REPOFILE} )
if [[ ${PACKAGE_MD5} = "" ]] ; then
    echo "Unkown package: $2. Maybe you should update repos info."
    exit 1
fi

URL=""
USER=""
PASS=""
. /etc/installinux/tftp_repos/$1

if [[ ${USER} == "" ]] ; then
    AUTH=""
else
    AUTH="--http-user=${USER} --http-password=${PASS}"
fi

TMPDIR=$(mktemp -d)
TMPFILE=${TMPDIR}/${PACKAGE}
wget -q ${AUTH} -O ${TMPFILE} ${URL}/${PACKAGE} || {
    rm ${TMPFILE} 2>/dev/null
    rmdir ${TMPDIR} 2>/dev/null
    echo "Failed to download package: $2. (from: ${URL}/${PACKAGE})"
    exit 1
}

echo "${PACKAGE_MD5}" >${TMPFILE}.md5
cd ${TMPDIR}
md5sum -c --status ${TMPFILE}.md5 || {
    echo "Wrong checksum. Aborting."
    rm ${TMPFILE} ${TMPFILE}.md5 2>/dev/null
    rmdir ${TMPDIR} 2>/dev/null
    exit 1
}

EXTRACT_DIR=${TARGET}

tar xf ${TMPFILE} -C ${EXTRACT_DIR} || {
    echo "Error extracting package. Something is now messed up. Sorry."
    echo "It's not my fault, anyway."
    rm ${TMPFILE} ${TMPFILE}.md5 2>/dev/null
    rmdir ${TMPDIR} 2>/dev/null
    exit 1
}

rm ${TMPFILE} 2>/dev/null
mv ${TMPFILE}.md5 ${REPODIR}
rmdir ${TMPDIR} 2>/dev/null

echo "Package $2 installed."

echo "Please run /usr/share/installinux/html/scripts/update_pxelinux_config.sh"
