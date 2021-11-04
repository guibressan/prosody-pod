# Docker Prosody: A Prosody XMPP server ambient

* To run this project, you will need to have docker and docker-compose installed in your Linux or Mac OS system

* Start the container

```bash
./up.sh
```

* If you're running for the first time, you will need to setup ssl, to do that, after start the container:

```bash
docker exec -it prosody sslconfig
```

* Stop the containers
```bash
./down.sh
```

* Attach to container bash
```bash
docker exec -it prosody bash
```

* Register new users:

```bash
docker exec -it prosody prosodyctl register <username> <hostname> <password>
```

* Reset all settings and data:

```bash
containers/prosody/volume/scripts/clean.sh
```