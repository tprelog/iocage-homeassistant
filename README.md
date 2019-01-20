# iocage-homeassistant
Artifact file(s) for [Home-Assistant](https://www.home-assistant.io/) + [App-Daemon](https://www.home-assistant.io/docs/ecosystem/appdaemon/) / [HA-Dashboard](https://www.home-assistant.io/docs/ecosystem/hadashboard/) + [Hass-Configurator](https://www.home-assistant.io/docs/ecosystem/hass-configurator/#configuration-ui-for-home-assistant)  

If you are using a Z-Wave or Zigbee controller such as the Aeotec Gen-5, Nortek HUSBZB-1, or similiar USB device, you will need to create a custom devfs_ruleset on the FreeNAS host system. The steps for this as well as setting up a seperate dataset for the Home Assistant configuration files and additional information for using this repo can be found in this [FreeNAS Resource](https://forums.freenas.org/index.php?resources/fn-11-2-iocage-home-assistant-jail-plugins-for-node-red-mosquitto-amazon-dash-tasmoadmin.102/)

---
---
## iocage-jail-homeassistant

 - This scrpit can be used to create an iocage-jail for Home-Assistant
 - Includes option to install App-Daemon/HA-Dashboard and(or) Hass-Configurator
 
**Download pkg-list and create a jail using it to install requirements**

    wget -O /tmp/pkglist.json https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/pkg-list.json
    sudo iocage create -r 11.2-RELEASE dhcp=on bpf=yes vnet=on boot=on allow_raw_sockets=1 -p /tmp/pkglist.json -n homeassistant


**Optional: mount a dataset inside the jail**

    sudo iocage fstab -a homeassistant "/mnt/tank/user/hass /home/hass nullfs rw 0 0"
    
    
**Git script and begin install**

    sudo iocage exec homeassistant git clone https://github.com/tprelog/iocage-homeassistant.git /root/.iocage-homeassistant
    sudo iocage exec homeassistant bash /root/.iocage-homeassistant/post_install.sh standard
    

**Answer questions will choose what gets installed**

    Install Home-Assistant?  [Y/n]:
    Install Hass-Configurator?  [Y/n]:
    App-Daemon & HA-Dashboard?  [Y/n]:
    Use the pre-configured examples?  [Y/n]:

***Profit!***

**Includes a simple console menu for updates**

    sudo iocage exec homeassistant bash update
    Password:

    1) Home Assistant  3) Configurator    5) Status
    2) App Daemon      4) FreeBSD         6) Exit
    Enter Number to Upgrade: 

---

  - Home Assistant: `http://YOUR.HOMEASSISTANT.IP.ADDRESS:8123`  
  - HADashboard   : `http://YOUR.HOMEASSISTANT.IP.ADDRESS:5050`  
  - Configurator  : `http://YOUR.HOMEASSISTANT.IP.ADDRESS:3218`  

---
---

#### iocage-plugin-homeassistant

 - This script can also be used to create an iocage-plugin for Home Assistant on FreeNAS 11.2
 - I recommend using this script to install a standard iocage-jail for Home Assistant as shown above

**Download plugin and install**

    wget -O /tmp/homeassistant.json https://raw.githubusercontent.com/tprelog/iocage-homeassistant/master/homeassistant.json
    sudo iocage fetch -P dhcp=on vnet=on bpf=yes -n /tmp/homeassistant.json --branch 'master'

---

###### To see a list of jails as well as their ip address

    sudo iocage list -l
    +-----+-----------------+------+-------+----------+-----------------+---------------------+-----+----------+
    | JID |      NAME       | BOOT | STATE |   TYPE   |     RELEASE     |         IP4         | IP6 | TEMPLATE |
    +=====+=================+======+=======+==========+=================+=====================+=====+==========+
    | 1   | homeassistant   | on   | up    | jail     | 11.2-RELEASE-p4 | epair0b|192.0.1.75  | -   | -        |
    +-----+-----------------+------+-------+----------+-----------------+---------------------+-----+----------+
    | 2   | homeassistant_2 | on   | up    | pluginv2 | 11.2-RELEASE-p4 | epair0b|192.0.1.77  | -   | -        |
    +-----+-----------------+------+-------+----------+-----------------+---------------------+-----+----------+


Last tested on FreeNAS-11.2-U1  
More information about [iocage plugins](https://doc.freenas.org/11.2/plugins.html) and [iocage jails](https://doc.freenas.org/11.2/jails.html) can be found in the [FreeNAS guide](https://doc.freenas.org/11.2/intro.html#introduction)  

