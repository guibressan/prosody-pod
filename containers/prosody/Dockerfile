FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID

ENV CONTAINER_USER=${CONTAINER_USER}
ENV CONTAINER_UID=${CONTAINER_UID}
ENV CONTAINER_GID=${CONTAINER_GID}

ADD volume/scripts/init.sh /scripts/init.sh
ADD volume/scripts/user_setup.sh /scripts/user_setup.sh

RUN \
echo 'v2.2.0' > /version; \
apt update && \
apt upgrade -y && \
apt install -y links tor prosody \
lua-bitop lua-zlib; \
/scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID}

ENTRYPOINT ["/scripts/init.sh"]
