#!/usr/bin/env bash
############################################################################################
# SSL config script
############################################################################################
# Constants declaration
readonly certs_path="/app/data/certs"
readonly cert_path="${certs_path}/${1}"
readonly cert_to="${1}"

readonly country='NA'
readonly state='NA'
readonly location='NA'
readonly company='NA'
############################################################################################
# Generate SSL keys

if [ -z ${1} ]; then
    printf 'The service name must be passed by argument\n'
    exit
fi

if [ -e ${certs_path}/${1} ]; then
    exit
fi

printf "................GENERATING SSL CERTIFICATE TO: ${1}...............\n" 

mkdir -p ${certs_path}
mkdir -p ${certs_path}/root
mkdir -p $cert_path

# Generating RootCA
if [ ! -e ${certs_path}/root/rootCA.key ] || [ ! -e ${certs_path}/root/rootCA.crt ]; then
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
    printf "
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
DNS.2 = "upload.${cert_to}"
IP.1 = 0.0.0.0
    " > csr.conf
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
    printf "
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${cert_to}
DNS.2 = "upload.${cert_to}"
    " > cert.conf
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

# Setting Certs Ownership
chown -R prosody:prosody ${certs_path}