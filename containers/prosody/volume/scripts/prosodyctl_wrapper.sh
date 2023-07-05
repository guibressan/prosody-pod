#!/usr/bin/env bash
####################
set -e
####################
su -c "prosodyctl ${1} ${2} ${3} ${4}" ${CONTAINER_USER}
