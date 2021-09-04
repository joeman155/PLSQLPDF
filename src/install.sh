#!/bin/sh
# Name:   install.sh
# Purpose: Make it easy to install PDF creation
#

if [ $# -ne 3 ];
then
  echo "Usage $0 <username> <password> <DB Service>"
  exit;
fi

username=$1
password=$2
dbservice=$3

echo It is assumed you are logged on as user oracle on the DB server and you have
echo set your environment using oraenv.
echo
echo
echo Confirm username and password look right...
echo
echo Username: ${username}
echo Password: ${password}
echo DB Service: ${dbservice}
echo
echo Hit Enter to continue...
read a



sqlplus ${username}/${password}@${dbservice} @install 

