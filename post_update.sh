#!/usr/bin/env bash

# shellcheck disable=SC1091,2154
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

clean_install_service() {
  ## If enabled, clean-install Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_clean_install_service=YES` to enable
  local service="homeassistant" ; rm -rf "${homeassistant_venv}"
  service "${service}" install "${service}"
}

force_reinstall_service() {
  ## If enabled, force-reinstall Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_force_reinstall_service=YES` to enable
  local service="homeassistant"
  service "${service}" install --upgrade --force-reinstall "${service}"
}

upgrade_service() {
  ## If enabled, upgrade Home Assistant Core during a Plugin UPDATE
  ## Use `sysrc plugin_upgrade_service=YES` to enable
  service homeassistant install --upgrade homeassistant
}

checkyesno plugin_enable_pkglist && install_pkglist

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
