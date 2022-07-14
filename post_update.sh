#!/usr/bin/env bash

# shellcheck disable=SC1091,2001,2154
. /etc/rc.subr && load_rc_config
: "${plugin_enable_pkglist:="NO"}"
: "${plugin_clean_install_service:="NO"}"
: "${plugin_force_reinstall_service:="NO"}"
: "${plugin_upgrade_service:="NO"}"

install_pkglist() {
  ## If enabled, re-install packages from a pkglist during a Plugin UPDATE
  ## Use `sysrc plugin_pkglist="/path/to/pkglist"` to set a pkglist
  ## Use `sysrc plugin_enable_pkglist=YES` to enable
  local pkgs ; pkgs=$(cat "${plugin_pkglist:-/dev/null}")
  echo -e "\nChecking for additional packages to install..."
  echo "${pkgs}" | xargs pkg install -y
}

check_for_python() {
  ## Ensure the set version of Python is installed for Home Assistant Core
  if ! which "${homeassistant_python:?"version not set"}"; then
    local version; version=$(echo "${homeassistant_python##*python}" | sed 's/\.//')
    pkg install -y "python${version} py${version}-sqlite3"
  fi
  ## ... and Appdaemon, if enabled
  if service -e | grep appdaemon; then
    if ! which "${appdaemon_python:?"version not set"}"; then
      local version; version=$(echo "${appdaemon_python##*python}" | sed 's/\.//')
      pkg install -y "python${version}"
    fi
  fi
  ## ... and Hass-Configurator, if enabled
  if service -e | grep configurator; then
    if ! which "${configurator_python:?"version not set"}"; then
      local version; version=$(echo "${configurator_python##*python}" | sed 's/\.//')
      pkg install -y "python${version}"
    fi
  fi
}

clean_install_service() {
  ## If enabled, clean-install Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_clean_install_service=YES` to enable
  rm -rf "${homeassistant_venv}"
  service homeassistant install homeassistant
}

force_reinstall_service() {
  ## If enabled, force-reinstall Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_force_reinstall_service=YES` to enable
  service homeassistant install --upgrade --force-reinstall homeassistant
}

upgrade_service() {
  ## If enabled, upgrade Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_upgrade_service=YES` to enable
  service homeassistant install --upgrade homeassistant
}

checkyesno plugin_enable_pkglist && install_pkglist

check_for_python

if checkyesno plugin_clean_install_service; then
  clean_install_service
elif checkyesno plugin_force_reinstall_service; then
  force_reinstall_service
elif checkyesno plugin_upgrade_service; then
  upgrade_service
fi

sysrc plugin_version="$(cat /root/.PLUGIN_VERSION)"

## Gererate PLUGIN_INFO
/root/.plugin/bin/plugin-info
