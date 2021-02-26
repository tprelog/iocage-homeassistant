#!/usr/bin/env bash

version="$(cat /root/.PLUGIN_VERSION)"
sysrc plugin_initialized="${version}"
sysrc plugin_version="${version}"

## Who will run the jail's primary service, Home Assistant Core
## Typically, the username is similar to the name of the service
## Also, the UID usually matches the service's default port ---
## If installed, optional services will also be run as this user
service_port="8123"           # UID == service_port
service_name="homeassistant"  # username == service_name
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
/root/.plugin/bin/get-pip-required "${service_name}" \
&& service "${service_name}" oneinstall "${service_name}" \
  -r "/root/.plugin/pip/requirements.${service_name}" || exit 1

## Enable and start the Home Assistant Core service
chmod +x "/usr/local/etc/rc.d/${service_name}"
sysrc -f /etc/rc.conf ${service_name}_enable="YES"
service "${service_name}" start

# shellcheck disable=SC1073,2016
{ echo -e '\nset path = (${path} /root/.plugin/bin)\n' ; \
  echo -e "\n# Start console menu after login." ; \
  echo "if ( -x /root/.plugin/bin/menu ) menu" ; } >> /root/.login

## Gererate PLUGIN_INFO
/root/.plugin/bin/plugin-info
