# iocage-homeassistant
Artifact file(s) for Home Assistant Core (Python virtualenv) on FreeNAS

**This branch is intended for FreeNAS 11.3 but should work with FreeNAS-11.2-U7 or later**

- This will create an 11.3-RELEASE iocage-jail for Home Assistant on FreeNAS 11.x
- The script will [install Home Assistant Core in a Python virtualenv](https://www.home-assistant.io/docs/installation/virtualenv/)
- Includes options to create and install seperate Python virtualenvs for the following
    - ESPHome *added by request and with the help of @CyanoFresh*
    - AppDaemon (includes HA Dashboard)
    - HASS-Configurator

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
[Home Assistant][HA] |homeassistant | /srv/homeassistant | 8123 | hass | /home/hass/homeassistant
[Configurator][HC] | configurator | /srv/configurator | 3218 | hass | /home/hass/configurator
[AppDaemon][AD] | appdaemon | /srv/appdaemon |  NA  | hass | /home/hass/appdaemon
[HADashboard][HD] | appdaemon | /srv/appdaemon | 5050 | hass | /home/hass/appdaemon
[ESPHome][EH] | esphome | /srv/esphome | 6052 | hass | /home/hass/esphome


##### USB devices are not supported with ESPHome

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

##### Using USB Z-Wave and Zigbee controllers

To directly access devices like the Aeotec Gen-5 USB Stick, Nortek HUSZB-1 or similar USB controllers inside an iocage-jail, you will need to use a custom devfs_ruleset. Before a jail can use the custom ruleset, it must first be created on the FreeNAS host. These steps can be found [HERE][ruleset]

---

## Installing Home Assistant Core

#### plugin-jail

- Now available in FreeNAS 11.3 as a community plugin
- The plugin-jail is *only available on FreeNAS 11.3*

Install using this using FreeNAS webui
![img][fn_plugins]


#### standard-jail

*The standard-jail is the only option for FreeNAS 11.2-U7*.

Use the standard-jail on FreeNAS 11.3 if you need to compile packages from the ports tree or if you want to make changes to the jail’s BSD system itself.  *With regards to Home Assistant and the other applications running in virtualenvs, there should be no advantage to using a standard-jail.*

- This is intended for FreeNAS 11.3 but should work with *FreeNAS-11.2-U7* and later
- Replace `JAIL_NAME` with something of your choice (This will be the name of the jail)

**Make a pkglist and create a jail using it to install requirements**
```bash
echo '{"pkgs":["autoconf","bash","ca_root_nss","git-lite","gmake","pkgconf","python37","py37-sqlite3"]}' > /tmp/pkglist.json
iocage create -r 11.3-RELEASE dhcp=on bpf=yes vnet=on boot=on allow_raw_sockets=1 -p /tmp/pkglist.json --name JAIL_NAME
```

**Git script and begin install**
```bash
iocage exec JAIL_NAME git clone -b 11.3-RELEASE https://github.com/tprelog/iocage-homeassistant.git /root/.iocage-homeassistant
iocage exec JAIL_NAME bash /root/.iocage-homeassistant/post_install.sh standard
```

---
##### This should be exactly the same for both the plugin-jail and the standard-jail

###### Includes an updated main console menu to help manage the services
![img][fn_console_menu]

###### Each service will have a corresponding console menu
![img][ha_freenas_menu]

---
##### Tested on FreeNAS-11.3
![img][ha_info]

---

- Links to the FreeNAS Docs
  - [iocage plugins][FN_docs_plugins]
  - [iocage jails][FN_docs_jails]

[ruleset]: https://tprelog.github.io/iocage-homeassistant/custom_ruleset.html

[fn_plugins]: docs/_img/freenas_plugins.png
[fn_console_menu]: docs/_img/fn_console_menu.png

[ha_freenas_menu]: docs/_img/ha_console_menu.png
[ha_info]: docs/_img/ha_info.png


[FN]: https://www.ixsystems.com/documentation/freenas/11.3-RELEASE/intro.html
[FN_docs_plugins]: https://www.ixsystems.com/documentation/freenas/11.3-RELEASE/plugins.html
[FN_docs_jails]: https://www.ixsystems.com/documentation/freenas/11.3-RELEASE/jails.html

[HA]: https://www.home-assistant.io/
[HC]: https://www.home-assistant.io/docs/ecosystem/hass-configurator/
[AD]: https://www.home-assistant.io/docs/ecosystem/appdaemon/
[HD]: https://www.home-assistant.io/docs/ecosystem/hadashboard/
[EH]: https://esphome.io/index.html
