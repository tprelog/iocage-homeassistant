#!/usr/bin/env bash

# shellcheck disable=SC1091
. /etc/rc.subr && load_rc_config

# shellcheck disable=SC2154
if [ "${plugin_ver}" == "v_0.4.0" ]; then
  warn "Version 6 is now available! Please see the wiki for breaking changes."
  warn "You may need a fresh install of this plugin in order to upgrade!"
  rm -f /root/post_install.sh
elif [ "${plugin_version%%.*}" == "5" ]; then
  ## TODO -- for now just exit 0
  exit 0
elif [ "${plugin_version%%-*}" == "6" ]; then
  exit 0
else
  warn "Upgrades from unknown versions are no longer supported! Please reinstall this plugin."
  err 1 "Manual intervention is required! Please see the wiki for breaking changes."
fi
