#!/usr/bin/env bash

## Check for a version and be sure it's assigned to plugin_ver
## If no version is assigned start from zero
if [ ! -z $(sysrc -n plugin 2>/dev/null) ]; then
  _plugin_ver=$(sysrc -n plugin)
  sysrc plugin_ver=${_plugin_ver}
  sysrc -x plugin
elif [ ! -z $(sysrc -n plugin_version 2>/dev/null) ]; then
  _plugin_ver=$(sysrc -n plugin_version)
  sysrc plugin_ver=${_plugin_ver}
  sysrc -x plugin_version
elif [ ! -z $(sysrc -n plugin_ver 2>/dev/null) ]; then
  _plugin_ver=$(sysrc -n plugin_ver)
else
  _plugin_ver="0.0.0"
  sysrc plugin_ver="${_plugin_ver}"
fi

sysrc plugin_ini 2>/dev/null \
|| sysrc plugin_ini="${_plugin_ver}_$(date +%y%m%d)"

update_post_install() {
  ## `post_install.sh` is not updated after the initial installation. Likely it's only files in the overlay
  ## Future versions of this plugin should not require any updates to `post_install.sh` after installation
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/11.3-RELEASE/post_install.sh \
  && chmod +x /root/post_install.sh || return 1
}
update_post_install; echo " update_post_install: $?"
 
if [ "${_plugin_ver}" == "0.0.0" ]; then
  update_compile_linking() {
    ## https://homepages.inf.ed.ac.uk/imurray2/compnotes/library_linking.txt
    ## Use openssl 1.1.1 in Home Assistant Core on BSD 11.3-RELEASE
    local _user_="$(sysrc -n homeassistant_user 2>/dev/null)"
    if [ -z "${_user_}" ]; then
      _user_="hass"
    fi
    local _profile_="/home/${_user_}/.profile"
    if [ -f "${_profile_}" ]; then
      sed -e "s%export LDFLAGS=-I/usr/local/include%export LIBRARY_PATH=/usr/local/lib%
              s%export CFLAGS=-I/usr/local/include%export CPATH=/usr/local/include%" "${_profile_}" > "${_profile_}.temp" \
      && mv "${_profile_}.temp" "${_profile_}" || return 1
      chown "${_user_}" "${_profile_}" || return 2
    fi
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
  check_openssl () {
      ## Assume to keep using package version of openssl, if it's already installed
      ## Manual intervention will be required if you are not using 
      ## HomeKit and you want to fix Z-Wave. ( Sorrry for the inconvenience )
    if [ -f "/usr/local/bin/openssl" ]; then
      sysrc homeassistant_openssl="package"
    fi
  }
  echo -e "\nRunning pre-update functions for version 0.0.0"
  disable_esphome_menu; echo " disable_esphome_menu: $?"
  update_compile_linking; echo " update_compile_linking: $?"
  rename_console_menu; echo " rename_console_menu: $?"
  check_openssl; echo " check_openssl: $?"
fi


if [ "${_plugin_ver}" == "0.0.1" ]; then
  do_something() {
    echo "Do something else" && return 0 || return 1
  }
  echo -e "\nRunning pre-update functions for version 0.0.1"
  do_something; echo " do_something: $?"
fi

## Check for and set any missing rc vars to original defaults in the 11.3-RELEASE plugin
## Recent versions of the plugin should set these during installation
## These default values may change for the 12.1-RELEASE plugin installation
check_rcvar() {
  ## AppDaemon
  if [ ! -z $(sysrc -n appdaemon_enable 2>/dev/null) ];then
    if [ -z $(sysrc -n appdaemon_python 2>/dev/null) ];then
      sysrc appdaemon_python="$(which python3.7)"
    fi
    if [ -z $(sysrc -n appdaemon_venv 2>/dev/null) ];then
      sysrc appdaemon_venv="/srv/appdaemon"
    fi
    if [ -z $(sysrc -n appdaemon_user 2>/dev/null) ];then
      sysrc appdaemon_user="hass"
    fi
    if [ -z $(sysrc -n appdaemon_group 2>/dev/null) ];then
      sysrc appdaemon_group="hass"
    fi
    if [ -z $(sysrc -n appdaemon_config_dir 2>/dev/null) ];then
      sysrc appdaemon_config_dir="/home/hass/appdaemon/conf"
    fi
  fi
  ## Configurator -- File Editor
  if [ ! -z $(sysrc -n configurator_enable 2>/dev/null) ];then
    if [ -z $(sysrc -n configurator_python 2>/dev/null) ];then
      sysrc configurator_python="$(which python3.7)"
    fi
    if [ -z $(sysrc -n configurator_venv 2>/dev/null) ];then
      sysrc configurator_venv="/srv/configurator"
    fi
    if [ -z $(sysrc -n configurator_user 2>/dev/null) ];then
      sysrc configurator_user="hass"
    fi
    if [ -z $(sysrc -n configurator_group 2>/dev/null) ];then
      sysrc configurator_group="hass"
    fi
    if [ -z $(sysrc -n configurator_config 2>/dev/null) ];then
      sysrc configurator_config="/home/hass/configurator/configurator.conf"
    fi
  fi
  ## Home Assistant Core
  if [ ! -z $(sysrc -n homeassistant_enable 2>/dev/null) ];then
    if [ -z $(sysrc -n homeassistant_python 2>/dev/null) ];then
      sysrc homeassistant_python="$(which python3.7)"
    fi
    if [ -z $(sysrc -n homeassistant_venv 2>/dev/null) ];then
      sysrc homeassistant_venv="/srv/homeassistant"
    fi
    if [ -z $(sysrc -n homeassistant_user 2>/dev/null) ];then
      sysrc homeassistant_user="hass"
    fi
    if [ -z $(sysrc -n homeassistant_group 2>/dev/null) ];then
      sysrc homeassistant_group="hass"
    fi
    if [ -z $(sysrc -n homeassistant_config_dir 2>/dev/null) ];then
      sysrc homeassistant_config_dir="/home/hass/homeassistant"
    fi
  fi
}

if [ $(echo ${_plugin_ver} | cut -d "-" -f "2") != "1" ]; then
  check_rcvar; echo " check_rcvar: $?"
  sysrc plugin_ver="${_plugin_ver}-1"
fi

## Generate a list of manually installed packages
## This list will used to (hopefully) ensure that any user installed FreeBSD packages,
##  not included in the plugin manifest, will be reinstalled after a plugin update
pkg query -e '%a = 0' %n | sort > /tmp/pkglist
