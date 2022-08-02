#!/bin/bash

#Richard Deodutt
#08/01/2022
#This script is a software management script meant for a server. It will automtically update a server using apt package manager when executed. Run with admin permissions when needed using cron to schedule the updates. The only parameter accepted is a file location for where the log file should be stored. 
#0 23 * * 5 richard sudo /bin/bash ~/bs1sfwmanagement.sh ~/.bs1sfwmanagement.log



#Logfile location
LogFile="$HOME/.bs1sfwmanagement.log"

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
        LogFile=".bs1sfwmanagement.log"
        touch $LogFile > /dev/null 2>&1
    fi
}



#Main script below

#Dealing with having a logfile as a commandline argument

#Check if we have atleast 1 argument
if [ $# -gt 0 ]; then 
    #Assuming the first argument is a log file, check if it exists
    if [ -f "$1" ]; then
        #Argument log file exists, using this file as a log file
        LogFile=$1
    else
        #Argument log file does not exists, attempt to create it and hide command errors
        touch $1 > /dev/null 2>&1
        #Check if argument log file creation worked
        if [ $? -eq 0 ]; then
            #Argument log file creation worked, using this file as a log file
            LogFile=$1
        else
            #Set up logfile and log error with the arugment
            setuplogfile
            log "Could not create log file: $1"
        fi
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