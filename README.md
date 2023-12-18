# shelly-trv.sh

Change profile of the Shelly TRVs of a user based on the presentness of MAC-addresses by its user, seen by a VyattaOS/Ubiquiti EdgeRouter.

## usage

Modify parameters in script, write script e.g. to /config/scripts/shelly-trv.sh and have a line like this (updating every 10minutes) in the /etc/crontab file of your EdgeRouter to call the schedule_profile of per-user-relevant Shelly TRVs based on the availability of ethernet devices of this user.

`*/10 *   * * *   root    /bin/sh /config/scripts/shelly-trv.sh`
