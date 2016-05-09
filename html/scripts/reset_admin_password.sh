#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

rm /etc/pure-ftpd/pureftpd.passwd
( echo admin ; echo admin ) | /usr/bin/pure-pw useradd admin -u ftp -d /srv/iso/ -m

echo Password resetted. You can now login at the following addresses:
echo   http://$LANADDRESS:880/
echo   http://$WANADDRESS:880/
echo with the following credentials:
echo   user:  admin
echo   pass:  admin
