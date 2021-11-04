#!/bin/bash



if [ -e /app/verifications/is_onion_set ]
then
    echo "Hidden service already setted, restoring files to container."
    

    service tor stop

    mkdir /var/lib/tor/xmpp/
    chown debian-tor:debian-tor /var/lib/tor/xmpp/
    chmod 700 /var/lib/tor/xmpp/
    
    cp /app/tor/data/lib/xmpp/hostname /var/lib/tor/xmpp/
    chown debian-tor:debian-tor /var/lib/tor/xmpp/hostname
    chmod 600 /var/lib/tor/xmpp/hostname

    cp /app/tor/data/lib/xmpp/hs_ed25519_public_key  /var/lib/tor/xmpp/
    chown debian-tor:debian-tor /var/lib/tor/xmpp/hs_ed25519_public_key
    chmod 600 /var/lib/tor/xmpp/hs_ed25519_public_key

    cp /app/tor/data/lib/xmpp/hs_ed25519_secret_key  /var/lib/tor/xmpp/
    chown debian-tor:debian-tor /var/lib/tor/xmpp/hs_ed25519_secret_key

    # Hidden Services
    echo "
        HiddenServiceDir /var/lib/tor/xmpp
        HiddenServicePort 5222 127.0.0.1:5222
        HiddenServicePort 5269 127.0.0.1:5269
    " >> /etc/tor/torrc

    service tor restart

else
    echo "Creating Hidden Service"
    
    service tor stop

    # Hidden Services
    echo "
        HiddenServiceDir /var/lib/tor/xmpp
        HiddenServicePort 5222 127.0.0.1:5222
        HiddenServicePort 5269 127.0.0.1:5269
    " >> /etc/tor/torrc

    service tor restart

    mkdir /app/tor/
    mkdir /app/tor/data
    mkdir /app/tor/data/lib
    mkdir /app/tor/data/etc
    cp -r /var/lib/tor/* /app/tor/data/lib/
    cp /etc/tor/torrc /app/tor/data/etc/
    
    touch /app/verifications/is_onion_set
    echo "Hidden Service created"
fi



