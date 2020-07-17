#!/usr/bin/env bash

update_post_install() {
  ## `post_install.sh` is not updated after the initial installation.
  ## FIXME This plugin should not require any updates to `post_install.sh` after initial installation
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/12.1-RELEASE/post_install.sh \
  && chmod +x /root/post_install.sh || return 1
}
update_post_install; echo " update_post_install: $?"

## Generate a list of manually installed packages
## This list will used to (hopefully) ensure that any user installed FreeBSD packages,
##  not included in the plugin manifest, will be reinstalled after a plugin update
pkg query -e '%a = 0' %n | sort > /tmp/pkglist
