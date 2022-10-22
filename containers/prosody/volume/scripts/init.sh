#!/usr/bin/env bash
##############################################################################
# Docker Prosody Init File
##############################################################################
# Start / install services

    # Setting up HiddenService
    /app/scripts/torconfig.sh
    while [ ! -e /app/data/tor/prosody/hostname ]; do
        sleep 1
    done
    hostname=$(cat /app/data/tor/prosody/hostname)

    # Setting up SSL
    /app/scripts/sslconfig.sh ${hostname}

    # Setting up Prosody
    service prosody stop
    /app/scripts/prosodyconfig.sh
    service prosody start

    # Watching prosody logs
    ## "tail -f" will keep this container alive, if you want to watch some logfile, 
    ##  you can change /dev/null to the path of the logfile that you want to watch
    tail -f /var/log/prosody/* &

    sleep 2

    # Print some init messages
    printf "\n\nCongratulations, you're running your own Prosody XMPP Server!\n"
    sleep 1
    printf "\nServer Hostname: ${hostname} Port: 5222\n"
    sleep 1
    printf "\nTo create the admin user just insert the following command: \n"
    printf "<docker exec -it prosody prosodyctl register admin ${hostname} password>\n"
    printf "\nTo create a new normal user just insert the same command, with another username instead of admin\n"

    # Keep container running 
    tail -f /dev/null





