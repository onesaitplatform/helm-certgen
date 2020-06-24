#!/bin/bash

# Load configuration file
source config.properties

# Generate and self-sign the Root CA
#===========================================================
openssl genrsa -out ca.key 2048

openssl req -new -x509 -days 3650 -key ca.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN1}" -out ca.crt

# Generate and sign the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout intermediate.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN2}" -out intermediate.csr
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}")  -in intermediate.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out intermediate.crt -days 2000 -sha256

# Generate a certificate and sign with the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${DNS}" -out server.csr
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}") -days 730 -in server.csr -CA intermediate.crt -CAkey intermediate.key -CAcreateserial -out server.crt

# Generate a certificate chain
#===========================================================
cat intermediate.crt ca.crt > fullchain.crt

# Verify the certificate (CRT) info

#============================================================
openssl x509 -in server.crt -text -noout

# Verifies the Chain of Trust
#============================================================
openssl verify -CAfile ca.crt intermediate.crt
openssl verify -verbose -CAfile <(cat intermediate.crt ca.crt) server.crt