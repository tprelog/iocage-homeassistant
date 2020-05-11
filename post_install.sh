#!/usr/bin/env bash

  # pkg install autoconf bash ca_root_nss git-lite gmake pkgconf python37 py37-sqlite3
  # git clone -b 11.3-RELEASE https://github.com/tprelog/iocage-homeassistant.git /root/.iocage-homeassistant
  # bash /root/.iocage-homeassistant/post_install.sh standard

v2srv_user=hass     # Changing this is not tested
v2srv_uid=8123      # Changing this is not tested but should be OK
v2env=/srv          # Changing this is not tested

pkglist=/root/pkg_extra
python=python3.7

v2srv_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
plugin_overlay="/root/.iocage-homeassistant/overlay"   # Used for `post_install.sh standard`

script="${0}"
ctrl="$(basename "${0}" .sh)"

first_run () {
  
  ## Install these extra packages not required by the Home Assistant Core install.
  ## However THESE EXTRAS PACKAGES ARE REQUIRED TO USE SOME BUILD IN COMPONENTS
  #[ -f "${pkglist}" ] && pkgs=$(cat "${pkglist}" | grep -v '^[#;]' | grep .) \
  #&& [ ! -z "${pkgs}" ] && echo "${pkgs}" | xargs pkg install -y
  
  sed "s/^umask.*/umask 2/g" .cshrc > .cshrcTemp && mv .cshrcTemp .cshrc
  echo -e "\n# Start hassbsd (console menu) after login." >> /root/.login
  echo "if ( -x /root/bin/hassbsd ) hassbsd" >> /root/.login
  
  add_user
  v2srv=homeassistant
  cp_config "${v2srv}"
  install_service
}

add_user () {
  install -d -g ${v2srv_uid} -o ${v2srv_uid} -m 775 -- /home/${v2srv_user}
  pw addgroup -g ${v2srv_uid} -n ${v2srv_user}
  pw adduser -u ${v2srv_uid} -n ${v2srv_user} -d /home/${v2srv_user} -w no -s /usr/local/bin/bash -G dialer
  ## This is a workaround to hopefully avoid pip related "/.cache" permission errors
  install -d -g ${v2srv_uid} -o ${v2srv_uid} -m 700 -- /home/${v2srv_user}/.cache
  install -l s -g ${v2srv_uid} -o ${v2srv_uid} -m 700 /home/${v2srv_user}/.cache /.cache
}

install_service() {
  d="${v2env}/${v2srv}"
  p=$(which ${python})
  
  if [ ! -d ${d} ]; then
    install -d -g ${v2srv_user} -o ${v2srv_user} -m 775 -- ${d} || exit
  elif [ ! -z "$(ls -A ${d})" ]; then  
    echo -e "${red}\nvirtualenv directory found and it's not empty!\n${orn} Is ${v2srv} already installed?"
    echo -e " You can remove ${d} and try again${end}\n"
    exit
  fi
  
  su ${v2srv_user} -c '
    ${1} -m venv ${2}
    source ${2}/bin/activate || exit 1
    pip3 install --upgrade pip
    
    if [ ${3} = "homeassistant" ]; then
      ## Install Home Assistant

      ## Workaround Invaild Config ( HA 0.107.x )
      pip3 install --upgrade SQLAlchemy

      pip3 install --upgrade colorlog
      pip3 install --upgrade ${3}
      
      ## Known issue in version 0.101.X -- Ensure the front-end gets installed
      if [ $(pip3 show homeassistant | grep Version | cut -d'.' -f2) = 101 ]; then
        pip3 install --upgrade home-assistant-frontend
      fi
      
    elif [ ${3} = "appdaemon" ]; then
      ## Install appdaemon
      pip3 install astral==1.10
      pip3 install --upgrade ${3}
      
    elif [ ${3} = "configurator" ]; then
      ## Install Hass Configurator
      pip3 install --upgrade hass-configurator
    
    elif [ ${3} = "esphome" ]; then
      ## Install esphome
      pip3 install --upgrade ${3}
      
      ## Download and install extra files needed for esp32 support on *BSD
      ## Thanks @CyanoFresh for figuring this out! (link below)
      ## https://github.com/tprelog/iocage-homeassistant/issues/5#issuecomment-573179387
      pkg=toolchain-xtensa32-FreeBSD.11.amd64-2.50200.80.tar.gz
      wget -O /tmp/${pkg} https://github.com/trombik/toolchain-xtensa32/releases/download/0.2.0/${pkg}
      mkdir -p ~/esphome/.platformio/packages/toolchain-xtensa32
      tar -x -C ~/esphome/.platformio/packages/toolchain-xtensa32 -f /tmp/${pkg}
      
    else
      pip3 install --upgrade ${3}
    fi
    deactivate
  ' _ ${p} ${d} ${v2srv} && enableStart_v2srv
}

enableStart_v2srv () {
  chmod +x /usr/local/etc/rc.d/${v2srv}
  sysrc -f /etc/rc.conf ${v2srv}_enable=yes
  service ${v2srv} start; sleep 1
}

cp_overlay() {
  ## This function is used for `post_install standard`
  mkdir -p /root/bin
  ln -s ${0} /root/bin/update
  ln -s ${0} /root/post_install.sh
  ln -s ${plugin_overlay}/root/.hass_overlay /root/.hass_overlay
  ln -s ${plugin_overlay}/root/bin/hassbsd /root/bin/hassbsd
  
  mkdir -p /usr/local/etc/rc.d
  mkdir -p /usr/local/etc/sudoers.d
  cp -R ${plugin_overlay}/usr/local/etc/ /usr/local/etc/
  #cp ${plugin_overlay}/etc/motd /etc/motd
  #chmod -R +x /usr/local/etc/rc.d/
}

cp_config() {
  
  ## ONLY IF ${config_dir} IS EMPTY else nothing is copied.
  ## copy the example configuration files during an install.
  ## These files should be modified or replaced by end users
  
  v2srv=$1
  hass_overlay="/root/.hass_overlay"
  ha_confd="/home/${v2srv_user}/homeassistant"
  
  # yaml = file containing plugin provided panel_iframes
  yaml="${ha_confd}/packages/freenas_plugin.yaml"
  
  config_dir="/home/${v2srv_user}/${v2srv}"
  if [ ! -d "${config_dir}" ]; then
    install -d -g ${v2srv_user} -o ${v2srv_user} -m 775 -- "${config_dir}" || return
  fi
  
  case $1 in
    
    ## Home Assistant
    "homeassistant")
      ## Copy the example Home Assistant configuration files
      if [ ! "$(ls -A ${config_dir})" ]; then
        cp -R "${hass_overlay}/${1}/" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${v2srv_user}:${v2srv_user} ${config_dir} && chmod -R g=u ${config_dir}
      else
       _config_warning "${1}"
      fi
    ;;
    
    ## Hass-Configurator
    "configurator")
      ## Copy the example Hass-Configurator configuration file
      if [ ! "$(ls -A ${config_dir})" ]; then
        cp -R "${hass_overlay}/${1}/" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${v2srv_user}:${v2srv_user} ${config_dir} && chmod -R g=u ${config_dir}
      else
        _config_warning "${1}"
      fi
      # Enable the Hass-Configurator iframe
      if [ -f "${yaml}" ]; then
        sed -e "s/#panel_iframe:/panel_iframe:/
          s/#configurator:/configurator:/
          s/#title: Configurator/title: Configurator/
          s/#icon: mdi:wrench/icon: mdi:wrench/
          s/#require_admin: true/require_admin: true/
          s%#url: http://0.0.0.0:3218%url: http://${v2srv_ip}:3218%" "${yaml}" > ${yaml}.temp && mv ${yaml}.temp ${yaml}
        chown -R ${v2srv_user}:${v2srv_user} "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;
    
    ## AppDaemon (includes HADashboard)
    "appdaemon")
      ## Copy the example AppDaemon configuration files
      if [ ! "$(ls -A ${config_dir})" ]; then
        cp -R "${hass_overlay}/${1}/" "${config_dir}"
        find ${config_dir} -type f -name ".empty" -depth -exec rm -f {} \;
        chown -R ${v2srv_user}:${v2srv_user} ${config_dir} && chmod -R g=u ${config_dir}
      else
        _config_warning "${1}"
      fi
      # Enable the AppDaemon iframe
      if [ -f "${yaml}" ]; then
        sed -e "s/#panel_iframe:/panel_iframe:/
          s/#appdaemon:/appdaemon:/
          s/#title: AppDaemon/title: AppDaemon/
          s/#icon: mdi:view-dashboard-variant/icon: mdi:view-dashboard-variant/
          s/#require_admin: false/require_admin: true/
          s%#url: http://0.0.0.0:5050%url: http://${v2srv_ip}:5050%" "${yaml}" > ${yaml}.temp && mv ${yaml}.temp ${yaml}
        chown -R ${v2srv_user}:${v2srv_user} "${yaml}"; chmod -R g=u "${yaml}"
      fi
    ;;
    
    ## ESPHome
    "esphome")
      ## This is a workaround to avoid "/.platformio" permission errors
      install -d -g ${v2srv_uid} -o ${v2srv_uid} -m 700 -- /home/${v2srv_user}/esphome/.platformio
      install -l s -g ${v2srv_uid} -o ${v2srv_uid} -m 700 /home/${v2srv_user}/esphome/.platformio /.platformio
    ;;
    
  esac
}

_config_warning() {
  ## called by cp_config function
  echo -e " \n${red}${config_dir} is not empty!\n"
  echo    " ${yel}Example configuration files not copied."
  echo -e " ${1} service may fail to start with invalid or missing configuration${end}\n"
  sleep 1
}

colors () {         # Define Some Colors for Messages
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
colors

if [ "${ctrl}" = "post_install" ]; then
  
  if [ -z "${1}" ]; then
    # Install Home Assistant in a plugin-jail
    first_run
    echo -e "\n Initial startup can take 5-10 minutes before Home Assistant is reachable."
    echo "Initial startup can take 5-10 minutes before Home Assistant is reachable." > /root/PLUGIN_INFO
    
  elif [ "${1}" = "standard" ]; then
    # Install Home Assistant in a standard-jail
    cp_overlay || exit 1
    first_run || exit 1
    service ${v2srv} status && \
    echo -e "\n ${grn}http://${v2srv_ip}:8123${end}\n"
    echo -e "${red}Initial startup can take 5-10 minutes before Home Assistant is reachable${end}\n"
    
  elif [ "${1}" = "hass-configurator" ] || [ "${1}" = "configurator" ]; then
  # This should have some basic testing. Start by determining if the directory
  # already exist then figure how to proceed. For now this will show a message and exit.
    v2srv=configurator
    cp_config ${v2srv}
    install_service && echo; service ${v2srv} status && \
    echo -e "\n ${grn}http://${v2srv_ip}:3218${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    
  elif [ "${1}" = "appdaemon" ]; then
  # This should have some basic testing. Start by determining if the directory
  # already exist then figure how to proceed. For now this will show a message and exit.
    v2srv=appdaemon
    cp_config ${v2srv}
    install_service && echo; service ${v2srv} status && \
    echo -e "\n ${grn}http://${v2srv_ip}:5050${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    
  elif [ "${1}" = "esphome" ]; then
  # This should have some basic testing. Start by determining if the directory
  # already exist then figure how to proceed. For now this will show a message and exit.
    pkg install -y gcc wget || exit
    v2srv=esphome
    cp_config ${v2srv}
    install_service && echo; service ${v2srv} status && \
    ln -s /srv/esphome/bin/esphome /usr/local/bin/esphome && \
    echo -e "\n ${grn}http://${v2srv_ip}:6052${end}\n"
    echo -e "You may need to restart Home Assistant for all changes to take effect\n"
    
  elif [ "${1}" = "hacs" ]; then
  # This should just download the latest version of HACS and extract it to 'homeassistant/custom_components/'
    [ -d "/home/${v2srv_user}/homeassistant/custom_components/hacs" ] && echo "${red}Is HACS already installed?${end}" && exit
    pkg install -y wget zip || exit
    su - ${v2srv_user} -c '
      wget -O /var/tmp/hacs.zip https://github.com/hacs/integration/releases/latest/download/hacs.zip \
      && unzip -d homeassistant/custom_components/hacs /var/tmp/hacs.zip
    ' _ || exit 1
    echo -e "\n${red} !! RESTART HOME ASSISTANT BEFORE THE NEXT STEP !!"
    echo -e "${grn}     https://hacs.xyz/docs/configuration/start${end}\n"
    
  else
    echo "${red}post_install.sh - Nothing to do.${end}"
    echo " script: ${script}"
    echo " crtl name: ${ctrl}"
    echo " arguments: ${@}"
  fi
  
  exit
fi

# -------- BELOW THIS LINE IS CODE FOR A "SATNDARD JAIL INSTALL" ----------------- ,

upgrade_menu () {
  while true; do
    echo
    PS3="${cyn} Enter Number to Upgrade${end}: "
    select OPT in "Home Assistant" "App Daemon" "Configurator" "FreeBSD" "Exit"
    do
      case ${OPT} in
        "Home Assistant")
          service homeassistant upgrade; break
          ;;
        "App Daemon")
          service appdaemon upgrade; break
          ;;
        "Configurator")
          service configurator upgrade; break
          ;;
        "FreeBSD")
          pkg update && pkg upgrade; break
          ;;
        "Exit")
          exit
          ;;
      esac
    done
  done
}

case $@ in
  "update")
    upgrade_menu
    ;;
  "refresh")
    git -C /root/.iocage-homeassistant/ pull
    echo "Please restart this script"
    exit
    ;;
esac

if [ "${ctrl}" = "update" ]; then
    script="$(realpath "$BASH_SOURCE")"
    upgrade_menu
else
    echo "${red}! Finished with Nothing To Do !${end}"
    echo "script: ${script} "
    echo "crtl name: ${ctrl} "
    echo "arguments: ${@} "
fi
