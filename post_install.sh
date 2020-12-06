#!/usr/bin/env bash
# plugin version 5.0

plugin_version="5.0.$(date +%Y%m%d)"
sysrc plugin_initialized="${plugin_version}"
sysrc plugin_version="${plugin_version}"

## Who will run the jail's primary service, Home Assistant Core
## If installed, optional services will also be run as this user
service_port="8123"           # service_port == UID
service_name="homeassistant"  # service_name == username
service_home="/home/${service_name}"
service_config="${service_home}/${service_name}"

## Which version of Python to use
service_python="python3.8"

## Add the service_name user and install a service_config directory. Creates service_home in the process
pw adduser -u "${service_port}" -n "${service_name}" -d "${service_home}" -w no -s /usr/local/bin/bash -G dialer
install -d -m 775 -o "${service_name}" -g "${service_name}" -- "${service_config}"

## Configure the jail's primary service using rcvars
sysrc ${service_name}_umask="002"
sysrc ${service_name}_user="${service_name}"
sysrc ${service_name}_group="${service_name}"
sysrc ${service_name}_config_dir="${service_config}"
sysrc ${service_name}_python="$(which ${service_python})"
sysrc ${service_name}_venv="/usr/local/share/${service_name}"

## Provide the example configuration files for the jail's primary service
cp -R "/usr/local/examples/${service_name}/" "${service_config}"
find "${service_config}" -type f -name ".empty" -depth -exec rm -f {} \;
chown -R "${service_name}":"${service_name}" "${service_home}" && chmod -R g=u "${service_home}"

## Install the jail's primary service, Home Assistant Core
service "${service_name}" oneinstall "${service_name}" || exit 1

## Enable and start the Home Assistant Core service
chmod +x "/usr/local/etc/rc.d/${service_name}"
sysrc -f /etc/rc.conf ${service_name}_enable="YES"
service "${service_name}" start

## Start the console menu, upon login as user "root"
echo -e "\n# Start console menu after login." >> /root/.login
echo "if ( -x /root/bin/menu ) menu" >> /root/.login

## TODO Add someting useful to PLUGIN_INFO
echo "version: ${plugin_version}" > /root/PLUGIN_INFO
echo -e "\nInitial startup can take 5-10 minutes before Home Assistant is reachable." >> /root/PLUGIN_INFO
echo -e " Please see the wiki for more information\n" >> /root/PLUGIN_INFO
