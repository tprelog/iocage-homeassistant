#!/bin/bash

  # pkg install bash ca_root_nss git gmake python36 py-sqlite3 screen wget
  # git clone https://github.com/tprelog/iocage-homeassistant.git /root/.iocage-homeassistant
  # bash /root/.iocage-homeassistant/post_install.sh standard

v2srv_user=hass     # Changing this is not tested and will likely break something
v2srv_uid=8123      # Changing this is not tested but should be OK

# ------------------------------------------------------------------------------------------------------------------------------------------- ,
# ------------------------------------------------------------------------------------------------------------------------------------------- ,

ha=1  # homeassistant       ##  [ NOTHING = 0 ]
ex=0  # example files       ##  [ INSTALL = 1 ]
ad=0  # appdaemon           ##  [ UPGRADE = 2 ]
cf=0  # configurator

action=   #|--
v2srv=    #|-These should be blank
mode=     #|--

plugin=YES # NOTE `post_install.sh standard` will set 'plugin=NO'

script="${0}"
ctrl="$(basename "${0}" .sh)"

v2srv_ip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

first_run () {      # This is the main function to setup homeassistant jail
  
  mode=1
  action=Installing
  
  if [ "${plugin}" = "NO" ]; then
    question  # Ask what to install
    cp /root/.iocage-homeassistant/overlay/etc/motd /etc/motd
  fi

  pip_pip   # Required for this script to work
  add_user  # Required for this script to work

  sed "s/^umask.*/umask 2/g" .cshrc > .cshrcTemp && mv .cshrcTemp .cshrc
  
  mkdir -p /root/bin                    #|- These are like an alais BUT they will also work
  ln -s ${0} /root/bin/menu-install     #|- using `iocage exec ${JAIL} update
  ln -s ${0} /root/bin/menu-update      #|- Different names are like using arguments
  ln -s ${0} /root/bin/update           #|- `iocage exec ${JAIL} /root/post_install.sh update'
                                        
    
  if [ $ex = 1 ]; then
   cp_examples
  fi
  if [ $ha = 1 ]; then
   v2srv=homeassistant
   v2srv_action; sleep 1
  fi
  if [ $ad = 1 ]; then
   v2srv=appdaemon
   v2srv_action; sleep 1
  fi
  if [ $cf = 1 ]; then
   v2srv=configurator
   configurator_action; sleep 1
  fi
  if [ "${plugin}" = "NO" ]; then
    end_report
  fi
}

question () {       # What should first_run install
    echo
  prompt_yes ${cyn}"Install Home Assistant? "${end}
    if [ "$ANSWER" = "Y" ]; then
      ha=1
    fi
  prompt_yes ${cyn}"Install Hass Configurator? "${end}
    if [ "$ANSWER" = "Y" ]; then
      cf=1
    fi
  prompt_yes ${cyn}"App-Daemon & HA-Dashboard? "${end}
    if [ "$ANSWER" = "Y" ]; then
      ad=1
    fi
  prompt_yes ${cyn}"Use the pre-configured examples? "${end}
    if [ "$ANSWER" = "Y" ]; then
      ex=1
    fi
}

pip_pip () {
  python3.6 -m ensurepip
  pip3 install --upgrade pip
  pip3 install --upgrade virtualenv
}

add_user () {
  install -d -g ${v2srv_uid} -o ${v2srv_uid} -m 775 -- /home/${v2srv_user}
  pw addgroup -g ${v2srv_uid} -n ${v2srv_user}
  pw adduser -u ${v2srv_uid} -n ${v2srv_user} -d /home/${v2srv_user} -w no -s /usr/local/bin/bash -G dialer -c "Daemon for homeassistant jail"
}

v2srv_action () {
    if [ ${mode} = 1 ]; then
      install -d -g ${v2srv_user} -o ${v2srv_user} -m 775 -- /srv/${v2srv} || exit
    elif [ ${mode} = 2 ] || [ ${mode} = 3 ]; then
      service ${v2srv} stop; sleep 1
    else
      echo ${red} "Missing Valid Action! [${mode}]" ${end}; exit
    fi  
  screen -dmS scrn_env su - hass -c "bash "${script}" "${v2srv}-virt-${mode}"";sleep 1
  screen -r scrn_env || exit
    if [ ${mode} = 1 ]; then
      enableStart_v2srv
    elif [ ${mode} = 2 ] || [ ${mode} = 3 ]; then
      service ${v2srv} start; sleep 1
    else
      echo ${red} "INVAILD: Service not set! [${mode}]" ${end}; exit
    fi  
}

v2env_action () {
    if [ ${mode} = 1 ]; then
      action=Installing
    elif [ ${mode} = 2 ] || [ ${mode} = 3 ]; then
      action=Upgrading
    else
      echo ${red} "Invalid Mode! [${mode}]" ${end}; exit
    fi
  echo "${grn} ${action} ${v2srv} virtualenv for user `whoami` ${end}"; echo
  sleep 3 # sleep 2 so we check we're the right person above
    if [ ${mode} = 1 ]; then
      virtualenv -p /usr/local/bin/python3.6 /srv/${v2srv} || exit
    fi
  source /srv/${v2srv}/bin/activate || exit
    if [ ${mode} = 3 ]; then
     pip3 install --upgrade pip
    fi
  pip3 install --upgrade ${v2srv}
  deactivate && exit
}

configurator_action () {                # Install or Update The HASS Configurator
  # v2srv=configurator
    echo; echo "${action} the ${v2srv}"; echo; sleep 2
    if [ ${mode} = 1 ]; then
      install -d -g ${v2srv_user} -o ${v2srv_user} -m 775 -- /srv/${v2srv} || exit
    elif [ ${mode} = 2 ]; then
      service ${v2srv} stop; sleep 1
    else
      echo ${red} "Missing Valid Action! [${mode}]" ${end}; exit
    fi
  wget -O /srv/${v2srv}/configurator.py https://raw.githubusercontent.com/danielperna84/hass-configurator/master/configurator.py
  chmod +x /srv/${v2srv}/configurator.py
    if [ ${mode} = 1 ]; then
      enableStart_v2srv
    elif [ ${mode} = 2 ]; then
      service ${v2srv} start; sleep 1
    else
      echo "${red} INVAILD: Service not set! ["${mode}"] ${end}"; exit
    fi
}

enableStart_v2srv () {  
  rcd=/usr/local/etc/rc.d
    if [ ! -d "${rcd}" ]; then
        mkdir -p ${rcd}
    fi
    if [ ! -f "${rcd}/${v2srv}" ]; then
        cp -n /root/.iocage-homeassistant/overlay/${rcd}/${v2srv} ${rcd}/${v2srv}
    fi
  chmod +x ${rcd}/${v2srv}
  sysrc -f /etc/rc.conf ${v2srv}_enable=yes
  service ${v2srv} start; sleep 1
}

cp_examples () {                             # Copy sample config files
  yaml=/home/${v2srv_user}/homeassistant/configuration.yaml
  if [ $ha = 1 ]; then
    if [ ! -f "${yaml}" ]; then
        cp -R /root/.iocage-homeassistant/example/config/homeassistant /home/${v2srv_user}/homeassistant
    else
        echo "${red} ha | example copy skip - file exists! ${end}"
    fi
  fi
  if [ $ad = 1 ]; then
    if [ ! -f  /home/${v2srv_user}/appdaemon/conf/appdaemon.yaml ]; then
        cp -R /root/.iocage-homeassistant/example/config/appdaemon /home/${v2srv_user}/appdaemon
        chown -R ${v2srv_user}:${v2srv_user} /home/${v2srv_user}/appdaemon && chmod -R g=u /home/${v2srv_user}/appdaemon
        sed -e "s/#panel_iframe:/panel_iframe:/
            s/#hadashboard:/hadashboard:/
            s/#title: HA Dashboard/title: HA Dashboard/
            s/#icon: mdi:view-dashboard-variant/icon: mdi:view-dashboard-variant/
            s%#url: http://0.0.0.0:5050%url: http://${v2srv_ip}:5050% " ${yaml} > ${yaml}.temp && mv ${yaml}.temp ${yaml}
     else
        echo "${red} ad | example copy skip - file exists!${end}"
     fi     
  fi
  if [ $cf = 1 ]; then
    if [ -f /home/${v2srv_user}/configurator/configurator.conf ]; then
        echo "${red} cf | example copy rename - file exists!${end}"
        cp -i  /home/${v2srv_user}/configurator/configurator.conf /home/${v2srv_user}/configurator/configurator.conf.old
    fi
    cp -R /root/.iocage-homeassistant/example/config/configurator /home/${v2srv_user}/configurator
    chown -R ${v2srv_user}:${v2srv_user} /home/${v2srv_user}/configurator && chmod -R g=u /home/${v2srv_user}/configurator
    sed -e "s/#panel_iframe:/panel_iframe:/
        s/#configurator:/configurator:/
        s/#title: Configurator/title: Configurator/
        s/#icon: mdi:circle-edit-outline/icon: mdi:circle-edit-outline/
        s%#url: http://0.0.0.0:3218%url: http://${v2srv_ip}:3218% " ${yaml} > ${yaml}.temp && mv ${yaml}.temp ${yaml}
  fi
  find /home/${v2srv_user} -type f -name ".empty" -depth -exec rm -f {} \;
  chown -R ${v2srv_user}:${v2srv_user} /home/${v2srv_user}/homeassistant && chmod -R g=u /home/${v2srv_user}/homeassistant
}

prompt_yes () {     # prompt [YES|no] "default yes"  
  while true; do
    read -r -p "${1} [Y/n]: " REPLY
    case $REPLY in
      [qQ]) echo ; echo "Goodbye!"; exit ;;
      [yY]|[yY][eE][sS]|"") echo ; ANSWER=Y ; return ;;
      [nN]|[nN][oO]) echo ; ANSWER=N ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" " ! Invalid Input Received"
    esac
  done
}

prompt_no () {     # prompt [yes|NO] "default no"  
  while true; do
    read -r -p "${1} [y/N]: " REPLY
    case $REPLY in
      [qQ]) echo ; echo "Goodbye!"; exit ;;
      [yY]|[yY][eE][sS]) echo ; ANSWER=Y ; return ;;
      [nN]|[nN][oO]|"") echo ; ANSWER=N ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" " ! Invalid Input Received"
    esac
  done
}

colors () {         # Define Some Colors for Messages
  red=$'\e[1;31m'
  grn=$'\e[1;32m'
  yel=$'\e[1;33m'
  blu=$'\e[1;34m'
  mag=$'\e[1;35m'
  cyn=$'\e[1;36m'
  end=$'\e[0m'
}
colors

end_report () {     # Status
  echo; echo; echo; echo
    echo " ${blu}Status Report: ${end}"; echo
    echo "      $(service appdaemon status)"
    echo "  $(service homeassistant status)"
    echo "   $(service configurator status)"
   echo   
    echo " ${cyn}Home Assistant${end}: ${grn}http://${v2srv_ip}:8123${end}"
    echo "   ${cyn}HA Dashboard${end}: ${grn}http://${v2srv_ip}:5050${end}"
    echo "   ${cyn}Configurator${end}: ${grn}http://${v2srv_ip}:3218${end}"
   echo; echo
}

case $@ in
  appdaemon-virt-*)
    mode=$(echo $@ | cut -d'-' -f3)
    v2srv=$(echo $@ | cut -d'-' -f1)
    v2env_action
    ;;
  homeassistant-virt-*)
    mode=$(echo $@ | cut -d'-' -f3)
    v2srv=$(echo $@ | cut -d'-' -f1)
    v2env_action
    ;;
esac

if [ "${ctrl}" = "post_install" ]; then

    if [ "${ctrl}" = "post_install" ] && [ -z "${1}" ]; then
        first_run
        echo "Initial Startup Can Take 1-2 Minutes Before Home-Assistant is Reachable" 
        exit
    elif [ "${ctrl}" = "post_install" ] &&  [ "${1}" = "standard" ]; then
        plugin=NO
        first_run
        echo "Initial Startup Can Take 1-2 Minutes Before Home-Assistant is Reachable"
        exit
    else
        echo "${red}!! post_install.sh !!${end}"
        echo "script: ${script} "
        echo "crtl name: ${ctrl} "
        echo "arguments: ${@} "
    fi
    
fi

# ------------------ BELOW THIS LINE IS CODE FOR A "SATNDARD JAIL INSTALL" ------------------------------------------------------------------ ,

upgrade_menu () {
  action=Upgrading
  while true; do
    echo
    mode=2
    PS3="${cyn} Enter Number to Upgrade${end}: "
    select OPT in "Home Assistant" "App Daemon" "Configurator" "FreeBSD" "Status" "Exit"
    do
      case ${OPT} in
        "Home Assistant")
          v2srv=homeassistant
            prompt_no "Upgrade PiP First? "
              if [ "$ANSWER" = "Y" ]; then
                mode=3
              fi
          v2srv_action; sleep 1; break
          ;;
        "App Daemon")
          v2srv=appdaemon
            prompt_no "Upgrade PiP First? "
              if [ "$ANSWER" = "Y" ]; then
                mode=3
              fi
          v2srv_action; sleep 1; break
          ;;
        "Configurator")
          v2srv=configurator
          ${v2srv}_action; sleep 1; break
          ;;
        "Status")
          end_report; break
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

install_menu () {    # NOT COMPLETE - "THIS ONLY PRINTS (echo) MESSAGES"
  action=Installing
  while true; do
    echo
    mode=1
    PS3="${mag} Enter Number to Install${end}: "
    select OPT in "Home Assistant" "App Daemon" "Configurator" "Exit"
    do
      case "${OPT}" in
        "Home Assistant")
           v2srv=homeassistant
            prompt_no " ! deleting zpool ! "                     # JK
              if [ "$ANSWER" = "Y" ]; then
                mode=3
              fi
          #v2srv_action; sleep 1; break
          echo "${red}WHATEVER${end}..."; sleep 1                # JK
          echo "${red}DELETING ANYWAYS!${end}"; sleep 1; break   # JK    
          ;;
        "App Daemon")
           v2srv=appdaemon
            prompt_yes " ! kittens will be eaten if you continue ! "
              if [ "$ANSWER" = "Y" ]; then
                mode=3
              fi
          #v2srv_action; sleep 1; break
          echo " ${mag}Cat... The other, other white meat${end}"; sleep 1; break
          ;;
        "Configurator")
          v2srv=configurator
          #${v2srv}_action; sleep 1; break
          echo "${mag}In the future this menu will actually install things${end}"; sleep 1; break
          ;;
        "Exit")
          echo ${grn} "Goodbye!" ${end}
          exit
          ;;
      esac
    done
  done
}

case $@ in
  "install")
    install_menu
    ;;
  "update")
    upgrade_menu
    ;;
  "refresh")
    git -C /root/.iocage-homeassistant/ pull
    echo "Please restart this script"
    exit
    ;;
esac

if [ "${ctrl}" = "menu-update" ] || [ "${ctrl}" = "update" ]; then
    script="$(realpath "$BASH_SOURCE")"
    upgrade_menu
elif [ "${ctrl}" = "menu-install" ]; then
    script="$(realpath "$BASH_SOURCE")"
    install_menu
else
    echo "${red}! Finished with Nothing To Do !${end}"
    echo "script: ${script} "
    echo "crtl name: ${ctrl} "
    echo "arguments: ${@} "
fi
