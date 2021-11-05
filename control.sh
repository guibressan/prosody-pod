#!/usr/bin/env sh

case "$1" in

  up)
    containers/prosody/volume/scripts/animation.sh
    docker network create -d bridge prosody
    docker-compose up --build &
  ;;

  down)
    docker-compose down
    docker network rm prosody
  ;;

  *) printf "Usage: [up|down|help]"

esac