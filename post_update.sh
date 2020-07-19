#!/usr/bin/env bash

install_extra_pkgs() {
  ## Install any remaining packages from '/tmp/pkglist'
  ## This is used to reinstall any additional pakages not included in the plugin manifest
  pkgs=$(cat /tmp/pkglist)
  echo -e "Installing any remaining packages"
  echo "${pkgs}" | xargs pkg install -y
}

install_extra_pkgs
echo -e "\npost_update.sh Finished\n"
