#!/bin/bash

    hostname=$(cat /var/lib/tor/xmpp/hostname) 

    prosodyctl cert generate $hostname

    cd /etc/prosody/certs 
    ln -s /var/lib/prosody/$hostname.crt $hostname.crt
    ln -s /var/lib/prosody/$hostname.key $hostname.key

    service prosody restart 

    prosodyctl register admin $hostname 123

    prosodybackup

    echo -e "\n\n\n"
    echo "Prosody setted up, your user is admin and the password is 123" 
    echo "The hostname of you prosody server is $hostname:5222"
    echo "Log in with pidgin or other client and change your password"
    echo -e "\n\n\n"

    touch /app/prosody/data/hostname
    echo $hostname:5222 > /app/prosody/data/hostname

    echo '
*/10 * * * *     root    prosodybackup
#

' >> /etc/crontab