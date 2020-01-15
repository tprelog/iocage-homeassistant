# iocage-homeassistant
Artifact file(s) for [Home Assistant](https://www.home-assistant.io/) + [AppDaemon](https://www.home-assistant.io/docs/ecosystem/appdaemon/) + [HASS Configurator](https://www.home-assistant.io/docs/ecosystem/hass-configurator/#configuration-ui-for-home-assistant) + [ESPHome](https://esphome.io/index.html)

**This branch is intended for FreeNAS 11.3 but should work with FreeNAS-11.2-U7 or later**

- This will create an 11.3-RELEASE iocage-jail for Home Assistant on FreeNAS 11
- The script will [install Home Assistant in a Python virtualenv](https://www.home-assistant.io/docs/installation/virtualenv/). *This is not [Hass.io](https://www.home-assistant.io/hassio/)*
- Includes options to create and install seperate Python virtualenvs for the following
    - ESPHome *added by request and with the help of @CyanoFresh*
    - AppDaemon (includes HADashboard)
    - HASS-Configurator

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
Home Assistant |homeassistant | /srv/homeassistant | 8123 | hass | /home/hass/homeassistant
Hass Configurator | configurator | /srv/configurator | 3218 | hass | /home/hass/configurator
AppDaemon | appdaemon | /srv/appdaemon |  NA  | hass | /home/hass/appdaemon
HA Dashboard | appdaemon | /srv/appdaemon | 5050 | hass | /home/hass/appdaemon
ESPHome | esphome | /srv/esphome | 6052 | hass | /home/hass/esphome


##### USB devices are not supported with ESPHome

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.

##### USB Z-Wave and Zigbee devices

If you are using a Z-Wave or Zigbee controller such as the Aeotec Gen-5, Nortek HUSBZB-1, or similiar USB device, you will need to create a custom devfs_ruleset on the FreeNAS host system. The steps for this can be found in this [FreeNAS Resource](https://forums.freenas.org/index.php?resources/fn-11-2-iocage-home-assistant-jail-plugins-for-node-red-mosquitto-amazon-dash-tasmoadmin.102/)

---

## Installing Home Assistant

#### plugin-jail

- The plugin-jail is *only for FreeNAS 11.3*
- I am using this for my main Home Assistant install on FreeNAS 11.3-RC1
- Replace `JAIL_NAME` with something of your choice (This will be the name of the jail)

```bash
iocage fetch -P homeassistant -g https://github.com/tprelog/freenas-plugin-index.git --name JAIL_NAME
```

#### standard-jail

*The standard-jail is the only option for FreeNAS 11.2-U7*. Use the standard-jail on FreeNAS 11.3 if you need to compile packages from the ports tree or if you want to make changes to the jail’s BSD system itself.  *With regards to Home Assistant and the other applications running in virtualenvs, there should be no advantage to using a standard-jail.*

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
![fn_console_menu][fn_console_menu]

###### Each service will have a corresponding console menu
![ha_freenas_menu][ha_freenas_menu]

---
##### Tested on FreeNAS-11.3-RC1
![ha_info][ha_info]

---

- More information about [iocage plugins](https://doc.freenas.org/11.3/plugins.html) and [iocage jails](https://doc.freenas.org/11.3/jails.html) can be found in the [FreeNAS guide](https://doc.freenas.org/11.3/intro.html#introduction)

[ha_freenas_menu]: docs/_img/ha_console_menu.png
[ha_info]: docs/_img/ha_info.png
[freenas_plugins]: docs/_img/freenas_plugins.png
[fn_console_menu]: docs/_img/fn_console_menu.png
