#!/bin/bash
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
#Script Name: gmetric.sh
#Date: Sep 06th, 2017. 
#Modified: Apr 16th, 2017
#Versioning: 0.1 = UPdated hostip, username and password as veriable.
#Author: Krishna Bagal.
#Info: Tomcat thread and memory information/Value send to ganglia server.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
value='^[0-9]+([.][0-9]+)?$'
hostip=`ip route get 1 | awk '{print $NF;exit}'`
user="USERNAME"
password="PASSWORD"

T8080=`check_tomcat.py -H $hostip -p 8080 -u $user -a $password -m thread -w 999 -c 1000 -U "/manager" -C \"http-bio-8080\" |awk {'print $3'}`
M8080=`check_tomcat.py -H $hostip -p 8080 -u $user -a $password -m mem -w 90 -c 99 | cut -d= -f2 |cut -d% -f1`
if ! [[ $T8080 =~ $value ]] ; 
then
           /usr/bin/gmetric --name  Tomcat-Thread-8080 --value 0 --type int32 --unit Count
else
           /usr/bin/gmetric --name  Tomcat-Thread-8080 --value $T8080 --type int32 --unit Count
fi
if ! [[ $M8080 =~ $value ]] ; 
then
           /usr/bin/gmetric --name  Tomcat-Memory-8080 --value 0 --type int32 --unit %
else
         
           /usr/bin/gmetric --name  Tomcat-Memory-8080 --value $M8080 --type int32 --unit %
fi
