# Docker Prosody: A Prosody XMPP plug and play server
## This project implements the Prosody XMPP server with Onion routing by default

* To run this project, you will need to have docker and docker-compose installed in your Linux or Mac OS system

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
docker exec -it prosody prosodyctl register <username> <hostname> <password>
```

* Reset all settings and data:
```sh
sudo ./control.sh clean
```