# iocage-homeassistant
Artifact file(s) for [Home Assistant Core][1] (Python Virtualenv)

### This is a FreeNAS / TrueNAS Core Community Plugin


**This release is intended for TrueNAS Core 12**

- This plugin will create a 12.1-RELEASE iocage jail and install [Home Assistant Core][1] using a Pyton Virtualenv
- Includes option to install the [Hass Configurator](https://github.com/danielperna84/hass-configurator#hass-configurator) ( :wrench: File Editor) in a separate Python Virtualenv

**The FreeNAS Community Plugin [provides this basic configuration][config] to help get started**

**Home Assistant Community Guide**
- [Home Assistant Core -- FreeNAS Community Plugin][ha_forum_qs]

**You may find some additional information in the [project wiki](https://github.com/tprelog/iocage-homeassistant/wiki)**


## Installation

**Home Assistant Core is available from the Community Plugins page on FreeNAS and TrueNAS Core**

![img][FreeNAS_plugins]



---

###### Current artifact files can be found in the [12.1-RELEASE branch][4]

[ha_forum_qs]: https://community.home-assistant.io/t/home-assistant-core-freenas-community-plugin/170542?u=troy
[FreeNAS_plugins]: _img/TrueNAS_homeassistant.png

[1]: https://homeassistant.io/
[2]: https://www.freenas.org/plugins/
[3]: https://github.com/tprelog/freenas-plugin-index
[4]: https://github.com/tprelog/iocage-homeassistant/tree/12.1-RELEASE


[HC]: https://github.com/danielperna84/hass-configurator#hass-configurator

[github_pages]: https://tprelog.github.io/iocage-homeassistant/
[ruleset]: https://tprelog.github.io/iocage-homeassistant/custom_ruleset.html
[ruleset_wiki]: https://github.com/tprelog/iocage-homeassistant/wiki/Using-a-USB-Z-Wave-or-Zigbee-controller
[config]: https://github.com/tprelog/iocage-homeassistant/tree/11.3-RELEASE/overlay/root/.hass_overlay
