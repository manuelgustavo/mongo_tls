#!/bin/bash
set -euo pipefail

script_path=$(realpath "$(dirname "$0")")
pushd "${script_path}"

rm -fr ssl
mkdir -p ssl
cd ssl
openssl req -newkey rsa:2048 -nodes -keyout mongodbkey.key -x509 -days 365 -out mongodbkey.crt -subj "/C=US/ST=New Sweden/L=Stockholm /O=.../OU=.../CN=.../emailAddress=..."
cat mongodbkey.key mongodbkey.crt > mongodb.pem
cd ..
docker build -t mongo_local .
