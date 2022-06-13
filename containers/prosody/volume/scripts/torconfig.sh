#!/usr/bin/env bash
############################################################################################
# TOR CONFIG AND SETUP FILE
############################################################################################
# Functions

set_variables(){
    readonly tor_path='/app/data/tor'
    readonly hidden_service_path='/app/data/tor/prosody'
}

setup_hidden_service (){
    # Exiting if tor is setted up
    if [ -e ${hidden_service_path} ]; then
        return 1
    fi

    # Hidden service no setted up
    printf 'Creating Hidden Service\n'

    # Hidden Services
    printf "
HiddenServiceDir ${hidden_service_path}
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
    \n" >> /etc/tor/torrc

    return 0
}

set_tor_dir_permissions(){

    chown -R debian-tor:debian-tor ${tor_path}

    chown -R debian-tor:debian-tor ${hidden_service_path}/authorized_clients

    chown debian-tor:debian-tor ${hidden_service_path}/
    chmod 700 ${hidden_service_path}/

    chown debian-tor:debian-tor ${hidden_service_path}/hostname
    chmod 600 ${hidden_service_path}/hostname

    chown debian-tor:debian-tor ${hidden_service_path}/hs_ed25519_public_key
    chmod 600 ${hidden_service_path}/hs_ed25519_public_key

    chown debian-tor:debian-tor ${hidden_service_path}/hs_ed25519_secret_key
}

restore_hidden_service (){
    # Exiting if tor is not setted
    if [ ! -e ${hidden_service_path} ]; then
        return 1
    fi

    echo "Hidden service already setted, setting the permissions"

    # Hidden Services
    printf "
HiddenServiceDir ${hidden_service_path}
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
    \n" >> /etc/tor/torrc

    set_tor_dir_permissions
}

############################################################################################
# Code

set_variables

if setup_hidden_service; then
    printf 'Hidden Service created\n'
else
    restore_hidden_service
fi










