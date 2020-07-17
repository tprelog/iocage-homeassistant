#!/usr/bin/env bash
srv_name="homeassistant"

. /etc/rc.subr
load_rc_config
plugin_ver="${plugin_ver:="v_0.4.0"}"

#
# plugin_srv_prefix: Directory where virtualenv directories are located.
#       Default:  "/usr/local/share"
#       Set to retro:    `sysrc plugin_srv_prefix=/srv`
#       Reset to default: `sysrc -x plugin_srv_prefix`

# ( Hopefully ) sane default for *BSD / FreeNAS / TrueNAS Core
srv_prefix="${plugin_srv_prefix:="/usr/local/share"}"

srv_enable="${homeassistant_enable:-"yes"}"
srv_umask="${homeassistant_umask:-"002"}"
# UUID matches the default port used by homeassistant
srv_uuid="${homeassistant_uid:-"8123"}"
# USER / GROUP to run the homeassistant daemon
srv_uname="${homeassistant_user:-"homeassistant"}"
srv_gname="${homeassistant_group:-"homeassistant"}"
# user_dir is HOME and PARENT_DIR to SERVICE configuration
srv_uhome="${homeassistant_user_dir:-"/home/homeassistant"}"
# locatation for homeassistant confiuragtion files
srv_config_dir="${homeassistant_config_dir:-"/home/homeassistant/homeassistant"}"
# path to python version to use for the virtualenv
srv_python="${homeassistant_python:-"/usr/local/bin/python3.8"}"
# full path to the python virtualenv for homeassistant
srv_venv="${homeassistant_venv:-"${srv_prefix}/${srv_name}"}"


set_rc_vars() {
  echo -e "\nsetting rc vars for \"${srv_name}\""
  sysrc ${srv_name}_enable="${srv_enable}"
  sysrc ${srv_name}_config_dir="${srv_config_dir}"
  sysrc ${srv_name}_user="${srv_uname}"
  sysrc ${srv_name}_group="${srv_gname}"
  sysrc ${srv_name}_python="${srv_python}"
  sysrc ${srv_name}_venv="${srv_venv}"
  sysrc ${srv_name}_umask="${srv_umask}"
  echo
}


add_user() {
  local _U_="${srv_uuid}" 
  local _D_="${srv_uhome}"
  local _N_="${srv_uname}"
  local _G_="${srv_gname}"
  info "adding user \"${_N_}\""
  pw adduser -u "${_U_}" -n "${_N_}" -d "${_D_}" -w no -s /usr/local/bin/bash -G dialer 2>/tmp/err \
  || return 1
  install -d -m 775 -o "${_N_}" -g "${_G_}" -- "${_D_}"
  chown -R "${_N_}":"${_G_}" "${_D_}"
}


_config_warning() {
  echo -e " \n${orn} ${2} is not empty!\n"
  echo    " example configuration will not copied."
  echo -e " \"${1}\" may fail to start with invalid or missing configuration${end}\n"
  sleep 1
}

cp_config() {
  ## ONLY IF ${config_dir} == EMPTY, else nothing is copied.
  ## copy the example configuration files during an install.
  ## These files should be modified or replaced by end users
  srv_name="${1:-"${srv_name}"}"
  config_dir="${2:-"${srv_config_dir}"}"
  example_cfg="/usr/local/examples/${srv_name}/"
  debug "copy example config for ${srv_name}: ${config_dir}"
  
  # yaml = file containing plugin provided panel_iframes
  yaml="${homeassistant_config_dir}/packages/freenas_plugin.yaml"
  
  if [ ! -d "${config_dir}" ]; then
    install -d -g ${srv_uname} -o ${srv_uname} -m 775 -- "${config_dir}" || return
  fi
  
  case "${srv_name}" in
    
    ## Home Assistant Core
    "homeassistant")
      ## Copy the example Home Assistant Core configuration files
      if [ ! "$(ls -A ${config_dir})" ]; then
        cp -R "${example_cfg}" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${srv_uname}:${srv_uname} ${config_dir} && chmod -R g=u ${config_dir}
      else
       _config_warning "${srv_name}" "${config_dir}"
      fi
    ;;
    
    ## Hass-Configurator
    "configurator")
      ## Copy the example Hass-Configurator configuration file
      if [ ! "$(ls -A ${config_dir})" ]; then
        debug "copy ${srv_name} examples: cp -R "${example_cfg}" "${config_dir}""
        cp -R "${example_cfg}" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${srv_uname}:${srv_uname} ${config_dir} && chmod -R g=u ${config_dir}
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
          s%#url: http://0.0.0.0:3218%url: http://${v2srv_ip}:3218%" "${yaml}" > ${yaml}.temp && mv ${yaml}.temp ${yaml}
        chown -R ${srv_uname}:${srv_uname} "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;
    
    ## AppDaemon (includes HADashboard)
    "appdaemon")
      ## Copy the example AppDaemon configuration files
      if [ ! "$(ls -A ${config_dir})" ]; then
        debug "copy ${srv_name} examples: cp -R "${example_cfg}" "${config_dir}""
        cp -R "${example_cfg}" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${srv_uname}:${srv_uname} ${config_dir} && chmod -R g=u ${config_dir}
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
          s%#url: http://0.0.0.0:5050%url: http://${v2srv_ip}:5050%" "${yaml}" > ${yaml}.temp && mv ${yaml}.temp ${yaml}
        chown -R ${srv_uname}:${srv_uname} "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;

esac
}


install_service() {
  if [ ! -d ${srv_venv} ]; then
    info "creating virtualenv for \"${srv_name}\": ${srv_venv}"
    install -d -g ${srv_gname} -m 775 -o ${srv_uname} -- ${srv_venv} 2>/tmp/err \
    || err ${?} "$(</tmp/err)"
  elif [ ! -z "$(ls -A ${srv_venv})" ] && [ "${__name__}" = "post_install.sh" ]; then
  # TODO allow this function to pass if ${1} == ${srv_name}
    warn "${orn}virtualenv directory found and it's not empty!${end}"
    warn "${orn}please remove \"${srv_venv}\" and try again${end}"
    err 1 "${red}expecting empty directory${end} ${srv_venv}"
    exit
  else
    info "using existing directory for virtualenv: ${srv_venv}"
  fi
  su ${srv_uname} -c '
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
  ' _ ${srv_python} ${srv_venv} ${@} || err ${?} "$(</tmp/err)"
}

enableStart_v2srv () {
  chmod +x /usr/local/etc/rc.d/${srv_name}
  sysrc -f /etc/rc.conf ${srv_name}_enable=yes
  service ${srv_name} start
}

colors () {
  red=$'\e[1;31m'
  grn=$'\e[1;32m'
  yel=$'\e[1;33m'
  bl1=$'\e[1;34m'
  mag=$'\e[1;35m'
  cyn=$'\e[1;36m'
  blu=$'\e[38;5;39m'
  orn=$'\e[38;5;208m'
  end=$'\e[0m'
}

__script__="${0}"
__name__="$(basename ${__script__})"

install -m 666 -- /dev/null "/tmp/err"
colors

v2srv_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

#case "${__name__}" in
if [ "${__name__}" == "post_install.sh" ] && [ -z "${1}" ]; then
#  "post_install.sh")
    ## WARNING Running this script, `post_install.sh` ( with NO_ARGS ), is intended for the initial installation only
    ## Install the Home Assistant Core -- Community  Plugin (iocage) -- Tested on FreeNAS 11.3 / TrueNAS Core 12.x
#    rc_debug="ON"
    add_user || err 1 "$(</tmp/err)"
    sysrc plugin_ver="${plugin_ver}"
    sysrc plugin_ini="${plugin_ver}_$(date +%Y%m%d)"
    set_rc_vars
    cp_config ${srv_name}
    service ${srv_name} install ${srv_name} || err 1 "return $?"
    service ${srv_name} config --check
    enableStart_v2srv
    ## WARNING Running the initial installation multiple times, will result in multiple entries to launch the menu
    ## Start the console menu upon login
    echo -e "\n# Start console menu after login." >> /root/.login
    echo "if ( -x /root/bin/menu ) menu" >> /root/.login
    ## TODO Add someting useful to this
    echo "useful information coming soon!" > /root/PLUGIN_INFO
    exit "${?}"
#  ;;
elif [ "${__name__}" == "homeassistant" ] || [ "${1}" == "homeassistant" ]; then
#  "homeassistant")
    srv_name="homeassistant"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
    install_service ${srv_name} || exit
    set_rc_vars
    cp_config ${srv_name}
    enableStart_v2srv || exit
    echo -e "\n ${grn}http://${v2srv_ip}:8123${end}\n"
    echo -e "${orn}Initial startup can take several minutes before Home Assistant is fully loaded${end}\n"
    exit "${?}"
#  ;;
elif [ "${__name__}" == "appdaemon" ] || [ "${1}" == "appdaemon" ]; then
#  "appdaemon")
    srv_name="appdaemon"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
#     srv_prefix="${plugin_srv_prefix:-"/usr/local/share"}"
    srv_enable="${appdaemon_enable:-"yes"}"
    srv_umask="${appdaemon_umask:-"002"}"
    # USER / GROUP to run the appdaemon daemon
    srv_uname="${appdaemon_user:-"homeassistant"}"
    srv_gname="${appdaemon_group:-"homeassistant"}"
    # user_dir is HOME and PARENT_DIR to SERVICE configuration
    srv_uhome="${appdaemon_user_dir:-"/home/homeassistant"}"
    # locatation for appdaemon confiuragtion files
    srv_config_dir="${appdaemon_config_dir:-"/home/homeassistant/appdaemon"}"
    # path to python version to use for the virtualenv
    srv_python="${appdaemon_python:-"/usr/local/bin/python3.8"}"
    # full path to the python virtualenv for appdaemon
    srv_venv="${appdaemon_venv:-"${srv_prefix}/${srv_name}"}"
    # TODO TN > service ${srv_name} install ${srv_name} || err 1 "return $?"
    install_service ${srv_name} || exit
    set_rc_vars
    cp_config ${srv_name}
    enableStart_v2srv || exit
    echo -e "\n ${grn}http://${v2srv_ip}:5050${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    exit "${?}"
#  ;;
elif [ "${__name__}" == "configurator" ] || [ "${1}" == "configurator" ]; then
#  "configurator")
    srv_name="configurator"
    info "service \"${__name__}\" has called post_install.sh ${srv_name}"
#     srv_prefix="${plugin_srv_prefix:-"/usr/local/share"}"
    srv_enable="${configurator_enable:-"yes"}"
    srv_umask="${configurator_umask:-"002"}"
    # USER / GROUP to run the configurator daemon
    srv_uname="${configurator_user:-"homeassistant"}"
    srv_gname="${configurator_group:-"homeassistant"}"
    # user_dir is HOME and PARENT_DIR to SERVICE configuration
    srv_uhome="${configurator_user_dir:-"/home/homeassistant"}"
    # locatation for configurator confiuragtion files
    srv_config_dir="${configurator_config_dir:-"/home/homeassistant/configurator"}"
    # path to python version to use for the virtualenv
    srv_python="${configurator_python:-"/usr/local/bin/python3.8"}"
    # full path to the python virtualenv for configurator
    srv_venv="${configurator_venv:-"${srv_prefix}/${srv_name}"}"
    # TODO TN > service ${srv_name} install ${srv_name} || err 1 "return $?"
    install_service ${srv_name} || exit
    set_rc_vars
    cp_config ${srv_name}
    enableStart_v2srv \
    || exit
    echo -e "\n ${grn}http://${v2srv_ip}:3218${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    exit "${?}"
#  ;;
elif [ "${__name__}" == "plugin" ]; then
#  "plugin")
    ## "plugin" is generic name to test"
    info " -- MOCK SERVICE ONLY -- "
    rc_debug="ON"
    echo "debug should on"
    debug "TEST: ${__name__}"
    exit "${?}"
#  ;;
else
#  *)
    warn "service \"${__name__}\" has called post_install.sh"
    debug " script: ${__script__}"
    debug " name: ${__name__}"
    debug " args: ${@}"
    err 1 "Finished with nothing to do!"
#  ;;
fi
#esac
echo -e "\nYOU SHOULDN'T BE HERE\n"
exit 1
