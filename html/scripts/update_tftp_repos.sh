#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

if [ ! -d /etc/installinux/tftp_repos ] ; then
        exit 1
fi

for REPOFILE in $(ls /etc/installinux/tftp_repos/* ) ; do
        URL=""
        USER=""
        PASS=""
        REPOFILENAME=$(basename ${REPOFILE})
        . $REPOFILE
        
        if [[ ${USER} == "" ]] ; then
            AUTH=""
        else
            AUTH="--http-user=${USER} --http-password=${PASS}"
        fi
        
        LOCALREPODIR=/var/lib/installinux/tftp_repos/${REPOFILENAME}
        if [ ! -d ${LOCALREPODIR} ] ; then
            mkdir -p ${LOCALREPODIR}
        fi
       
        LOCAL_MD5=$(cat ${LOCALREPODIR}/packages.list.md5 2>/dev/null )
        REMOTE_MD5=$(wget -q ${AUTH} -O - ${URL}/packages.list.md5 )
        
        if [[ ! ${LOCAL_MD5} = ${REMOTE_MD5} ]] ; then
            echo -n "Updating '${REPOFILENAME}': "
            TMPDIR=$(mktemp -d)
            # TODO: add error handling to wget?
            wget -q ${AUTH} -O ${TMPDIR}/packages.list ${URL}/packages.list 
            echo "${REMOTE_MD5}" > ${TMPDIR}/packages.list.md5
            cd ${TMPDIR}
            md5sum -c --status packages.list.md5 || {
                echo "Wrong checksum. Aborting."
                rm ${LOCALREPODIR}/packages.list ${LOCALREPODIR}/packages.list.md5 ${TMPDIR}/packages.list ${TMPDIR}/packages.list.md5 2>/dev/null
                rmdir ${TMPDIR}
                exit 1
            }
            mv ${TMPDIR}/packages.list ${LOCALREPODIR}/packages.list
            mv ${TMPDIR}/packages.list.md5 ${LOCALREPODIR}/packages.list.md5
            rmdir ${TMPDIR}
            echo " done."
        else
            echo "'${REPOFILENAME}' is already up-to-date."    
        fi
done
