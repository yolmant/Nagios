#!/bin/bash

#check the list of IPs of the instances in the network 
list=$(sudo gcloud compute instances list | tail -n+2 | awk '{print $4}')

#a loop that take each IP to be verified
for ((i=1; i<=$(echo "$list" | wc -w); i++))
do
	#assign the IP to the variable
	Ip=$(echo "$list" | sed -n "$i p")

	#verify the IP from the file IPs.txt created in Network directory using mkdir /Network
	if grep $Ip /Network/Ips.txt
	then
		#if the IP is already in the Nagios
		echo "Ip already Included"
	else
		#if the Ip is not create the configuration file for Nagios
		echo "Creating configuration"

		#obtain the name of the host
		host=$(sudo gcloud compute instances list | grep $Ip | cut -d' ' -f1)
		
		#execute the genrator file
		sudo bash /home/yojetoga/Nagios/Installers/generator.sh $host $Ip
		
		#copy the nagios_host file in the instance
		sudo gcloud compute copy-files /home/yojetoga/Nagios/Installers/Nagios_hosts yojetoga@$host:/home/yojetoga/
		sudo gcloud compute copy-files /home/yojetoga/plugins.repo yojetoga@$host:/home/yojetoga/		

		#execute the installation of the repo and nagios
		sudo gcloud compute ssh yojetoga@$host --command "sudo cp /home/yojetoga/plugins.repo /etc/yum.repos.d/plugins.repo"
		sudo gcloud compute ssh yojetoga@$host --command "sudo yum repolist"
	 	sudo gcloud compute ssh yojetoga@$host --command "sudo bash Nagios_hosts"
		sudo gcloud compute ssh yojetoga@$host --command "sudo yum -y install plugins"
		sudo gcloud compute ssh yojetoga@$host --command "sudo systemctl restart nrpe"
		
		sudo systemctl restart nrpe nagios httpd
		
		#send a message to a cellphone number to confirm the changes
		echo "Changes in the Network - $host - $Ip were added to the network and configurated" | mail -s "project-y" 18328710948@tmomail.net
		
		#save the IP in the Nagios-server
		sudo sh -c "echo '$Ip' >> /Network/Ips.txt"

	fi
done
