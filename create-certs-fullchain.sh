#!/bin/bash

# if an error occurs the script stops inmediately
set -e

# Load configuration file
source config.properties

mkdir $(pwd)/ssl

echo "------------------- Parameters -------------------"
echo $*
echo "------------------- Parameters -------------------"

params=("$@")

# Generate and self-sign the Root CA
#===========================================================
openssl genrsa -out ssl/ca.key 2048

openssl req -new -x509 -days 3650 -key ssl/ca.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN1}" -out ssl/ca.crt

# Generate and sign the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout ssl/intermediate.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN2}" -out ssl/intermediate.csr
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}$1")  -in ssl/intermediate.csr -CA ssl/ca.crt -CAkey ssl/ca.key -CAcreateserial -out ssl/intermediate.crt -days 2000 -sha256

# Generate a certificate and sign with the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout ssl/server.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${DNS}$1" -out ssl/server.csr
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}$1") -days 730 -in ssl/server.csr -CA ssl/intermediate.crt -CAkey ssl/intermediate.key -CAcreateserial -out ssl/server.crt

# Generate a certificate chain
#===========================================================
cat ssl/intermediate.crt ssl/ca.crt > ssl/fullchain.crt

# Verify the certificate (CRT) info

#============================================================
openssl x509 -in ssl/server.crt -text -noout

# Verifies the Chain of Trust
#============================================================
openssl verify -CAfile ssl/ca.crt ssl/intermediate.crt
openssl verify -verbose -CAfile <(cat ssl/intermediate.crt ssl/ca.crt) ssl/server.crt

key=$(cat ssl/intermediate.key | base64)
cert=$(cat ssl/fullchain.crt | base64)

# if [ ${#params[@]} == '--route-deploy' ]
echo "[INFO] Route manifest deletion if exists..."
echo $HELM_KUBECONTEXT

rm route-template/*.yml
echo "apiVersion: v1" >> route-template/route.yml
echo "kind: Route" >> route-template/route.yml
echo "metadata:" >> route-template/route.yml
echo "  name: frontend" >> route-template/route.yml
echo "spec:" >> route-template/route.yml
echo "  host: www.example.com" >> route-template/route.yml
echo "  to:" >> route-template/route.yml
echo "    kind: Service" >> route-template/route.yml
echo "    name: loadbalancer" >> route-template/route.yml
echo "  tls:" >> route-template/route.yml
echo "    termination: edge" >> route-template/route.yml
echo "    key: |" >> route-template/route.yml
echo "$key" >> route-template/route.yml
echo "    certificate: |" >> route-template/route.yml
echo "$cert" >> route-template/route.yml

exit 0
