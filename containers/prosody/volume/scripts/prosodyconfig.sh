#!/usr/bin/env bash
##############################################################################
# Prosody Config File

##############################################################################
# Variables
readonly hostname=$(cat /app/data/tor/prosody/hostname)
readonly data_path='/app/data/prosody'

##############################################################################


# rm -rf /var/lib/prosody/*
# cp -r /app/prosody/data/lib/prosody/* /var/lib/prosody/
# chown -R prosody:prosody /var/lib/prosody

# rm -rf /usr/lib/prosody/*
# cp -r /app/prosody/data/usr/prosody/* /usr/lib/prosody/
# chown -R root:prosody /usr/lib/prosody/

# rm -rf /etc/prosody/*
# cp -r /app/prosody/data/etc/prosody/* /etc/prosody
# chown -R root:prosody /etc/prosody

# Removing localhost config
if [ -e /etc/prosody/conf.d/*localhost* ]; then
    rm -rfv /etc/prosody/conf.avail/*localhost*
    rm -rfv /etc/prosody/conf.d/*localhost*
fi    

# Copying modules
cp /app/prosody/mod_onions.lua /usr/lib/prosody/modules/
chown root:root /usr/lib/prosody/modules/mod_onions.lua
chmod 644 /usr/lib/prosody/modules/mod_onions.lua

cp /app/prosody/mod_http_upload.lua /usr/lib/prosody/modules/
chown root:root /usr/lib/prosody/modules/mod_http_upload.lua
chmod 644 /usr/lib/prosody/modules/mod_http_upload.lua

# Setting up global prosody config
/app/scripts/prosodyconfigfileset.sh

# Setting datadir into global prosody config
printf "
data_path = \"/app/data/prosody\"
\n" >> /etc/prosody/prosody.cfg.lua

# Creating certificate symlink
mkdir -p /etc/prosody/certs
ln -s /app/data/certs/${hostname}/server.crt /etc/prosody/certs/${hostname}.crt
ln -s /app/data/certs/${hostname}/server.key /etc/prosody/certs/${hostname}.key

# Setting prosody hidden service host configuration
printf "

admins = { \"admin@${hostname}\" }

https_certificate = \"/etc/prosody/certs/${hostname}.crt\"

VirtualHost \"${hostname}\"
    disco_items = {
        { \"conference.${hostname}\", \"Public Chatrooms\" };
    }

modules_enabled = {\"onions\", \"register\"};
onions_only = \"true\";

Component \"upload.${hostname}\" \"http_upload\"
    http_upload_file_size_limit = 1024*10000

Component \"conference.${hostname}\" \"muc\"
    name = \"Prosody Chatrooms\"
    restrict_room_creation = \"true\"

\n" > /etc/prosody/conf.avail/${hostname}.cfg.lua

# Setting hidden service host symlink
ln -s /etc/prosody/conf.avail/${hostname}.cfg.lua /etc/prosody/conf.d/${hostname}.cfg.lua


