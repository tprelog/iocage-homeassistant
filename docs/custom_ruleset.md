---
layout: default
title: Using USB Z-Wave and Zigbee controllers
---

[Back][home]

Devices like the Aeotec Gen-5 USB Stick, Nortek HUSZB-1 and similar USB controllers require a custom `devfs_ruleset` to be accessible inside an iocage-jail. Before a jail can use the custom ruleset, it must first created on the FreeNAS host.

A few quick notes before creating the custom devfs_ruleset.
- Actually this will use a script that will create the custom devfs_ruleset for you
- The name of this script is trivial. In this example I will use `zwave-ruleset.sh`
- This will create `devfs_ruleset 99` on your FreeNAS host.
- I'm using `99` because it seems unlikely this would otherwise be used by the host.
- Only rulesets `1-4` are defined in `/etc/defaults/devfs.rules` but I have no idea what voodoo the middle-ware is performing

---

First, create a simple script `zwave-ruleset.sh` on your FreeNAS. This is what will actually create the custom ruleset.

I used the FreeNAS console to create this file in my home directory.
```bash
ee zwave-ruleset.sh
```

Add the following contents. You can change `99` in `ruleNum=99` if you need to use a different ruleset number.
```bash
#!/bin/sh
# Create custom devfs_ruleset NUMBER
NUMBER=99

/sbin/devfs rule -s ${NUMBER} add include 1
/sbin/devfs rule -s ${NUMBER} add include 2
/sbin/devfs rule -s ${NUMBER} add include 3
/sbin/devfs rule -s ${NUMBER} add path zfs unhide
/sbin/devfs rule -s ${NUMBER} add path 'bpf*' unhide
/sbin/devfs rule -s ${NUMBER} add path 'cua*' unhide
```
Save changes and exit the editor by pressing <kbd>ESC</kbd>, then <kbd>ENTER</kbd> twice.

Make the script executable.
```
chmod +x zwave-ruleset.sh
```

Run this script from the FreeNAS console to immediately create the custom ruleset.
```
sh zwave-ruleset.sh
```

Check that your custom ruleset has been successfully created.
`devfs rule -s 99` should return the following
```
sudo devfs rule -s 99 show

100 include 1
200 include 2
300 include 3
400 path zfs unhide
500 path bpf* unhide
600 path cua* unhide
```

Next, you will need to set your Home Assistant jail to use the custom ruleset. For an existing jail, do this from the FreeNAS console or use the webui. You will need to restart the jail to finishes applying the ruleset.
For this, I find using the FreeNAS console quickest. For example, if your jail is named `homeassistant`
```
iocage set devfs_ruleset=99 homeassistant
iocage restart homeassistant
```

If everything is working as expected, finally add zwave-ruleset.sh as a startup script using the FreeNAS webui.
This final step is required for FreeNAS to automatically create the custom ruleset during every (re)boot.

![img][devfs_ruleset]
[full size image][devfs_ruleset_raw]

---

[Back][home]

[home]: index.md

[devfs_ruleset]: _img/add_ruleset_11.2.png
[devfs_ruleset_raw]: https://github.com/tprelog/iocage-homeassistant/raw/master/docs/_img/add_ruleset_11.2.png
