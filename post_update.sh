#!/usr/bin/env bash
# plugin version 5.0

. /etc/rc.subr && load_rc_config
: "${plugin_enable_primelist:="NO"}"

install_primelist() {
  ## If enabled, re-install packages from the prime-list
  ## Use `sysrc plugin_enable_primelist=YES` to enable
  local pkgs ; pkgs=$(cat "${plugin_primelist:-/tmp/pkglist}")
  echo -e "\nChecking prime-list for additional packages..."
  echo "${pkgs}" | xargs pkg install -y
}

checkyesno plugin_enable_primelist && install_primelist

echo "TODO: Update the PLUGIN_INFO"
