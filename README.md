# About this
This is my version of someone else's script to create PDF using PL/SQL

IT has a few enhancements to tables and likely I'll add more later on.


# What you get
A few scripts

./install.sh   - Installs code into schema and db of your choice
./init_test.sh - Sets up some config for testing
./test.sh      - Does a test


# What it does not do
It does not:-
1. create a database :-)
2. It does not create the user in which you want to install the scripts
3. It does set up appropriate access inside DB (e.g. create procedure, type, etc)
4. It relies upon set-up of your DB inside tnsnames.ora...i.e. it is resolveable.



