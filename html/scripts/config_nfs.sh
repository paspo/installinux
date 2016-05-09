#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

echo -n Configuring NFS...

mkdir -p /etc/exports.d
render_template ${TEMPLATESDIR}/etc/exports.d/installinux.exports > /etc/exports.d/installinux.exports

/usr/sbin/exportfs -ra

/usr/sbin/service nfs-kernel-server restart &>/dev/null

echo OK
