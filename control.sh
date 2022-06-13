#!/usr/bin/env bash
##############################################################################
# Docker Prosody Control File

##############################################################################
# Functions

createDirectories(){
  mkdir -p ./containers/prosody/volume/data
  mkdir -p ./containers/prosody/volume/data/verifications
  mkdir -p ./containers/prosody/volume/data/tor
  mkdir -p ./containers/prosody/volume/data/prosody
}

setScriptsPermissions(){
  chmod -R +x ./containers/prosody/volume/scripts/*.sh
}

clean(){
  rm -r ./containers/prosody/volume/data
}


##############################################################################
# Menu
case "$1" in

  up)
    containers/prosody/volume/scripts/animation.sh

    createDirectories
    setScriptsPermissions


    docker network create -d bridge prosody

    docker-compose up --build &
  ;;

  down)
    docker-compose down
    docker network rm prosody
  ;;

  clean)
    clean
  ;;

  *) printf 'Usage: [up|down|clean|help]\n'

esac