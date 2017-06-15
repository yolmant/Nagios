#!/bin/bash

if [[  $# -eq 0 ]]; then                       	 # If no arguments are given to the script
   
	echo "No arguments: Usage:              
 	config_generator hostname ip
   	"
   	
	exit 0;
fi
	
Host="$1"
IP="$2"

#create a file configuration for the remote host
sh -c "cat > /etc/nagios/conf.d/$Host.cfg" << EF
#define host
define host {
        use             linux-server
        host_name       $Host
        alias           $Host
        address         $IP
        }

#DEFINING SERVICES

#PING service
define service{
        use                     generic-service
        host_name               $Host
        service_description     PING
        check_command           check_ping!100.0,20%!500.0,60%
        }

#HTTP services check
define service{
        use                     generic-service
        host_name               $Host
        service_description     HTTP
        check_command           check_http
        }


#SSH service check
define service{
        use                     generic-service
        host_name               $Host
        service_description     SSH
        check_command           check_ssh
        }

#Disk service check      
define service{
        use                     generic-service         
        host_name               $Host
        service_description     Root Partition
        check_command	        check_nrpe!check_disk!20%!10%!/
        }

#User service chech
define service{
        use                     generic-service      
        host_name               $Host
        service_description     Current Users
        check_command		check_nrpe!check_users!20!50
        }

#Proccess service check
define service{
        use                     generic-service        
        host_name               $Host
        service_description     Total Processes
        check_command	        check_nrpe!check_procs!250!400!RSZDT
        }

#Load Balance service check
define service{
        use                      generic-service        
        host_name                $Host
        service_description      Current Load
        check_command	         check_nrpe!check_load!5.0,4.0,3.0!10.0,6.0,4.0
        }
#Memory RAM service check
define service{
        use                      generic-service
        host_name                $Host
        service_description      Check RAM
        check_command            check_nrpe!check_mem
        }
EF
