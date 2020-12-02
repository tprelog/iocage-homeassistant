#!/usr/bin/env bash

plugin_version="5"
plugin_name="homeassistant"

. /etc/rc.subr && load_rc_config

#
# plugin_srv_prefix: Parent directory, where virtualenv directories created by this plugin will be located.
#       Default:  "/usr/local/share"
# TODO: part of cleanup duplicate code
#

srv_prefix="${plugin_srv_prefix:-"/usr/local/share"}"
srv_venv="${plugin_srv_venv:-"${srv_prefix}/${srv_name}"}"
srv_python="${plugin_srv_python:-"$(which python3.8)"}"
# TODO: reduce reuse recycle
srv_umask="${plugin_srv_umask:-"002"}"
srv_uuid="${plugin_srv_uuid:-"8123"}"
srv_uname="${plugin_srv_uname:-"${srv_name}"}"
srv_gname="${plugin_srv_gname:-"${srv_name}"}"
srv_uhome="${plugin_srv_uhome:-"/home/${srv_name}"}"
srv_config_dir="${plugin_srv_config_dir:-"${srv_uhome}/${srv_name}"}"


set_rc_vars() {
  echo -e "\nINFO: setting rc vars for ${srv_name}"
  #sysrc ${srv_name}_enable="${srv_enable}"
  if [ -z "${_dir_:-"$(sysrc -n "${srv_venv}" 2>/dev/null)"}" ]; then
    if [ -d "/srv/${srv_name}" ]; then
      echo "RETRO VENV: found directory. setting manual override to use existing directory"
      srv_venv="/srv/${srv_name}"
    fi
  fi
  sysrc "${srv_name}"_venv="${srv_venv}"
  sysrc "${srv_name}"_python="${srv_python}"
  sysrc "${srv_name}"_umask="${srv_umask}"
  sysrc "${srv_name}"_user="${srv_uname}"
  sysrc "${srv_name}"_group="${srv_gname}"
  sysrc "${srv_name}"_config_dir="${srv_config_dir}"
}


_config_warning() {
  echo -e " \n${orn} ${2} is not empty!\n"
  echo    " example configuration will not copied."
  echo -e " \"${1}\" may fail to start with invalid or missing configuration${end}\n"
  sleep 1
}

# TODO: part of cleanup duplicate code
# TODO: move to separate script - possibly combine with the "config function" removed from HA RC script
cp_config() {
  ## ONLY IF ${config_dir} == EMPTY, else nothing is copied.
  ## copy the example configuration files during an install.
  ## These files should be modified or replaced by end users
  srv_name="${1:-"${srv_name}"}"
  config_dir="${srv_config_dir}"
  example_cfg="/usr/local/examples/${srv_name}/"
  debug "copy example config for ${srv_name}: ${config_dir}"
  
  # yaml = file containing plugin provided panel_iframes
  # shellcheck disable=SC2154
  yaml="${homeassistant_config_dir}/packages/freenas_plugin.yaml"
  
  if [ ! -d "${config_dir}" ]; then
    install -d -g "${srv_uname}" -o "${srv_uname}" -m 775 -- "${config_dir}" || return
  fi
  
  case "${srv_name}" in
    
    ## Home Assistant Core
    "homeassistant")
      ## Copy the example Home Assistant Core configuration files
      if [ ! "$(ls -A "${config_dir}")" ]; then
        cp -R "${example_cfg}" "${config_dir}"
        find "${config_dir}" -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R "${srv_uname}":"${srv_uname}" "${config_dir}" && chmod -R g=u "${config_dir}"
      else
        _config_warning "${srv_name}" "${config_dir}"
      fi
    ;;
    
    ## Hass-Configurator
    "configurator")
      ## Copy the example Hass-Configurator configuration file
      if [ ! "$(ls -A "${config_dir}")" ]; then
        debug "copy ${srv_name} examples: cp -R ${example_cfg} ${config_dir}"
        cp -R "${example_cfg}" "${config_dir}"
        find "${config_dir}" -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R "${srv_uname}":"${srv_uname}" "${config_dir}" && chmod -R g=u "${config_dir}"
      else
        _config_warning "${srv_name}" "${config_dir}"
      fi
      # Enable the Hass-Configurator iframe
      if [ -f "${yaml}" ]; then
        sed -e "s/#panel_iframe:/panel_iframe:/
          s/#configurator:/configurator:/
          s/#title: File Editor/title: File Editor/
          s/#icon: mdi:wrench/icon: mdi:wrench/
          s/#require_admin: true/require_admin: true/
          s%#url: http://0.0.0.0:3218%url: http://${v2srv_ip}:3218%" "${yaml}" > "${yaml}".temp && mv "${yaml}".temp "${yaml}"
        chown -R "${srv_uname}":"${srv_uname}" "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;
    
    ## AppDaemon (includes HADashboard)
    "appdaemon")
      ## Copy the example AppDaemon configuration files
      if [ ! "$(ls -A "${config_dir}")" ]; then
        debug "copy ${srv_name} examples: cp -R ${example_cfg} ${config_dir}"
        cp -R "${example_cfg}" "${config_dir}"
        find "${config_dir}" -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R "${srv_uname}":"${srv_uname}" "${config_dir}" && chmod -R g=u "${config_dir}"
      else
        _config_warning "${srv_name}" "${config_dir}"
      fi
      # Enable the AppDaemon iframe
      if [ -f "${yaml}" ]; then
        sed -e "s/#panel_iframe:/panel_iframe:/
          s/#appdaemon:/appdaemon:/
          s/#title: AppDaemon/title: AppDaemon/
          s/#icon: mdi:view-dashboard-variant/icon: mdi:view-dashboard-variant/
          s/#require_admin: false/require_admin: true/
          s%#url: http://0.0.0.0:5050%url: http://${v2srv_ip}:5050%" "${yaml}" > "${yaml}.temp" && mv "${yaml}.temp" "${yaml}"
        chown -R "${srv_uname}":"${srv_uname}" "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;

esac
}

# TODO: part of cleanup duplicate code
# TODO: move this it's own script and source from service rc script
install_service() {
  if [ ! -d "${srv_venv}" ]; then
    info "creating virtualenv for \"${srv_name}\": ${srv_venv}"
    install -d -g "${srv_gname}" -m 775 -o "${srv_uname}" -- "${srv_venv}" 2>/tmp/err \
    || err ${?} "$(</tmp/err)"
  elif [ -n "$(ls -A "${srv_venv}")" ] && [ "${__name__}" = "post_install.sh" ]; then
    warn "${orn}virtualenv directory found and it's not empty!${end}"
    warn "${orn}please remove \"${srv_venv}\" and try again${end}"
    err 1 "${red}expecting empty directory${end} ${srv_venv}"
    exit
  else
    info "using existing directory for virtualenv: ${srv_venv}"
  fi
  # shellcheck disable=SC2016
  su "${srv_uname}" -c '
    ${1} -m venv ${2}
    source ${2}/bin/activate 2>/tmp/err || exit 1
    shift 2
    pip install --upgrade --no-cache pip wheel
    if [ ${1} = "homeassistant" ]; then
      pip install --no-cache homeassistant \
      && service homeassistant config --ensure \
      && service homeassistant config --check
    elif [ ${1} = "appdaemon" ]; then
      pip install --no-cache appdaemon
    elif [ ${1} = "configurator" ]; then
      pip install --no-cache hass-configurator
    else
      pip install --no-cache "${@}"
    fi
    deactivate
  ' _ "${srv_python}" "${srv_venv}" "${@}" || err ${?} "$(</tmp/err)"
}

enableStart_v2srv () {
  chmod +x "/usr/local/etc/rc.d/${srv_name}"
  sysrc -f /etc/rc.conf "${srv_name}_enable"=yes
  service "${srv_name}" start
}

colors () {
  red=$'\e[1;31m'
  grn=$'\e[1;32m'
  orn=$'\e[38;5;208m'
  end=$'\e[0m'
}

__script__="${0}"
__name__="$(basename "${__script__}")"

install -m 666 -- /dev/null "/tmp/err"
colors

v2srv_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

## Install Home Assistant Core using 'post_install.sh homeassistant'
if [ "${__name__}" == "homeassistant" ] || [ "${1}" == "homeassistant" ]; then
    srv_name="homeassistant"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
    srv_umask="${homeassistant_umask:-"${srv_umask}"}"
    srv_uname="${homeassistant_user:-"$(id -unr "${srv_uuid}")"}"
    srv_gname="${homeassistant_group:-"$(id -nrg "${srv_uname}")"}"
    srv_uhome="${homeassistant_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
    srv_config_dir="${homeassistant_config_dir:-"${srv_uhome}/${srv_name}"}"
    srv_python="${homeassistant_python:-"${srv_python}"}"
    srv_venv="${homeassistant_venv:-"${srv_prefix}/${srv_name}"}"
    install_service ${srv_name} || err 1 "return $?"
    set_rc_vars
    cp_config ${srv_name}
    enableStart_v2srv || err 1 "return $?"
    echo -e "\n ${grn}http://${v2srv_ip}:8123${end}\n"
    echo -e "${orn}Initial startup can take several minutes before Home Assistant is fully loaded${end}\n"
    exit "${?}"
## Install AppDaemon using 'post_install.sh appdaemon'
elif [ "${__name__}" == "appdaemon" ] || [ "${1}" == "appdaemon" ]; then
    srv_name="appdaemon"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
    srv_umask="${appdaemon_umask:-"${srv_umask}"}"
    srv_uname="${appdaemon_user:-"$(id -unr "${srv_uuid}")"}"
    srv_gname="${appdaemon_group:-"$(id -nrg "${srv_uname}")"}"
    srv_uhome="${appdaemon_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
    srv_config_dir="${appdaemon_config_dir:-"${srv_uhome}/${srv_name}"}"
    srv_python="${appdaemon_python:-"${srv_python}"}"
    srv_venv="${appdaemon_venv:-"${srv_prefix}/${srv_name}"}"
    install_service ${srv_name} || exit "${?}"
    set_rc_vars
    cp_config ${srv_name}
    debug "checking for nested config directory - ${srv_config_dir}/conf"
    if [ -d "${_config:="${srv_config_dir}/conf"}" ]; then
      ## Check the previous location for a configuration directory
      echo "RETRO CONFIG: directory found - setting manual override to use existing configuration"
      sysrc appdaemon_config_dir="${_config}"
    fi
    enableStart_v2srv || exit "${?}"
    echo -e "\n ${grn}http://${v2srv_ip}:5050${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    exit "${?}"
## Install Hass-Configurator using 'post_install.sh configurator'
elif [ "${__name__}" == "configurator" ] || [ "${1}" == "configurator" ]; then
    srv_name="configurator"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
    srv_umask="${configurator_umask:-"${srv_umask}"}"
    srv_uname="${configurator_user:-"$(id -unr "${srv_uuid}")"}"
    srv_gname="${configurator_group:-"$(id -nrg "${srv_uname}")"}"
    srv_uhome="${configurator_user_dir:-"$(eval echo "~${srv_uname}" 2>/dev/null)"}"
    srv_config_dir="${configurator_config_dir:-"${srv_uhome}/${srv_name}"}"
    srv_python="${configurator_python:-"${srv_python}"}"
    srv_venv="${configurator_venv:-"${srv_prefix}/${srv_name}"}"
    install_service ${srv_name} || err 1 "return $?"
    set_rc_vars
    cp_config ${srv_name}
    debug "checking for retro config file - ${srv_config_dir}/configurator.conf"
    if [ -f "${_config:="${srv_config_dir}/configurator.conf"}" ]; then
      ## Check the previous location for a configuration file
      echo "RETRO CONFIG: file found - setting manual override to use existing configuration"
      sysrc configurator_config="${_config}"
    fi
    enableStart_v2srv || exit "${?}"
    echo -e "\n ${grn}http://${v2srv_ip}:3218${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    exit "${?}"
## Test install called by rc script - "plugin" is generic service used internally for testing
elif [ "${__name__}" == "plugin" ]; then
    info " -- MOCK SERVICE ONLY -- "
    rc_debug="ON"
    echo "debug should on"
    debug "TEST: ${__name__}"
    exit "${?}"
else
    warn "service \"${__name__}\" has called post_install.sh"
    debug " script: ${__script__}"
    debug " name: ${__name__}"
    debug " args: ${*}"
    err 1 "Finished with nothing to do!"
fi
echo -e "\nYOU SHOULDN'T BE HERE\n"
exit 1
