#!/bin/bash

# if an error occurs the script stops inmediately
set -e

help() {
  echo
  echo "Plugin usage:"
  echo
  echo "helm certgen --domain *.example.com --host onesaitplatform.example.com"
  echo
}

parseParams() {

  if [[ ${#params[@]} -lt 4 ]]; then
    echo "Bad number of params!"
    help
    exit 1
  fi

  if [[ ${params[0]} != '--domain' ]]; then
    echo "Bad parameter! --domain"
    help
    exit 1
  fi

  if [[ ${params[2]} != '--host' ]]; then
    echo "Bad parameter! --host"
    help
    exit 1
  fi

  domain=${params[1]}
  host=${params[3]}

}

# Load configuration file
source $HELM_PLUGIN_DIR/config.properties

echo "K8s Namespace: "$HELM_NAMESPACE

if [[ ! -d  $(pwd)/ssl ]]; then
  mkdir $(pwd)/ssl
fi

params=("$@")

parseParams

echo $domain
echo $host

# Generate and self-sign the Root CA
#===========================================================
openssl genrsa -out ssl/ca.key 2048 >> tracefile.out

openssl req -new -x509 -days 3650 -key ssl/ca.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN1}" -out ssl/ca.crt >> tracefile.out

# Generate and sign the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout ssl/intermediate.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN2}" -out ssl/intermediate.csr >> tracefile.out
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}$domain")  -in ssl/intermediate.csr -CA ssl/ca.crt -CAkey ssl/ca.key -CAcreateserial -out ssl/intermediate.crt -days 2000 -sha256 >> tracefile.out

# Generate a certificate and sign with the intermediate CA
#============================================================
openssl req -newkey rsa:2048 -nodes -keyout ssl/server.key -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${DNS}$domain" -out ssl/server.csr >> tracefile.out
openssl x509 -req -extfile <(printf "subjectAltName=${DNS}$domain") -days 730 -in ssl/server.csr -CA ssl/intermediate.crt -CAkey ssl/intermediate.key -CAcreateserial -out ssl/server.crt >> tracefile.out

# Generate a certificate chain
#===========================================================
cat ssl/intermediate.crt ssl/ca.crt > ssl/fullchain.crt

# Verify the certificate (CRT) info

#============================================================
openssl x509 -in ssl/server.crt -text -noout >> tracefile.out

# Verifies the Chain of Trust
#============================================================
openssl verify -CAfile ssl/ca.crt ssl/intermediate.crt >> tracefile.out
openssl verify -verbose -CAfile <(cat ssl/intermediate.crt ssl/ca.crt) ssl/server.crt >> tracefile.out

if [[ ! -d  $(pwd)/route-template ]]; then
  mkdir $(pwd)/route-template
else
  rm $(pwd)/route-template/*.yml
fi

# Create empty cert file if not exists
touch $(pwd)/ssl/tabulatecert.crt

# Create empty key file if not exists
touch $(pwd)/ssl/tabulatekey.key

# Read every line and append it with a new tab character at the begining to a new file
input=$(pwd)/ssl/fullchain.crt
while IFS= read -r line
do
  echo "      $line" >> $(pwd)/ssl/tabulatecert.crt
done < "$input"

# Read every line and append it with a new tab character at the begining to a new file
input=$(pwd)/ssl/intermediate.key
while IFS= read -r line
do
  echo "      $line" >> $(pwd)/ssl/tabulatekey.key
done < "$input"

key=$(cat ssl/tabulatekey.key)
cert=$(cat ssl/tabulatecert.crt)

echo "apiVersion: route.openshift.io/v1" >> route-template/route.yml
echo "kind: Route" >> route-template/route.yml
echo "metadata:" >> route-template/route.yml
echo "  name: loadbalancer-route" >> route-template/route.yml
echo "spec:" >> route-template/route.yml
echo "  host: $host" >> route-template/route.yml
echo "  path: /" >> route-template/route.yml
echo "  to:" >> route-template/route.yml
echo "    kind: Service" >> route-template/route.yml
echo "    name: loadbalancer" >> route-template/route.yml
echo "  port:" >> route-template/route.yml
echo "    targetPort: http" >> route-template/route.yml
echo "  tls:" >> route-template/route.yml
echo "    termination: edge" >> route-template/route.yml
echo "    key: |" >> route-template/route.yml
echo "$key" >> route-template/route.yml
echo "    certificate: |" >> route-template/route.yml
echo "$cert" >> route-template/route.yml

# Deploys route to the Openshift cluster
oc apply -f route-template/route.yml

# Declare an array and delete arguments
declare -a ARGS=()
declare -i argcounter=0
for var in "$@"; do
    ((argcounter++))

    # Ignore host and domain arguments
    if (( $argcounter < 5 )); then
        continue
    fi

    ARGS+=($var)
done

$HELM_BIN "${ARGS[@]}"
