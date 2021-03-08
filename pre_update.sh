#!/usr/bin/env bash

# shellcheck disable=SC1091,2016,2154
. /etc/rc.subr && load_rc_config

if [ "${homeassistant_user}" == "hass" ]; then
  warn "Manual intervention is required!"
  warn "BREAKING CHANGES - The 'hass' username is no longer supported"
  err 1 "Please see the wiki for details"
elif [ -n "${plugin_ver}" ] && [ "${homeassistant_user}" == "homeassistant" ]; then
  sysrc -x plugin_ver 2>/dev/null
  sysrc -x homeassistant_library_path 2>/dev/null
  sysrc -x homeassistant_cpath 2>/dev/null
  sysrc homeassistant_python=/usr/local/bin/python3.8
  rm -f /root/post_install.sh
  sysrc plugin_version="${plugin_version="5.0"}"
fi

if [ "${plugin_version%%.*}" == "5" ]; then
  sysrc homeassistant_path="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
  rm -rf /root/bin /home/"${homeassistant_user}"/.cache \
  && sed -i~ 's|# Start console menu after login.|set path = (${path} /root/.plugin/bin)|
      s|if ( -x /root/bin/menu ) menu|if ( -x /root/.plugin/bin/menu ) menu|' /root/.login
elif [ "${plugin_version%%-*}" == "v6" ]; then
  exit 0
else
  warn "Unknown Version -- You shouldn't be here!"
  err 1 "Please reinstall this plugin"
fi
