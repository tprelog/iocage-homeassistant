#!/usr/bin/env bash

. /etc/rc.subr
load_rc_config

## NOTE '_plugin_ver_next' should equal to 'plugin_ver' set in "post_install"
_plugin_ver_next="ver_0.4.0"

## Check for a previous version and be sure it's assigned to "plugin_ver"
## If there is no version, start from zero
if [ -n "${_plugin_ver:="$(sysrc -n plugin 2>/dev/null)"}" ]; then
  sysrc plugin_ver="${_plugin_ver}" && sysrc -x plugin
elif [ -n "${_plugin_ver:="$(sysrc -n plugin_version 2>/dev/null)"}" ]; then
  sysrc plugin_ver="${_plugin_ver}" && sysrc -x plugin_version
elif [ -n "${_plugin_ver:="$(sysrc -n plugin_ver 2>/dev/null)"}" ]; then
  true
else
  _plugin_ver="0.0.0"
fi

sysrc plugin_ini 2>/dev/null \
|| sysrc plugin_ini="${_plugin_ver}_$(date +%Y%m%d)"

: "${_ver:="$(echo "${_plugin_ver}" | cut -d. -f2)"}"

if [ "${_ver}" -lt 4 ]; then
  
  srv_prefix="${plugin_srv_prefix:-"/usr/local/share"}"
  srv_uuid="${plugin_srv_uuid:-"8123"}"
  srv_umask="${plugin_srv_umask:-"002"}"
  srv_venv="${plugin_srv_venv:-"${srv_prefix}/${srv_name}"}"
  ## Set python version -- Try using python 3.8 first
  [ ! -z "${_python:="$(which "${plugin_srv_python}")"}" ] \
  || [ ! -z "${_python:="$(which python3.8)"}" ] \
  || [ ! -z "${_python:="$(which python3.7)"}" ] \
  || warn "unable to find python version - set using 'sysrc plugin_srv_python=/path/to/python'"
  srv_python="${_python:-"SET_ME"}"
  debug "using python: ${_python}"

  rename_console_menu() {
    ## This should handle renaming to the console menu.
    local _name_="menu"
    if [ ! -f ${_console_menu_:="/root/bin/${_name_}"} ]; then
      return 1
    fi  ## and make sure it's executable
    [ -x "${_console_menu_}" ] || chmod +x "${_console_menu_}"
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
    if [ -f "/usr/local/bin/openssl" ]; then
      sysrc homeassistant_openssl="package"
    fi
  }
  disable_profile() {
    ## https://homepages.inf.ed.ac.uk/imurray2/compnotes/library_linking.txt
    ## Use openssl 1.1.1 in Home Assistant Core on BSD 11.3-RELEASE
    local _user_="$(id -unr "${srv_uuid}")"
    local _profile_="/home/${_user_}/.profile"
    if [ -f "${_profile_}" ]; then
      mv  "${_profile_}" "${_profile_}.disabled"
      echo "WARNING: using \"${_profile_}\" is no longer supported by this plugin"
      echo "INFO: \"${_profile_}\" has been disabled!"
      echo "INFO: It can be re-enabled using: mv ${_profile_}.disabled ${_profile_}"
    fi
  }
  _set_rc_vars() {
    echo -e "\nINFO: setting rc vars for ${srv_name}"
    if [ -z "${_dir_:-"$(sysrc -n ${srv_venv} 2>/dev/null)"}" ]; then
      if [ -d "/srv/${srv_name}" ]; then
        echo "RETRO VENV: found directory. setting manual override to use existing directory"
        srv_venv="/srv/${srv_name}"
      fi
    fi
    sysrc ${srv_name}_venv="${srv_venv}"
    sysrc ${srv_name}_python="${srv_python}"
    sysrc ${srv_name}_umask="${srv_umask}"
    sysrc ${srv_name}_user="${srv_uname}"
    sysrc ${srv_name}_group="${srv_gname}"
    sysrc ${srv_name}_config_dir="${srv_config_dir}"
  }
  getset_rcvars() {
    ## Home Assistant Core
    if [ ! -z $(sysrc -n homeassistant_enable 2>/dev/null) ];then
      srv_name="homeassistant"
      info "getting rcvars for service ${srv_name}"
      srv_umask="${homeassistant_umask:-"${srv_umask}"}"
      srv_uname="${homeassistant_user:-"$(id -unr "${srv_uuid}")"}"
      srv_gname="${homeassistant_group:-"$(id -nrg "${srv_uname}")"}"
      srv_uhome="${homeassistant_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
      srv_config_dir="${homeassistant_config_dir:-"${srv_uhome}/${srv_name}"}"
      srv_python="${homeassistant_python:-"${srv_python}"}"
      srv_venv="${homeassistant_venv:-"${srv_prefix}/${srv_name}"}"
      _set_rc_vars
    fi
    ## Configurator -- File Editor
    if [ ! -z $(sysrc -n configurator_enable 2>/dev/null) ];then
      srv_name="configurator"
      info "getting rcvars for service ${srv_name}"
      srv_umask="${configurator_umask:-"${srv_umask}"}"
      srv_uname="${configurator_user:-"$(id -unr "${srv_uuid}")"}"
      srv_gname="${configurator_group:-"$(id -nrg "${srv_uname}")"}"
      srv_uhome="${configurator_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
      srv_config_dir="${configurator_config_dir:-"${srv_uhome}/${srv_name}"}"
      srv_python="${configurator_python:-"${srv_python}"}"
      srv_venv="${configurator_venv:-"${srv_prefix}/${srv_name}"}"
      _set_rc_vars
      debug "checking for retro config file - ${srv_config_dir}/configurator.conf"
      if [ -f "${_config:="${srv_config_dir}/configurator.conf"}" ]; then
        ## If the file is not already there - it should no longer be provided by this plugin
        echo "RETRO CONFIG: file found - setting manual override to use existing configuration"
        sysrc configurator_config="${_config}"
      fi
    fi
    ## AppDaemon
    if [ ! -z $(sysrc -n appdaemon_enable 2>/dev/null) ];then
      srv_name="appdaemon"
      info "getting rcvars for service ${srv_name}"
      srv_umask="${appdaemon_umask:-"${srv_umask}"}"
      srv_uname="${appdaemon_user:-"$(id -unr "${srv_uuid}")"}"
      srv_gname="${appdaemon_group:-"$(id -nrg "${srv_uname}")"}"
      srv_uhome="${appdaemon_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
      srv_config_dir="${appdaemon_config_dir:-"${srv_uhome}/${srv_name}"}"
      srv_python="${appdaemon_python:-"${srv_python}"}"
      srv_venv="${appdaemon_venv:-"${srv_prefix}/${srv_name}"}"
      _set_rc_vars
      debug "checking for nested config directory - ${srv_config_dir}/conf"
      if [ -d "${_config:="${srv_config_dir}/conf"}" ]; then
        ## If the directory is not already there - it should no longer be provided by this plugin
        echo "RETRO CONFIG: directory found - setting manual override to use existing configuration"
        sysrc appdaemon_config_dir="${_config}"
      fi
    fi
  }

  echo -e "\nINFO: Running pre-update functions for versions 0.0 -> 0.4"
  getset_rcvars; echo -e "\n getset_rcvars: $?"
  check_openssl; echo " check_openssl: $?"
  disable_esphome_menu; echo " disable_esphome_menu: $?"
  disable_profile; echo " disable_profile: $?"
  rename_console_menu; echo -e " rename_console_menu: $?\n"
elif [ "${_ver}" == "4" ]; then ## likely to be at ver_0.4.X for awhile
  echo "INFO: pre_update: found current version "${_plugin_ver}""
else
  echo "WARNING: unknown version "${_plugin_ver}""
fi

update_post_install() {
  ## `post_install.sh` is not updated after the initial installation.
  ## FIXME This plugin should not require any updates to `post_install.sh` after initial installation
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/post_install.sh \
  && chmod +x /root/post_install.sh || return 1
}
update_post_install; echo " update_post_install: $?"

## Generate a list of manually installed packages
## This list will used to (hopefully) ensure that any user installed FreeBSD packages,
##  not included in the plugin manifest, will be reinstalled after a Plugin -> UPDATE
pkg query -e '%a = 0' %n | sort > /tmp/pkglist

## If you make it this, you should have made it to the next version!
sysrc plugin_ver="${_plugin_ver_next}"
