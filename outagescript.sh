#!/bin/bash
# Writen by Tyler Wallenstein for Logikgear on 05/12/16 to moniter for internet outages
# Added directions to the the top of the file per request by logikgear 
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#  This script runs on a loop below are the settings that can be changed without advanced scripting changes                                  #
#  Depnding on what user starts this scrip you may need to create this file and give them perms if you levae it in var log                   #
#  Margin of error and timer work togther to deterin how senstive it is to outages                                                           #
#  Marginoferror X timer = number of seconds that need to elapse before the outage would be logged                                           #
#  Remotehost is an ip that is cheecked to make sure we can make to the interent, best to set this to somthing like 8.8.8.8 or 1.1.1.1       #
#  as if they are down we have a bigger problem then just no internet                                                                        #
#  gateway is the ip address of your router or firewall and is checked to make sure its not just the router that is holding up progress      #
#  as gnreal practice i would not run this script as the root user                                                                           #
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# user settings
LogPath="/var/log/outages.txt"
MarginOfError=5
RemoteHost="8.8.8.8"
Gateway="192.168.25.1"
timer=1

####dont edit below here unless your feeling brave####
RHdown=0
GWdown=0
rhp=0
gwp=0
now=`date`
atime_r=0
atime_g=0
echo "$now Outage Moniter Started Due to System Reboot" >> $LogPath

while(true)
 do
 now=`date`
 ping -c 1 $Gateway > /dev/null
 if [ $? == "0" ]
  then
   if [ $GWdown -ge "$MarginOfError" ]
    then
     echo "$now connection to the gateway restablished" >> $LogPath
     gwp=0
     GWdown=0
     atime_g=0
    else
     GWdown=0
     atime_g=0
   fi
    
   ping -c 1 $RemoteHost > /dev/null
   if [ $? == "0" ] 
    then 
     #echo $now internet connection detcted
     if [ $RHdown -ge "$MarginOfError" ]
      then
       echo "$now connection to the internet restablished" >> $LogPath
       rhp=0
       RHdown=0
       atime_r=0
      else
       RHdown=0
       atime_r=0
     fi

   else 
    RHdown=$((RHdown+1))
    if [ $RHdown == "1" ]
      then 
       atime_r=$now
    fi
    #echo $down
     if [ $RHdown -ge "$MarginOfError" ] && [ $rhp -eq 0 ]
      then echo "$atime_r connection to the internet lost" >> $LogPath
      rhp=$((rhp+1))
     fi
  fi
 else
  GWdown=$((GWdown+1))
  if [ $GWdown == "1" ]
      then 
       atime_g=$now
  fi
  
  if [ $GWdown -ge "$MarginOfError" ] && [ $gwp -eq 0 ]
   then echo "$atime_g connection to the gateway lost" >> $LogPath
   gwp=$((gwp+1))
  fi
  
 fi


 sleep $timer
 done
