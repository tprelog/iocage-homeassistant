#!/usr/bin/env bash

. /etc/rc.subr && load_rc_config

# TODO work out logic that will only suggest a clean install when required
# TODO if plugin_force_update then attempt to force upgrade (useful for debugging)

# shellcheck disable=SC2154
if [ "${plugin_version}" == "5" ]; then
  true
elif [ "${plugin_ver}" == "v_0.4.0" ]; then
  # TODO if plugin_ini != some_date_in_time then suggested clean install and fail
  echo "INFO: pre_update: current version is ${plugin_ver}"
else # if plugin_ver != 4 then suggested a fresh install and fail
  warn "unsupported upgrade path, please reinstall this plugin"
  err 1 "BREAKING CHANGES - manual intervention required!"
fi

update_post_install() {
  # post_install.sh is not automatically updated after the initial installation
  # FIXME plugins should not require any updates to post_install.sh after initial installation
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/post_install.sh \
  && chmod +x /root/post_install.sh || return 1
} ; update_post_install

## Generate a list of the primaray packages that have been installed.
## If enabled, these packages will be re-installed after a Plugin -> UPDATE.
pkg prime-list > /tmp/pkglist
