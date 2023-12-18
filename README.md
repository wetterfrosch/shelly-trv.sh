# shelly-trv.sh

Change profile of a Shelly TRVs of a user based on the presentness of MAC-addresses by its user, seen by a VyattaOS/Ubiquiti EdgeRouter.

## usage

Modify parameters in script, write script e.g. to /config/scripts/shelly-trv.sh and have a line like this in the /etc/crontab file of your EdgeRouter to call a schedule_profile of per-user relevant Shelly TRVs based on the availability of the ethernet device.

