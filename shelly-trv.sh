#!/bin/sh
# Change profile of a Shelly TRVs of a user based on the presentness
# of MAC-addresses by its user, seen by a VyattaOS/Ubiquiti EdgeRouter.
#
# 2023-12-18 wtf v0.0
# https://github.com/wetterfrosch/shelly-trv.sh/

userList="userA
userB"

ethernetDevices="ac:ab:13:12:ac:01,userA,mobile
ac:ab:13:12:ac:02,userA,laptop
ac:ab:13:12:ac:20,userB,mobile"

thermostatDevices="ac:ab:13:12:00:01,userA,shellytrv-ACAB13120001
ac:ab:13:12:00:02,userB,shellytrv-ACAB13120002"

secret="secret00!"
profilePresent="1"
profileAbsent="2"

lastStateFile="/tmp/shelly-trv-last"
newStateFile="/tmp/shelly-trv-new"

# checking each user
rm -rf $newStateFile
for user in $userList; do
	echo ""
	userState="absent"
	printf "[${user}]\n"

	# checking up to each device of a user
	userEthernetDevices=$(echo $ethernetDevices | sed 's/ /\n/g' | grep $user )
	for ethernetDevice in $userEthernetDevices; do
		thermostatMac="$(echo $ethernetDevice | cut -d"," -f1)"
		deviceName="$(echo $ethernetDevice | cut -d"," -f3)"

		# check if device is in our ARP table
		printf -- "- $deviceName (${thermostatMac}) is "
		arpCheck="$(/usr/sbin/arp -n | grep $thermostatMac)"
		arpCheckResult="$(echo $?)"
		if [ "$arpCheckResult" = "0" ]; then
			userState="present"
			printf "OK!\n"
			break
		else
			# check if we've leased a IPv4-adress to this device and if its pingable
			deviceIpv4="$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show dhcp leases | grep $thermostatMac | cut -d" " -f1)"
			if [ "$deviceIpv4" = "" ]; then
				printf "FAIL!\n"
			else
				printf "pinging $deviceIpv4"
				pingCheck="$(ping -c 3 $deviceIpv4)"
				pingCheckResult="$(echo $?)"
				if [ "$pingCheckResult" = "0" ]; then
					userState="present"
					printf "OK!\n"
					break
				else
					printf "FAIL!\n"
				fi
			fi
		fi
	done

	# caputure current state
	printf "* ${user} is ${userState} "
	echo "${user},${userState}" >> $newStateFile

	# get last known state
	lastUserState="$(grep ${user} $lastStateFile | cut -d"," -f2)"
	printf "(last: $lastUserState) "

	# compare current and last known state
	if [ "$userState" = "$lastUserState" ]; then
		printf "> No change.\n"
	else
		printf "> Change!\n"

		if [ "$userState" = "absent" ]; then
			submitProfile="$profileAbsent"
		elif [ "$userState" = "present" ]; then
			submitProfile="$profilePresent"
		fi

		# change all thermostats of this user
		userThermostatDevices=$(echo $thermostatDevices | sed 's/ /\n/g' | grep $user )
		for thermostatDevice in $userThermostatDevices; do
			thermostatMac="$(echo $thermostatDevice | cut -d"," -f1)"
			thermostatIpv4="$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show dhcp leases | grep $thermostatMac | cut -d" " -f1)"

			printf "# thermostat $thermostatMac ($thermostatIpv4): new profile = $submitProfile\n"
			changeSubmitResult="$(curl -s -X POST -u "admin:${secret}" "http://${thermostatIpv4}/settings/thermostats/0?schedule_profile=${submitProfile}" | jq ".schedule_profile")"
			printf "profile now saved: $changeSubmitResult"

			if [ "$changeSubmitResult" = "$submitProfile" ]; then
				printf " OK!!\n"
			else
				printf " ERR!!\n"
			fi
		done
		



	fi
done

mv -f $newStateFile $lastStateFile
