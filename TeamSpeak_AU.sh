#!/bin/sh
# Author: David Kollarcik C 2023

### Variables ###
TMP_FOLDER=/tmp/teamspeak
LATEST=`curl https://www.teamspeak.com/en/downloads/#server 2>/dev/null |grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep teamspeak3-server_linux_amd64 | sort -u`
TSDIRECTORY="teamspeak3-server_linux_amd64"
VERSION=`curl https://www.teamspeak.com/en/downloads/#server 2>/dev/null |grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | grep teamspeak3-server_linux_amd64 | sort -u | cut -d "/" -f 7`

### Functions ###

CreateFolder () {
  echo "Create folder if no exist"
    mkdir -p ${TMP_FOLDER}
}

DownloadNew () {
    echo "Start downloading TeamSpeak Files"
        wget ${LATEST} -P ${TMP_FOLDER}/
}

PrepareFiles () {
    echo "Start Preparing Files"
        tar -xjf ${TMP_FOLDER}/${VERSION} -C ${TMP_FOLDER}/
}

DeployFiles () {
    echo "Checking differencies for TeamSpeak version"
        diff ${TMP_FOLDER}/${TSDIRECTORY}/ts3server /opt/teamspeak3-server/ts3server
            if [ $? = 2 ]
                then mv ${TMP_FOLDER}/$TSDIRECTORY/* /opt/teamspeak3-server/
                     cp -r ${TMP_FOLDER}/$TSDIRECTORY/* /opt/teamspeak3-server/
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

RemoveTempFolder () {
    echo "Removing Temp folder"
    rm -Rf ${TMP_FOLDER}
}

### Main ###
# Create folder if no Exist
CreateFolder
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
# Remove Folder after success installation
RemoveTempFolder