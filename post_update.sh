#!/usr/bin/env bash

install_extra_pkgs() {
  ## Install any remaining packages from '/tmp/pkglist'
  ## This is used to reinstall any additional pakages not included in the plugin manifest
  pkgs=$(cat /tmp/pkglist)
  echo -e "\nAttempting to reinstall any missing packages..."
  echo "${pkgs}" | xargs pkg install -y
}

update_post_install() {
  ## `post_install.sh` doesn't seem to get updated on it's own. Likely it's only files in the overlay
  ## I should probably move stuff out of the post_install script to avoid this need in the future.
  echo -e "\nUpdating post_install.sh..."
  wget -q -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/11.3-RELEASE/post_install.sh \
  && chmod +x /root/post_install.sh
}

rename_hass_helper() {
## hass-helper is now hassbsd -- This should handle that change.
if [ -f /root/bin/hass-helper ] && [ -f /root/bin/hassbsd ]; then
  sed -e "s/hass-helper/hassbsd/g" /root/.login > /root/.loginTemp \
  && mv /root/.loginTemp /root/.login \
  && rm /root/bin/hass-helper
fi
}

check_esphome () {
## ESPHome has been moved to a seperate FreeNAS plugin. This should re-enable the
## console menu for people who had it already installed before it was removed.
  echo -e "\nChecking for ESPHome..."
  sysrc esphome_enable  2> /dev/null
  if [ $? == 0 ]; then
    sysrc esphome_menu=1
  else
    sysrc -x esphome_menu 2> /dev/null
  fi
}

install_extra_pkgs
rename_hass_helper
update_post_install
check_esphome
echo -e "\npost_update.sh Finished\n"
