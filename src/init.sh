#!/bin/sh
# Name:   install.sh
# Purpose: Make it easy to initialise directory object for testing sample
#


echo 
echo It is assumed you are logged on as user oracle on the DB server and you have
echo set your environment using oraenv.
echo
echo Hit Enter to continue...
read a




sqlplus / as sysdba @init_test
