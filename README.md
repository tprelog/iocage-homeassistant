# iocage-homeassistant
Artifact file(s) for [Home-Assistant](https://www.home-assistant.io/) + [App-Daemon](https://www.home-assistant.io/docs/ecosystem/appdaemon/) + [Hass-Configurator](https://www.home-assistant.io/docs/ecosystem/hass-configurator/#configuration-ui-for-home-assistant)

- This script will create an iocage-plugin for Home Assistant on FreeNAS 11.3
- Using this script will [install Home Assistant in a Python virtualenv](https://www.home-assistant.io/docs/installation/virtualenv/). *This is not [Hass.io](https://www.home-assistant.io/hassio/)*
- Includes options to install ESPHome, HASS-Configurator and AppDaemon (with HA Dashboard) in seperate Python virtualenvs
- ESPHome was added by request and with the help of @CyanoFresh

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
Home Assistant |homeassistant | /srv/homeassistant | 8123 | hass | /home/hass/homeassistant
Hass Configurator | configurator | /srv/configurator | 3218 | hass | /home/hass/configurator
AppDaemon | appdaemon | /srv/appdaemon |  NA  | hass | /home/hass/appdaemon
HA Dashboard | appdaemon | /srv/appdaemon | 5050 | hass | /home/hass/appdaemon
ESPHome | esphome | /srv/esphome | 6052 | hass | /home/hass/esphome

#### Install Home Assistant

- Replace `JAIL_NAME` with something of your choice

```bash
iocage fetch -P homeassistant -g https://github.com/tprelog/freenas-plugin-index.git --name JAIL_NAME
```

##### USB devices are not supported with ESPHome

*There is currently no USB detection for device flashing on FreeNAS*. You can create, compile and download the initial firmware using ESPHome on FreeNAS. *You will need to use esphomeflasher on a seperate computer for the initial flash*. After the initial flash and your device is connected to your network, you will be able to manage and flash future firmwares using the ESPHome OTA process.


##### USB Z-Wave and Zigbee devices

If you are using a Z-Wave or Zigbee controller such as the Aeotec Gen-5, Nortek HUSBZB-1, or similiar USB device, you will need to create a custom devfs_ruleset on the FreeNAS host system. The steps for this as well as setting up a separate dataset for the Home Assistant configuration files and additional information for using this repo can be found in this [FreeNAS Resource](https://forums.freenas.org/index.php?resources/fn-11-2-iocage-home-assistant-jail-plugins-for-node-red-mosquitto-amazon-dash-tasmoadmin.102/)


---
##### Includes a simple console menu for some common tasks
![ha_freenas_menu][ha_freenas_menu]


---
##### Tested on FreeNAS-11.3-RC1
![ha_info][ha_info]

---

<details><summary>You can also use this script for a standard-jail install</summary>
<p>

- This is intended for FreeNAS 11.3 but should work with FreeNAS-11.2-U7 or later

With the new communtiy plugins available in FreeNAS 11.3 I'm shifting focus to include
a better experiance for managing Home Assistant from the FreeNAS console. All these 
changes will be available in the standard-jail install as well.

Using the plugin-install will make it possible to keep up to date with these changes by
pressing the update button in the FreeNAS webui. You can still get these updates using
a standard-jail but that will require you download and copy the updated files into place
yourself. Who wants to do all that when you can just press a button instead?

- Replace `JAIL_NAME` with something of your choice

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

**Answer questions will choose what gets installed**
```
    Install Home-Assistant?  [Y/n]:
    Install Hass-Configurator?  [Y/n]:
    App-Daemon & HA-Dashboard?  [Y/n]:
    Use the pre-configured examples?  [Y/n]:
```

- The example config is just a starting point but recommended if you install the configurator or appdaemon
- You will still need to setup your long-live-access-tokens for both the configurator & appdaemon after the install
- This is most important for appdaemon - you *will be* spammed with login fails until the access-tokens are set!

***Profit!***

</p>
</details>

---

- This branch is intended for FreeNAS 11.3 but should also work with FreeNAS-11.2-U7 or later
- More information about [iocage plugins](https://doc.freenas.org/11.3/plugins.html) and [iocage jails](https://doc.freenas.org/11.3/jails.html) can be found in the [FreeNAS guide](https://doc.freenas.org/11.3/intro.html#introduction)


[ha_freenas_menu]: docs/_img/ha_console_menu.png
[ha_info]: docs/_img/ha_info.png
