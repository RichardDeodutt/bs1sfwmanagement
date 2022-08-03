#!/bin/bash

#Richard Deodutt
#08/01/2022
#This script is a software management script meant for a server. It will automtically update a server using apt package manager when executed. Run with admin permissions when needed using cron to schedule the updates. The only parameter accepted is a file location for where the log file should be stored. 
#0 23 * * 5 richard sudo /bin/bash /home/richard/bs1sfwmanagement.sh



#Logfile location
Date=$(echo `date +"%m-%d-%Y"`"_")
LogFile="$HOME/"$Date"bs1sfwmanagement.log"

#function to get a timestamp
timestamp(){
    echo $(date +"%m/%d/%Y | %a %b %d %Y || %H:%M:%S %Z | %I:%M:%S %p %Z")
}

#function to log text with a timestamp to a logfile
log(){
 echo "`timestamp` || $1" >> $LogFile
}

#function to set up a logfile
setuplogfile(){
    #create log file if it does not exist
    touch $LogFile > /dev/null 2>&1
    #Check if log file creation worked
    if [ ! $? -eq 0 ]; then
        #if the previous log file creation failed try one last time
        LogFile=$Date"bs1sfwmanagement.log"
        touch $LogFile > /dev/null 2>&1
    fi
}



#Main script below

#Dealing with having a logfile as a commandline argument

#Check if we have atleast 1 argument
if [ $# -gt 0 ]; then 
    #Assuming the first argument is a log file, check if it exists or create it and hide command errors
    touch $Date$1 > /dev/null 2>&1
    #Check if argument logfile exists or creation worked
    if [ $? -eq 0 ]; then
        #Argument log file exists/creation worked, using this file as a log file
        LogFile=$Date$1
    else
        #Set up logfile and log error with the arugment
        setuplogfile
        log "Could not create log file: $1"
    fi
fi

#Set up logfile if not run already
setuplogfile

#Log the logfile location
log "For this run the log file location is: $LogFile"

#Require admin permissions to run this script
if [ $UID != 0 ]; then
    log "This script was not run with admin permissions, run it again with admin permissions"
    exit 1
fi

#Using apt-get instead of apt because apt is meant for the terminal while apt-get is for scripts
#Update the package list, needed before a upgrade and ignore output
apt-get update > /dev/null 2>&1

#Run the Upgrade command to check what can be upgraded and their version changes
UpgradeCheck=$(apt-get upgrade -V --assume-no)

#Check if there is a upgrade available by checking if it asked to continue with a upgrade
CanUpgrade=$(echo "$UpgradeCheck" | grep -c "Do you want to continue?")

#The Number of Lines in the UpgradeCheck Variable
UpgradeLinesCount=$(echo "$UpgradeCheck" | wc -l)

#If CanUpgrade is 0 it means no upgrade is available, 1 means a upgrade is available
if [ $CanUpgrade -eq 0 ]; then
    log "$(echo "$UpgradeCheck" | tail -n 1)"
    log "All packages are up to date."
else
    log "Upgrade available."
    #Remove the last two lines from UpgradeCheck and the first 4 lines from UpgradeCheck to get a upgrade list that writes to file
    UpgradeList="$(echo "$UpgradeCheck" | head -n $((($UpgradeLinesCount - 2))) | tail -n $((($UpgradeLinesCount - 6))))"
    #The Number of Lines in the UpgradeList Variable for the for loop to write line by line to the log file
    UpgradeListCount=$(echo "$UpgradeList" | wc -l)
    for ((i=1;i<=UpgradeListCount;i++)); do
        log "$(echo "$UpgradeList" | head -n $i | tail -n 1)"
    done

    #Actually Upgrade the server and ignore output
    apt-get upgrade -y > /dev/null 2>&1

    #Check if the update worked
    if [ $? -eq 0 ]; then
        log "Update Successful"
    else
        log "Update Failed"
        exit 1
    fi
fi

log "Script Successfully ran"
exit 0