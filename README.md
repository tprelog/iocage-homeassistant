# iocage-homeassistant
Artifact file(s) for [Home Assistant Core][1] (python virtualenv)

### This is a [FreeNAS Community Plugin][2]

**The current release is intended for FreeNAS 11.3 but should work with FreeNAS 11.2-U7 or later**

- This will create an 11.3-RELEASE iocage-jail for [Home Assistant Core][1]
- Includes options to create and install separate python virtualenvs for the following

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
[Home Assistant Core][1] |homeassistant | /srv/homeassistant | 8123 | hass | /home/hass/homeassistant
[Hass Configurator][HC] | configurator | /srv/configurator | 3218 | hass | /home/hass/configurator
[AppDaemon][AD] | appdaemon | /srv/appdaemon |  5050  | hass | /home/hass/appdaemon
[HA Dashboard][HD] | appdaemon | /srv/appdaemon | ^^^^ | hass | /home/hass/appdaemon

**The FreeNAS Community Plugin [provides this basic configuration][config] to help get started**

---

## Installation

**Home Assistant Core is available from the Community Plugins page on FreeNAS 11.3**

![img][FreeNAS_plugins]

---

**FreeNAS 11.2-U7**
<details><summary>Click Here</summary>
<p>

##### plugin-jail

*The 11.3-RELEASE should work on FreeNAS 11.2-U7 or later*

It is possible to install this plugin on FreeNAS 11.2-U7 using the console.

```bash
wget -O /tmp/homeassistant.json https://raw.githubusercontent.com/tprelog/freenas-plugin-index/11.3-RELEASE/homeassistant.json
iocage fetch -P dhcp=on vnet=on vnet_default_interface=auto bpf=yes boot=on -n /tmp/homeassistant.json --branch 11.3-RELEASE
```

</p>
</details>

---

##### Using USB Z-Wave and Zigbee controllers

To directly access devices like the Aeotec Gen-5 USB Stick, Nortek HUSZB-1 or similar USB controllers inside an iocage-jail, you will need to use a custom devfs_ruleset. Before a jail can use the custom ruleset, it must first be created on the FreeNAS host. These steps can be found [HERE][ruleset]

---

###### This branch is the source for https://tprelog.github.io/iocage-homeassistant/

###### Current artifact files can be found in the [11.3-RELEASE branch][4]

[FreeNAS_plugins]: _img/FreeNAS_homeassistant.png

[1]: https://homeassistant.io/
[2]: https://www.freenas.org/plugins/
[3]: https://github.com/tprelog/freenas-plugin-index
[4]: https://github.com/tprelog/iocage-homeassistant/tree/11.3-RELEASE


[HC]: https://www.home-assistant.io/docs/ecosystem/hass-configurator/
[AD]: https://www.home-assistant.io/docs/ecosystem/appdaemon/
[HD]: https://www.home-assistant.io/docs/ecosystem/hadashboard/

[github_pages]: https://tprelog.github.io/iocage-homeassistant/
[ruleset]: https://tprelog.github.io/iocage-homeassistant/custom_ruleset.html
[config]: https://github.com/tprelog/iocage-homeassistant/tree/11.3-RELEASE/overlay/root/.hass_overlay
