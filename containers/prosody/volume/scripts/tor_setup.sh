#!/usr/bin/env bash
####################
set -e
####################
readonly HIDDEN_SERVICE_PATH='/app/data/tor/prosody'
####################
set_config(){
  if grep "${HIDDEN_SERVICE_PATH}" /etc/tor/torrc > /dev/null; then return 0; fi
  cat << EOF >> /etc/tor/torrc
HiddenServiceDir ${HIDDEN_SERVICE_PATH}
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
EOF
}
run(){
  su -c 'tor > /dev/null &' ${CONTAINER_USER}
  su -c "while ! [ -e ${HIDDEN_SERVICE_PATH}/hostname ]; do sleep 1; done" ${CONTAINER_USER}
}
setup(){
  set_config
  run
}
####################
setup
