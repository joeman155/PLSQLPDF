#!/bin/sh
# Name:   test.sh
# Purpose: Make it easy to test PDF creation
#

if [ $# -ne 2 ];
then
  echo "Usage $0 <username> <password>"
  exit;
fi


sqlplus ${username}/${password} @test output.pdf

ls -al /tmp/output.pdf 
