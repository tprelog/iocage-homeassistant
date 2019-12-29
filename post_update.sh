#!#!/usr/bin/env bash


install.extra.pkgs.v1() {

  ## To ENABLE this function use `sysrc hass_extrapkgs=/path/to/file`
  ## To DISABLE this function after it has been set `sysrc -x hass_extrapkgs`

  ## hass_extrapkgs: Path to a file containing a list of extra packages to
  ##                 be installed. The list should contain ONLY ONE PER LINE.
  ##                 Blank and lines beginning with a comment (#) will be skipped.

  ## One concern with providing Home Assistant as a plugin verse a standard jail
  ## is the ability to trackdown and install all the FreeBSD pkgs that may be
  ## required to enable and use built-in and/or custom Home Assistant components
  ## and integrations. While it is possible to `pkg install *something*` inside the
  ## plugin, anything extra installed using `pkg install` will be removed during
  ## an update. (This behavior is not my choice) Hopefully this function will provide
  ## a usable solution that can be controlled on an individual basis.

  if [ -f "${pkglist}" ] ; then
    if pkgs=$(cat "${pkglist}" | grep -v '^[#;]' | grep .) && [ ! -z "${pkgs}" ]; then
      echo -e "\nAttempting to install extra packages..."
      echo "${pkgs}" | xargs pkg install -y
    else
      echo -e "\nPackage list is empty.\nNothing to do!\n"
    fi
  else
    echo -e "\n${pkglist} is either missing or not a file!\n"
  fi
}


upgrade.venv.service() {

  ## WIP This function is incomplete!

  ## To ENABLE this function use `sysrc hass_upgrade=yes`
  ## To DISABLE this function after it has been set `sysrc -x hass_upgrade`

  ## hass_srvupgrade: Also upgrade supported applications that have been pip installed
  ##                  using a virtualenv during a plugin update.

  ## This fuction will upgrade the virtualenv service (applications) during a plugin upgrade.
  ## Only valid services that have been enabled will be enabled will get upgraded
  ## The list of valid services are [ homeassistant | appdaemon | configurator ]

  echo "This function is incomplete!"
}


sysrc -a | grep hass_extrapkgs
if [ $? == 0 ]; then
  pkglist=$(sysrc -n hass_extrapkgs)
  if [ ! -z "${pkglist}" ]; then
    echo -e "hass_extrapkgs list is set..."
    install.extra.pkgs.v1
  else
    echo "hass_extrapkgs is not set!"
  fi
else
  echo -e "\npost_update.sh Finished OK!\nNothing to do!\n"
fi
