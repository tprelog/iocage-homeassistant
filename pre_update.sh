#!/usr/bin/env bash

## Generate a list of manually installed packages
## This list will used to (hopefully) ensure that any user installed FreeBSD packages,
##  not included in the plugin manifest, will be reinstalled after a plugin update
pkg query -e '%a = 0' %n | sort > /tmp/pkglist
