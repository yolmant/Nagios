#!/bin/bash

list=$(gcloud compute instances list | tail -n+2 | awk '{print $4}')

for ((i=1; i<=$(echo "$list" | wc -w); i++))
do
	Ip=$( echo "$list" | sed -n "$i p")
	if grep -R $Ip /Network/Ips.txt
	then
		echo "Ip already Included"
	else
		echo "Creating configuration"
		host=$(gcloud compute instances list | grep $Ip | cut -d' ' -f1)
		bash /home/yojetoga/Nagios/Installers/generator.sh $host $Ip
		echo $Ip >> /Network/Ips.txt
	fi
done
