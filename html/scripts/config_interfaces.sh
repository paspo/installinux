#!/bin/bash

. /usr/share/installinux/html/scripts/common.sh

echo -n Configuring INTERFACES...

if [[ ${DEBIAN_VERSION} -ge 8 ]] ; then
	mkdir -p /etc/network/interfaces.d
	render_template ${TEMPLATESDIR}/etc/network/interfaces.d/installinux-wan-${WANMODE} > /etc/network/interfaces.d/installinux-wan
	render_template ${TEMPLATESDIR}/etc/network/interfaces.d/installinux-lan-${LANMODE} > /etc/network/interfaces.d/installinux-lan
else
	FILENAME=/etc/network/interfaces
	TMPFILE=$(mktemp)
	render_template ${TEMPLATESDIR}/etc/network/interfaces.d/installinux-wan-${WANMODE} >> $TMPFILE
	render_template ${TEMPLATESDIR}/etc/network/interfaces.d/installinux-lan-${LANMODE} >> $TMPFILE
	if [ `grep -c '^### BEGIN INSTALLINUX CONTENT$' $FILENAME` == 0 ] ; then
		# if there's no sign of our custom section, we rewrite completely the file
		echo "auto lo" > $FILENAME
		echo "iface lo inet loopback" >> $FILENAME
		echo "### BEGIN INSTALLINUX CONTENT" >> $FILENAME
		cat $TMPFILE >> $FILENAME
		echo "### END INSTALLINUX CONTENT" >> $FILENAME
	else
		lead='^### BEGIN INSTALLINUX CONTENT$'
		tail='^### END INSTALLINUX CONTENT$'
		sed -ie "/$lead/,/$tail/{ /$lead/{p; r $TMPFILE
	        }; /$tail/p; d }" $FILENAME
	fi
	rm $TMPFILE
fi

# TODO: maybe it's better to use a different method for interface configuration

ifup ${WAN}
ifup ${LAN}

echo OK
