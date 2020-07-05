#!/usr/bin/env bash

## If no version is assigned we start from zero
_plugin_ver="$(sysrc -n plugin_ver 2>/dev/null)"
if [ -z "${_plugin_ver}" ]; then
  _plugin_ver="0.0.0"
fi

install_extra_pkgs() {
  ## Install any remaining packages from '/tmp/pkglist'
  ## This is used to reinstall any additional pakages not included in the plugin manifest
  pkgs=$(cat /tmp/pkglist)
  echo -e "Installing any remaining packages"
  echo "${pkgs}" | xargs pkg install -y
}

if [ "${_plugin_ver}" == "0.0.0" ] || [ "${_plugin_ver}" == "0.0.0-1" ]; then
  check_openssl() {
    if [ `sysrc -n homeassistant_openssl 2>/dev/null` != "pkg" ] \
    && [ -f "/usr/local/bin/openssl" ]; then
        pkg delete openssl && pkg autoremove
    fi
  }
  sysrc plugin_ver="0.3b.pr1-1"
fi

install_extra_pkgs
echo -e "\npost_update.sh Finished\n"
