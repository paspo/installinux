#!/bin/bash

# composer... we'll take care later
#cd html/ && composer update && cd ..

mkdir -p /usr/share/installinux/html
mkdir -p /usr/share/installinux/templates
cp -r conf/ /etc/
rsync -av --delete html/ /usr/share/installinux/html/
rsync -av --delete templates/ /usr/share/installinux/templates/
cp bin/* /usr/bin
mkdir -p /var/lib/installinux/tftp_repos

