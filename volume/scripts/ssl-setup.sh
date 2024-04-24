#!/usr/bin/env bash
####################
set -e
####################
readonly certs_path="/volume/data/certs"
readonly cert_path="${certs_path}/${1}"
readonly cert_to="${1}"

readonly country='NA'
readonly state='NA'
readonly location='NA'
readonly company='NA'
####################
eprintln() {
	! [ -z "${1}" ] || eprintln 'eprintln: empty message'
	printf "${1}\n" 1>&2
	return 1
}
check() {
	! [ -z "${1}" ] || eprintln 'The service name must be passed by argument\n'
	! [ -e "${certs_path}/${1}" ] || exit 0
}
generate() {
	# Generate SSL keys
	printf "................GENERATING SSL CERTIFICATE TO: ${1}...............\n" 

	mkdir -p ${certs_path}
	mkdir -p ${certs_path}/root
	mkdir -p $cert_path

	# Generating RootCA
	if ( \
		! [ -e ${certs_path}/root/rootCA.key ] \
		|| ! [ -e ${certs_path}/root/rootCA.crt ] \
		); then
			printf 'Generating RootCA\n'
			cd ${certs_path}/root
			openssl req -x509 \
				-sha256 -days 3650 \
				-nodes \
				-newkey rsa:4096 \
				-subj "/CN=${company}/C=${country}/L=${location}" \
				-keyout rootCA.key -out rootCA.crt
	fi

	# Generating the server RSA private key
	if [ ! -e ${cert_path}/server.key ]; then
			printf 'Generating the server RSA private key\n'
			cd $cert_path
			openssl genrsa -out server.key 4096
	fi

	# Generating Certificate Signing Request configuration
	if [ ! -e ${cert_path}/csr.conf ]; then
			printf 'Generating Certificate Signing Request configuration\n'
			cd $cert_path
			cat << EOF > csr.conf
[ req ]
default_bits = 4096
prompt = no
default_md = sha512
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = ${country}
ST = ${state}
L = ${location}
O = ${company}
OU = ${company}
CN = ${cert_to}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${cert_to}
DNS.2 = upload.${cert_to}
IP.1 = 0.0.0.0
EOF
	fi

	# Generate Server CSR
	if [ ! -e ${cert_path}/server.csr ]; then
			printf 'Generate Server CSR\n'
			cd $cert_path
			openssl req -new -key server.key -out server.csr -config csr.conf
	fi

	# Create SSL Certificate Configuration
	if [ ! -e ${cert_path}/cert.conf ]; then
			printf 'Create SSL Certificate Configuration\n'
			cd $cert_path
			cat << EOF > cert.conf
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${cert_to}
DNS.2 = upload.${cert_to}
EOF
	fi

	# Generating SSL certificate
	if [ ! -e ${cert_path}/server.key ] || [ ! -e ${cert_path}/server.crt ]; then
			printf 'Generating SSL certificate\n'
			cd $cert_path
			openssl x509 -req \
			-in server.csr \
			-CA ${certs_path}/root/rootCA.crt -CAkey ${certs_path}/root/rootCA.key \
			-CAcreateserial -out server.crt \
			-days 3650 \
			-sha512 -extfile cert.conf
	fi
}
set_ownership(){
# Setting Certs Ownership
	chown -R ${CONTAINER_USER}:${CONTAINER_USER} ${certs_path}
}
setup() {
	check "${cert_to}"
	generate "${cert_to}"
	#set_ownership
}
####################
setup
