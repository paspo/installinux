#!/bin/bash

ISO=$1
MOUNTDIR=/srv/isopreload/ubuntu

[ ! -d ${MOUNTDIR} ] && mkdir -p ${MOUNTDIR}

mount -o loop "${ISO}" "${MOUNTDIR}" >/dev/null | exit 1

cd /srv/isopreload
find ubuntu/pool -name '*.deb' | while read F ; do
	curl "http://installinux:880/isopreload/$F" -fNs --proxy 127.0.0.1:8080 -o /dev/null 
	echo Preloaded: $F
done

umount ${MOUNTDIR}
rmdir ${MOUNTDIR}
cd -

