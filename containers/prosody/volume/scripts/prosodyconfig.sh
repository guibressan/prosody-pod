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

    if [ -e /etc/prosody/conf.d/*localhost* ]; then
        rm -rfv /etc/prosody/conf.avail/*localhost*
        rm -rfv /etc/prosody/conf.d/*localhost*
    fi    

    if [ -e /etc/prosody/certs/${hostname}.crt ]; then
        printf "\n\nSymlinks apparently ok!\n\n"
        sleep 1
    else
        printf "\n\nSymlinks broken, rebuilding...\n\n"
        cd /etc/prosody/conf.d || exit 1
        ln -s /etc/prosody/conf.avail/${hostname}.cfg.lua ${hostname}.cfg.lua

        mkdir -p /etc/prosody/certs
        cd /etc/prosody/certs || exit 1
        ln -s /var/lib/prosody/${hostname}.crt ${hostname}.crt
        ln -s /var/lib/prosody/${hostname}.key ${hostname}.key
    fi


    service prosody restart

    cp /app/scripts/prosodybackup.sh /bin/prosodybackup
    chmod +x /bin/prosodybackup
    prosodybackup

    echo '
0 0 * * *     root    prosodybackup
#

' >> /etc/crontab

    #Verifying if prosody started
    printf "\n\n"
    while [ $(( 1 == 1 )) ]; do 
        if [ -e /var/log/prosody/prosody.log ]; then
            sleep 1
            break
        else
            sleep 1
        fi
    done

    printf "\n\n\nThe hostname of your Prosody server is %s$hostname and the port is 5222\n\n\n\n"

else
    echo "Setting up prosody"

    cp /app/prosody/mod_onions.lua /usr/lib/prosody/modules/
    chown root:root /usr/lib/prosody/modules/mod_onions.lua
    chmod 644 /usr/lib/prosody/modules/mod_onions.lua

    cp /app/prosody/mod_http_upload.lua /usr/lib/prosody/modules/
    chown root:root /usr/lib/prosody/modules/mod_http_upload.lua
    chmod 644 /usr/lib/prosody/modules/mod_http_upload.lua

    hostname=$(cat /var/lib/tor/xmpp/hostname)

    cp /app/prosody/prosody.cfg.lua /etc/prosody/prosody.cfg.lua
    chown root:prosody /etc/prosody/prosody.cfg.lua
    chmod 644 /etc/prosody/prosody.cfg.lua

    cd /etc/prosody/conf.avail ||exit 1
    touch "${hostname}".cfg.lua

    echo "

admins = { \"admin@${hostname}\" }

https_certificate = \"/etc/prosody/certs/${hostname}.crt\"

VirtualHost \"${hostname}\"
    disco_items = {
        { \"conference.${hostname}\", \"Public Chatrooms\" };
    }

modules_enabled = {\"onions\", \"register\"};
onions_only = true;

Component \"upload.${hostname}\" \"http_upload\"
    http_upload_file_size_limit = 1024*10000

Component \"conference.${hostname}\" \"muc\"
    name = \"Prosody Chatrooms\"
    restrict_room_creation = \"true\"


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