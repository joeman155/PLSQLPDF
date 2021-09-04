#!/bin/sh
# Name:   install.sh
# Purpose: Make it easy to initialise directory object for testing sample
#


if [ $# -ne 2 ];
then
   echo "Usage $0 <SYS Password> <DB Service>"
   exit;
fi

sys_pw=$1
dbservice=$2

echo 
echo It is assumed you are logged on as user oracle on the DB server and you have
echo set your environment using oraenv.
echo
echo Hit Enter to continue...
read a




sqlplus "sys/${sys_pw}@${dbservice} as sysdba" @init_test
