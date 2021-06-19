#!/bin/bash
#
# blarg=`openssl rand -base64 16`

# curl -i -X POST -H "Content-Type: application/json" -d '{"username":"xmrig","password":"$blarg"}' http://127.0.0.1:5000/api/users
#
# Self-signed certificate:
#
#openssl ecparam -out ec_key.pem -name secp256r1 -genkey
#openssl req -new -key ec_key.pem -x509 -nodes -days 365 -out cert.pem 

if [[ "$#" -lt 1 ]]; then
	echo " "
	echo "Remrig shell v0.1.0 (johnny neumonic)"
	echo " "
	echo "Usage: $0 <iptobind>"
	echo " "
	exit
fi

IPADDY=$1

cwd=`pwd`
#echo "Enter IP address of interface you wish to host Remrig: "
#read -r IPADDY
echo "CWD: $cwd"
uwsgi  --plugin python3 --https-socket $IPADDY:5000,$cwd/cert.pem,$cwd/ec_key.pem --wsgi-file uWSGI.py --callable app --processes 4 --threads 4 --stats $IPADDY:9191 --uid root --pidfile /tmp/remrig.pid &
