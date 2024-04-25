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
	' || true
	podman stop "${CONTAINER_NAME}" || true
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
mk_systemd() {
	! [ -e "/etc/systemd/system/${CONTAINER_NAME}.service" ] || eprintln "service ${CONTAINER_NAME} already exists"
	local user="${USER}"
	sudo bash -c "cat << EOF > /etc/systemd/system/${CONTAINER_NAME}.service
[Unit]
Description=Prosody Pod
After=network.target

[Service]
Environment=\"PATH=/usr/local/bin:/usr/bin:/bin:${PATH}\"
User=${user}
Type=forking
ExecStart=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh up\"
ExecStop=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh down\"
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
"
	sudo systemctl enable "${CONTAINER_NAME}".service
}
rm_systemd() {
	[ -e "/etc/systemd/system/${CONTAINER_NAME}.service" ] || return 0
	sudo systemctl stop "${CONTAINER_NAME}".service || true
	sudo systemctl disable "${CONTAINER_NAME}".service
	sudo rm /etc/systemd/system/"${CONTAINER_NAME}".service
}
####################
common
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	prosodyctl) prosodyctl "${2}" ;;
	clean) clean ;;
	mk-systemd) mk_systemd ;;
	rm-systemd) rm_systemd ;;
	nop) ;;
	*) eprintln 'usage: < build | up | down | clean | prosodyctl | mk-systemd | rm-systemd | help >' ;;
esac
