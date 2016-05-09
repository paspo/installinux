#!/bin/bash

INIFILE=/etc/installinux/installinux.conf

# default config
mkdir -p /etc/installinux/
if [ ! -f $INIFILE ] ; then
  cat > $INIFILE <<EOF_INIFILE
WAN=eth0
WANMODE=dhcp
LAN=eth1
LANMODE=static
LANADDRESS=172.16.17.1
LANNETWORK=172.16.17.0
LANSUBNETMASK=255.255.255.0
LAN_DHCP_START=172.16.17.100
LAN_DHCP_STOP=172.16.17.200
TARGET=/srv

PROXY_CACHEDIR=/var/spool/squid3
PROXY_TRANSPARENT=1
PROXY_LOCALHOST=1
EOF_INIFILE
fi

source $INIFILE


# install require packages  (should be managed by package manager)
echo -n Configuring PACKAGES...
apt-get install -y iptables iptables-persistent pure-ftpd nfs-kernel-server squid3 apache2 libapache2-mod-php5 dnsmasq
echo -n " done."

useradd ftp 
usermod -d $TARGET/iso ftp
rm /etc/pure-ftpd/pureftpd.passwd
( echo admin ; echo admin ) | /usr/bin/pure-pw useradd admin -u ftp -d /srv/iso/ -m

# create structure
mkdir -p $TARGET/{tftp,nfs,iso}
chown ftp:ftp $TARGET/iso
chmod 775 $TARGET/iso


# copying default mirrors
#mkdir -p /etc/installinux/mirrors
#cp mirrors/* /etc/installinux/mirrors

#./apply_config.sh
