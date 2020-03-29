#!/bin/sh
# Author: David Kollarcik C 2020

### Variables ###
set -x
LATEST=`curl https://www.teamspeak.com/en/downloads/#server 2>/dev/null |grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep teamspeak3-server_linux_amd64 | sort -u`
TSDIRECTORY="teamspeak3-server_linux_amd64"
VERSION=`curl https://www.teamspeak.com/en/downloads/#server 2>/dev/null |grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep teamspeak3-server_linux_amd64 | sort -u | cut -d "/" -f 7`

### Functions ### 

DownloadNew () {
    echo "Start downloading TeamSpeak Files"
        wget $LATEST -P /tmp/teamspeak/
}

PrepareFiles () {
    echo "Start Preparing Files"
        tar -xjf /tmp/teamspeak/$VERSION -C /tmp/teamspeak/
}

DeployFiles () {
    echo "Checking differencies for TeamSpeak version"
        diff /tmp/teamspeak/$TSDIRECTORY/ts3server /opt/teamspeak3-server/ts3server
            if [ $? = 2 ]
                then mv /tmp/teamspeak/$TSDIRECTORY/* /opt/teamspeak3-server/
                     cp -r /tmp/teamspeak/$TSDIRECTORY/* /opt/teamspeak3-server/
                echo "Copying new version to /opt/teamspeak3-server/" 
            else
                echo "Your version is newest on the world"
            fi
}

ReturnCode () {
    if [ $? -eq 0 ]
        then
            echo " Success: TeamSpeak was sucessful prepared for using "
    exit 0
        else
            echo " Failure: TeamSpeak wasn't prepared check log " >&2
    exit 1
    fi
}

### Main ###

# Download New Version of TeamSpeak Files
DownloadNew
# Prepare Files from bz2 to Copy
PrepareFiles
# Deploy files to production without backup, we don't have a backup, we don't need backup
DeployFiles
# Restart TeamSpeak Server
systemctl restart teamspeak.service
# Return Code from Restart
ReturnCode
