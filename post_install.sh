#!/usr/bin/env bash

version="$(cat /root/.PLUGIN_VERSION)"
sysrc plugin_initialized="${version}"
sysrc plugin_version="${version}"

## Set a supported version of Python for Home Assistant Core
service_python="python3.10"

## Who will run the jail's primary & optional services
## Here the username is similar to the name of the primary service
## Also the UID is set to match the service's default port
service_port="8123"
service_name="homeassistant"
service_home="/home/${service_name}"
service_config="${service_home}/${service_name}"

## Add the service_name user and install a service_config directory. Creates service_home in the process
pw adduser -u "${service_port}" -n "${service_name}" -d "${service_home}" -w no -s /usr/local/bin/bash -G dialer
install -d -m 775 -o "${service_name}" -g "${service_name}" -- "${service_config}"

## Install the required version of Python
# shellcheck disable=SC2001
version=$(echo "${service_python##*python}" | sed 's/\.//')
pkg install -y "python${version}" "py${version}-sqlite3"

## Configure rcvars for the jail's primary service
sysrc ${service_name}_umask="002"
sysrc ${service_name}_user="${service_name}"
sysrc ${service_name}_group="${service_name}"
sysrc ${service_name}_config_dir="${service_config}"
sysrc ${service_name}_path="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"
sysrc ${service_name}_python="$(which ${service_python})"
sysrc ${service_name}_venv="/usr/local/share/${service_name}"

## Provide the example configuration files for the jail's primary service
cp -R "/usr/local/examples/${service_name}/" "${service_config}"
find "${service_config}" -type f -name ".empty" -depth -exec rm -f {} \;
chown -R "${service_name}":"${service_name}" "${service_home}" && chmod -R g=u "${service_home}"

## Download R -> requirements and C -> constraints for the initial install
R="https://raw.githubusercontent.com/home-assistant/core/master/requirements.txt"
C="https://raw.githubusercontent.com/home-assistant/core/master/homeassistant/package_constraints.txt"
requirements="$(mktemp -t ${service_name}.requirements)"
constraints="$(mktemp -t ${service_name}.constraints)"
curl -so "${constraints}" ${C} \
  && curl -s ${R} | sed "s|homeassistant/package_constraints.txt|${constraints}|" > "${requirements}" \
  && chown "${service_name}" "${requirements}" "${constraints}"

## Install the jail's primary service, Home Assistant Core
## and remove temporary requirements and constraints files
service "${service_name}" oneinstall "${service_name}" -r "${requirements}" \
  && rm "${requirements}" "${constraints}"

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
