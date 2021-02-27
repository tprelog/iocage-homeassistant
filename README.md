
<!-- BADGE LINKS -->
[plugins-link]:https://www.truenas.com/plugins/
[plugins-shield]:https://img.shields.io/badge/TrueNAS%20CORE-Community%20Plugin-blue?logo=TrueNAS&style=for-the-badge
[homeassistant]:https://img.shields.io/pypi/v/homeassistant?label=Home%20Assistant%20Core&logo=home-assistant
[plugin-version]:https://img.shields.io/github/v/tag/tprelog/iocage-homeassistant?label=Plugin%20Version&logo=truenas
[artifact-repo]:https://github.com/tprelog/iocage-homeassistant

<!-- CIRRUS CI RESULTS -->
[results-12.2]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=homeassistant-12-2
[core-12.2]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=homeassistant-12-2&label=12.2-RELEASE&logo=FreeBSD&logoColor=red&style=for-the-badge

# iocage-homeassistant

Artifact file(s) for [Home Assistant Core][ADR] (Python Virtualenv)

<!-- BADGE SHIELDS -->
[![x][plugins-shield]][plugins-link] [![x][core-12.2]][results-12.2]

[![x][plugin-version]][artifact-repo] [![x][homeassistant]][1]

:warning: This plugin provides a scripted installation of [Home Assistant Core][ADR]. This is considered an advanced installation method, using this plugin is not an exception. There will be occasions that require manual intervention. *This plugin does not provide the full Supervisor experience. There is no Supervisor panel, hence no add-ons.*

**You may find some additional information in the [project wiki](https://github.com/tprelog/iocage-homeassistant/wiki)**

[1]: https://homeassistant.io/
[2]: _img/TrueNAS_homeassistant.png
[ADR]: https://github.com/home-assistant/architecture/blob/6da4482d171f2ef04de9320d313526653b5818b4/adr/0016-home-assistant-core.md#0016-installation-method-home-assistant-core
