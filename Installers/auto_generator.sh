#!/bin/bash

#check the list of IPs of the instances in the network 
list=$(gcloud compute instances list | tail -n+2 | awk '{print $4}')

#a loop that take each IP to be verified
for ((i=1; i<=$(echo "$list" | wc -w); i++))
do
	#assign the IP to the variable
	Ip=$( echo "$list" | sed -n "$i p")

	#verify the IP
	if grep -R $Ip /Network/Ips.txt
	then
		#if the IP is already in the Nagios
		echo "Ip already Included"
	else
		#if the Ip is not create the configuration file for Nagios
		echo "Creating configuration"

		#obtain the name of the host
		host=$(gcloud compute instances list | grep $Ip | cut -d' ' -f1)
		#execute the genrator file
		bash /home/yojetoga/Nagios/Installers/generator.sh $host $Ip
		
		#save the IP in the Nagios-server
		echo $Ip >> /Network/Ips.txt
	fi
done
