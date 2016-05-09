#!/bin/sh

INIFILE=/etc/installinux/installinux.conf
BASEDIR=/usr/share/installinux
HTMLDIR=$BASEDIR/html
SCRIPTSDIR=$HTMLDIR/scripts
TEMPLATESDIR=$BASEDIR/templates

#defaults
PROXY_CACHEDIR=/var/spool/squid3
PROXY_TRANSPARENT=1
PROXY_LOCALHOST=1


[ ! -f $INIFILE ] && echo "Can't locate config file! ($INIFILE)" && exit 1
source $INIFILE

DEBIAN_VERSION=$(sed 's/\..*//' /etc/debian_version)


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. You failed." 1>&2
   exit 1
fi

function render_template() {
  eval "echo \"$(cat $1)\""
}

render_template_dir() {
    for line in $(cd $1 ; find . -type d ) ; do
        mkdir -p "${2}/${line}"
    done
	for line in $(cd $1 ; find . -type f ) ; do
		render_template "${1}/${line}" > "${2}/${line}"
	done
	for line in $(cd $1 ; find . -type l ) ; do
		cp "${1}/${line}" "${2}/${line}"
	done
}
