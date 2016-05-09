#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

echo -n Configuring DNSMASQ...

render_template ${TEMPLATESDIR}/etc/dnsmasq.conf > /etc/dnsmasq.conf

/usr/sbin/service dnsmasq restart &>/dev/null

echo OK
