#!/usr/bin/env bash

## Start using some versions for the plugin
## If no version is assigned we start from zero
_plugin_ver="$(sysrc -n plugin_ver 2>/dev/null)"
if [ -z "${_plugin_ver}" ]; then
  _plugin_ver="0.0.0"
  sysrc plugin_ver="${_plugin_ver}"
fi
sysrc plugin_ini 2>/dev/null \
|| sysrc plugin_ini="${_plugin_ver}_$(date +%y%m%d)"


if [ "${_plugin_ver}" == "0.0.0" ]; then
  update_post_install() {
    ## `post_install.sh` is not updated after the initial installation. Likely it's only files in the overlay
    ## Future versions of this plugin should not require any updates to `post_install.sh` after installation
    wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/post_install.sh \
    && chmod +x /root/post_install.sh || return 1
    return 0
  }
  update_compile_linking() {
    ## https://homepages.inf.ed.ac.uk/imurray2/compnotes/library_linking.txt
    ## Use openssl 1.1.1 in Home Assistant Core on BSD 11.3-RELEASE
    local _user_="$(sysrc -n homeassistant_user 2>/dev/null)"
    if [ -z "${_user_}" ]; then
      _user_="hass"
    fi
    local _profile_="/home/${_user_}/.profile"
    sed -e "s%export LDFLAGS=-I/usr/local/include%export LIBRARY_PATH=/usr/local/lib%
            s%export CFLAGS=-I/usr/local/include%export CPATH=/usr/local/include%" "${_profile_}" > "${_profile_}.temp" \
    && mv "${_profile_}.temp" "${_profile_}" || return 1
    chown "${_user_}" "${_profile_}" && return 0 || return 2
  }
  rename_console_menu() {
    ## This should handle renaming to the console menu.            
    local _name_="menu"
    if [ ! -f ${_console_menu_:="/root/bin/${_name_}"} ]; then
      return 1
    elif [ ! -x "${_console_menu_}" ]; then
      chmod +x "${_console_menu_}" || return 2
    fi
    ## Rename hass-helper to $_name_
    if [ -f "/root/bin/hass-helper" ]; then
      sed -e "s/hass-helper/${_name_}/g" /root/.login > /root/.loginTemp \
      && mv /root/.loginTemp /root/.login && rm -f "/root/bin/hass-helper"
    fi
    ## Rename hassbsd to $_name_
    if [ -f "/root/bin/hassbsd" ]; then
      sed -e "s/hassbsd/${_name_}/g" /root/.login > /root/.loginTemp \
      && mv /root/.loginTemp /root/.login && rm -f "/root/bin/hassbsd"
    fi
  }
  disable_esphome_menu () {
    ## ESPHome has been moved to a seperate FreeNAS plugin. 
    ## The console menu is no longer available for this service
    sysrc -x esphome_menu 2>/dev/null
    return 0
  }
  echo -e "\nRunning pre-update functions for version 0.0.0"
  disable_esphome_menu; echo " disable_esphome_menu: $?"
  update_post_install; echo " update_post_install: $?"
  update_compile_linking; echo " update_compile_linking: $?"
  rename_console_menu; echo " rename_console_menu: $?"
fi


if [ "${_plugin_ver}" == "0.0.1" ]; then
  do_something() {
    echo "Do something else" && return 0 || return 1
  }
  echo -e "\nRunning pre-update functions for version 0.0.1"
  do_something; echo " do_something: $?"
fi

## Generate a list of manually installed packages
## This list will used to (hopefully) ensure that any user installed FreeBSD packages,
##  not included in the plugin manifest, will be reinstalled after a plugin update
pkg query -e '%a = 0' %n | sort > /tmp/pkglist
