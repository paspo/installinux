#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

if [ ! -d /etc/installinux/tftp_repos ] ; then
    mkdir /etc/installinux/tftp_repos
fi

if [[ "$1" = "--json" ]] ; then
    JSON=true
else
    JSON=false
fi

if [[ "${JSON}" = true ]] ; then
    echo -n '{ "repositories": ['
fi

ADD_COMMA_FOR_REPOS=false
for REPODIR in /var/lib/installinux/tftp_repos/* ; do
    if [[ "${JSON}" = true  && "${ADD_COMMA_FOR_REPOS}" = true ]] ; then
        echo -n ', '
    fi
    REPOLIST=${REPODIR}/packages.list
    REPONAME=$(basename $REPODIR)
    if [[ "${JSON}" = false ]] ; then
        echo
        echo "-------------------------------"
        echo "Repository: ${REPONAME}"
        echo "-------------------------------"
    else
        echo -n '{ "name":"'${REPONAME}'", "packages": ['
    fi
    ADD_COMMA_FOR_PACKAGE=false
    while IFS= read -r line || [[ -n "$line" ]] ; do
        if [[ "${JSON}" = true  && "${ADD_COMMA_FOR_PACKAGE}" = true ]] ; then
            echo -n ', '
        fi
        PACKAGE=$(echo "${line}" | sed "s/^[a-zA-Z0-9]\{32\}\ \ //" )
        PACKAGE_NAME=$(echo "${PACKAGE}" | sed "s/\.tar\.gz$//" )
        INSTALLED_MD5_FILE=${REPODIR}/${PACKAGE}.md5
        if [ -r "${INSTALLED_MD5_FILE}" ] ; then
            INSTALLED_MD5=$(cat ${INSTALLED_MD5_FILE})
            if [[ ${INSTALLED_MD5} = ${line} ]] ; then
                # installed package is current
                if [[ "${JSON}" = false ]] ; then
                    echo "[I] ${PACKAGE_NAME}"
                else
                    echo -n '{"name":"'${PACKAGE_NAME}'","installed":true,"update_available":false}'
                fi
            else
                # installed package has an update available
                if [[ "${JSON}" = false ]] ; then
                    echo "[U] ${PACKAGE_NAME}"
                else
                    echo -n '{"name":"'${PACKAGE_NAME}'","installed":true,"update_available":true}'
                fi
            fi
        else
            # package not installed
            if [[ "${JSON}" = false ]] ; then
                echo "[ ] ${PACKAGE_NAME}"
            else
                echo -n '{"name":"'${PACKAGE_NAME}'","installed":false,"update_available":false}'
            fi
        fi
        ADD_COMMA_FOR_PACKAGE=true
    done < ${REPOLIST}
    if [[ "${JSON}" = false ]] ; then
        echo
    else
        echo -n ']}'
    fi
    ADD_COMMA_FOR_REPOS=true
done

if [[ "${JSON}" = true ]] ; then
    echo -n ']}'
fi
