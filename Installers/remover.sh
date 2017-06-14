#!/bin/bash

#remove the IP from the file
sed -i "s/$2//g" /Network/Ips.txt

#remove the nagios configuration of the host
rm -rf /etc/nagios/conf.d/$1.cfg

#restart nagios
systemctl restart nagios nrpe
