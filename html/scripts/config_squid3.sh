#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

echo -n Configuring SQUID3...

/usr/sbin/service squid3 stop &>/dev/null

render_template ${TEMPLATESDIR}/etc/squid3/squid.conf > /etc/squid3/squid.conf

# TODO: check if $PROXY_CACHEDIR exists or make it. And chown it.

/usr/sbin/service squid3 start &>/dev/null

echo OK
