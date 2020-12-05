#!/usr/bin/env bash
# plugin version 5.0

. /etc/rc.subr && load_rc_config

update_post_install() {
  ## post_install.sh is not automatically updated after the initial installation. (This should NOT be required)
  ## FIXED - Version 5 does not require any updates to post_install.sh after initial installation. Still, we
  ## should update the script in version 4, but disable exe to midigate potential use - It should NOT be used!
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/post_install.sh \
  && chmod -x /root/post_install.sh
}

# shellcheck disable=SC2154
if [ "${plugin_ver}" == "v_0.4.0" ]; then
  warn "Version 5 is now available! Please see the wiki for breaking changes."
  warn "You may need a fresh install of this plugin in order to upgrade!"
  update_post_install
elif [ "${plugin_version%%.*}" == "5" ]; then
  true
else ## if plugin_ver != 4 then suggested a fresh install and fail.
# TODO if plugin_force_update then attempt to force upgrade (useful for debugging)
  warn "Version 5 now is available! Please see the wiki for breaking changes."
  warn "Unsupported update path! Please reinstall this plugin."
  err 1 "BREAKING CHANGES - Manual intervention is required!"
fi

## Generate a list of the primaray packages that have been installed.
## If enabled, these packages will be re-installed after Plugin -> UPDATE.
pkg prime-list > /tmp/pkglist
