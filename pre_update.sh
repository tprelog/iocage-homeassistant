#!/usr/bin/env bash

# shellcheck disable=SC1091,2016,2154
. /etc/rc.subr && load_rc_config

if  [ "${plugin_ver}" == "v_0.4.0" ] && [ "${homeassistant_user}" == "homeassistant" ]; then
  plugin_version=5.0 ; sysrc -x plugin_ver
  rm -f /root/post_install.sh
elif [ "${plugin_ver}" == "v_0.4.0" ] && [ "${homeassistant_user}" == "hass" ]; then
  warn "BREAKING CHANGES - The 'hass' username is no longer supported."
fi

if [ "${plugin_version%%.*}" == "5" ]; then
  sysrc homeassistant_path="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
  rm -rf /root/bin/{menu,menu_service,install_hacs} /home/"${homeassistant_user}"/.cache \
  && sed -i~ 's|# Start console menu after login.|set path = (${path} /root/.plugin/bin)|
      s|if ( -x /root/bin/menu ) menu|if ( -x /root/.plugin/bin/menu ) menu|' /root/.login
elif [ "${plugin_version%%-*}" == "v6" ]; then
  exit 0
else
  warn "Manual intervention is required!"
  err 1 "Please see the wiki for breaking changes."
fi
