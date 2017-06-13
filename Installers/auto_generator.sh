#!/bin/bash

#check the list of IPs of the instances in the network 
list=$(gcloud compute instances list | tail -n+2 | awk '{print $4}')

#a loop that take each IP to be verified
for ((i=1; i<=$(echo "$list" | wc -w); i++))
do
	#assign the IP to the variable
	Ip=$(echo "$list" | sed -n "$i p")

	#verify the IP
	if  grep -R $Ip /Network/Ips.txt
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
		
		#copy the nagios_host file in the instance
		gcloud compute copy-files /home/yojetoga/Nagios/Installers/Nagios_hosts yojetoga@$host:/home/yojetoga/
		gcloud compute copy-files /home/yojetoga/plugins.repo yojetoga@$host:/home/yojetoga/		

		#execute the installation of the repo and nagios
		gcloud compute ssh yojetoga@$host --command "sudo cp /home/yojetoga/plugins.repo /etc/yum.repos.d/plugins.repo"
		gcloud compute ssh yojetoga@$host --command "sudo yum repolist"
	 	gcloud compute ssh yojetoga@$host --command "sudo bash Nagios_hosts"
		gcloud compute ssh yojetoga@$host --command "sudo yum -y install plugins"
		gcloud compute ssh yojetoga@$host --command "sudo systemctl restart nrpe"
		
		systemctl restart nrpe nagios httpd
		
		#send a message to a cellphone number to confirm the changes
		echo "Changes in the Network - $host - $Ip were added to the network and configurated" | mail -s "project-y" *********@tmomail.net
		
		#save the IP in the Nagios-server
		echo $Ip >> /Network/Ips.txt

	fi
done
