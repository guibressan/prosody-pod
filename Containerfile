FROM docker.io/library/debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN \
	set -e; \
	apt update; \
	apt install -y --no-install-recommends \
		prosody tor lua-bitop lua-zlib lua-unbound

ENTRYPOINT ["/volume/scripts/init.sh"]
