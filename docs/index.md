***Construction of this site (using these github pages) is temporarily on hold***

In these last months, I have made no progress toward advancing this quick start for Home Assistant Core on FreeNAS. In an effort to remove some distractions -- *because I can't just turn on and leave alone* -- that come with using github pages, I am putting this site on hold.

I am hoping that [temporarily moving this quick start to the project wiki](https://github.com/tprelog/iocage-homeassistant/wiki) will allow me to focus on expanding these docs in a more timely manner. When the wiki is more complete with content, I will again attempt for better presentaion using these github pages.

---

**This is a [FreeNAS Community Plugin][2]**
- The FreeNAS Community Plugin [provides these basic configuration files][config] to help get started

NAME | SERVICE | VIRTUALENV | PORT | USER | CONFIG DIR
:---: | :---: | :---: | :---: | :---: | :---: |
[Home Assistant Core][1] |homeassistant | /srv/homeassistant | 8123 | hass | /home/hass/homeassistant
[Hass Configurator][HC] | configurator | /srv/configurator | 3218 | hass | /home/hass/configurator
[AppDaemon][AD] | appdaemon | /srv/appdaemon |  5050  | hass | /home/hass/appdaemon
[HA Dashboard][HD] | appdaemon | /srv/appdaemon | ^^^^ | hass | /home/hass/appdaemon


---

**Using USB Z-Wave and Zigbee controllers**

To directly access devices like the Aeotec Gen-5 USB Stick, Nortek HUSZB-1 or similar USB controllers inside an iocage-jail, you will need to use a custom devfs_ruleset. Before a jail can use the custom ruleset, it must first be created on the FreeNAS host.

- [Using a USB Z-Wave or Zigbee controller][ruleset_wiki]

---

**Home Assistant Community Forum**
- [Home Assistant Core -- FreeNAS Community Plugin][ha_forum_qs]

---

**The current release is intended for FreeNAS 11.3 but should work with FreeNAS 11.2-U7 or later**
- The current artifact files for this FreeNAS plugin can be found [HERE][4]
- All of my FreeNAS plugin manifests can be found [HERE][3]


[ha_forum_qs]: https://community.home-assistant.io/t/home-assistant-core-freenas-community-plugin/170542?u=troy


[1]: https://homeassistant.io/
[2]: https://www.freenas.org/plugins/
[3]: https://github.com/tprelog/freenas-plugin-index
[4]: https://github.com/tprelog/iocage-homeassistant/tree/11.3-RELEASE


[HC]: https://www.home-assistant.io/docs/ecosystem/hass-configurator/
[AD]: https://www.home-assistant.io/docs/ecosystem/appdaemon/
[HD]: https://www.home-assistant.io/docs/ecosystem/hadashboard/

[github_pages]: https://tprelog.github.io/iocage-homeassistant/

[add_ruleset]: ./custom_ruleset.html
[ruleset_wiki]: https://github.com/tprelog/iocage-homeassistant/wiki/Using-a-USB-Z-Wave-or-Zigbee-controller
[ruleset]: https://tprelog.github.io/iocage-homeassistant/custom_ruleset.html

[config]: https://github.com/tprelog/iocage-homeassistant/tree/11.3-RELEASE/overlay/root/.hass_overlay
