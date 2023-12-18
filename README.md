# shelly-trv.sh

Change profiles of Shelly TRVs of a user based on the presentness of his/her MAC-addresses, as seen by a VyattaOS/Ubiquiti EdgeRouter.

## usage

Modify parameters in script, write the script e.g. to `/config/scripts/shelly-trv.sh` and have a line like this in the `/etc/crontab` file of your EdgeRouter (updating every 10minutes) to call the schedule_profile of per-user-relevant Shelly TRVs based on the availability of ethernet devices of this user.

`*/10 *   * * *   root    /bin/sh /config/scripts/shelly-trv.sh`

## parameters



list of users:
```
    userList="userA
    userB"
```

list of all ethernet devices:
```
    ethernetDevices="ac:ab:13:12:ac:01,userA,mobile
    ac:ab:13:12:ac:02,userA,laptop
    ac:ab:13:12:ac:20,userB,mobile"
```

list of all Shelly TRV devices:
```
    thermostatDevices="ac:ab:13:12:00:01,userA,shellytrv-ACAB13120001
    ac:ab:13:12:00:02,userB,shellytrv-ACAB13120002"
```

password of Shelly TRVs (assuming username "admin"):
```
    secret="secret00!"
```

profile for "present":
```
    profilePresent="1"
```

profile for "absent":
```
    profileAbsent="2"
```
