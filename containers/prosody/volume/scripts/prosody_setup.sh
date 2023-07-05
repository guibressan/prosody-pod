#!/usr/bin/env bash
####################
set -e
####################
# Variables
readonly hostname="$(su -c 'cat /app/data/tor/prosody/hostname' ${CONTAINER_USER})"
readonly data_path='/app/data/prosody'
####################
set_ownership(){
  mkdir -p /run/prosody
  chown -R ${CONTAINER_USER}:${CONTAINER_USER} /etc/prosody /usr/lib/prosody /var/lib/prosody /var/log/prosody /run/prosody
}
remove_localhost_config(){
  if [ -e /etc/prosody/conf.d/*localhost* ]; then
      rm -rfv /etc/prosody/conf.avail/*localhost*
      rm -rfv /etc/prosody/conf.d/*localhost*
  fi    
}
copy_lua_modules(){
cp /app/prosody/mod_onions.lua /usr/lib/prosody/modules/
chmod 644 /usr/lib/prosody/modules/mod_onions.lua

cp /app/prosody/mod_http_upload.lua /usr/lib/prosody/modules/
chmod 644 /usr/lib/prosody/modules/mod_http_upload.lua
}
set_prosody_global_config(){
  /app/scripts/prosodyconfigfileset.sh
  cat << EOF >> /etc/prosody/prosody.cfg.lua
  data_path = "${data_path}"
EOF
}
set_prosody_certificate_link(){
  mkdir -p /etc/prosody/certs
  ln -sf /app/data/certs/${hostname}/server.crt /etc/prosody/certs/${hostname}.crt
  ln -sf /app/data/certs/${hostname}/server.key /etc/prosody/certs/${hostname}.key
  chown -R prosody:prosody /etc/prosody/certs/*
}
set_prosody_hidden_service_config(){
  cat << EOF > /etc/prosody/conf.avail/${hostname}.cfg.lua
  admins = { "admin@${hostname}" }

  https_certificate = "/etc/prosody/certs/${hostname}.crt"

  VirtualHost "${hostname}"
      disco_items = {
          { "conference.${hostname}", "Public Chatrooms" };
      }

  modules_enabled = {"onions", "register"};
  onions_only = "true";

  Component "upload.${hostname}" "http_upload"
      http_upload_file_size_limit = 1024*10000

  Component "conference.${hostname}" "muc"
      name = "Prosody Chatrooms"
      restrict_room_creation = "true"
EOF
  ln -sf /etc/prosody/conf.avail/${hostname}.cfg.lua /etc/prosody/conf.d/${hostname}.cfg.lua
}
run(){
  su -c 'prosody &' ${CONTAINER_USER}
}
setup(){
  set_ownership
  remove_localhost_config
  copy_lua_modules
  set_prosody_global_config
  set_prosody_certificate_link
  set_prosody_hidden_service_config
  set_ownership
  run
}
####################
setup
