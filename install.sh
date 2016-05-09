#!/bin/bash

# composer... we'll take care later
#cd html/ && composer update && cd ..

apt-get install iptables iptables-persistent pure-ftpd nfs-kernel-server \
	squid3 apache2 apache2-mpm-prefork libapache2-mod-php5 coreutils \
	dnsmasq perl wget bash snmpd mrtg cron sudo

# make sure squid3 is >= 3.4

mkdir -p /usr/share/installinux/html
mkdir -p /usr/share/installinux/templates
cp -r conf/ /etc/
rsync -av --delete html/ /usr/share/installinux/html/
rsync -av --delete templates/ /usr/share/installinux/templates/
cp bin/* /usr/bin
mkdir -p /var/lib/installinux/tftp_repos

echo Take a look at /etc/installunux/installinux.conf then run
echo    /usr/share/installinux/html/scripts/apply_config.sh
