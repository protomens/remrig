#!/bin/bash

#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root i.e., sudo"
#  exit
#fi

# Check python3 dependencies
return=`pip list | grep "Flask"`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing Flask..."
	pip -qqq install flask
	echo "Done."
else
	echo "Flask is installed."
fi

return=`pip list | grep "Flask-HTTPAuth"`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing Flask-HTTPAuth..."
	pip -qqq install flask_httpauth
	echo "Done."
else
	echo "Flask_HTTPAuth is installed."
fi

return=`pip list | grep "Flask-SQLAlchemy"`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing Flask-SQLAlchemy..."
	pip -qqq install flask_sqlalchemy
	echo "Done."
else
	echo "Flask_SQLAlchemy is installed."
fi


return=`pip list | grep "passlib"`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing passlib..."
	pip -qqq install passlib
	echo "Done."
else
	echo "Passlib is installed."
fi

return=`dpkg -l uwsgi`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing uwsgi..."
	sudo apt-get install uwsgi -y
	echo "Done."
else
	echo "uWSGI is installed."
fi

return=`dpkg -l uwsgi-plugin-python3`
returnval=$?
if [ "$returnval" -ne 0 ]; then
	echo -ne "Installing uwsgi-plugin-python3..."
	sudo apt-get install uwsgi-plugin-python3 -y
	echo "Done."
else
	echo "uWSGI-plugin-python3 is installed."
fi


sleep 2
echo "We will now edit /etc/sudoers to make '$USER' have passwordless sudo."
echo -ne "This step is essential for remrig to work. Continue? (press enter)"
read nous

sudo sh -c 'echo "$SUDO_USER ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers'
echo "Done."

sleep 2

echo "Setting up remrig...."
chmod +x ./*
echo -ne "Making remrig db directory..."
mkdir $HOME/dbs
sleep 2
echo "Done."
echo -ne "Creating self-signed certificate and key file...."
openssl ecparam -out ec_key.pem -name prime256v1 -genkey
openssl req -new -key ec_key.pem -x509 -nodes -days 365 -out cert.pem -config cert.conf
echo "Done."
sleep 1
echo "Starting remrig..." 
./remrig.sh 127.0.0.1 &
sleep 4
echo "done."

echo "Creating user for Remrig..."
sleep 2
blarg=`openssl rand -base64 16`
curl -k -i -X POST -H "Content-Type: application/json" -d '{"username":"xmrig","password":"'"$blarg"'"}' https://127.0.0.1:5000/api/users
echo "---------------------------------"
echo "Username: xmrig"
echo "Password: $blarg"
echo ""
echo "Store these in your password vault before continuting."
echo "These credentials are needed for Monerado remote control."
sleep 7

echo "Shutting down remrig..."
uwsgi --stop /tmp/remrig.pid
echo "Done."
sleep 1
echo " "
echo "--------------------------------------------------------------------"
echo "                        Setup is complete.                          "
echo " "
echo " You can run remrig on your own by running:                         "
echo " "
echo " ./remrig.sh <ipbind>"
echo " "
echo " Where <ipbind> is the ip address you want to bind to               "
echo " "
echo " Enjoy!"
echo "--------------------------------------------------------------------"



echo 