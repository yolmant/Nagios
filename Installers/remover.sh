#!/bin/bash

#remove the IP from the file
sudo sed -i "s/$2//g" /Network/Ips.txt

#remove blank spaces in the file
sudo sed -i 's/[\t ]//g;/^$/d' /Network/Ips.txt 

#remove the nagios configuration of the host
sudo rm -rf /etc/nagios/conf.d/$1.cfg

#restart nagios
sudo systemctl restart nagios nrpe
