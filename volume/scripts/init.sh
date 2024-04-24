#!/usr/bin/env bash
####################
set -e
####################
readonly TOR_DATADIR="/volume/data/tor"
tor_hostname=
####################
setup_tor() {
	[ -e "${TOR_DATADIR}" ] || mkdir -p "${TOR_DATADIR}"
	cat << EOF > /etc/tor/torrc
HiddenServiceDir ${TOR_DATADIR}/prosody
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
EOF
	tor 1>/dev/null &
	while ! [ -e "${TOR_DATADIR}/prosody/hostname" ]; do
		printf 'waiting for tor hostname'
		sleep 1
	done
	tor_hostname="$(cat ${TOR_DATADIR}/prosody/hostname)"
}
setup_ssl() {
	/volume/scripts/ssl-setup.sh "${1}"
}
setup_prosody() {
	/volume/scripts/prosody-setup.sh
}
init() {
	setup_tor
	setup_ssl "${tor_hostname}"
	setup_prosody

	prosody &
	local prosody_pid="${!}"
	printf ${prosody_pid} > /volume/data/prosody.pid
	while ! [ -e "/var/log/prosody/prosody.log" ]; do
		printf 'waiting for prosody logfile to be created\n'
		sleep 1
	done

	tail -f /var/log/prosody/*.log &

	sleep 5
	printf "\nServer Hostname: ${tor_hostname} Port: 5222\n"
	printf "To create the admin user just insert the following command: \n"
	printf "<./control.sh prosodyctl \"register admin ${tor_hostname} password\">\n"
	printf "To create a new normal user just insert the same command, with another username instead of admin\n"
	printf "Registering the same user twice can be used to change the password (useful in forgotten password)\n"

	while kill -0 ${prosody_pid} 1>/dev/null 2>&1; do
		sleep 1
	done
}
####################
init
