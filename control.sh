#!/usr/bin/env bash
####################
set -e
####################
readonly RELDIR="$(dirname ${0})"
readonly IMAGE_NAME="prosody"
####################
eprintln() {
	! [ -z "${1}" ] || eprintln 'eprintln: empty message'
	printf "${1}\n" 1>&2
	return 1
}
common() {
	[ -e "${RELDIR}/.env" ] || eprintln ".env not found" 
	source "${RELDIR}/.env"
	! [ -z "${CONTAINER_NAME}" ] || eprintln 'undefined env: CONTAINER_NAME'
	[ -e "${RELDIR}/volume/data" ] || mkdir -p "${RELDIR}/volume/data"
	chmod +x "${RELDIR}/volume/scripts"/*.sh
}
build() {
	podman build \
		-f="${RELDIR}/Containerfile" \
		--tag="${IMAGE_NAME}" \
		"${RELDIR}"
}
up() {
	podman run \
		--rm \
		-v="${RELDIR}/volume:/volume" \
		--name="${CONTAINER_NAME}" \
		"localhost/${IMAGE_NAME}" &
}
down() {
	podman exec "${CONTAINER_NAME}" bash -c '
		while kill -15 $(cat /volume/data/prosody.pid) 1>/dev/null 2>&1; do 
			printf "stopping prosody\n"
			sleep 1
		done
	'
	podman stop "${CONTAINER_NAME}"
}
prosodyctl() {
	podman exec ${CONTAINER_NAME} bash -c "prosodyctl ${1}"
}
clean() {
	printf 'are you sure? This will delete all the data (Y/n): '
	read v
	[ "${v}" == "Y" ] || eprintln 'abort!'
	sudo rm -rf "${RELDIR}/volume/data"
}
####################
common
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	prosodyctl) prosodyctl "${2}" ;;
	clean) clean ;;
	nop) ;;
	*) eprintln 'usage: < build | up | down | clean | prosodyctl | help >' ;;
esac
