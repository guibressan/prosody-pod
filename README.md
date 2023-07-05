# Docker Prosody: A Prosody XMPP plug and play server
## Automated setup of a Prosody XMPP server with Onion routing by default

* Dependencies: docker and docker-compose
* Tested on Debian 12 host

* Start the container
```sh
./control.sh up
```

* Stop the containers
```sh
./control.sh down
```

* Attach to container bash
```sh
docker exec -it prosody bash
```

* Register new users:
```sh
./control.sh prosodyctl register <username> <hostname> <password>
```

* Reset all settings and data:
```sh
sudo ./control.sh clean
```
