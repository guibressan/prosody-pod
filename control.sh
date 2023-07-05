#!/usr/bin/env bash
####################
set -e
####################
createDirectories(){
  mkdir -p ./containers/prosody/volume/data
  mkdir -p ./containers/prosody/volume/data/verifications
  mkdir -p ./containers/prosody/volume/data/tor
  mkdir -p ./containers/prosody/volume/data/prosody
}

setScriptsPermissions(){
  chmod +x ./containers/prosody/volume/scripts/*.sh
}

clean(){
  rm -r ./containers/prosody/volume/data
}

startContainers(){
  if ! docker network ls | grep prosody > /dev/null; then 
    docker network create -d bridge prosody 
  fi
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g)
  docker-compose up --remove-orphans &
}

##############################################################################
# Menu
case "$1" in
  up)
    containers/prosody/volume/scripts/animation.sh
    createDirectories
    setScriptsPermissions
    startContainers
  ;;
  down)
    docker-compose down
  ;;
  clean)
    clean
  ;;
  *) printf 'Usage: [up|down|clean|help]\n' ;;

esac
