<!-- markdownlint-disable MD012 MD041 -->

<!-- BADGE LINKS -->
[plugins-link]:https://www.truenas.com/plugins/
[plugins-shield]:https://img.shields.io/badge/TrueNAS%20CORE-Community%20Plugin-blue?logo=TrueNAS&style=for-the-badge

<!-- CIRRUS CI RESULTS -->
[results-12.2]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/12.2-RELEASE
[results-13.0]:https://cirrus-ci.com/github/tprelog/truenas-plugin-index/13.0-RELEASE

[core-12.2]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/12.2-RELEASE?task=homeassistant-12-2&label=12.2-RELEASE&logo=FreeBSD&logoColor=red&style=plastic
[core-13.0]:https://img.shields.io/cirrus/github/tprelog/truenas-plugin-index/13.0-RELEASE?task=homeassistant-13-0&label=13.0-RELEASE&logo=FreeBSD&logoColor=red&style=plastic

[1]: https://homeassistant.io/
[ADR]: https://github.com/home-assistant/architecture/blob/6da4482d171f2ef04de9320d313526653b5818b4/adr/0016-home-assistant-core.md#0016-installation-method-home-assistant-core

# iocage-homeassistant

Artifact file(s) for [Home Assistant Core][ADR]

[![x][plugins-shield]][plugins-link]

[![x][core-12.2]][results-12.2]

[![x][core-13.0]][results-13.0]

:warning: **This plugin is not actively maintained**

At this time I am no longer using TrueNAS CORE or any iocage jails. As a consequence I may not be aware of, and proactively fixing any issues that could arise. If you're having trouble with the installation of this plugin you can still open an issue and I will do my best to help. While no further development is currently planned, I will remain open to any suggestions for improvement, try to fix any bugs when they are reported, and continue trying to support this plugin for as long as it remains feasible.

:warning: This plugin provides a scripted installation of [Home Assistant Core][ADR]. This is considered an advanced installation method, using this plugin will not be an exception. This plugin does not provide a fully managed system like Home Assistant OS. There is no Supervisor hence addons are not available. Manual intervention and use of the command line will be required!

:warning: Home Assistant only supports Linux, OSX and Windows using WSL. FreeBSD is not supported. This plugin runs in a FreeBSD jail, therefore it is not supported. Some integrations may not work as expected!

**You may find some additional information in the [wiki](https://github.com/tprelog/iocage-homeassistant/wiki)**
