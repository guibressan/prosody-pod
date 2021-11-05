#!/usr/bin/env sh

if [ -e /app/verifications/is_prosody_set ]; then
    echo "Prosody service already setted, restoring files to container."

    hostname=$(cat /var/lib/tor/xmpp/hostname)

    service prosody stop

    rm -rf /var/lib/prosody/*
    cp -r /app/prosody/data/lib/prosody/* /var/lib/prosody/
    chown -R prosody:prosody /var/lib/prosody
    #chmod -R 777 /var/lib/prosody

    rm -rf /usr/lib/prosody/*
    cp -r /app/prosody/data/usr/prosody/* /usr/lib/prosody/
    chown -R root:prosody /usr/lib/prosody/
    #chmod -R 777 /usr/lib/prosody/

    rm -rf /etc/prosody/*
    cp -r /app/prosody/data/etc/prosody/* /etc/prosody
    chown -R root:prosody /etc/prosody
    #chmod -R 777 /etc/prosody

    service prosody restart

    cp /app/scripts/prosodybackup.sh /bin/prosodybackup
    chmod +x /bin/prosodybackup
    prosodybackup

    echo '
*/10 * * * *     root    prosodybackup
#

' >> /etc/crontab

    printf "\n\n\nThe hostname of your Prosody server is %s$hostname and the port is 5222\n\n\n\n"

else
    echo "Setting up prosody"

    cp /app/prosody/mod_onions.lua /usr/lib/prosody/modules/
    chown root:root /usr/lib/prosody/modules/mod_onions.lua
    chmod 644 /usr/lib/prosody/modules/mod_onions.lua

    hostname=$(cat /var/lib/tor/xmpp/hostname)

    cp /app/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
    chown root:prosody /etc/prosody/prosody.cfg.lua
    chmod 644 /etc/prosody/prosody.cfg.lua

    cd /etc/prosody/conf.avail ||exit 1
    touch "${hostname}".cfg.lua

    echo "

VirtualHost \"${hostname}\"

ssl = {
    key = \"/etc/prosody/certs/${hostname}.key\";
    certificate = \"/etc/prosody/certs/${hostname}.crt\";
}

modules_enabled = {\"onions\"};
onions_only = true;

    " > "${hostname}.cfg.lua"

    cd /etc/prosody/conf.d || exit 1

    ln -s /etc/prosody/conf.avail/"${hostname}".cfg.lua "${hostname}".cfg.lua

    service prosody restart

    cp /app/scripts/sslconfig.sh /bin/sslconfig
    chmod +x /bin/sslconfig

    cp /app/scripts/prosodybackup.sh /bin/prosodybackup
    chmod +x /bin/prosodybackup

    touch /app/verifications/is_prosody_set
fi