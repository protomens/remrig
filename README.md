# remrig
Remote Control of XMRig

Using flask and other python libraries this program sets up a public REST API environment on your server/workstation. It is accessible by public IP or through a service like *ngrok*. Personally, I use both. I have remote servers with public IP address and also my private home workstations which are behind a VPN where I expose the **remrig** REST API via *ngrok*.

The API is accessible through username:password credentials, which are setup at runtime, and comes built with it's own self-signed SSL certificate to ensure data security. We handle 98% of the setup work in our **setup.sh** script. 

### Note
As some of you might know, **xmrig** needs to be run as *root* or *Administrator* when applying the **msr** module. Hence, we ask permission in our **setup.sh** script to allow a passwordless SUDO operation by the user using **remrig** and **xmrig**. 

**remrig** itself does not need to be run as root, so there is no security implications there. It does fork a **xmrig** subprocess in *root* UID. If you already run **xmrig** as root, then this is not changing a thing - except giving your user passwordless sudo operation. This can be changed anytime by editing: */etc/sudoers* 

### Support

Currently only *nix* type machines are supported. We do have aspirations to make this widely avaialble to the Windows community. **remrig** is fully operational and so most of the remaining updates to this git will be in support of Windows servers/workstations.

We've tested this on Ubuntu 20.04 servers and everything seems to be a.ok.


## Installation

First clone this github repository:
```
mkdir $HOME/git
cd $HOME/git
git clone https://github.com/protomens/remrig
```

Make all files in the repository executable:
```
cd remrig
chmod +x *
```

Create a symbolic link to your **xmrig** executable that is findable in the environment variable *PATH* i.e.,

```
ln -s /home/protomens/git/xmrig/build/xmrig /usr/local/bin/xmrig
```

Run **setup.sh**
```
./setup.sh
```

Be sure to note your **remrig** username and password which is created upon executing the setup script. THIS IS IMPORTANT! SO DON'T LOSE IT!

The setup script adds any necessary repositories needed to run **remrig**. It may require sudo if *uwsgi* and similar python API commands are not found. It will prompt you for your username password to add these if necessary. 

## Running

Simply run **remrig** by executing the bash shell script and providing the IP address you wish this API to bind to. i.e.:

```
./remrig.sh 192.168.4.69
```
which would need to be exposed via port forwarding on your router or with *ngrok*. **remrig** always runs on port 5000. This can be changed by editing remrig.sh and setting the port of your choice. 

### Testing
At this stage, only the REST API is running, not **xmrig**. To test the functionality of the API simply run curl with creditials to the API endpoint. i.e.:

To start **xmrig**: 
```
$ curl -u xmrig:password -i -X GET "http://192.168.4.69:5000/api/xmrig?action=start"
```
To stop **xmrig**:
```
$ curl -u xmrig:password -i -X GET "http://192.168.4.69:5000/api/xmrig?action=stop"
```

If there is an instance of **xmrig** already running the *start* action it will not spawn another instance. It checks for an already running process and if true then returns null.

## Monerado
![https://i.imgur.com/UjEMB0L.png](https://i.imgur.com/UjEMB0L.png)

We have integrated this feature into our **Monerado** app which is available at: http://eratosthen.es

This allows for control of your *xmrig* instances via our app. **Note**: This app is only designed for Monero Ocean at the moment. More pools will be added in the future. 

### Buy us a coffe (or two)

![https://i.imgur.com/2eZdcrV.png](https://i.imgur.com/2eZdcrV.png)

89eWmQeta2ZS1VPYBePHPyaQsMQkMa3C8EMhTEjSr228MgvtF3qhCHXKUmZy5Ww6gei3r7ozmghHyTb4S1iK55m8SUBUw7Y


