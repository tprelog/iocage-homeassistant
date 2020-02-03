## Using USB Z-Wave and Zigbee controllers

To directly access devices like the Aeotec Gen-5 USB Stick, Nortek HUSZB-1 or similar USB controllers inside an iocage-jail, you will need to use a custom devfs_ruleset. Before a jail can use the custom ruleset, it must first be created on the FreeNAS host.

- This will use a script to create the custom devfs_ruleset on your FreeNAS
- The name of this script is trivial. In this example I use `zwave-ruleset.sh`

---

## Create a script `zwave-ruleset.sh` on your FreeNAS
- The script will create `devfs_ruleset 99` on your FreeNAS
- I use `99` because it seems unlikely this would otherwise be used
- To use a different ruleset number, change `RULE_NUM=99`

**I used the FreeNAS console to create the script in my user's home directory**
```bash
ee zwave-ruleset.sh
```

**Add the following contents**
```bash
#!/bin/sh

## Create custom devfs_ruleset RULE_NUM
RULE_NUM=99

/sbin/devfs rule -s ${RULE_NUM} add include 1
/sbin/devfs rule -s ${RULE_NUM} add include 2
/sbin/devfs rule -s ${RULE_NUM} add include 3
/sbin/devfs rule -s ${RULE_NUM} add path zfs unhide
/sbin/devfs rule -s ${RULE_NUM} add path 'bpf*' unhide
/sbin/devfs rule -s ${RULE_NUM} add path 'cua*' unhide
```

- To Save and Exit, press <kbd>ESC</kbd> then press <kbd>ENTER</kbd> twice

**Make the script executable**
```bash
chmod +x zwave-ruleset.sh
```

### Test the script from the FreeNAS console
```bash
sh zwave-ruleset.sh
```

**Check that your custom ruleset has been successfully created**
```bash
devfs rule -s 99
```

- You should see similar output

```bash
$ sudo devfs rule -s 99 show

100 include 1
200 include 2
300 include 3
400 path zfs unhide
500 path bpf* unhide
600 path cua* unhide
```

---

## Setting your jail to use the custom ruleset
- You can do this from the FreeNAS console or use the webui
- I find using the FreeNAS console quickest

For example, if your jail is named `homeassistant`

```bash
iocage set devfs_ruleset=99 homeassistant
iocage restart homeassistant
```

---

## Automatically creating the custom ruleset
- Set `zwave-ruleset.sh` to run at startup using the FreeNAS webui

__*This is required for FreeNAS to automatically (re)create the custom ruleset during (re)boot.*__

![img][devfs_ruleset]
[full size image][devfs_ruleset_raw]

---

[home]: ./index.html

[devfs_ruleset]: img/add_ruleset_11.2.png
[devfs_ruleset_raw]: https://github.com/tprelog/iocage-homeassistant/raw/master/docs/img/add_ruleset_11.2.png
