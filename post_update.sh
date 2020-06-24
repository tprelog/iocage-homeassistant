#!/usr/bin/env bash

install_extra_pkgs() {
  ## Install any remaining packages from '/tmp/pkglist'
  ## This is used to reinstall any additional pakages not included in the plugin manifest
  pkgs=$(cat /tmp/pkglist)
  echo -e "\nAttempting to reinstall any missing packages..."
  echo "${pkgs}" | xargs pkg install -y
}

check_esphome () {
## ESPHome has been moved to a seperate FreeNAS plugin. This should re-enable the
## console menu for people who had it already installed before it was removed.
  echo -e "\nChecking for ESPHome..."
  sysrc esphome_enable  2>/dev/null
  if [ $? == 0 ]; then
    sysrc esphome_menu=1
  else
    sysrc -x esphome_menu 2>/dev/null
  fi
}

install_extra_pkgs
check_esphome
echo -e "\npost_update.sh Finished\n"
