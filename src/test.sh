#!/bin/sh
# Name:   test.sh
# Purpose: Make it easy to test PDF creation
#

if [ $# -ne 3 ];
then
  echo "Usage $0 <username> <password> <DB Service>"
  exit;
fi


username=$1
password=$2
dbservice=$3



sqlplus ${username}/${password}@${dbservice} @test output.pdf

ls -al /tmp/output.pdf 
