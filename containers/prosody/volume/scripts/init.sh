#!/usr/bin/env sh

## You can put some message here
echo "You're welcome!"

sleep 2

service cron start

mkdir /app/verifications

# Start / install services
##############################################################################
##############################################################################
if [ -e /app/verifications/not_first_run ]; then
    echo "Prosody already configured, starting services"

    #Setting up HiddenService
    /app/scripts/torconfig.sh

    #Setting up Prosody
    /app/scripts/prosodyconfig.sh

    ## "tail -f" will keep this container alive, if you want to watch some logfile, you can change /dev/null to the path of the logfile that you want to watch
    tail -f /var/log/prosody/*

else
    echo "Setting up Prosody"

    #Setting up HiddenService
    /app/scripts/torconfig.sh

    #Setting up Prosody
    /app/scripts/prosodyconfig.sh

    touch /app/verifications/not_first_run
    echo "Done! Please configure the SSL (docker exec -it prosody sslconfig)"

    ## "tail -f" will keep this container alive, if you want to watch some logfile, you can change /dev/null to the path of the logfile that you want to watch
    tail -f /dev/null

fi

# /app/scripts/test.sh
##############################################################################
##############################################################################


