#!/usr/bin/env bash
####################
set -e
####################
/app/scripts/tor_setup.sh

hostname=$(su -c 'cat /app/data/tor/prosody/hostname' ${CONTAINER_USER})

su -c "/app/scripts/sslconfig.sh ${hostname}" ${CONTAINER_USER}

/app/scripts/prosody_setup.sh

su -c 'tail -f /var/log/prosody/*.log &' ${CONTAINER_USER}
sleep 2

printf "\nCongratulations, you're running your own Prosody XMPP Server!\n"
sleep 1
printf "Server Hostname: ${hostname} Port: 5222\n"
sleep 1
printf "To create the admin user just insert the following command: \n"
printf "<docker exec -it prosody prosodyctl register admin ${hostname} password>\n"
printf "\nTo create a new normal user just insert the same command, with another username instead of admin\n"

while pidof lua5.4 > /dev/null; do sleep 60; done
