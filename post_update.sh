#!/usr/bin/env bash

. /etc/rc.subr && load_rc_config

install_primelist() {
  ## If enabled, re-install packages from the prime-list
  ## Use `sysrc plugin_enable_primelist=YES` to enable
  local pkgs ; pkgs=$(cat "${plugin_primelist:-/tmp/pkglist}")
  echo -e "\nChecking prime-list for additional packages..."
  echo "${pkgs}" | xargs pkg install -y
}

checkyesno "${plugin_enable_primelist:-"NO"}" && install_primelist
