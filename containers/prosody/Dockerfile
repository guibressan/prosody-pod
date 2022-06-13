FROM ubuntu:22.04

RUN printf 'v2.1' > ~/version

RUN apt update

ARG DEBIAN_FRONTEND=noninteractive

RUN apt upgrade -y

RUN apt install -y links tor prosody lua-bitop lua-zlib nano vim

COPY $PWD/volume/scripts /scripts

RUN chmod 700 /scripts/init.sh

ENTRYPOINT ["/scripts/init.sh"]
