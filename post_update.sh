#!/usr/bin/env bash

install.extra.pkgs() {
  ## Install any remaining packages from '/tmp/pkglist'
  ## This is used to reinstall any additional pakages not included in the plugin manifest
  pkgs=$(cat /tmp/pkglist)
  echo -e "\nAttempting to reinstall any missing packages..."
  echo "${pkgs}" | xargs pkg install -y
}

update.post_install() {
  ## `post_install.sh` doesn't seem to get updated on it's own. Likely it's only files in the overlay
  ## I should probably move stuff out of the post_install script to avoid this in the future.
  wget -O /root/post_install.sh https://raw.githubusercontent.com/tprelog/iocage-homeassistant/11.3-RELEASE/post_install.sh \
  && chmod +x /root/post_install.sh
}

rename.hasshelper() {
## hass-helper is now hassbsd -- This should handle that change.
if [ -f /root/bin/hass-helper ] && [ -f /root/bin/hassbsd ]; then
  sed -e "s/hass-helper/hassbsd/g" /root/.login > /root/.loginTemp \
  && mv /root/.loginTemp /root/.login \
  && rm /root/bin/hass-helper
fi
}

rename.hasshelper
install.extra.pkgs
update.post_install
echo -e "\npost_update.sh Finished\n"
